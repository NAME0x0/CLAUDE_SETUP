import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
const { init } = require("@heyputer/puter.js/src/init.cjs");

const token = process.env.PUTER_AUTH_TOKEN;
if (!token) {
  process.stderr.write(
    "ERROR: PUTER_AUTH_TOKEN not set. Run 'npm run get-token' to get one (free).\n"
  );
  process.exit(1);
}

const puter = init(token);

const server = new McpServer({
  name: "free-search",
  version: "1.0.1",
});

// Puter's ai.chat response shape has varied across versions (string, {message:{content}},
// {text}, or content as an array of blocks) — extract text defensively.
function extractText(response) {
  if (response?.error)
    throw new Error(
      typeof response.error === "string" ? response.error : JSON.stringify(response.error)
    );
  if (typeof response === "string") return response;
  const msg = response?.message ?? response;
  const c = msg?.content ?? msg?.text ?? response?.text;
  if (typeof c === "string") return c;
  if (Array.isArray(c))
    return c
      .map((p) => (typeof p === "string" ? p : p?.text ?? ""))
      .filter(Boolean)
      .join("\n");
  return JSON.stringify(response);
}

server.tool(
  "search",
  "Search the web using Perplexity Sonar. Returns comprehensive answers with citations.",
  {
    query: z.string().describe("The search query or question"),
  },
  async ({ query }) => {
    try {
      const response = await puter.ai.chat(query, {
        model: "perplexity/sonar",
      });
      return {
        content: [{ type: "text", text: extractText(response) }],
      };
    } catch (error) {
      return {
        content: [
          { type: "text", text: `Search failed: ${error.message}` },
        ],
        isError: true,
      };
    }
  }
);

server.tool(
  "research",
  "Deep research using Perplexity Sonar Pro. Use for complex topics needing thorough analysis with sources.",
  {
    query: z.string().describe("The research question or topic"),
  },
  async ({ query }) => {
    try {
      const response = await puter.ai.chat(query, {
        model: "perplexity/sonar-pro",
      });
      return {
        content: [{ type: "text", text: extractText(response) }],
      };
    } catch (error) {
      return {
        content: [
          { type: "text", text: `Research failed: ${error.message}` },
        ],
        isError: true,
      };
    }
  }
);

server.tool(
  "deep_research",
  "Perplexity Deep Research for exhaustive investigation of a topic. Slower but much more thorough.",
  {
    query: z.string().describe("The topic to deeply research"),
  },
  async ({ query }) => {
    try {
      const response = await puter.ai.chat(query, {
        model: "perplexity/sonar-deep-research",
      });
      return {
        content: [{ type: "text", text: extractText(response) }],
      };
    } catch (error) {
      return {
        content: [
          { type: "text", text: `Deep research failed: ${error.message}` },
        ],
        isError: true,
      };
    }
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
