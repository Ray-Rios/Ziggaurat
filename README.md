# PowerShell Terminal Web Application

A beautiful, modern web-based PowerShell terminal built with Zig, featuring a collapsible sidebar with pre-configured Windows administrative commands and elegant animations.

## Features

✨ **Modern UI Design**
- Dark theme with smooth gradients and animations
- Collapsible sidebar for easy navigation
- Responsive layout that works on various screen sizes

🎨 **Elegant Animations**
- Smooth transitions and hover effects
- Fade-in animations for terminal output
- Slide-in animations for command list items
- Loading indicators for command execution

⚡ **Powerful Functionality**
- Execute PowerShell commands directly from the web interface
- 20+ pre-configured Windows administrative commands
- Save and manage your own custom commands
- Search functionality to quickly find commands
- Real-time command output display

🔧 **Pre-configured Commands Include:**
- System Information & Diagnostics
- Service & Process Management
- Network Configuration & Monitoring
- Disk Usage & Storage Management
- User & Group Management
- Security & Firewall Rules
- Event Logs & System Errors
- Windows Updates & Hotfixes
- And much more!

## Architecture

- **Backend**: Zig web server (high-performance, memory-safe)
- **Frontend**: Pure HTML, CSS, and JavaScript (no dependencies)
- **Container**: Docker with Ubuntu 22.04
- **PowerShell**: PowerShell 7.x for cross-platform compatibility

## Prerequisites

- Docker
- Docker Compose (optional, but recommended)

## Quick Start

### Using Docker Compose (Recommended)

1. Clone or download this repository
2. Navigate to the project directory
3. Start the application:

```bash
docker-compose up -d
```

4. Open your browser and navigate to:
```
http://localhost:80
```

### Using Docker Directly

1. Build the Docker image:
```bash
docker build -t powershell-terminal .
```

2. Run the container:
```bash
docker run -d -p 80:80 --name powershell-terminal powershell-terminal
```

3. Access the application at `http://localhost:80`

## Usage Guide

### Executing Commands

1. **From the Input Field**: Type any PowerShell command in the input field and click "Execute" or press Enter
2. **From Saved Commands**: Click any command in the sidebar to populate the input field, then execute

### Managing Saved Commands

- **Add New Command**: Click the "+ Add Command" button at the bottom of the sidebar
- **Search Commands**: Use the search box at the top of the sidebar to filter commands
- **Toggle Sidebar**: Click the hamburger menu (☰) to show/hide the sidebar

### Customizing Commands

Commands are stored in your browser's local storage. To add a new command:

1. Click "+ Add Command"
2. Enter a name for the command
3. Enter the PowerShell command
4. Optionally add a description
5. Click "Save"

## Development Environment Suggestions

### For an Enhanced Development Experience:

1. **Volume Mounting for Live Development**
   - Mount your source directory to enable live code changes:
   ```bash
   docker run -d -p 80:80 -v $(pwd)/src:/app/src powershell-terminal
   ```

2. **Logging and Debugging**
   - View container logs:
   ```bash
   docker logs -f powershell-terminal
   ```

3. **Shell Access**
   - Access the container shell for debugging:
   ```bash
   docker exec -it powershell-terminal /bin/bash
   ```

4. **Custom PowerShell Scripts**
   - Place scripts in the `powershell_scripts` directory (auto-created)
   - They'll be accessible from `/app/powershell_scripts` in the container

### Recommended VS Code Extensions

- Zig Language (for Zig syntax highlighting)
- Docker (for container management)
- PowerShell (for script editing)
- Live Server (for frontend development)

## Project Structure

```
.
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Docker Compose configuration
├── build.zig              # Zig build configuration
├── README.md              # This file
├── src/
│   ├── main.zig          # Zig web server implementation
│   └── index.html        # Frontend UI with embedded CSS/JS
└── powershell_scripts/   # Directory for custom PowerShell scripts
```

## Customization

### Changing the Port

Edit `docker-compose.yml` or the docker run command:
```yaml
ports:
  - "8080:80"  # Change 8080 to your desired port
```

### Modifying the UI Theme

The UI uses CSS custom properties (variables) for easy theming. Edit the `:root` section in `src/index.html`:

```css
:root {
    --primary-bg: #1e1e2e;      /* Main background color */
    --secondary-bg: #2a2a3e;    /* Secondary background */
    --accent: #89b4fa;          /* Accent color */
    --text: #cdd6f4;            /* Text color */
    /* ... more variables ... */
}
```

### Adding More Default Commands

Edit the `defaultCommands` array in `src/index.html`:

```javascript
const defaultCommands = [
    { 
        name: "Your Command Name", 
        command: "Your-PowerShell-Command", 
        description: "Command description" 
    },
    // ... more commands
];
```

## Security Considerations

⚠️ **Important Security Notes:**

1. **Local Use Only**: This application is designed for local development and administration
2. **No Authentication**: There is no built-in authentication system
3. **Command Execution**: The application executes PowerShell commands with the container's permissions
4. **Network Exposure**: Do not expose this application to the public internet without proper security measures

### Recommended Security Practices:

- Run the container with limited privileges
- Use Docker networks to isolate the container
- Implement authentication if deploying in a shared environment
- Regularly update the base image and dependencies
- Review and audit executed commands

## Troubleshooting

### Container Won't Start
```bash
# Check container logs
docker logs powershell-terminal

# Verify port availability
netstat -an | grep :80
```

### PowerShell Commands Fail
- Ensure PowerShell is properly installed in the container
- Check command syntax (use PowerShell 7 syntax)
- Verify container has necessary permissions

### UI Not Loading
- Clear browser cache
- Check browser console for errors
- Verify the container is running: `docker ps`

### Port Already in Use
```bash
# Find process using port 80
netstat -ano | findstr :80  # Windows
lsof -i :80                 # Linux/Mac

# Use a different port
docker run -p 8080:80 powershell-terminal
```

## Performance Optimization

- **Zig Optimization**: The application is built with `-Doptimize=ReleaseFast` for maximum performance
- **Memory Efficiency**: Zig's memory management ensures low overhead
- **Async Handling**: The server handles connections asynchronously for better concurrency

## Contributing

Suggestions for improvements:

1. **Authentication System**: Add user authentication and session management
2. **Command History**: Implement persistent command history
3. **Multi-tab Support**: Allow multiple terminal sessions
4. **Syntax Highlighting**: Add PowerShell syntax highlighting in the input
5. **Export Results**: Add ability to export command outputs
6. **Themes**: Create additional color themes
7. **Command Scheduling**: Add ability to schedule commands
8. **Remote Execution**: Support for remote PowerShell sessions

## License

This project is provided as-is for educational and development purposes.

## Acknowledgments

- Built with [Zig](https://ziglang.org/) - A general-purpose programming language
- Styled with modern CSS3 features
- Powered by [PowerShell](https://github.com/PowerShell/PowerShell)
- Color scheme inspired by Catppuccin theme

## Version History

- **v1.0.0** - Initial release
  - Zig web server implementation
  - Modern UI with animations
  - 20+ pre-configured Windows admin commands
  - Command save/search functionality
  - Docker containerization

---

**Enjoy your beautiful PowerShell terminal! 🚀**