---
name: database-migrator
description: Compares models to database state and generates migration scripts
triggers:
  - /database-migrator
  - /migrate
  - /db-migrate
---

# Instructions

When this skill is invoked, analyze model definitions and generate database migration scripts.

## Process

1. **Detect ORM/Migration System**:
   - Prisma: `prisma/schema.prisma`
   - TypeORM: `**/entities/**/*.ts`
   - Sequelize: `**/models/**/*.js`
   - SQLAlchemy/Alembic: `**/models/**/*.py`, `alembic/`
   - Django: `**/models.py`
   - Knex: `knexfile.js`
   - Go/GORM: `**/models/**/*.go`
   - Rails/ActiveRecord: `db/migrate/`, `app/models/`

2. **Analyze Current Models**:
   - Read all model/entity definitions
   - Extract table names, columns, types
   - Identify relationships (FK, M2M)
   - Note indexes and constraints

3. **Compare with Database State** (if possible):
   ```bash
   # Prisma
   npx prisma migrate diff

   # Alembic
   alembic revision --autogenerate

   # Django
   python manage.py makemigrations --dry-run
   ```

4. **Generate Migration Script**:

   **Prisma**:
   ```prisma
   model User {
     id        String   @id @default(cuid())
     email     String   @unique
     name      String?
     posts     Post[]
     createdAt DateTime @default(now())
   }
   ```

   **SQL (generic)**:
   ```sql
   -- Migration: add_user_profile_fields
   -- Created: 2024-01-15

   ALTER TABLE users
   ADD COLUMN phone VARCHAR(20),
   ADD COLUMN avatar_url TEXT,
   ADD COLUMN settings JSONB DEFAULT '{}';

   CREATE INDEX idx_users_phone ON users(phone);

   -- Rollback
   -- ALTER TABLE users
   -- DROP COLUMN phone,
   -- DROP COLUMN avatar_url,
   -- DROP COLUMN settings;
   ```

   **TypeORM**:
   ```typescript
   import { MigrationInterface, QueryRunner } from "typeorm";

   export class AddUserProfileFields1705312345678
     implements MigrationInterface {

     public async up(queryRunner: QueryRunner): Promise<void> {
       await queryRunner.query(`
         ALTER TABLE "users"
         ADD COLUMN "phone" VARCHAR(20),
         ADD COLUMN "avatar_url" TEXT
       `);
     }

     public async down(queryRunner: QueryRunner): Promise<void> {
       await queryRunner.query(`
         ALTER TABLE "users"
         DROP COLUMN "phone",
         DROP COLUMN "avatar_url"
       `);
     }
   }
   ```

5. **Safety Checks**:
   - Warn about destructive operations (DROP, DELETE)
   - Check for data loss scenarios
   - Suggest data migration for column type changes
   - Verify foreign key constraints

## Output Format

```markdown
## Migration Analysis

**ORM**: Prisma
**Changes Detected**: 5

### Schema Changes

| Table | Change | Column | Type | Breaking |
|-------|--------|--------|------|----------|
| users | ADD | phone | String? | No |
| users | ADD | avatarUrl | String? | No |
| posts | MODIFY | content | Text→LongText | No |
| orders | DROP | legacyId | Int | ⚠️ Yes |

### Generated Migration

[Migration code]

### Safety Warnings

⚠️ **Dropping column `orders.legacyId`**
- Contains data in 1,234 rows
- Suggestion: Backup data or add soft-delete first

### Commands

```bash
# Preview
npx prisma migrate dev --create-only

# Apply
npx prisma migrate dev

# Rollback (if supported)
npx prisma migrate reset
```
```

## Enhancements

- Generate seed data migration for new tables
- Detect circular dependencies in relationships
- Suggest indexes based on common query patterns
- Check for production-safe migrations (no locks on large tables)
- Generate rollback scripts automatically
- Validate foreign key constraints
- Estimate migration execution time for large tables
