---
name: logging-scaffolder
description: Injects structured JSON logging and consistent error handling throughout codebase
triggers:
  - /logging-scaffolder
  - /logging
  - /add-logging
---

# Instructions

When this skill is invoked, set up professional structured logging with consistent error handling.

## Process

1. **Detect Existing Logging**:
   - Check for logging libraries (winston, pino, bunyan, loguru, zerolog)
   - Find `console.log`, `print`, `fmt.Println` statements
   - Identify existing logging patterns

2. **Recommend Logging Library**:

   | Language | Recommended | Alternative |
   |----------|-------------|-------------|
   | Node.js | pino | winston |
   | Python | structlog | loguru |
   | Go | zerolog | zap |
   | Rust | tracing | log + env_logger |
   | Java | SLF4J + Logback | Log4j2 |

3. **Generate Logger Configuration**:

   **Node.js (pino)**:
   ```typescript
   // src/lib/logger.ts
   import pino from 'pino';

   export const logger = pino({
     level: process.env.LOG_LEVEL || 'info',
     transport: process.env.NODE_ENV === 'development'
       ? { target: 'pino-pretty', options: { colorize: true } }
       : undefined,
     base: {
       service: 'my-service',
       version: process.env.npm_package_version,
     },
     redact: ['req.headers.authorization', 'password', 'token'],
   });

   // Child logger for specific modules
   export const createLogger = (module: string) =>
     logger.child({ module });
   ```

   **Python (structlog)**:
   ```python
   # src/lib/logger.py
   import structlog
   import logging

   structlog.configure(
       processors=[
           structlog.contextvars.merge_contextvars,
           structlog.processors.add_log_level,
           structlog.processors.TimeStamper(fmt="iso"),
           structlog.processors.StackInfoRenderer(),
           structlog.processors.format_exc_info,
           structlog.processors.JSONRenderer()
           if os.getenv("ENV") == "production"
           else structlog.dev.ConsoleRenderer(),
       ],
       wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
       context_class=dict,
       logger_factory=structlog.PrintLoggerFactory(),
   )

   def get_logger(name: str):
       return structlog.get_logger(name)
   ```

4. **Generate Error Handling Utilities**:

   ```typescript
   // src/lib/errors.ts
   export class AppError extends Error {
     constructor(
       message: string,
       public code: string,
       public statusCode: number = 500,
       public isOperational: boolean = true,
       public context?: Record<string, unknown>
     ) {
       super(message);
       this.name = this.constructor.name;
       Error.captureStackTrace(this, this.constructor);
     }
   }

   export class NotFoundError extends AppError {
     constructor(resource: string, id: string) {
       super(`${resource} not found: ${id}`, 'NOT_FOUND', 404);
     }
   }

   export class ValidationError extends AppError {
     constructor(message: string, context?: Record<string, unknown>) {
       super(message, 'VALIDATION_ERROR', 400, true, context);
     }
   }

   // Global error handler
   export const errorHandler = (err: Error, req: Request, res: Response) => {
     const logger = createLogger('error-handler');

     if (err instanceof AppError) {
       logger.warn({ err, context: err.context }, err.message);
       return res.status(err.statusCode).json({
         error: { code: err.code, message: err.message }
       });
     }

     logger.error({ err }, 'Unhandled error');
     return res.status(500).json({
       error: { code: 'INTERNAL_ERROR', message: 'Internal server error' }
     });
   };
   ```

5. **Add Request Logging Middleware**:

   ```typescript
   // src/middleware/requestLogger.ts
   import { randomUUID } from 'crypto';

   export const requestLogger = (req, res, next) => {
     const requestId = req.headers['x-request-id'] || randomUUID();
     const startTime = Date.now();

     req.log = logger.child({ requestId });
     res.setHeader('x-request-id', requestId);

     req.log.info({
       method: req.method,
       url: req.url,
       userAgent: req.headers['user-agent'],
     }, 'Request started');

     res.on('finish', () => {
       req.log.info({
         method: req.method,
         url: req.url,
         statusCode: res.statusCode,
         duration: Date.now() - startTime,
       }, 'Request completed');
     });

     next();
   };
   ```

## Output Format

```markdown
## Logging Setup Complete

### Files Created
- `src/lib/logger.ts` - Logger configuration
- `src/lib/errors.ts` - Error classes and handler
- `src/middleware/requestLogger.ts` - HTTP request logging

### Integration Points

Add to your main app:
```typescript
import { logger } from './lib/logger';
import { requestLogger } from './middleware/requestLogger';
import { errorHandler } from './lib/errors';

app.use(requestLogger);
// ... routes ...
app.use(errorHandler);
```

### Log Levels
- `error`: System errors, exceptions
- `warn`: Handled errors, deprecations
- `info`: Request lifecycle, business events
- `debug`: Detailed debugging info

### Environment Variables
- `LOG_LEVEL`: Minimum log level (default: info)
- `LOG_FORMAT`: json | pretty (default: json in prod)
```

## Enhancements

- Add correlation ID propagation across services
- Generate log aggregation config (ELK, Datadog, CloudWatch)
- Create alert rules for error rate thresholds
- Add performance timing helpers
- Generate log rotation configuration
- Include APM integration (OpenTelemetry)
- Create log-based metrics extraction
