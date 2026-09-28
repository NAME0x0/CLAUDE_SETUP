# Third-party notices

Some skills and commands in `claude/` are copies (sometimes lightly edited) of
open-source work. Each one below is MIT-licensed. The full MIT text is at the
end of this file and applies to every entry, with the copyright line shown.

| Path in this repo | Upstream | Copyright |
|---|---|---|
| `claude/skills/{autoplan, benchmark, canary, careful, codex, connect-chrome, cso, design-consultation, design-html, design-review, design-shotgun, document-release, freeze, gstack-upgrade, guard, land-and-deploy, learn, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, qa, retro, setup-browser-cookies, setup-deploy, ship, unfreeze}` | [garrytan/gstack](https://github.com/garrytan/gstack) | Copyright (c) 2026 Garry Tan |
| `claude/skills/design` (merged from taste-skill and redesign-skill) | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | Copyright (c) 2026 Leonxlnx |
| `claude/skills/find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills) | Copyright (c) 2026 Vercel, Inc. |
| `claude/skills/rust-best-practices` | [apollographql/skills](https://github.com/apollographql/skills) | Copyright (c) 2024 Apollo Graph, Inc. |
| `claude/skills/tailwind-design-system`, `claude/skills/llm-evaluation` | [wshobson/agents](https://github.com/wshobson/agents) | Copyright (c) 2024 Seth Hobson |
| `claude/skills/react-spring-physics` | [freshtechbro/claudedesignskills](https://github.com/freshtechbro/claudedesignskills) | Copyright (c) 2025 Claude Skills Project |
| `claude/skills/humanizer` | [blader/humanizer](https://github.com/blader/humanizer) | Copyright (c) 2025 Siqi Chen |
| `claude/skills/shadcn` | [shadcn-ui/ui](https://github.com/shadcn-ui/ui) | Copyright (c) 2023 shadcn |
| `claude/commands/subagent-catalog` | [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | Copyright (c) 2025 VoltAgent |

## Fetched at install time, not redistributed

These upstream repos have no license file, so the installer downloads them
from the author at a pinned commit (see `manifest/remote-skills.json`):

- `logo-generator` from [op7418/logo-generator-skill](https://github.com/op7418/logo-generator-skill)
- `karpathy-guidelines` from [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)

The installer also clones or installs these directly from their sources, under
their own licenses: gstack's runtime (`garrytan/gstack`), every plugin in
`manifest/plugins.json`, the MCP servers in `manifest/mcp.json`, and the
command-line tools in `manifest/tools.json`.

## MIT License

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
