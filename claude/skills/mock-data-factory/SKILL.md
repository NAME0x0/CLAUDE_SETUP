---
name: mock-data-factory
description: Generates realistic seed data and test fixtures based on project schemas
triggers:
  - /mock-data-factory
  - /seed-data
  - /fixtures
---

# Instructions

When this skill is invoked, analyze schemas and generate realistic mock data for testing and development.

## Process

1. **Analyze Data Models**:
   - Read Prisma schema, TypeORM entities, SQLAlchemy models
   - Extract field types, constraints, relationships
   - Identify required vs optional fields
   - Note unique constraints and foreign keys

2. **Determine Data Requirements**:
   - Volume needed (10, 100, 1000+ records)
   - Relationship consistency requirements
   - Edge cases to include
   - Locale/language requirements

3. **Generate Factory Functions**:

   **TypeScript (with Faker.js)**:
   ```typescript
   // src/test/factories/user.factory.ts
   import { faker } from '@faker-js/faker';
   import { User } from '@prisma/client';

   type UserOverrides = Partial<Omit<User, 'id' | 'createdAt'>>;

   export const createUser = (overrides: UserOverrides = {}): Omit<User, 'id'> => ({
     email: faker.internet.email(),
     name: faker.person.fullName(),
     avatar: faker.image.avatar(),
     role: 'USER',
     isVerified: faker.datatype.boolean(),
     createdAt: faker.date.past(),
     updatedAt: new Date(),
     ...overrides,
   });

   export const createUsers = (count: number, overrides: UserOverrides = {}) =>
     Array.from({ length: count }, () => createUser(overrides));

   // With relationships
   export const createUserWithPosts = (postCount: number = 3) => {
     const user = createUser();
     const posts = Array.from({ length: postCount }, () =>
       createPost({ authorEmail: user.email })
     );
     return { user, posts };
   };
   ```

   **Python (with Faker)**:
   ```python
   # tests/factories.py
   from faker import Faker
   from datetime import datetime
   from typing import Optional
   from dataclasses import dataclass, field

   fake = Faker()

   @dataclass
   class UserFactory:
       email: str = field(default_factory=fake.email)
       name: str = field(default_factory=fake.name)
       avatar: str = field(default_factory=fake.image_url)
       role: str = "USER"
       is_verified: bool = field(default_factory=fake.boolean)
       created_at: datetime = field(default_factory=datetime.now)

       @classmethod
       def create(cls, **overrides):
           return cls(**{**cls.__dict__, **overrides})

       @classmethod
       def create_batch(cls, count: int, **overrides):
           return [cls.create(**overrides) for _ in range(count)]
   ```

4. **Generate Seed Scripts**:

   **Prisma Seed**:
   ```typescript
   // prisma/seed.ts
   import { PrismaClient } from '@prisma/client';
   import { createUsers, createPosts, createComments } from '../src/test/factories';

   const prisma = new PrismaClient();

   async function main() {
     console.log('Seeding database...');

     // Clear existing data (dev only!)
     await prisma.comment.deleteMany();
     await prisma.post.deleteMany();
     await prisma.user.deleteMany();

     // Create users
     const users = await Promise.all(
       createUsers(10).map(user => prisma.user.create({ data: user }))
     );
     console.log(`Created ${users.length} users`);

     // Create posts for each user
     for (const user of users) {
       const posts = createPosts(faker.number.int({ min: 1, max: 5 }), {
         authorId: user.id,
       });
       await Promise.all(posts.map(post => prisma.post.create({ data: post })));
     }
     console.log('Created posts');

     // Create comments
     const allPosts = await prisma.post.findMany();
     for (const post of allPosts) {
       const comments = createComments(faker.number.int({ min: 0, max: 10 }), {
         postId: post.id,
         authorId: faker.helpers.arrayElement(users).id,
       });
       await Promise.all(
         comments.map(comment => prisma.comment.create({ data: comment }))
       );
     }
     console.log('Created comments');

     console.log('Seeding complete!');
   }

   main()
     .catch(console.error)
     .finally(() => prisma.$disconnect());
   ```

5. **Generate JSON Fixtures**:
   ```json
   {
     "users": [
       {
         "id": "user_1",
         "email": "john.doe@example.com",
         "name": "John Doe",
         "role": "ADMIN"
       },
       {
         "id": "user_2",
         "email": "jane.smith@example.com",
         "name": "Jane Smith",
         "role": "USER"
       }
     ],
     "posts": [
       {
         "id": "post_1",
         "title": "Getting Started with TypeScript",
         "authorId": "user_1",
         "publishedAt": "2024-01-15T10:00:00Z"
       }
     ]
   }
   ```

## Output Format

```markdown
## Mock Data Generated

### Factory Files
- `src/test/factories/user.factory.ts`
- `src/test/factories/post.factory.ts`
- `src/test/factories/comment.factory.ts`
- `src/test/factories/index.ts`

### Seed Script
- `prisma/seed.ts`

### Usage
```typescript
// In tests
const user = createUser({ role: 'ADMIN' });
const users = createUsers(10);
const { user, posts } = createUserWithPosts(5);
```

### Run Seed
```bash
npx prisma db seed
```

### Edge Cases Included
- Empty strings, null values where allowed
- Boundary dates (far past, far future)
- Special characters in text fields
- Maximum length strings
```

## Enhancements

- Generate locale-specific data (names, addresses)
- Create scenario-based fixtures (new user, power user, etc.)
- Add data anonymization for production snapshots
- Generate GraphQL/REST mocking servers
- Create Cypress/Playwright test fixtures
- Support incremental seeding (don't duplicate)
- Generate realistic time-series data
