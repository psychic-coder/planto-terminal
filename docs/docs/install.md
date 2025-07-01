---
sidebar_position: 1
sidebar_label: Install
---

# Install Planto

## Quick Install

```bash
curl -sL https://planto.ai/install.sh | bash
```

## Manual install

Grab the appropriate binary for your platform from the latest [release](https://github.com/planto-ai/planto/releases) and put it somewhere in your `PATH`.

## Build from source

```bash
git clone https://github.com/planto-ai/planto.git
cd planto/app/cli
go build -ldflags "-X planto/version.Version=$(cat version.txt)"
mv planto /usr/local/bin # adapt as needed for your system
```

## Windows

Windows is supported via [WSL](https://learn.microsoft.com/en-us/windows/wsl/about).

Planto only works correctly in the WSL shell. It doesn't work in the Windows CMD prompt or PowerShell.

## Upgrading from v1 to v2

When you install the Planto v2 CLI with the quick install script, it will rename your existing `planto` command to `planto1` (and the `pdx` alias to `pdx1`). Planto v2 is designed to run *separately* from v1 rather than upgrading in place. [More details here.](./upgrading-v1-to-v2.md)