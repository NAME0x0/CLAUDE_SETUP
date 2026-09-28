---
name: docker-architect
description: Generates optimized multi-stage Dockerfiles and Docker Compose configurations
triggers:
  - /docker-architect
  - /docker
  - /dockerfile
---

# Instructions

When this skill is invoked, analyze the project and generate production-ready Docker configuration.

## Process

1. **Analyze Project**:
   - Identify language and framework
   - Determine build process and dependencies
   - Identify runtime requirements
   - Check for existing Docker files to enhance

2. **Generate Optimized Dockerfile**:

   **Multi-Stage Build Pattern**:

   **Node.js Example**:
   ```dockerfile
   # Build stage
   FROM node:20-alpine AS builder
   WORKDIR /app

   # Install dependencies first (better caching)
   COPY package*.json ./
   RUN npm ci --only=production

   # Copy source and build
   COPY . .
   RUN npm run build

   # Production stage
   FROM node:20-alpine AS production
   WORKDIR /app

   # Security: non-root user
   RUN addgroup -g 1001 -S nodejs && \
       adduser -S nextjs -u 1001

   # Copy only production artifacts
   COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
   COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
   COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

   USER nextjs
   EXPOSE 3000
   ENV NODE_ENV=production

   CMD ["node", "dist/main.js"]
   ```

   **Python Example**:
   ```dockerfile
   # Build stage
   FROM python:3.12-slim AS builder
   WORKDIR /app

   RUN pip install --no-cache-dir poetry
   COPY pyproject.toml poetry.lock ./
   RUN poetry export -f requirements.txt -o requirements.txt

   # Production stage
   FROM python:3.12-slim AS production
   WORKDIR /app

   # Security: non-root user
   RUN useradd --create-home --shell /bin/bash app

   COPY --from=builder /app/requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt

   COPY --chown=app:app . .
   USER app

   EXPOSE 8000
   CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```

3. **Generate docker-compose.yml**:

   ```yaml
   version: '3.8'

   services:
     app:
       build:
         context: .
         dockerfile: Dockerfile
         target: production
       ports:
         - "3000:3000"
       environment:
         - NODE_ENV=production
         - DATABASE_URL=postgresql://postgres:postgres@db:5432/app
       depends_on:
         db:
           condition: service_healthy
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
         interval: 30s
         timeout: 10s
         retries: 3
       restart: unless-stopped

     db:
       image: postgres:16-alpine
       environment:
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: postgres
         POSTGRES_DB: app
       volumes:
         - postgres_data:/var/lib/postgresql/data
       healthcheck:
         test: ["CMD-SHELL", "pg_isready -U postgres"]
         interval: 5s
         timeout: 5s
         retries: 5

     redis:
       image: redis:7-alpine
       command: redis-server --appendonly yes
       volumes:
         - redis_data:/data

   volumes:
     postgres_data:
     redis_data:
   ```

4. **Generate .dockerignore**:
   ```
   node_modules
   npm-debug.log
   .git
   .gitignore
   .env*
   !.env.example
   Dockerfile*
   docker-compose*
   .dockerignore
   README.md
   .vscode
   coverage
   .nyc_output
   dist
   ```

## Output Format

```markdown
## Docker Configuration Generated

### Files Created
- `Dockerfile` - Multi-stage production build
- `docker-compose.yml` - Full stack with dependencies
- `.dockerignore` - Build context exclusions

### Image Details
- **Base Image**: node:20-alpine
- **Final Size**: ~150MB (estimated)
- **Security**: Non-root user, minimal attack surface

### Commands
```bash
# Build
docker build -t myapp:latest .

# Run standalone
docker run -p 3000:3000 myapp:latest

# Run with compose
docker-compose up -d

# View logs
docker-compose logs -f app
```

### Production Checklist
- [ ] Set proper environment variables
- [ ] Configure secrets management
- [ ] Set up container registry
- [ ] Configure health checks
- [ ] Set resource limits
```

## Enhancements

- Generate Kubernetes manifests (Deployment, Service, ConfigMap)
- Add container security scanning (Trivy)
- Generate GitHub Actions for image building
- Include development docker-compose override
- Add nginx reverse proxy configuration
- Generate Helm charts for K8s deployment
- Optimize for specific cloud providers (ECS, Cloud Run, etc.)
