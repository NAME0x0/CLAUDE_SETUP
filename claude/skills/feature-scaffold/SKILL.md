---
name: feature-scaffold
description: Generates boilerplate for routes, models, services, and controllers following project conventions
triggers:
  - /feature-scaffold
  - /new-feature
  - /scaffold
---

# Instructions

When this skill is invoked, generate complete boilerplate code for a new feature following the existing project's patterns.

## Process

1. **Analyze Existing Codebase**:
   - Use Glob to find existing routes, models, services, controllers
   - Use Read to examine 2-3 examples of each to understand patterns
   - Identify naming conventions (camelCase, snake_case, PascalCase)
   - Detect framework being used (Express, FastAPI, Django, Rails, etc.)

2. **Gather Feature Requirements**:
   - Feature name (e.g., "user-profile", "order-management")
   - Required operations: CRUD, specific actions, or custom
   - Related entities/models involved
   - API endpoints needed (if applicable)

3. **Generate Components Based on Framework**:

   **For Node.js/Express:**
   - `routes/[feature].routes.js`
   - `controllers/[feature].controller.js`
   - `services/[feature].service.js`
   - `models/[feature].model.js`
   - `validators/[feature].validator.js`

   **For Python/FastAPI:**
   - `routers/[feature].py`
   - `services/[feature]_service.py`
   - `models/[feature].py`
   - `schemas/[feature].py`

   **For Python/Django:**
   - `[feature]/models.py`
   - `[feature]/views.py`
   - `[feature]/urls.py`
   - `[feature]/serializers.py`
   - `[feature]/admin.py`

4. **Wire Up**:
   - Add imports to main router/app file
   - Register routes in application entry point
   - Add model to database initialization if needed

5. **Generate Tests**:
   - Create test file stub following project test patterns
   - Include basic CRUD test cases if applicable

## Output Format

- List all files created with their paths
- Show key integration points that were modified
- Provide example API calls or usage code

## Enhancements

- Auto-detect ORM (Sequelize, Prisma, SQLAlchemy, TypeORM) and generate appropriate model syntax
- Include OpenAPI/JSDoc comments in generated code
- Add input validation schemas matching existing patterns
- Generate corresponding TypeScript types if project uses TS
