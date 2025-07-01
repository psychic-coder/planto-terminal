# Running Planto Locally

This guide will help you set up and run Planto (rebranded from Plandex) on your local machine.

## Overview

Planto is an AI-powered coding assistant that can plan and execute large coding tasks. This rebranded version uses:
- **Main command**: `planto` 
- **Short alias**: `pto` (instead of `pdx`)
- **Server**: Runs on `http://localhost:8099`
- **Database**: PostgreSQL on port `5433` (to avoid conflicts)

## Prerequisites

Before starting, ensure you have:

- **Docker & Docker Compose**: For running the server and database
- **Git**: For version control
- **Go 1.19+**: For building the CLI (optional)

### Check Prerequisites

```bash
# Check Docker
docker --version
docker compose version

# Check Git
git --version

# Check Go (optional)
go version
```

## Quick Setup

### 1. Run the Setup Script

```bash
cd /Users/rohitganguly/desktop/planto
./setup-planto.sh
```

This script will:
- ✅ Check all prerequisites
- 🔧 Set up Go workspace
- 🛠️ Try to build the CLI
- 🐳 Verify Docker is running
- 📦 Create command aliases

### 2. Start the Server

```bash
cd app
./start_local.sh
```

This will:
- 🐳 Pull the latest Planto Docker images
- 🗄️ Start PostgreSQL database on port 5433
- 🚀 Start Planto server on port 8099

### 3. Set Up API Keys

In a **new terminal window**:

```bash
# Required: OpenRouter API Key
export OPENROUTER_API_KEY=your_openrouter_key_here

# Optional: OpenAI API Key (for better performance)
export OPENAI_API_KEY=your_openai_key_here
```

**Get API Keys:**
- OpenRouter: https://openrouter.ai/keys
- OpenAI: https://platform.openai.com/api-keys

### 4. Start Using Planto

```bash
# If CLI was built successfully
cd app/cli
./planto

# Or use the short alias
./pto

# If CLI build failed, use the original for now
plandex sign-in
# Select "Local mode host" 
# Confirm host: http://localhost:8099
```

## Manual Setup (Alternative)

If the setup script doesn't work, follow these manual steps:

### 1. Start Docker Services

```bash
cd /Users/rohitganguly/desktop/planto/app

# Make sure Docker is running
docker info

# Start the services
./start_local.sh
```

### 2. Install CLI (Fallback)

If building the CLI fails, use the original Plandex CLI:

```bash
curl -sL https://plandex.ai/install.sh | bash
```

Then connect to your local server:

```bash
plandex sign-in
# Choose "Local mode host"
# Host: http://localhost:8099
```

### 3. Create Project Directory

```bash
mkdir my-planto-project
cd my-planto-project
git init  # optional but recommended
```

### 4. Start Planto REPL

```bash
# With built CLI
/Users/rohitganguly/desktop/planto/app/cli/planto

# Or with original CLI
plandex
```

## Usage Commands

Once you're in the Planto REPL:

### Basic Commands
- `\\help` - Show help
- `\\quit` - Exit REPL  
- `\\tell` - Switch to tell mode (for implementation)
- `\\chat` - Switch to chat mode (for conversation)

### Context Management  
- `@filename` - Load file into context
- `\\load path/to/file` - Load file or directory
- `\\ls` - List context
- `\\rm` - Remove from context

### Plan Management
- `\\new` - Create new plan
- `\\plans` - List plans
- `\\current` - Show current plan
- `\\continue` - Continue current plan

### File Operations
- `\\diff` - Review pending changes
- `\\apply` - Apply changes to files
- `\\build` - Build current changes

## Configuration

### Server Configuration

The server runs with these settings:
- **Host**: `localhost:8099`
- **Database**: PostgreSQL on port 5433
- **Environment**: Development mode
- **Base Directory**: `/planto-server` (in container)

### CLI Configuration

Home directory: `~/.planto-home-v2`
Log file: `~/.planto-home-v2/planto.log`

## Troubleshooting

### Port Conflicts
If you get port conflicts:

```bash
# Check what's using the ports
lsof -i :8099
lsof -i :5433

# Stop conflicting services or change ports in docker-compose.yml
```

### Docker Issues
```bash
# Restart Docker
# On macOS: Restart Docker Desktop

# Clean up containers
docker-compose down
docker system prune

# Restart services
./start_local.sh
```

### CLI Build Issues
```bash
# Use the original CLI as fallback
curl -sL https://plandex.ai/install.sh | bash
plandex sign-in
# Select "Local mode host" and use http://localhost:8099
```

### API Key Issues
```bash
# Make sure keys are exported in the terminal where you run Planto
echo $OPENROUTER_API_KEY
echo $OPENAI_API_KEY

# Re-export if needed
export OPENROUTER_API_KEY=your_key_here
```

## Stopping Planto

### Stop the Server
Press `Ctrl+C` in the terminal where `start_local.sh` is running.

### Clean Shutdown
```bash
cd app
docker-compose down
```

### Complete Cleanup
```bash
cd app
docker-compose down -v  # This removes volumes too
```

## Restarting

To restart Planto:

```bash
cd /Users/rohitganguly/desktop/planto/app
./start_local.sh
```

The script automatically:
- 🔄 Pulls latest images
- 🗄️ Starts fresh database (or restores existing data)
- 🚀 Starts the server

## What's Different from Plandex

This rebranded version changes:

✅ **Command Names:**
- `plandex` → `planto`
- `pdx` → `pto`

✅ **Branding:**
- All references to "Plandex" → "Planto"
- URLs and docs updated (conceptually)
- Docker images: `plantoai/planto-server`

✅ **Database:**
- Database name: `planto`
- User: `planto`  
- Password: `planto`

⚠️ **Compatibility:**
- Same file formats and data structures
- Same API endpoints and functionality
- Can migrate from existing Plandex installations

## Development

### Building from Source

```bash
cd app

# Set up workspace
go work init
go work use . ./cli ./shared

# Build CLI
cd cli
go mod tidy
go build -o planto .

# Create alias
ln -sf planto pto
```

### Server Development

```bash
cd app
docker-compose -f docker-compose.yml up --build
```

## Support

Since this is a rebranded version:

1. **Core functionality**: Same as Plandex
2. **Issues**: Check original Plandex documentation
3. **Community**: Plandex Discord/GitHub until Planto community grows

## Next Steps

1. ✅ Start with simple tasks to test the setup
2. 📚 Read the original Plandex documentation for advanced features  
3. 🚀 Build your first project with Planto!

---

**Happy coding with Planto!** 🎯
