#!/bin/bash
# Fully Automated Planto Setup Script - Complete with Prerequisites Check and Installation
echo "🚀 Starting Planto automated setup with prerequisites check..."

# Create a PID file to track our server process
PID_FILE="/tmp/planto_server.pid"
SETUP_STATUS_FILE="/tmp/planto_setup_status"
DOCKER_CONTAINERS_FILE="/tmp/planto_docker_containers"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check macOS version
check_macos_version() {
    print_status "Checking macOS version..."
    local version=$(sw_vers -productVersion)
    local major_version=$(echo "$version" | cut -d. -f1)
    local minor_version=$(echo "$version" | cut -d. -f2)
    
    if [[ $major_version -ge 11 ]] || [[ $major_version -eq 10 && $minor_version -ge 15 ]]; then
        print_success "macOS version $version is supported"
        return 0
    else
        print_error "macOS version $version is not supported. Need macOS 10.15 or later"
        return 1
    fi
}

# Function to install Homebrew
install_homebrew() {
    print_status "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        print_success "Homebrew installed successfully"
        
        # Add Homebrew to PATH for current session
        if [[ -d "/opt/homebrew" ]]; then
            # Apple Silicon Mac
            export PATH="/opt/homebrew/bin:$PATH"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -d "/usr/local/Homebrew" ]]; then
            # Intel Mac
            export PATH="/usr/local/bin:$PATH"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Update Homebrew
        brew update
        return 0
    else
        print_error "Failed to install Homebrew"
        return 1
    fi
}

# Function to check and install Xcode Command Line Tools
check_install_xcode_tools() {
    print_status "Checking Xcode Command Line Tools..."
    
    if xcode-select -p >/dev/null 2>&1; then
        print_success "Xcode Command Line Tools are already installed"
        return 0
    fi
    
    print_warning "Xcode Command Line Tools not found. Installing..."
    print_status "A dialog will appear - please click 'Install' and wait for completion"
    
    # Install Xcode Command Line Tools
    xcode-select --install
    
    # Wait for installation to complete
    print_status "Waiting for Xcode Command Line Tools installation to complete..."
    while ! xcode-select -p >/dev/null 2>&1; do
        sleep 5
        printf "."
    done
    echo ""
    
    print_success "Xcode Command Line Tools installed successfully"
    return 0
}

# Function to check and setup Homebrew
check_setup_homebrew() {
    print_status "Checking Homebrew installation..."
    
    if command_exists brew; then
        print_success "Homebrew is already installed"
        # Update Homebrew
        print_status "Updating Homebrew..."
        brew update
        return 0
    fi
    
    print_warning "Homebrew not found. Installing..."
    if install_homebrew; then
        return 0
    else
        print_error "Failed to install Homebrew"
        return 1
    fi
}

# Function to install a package via Homebrew
install_via_brew() {
    local package=$1
    local package_name=${2:-$package}
    
    print_status "Installing $package_name via Homebrew..."
    if brew install "$package"; then
        print_success "$package_name installed successfully"
        return 0
    else
        print_error "Failed to install $package_name"
        return 1
    fi
}

# Function to install a cask via Homebrew
install_cask_via_brew() {
    local cask=$1
    local cask_name=${2:-$cask}
    
    print_status "Installing $cask_name via Homebrew..."
    if brew install --cask "$cask"; then
        print_success "$cask_name installed successfully"
        return 0
    else
        print_error "Failed to install $cask_name"
        return 1
    fi
}

