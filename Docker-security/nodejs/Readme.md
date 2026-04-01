# 🔐 Securing Your Containers: Docker Best Practices

A comprehensive guide to building secure, production-ready Docker containers with minimal attack surface and optimized performance.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Security Practices](#key-security-practices)
  - [Run as Non-Root User](#1-run-as-non-root-user)
  - [Use .dockerignore](#2-use-dockerignore)
  - [Multi-Stage Builds](#3-multi-stage-builds)
  - [Distroless Images](#4-distroless-images)
  - [Version Control Best Practices](#5-version-control-best-practices)
- [Quick Start](#quick-start)
- [Real-World Example](#real-world-example)
- [Security Checklist](#security-checklist)

---

## Overview

Container security is not an afterthought—it's fundamental to your infrastructure. This guide walks you through essential practices that reduce your attack surface, limit blast radius, and prevent privilege escalation attacks.

**Key Benefits:**

- ✅ Prevent host compromise
- ✅ Reduce image bloat (400MB → 79.5MB possible)
- ✅ Minimize attack surface
- ✅ Faster deployments
- ✅ Better resource efficiency

---

## Key Security Practices

### 1. Run as Non-Root User

**Why It Matters:**

Running containers as root is the default for many images, but it's a critical security vulnerability.

| Risk                     | Impact                                                             |
| ------------------------ | ------------------------------------------------------------------ |
| **Host Compromise**      | Attackers can interact with Docker daemon and escape the container |
| **Privilege Escalation** | Root access enables installation of malicious software             |
| **DoS Attacks**          | Unlimited resource consumption can crash the host                  |
| **Blast Radius**         | Full system access if any vulnerability is exploited               |

**How to Implement:**

```dockerfile
# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Switch to that user
USER appuser
```

**Verification:**

```bash
docker run your-image
id
# Should show: uid=XXX(appuser) gid=XXX(appuser) groups=XXX(appuser)
```

---

### 2. Use .dockerignore

**Without .dockerignore, you risk:**

- 🚨 Leaking `.env` files and secrets
- 📚 Including `.git` history (increases size unnecessarily)
- 📦 Bloating images with `node_modules` before they're needed
- 🐛 Including build artifacts and temporary files

**Example .dockerignore:**

```
# Dependencies
node_modules

# Environment files
.env
.env.*
.npmrc

# Git and version control
.git
.gitignore
.gitattributes

# Docker specific files
Dockerfile
docker-compose*.yml

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode
.idea
*.swp
```

---

### 3. Multi-Stage Builds

**The Problem:**
Standard Docker builds include all build-time dependencies (compilers, SDKs, build tools) in your final image, dramatically increasing size and attack surface.

**The Solution:**
Use multiple stages—one for building, one for running.

**Stage 1: Build**

```dockerfile
FROM node:latest AS Builder

RUN groupadd -r nonroot && useradd -r -g nonroot nonroot
WORKDIR /app
COPY package*.json .
RUN npm install
COPY *.js .
```

**Stage 2: Runtime** (slim, minimal, only what you need)

```dockerfile
FROM node:25-slim

WORKDIR /app

# Copy only the compiled/installed artifacts
COPY --from=Builder /app/node_modules ./node_modules
COPY --from=Builder /app/*.js ./app.js

USER nonroot
EXPOSE 3000
CMD ["node", "app.js"]
```

**Results:**

- 📉 400MB → 79.5MB (typical reduction)
- ⚡ Faster deployments
- 🔒 Smaller attack surface

---

### 4. Distroless Images

**What are distroless images?**
Container images containing _only_ your application and its runtime dependencies—no package managers, shells, or OS-level utilities.

**Benefits:**

- Smallest possible images
- Minimal system packages = fewer vulnerabilities
- Reduced attack surface
- Perfect for production

**Example with Distroless:**

```dockerfile
FROM node:latest AS Builder

RUN groupadd -r nonroot && useradd -r -g nonroot nonroot
WORKDIR /app
COPY package*.json .
RUN npm install
COPY *.js .

# Distroless image with no shell, no package manager
FROM gcr.io/distroless/nodejs22-debian13

WORKDIR /app
COPY --from=Builder /app/node_modules ./node_modules
COPY --from=Builder /app/*.js ./app.js

USER nonroot
EXPOSE 3000
CMD ["app.js"]
```

**Popular Distroless Images:**

- `gcr.io/distroless/nodejs22-debian13` (Node.js)
- `gcr.io/distroless/python3` (Python)
- `gcr.io/distroless/java17` (Java)
- `gcr.io/distroless/cc` (C/C++)

---

### 5. Version Control Best Practices

**Always create a .gitignore to prevent leaking sensitive data:**

```
# Dependencies
node_modules

# Environment files
.env
.env.*
.npmrc

# Git and version control
.git
.gitignore
.gitattributes

# Docker specific files
Dockerfile
docker-compose*.yml
```

---

## Quick Start

### Minimal Secure Dockerfile

```dockerfile
FROM node:latest AS builder

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
WORKDIR /app

# Install dependencies
COPY package*.json .
RUN npm install

# Copy application
COPY *.js .

# Runtime stage
FROM node:25-slim

WORKDIR /app

# Copy only necessary artifacts
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/*.js ./

# Use non-root user
USER appuser

EXPOSE 3000
CMD ["node", "app.js"]
```

---

## Real-World Example

**Before (Insecure):**

- ❌ Runs as root
- ❌ 400MB image size
- ❌ Includes build tools and compilers
- ❌ No .dockerignore file
- ❌ Secrets in .env files included

**After (Secure):**

- ✅ Runs as non-root user
- ✅ 79.5MB image size (80% reduction)
- ✅ Multi-stage build
- ✅ Distroless base image
- ✅ .dockerignore prevents secret leaks
- ✅ Minimal attack surface

---

## Security Checklist

Use this checklist before pushing your containers to production:

- [ ] Application runs as non-root user
- [ ] Used multi-stage builds to reduce image size
- [ ] Considered distroless images for runtime
- [ ] Created .dockerignore file (no secrets, no .git, no node_modules)
- [ ] Created .gitignore file (no .env files, no secrets)
- [ ] Scanned image for vulnerabilities (`docker scout cves`)
- [ ] Verified all base image versions are current
- [ ] Removed unnecessary packages and build tools
- [ ] Set explicit EXPOSE ports
- [ ] Used specific base image tags (not `latest`)
- [ ] Implemented health checks for production
- [ ] Documented security practices in your code

---

## Deployment Best Practices

```bash
# Build your image
docker build -t myapp:1.0.0 .

# Scan for vulnerabilities
docker scout cves myapp:1.0.0

# Run with minimal permissions
docker run --read-only --cap-drop=ALL myapp:1.0.0

# Use container orchestration (Kubernetes, Docker Swarm)
# with network policies and RBAC
```

---

## Resources

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [Docker Scout](https://docs.docker.com/scout/)
- [OWASP Container Security](https://owasp.org/www-project-container-security/)

---

## Contributing

Have improvements to these practices? Open an issue or PR!

---

## License

MIT

---

**Remember:** Container security is a journey, not a destination. Regularly audit your images, update base images, and stay informed about emerging threats.
