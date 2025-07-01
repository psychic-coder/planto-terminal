#!/bin/bash

# Planto Setup Script
# This script sets up Planto locally after rebranding from Plandex

set -e

echo "🚀 Setting up Planto locally..."
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    if ! docker compose version &> /dev/null; then
        echo "❌ Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

echo "✅ All prerequisites found!"
echo ""

# Setup Go workspace for building CLI
echo "🔧 Setting up Go workspace..."
cd app
go work init || true
go work use . ./cli ./shared || true

# Try to build the CLI
echo "🛠️  Building Planto CLI..."
cd cli
go mod download
go mod tidy

# Build the CLI binary
if go build -o planto .; then
    echo "✅ CLI built successfully!"
    
    # Create symlink for short alias
    ln -sf "./planto" "./pto" 2>/dev/null || true
    
    # Make binaries executable
    chmod +x planto pto
    
    echo "📦 Created CLI binaries:"
    echo "  - planto (main command)"
    echo "  - pto (short alias)"
else
    echo "⚠️  CLI build failed. You can still use Docker mode."
    echo "   The server will work, but you'll need to install the CLI separately."
fi

cd ../..

echo ""
echo "🐳 Setting up Docker environment..."

# Make sure Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running!"
echo ""

echo "🎉 Planto setup complete!"
echo ""
echo "📚 Next steps:"
echo ""
echo "1. Start the Planto server:"
echo "   cd app && ./start_local.sh"
echo ""
echo "2. Set up API keys (in a new terminal):"
echo "   export OPENROUTER_API_KEY=your_openrouter_key"
echo "   export OPENAI_API_KEY=your_openai_key  # optional"
echo ""
echo "3. If CLI was built successfully, you can use:"
echo "   cd app/cli && ./planto"
echo "   cd app/cli && ./pto  # short alias"
echo ""
echo "4. Otherwise, install the CLI separately:"
echo "   curl -sL https://plandex.ai/install.sh | bash"
echo "   # Then use 'plandex' instead of 'planto' until CLI is updated"
echo ""
echo "🌐 Server will be available at: http://localhost:8099"
echo "🗄️  Database will be on port: 5433 (to avoid conflicts)"
echo ""
echo "Happy coding with Planto! 🎯"
