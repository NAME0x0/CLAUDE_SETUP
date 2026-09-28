---
name: api-spec-generator
description: Generates OpenAPI/Swagger specifications from route handlers and controllers
triggers:
  - /api-spec-generator
  - /openapi
  - /swagger
---

# Instructions

When this skill is invoked, analyze API routes and generate comprehensive OpenAPI 3.0 specification.

## Process

1. **Discover API Routes**:
   - Use Glob to find route files (`**/routes/**`, `**/controllers/**`, `**/api/**`)
   - Identify framework (Express, FastAPI, Flask, Gin, etc.)
   - Read all route definitions

2. **Extract Route Information**:

   For each endpoint, identify:
   - HTTP method (GET, POST, PUT, DELETE, PATCH)
   - Path with parameters (`/users/{id}`)
   - Request body schema
   - Query parameters
   - Path parameters
   - Response schemas (success and error)
   - Authentication requirements
   - Rate limiting info

3. **Infer Schemas**:
   - From TypeScript interfaces/types
   - From Python type hints / Pydantic models
   - From JSDoc comments
   - From validation libraries (Joi, Zod, Yup)
   - From actual response examples in code

4. **Generate OpenAPI Spec**:

   ```yaml
   openapi: 3.0.3
   info:
     title: API Name
     description: Auto-generated API documentation
     version: 1.0.0

   servers:
     - url: http://localhost:3000
       description: Development
     - url: https://api.example.com
       description: Production

   paths:
     /users:
       get:
         summary: List all users
         tags: [Users]
         parameters:
           - name: limit
             in: query
             schema:
               type: integer
               default: 10
         responses:
           '200':
             description: Successful response
             content:
               application/json:
                 schema:
                   type: array
                   items:
                     $ref: '#/components/schemas/User'

     /users/{id}:
       get:
         summary: Get user by ID
         tags: [Users]
         parameters:
           - name: id
             in: path
             required: true
             schema:
               type: string
         responses:
           '200':
             description: User found
             content:
               application/json:
                 schema:
                   $ref: '#/components/schemas/User'
           '404':
             description: User not found

   components:
     schemas:
       User:
         type: object
         properties:
           id:
             type: string
           email:
             type: string
             format: email
           name:
             type: string
         required: [id, email]

     securitySchemes:
       bearerAuth:
         type: http
         scheme: bearer
         bearerFormat: JWT

   security:
     - bearerAuth: []
   ```

5. **Validate Specification**:
   - Check for missing required fields
   - Verify schema references exist
   - Validate against OpenAPI 3.0 schema

## Output Format

```markdown
## OpenAPI Specification Generated

**File**: `openapi.yaml` (or `openapi.json`)
**Endpoints Documented**: 24
**Schemas Defined**: 15

### Endpoints by Tag
- **Users** (6 endpoints): CRUD + search, profile
- **Orders** (8 endpoints): CRUD + status, payments
- **Auth** (4 endpoints): login, logout, refresh, register

### Schemas
- User, UserCreate, UserUpdate
- Order, OrderCreate, OrderStatus
- Error, PaginatedResponse

### Viewing the Docs
```bash
# Swagger UI
npx swagger-ui-express

# Redoc
npx redoc-cli serve openapi.yaml
```

### Integration
[Instructions for integrating with existing app]
```

## Enhancements

- Generate client SDKs using openapi-generator
- Add example values based on test fixtures
- Include authentication flow diagrams
- Generate Postman collection from spec
- Add webhook documentation
- Include rate limiting headers in responses
- Validate spec against existing tests
