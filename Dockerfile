# Use Windows Server Core with PowerShell
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install Chocolatey package manager
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Zig using Chocolatey
RUN choco install zig -y

# Set up the working directory
WORKDIR C:\\app

# Copy the project files
COPY build.zig .
COPY src/ ./src/

# Build the Zig application
RUN zig build -Doptimize=ReleaseFast

# Expose port 80
EXPOSE 80

# Run the Zig application
CMD ["C:\\app\\zig-out\\bin\\powershell-terminal.exe"]