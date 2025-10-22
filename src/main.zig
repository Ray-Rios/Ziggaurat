const std = @import("std");
const http = std.http;
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = try net.Address.parseIp("0.0.0.0", 80);
    const socket = try posix.socket(address.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
    defer posix.close(socket);
    
    try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(socket, &address.any, address.getOsSockLen());
    try posix.listen(socket, 128);

    std.debug.print("Server listening on http://0.0.0.0:80\n", .{});

    while (true) {
        var client_address: net.Address = undefined;
        var client_address_len: posix.socklen_t = @sizeOf(net.Address);
        const client_socket = try posix.accept(socket, &client_address.any, &client_address_len, 0);
        
        _ = try std.Thread.spawn(.{}, handleConnection, .{ allocator, client_socket });
    }
}

fn handleConnection(allocator: std.mem.Allocator, socket: posix.socket_t) !void {
    defer posix.close(socket);

    var read_buffer: [4096]u8 = undefined;
    const bytes_read = try posix.read(socket, &read_buffer);
    
    if (bytes_read == 0) return;

    const request = read_buffer[0..bytes_read];
    
    // Simple routing
    if (std.mem.indexOf(u8, request, "GET / ")) |_| {
        try serveIndex(socket);
    } else if (std.mem.indexOf(u8, request, "POST /execute")) |_| {
        try executeCommand(allocator, socket, request);
    } else {
        try serve404(socket);
    }
}

fn serveIndex(socket: posix.socket_t) !void {
    const html = @embedFile("index.html");
    const response = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: {d}\r\n\r\n{s}",
        .{ html.len, html }
    );
    defer std.heap.page_allocator.free(response);
    _ = try posix.write(socket, response);
}

fn serve404(socket: posix.socket_t) !void {
    const response = "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found";
    _ = try posix.write(socket, response);
}

fn escapeJson(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var escaped = std.ArrayList(u8).init(allocator);
    defer escaped.deinit();
    
    for (input) |c| {
        switch (c) {
            '"' => try escaped.appendSlice("\\\""),
            '\\' => try escaped.appendSlice("\\\\"),
            '\n' => try escaped.appendSlice("\\n"),
            '\r' => try escaped.appendSlice("\\r"),
            '\t' => try escaped.appendSlice("\\t"),
            0x08 => try escaped.appendSlice("\\b"),
            0x0C => try escaped.appendSlice("\\f"),
            else => {
                if (c < 0x20) {
                    try escaped.writer().print("\\u{x:0>4}", .{c});
                } else {
                    try escaped.append(c);
                }
            },
        }
    }
    
    return escaped.toOwnedSlice();
}

fn executeCommand(allocator: std.mem.Allocator, socket: posix.socket_t, request: []const u8) !void {
    // Extract command from request body
    const body_start = std.mem.indexOf(u8, request, "\r\n\r\n") orelse return error.InvalidRequest;
    const body = request[body_start + 4..];
    
    // Parse JSON to get command
    var command: []const u8 = "";
    if (std.mem.indexOf(u8, body, "\"command\":\"")) |cmd_start| {
        const cmd_value_start = cmd_start + 11;
        if (std.mem.indexOfPos(u8, body, cmd_value_start, "\"")) |cmd_end| {
            command = body[cmd_value_start..cmd_end];
        }
    }

    // Execute PowerShell command (using Windows PowerShell, not PowerShell Core)
    var child = std.process.Child.init(&[_][]const u8{ "powershell.exe", "-Command", command }, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    
    try child.spawn();
    const stdout = try child.stdout.?.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(stdout);
    
    const stderr = try child.stderr.?.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(stderr);
    
    _ = try child.wait();

    // Escape JSON strings
    const escaped_stdout = try escapeJson(allocator, stdout);
    defer allocator.free(escaped_stdout);
    
    const escaped_stderr = try escapeJson(allocator, stderr);
    defer allocator.free(escaped_stderr);

    // Send response
    const json_response = try std.fmt.allocPrint(
        allocator,
        "{{\"stdout\":\"{s}\",\"stderr\":\"{s}\"}}",
        .{ escaped_stdout, escaped_stderr }
    );
    defer allocator.free(json_response);

    const response = try std.fmt.allocPrint(
        allocator,
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {d}\r\n\r\n{s}",
        .{ json_response.len, json_response }
    );
    defer allocator.free(response);
    
    _ = try posix.write(socket, response);
}