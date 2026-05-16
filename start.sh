#!/bin/bash

# --- Color Definitions ---
GOLD='\033[0;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GOLD}🚀 Initializing Stellaar Premium Experience...${NC}"

# --- Helper: Robust IP Detection ---
get_local_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "127.0.0.1"
    else
        # Linux
        hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1"
    fi
}

# --- Main Functions ---
run_dev() {
    local IP=$(get_local_ip)
    
    echo -e "${CYAN}🛠️  Preparing Development Environment...${NC}"
    
    # Check for port conflicts (Port 3000)
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}⚠️  Port 3000 is busy. Clearing previous session...${NC}"
        lsof -ti:3000 | xargs kill -9 2>/dev/null
        sleep 1
    fi

    # Final validation of node_modules
    if [ ! -f "./node_modules/.bin/next" ]; then
        echo -e "${RED}❌ Error: 'next' binary not found. Attempting repair...${NC}"
        install_deps
    fi

    echo -e "\n${GOLD}✨ STELLAAR IS READY${NC}"
    echo -e "-------------------------------------------"
    echo -e "${GREEN}💻 Local:${NC}   http://localhost:3000"
    echo -e "${GREEN}🌐 Network:${NC} http://$IP:3000"
    echo -e "-------------------------------------------"
    echo -e "${CYAN}Note: Both links are active and synced.${NC}\n"
    
    npm run dev -- -H 0.0.0.0
}

install_deps() {
    echo -e "${CYAN}📦 Installing dependencies (using local cache workaround)...${NC}"
    mkdir -p .npm-cache
    # Use local cache to bypass global EACCES issues
    npm install --cache ./.npm-cache --loglevel=error
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install dependencies. Please check permissions.${NC}"
        exit 1
    fi
}

run_prod() {
    echo -e "${CYAN}🏗️  Building Production Bundle...${NC}"
    npm run build
    echo -e "${GREEN}✨ Build Complete. Launching Production Server...${NC}"
    npm run start -- -H 0.0.0.0
}

show_help() {
    echo "Usage: ./start.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --prod    Build and run in production mode"
    echo "  --clean   Deep clean workspace (removes node_modules)"
    echo "  --help    Show this help message"
}

# --- Logic ---
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ "$1" == "--clean" ]]; then
    echo -e "${RED}🧹 Deep cleaning workspace...${NC}"
    rm -rf .next node_modules package-lock.json .npm-cache
fi

# Auto-install dependencies if missing or broken
if [ ! -d "node_modules" ] || [ ! -f "./node_modules/.bin/next" ]; then
    install_deps
fi

if [[ "$1" == "--prod" ]]; then
    run_prod
else
    run_dev
fi
