# Planto Documentation Structure and Working

## Overview

The Planto documentation is built using **Docusaurus 3.4.0**, a modern static site generator built on React. The documentation is deployed at `https://docs.planto.ai` and serves as the comprehensive guide for users and developers working with Planto.

## Directory Structure

```
docs/
├── README.md                      # Documentation setup guide
├── package.json                   # Dependencies and build scripts
├── docusaurus.config.ts          # Main Docusaurus configuration
├── sidebars.ts                    # Sidebar navigation configuration
├── tsconfig.json                  # TypeScript configuration
├── babel.config.js               # Babel configuration
├── .gitignore                    # Git ignore patterns
├── package-lock.json             # Dependency lock file
│
├── docs/                         # Main documentation content
│   ├── cli-reference.md         # Complete CLI command reference
│   ├── quick-start.md           # Getting started guide
│   ├── install.md               # Installation instructions
│   ├── repl.md                  # REPL (Read-Eval-Print Loop) guide
│   ├── environment-variables.md # Environment configuration
│   ├── security.md              # Security considerations
│   ├── development.md           # Development setup
│   ├── upgrading-v1-to-v2.md   # Version upgrade guide
│   │
│   ├── core-concepts/           # Core functionality documentation
│   │   ├── _category_.json     # Category configuration
│   │   ├── plans.md            # Plan management
│   │   ├── context-management.md
│   │   ├── conversations.md    # Chat and conversation features
│   │   ├── version-control.md  # Git integration
│   │   ├── branches.md         # Branch management
│   │   ├── reviewing-changes.md
│   │   ├── execution-and-debugging.md
│   │   ├── background-tasks.md
│   │   ├── autonomy.md         # AI autonomy features
│   │   ├── configuration.md    # Configuration management
│   │   └── prompts.md          # Prompt engineering
│   │
│   ├── models/                 # AI model documentation
│   │   ├── _category_.json
│   │   ├── model-providers.md  # Supported AI providers
│   │   ├── model-settings.md   # Model configuration
│   │   └── roles.md            # Model roles and usage
│   │
│   └── hosting/                # Deployment and hosting
│       ├── _category_.json
│       ├── cloud.md            # Planto Cloud hosting
│       └── self-hosting/       # Self-hosting documentation
│           ├── _category_.json
│           ├── local-mode-quickstart.md
│           └── advanced-self-hosting.md
│
├── blog/                       # Blog functionality (disabled)
│   ├── authors.yml            # Blog authors configuration
│   ├── tags.yml               # Blog tags configuration
│   └── 2021-08-26-welcome/    # Sample blog post
│
├── src/                       # Custom React components and CSS
│   └── css/
│       └── custom.css         # Custom styling
│
└── static/                    # Static assets
    ├── .nojekyll             # GitHub Pages configuration
    ├── _redirects            # Netlify redirects
    └── img/                  # Images and icons
        ├── favicon.ico
        ├── planto-logo-*.png
        └── planto-social-preview.png
```

## Key Configuration Files

### 1. docusaurus.config.ts
The main configuration file that defines:
- **Site metadata**: Title, tagline, URL, favicon
- **Theme configuration**: Dark mode default, navbar, footer
- **Search integration**: Algolia search configuration
- **Routing**: Docs served at site root (`/`)
- **Social links**: GitHub, Discord, X (Twitter), YouTube

### 2. sidebars.ts
Configures the sidebar navigation using auto-generation from the file structure.

### 3. package.json
Defines dependencies and build scripts:
- **Core**: Docusaurus 3.4.0, React 18
- **Plugins**: Client redirects, Algolia search, MDX support
- **Build scripts**: `start`, `build`, `serve`, `deploy`

## Content Organization

### Documentation Categories

1. **Getting Started**
   - Quick installation and setup
   - Hosting options (Cloud vs Self-hosted)
   - Environment configuration

2. **Core Concepts** 
   - Plan management and execution
   - Context and conversation handling
   - Version control integration
   - AI autonomy features

3. **Models**
   - AI provider configuration
   - Model settings and roles
   - Provider-specific documentation

4. **Hosting**
   - Cloud deployment options
   - Self-hosting setup (Docker-based)
   - Advanced configuration

### Content Features

- **Frontmatter Configuration**: Each markdown file uses YAML frontmatter for:
  - `sidebar_position`: Controls navigation order
  - `sidebar_label`: Custom navigation labels
  - Metadata and SEO configuration

- **Category Configuration**: `_category_.json` files define:
  - Category labels and positioning
  - Collapsible/expanded state
  - Hierarchical organization

## Build and Deployment

### Development Workflow
```bash
# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Serve production build
npm run serve
```

### Features
- **Live Reload**: Changes reflect immediately during development
- **Search**: Algolia-powered search with indexing
- **Dark Mode**: Default dark theme with light mode toggle
- **Responsive Design**: Mobile-friendly documentation
- **SEO Optimized**: Meta tags, social cards, structured data

### Deployment Configuration
- **Production URL**: `https://docs.planto.ai`
- **GitHub Integration**: Edit links point to GitHub repository
- **Netlify Redirects**: `_redirects` file handles URL routing
- **Search Indexing**: Algolia search integration

## Content Management

### Adding New Documentation
1. Create markdown files in appropriate directories
2. Use proper frontmatter configuration
3. Update category configurations if needed
4. Follow existing naming conventions

### Navigation Structure
The sidebar is auto-generated based on:
- Directory structure
- File naming conventions
- `_category_.json` configurations
- Frontmatter positioning

### Search Functionality
- **Algolia Search**: Professional search experience
- **Auto-indexing**: Content automatically indexed on deployment
- **Contextual Results**: Search results with relevant snippets

## Key Features

### User Experience
- **Single Page Application**: Fast navigation between docs
- **Progressive Web App**: Offline reading capability
- **Code Highlighting**: Syntax highlighting for multiple languages
- **Copy Code Buttons**: Easy code snippet copying

### Developer Experience
- **TypeScript Support**: Full TypeScript configuration
- **Hot Reloading**: Instant feedback during development
- **Plugin Ecosystem**: Extensible with Docusaurus plugins
- **Version Control**: Git-based content management

### Content Features
- **MDX Support**: React components in markdown
- **Admonitions**: Info, warning, tip callouts
- **Tabs**: Tabbed content sections
- **Code Blocks**: Multi-language syntax highlighting

## Integration Points

### External Services
- **Algolia**: Search functionality
- **GitHub**: Source code linking and edit functionality
- **Netlify**: Hosting and deployment
- **Social Platforms**: Discord, X, YouTube integration

### Brand Consistency
- **Logo Integration**: Light/dark mode logos
- **Color Scheme**: Consistent with main Planto branding
- **Typography**: Professional documentation styling
- **Social Previews**: Custom social media cards

This documentation system provides a comprehensive, maintainable, and user-friendly experience for Planto users and developers, with modern web standards and excellent search capabilities.
