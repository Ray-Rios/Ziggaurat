#!/bin/bash

echo "🚀 Starting PowerShell Terminal Web Application..."
echo ""

# Check if Docker is installed
#if ! command -v docker &> /dev/null; then
#    echo "❌ Docker is not installed. Please install Docker first."
#    exit 1
#fi

# Check if Docker Compose is installed
if command -v docker-compose &> /dev/null; then
    echo "📦 Building and starting with Docker Compose..."
    docker-compose up --build -d
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Application started successfully!"
        echo "🌐 Open your browser and navigate to: http://localhost:80"
        echo ""
        echo "📋 Useful commands:"
        echo "   View logs:     docker-compose logs -f"
        echo "   Stop app:      docker-compose down"
        echo "   Restart app:   docker-compose restart"
    else
        echo "❌ Failed to start the application"
        exit 1
    fi
else
    echo "📦 Building Docker image..."
    docker build -t powershell-terminal .
    
    if [ $? -eq 0 ]; then
        echo "🏃 Starting container..."
        docker run -d -p 80:80 --name powershell-terminal powershell-terminal
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Application started successfully!"
            echo "🌐 Open your browser and navigate to: http://localhost:80"
            echo ""
            echo "📋 Useful commands:"
            echo "   View logs:     docker logs -f powershell-terminal"
            echo "   Stop app:      docker stop powershell-terminal"
            echo "   Remove app:    docker rm powershell-terminal"
        else
            echo "❌ Failed to start the container"
            exit 1
        fi
    else
        echo "❌ Failed to build the Docker image"
        exit 1
    fi
fi