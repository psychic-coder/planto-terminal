#!/bin/bash
# Fully Automated Planto Setup Script - Fixed Terminal Launch Version with API Key Validation
echo "🚀 Starting Planto automated setup..."

# Create a PID file to track our server process
PID_FILE="/tmp/planto_server.pid"
SETUP_STATUS_FILE="/tmp/planto_setup_status"

# Cleanup function to stop server and processes
cleanup() {
    echo "🧹 Cleaning up processes..."
    if [ -f "$PID_FILE" ]; then
        SERVER_PID=$(cat "$PID_FILE")
        if ps -p "$SERVER_PID" > /dev/null 2>&1; then
            echo "🛑 Stopping Planto server (PID: $SERVER_PID)..."
            kill "$SERVER_PID" 2>/dev/null
            # Wait a bit, then force kill if necessary
            sleep 3
            if ps -p "$SERVER_PID" > /dev/null 2>&1; then
                echo "⚠️  Force killing server..."
                kill -9 "$SERVER_PID" 2>/dev/null
            fi
        fi
        rm -f "$PID_FILE"
    fi
    
    # Kill any remaining planto processes
    pkill -f "start_local.sh" 2>/dev/null
    pkill -f "planto" 2>/dev/null
    
    rm -f "$SETUP_STATUS_FILE"
    echo "✅ Cleanup complete"
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Step 1: Run the initial setup
echo "📋 Running initial Planto setup..."
cd /Users/rohitganguly/desktop/planto || { echo "❌ Planto directory not found"; exit 1; }
./setup-planto.sh

# Step 2: Start the Planto server in background and track PID
echo "🖥️  Starting Planto server..."
cd /Users/rohitganguly/desktop/planto/app || { echo "❌ App directory not found"; exit 1; }
./start_local.sh &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

# Give server some time to start
echo "⏳ Waiting for server to start..."
sleep 10

# Check if server is still running
if ! ps -p "$SERVER_PID" > /dev/null 2>&1; then
    echo "❌ Server failed to start"
    exit 1
fi

echo "✅ Server started successfully (PID: $SERVER_PID)"

# Initialize status file
echo "waiting" > "$SETUP_STATUS_FILE"

# Create a temporary script for the new terminal
TEMP_SCRIPT=$(mktemp /tmp/planto-setup.XXXXXX)
cat > "$TEMP_SCRIPT" <<EOT
#!/bin/zsh
SETUP_STATUS_FILE="$SETUP_STATUS_FILE"
PID_FILE="$PID_FILE"

# Function to cleanup and signal failure
cleanup_and_exit() {
    echo "failed" > "\$SETUP_STATUS_FILE"
    echo ""
    echo "❌ Setup cancelled. Cleaning up..."
    exit 1
}

# Set up signal handlers for this terminal
trap cleanup_and_exit INT TERM

clear
echo "🔑 PLANTO API KEY SETUP"
echo "======================="
echo ""
echo "❗ IMPORTANT: You need to provide your OPENROUTER_API_KEY to continue"
echo "   If you don't have one, visit: https://openrouter.ai/"
echo ""
echo "⚠️  WARNING: If you cancel or don't provide the key, the server will be stopped"
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
        echo "❌ No API key provided or cancelled"
        cleanup_and_exit
    fi
    
    # Basic validation - check if it looks like an API key
    if [[ "\$openrouter_key" =~ ^[a-zA-Z0-9_-]+\$ ]] && [ \${#openrouter_key} -gt 10 ]; then
        break
    else
        echo ""
        echo "⚠️  Invalid API key format. Please try again."
        echo "   API keys should be alphanumeric with dashes/underscores and longer than 10 characters"
        echo ""
    fi
done

export OPENROUTER_API_KEY=\$openrouter_key
echo ""
echo "✅ API key set successfully"
echo ""

echo "❗ STEP 2: Installing Planto CLI..."
if curl -sL https://plandex.ai/install.sh | bash; then
    echo "✅ CLI installed successfully"
else
    echo "❌ CLI installation failed"
    cleanup_and_exit
fi

echo ""
echo "❗ STEP 3: Running sign-in process..."
echo "   (This will simulate the exact keypresses you described)"
echo ""

# Check if expect is installed, install if needed
if ! command -v expect &> /dev/null; then
    echo "Installing expect..."
    if ! brew install expect; then
        echo "❌ Failed to install expect"
        cleanup_and_exit
    fi
fi

# Run the sign-in process
if /usr/bin/expect <<EOF
spawn planto sign-in
expect "? Select an account:"
send "\\033\[B\\r"
expect "? Use Plandex Cloud or another host?"
send "\\033\[B\\r"
expect "Host: › "
send "http://localhost:8099\\r"
expect eof
EOF
then
    echo ""
    echo "✅ Sign-in complete!"
    echo "success" > "\$SETUP_STATUS_FILE"
else
    echo ""
    echo "❌ Sign-in failed"
    cleanup_and_exit
fi

echo ""
echo "🎉 SETUP COMPLETE!"
echo "================="
echo ""
echo "✅ Planto server is running"
echo "✅ API key is configured"
echo "✅ CLI is installed and signed in"
echo ""
echo "You can now use 'planto' in any project directory"
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
echo "🔑 Opening new terminal for API key setup..."
echo "   Please complete the setup in the new terminal window"
echo ""

osascript <<EOF
tell application "Terminal"
    activate
    do script "exec '$TEMP_SCRIPT'"
end tell
EOF

# Monitor the setup status
echo "⏳ Waiting for API key setup to complete..."
echo "   (Monitoring setup progress...)"

TIMEOUT=300  # 5 minutes timeout
ELAPSED=0
INTERVAL=2

while [ $ELAPSED -lt $TIMEOUT ]; do
    if [ ! -f "$SETUP_STATUS_FILE" ]; then
        echo "❌ Setup status file disappeared"
        break
    fi
    
    STATUS=$(cat "$SETUP_STATUS_FILE")
    
    case "$STATUS" in
        "success")
            echo ""
            echo "🎉 Setup completed successfully!"
            echo "✅ Planto server is running and configured"
            echo "✅ You can now use 'planto' in any project directory"
            echo ""
            echo "Server will continue running in the background"
            echo "To stop the server later, run: kill $SERVER_PID"
            exit 0
            ;;
        "failed")
            echo ""
            echo "❌ Setup failed or was cancelled"
            echo "🛑 Stopping server and cleaning up..."
            cleanup
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
echo "⏰ Timeout reached (5 minutes)"
echo "❌ Setup did not complete in time"
echo "🛑 Stopping server and cleaning up..."
cleanup
exit 1