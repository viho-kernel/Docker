# Tech Stack Essentials: What Each Language/Framework Needs (Developer Fundamentals)

## The Core Thinking Framework

When you Dockerize **anything**, you're answering ONE question:

> "What does this application need to RUN in isolation?"

For each tech stack, identify:

1. **Runtime** - What interpreter/JVM/engine executes the code?
2. **Dependencies/Packages** - What libraries does the code need?
3. **Build Artifacts** - What does the app produce that needs to run?
4. **Configuration** - What files configure the app?
5. **Entry Point** - How does the app start?

---

## NODE.JS (JavaScript/TypeScript)

### Essential Files

```
my-app/
├── package.json        ← Lists dependencies
├── package-lock.json   ← Locks specific versions (important for reproducibility)
├── index.js or server.js  ← Entry point
└── src/               ← Your code
```

### What Node Needs

- **Runtime**: Node.js interpreter
- **Dependencies**: Listed in `package.json` → installed via `npm install`
- **Entry**: Usually `node index.js` or script in `package.json`

### Dockerfile Thinking

```dockerfile
FROM node:18-alpine        # Get Node runtime
WORKDIR /app              # Set working directory
COPY package*.json ./     # Copy dependency list
RUN npm install           # Install dependencies (this is the KEY step)
COPY . .                  # Copy your code
EXPOSE 3000               # If it's a server
CMD ["node", "index.js"]  # How to start it
```

**Key Insight**: The critical step is `npm install` - it reads `package.json` and creates `node_modules/`. Without this, Node can't find dependencies.

---

## PYTHON (Flask, Django, FastAPI)

### Essential Files

```
my-app/
├── requirements.txt    ← Lists dependencies (pip freeze > requirements.txt)
├── app.py or main.py   ← Entry point
├── venv/              ← Virtual environment (DON'T copy this)
└── src/               ← Your code
```

### What Python Needs

