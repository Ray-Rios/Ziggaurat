const std = @import("std");
const http = std.http;
const net = std.net;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = try net.Address.parseIp("0.0.0.0", 80);
    var server = net.StreamServer.init(.{
        .reuse_address = true,
    });
    defer server.deinit();
    
    try server.listen(address);

    std.debug.print("Server listening on http://0.0.0.0:80\n", .{});

    while (true) {
        const connection = try server.accept();
        _ = try std.Thread.spawn(.{}, handleConnection, .{ allocator, connection });
    }
}

fn handleConnection(allocator: std.mem.Allocator, connection: net.StreamServer.Connection) !void {
    defer connection.stream.close();

    var read_buffer: [4096]u8 = undefined;
    const bytes_read = try connection.stream.read(&read_buffer);
    
    if (bytes_read == 0) return;

    const request = read_buffer[0..bytes_read];
    
    // Simple routing
    if (std.mem.indexOf(u8, request, "GET / ")) |_| {
        try serveIndex(connection.stream);
    } else if (std.mem.indexOf(u8, request, "POST /execute")) |_| {
        try executeCommand(allocator, connection.stream, request);
    } else {
        try serve404(connection.stream);
    }
}

fn serveIndex(stream: net.Stream) !void {
    const html = @embedFile("index.html");
    const response = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: {d}\r\n\r\n{s}",
        .{ html.len, html }
    );
    defer std.heap.page_allocator.free(response);
    _ = try stream.write(response);
}

fn serve404(stream: net.Stream) !void {
    const response = "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found";
    _ = try stream.write(response);
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

fn executeCommand(allocator: std.mem.Allocator, stream: net.Stream, request: []const u8) !void {
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

    // Execute PowerShell command
    var child = std.process.Child.init(&[_][]const u8{ "pwsh", "-Command", command }, allocator);
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
    
    _ = try stream.write(response);
}