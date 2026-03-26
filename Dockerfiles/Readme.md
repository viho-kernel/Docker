# Docker Commands Reference

A comprehensive guide to essential Docker commands for container management and orchestration.

## Table of Contents

- [Basic Commands](#basic-commands)
- [Advanced Commands](#advanced-commands)
- [Best Practices](#best-practices)

## Basic Commands

### Image & Container Lifecycle

| Command                       | Description                                        |
| ----------------------------- | -------------------------------------------------- |
| `docker ps`                   | List all running containers                        |
| `docker ps -a`                | List all containers (running and stopped)          |
| `docker pull nginx`           | Pull an image from Docker Hub                      |
| `docker create nginx`         | Create a container without starting it             |
| `docker start <container-id>` | Start an existing container                        |
| `docker rm <container-id>`    | Remove a stopped container                         |
| `docker rmi nginx`            | Remove an image                                    |
| `docker run nginx`            | Pull, create, and start a container in one command |

## Advanced Commands

### Running Containers

```bash
# Run in foreground (interactive)
docker run nginx

# Run in background (detached mode)
docker run -d nginx
docker run -d nginx:latest
```

### Container Management

```bash
# Remove containers
docker rm -f b3                    # Remove container starting with 'b3'
docker rm -f $(docker ps -aq)      # Remove all containers

# Expose ports
docker run -d -p 8080:80 nginx     # Map port 8080 (host) to 80 (container)

# Interactive terminal access
docker exec -it <container-id> /bin/bash    # Login into a running container

# Get container information
docker inspect <container-id>      # View detailed container configuration
docker stats                       # Display real-time container statistics

# Named containers
docker run -d -p 8080:80 --name frontend nginx    # Assign a friendly name
```

### Useful Variations

```bash
# View logs
docker logs <container-id>
docker logs -f <container-id>      # Follow logs in real-time

# Copy files
docker cp <container-id>:/path/to/file ./local/path

# Commit changes to create new image
docker commit <container-id> my-image:tag
```

## Best Practices

- Use **named containers** for easier identification and management
- Always specify **image tags** (e.g., `nginx:1.21`) instead of relying on `latest`
- Use **detached mode** (`-d`) for background services
- Map ports explicitly with `-p` for clarity
- Use `docker ps -a` to manage container cleanup
- Leverage `docker inspect` for debugging container issues
- Monitor resource usage regularly with `docker stats`
- Use `.dockerignore` files to reduce image size

## Quick Reference

```bash
# Common workflow
docker pull nginx                              # Get image
docker run -d -p 8080:80 --name web nginx    # Start container
docker ps                                      # Verify running
docker logs web                                # Check logs
docker exec -it web /bin/bash                 # Access container
docker stop web                                # Stop gracefully
docker rm web                                  # Clean up
```

---

**Note:** Replace `<container-id>` with actual container ID or name. Use `docker --help` for more information.