- **Runtime**: Python interpreter
- **Dependencies**: Listed in `requirements.txt` → installed via `pip install -r requirements.txt`
- **Virtual Environment**: Created INSIDE Docker (don't copy from local)

### Dockerfile Thinking

```dockerfile
FROM python:3.11-slim     # Get Python runtime
WORKDIR /app
COPY requirements.txt .   # Copy dependency list
RUN pip install -r requirements.txt  # Install dependencies (KEY step)
COPY . .                  # Copy your code
EXPOSE 5000               # If Flask/FastAPI
CMD ["python", "app.py"]  # How to start
```

**Key Insight**: Python needs a `requirements.txt` - it's like Node's `package.json`. The `pip install` command reads this file and gets all packages.

**Pro Tip**: Unlike Node, you DON'T copy your local `venv/` folder - Docker creates its own clean environment.

---

## JAVA (Spring Boot, Maven/Gradle)

### Essential Files

```
my-app/
├── pom.xml            ← Maven dependency config (or build.gradle for Gradle)
├── src/
│   └── main/java/     ← Your code
├── target/            ← Build output (Maven creates this)
│   └── myapp.jar      ← Compiled JAR file (what actually runs)
└── Dockerfile
```

### What Java Needs

- **Runtime**: JDK (Java Development Kit) to compile, JRE (Java Runtime) to run
- **Dependencies**: Listed in `pom.xml` (Maven) or `build.gradle` (Gradle)
- **Build Process**: `mvn clean package` creates a JAR file
- **Execution**: `java -jar myapp.jar` runs the compiled JAR

### Dockerfile Thinking (Multi-stage - this is important!)

```dockerfile
# STAGE 1: Build
FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline  # Download dependencies once
COPY src ./src
RUN mvn clean package           # Creates target/myapp.jar

# STAGE 2: Runtime
FROM openjdk:17-jre-slim        # Smaller JRE image (no compiler needed)
WORKDIR /app
COPY --from=builder /app/target/myapp.jar app.jar
EXPOSE 8080                     # Spring Boot default
CMD ["java", "-jar", "app.jar"]
```

**Key Insight**: Java has a "build" step (compiling to JAR). You can use multi-stage builds: compile in heavy image, run in light image. This saves space.

**Critical Knowledge**:

- `pom.xml` = dependency list + build config
- `mvn clean package` = compile your code into a JAR
- You run the JAR, not source code

---

## GO

### Essential Files

```
my-app/
├── go.mod            ← Lists dependencies
├── go.sum            ← Locks versions
├── main.go           ← Entry point
└── src/              ← Your code
```

### What Go Needs

- **Runtime**: Go compiler (for building), but compiled binary doesn't need runtime
- **Dependencies**: Listed in `go.mod` → installed via `go mod download`
- **Build**: `go build` creates a binary executable

### Dockerfile Thinking

```dockerfile
# STAGE 1: Build
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download           # Get dependencies
COPY . .
RUN go build -o myapp .      # Creates "myapp" binary

# STAGE 2: Runtime
FROM alpine:latest            # Super tiny base image
COPY --from=builder /app/myapp /myapp
EXPOSE 8080
CMD ["/myapp"]
```

**Key Insight**: Go compiles to a BINARY. Once compiled, it needs almost nothing - no runtime, no interpreter. That's why the final image is tiny.

---

## PHP (Laravel, Symfony)

### Essential Files

```
my-app/
├── composer.json      ← Dependency list (like package.json for PHP)
├── composer.lock      ← Version lock
├── index.php          ← Entry point
├── app/               ← Your code
└── public/            ← Web root
```

### What PHP Needs

- **Runtime**: PHP-FPM (PHP FastCGI) or mod_php
- **Web Server**: Nginx or Apache to serve requests to PHP
- **Dependencies**: Listed in `composer.json` → installed via `composer install`

### Dockerfile Thinking

```dockerfile
FROM php:8.1-fpm-alpine       # PHP-FPM runtime
WORKDIR /app

# Install Composer (PHP dependency manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json composer.lock ./
RUN composer install           # Get dependencies

COPY . .                        # Copy your code
EXPOSE 9000                     # PHP-FPM port (not HTTP)
CMD ["php-fpm"]               # PHP-FPM process
```

**BUT WAIT** - PHP-FPM doesn't speak HTTP directly. You need Nginx in front:

```dockerfile
# Use docker-compose to run both:
# - PHP container (PHP-FPM)
# - Nginx container (handles HTTP, forwards to PHP)
```

**Key Insight**: PHP needs TWO containers usually - one for PHP-FPM, one for Nginx. They talk via network.

---

## Ruby (Rails, Sinatra)

### Essential Files

```
my-app/
├── Gemfile           ← Dependency list (Ruby's equivalent)
├── Gemfile.lock      ← Version lock
├── app.rb or config/environment.rb  ← Entry point
└── app/              ← Your code
```

### What Ruby Needs

- **Runtime**: Ruby interpreter
- **Dependencies**: Listed in `Gemfile` → installed via `bundle install`
- **Bundler**: Package manager (like npm for Node)

### Dockerfile Thinking

```dockerfile
FROM ruby:3.1-alpine          # Ruby runtime
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install            # Install gem dependencies
COPY . .
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

**Key Insight**: Like Node/Python - copy dependency list, install, then copy code.

---

## NGINX (Web Server)

### Essential Files

```
my-nginx/
├── nginx.conf         ← Configuration file
└── Dockerfile
```

### What Nginx Needs

- **Configuration**: `nginx.conf` (tells Nginx how to serve/route)
- **Static files** (optional): HTML, CSS, JS to serve

### Dockerfile Thinking

```dockerfile
FROM nginx:alpine
# Remove default config
RUN rm /etc/nginx/conf.d/default.conf
# Copy your config
COPY nginx.conf /etc/nginx/conf.d/
# Copy static files (optional)
COPY ./html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Key Insight**: Nginx is just a configuration. You're telling it: "Here's how to route traffic" and optionally "Here are static files to serve."

---

## The Universal Pattern

No matter the language, the Dockerfile thinking is always:

```
1. Pick base image with runtime
2. Set working directory
3. Copy dependency files (package.json, requirements.txt, pom.xml, go.mod, Gemfile, etc.)
4. Install dependencies (npm install, pip install, mvn download, go mod download, bundle install, etc.)
5. Copy your actual code
6. Expose ports
7. Define how to start it
```

**Why this order?**

- Docker caches layers. Copying dependencies separately means if you change code, Docker reuses the cached dependency layer (saves time).

---

## Decision Tree: "What do I need for tech stack X?"

When someone asks you to Dockerize something:

1. **What's the language/framework?** (Node, Python, Java, Go, PHP, etc.)
2. **What file lists dependencies?** (package.json, requirements.txt, pom.xml, go.mod, Gemfile, composer.json)
3. **What's the build process?** (None for Python/Node/PHP, `mvn clean package` for Java, `go build` for Go)
4. **What's the entry point?** (node app.js, python app.py, java -jar app.jar, ./myapp for Go)
5. **Does it need other services?** (PHP needs Nginx, some services need databases)

---

## Real Scenario: Tomorrow's Interview/Task

**Boss**: "We have a Node.js + Express app. Write the Dockerfile."

**Your Brain Should Think**:

- Node.js runtime ✓
- It has `package.json` ✓
- Dependencies installed via `npm install` ✓
- Starts with `npm start` (check package.json scripts) ✓
- Probably listens on port 3000 ✓

**Dockerfile you write**: _(See Node example above)_

---

## Real Scenario 2: Spring Boot Service

**Boss**: "Package this Spring Boot service as Docker."

**Your Brain Should Think**:

- Java runtime (need JDK to build, JRE to run) ✓
- Depends on `pom.xml` ✓
- Build step: `mvn clean package` creates JAR ✓
- Run: `java -jar myapp.jar` ✓
- Two-stage build makes sense (smaller image) ✓

**Dockerfile you write**: _(See Java example above)_

---

## Key Insight: The Real Skill

The real skill isn't Docker. **It's understanding what each tech stack fundamentally needs to run.**

Once you know:

- Node needs `node_modules/` (from package.json)
- Python needs packages (from requirements.txt)
- Java needs a compiled JAR
- Go needs a binary
- PHP needs a PHP-FPM container + Nginx

...writing Dockerfiles becomes trivial. It's just "put this in a container the way it needs to run."

---

## Common Gotchas (Experience-Level Knowledge)

1. **Copying .gitignore files**: If you `COPY . .`, make sure `.dockerignore` excludes junk
   - Otherwise you copy 500MB of node_modules or .git history

2. **Multi-stage builds**: Worth using for Java, Go, TypeScript (anything that builds)
   - Keeps final image small

3. **Alpine vs full images**:
   - `node:18-alpine` = 170MB, good for most cases
   - `node:18` = 900MB, has more tools built in
   - For production, alpine is usually better

4. **Volumes in development vs production**:
   - Dev: Mount code directory for hot reload
   - Production: Copy code into image, no mounts

5. **Env variables vs hardcoding**:
   - `ENV DATABASE_URL=...` in Dockerfile
   - `ARG` for build-time, `ENV` for runtime

6. **Running as non-root**: Security best practice
   ```dockerfile
   RUN useradd -m appuser
   USER appuser
   ```

# Multi-Stage Builds: COPY --from Explained (What Goes Where?)

## The Question

```dockerfile
COPY --from=builder /app/??? ???
                    ↑         ↑
            Source path    Destination
         (WHERE IS IT?)    (WHERE TO PUT IT?)
```

---

## JAVA Spring Boot Example (Most Common)

### What Happens in Stage 1

```dockerfile
FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package
# CREATES: /app/target/myapp.jar
```

**After `mvn clean package` finishes:**

```
Inside builder stage:
/app/
├── pom.xml
├── src/
├── target/           ← OUTPUT created
│   ├── classes/
│   ├── lib/          ← Dependencies compiled in
│   ├── myapp.jar     ← This is what we want!
│   └── ...
└── ...other files...
```

### What We Copy in Stage 2

```dockerfile
FROM openjdk:17-jre-slim AS runtime
WORKDIR /app
COPY --from=builder /app/target/myapp.jar app.jar
                    ↑                     ↑
            Source (from stage 1)   Destination (in this stage)
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

**Result in Stage 2:**

```
/app/
├── app.jar     ← Copied from /app/target/myapp.jar
```

---

## Breakdown

### Source Path: `/app/target/myapp.jar`

- `/app/` = working directory we set in stage 1
- `target/` = folder Maven created
- `myapp.jar` = the actual compiled JAR file

### Destination Path: `app.jar`

- Just a filename (relative to current WORKDIR)
- It goes to `/app/app.jar` because WORKDIR is `/app`

---

## GO Example

### Stage 1 Creates Binary

```dockerfile
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o myapp .
# CREATES: /app/myapp (binary executable)
```

**After `go build` finishes:**

```
Inside builder stage:
/app/
├── go.mod
├── go.sum
├── main.go
├── src/
├── myapp       ← This is the binary we want!
└── ...
```

### Stage 2 Copies Binary

```dockerfile
FROM alpine:latest AS runtime
WORKDIR /app
COPY --from=builder /app/myapp myapp
                    ↑           ↑
            Binary from stage1  Name in stage2
EXPOSE 8080
CMD ["./myapp"]
```

**Result:**

```
/app/
├── myapp       ← Binary ready to run
```

---

## Python Flask Example

### Stage 1 (If you need compilation/build)

```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt
# CREATES: /root/.local/lib/python3.11/site-packages/
```

### Stage 2 Copies Packages

```dockerfile
FROM python:3.11-slim AS runtime
WORKDIR /app
COPY --from=builder /root/.local/lib /root/.local/lib
                    ↑                 ↑
        Site-packages from stage1   Same location in stage2
COPY . .
CMD ["python", "app.py"]
```

**Result:**

```
/root/.local/lib/    ← All installed packages
/app/                ← All your code
```

---

## Node.js Example (Usually No Multi-Stage)

### If You Use Multi-Stage (for TypeScript compilation)

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
# CREATES: /app/dist/ (compiled JavaScript)
```

**After `npm run build`:**

```
Inside builder stage:
/app/
├── package.json
├── src/              ← TypeScript source
├── dist/             ← Compiled JavaScript (OUTPUT)
│   ├── index.js
│   ├── utils.js
│   └── ...
└── node_modules/
```

### Stage 2 Copies Compiled Code

```dockerfile
FROM node:18-alpine AS runtime
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY --from=builder /app/dist dist
                    ↑         ↑
            Compiled code   Destination folder
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Result:**

```
/app/
├── package.json
├── node_modules/      ← Only production deps (--production flag)
├── dist/              ← Compiled code from stage 1
│   ├── index.js
│   └── ...
```

---

## PHP with Composer and Nginx

### This is Different! You copy to different places

```dockerfile
# Stage 1: Dependencies
FROM composer:2 AS dependency-installer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader
# CREATES: /app/vendor/
```

### Stage 2: PHP-FPM

```dockerfile
FROM php:8.1-fpm-alpine AS app
WORKDIR /app
COPY --from=dependency-installer /app/vendor vendor
COPY . .
EXPOSE 9000
CMD ["php-fpm"]
```

### Stage 3: Nginx (SEPARATE container, but let's show the pattern)

```dockerfile
FROM nginx:alpine
COPY --from=app /app /app/public
                ↑     ↑
         Code from    Where Nginx serves from
         PHP stage
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## The Pattern (Universal)

```dockerfile
# Stage 1
FROM [build-image] AS builder
RUN [build command that CREATES something]
# Output is at: /app/[SOMETHING]

# Stage 2
FROM [runtime-image]
COPY --from=builder /app/[SOMETHING] [DESTINATION]
                    ↑                 ↑
            Exact path from       Where to put it
            builder stage         in runtime stage
```

---

## Real Question: "What Goes After /app/?"

### For Java

- **After `/app/`**: `target/myapp.jar`
  - Because Maven creates output in `target/` folder
  - The JAR file is specifically `myapp.jar`

```dockerfile
COPY --from=builder /app/target/myapp.jar app.jar
```

### For Go

- **After `/app/`**: `myapp` (just the binary name)
  - Because `go build -o myapp` creates binary in working directory

```dockerfile
COPY --from=builder /app/myapp myapp
```

### For Node (TypeScript)

- **After `/app/`**: `dist` (the whole folder)
  - Because `npm run build` creates entire `dist/` folder

```dockerfile
COPY --from=builder /app/dist dist
```

### For Python

- **After `/app/`**: `src/` or specific files
  - Depends what you built/created

```dockerfile
COPY --from=builder /app/dist dist
# OR
COPY --from=builder /app/src src
```

---

## What You're Actually Asking: The Full Path Breakdown

Let's use **Java Spring Boot** as example:

### Stage 1: Maven creates files

```
/app/
├── pom.xml
├── src/
│   └── main/java/com/example/App.java
├── target/
│   ├── classes/              ← Compiled classes
│   ├── dependency/           ← Downloaded JARs
│   ├── myapp-1.0.0.jar       ← Final packaged JAR
│   └── myapp-1.0.0-SNAPSHOT.jar
```

### Stage 2: What to copy?

**Option 1: Copy final JAR only**

```dockerfile
COPY --from=builder /app/target/myapp-1.0.0.jar app.jar
```

**Option 2: Copy specific JAR (snapshot version)**

```dockerfile
COPY --from=builder /app/target/myapp-1.0.0-SNAPSHOT.jar app.jar
```

**What changes after `/app/`?**

- `target/` = the folder created by Maven
- `myapp-1.0.0.jar` = the specific file you want

---

## Quick Answer to Your Question

When you ask "**what goes after `/app/`?":**

**Look at what the build command creates:**

| Build Tool | Creates                     | Copy Command                                    |
| ---------- | --------------------------- | ----------------------------------------------- |
| Maven      | `/app/target/myapp.jar`     | `COPY --from=builder /app/target/myapp.jar`     |
| Gradle     | `/app/build/libs/myapp.jar` | `COPY --from=builder /app/build/libs/myapp.jar` |
| Go         | `/app/myapp`                | `COPY --from=builder /app/myapp`                |
| Node (TS)  | `/app/dist/`                | `COPY --from=builder /app/dist`                 |
| Python     | `/app/dist/`                | `COPY --from=builder /app/dist`                 |

**The answer is always: "Whatever the build command created"**

---

## Destination Part (After the space)

```dockerfile
COPY --from=builder /app/target/myapp.jar app.jar
                                          ↑
                                   Destination
```

### Options:

1. **Just a name**: `app.jar`
   - Goes to `$WORKDIR/app.jar` (i.e., `/app/app.jar`)

2. **Full path**: `/app/app.jar`
   - Same as above but explicit

3. **In a subfolder**: `bin/app.jar`
   - Goes to `/app/bin/app.jar`

### Common Patterns:

```dockerfile
# Copy and rename
COPY --from=builder /app/target/myapp-1.0.0.jar app.jar

# Copy to specific folder
COPY --from=builder /app/target/myapp.jar /opt/app/myapp.jar

# Copy with exact same name
COPY --from=builder /app/myapp myapp
```

---

## The Mental Model

**Stage 1** = "Create the thing"

```
BUILD PROCESS → Creates /app/target/myapp.jar
```

**Stage 2** = "Copy the thing from Stage 1"

```
COPY --from=builder /app/target/myapp.jar app.jar
                    └─ Where it is    └─ Where to put it
```

**That's it.**

---

## Real-World Example: You're Given This Task

**Task**: "Package this Spring Boot app in Docker"

**You look at the project:**

```
pom.xml
src/
README.md
```

**You run `mvn clean package` locally and see:**

```
target/
└── myspring-api-2.5.0.jar
```

**You write:**

```dockerfile
FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package
# Creates /app/target/myspring-api-2.5.0.jar

FROM openjdk:17-jre-slim
WORKDIR /app
COPY --from=builder /app/target/myspring-api-2.5.0.jar app.jar
# Copies /app/target/myspring-api-2.5.0.jar → /app/app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

**You know exactly what goes after `/app/`** because you saw what Maven created.

That's the expertise.
