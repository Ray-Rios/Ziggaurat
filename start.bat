@echo off
echo.
echo 🚀 Starting PowerShell Terminal Web Application...
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo 📦 Building Docker image...
    docker build -t powershell-terminal .
    
    if errorlevel 1 (
        echo ❌ Failed to build the Docker image
        pause
        exit /b 1
    )
    
    echo 🏃 Starting container...
    docker run -d -p 80:80 --name powershell-terminal powershell-terminal
    
    if errorlevel 1 (
        echo ❌ Failed to start the container
        pause
        exit /b 1
    )
    
    echo.
    echo ✅ Application started successfully!
    echo 🌐 Open your browser and navigate to: http://localhost:80
    echo.
    echo 📋 Useful commands:
    echo    View logs:     docker logs -f powershell-terminal
    echo    Stop app:      docker stop powershell-terminal
    echo    Remove app:    docker rm powershell-terminal
    echo.
) else (
    echo 📦 Building and starting with Docker Compose...
    docker-compose up --build -d
    
    if errorlevel 1 (
        echo ❌ Failed to start the application
        pause
        exit /b 1
    )
    
    echo.
    echo ✅ Application started successfully!
    echo 🌐 Open your browser and navigate to: http://localhost:80
    echo.
    echo 📋 Useful commands:
    echo    View logs:     docker-compose logs -f
    echo    Stop app:      docker-compose down
    echo    Restart app:   docker-compose restart
    echo.
)

pause