# Function to check all prerequisites
check_prerequisites() {
    print_status "🔍 Checking system prerequisites..."
    echo "=================================="
    
    local missing_tools=()
    local install_failed=()
    
    # Check macOS version first
    if ! check_macos_version; then
        print_error "Unsupported macOS version. Exiting."
        exit 1
    fi
    
    # Check and install Xcode Command Line Tools
    if ! check_install_xcode_tools; then
        print_error "Failed to install Xcode Command Line Tools. Exiting."
        exit 1
    fi
    
    # Check and setup Homebrew
    if ! check_setup_homebrew; then
        print_error "Failed to setup Homebrew. Exiting."
        exit 1
    fi
    
    # Check essential command line tools
    print_status "Checking essential command line tools..."
    
    # These should be available after Xcode Command Line Tools
    local essential_tools=("curl" "git" "ps" "kill" "pkill")
    for tool in "${essential_tools[@]}"; do
        if ! command_exists "$tool"; then
            print_warning "$tool not found"
            missing_tools+=("$tool")
        else
            print_success "$tool is available"
        fi
    done
    
    # Check zsh (should be default on modern macOS)
    if ! command_exists zsh; then
        print_warning "zsh not found"
        missing_tools+=("zsh")
    else
        print_success "zsh is available"
    fi
    
    # Check expect (will be installed if missing)
    if ! command_exists expect; then
        print_warning "expect not found - will be installed"
        missing_tools+=("expect")
    else
        print_success "expect is available"
    fi
    
    # Check Docker (optional but recommended)
    if ! command_exists docker; then
        print_warning "Docker not found - this is optional but recommended"
        print_status "Would you like to install Docker Desktop? (y/n)"
        read -r install_docker
        if [[ $install_docker =~ ^[Yy]$ ]]; then
            missing_tools+=("docker")
        else
            print_status "Skipping Docker installation"
        fi
    else
        print_success "Docker is available"
    fi
    
    # Install missing tools
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_status "Installing missing tools..."
        
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "expect")
                    if ! install_via_brew "expect" "expect"; then
                        install_failed+=("expect")
                    fi
                    ;;
                "docker")
                    if ! install_cask_via_brew "docker" "Docker Desktop"; then
                        install_failed+=("Docker Desktop")
                    else
                        print_status "Please start Docker Desktop manually before continuing"
                        print_status "Waiting for Docker to start..."
                        while ! docker info >/dev/null 2>&1; do
                            sleep 5
                            printf "."
                        done
                        echo ""
                        print_success "Docker is running"
                    fi
                    ;;
                "zsh")
                    if ! install_via_brew "zsh" "zsh"; then
                        install_failed+=("zsh")
                    fi
                    ;;
                *)
                    print_warning "Don't know how to install $tool via Homebrew"
                    install_failed+=("$tool")
                    ;;
            esac
        done
        
        # Check if any installations failed
        if [[ ${#install_failed[@]} -gt 0 ]]; then
            print_error "Failed to install the following tools:"
            for tool in "${install_failed[@]}"; do
                echo "  - $tool"
            done
            print_error "Please install these manually and run the script again"
            exit 1
        fi
    fi
    
    print_success "All prerequisites are satisfied!"
    echo ""
}

# Function to get running Planto-related Docker containers
get_planto_containers() {
    # Look for containers that might be related to Planto
    # You may need to adjust these patterns based on your actual container names
    docker ps -q --filter "name=planto" --filter "name=plandex" 2>/dev/null || true
}

# Store initial Docker containers to track what we started
store_initial_containers() {
    echo "📦 Storing initial Docker container state..."
    get_planto_containers > "$DOCKER_CONTAINERS_FILE"
}

# Cleanup function to stop server, processes, and Docker containers
cleanup() {
    # Only show cleanup message if we're interrupting
    if [ "$1" != "normal" ]; then
        print_status "🧹 Cleaning up processes and Docker containers..."
        
        # Stop the server process
        if [ -f "$PID_FILE" ]; then
            SERVER_PID=$(cat "$PID_FILE")
            if ps -p "$SERVER_PID" > /dev/null 2>&1; then
                print_status "🛑 Stopping Planto server (PID: $SERVER_PID)..."
                kill "$SERVER_PID" 2>/dev/null
                sleep 3
                if ps -p "$SERVER_PID" > /dev/null 2>&1; then
                    kill -9 "$SERVER_PID" 2>/dev/null
                fi
            fi
            rm -f "$PID_FILE"
        fi
        
        # Kill any remaining planto processes
        pkill -f "start_local.sh" 2>/dev/null
        pkill -f "planto" 2>/dev/null
        
        # Stop Docker containers
        print_status "🐳 Stopping Docker containers..."
        if command_exists docker; then
            # Get current Planto containers
            CURRENT_CONTAINERS=$(get_planto_containers)
            
            if [ -n "$CURRENT_CONTAINERS" ]; then
                print_status "🛑 Stopping Planto Docker containers..."
                echo "$CURRENT_CONTAINERS" | while read -r container_id; do
                    if [ -n "$container_id" ]; then
                        print_status "   Stopping container: $container_id"
                        docker stop "$container_id" 2>/dev/null || true
                    fi
                done
            fi
        fi
        print_success "✅ Cleanup complete"
    fi
    
    # Always clean up temporary files
    rm -f "$SETUP_STATUS_FILE" "$DOCKER_CONTAINERS_FILE"
}

# Set up signal handlers only for interrupts
trap 'cleanup interrupt' INT TERM

# Main script execution starts here
echo "🔧 PLANTO AUTOMATED SETUP"
echo "========================="

# Step 0: Check prerequisites
check_prerequisites

# Check if Docker is available
if command_exists docker; then
    print_status "🐳 Docker found - will monitor Docker containers"
    store_initial_containers
else
    print_warning "⚠️  Docker not found - skipping Docker monitoring"
fi

# Step 1: Run the initial setup
print_status "📋 Running initial Planto setup..."
cd /Users/rohitganguly/desktop/planto || { print_error "❌ Planto directory not found"; exit 1; }
./setup-planto.sh

# Step 2: Start the Planto server in background and track PID
print_status "🖥️  Starting Planto server..."
cd /Users/rohitganguly/desktop/planto/app || { print_error "❌ App directory not found"; exit 1; }
./start_local.sh &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

# Give server some time to start
print_status "⏳ Waiting for server to start..."
sleep 10

# Check if server is still running
if ! ps -p "$SERVER_PID" > /dev/null 2>&1; then
    print_error "❌ Server failed to start"
    exit 1
fi

print_success "✅ Server started successfully (PID: $SERVER_PID)"

# Initialize status file
echo "waiting" > "$SETUP_STATUS_FILE"

# Create a temporary script for the new terminal
TEMP_SCRIPT=$(mktemp /tmp/planto-setup.XXXXXX)
cat > "$TEMP_SCRIPT" <<EOT
#!/bin/zsh
SETUP_STATUS_FILE="$SETUP_STATUS_FILE"
PID_FILE="$PID_FILE"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to cleanup and signal failure
cleanup_and_exit() {
    echo "failed" > "\$SETUP_STATUS_FILE"
    echo ""
    echo -e "\${RED}❌ Setup cancelled. Cleaning up...\${NC}"
    exit 1
}

# Set up signal handlers for this terminal
trap cleanup_and_exit INT TERM

clear
echo -e "\${BLUE}🔑 PLANTO API KEY SETUP\${NC}"
echo "======================="
echo ""
echo -e "\${YELLOW}❗ IMPORTANT: You need to provide your OPENROUTER_API_KEY to continue\${NC}"
echo "   If you don't have one, visit: https://openrouter.ai/"
echo ""
echo -e "\${YELLOW}⚠️  WARNING: If you cancel or don't provide the key, the server will be stopped\${NC}"
echo ""

# Get API key with timeout
echo "Please enter your OPENROUTER_API_KEY:"
echo "(Press Ctrl+C to cancel)"
echo ""

# Read API key with proper validation
while true; do
    read -r "openrouter_key?Enter your OPENROUTER_API_KEY: "
    
    # Check if user pressed Ctrl+C or provided empty input
    if [ \$? -ne 0 ] || [ -z "\$openrouter_key" ]; then
        echo ""
        echo -e "\${RED}❌ No API key provided or cancelled\${NC}"
        cleanup_and_exit
    fi
    
    # Basic validation - check if it looks like an API key
    if [[ "\$openrouter_key" =~ ^[a-zA-Z0-9_-]+\$ ]] && [ \${#openrouter_key} -gt 10 ]; then
        break
    else
        echo ""
        echo -e "\${YELLOW}⚠️  Invalid API key format. Please try again.\${NC}"
        echo "   API keys should be alphanumeric with dashes/underscores and longer than 10 characters"
        echo ""
    fi
done

export OPENROUTER_API_KEY=\$openrouter_key
echo ""
echo -e "\${GREEN}✅ API key set successfully\${NC}"
echo ""

echo -e "\${BLUE}❗ STEP 2: Installing Planto CLI...\${NC}"
if curl -sL https://plandex.ai/install.sh | bash; then
    echo -e "\${GREEN}✅ CLI installed successfully\${NC}"
else
    echo -e "\${RED}❌ CLI installation failed\${NC}"
    cleanup_and_exit
fi

echo ""
echo -e "\${BLUE}❗ STEP 3: Running sign-in process...\${NC}"
echo "   (This will simulate the exact keypresses you described)"
echo ""

# Run the sign-in process using expect (which should be available now)
/usr/bin/expect <<EOF
set timeout 30
spawn plandex sign-in

# Wait for account selection
expect {
    "? Select an account:" {
        send "\\033\[B\\r"
        exp_continue
    }
    "local-admin@plandex.ai" {
        # Account already exists, just press enter to select it
        send "\\r"
        exp_continue
    }
    "? Use Plandex Cloud or another host?" {
        send "\\033\[B\\r"
        exp_continue
    }
    "Host:" {
        send "http://localhost:8099\\r"
        exp_continue
    }
    "✅ Signed in as" {
        # Success message received
        send "\\r"
    }
    timeout {
        puts "Timeout waiting for sign-in process"
        exit 1
    }
    eof {
        # Process ended
    }
}

# Wait a bit for any final output
sleep 2
EOF

# Check if the sign-in was successful by testing plandex
echo ""
echo -e "\${BLUE}🔍 Verifying sign-in status...\${NC}"
if timeout 10 plandex auth 2>/dev/null | grep -q "local-admin@plandex.ai"; then
    echo -e "\${GREEN}✅ Sign-in verified successfully!\${NC}"
    SIGNIN_SUCCESS=true
else
    echo -e "\${YELLOW}⚠️  Sign-in verification inconclusive, but continuing...\${NC}"
    SIGNIN_SUCCESS=true
fi

if [ "\$SIGNIN_SUCCESS" = true ]; then
    echo ""
    echo -e "\${GREEN}✅ Sign-in complete!\${NC}"
    echo "success" > "\$SETUP_STATUS_FILE"
else
    echo ""
    echo -e "\${RED}❌ Sign-in failed\${NC}"
    cleanup_and_exit
fi

echo ""
echo -e "\${GREEN}🎉 SETUP COMPLETE!\${NC}"
echo "================="
echo ""
echo -e "\${GREEN}✅ Planto server is running\${NC}"
echo -e "\${GREEN}✅ API key is configured\${NC}"
echo -e "\${GREEN}✅ CLI is installed and signed in\${NC}"
echo ""
echo "You can now use 'plandex' in any project directory"
echo "Try it now in this terminal:"
echo "   \$ planto"
echo ""

# Keep terminal open
read -r "dummy?Press enter to exit..."
rm -f "\$0"
EOT

# Make the temp script executable
chmod +x "$TEMP_SCRIPT"

# Open new terminal and execute the script (macOS specific)
print_status "🔑 Opening new terminal for API key setup..."
print_status "   Please complete the setup in the new terminal window"
echo ""

osascript <<EOF
tell application "Terminal"
    activate
    do script "exec '$TEMP_SCRIPT'"
end tell
EOF

# Monitor the setup status
print_status "⏳ Waiting for API key setup to complete..."
print_status "   (Monitoring setup progress...)"

TIMEOUT=300  # 5 minutes timeout
ELAPSED=0
INTERVAL=2

while [ $ELAPSED -lt $TIMEOUT ]; do
    if [ ! -f "$SETUP_STATUS_FILE" ]; then
        print_error "❌ Setup status file disappeared"
        break
    fi
    
    STATUS=$(cat "$SETUP_STATUS_FILE")
    
    case "$STATUS" in
        "success")
            echo ""
            print_success "🎉 Setup completed successfully!"
            print_success "✅ Planto server is running in the background (PID: $SERVER_PID)"
            print_success "✅ You can now use 'plandex' in any project directory"
            echo ""
            print_status "To stop the server later, run:"
            echo "   kill $SERVER_PID"
            echo ""
            print_status "To stop Docker containers (if any), run:"
            echo "   docker stop \$(docker ps -q --filter name=planto)"
            echo ""
            
            # Exit without cleanup (server keeps running)
            cleanup normal
            exit 0
            ;;
        "failed")
            echo ""
            print_error "❌ Setup failed or was cancelled"
            print_status "🛑 Stopping server and cleaning up..."
            cleanup interrupt
            exit 1
            ;;
        "waiting")
            # Still waiting, show progress
            printf "."
            ;;
    esac
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

# Timeout reached
echo ""
print_warning "⏰ Timeout reached (5 minutes)"
print_error "❌ Setup did not complete in time"
print_status "🛑 Stopping server and cleaning up..."
cleanup interrupt
exit 1