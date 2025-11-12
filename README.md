# Devops API App

## install the node packages for the api tier:

```sh
→ npm install
```

## start the app

```sh
→ npm start
```

## NOTE this app uses two env variables:

- PORT: the listening PORT
- DB: Name of the database to connect
- DBUSER: Database user
- DBPASS: DB user password,
- DBHOST: Database hostname,
- DBPORT: Database server listening port

These variables need to be set


## Description
Workflow run with auto tests, encypted images, saved in repo 5 last versions(old one deleted), triggered manually or by PR merge

### Pre-Build Tests - These tests run before building the Docker image:

1. **Lint Test** - Runs ESLint to check code quality and style
2. **Unit Tests** - Executes unit tests via npm test
3. **Integration Tests** - Runs integration test suite
4. **Security Scan** - Performs npm audit for dependency vulnerabilities
5. **Dockerfile Lint** - Validates Dockerfile best practices using Hadolint
6. **Dependency Validation** - Checks package.json validity, outdated packages, and duplicates
7. **License Compliance** - Scans dependencies for license issues and generates compliance reports


### Post-Build Tests - These tests run after building the Docker image:

1. **Vulnerability Scan** - Scans image for OS and library vulnerabilities using Trivy
2. **Health Endpoint Test** - Verifies the /health endpoint responds correctly
3. **Container Startup Test** - Ensures container starts successfully with required environment variables
4. **Image Size Test** - Checks if image size is under 500MB threshold
5. **Port Exposure Test** - Validates that port 3000 is properly exposed
6. **Environment Variables Test** - Tests container behavior with missing environment variables
7. **Security Test** - Verifies container runs as non-root user
8. **Graceful Shutdown Test** - Tests SIGTERM handling and shutdown time
9. **Layer Analysis** - Analyzes Docker image layers for optimization opportunities
---

## Workflow scheme diagram
```sh
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW TRIGGER                         │
│              (Manual: workflow_dispatch)                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   PRE-BUILD TESTS                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │   Lint   │  │   Unit   │  │Integration│ │ Security │     │
│  │   Test   │  │  Tests   │  │  Tests    │ │   Scan   │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                   │
│  │Dockerfile│  │Dependency│  │ License  │                   │
│  │   Lint   │  │  Check   │  │  Check   │                   │
│  └──────────┘  └──────────┘  └──────────┘                   │
└────────────────────────┬────────────────────────────────────┘
                         │ (continue-on-error: true)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    BUILD IMAGE                              │
│  1. Get latest version from Docker Hub                      │
│  2. Bump version (major/minor/patch)                        │
│  3. Build Docker image                                      │
│  4. Save image as artifact                                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  POST-BUILD TESTS                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │Vulnerabi-│  │  Health  │  │ Startup  │  │   Size   │     │
│  │   lity   │  │   Test   │  │   Test   │  │   Test   │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │  Ports   │  │Env Vars  │  │ Security │  │ Shutdown │     │
│  │   Test   │  │   Test   │  │   Test   │  │   Test   │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
│  ┌──────────┐                                               │
│  │  Layers  │                                               │
│  │ Analysis │                                               │
│  └──────────┘                                               │
└────────────────────────┬────────────────────────────────────┘
                         │ (if tests pass OR push_on_test_failure=yes)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   PUSH TO DOCKER HUB                        │
│  1. Login to Docker Hub                                     │
│  2. Tag image (version + latest)                            │
│  3. Push images                                             │
│  4. Cleanup old images (keep last 5)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  CLEANUP ARTIFACTS                          │
│  Delete temporary Docker image artifact from GitHub         │
└─────────────────────────────────────────────────────────────┘
```


## Example of Dockerfile
``` sh
# Build stage
FROM node:18-alpine AS builder
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Production stage
FROM node:18-alpine
WORKDIR /usr/src/app

# Copy dependencies from builder
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application code
COPY . .

# Set default environment variables (will be overridden by Kubernetes/Docker run)
ENV PORT=3000 \
    DB="" \
    DBUSER="" \
    DBPASS="" \
    DBHOST="" \
    DBPORT=""

# Expose application port
EXPOSE 3001

# Run as non-root user for security
USER node

# Start the application
CMD ["npm", "start"]
``` 