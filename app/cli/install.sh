#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PLATFORM=
ARCH=
VERSION=
RELEASES_URL="https://github.com/planto-ai/planto/releases/download"

 # Ensure cleanup happens on exit and on specific signals
trap cleanup EXIT
trap cleanup INT TERM

cleanup () {
  cd "${SCRIPT_DIR}"
  rm -rf planto_install_tmp
}

# Set platform
case "$(uname -s)" in
 Darwin)
   PLATFORM='darwin'
   ;;

 Linux)
   PLATFORM='linux'
   ;;

 FreeBSD)
   PLATFORM='freebsd'
   ;;

 CYGWIN*|MINGW*|MSYS*)
   PLATFORM='windows'
   ;;

 *)
   echo "Platform may or may not be supported. Will attempt to install."
   PLATFORM='linux'
   ;;
esac

if [[ "$PLATFORM" == "windows" ]]; then
  echo "🚨 Windows is only supported via WSL. It doesn't work in the Windows CMD prompt or PowerShell."
  echo "How to install WSL 👉 https://learn.microsoft.com/en-us/windows/wsl/about"
  exit 1
fi

# Set arch
if [[ "$(uname -m)" == 'x86_64' ]]; then
  ARCH="amd64"
elif [[ "$(uname -m)" == 'arm64' || "$(uname -m)" == 'aarch64' ]]; then
  ARCH="arm64"
fi

if [[ "$(cat /proc/1/cgroup 2> /dev/null | grep docker | wc -l)" > 0 ]] || [ -f /.dockerenv ]; then
  IS_DOCKER=true
else
  IS_DOCKER=false
fi

# Set Version
if [[ -z "${PLANTO_VERSION}" ]]; then
  VERSION=$(curl -sL https://planto.ai/v2/cli-version.txt)
else
  VERSION=$PLANTO_VERSION
  echo "Using custom version $VERSION"
fi


welcome_planto () {
  echo ""
  echo "$(printf '%*s' "$(tput cols)" '' | tr ' ' -)"
  echo ""
  echo "🚀 Planto v$VERSION • Quick Install"
  echo ""
  echo "$(printf '%*s' "$(tput cols)" '' | tr ' ' -)"
  echo ""
}

download_planto () {
  ENCODED_TAG="cli%2Fv${VERSION}"

  url="${RELEASES_URL}/${ENCODED_TAG}/planto_${VERSION}_${PLATFORM}_${ARCH}.tar.gz"

  mkdir -p planto_install_tmp
  cd planto_install_tmp

  echo "📥 Downloading Planto tarball"
  echo ""
  echo "👉 $url"
  echo ""
  curl -s -L -o planto.tar.gz "${url}"

  tar zxf planto.tar.gz 1> /dev/null

  should_sudo=false

  if [ "$PLATFORM" == "darwin" ] || $IS_DOCKER ; then
    if [[ -d /usr/local/bin ]]; then
      if ! mv planto /usr/local/bin/ 2>/dev/null; then
        echo "Permission denied when attempting to move Planto to /usr/local/bin."
        if hash sudo 2>/dev/null; then
          should_sudo=true
          echo "Attempting to use sudo to complete installation."
          sudo mv planto /usr/local/bin/
          if [[ $? -eq 0 ]]; then
            echo "✅ Planto is installed in /usr/local/bin"
            echo ""
          else
            echo "Failed to install Planto using sudo. Please manually move Planto to a directory in your PATH."
            exit 1
          fi
        else
          echo "sudo not found. Please manually move Planto to a directory in your PATH."
          exit 1
        fi
      else
        echo "✅ Planto is installed in /usr/local/bin"
      fi
    else
      echo >&2 'Error: /usr/local/bin does not exist. Create this directory with appropriate permissions, then re-install.'
      exit 1
    fi
  else
    if [ $UID -eq 0 ]
    then
      # we are root
      mv planto /usr/local/bin/
    elif hash sudo 2>/dev/null;
    then
      # not root, but can sudo
      sudo mv planto /usr/local/bin/
      should_sudo=true
    else
      echo "ERROR: This script must be run as root or be able to sudo to complete the installation."
      exit 1
    fi

    echo "✅ Planto is installed in /usr/local/bin"
  fi

  # create 'pdx' alias, but don't overwrite existing pdx command
  if [ ! -x "$(command -v pdx)" ]; then
    echo "🎭 Creating pdx alias..."
    LOC=$(which planto)
    BIN_DIR=$(dirname "$LOC")

    if [ "$should_sudo" = true ]; then
      sudo ln -s "$LOC" "$BIN_DIR/pdx" && \
        echo "✅ Successfully created 'pdx' alias with sudo." || \
        echo "⚠️ Failed to create 'pdx' alias even with sudo. Please create it manually."
    else
      ln -s "$LOC" "$BIN_DIR/pdx" && \
        echo "✅ Successfully created 'pdx' alias." || \
        echo "⚠️ Failed to create 'pdx' alias. Please create it manually."
    fi
  fi
}

check_existing_installation () {
  if command -v planto >/dev/null 2>&1; then
    existing_version=$(planto version 2>/dev/null || echo "unknown")
    # Check if version starts with 1.x.x
    if [[ "$existing_version" =~ ^1\. ]]; then
      echo "Found existing Planto v1.x installation ($existing_version). Renaming to 'planto1' before installing v2..."
      
      # Get the location of existing binary
      existing_binary=$(which planto)
      binary_dir=$(dirname "$existing_binary")
      
      # Rename planto to planto1
      if ! mv "$existing_binary" "${binary_dir}/planto1" 2>/dev/null; then
        sudo mv "$existing_binary" "${binary_dir}/planto1"
      fi
      
      # Rename pdx to pdx1 if it exists
      if [ -L "${binary_dir}/pdx" ]; then
        if ! mv "${binary_dir}/pdx" "${binary_dir}/pdx1" 2>/dev/null; then
          sudo mv "${binary_dir}/pdx" "${binary_dir}/pdx1"
        fi
        echo "Renamed 'pdx' alias to 'pdx1'"
      fi
      
      echo "Your v1.x installation is now accessible as 'planto1' and 'pdx1'"
    fi
  fi
}

welcome_planto
check_existing_installation
download_planto

echo ""
echo "🎉 Installation complete"
echo ""
echo "$(printf '%*s' "$(tput cols)" '' | tr ' ' -)"
echo ""
echo "⚡️ Run 'planto' or 'pdx' in any project directory and start building!"
echo ""
echo "$(printf '%*s' "$(tput cols)" '' | tr ' ' -)"
echo ""
echo "📚 Need help? 👉 https://docs.planto.ai"
echo ""
echo "👋 Join a community of AI builders 👉 https://discord.gg/planto-ai"
echo ""
echo "$(printf '%*s' "$(tput cols)" '' | tr ' ' -)"
echo ""

