/**
 * One-time setup: Get a free Puter auth token.
 * Opens your browser for login (free account), then prints the token.
 * Save the token — you only need to do this once.
 *
 * Usage: node get-token.mjs
 */

import { createRequire } from "module";
const require = createRequire(import.meta.url);
const { getAuthToken } = require("@heyputer/puter.js/src/init.cjs");

console.log("Opening browser for Puter login (free account)...\n");

try {
  const token = await getAuthToken();
  console.log("=".repeat(60));
  console.log("Your Puter auth token (save this):\n");
  console.log(token);
  console.log("\n" + "=".repeat(60));
  console.log("\nAdd this to your Claude Code MCP config as PUTER_AUTH_TOKEN");
  console.log("or set it as an environment variable.");
} catch (err) {
  console.error("Failed to get token:", err.message);
  process.exit(1);
}
