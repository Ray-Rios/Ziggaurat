# Project Structure

```
powershell-terminal/
│
├── 📄 Dockerfile                    # Docker image configuration
├── 📄 docker-compose.yml            # Docker Compose orchestration
├── 📄 build.zig                     # Zig build system configuration
│
├── 📁 src/                          # Source code directory
│   ├── 📄 main.zig                  # Zig web server (backend)
│   └── 📄 index.html                # Web UI (frontend with embedded CSS/JS)
│
├── 📁 powershell_scripts/           # Custom PowerShell scripts (auto-created)
│   └── (your custom .ps1 files)
│
├── 📄 start.sh                      # Linux/Mac startup script
├── 📄 start.bat                     # Windows startup script
│
├── 📄 README.md                     # Comprehensive documentation
├── 📄 QUICKSTART.md                 # Quick start guide
├── 📄 PROJECT_STRUCTURE.md          # This file
│
├── 📄 .dockerignore                 # Docker build exclusions
├── 📄 .gitignore                    # Git exclusions
│
└── 📁 zig-out/                      # Build output (auto-generated)
    └── bin/
        └── powershell-terminal      # Compiled executable
```

## File Descriptions

### Core Application Files

#### `src/main.zig`
The heart of the application - a high-performance web server written in Zig that:
- Listens on port 80
- Serves the HTML frontend
- Handles PowerShell command execution via POST requests
- Manages concurrent connections asynchronously
- Returns command output as JSON

**Key Functions:**
- `main()` - Initializes server and accepts connections
- `handleConnection()` - Routes HTTP requests
- `serveIndex()` - Serves the HTML page
- `executeCommand()` - Executes PowerShell commands and returns results

#### `src/index.html`
A self-contained single-page application with:
- **HTML** - Structure and layout
- **CSS** - Styling with custom properties for theming
- **JavaScript** - Command execution, UI interactions, local storage

**Features:**
- 625 lines of beautiful, well-organized code
- Responsive design
- Smooth animations and transitions
- Local storage for saved commands
- Real-time command execution
- Search and filter functionality

### Configuration Files

#### `Dockerfile`
Multi-stage Docker configuration that:
1. Installs Zig compiler (v0.11.0)
2. Installs PowerShell 7.x
3. Copies source files
4. Builds the Zig application
5. Exposes port 80
6. Runs the compiled binary

#### `docker-compose.yml`
Simplified deployment configuration:
- Maps port 80
- Mounts `powershell_scripts` volume
- Sets timezone
- Configures restart policy

#### `build.zig`
Zig build system configuration:
- Defines executable target
- Sets optimization level
- Configures build and run steps

### Documentation Files

#### `README.md`
Comprehensive documentation covering:
- Features and architecture
- Installation and setup
- Usage guide
- Customization options
- Security considerations
- Troubleshooting
- Contributing guidelines

#### `QUICKSTART.md`
Fast-track guide for:
- Prerequisites
- Quick installation
- First steps
- Common commands
- Troubleshooting

#### `PROJECT_STRUCTURE.md`
This file - explains the project organization

### Utility Files

#### `start.sh` (Linux/Mac)
Bash script that:
- Checks for Docker installation
- Builds the Docker image
- Starts the container
- Provides helpful commands

#### `start.bat` (Windows)
Batch script that:
- Checks for Docker installation
- Builds the Docker image
- Starts the container
- Provides helpful commands

### Build Artifacts (Auto-generated)

#### `zig-out/`
Generated during build process:
- `bin/powershell-terminal` - Compiled executable
- Intermediate build files

#### `zig-cache/`
Zig compiler cache directory

#### `powershell_scripts/`
Volume mount point for custom scripts:
- Created automatically on first run
- Accessible from container at `/app/powershell_scripts`
- Persists between container restarts

## Data Flow

```
┌─────────────┐
│   Browser   │
│  (User UI)  │
└──────┬──────┘
       │ HTTP Request
       ▼
┌─────────────────────┐
│   Zig Web Server    │
│   (src/main.zig)    │
└──────┬──────────────┘
       │ Execute
       ▼
┌─────────────────────┐
│   PowerShell 7.x    │
│  (in container)     │
└──────┬──────────────┘
       │ Output
       ▼
┌─────────────────────┐
│   JSON Response     │
│   (stdout/stderr)   │
└──────┬──────────────┘
       │ Display
       ▼
┌─────────────┐
│   Browser   │
│  (Terminal) │
└─────────────┘
```

## Technology Stack

### Backend
- **Language**: Zig 0.11.0
- **Runtime**: PowerShell 7.x
- **Server**: Custom HTTP server (built-in Zig)
- **Concurrency**: Async/multi-threaded

### Frontend
- **HTML5**: Semantic markup
- **CSS3**: Custom properties, animations, gradients
- **JavaScript**: ES6+, Fetch API, LocalStorage

### Infrastructure
- **Container**: Docker
- **Base Image**: Ubuntu 22.04
- **Orchestration**: Docker Compose (optional)

## Development Workflow

1. **Edit Source**: Modify `src/main.zig` or `src/index.html`
2. **Rebuild**: Run `docker-compose up --build`
3. **Test**: Access `http://localhost:80`
4. **Debug**: Check logs with `docker-compose logs -f`
5. **Iterate**: Repeat as needed

## Customization Points

### UI Theme
Edit CSS variables in `src/index.html`:
```css
:root {
    --primary-bg: #1e1e2e;
    --accent: #89b4fa;
    /* ... */
}
```

### Default Commands
Edit JavaScript array in `src/index.html`:
```javascript
const defaultCommands = [
    { name: "...", command: "...", description: "..." },
    // ...
];
```

### Server Port
Edit `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # External:Internal
```

### Zig Optimization
Edit `Dockerfile`:
```dockerfile
RUN zig build -Doptimize=ReleaseFast  # or Debug, ReleaseSafe, ReleaseSmall
```

## Security Notes

⚠️ **Important**: 
- The application has no authentication
- PowerShell commands run with container permissions
- Designed for local development only
- Do not expose to public internet without security measures

## Resource Requirements

- **Disk Space**: ~500MB (Docker image)
- **Memory**: ~100MB (running container)
- **CPU**: Minimal (Zig is highly efficient)

---

**Understanding the structure helps you customize and extend the application! 🏗️**