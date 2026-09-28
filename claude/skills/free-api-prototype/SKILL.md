---
name: free-api-prototype
description: Discovers and integrates free/public APIs for rapid feature prototyping
triggers:
  - /free-api-prototype
  - /find-api
  - /public-api
---

# Instructions

When this skill is invoked, search for free APIs matching the user's requirements and generate integration code.

## Process

1. **Understand Requirements**:
   - What data/functionality is needed?
   - Rate limit tolerance (requests/minute)
   - Authentication preference (none, API key, OAuth)
   - Response format preference (JSON, XML)

2. **Search for APIs**:

   Use WebSearch to find APIs from trusted sources:
   - https://github.com/public-apis/public-apis
   - https://rapidapi.com (free tier)
   - https://any-api.com
   - Direct documentation sites

   **Evaluate Options**:
   - Free tier limits
   - Authentication requirements
   - Documentation quality
   - Response reliability
   - CORS support (for frontend)

3. **Test API Viability**:
   ```bash
   # Test endpoint accessibility
   curl -s "https://api.example.com/endpoint" | head -c 500
   ```

4. **Generate Integration Code**:

   **Create API Client**:
   ```python
   # Example Python
   class ExampleAPIClient:
       BASE_URL = "https://api.example.com/v1"

       def __init__(self, api_key: str = None):
           self.api_key = api_key or os.getenv("EXAMPLE_API_KEY")
           self.session = requests.Session()

       def get_resource(self, resource_id: str) -> dict:
           """Fetch a resource by ID."""
           response = self.session.get(
               f"{self.BASE_URL}/resources/{resource_id}",
               headers={"Authorization": f"Bearer {self.api_key}"}
           )
           response.raise_for_status()
           return response.json()
   ```

5. **Add Error Handling**:
   - Rate limit handling with exponential backoff
   - Timeout configuration
   - Response validation
   - Fallback strategies

6. **Document Usage**:
   - Environment variable setup
   - Example usage code
   - Rate limit considerations
   - API reference links

## Output Format

```markdown
## API Recommendation: [API Name]

**URL**: https://api.example.com
**Auth**: API Key (free tier: 1000 req/day)
**Docs**: [link]

### Why This API
- [Reason 1]
- [Reason 2]

### Setup
1. Sign up at [url]
2. Get API key from dashboard
3. Add to .env: `EXAMPLE_API_KEY=your_key`

### Integration Code
[Generated client code]

### Example Usage
[Code examples]

### Alternatives Considered
| API | Free Tier | Pros | Cons |
|-----|-----------|------|------|
| [API 2] | X req/day | ... | ... |
```

## Enhancements

- Cache API responses to reduce rate limit usage
- Generate TypeScript types from JSON responses
- Create mock server for offline development
- Add request/response logging for debugging
- Generate OpenAPI spec from discovered API
- Suggest combining multiple APIs for richer data
