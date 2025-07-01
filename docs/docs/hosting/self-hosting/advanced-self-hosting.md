---
sidebar_position: 2
sidebar_label: Advanced Self-Hosting
---

# Advanced Self-Hosting

The easiest way to self-host Planto is to use the [Local Mode Quickstart](./local-mode-quickstart.md). But if you need to run Planto on a remote server with multiple users or orgs, or you want to run it without docker/docker-compose, keep reading below.

## Requirements

The Planto server requires a PostgreSQL database (ideally v14), a persistent file system, and git.

Due to a dependency on tree-sitter, gcc, g++, and make are also required to build the server.

## Development vs. Production

The Planto server can be run in development or production mode. The main differences are how authentication pins and emails are handled, and the default path for the persistent file system.

Development mode is designed for local usage with a single user. Email isn't enabled and verification pins are skipped. In development mode, the default base directory is `$HOME/planto-server`.

Production mode is designed for multiple users or organizations. Email is enabled and SMTP environment variables are required. Authentication pins are sent via email. In production mode, the default base directory is `/planto-server`.

Development or production mode is set with the `GOENV` environment variable. It should be set to either `development` or `production`.

In both development and production mode, the server runs on port 8099 by default. This can be changed with the `PORT` environment variable.

## PostgreSQL Database

If you aren't using docker-compose to start the server and run the database, you'll need a PostgreSQL database. You can run the following SQL to create a user and database, replacing `user` and `password` with your own values:

```sql
CREATE USER 'user' WITH PASSWORD 'password';
CREATE DATABASE 'planto' OWNER 'user';
GRANT ALL PRIVILEGES ON DATABASE 'planto' TO 'user';
```

### Environment Variables

Set `GOENV` to either `development` or `production` as described above in the [Development vs. Production](#development-vs-production) section:

```bash
export GOENV=development
```

or
  
```bash
export GOENV=production
```

You'll also need a `DATABASE_URL`:

```bash
export DATABASE_URL=postgres://user:password@host:5432/planto # replace with your own database URL
```

In production mode, you'll also need to connect to SMTP to send emails. Set the following environment variables:

```bash
export SMTP_HOST=smtp.example.com
export SMTP_PORT=587
export SMTP_USER=user
export SMTP_PASSWORD=password
export SMTP_FROM=user@example.com # optional, if not set then SMTP_USER is used
```

In either development or production mode, the base directory for the persistent file system can optionally be overridden with the `PLANTO_BASE_DIR` environment variable:

```bash
export PLANTO_BASE_DIR=~/some-dir/planto-server
```

When running the Planto CLI, to connect to a server running in production mode, set the API_HOST environment variable to the host the server is running on:

```bash
export API_HOST=api.your-domain.ai
```

### Using Docker Build

The server can be run from a Dockerfile at `app/Dockerfile.server`:

```bash
git clone https://github.com/planto-ai/planto.git
VERSION=$(cat app/server/version.txt) # or use the version you want
git checkout server/v$VERSION
cd planto/app
mkdir ~/planto-server # or another directory where you want to store files
docker build -t planto-server -f Dockerfile.server .
docker run -p 8099:8099 \
  -v ~/planto-server:/planto-server \
  -e DATABASE_URL \
  -e GOENV \
  -e API_HOST \
  -e SMTP_HOST \ 
  -e SMTP_PORT \
  -e SMTP_USER \
  -e SMTP_PASSWORD \
  planto-server
```

The API_HOST and SMTP environment variables above are only required if you're running in [production mode](#development-vs-production).

### DockerHub Server Images

Apart from building manually with the Dockerfile, server images are also built and pushed to [DockerHub](https://hub.docker.com/r/plantoai/planto-server/tags) automatically when a new version of the server is released.

You can pull the latest server image with:

```bash
docker pull plantoai/planto-server:latest
```

### Run From Source

You can also run the server from source:

```bash
git clone https://github.com/planto-ai/planto.git
cd planto/
VERSION=$(cat app/server/version.txt) # or use the version you want
git checkout server/v$VERSION
cd app/server
export GOENV=development # or production
export DATABASE_URL=postgres://user:password@host:5432/planto # replace with your own database URL
export PLANTO_BASE_DIR=~/planto-server # or another directory where you want to store files
go run main.go
```

## Health Check

You can check if the server is running by sending a GET request to `/health`. If all is well, it will return a 200 status code.

## Create a New Account

Once the server is running and you've [installed the Planto CLI](../../install.md) on your local development machine, you can create a new account by running `planto sign-in`: 

```bash
planto sign-in # follow the prompts to create a new account on your self-hosted server
```

## Note On Local CLI Files

If you use the Planto CLI and then for some reason you reset the database or use a new one, you'll need to remove the local files that the CLI creates in directories where you used Planto in order to start fresh. Otherwise, the CLI will attempt to authenticate with an account that doesn't exist in the new database and you'll get errors.

To resolve this, remove the following in any directory you used the CLI in:

- `.planto-dev` directory if you ran the CLI with `PLANTO_ENV=development`
- `.planto` directory otherwise

Then run `planto sign-in` again to create a new account.

If you're still having trouble with accounts, you can also remove the following from your $HOME directory to fully reset them:

- `.planto-home-dev` directory if you ran the CLI with `PLANTO_ENV=development`
- `.planto-home` directory otherwise