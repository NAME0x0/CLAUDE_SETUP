---
name: schema-visualiser
description: Generates Mermaid.js diagrams for database schemas and system architecture
triggers:
  - /schema-visualiser
  - /visualize
  - /diagram
---

# Instructions

When this skill is invoked, analyze code/schemas and generate visual diagrams.

## Process

1. **Determine Diagram Type Needed**:
   - **ERD**: Database/model relationships
   - **Class Diagram**: OOP class structures
   - **Sequence**: API/service interactions
   - **Flowchart**: Business logic flows
   - **Architecture**: System component overview

2. **Analyze Source Material**:

   **For ERD**:
   - Read Prisma schema, TypeORM entities, SQLAlchemy models
   - Extract tables, columns, types, relationships
   - Identify primary/foreign keys

   **For Architecture**:
   - Scan for service definitions
   - Identify external integrations
   - Map API boundaries
   - Find message queues, caches, databases

3. **Generate Mermaid Diagrams**:

   **Entity Relationship Diagram**:
   ```mermaid
   erDiagram
       USER ||--o{ POST : writes
       USER ||--o{ COMMENT : writes
       POST ||--o{ COMMENT : has
       POST }o--|| CATEGORY : belongs_to

       USER {
           string id PK
           string email UK
           string name
           datetime createdAt
       }

       POST {
           string id PK
           string title
           text content
           string authorId FK
           string categoryId FK
           datetime publishedAt
       }

       COMMENT {
           string id PK
           text content
           string authorId FK
           string postId FK
       }

       CATEGORY {
           string id PK
           string name UK
           string slug UK
       }
   ```

   **System Architecture**:
   ```mermaid
   graph TB
       subgraph Client
           Web[Web App]
           Mobile[Mobile App]
       end

       subgraph API Gateway
           LB[Load Balancer]
           Auth[Auth Service]
       end

       subgraph Services
           UserSvc[User Service]
           OrderSvc[Order Service]
           PaymentSvc[Payment Service]
       end

       subgraph Data
           PG[(PostgreSQL)]
           Redis[(Redis Cache)]
           S3[S3 Storage]
       end

       subgraph External
           Stripe[Stripe API]
           SendGrid[SendGrid]
       end

       Web --> LB
       Mobile --> LB
       LB --> Auth
       Auth --> UserSvc
       Auth --> OrderSvc
       Auth --> PaymentSvc

       UserSvc --> PG
       UserSvc --> Redis
       OrderSvc --> PG
       PaymentSvc --> Stripe

       UserSvc --> SendGrid
       OrderSvc --> S3
   ```

   **Sequence Diagram**:
   ```mermaid
   sequenceDiagram
       participant C as Client
       participant A as API Gateway
       participant U as User Service
       participant D as Database
       participant R as Redis

       C->>A: POST /login
       A->>U: Validate credentials
       U->>D: Query user
       D-->>U: User data
       U->>U: Verify password
       U->>R: Store session
       U-->>A: JWT token
       A-->>C: 200 OK + token
   ```

   **Class Diagram**:
   ```mermaid
   classDiagram
       class User {
           +String id
           +String email
           +String name
           +createPost(title, content)
           +updateProfile(data)
       }

       class Post {
           +String id
           +String title
           +String content
           +publish()
           +addComment(comment)
       }

       class Comment {
           +String id
           +String content
           +User author
       }

       User "1" --> "*" Post : writes
       Post "1" --> "*" Comment : has
       User "1" --> "*" Comment : writes
   ```

4. **Output Options**:
   - Embed in Markdown files
   - Generate SVG/PNG using mermaid-cli
   - Create HTML preview file

## Output Format

```markdown
## Generated Diagrams

### Database Schema (ERD)
[Mermaid code block]

**Tables**: 8 | **Relationships**: 12

### System Architecture
[Mermaid code block]

**Services**: 5 | **Databases**: 2 | **External APIs**: 3

### Render Commands
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Generate PNG
mmdc -i diagram.md -o diagram.png

# Generate SVG
mmdc -i diagram.md -o diagram.svg -b transparent
```

### Integration
Add to README.md or docs/ for automatic rendering on GitHub.
```

## Enhancements

- Generate C4 model diagrams for architecture
- Create data flow diagrams for GDPR compliance
- Add interactive HTML viewers
- Generate PlantUML as alternative
- Include cardinality and constraints in ERD
- Auto-update diagrams on schema changes
- Create API dependency graphs
