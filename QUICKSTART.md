# Quick Start Guide

Get your PowerShell Terminal Web Application up and running in minutes!

## Prerequisites

✅ **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop/)
- Make sure Docker is running before proceeding

## Starting the Application

### Option 1: Using the Start Script (Easiest)

#### Windows:
1. Double-click `start.bat`
2. Wait for the build to complete
3. Open your browser to `http://localhost:80`

#### Linux/Mac:
```bash
chmod +x start.sh
./start.sh
```

### Option 2: Using Docker Compose

```bash
docker-compose up --build -d
```

### Option 3: Using Docker Directly

```bash
# Build the image
docker build -t powershell-terminal .

# Run the container
docker run -d -p 80:80 --name powershell-terminal powershell-terminal
```

## Accessing the Application

Once started, open your web browser and navigate to:

```
http://localhost:80
```

You should see a beautiful dark-themed terminal interface with a sidebar of pre-configured commands!

## First Steps

1. **Explore Pre-configured Commands**
   - Check out the 20+ Windows administrative commands in the sidebar
   - Click any command to load it into the input field

2. **Execute Your First Command**
   - Try: `Get-ComputerInfo` for system information
   - Or: `Get-Process` to see running processes

3. **Add Your Own Commands**
   - Click the "+ Add Command" button
   - Save your frequently used commands for quick access

4. **Search Commands**
   - Use the search box at the top of the sidebar
   - Quickly find the command you need

## Common Commands

### View Logs
```bash
# Docker Compose
docker-compose logs -f

# Docker
docker logs -f powershell-terminal
```

### Stop the Application
```bash
# Docker Compose
docker-compose down

# Docker
docker stop powershell-terminal
```

### Restart the Application
```bash
# Docker Compose
docker-compose restart

# Docker
docker restart powershell-terminal
```

## Troubleshooting

### Port 80 Already in Use?

Change the port in `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Use port 8080 instead
```

Or when using Docker directly:
```bash
docker run -d -p 8080:80 --name powershell-terminal powershell-terminal
```

Then access at `http://localhost:8080`

### Docker Not Running?

Make sure Docker Desktop is running:
- **Windows**: Check system tray for Docker icon
- **Mac**: Check menu bar for Docker icon
- **Linux**: Run `sudo systemctl start docker`

### Build Fails?

1. Make sure you have a stable internet connection (downloads Zig and PowerShell)
2. Check Docker has enough disk space
3. Try cleaning Docker cache:
   ```bash
   docker system prune -a
   ```

### Commands Not Executing?

1. Check if PowerShell is installed in the container:
   ```bash
   docker exec -it powershell-terminal pwsh --version
   ```

2. View container logs for errors:
   ```bash
   docker logs powershell-terminal
   ```

## Tips for Best Experience

🎨 **UI Features:**
- Click the ☰ button to toggle the sidebar
- Hover over commands for smooth animations
- Use the search box to filter commands quickly

⚡ **Performance:**
- The Zig backend is optimized for speed
- Commands execute in real-time
- Output appears with smooth animations

💾 **Data Persistence:**
- Your saved commands are stored in browser localStorage
- They persist across browser sessions
- Export/backup not yet implemented (coming soon!)

## Next Steps

Check out the full [README.md](README.md) for:
- Detailed architecture information
- Customization options
- Security considerations
- Development environment setup
- Contributing guidelines

## Need Help?

- Review the [README.md](README.md) for detailed documentation
- Check container logs for error messages
- Ensure Docker Desktop has sufficient resources allocated

---

**Enjoy your PowerShell Terminal! 🚀**