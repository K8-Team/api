## Workflows Description
Comprehensive testing suite with parallel execution; encrypted Docker images stored in the repository with retention of the five most recent versions (older ones automatically deleted); manually or PR-merge triggered builds; secure AWS OIDC authentication (no static access keys); automatic ECR repository creation with lifecycle policies for image retention and full multi-region support. If workflows triggers by push event and image fails tests - it will not push image to storage.

## ⚠️ Workflow triggeres on: "event = push" to main branch of repo ⚠️

## Requirments - add to 'Repository secrets' folder in GitHub repo:
- Add Roles and Policy permissions to GitHub Actions (run script or create manually OIDC)
- AWS_ACCOUNT_ID
- DOCKERHUB_TOKEN
- DOCKERHUB_USERNAME


##  GitHub Actions Tests  
### These tests run before building the Docker image:
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


## Jenkins Pipeline Tests

### Node.js Code Validation Tests
- **Package.json Existence** - Verifies that package.json file exists in the repository root
- **Installing Production Dependencies** - Installs all production dependencies using npm to ensure the application can run
- **Validating JavaScript Syntax** - Checks JavaScript syntax of the main application file for errors
- **Running NPM Test Suite** - Executes npm test if a test script is defined in package.json

### Docker Image Validation Tests
- **Authenticating to ECR** - Verifies that the pipeline can successfully authenticate to AWS Elastic Container Registry
- **Pulling Docker Image from ECR** - Confirms that the built Docker image can be pulled from ECR without errors
- **Inspecting Docker Image** - Validates the Docker image metadata and checks the image size
- **Starting Container from Image** - Tests that a container can be started from the image and runs without crashing
