---
name: performance-profiler
description: Identifies execution bottlenecks through timing analysis and optimization suggestions
triggers:
  - /performance-profiler
  - /profile
  - /perf
---

# Instructions

When this skill is invoked, analyze code for performance bottlenecks and suggest optimizations.

## Process

1. **Identify Performance-Critical Code**:
   - Read target file or module
   - Identify loops, recursive functions, I/O operations
   - Find database queries and API calls
   - Locate data transformations on large datasets

2. **Static Analysis**:

   **Common Bottleneck Patterns**:
   - N+1 query problems (loop with DB call inside)
   - Unnecessary iterations (could use early returns)
   - Repeated calculations (missing memoization)
   - Synchronous operations that could be parallel
   - Large object copying instead of references
   - String concatenation in loops
   - Unindexed database queries

3. **Suggest Instrumentation**:

   **JavaScript/TypeScript**:
   ```typescript
   function withTiming<T>(name: string, fn: () => T): T {
     const start = performance.now();
     try {
       return fn();
     } finally {
       console.log(`${name}: ${(performance.now() - start).toFixed(2)}ms`);
     }
   }
   ```

   **Python**:
   ```python
   import time
   from functools import wraps

   def profile(func):
       @wraps(func)
       def wrapper(*args, **kwargs):
           start = time.perf_counter()
           result = func(*args, **kwargs)
           elapsed = (time.perf_counter() - start) * 1000
           print(f"{func.__name__}: {elapsed:.2f}ms")
           return result
       return wrapper
   ```

4. **Analyze Complexity**:
   - Calculate Big O for identified functions
   - Flag O(n²) or worse algorithms
   - Identify unnecessary complexity

5. **Generate Optimizations**:

   For each bottleneck, provide:
   - Current code
   - Optimized version
   - Expected improvement
   - Trade-offs

## Output Format

```markdown
## Performance Analysis

**File**: path/to/file.js
**Functions Analyzed**: 12

### Bottlenecks Found

#### 1. N+1 Query in `getUserOrders()` [High Impact]

**Location**: line 45-52
**Issue**: Database query inside loop
**Complexity**: O(n) queries → O(1) with fix

**Current**:
```javascript
for (const user of users) {
  user.orders = await db.orders.find({ userId: user.id });
}
```

**Optimized**:
```javascript
const userIds = users.map(u => u.id);
const orders = await db.orders.find({ userId: { $in: userIds } });
const ordersByUser = groupBy(orders, 'userId');
users.forEach(u => u.orders = ordersByUser[u.id] || []);
```

**Expected Improvement**: ~90% reduction in DB calls

---

#### 2. Missing Memoization in `fibonacci()` [Medium Impact]
[Similar breakdown]

### Quick Wins
- [ ] Add index on `orders.userId`
- [ ] Enable query caching
- [ ] Use connection pooling

### Profiling Commands
```bash
# Node.js
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# Python
python -m cProfile -s cumtime script.py
```
```

## Enhancements

- Generate flame graph visualization data
- Compare before/after benchmarks
- Identify memory leaks patterns
- Suggest caching strategies (Redis, in-memory)
- Analyze bundle size for frontend code
- Detect render performance issues (React, Vue)
- Profile database query execution plans
