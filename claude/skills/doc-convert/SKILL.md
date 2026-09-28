---
name: doc-convert
description: Convert documents (PDF, DOCX, PPTX) into clean, properly structured Markdown — real heading hierarchy, GFM tables, lists — not a text dump. Use when asked to "make an md from this pdf", "convert this document to markdown", or restructure a document file.
---

# Doc Convert

The output must read like it was authored in Markdown, not extracted into it.

## Procedure

1. **Read the source.** PDFs: Read tool with `pages` (20-page chunks). DOCX: `pandoc -f docx -t gfm` if available, else python-docx. PPTX: python-pptx, slide per section. Never `cat` a binary.
2. **Map structure before writing** — outline the document's heading hierarchy first (title → H1s → H2s). Preserve the source's hierarchy; don't invent one.
3. **Convert with fidelity rules:**
   - Tables → GFM tables (wide tables: keep columns, note truncation if unavoidable).
   - Numbered/bulleted lists → native Markdown lists, nesting preserved.
   - Figures/images → `![caption](placeholder)` with the caption text; note count of images not extracted.
   - Bold/emphasis in headings and key terms preserved; decorative formatting dropped.
4. **Verify nothing dropped** — compare section count and approximate word count against the source; spot-check the last section (truncation hides at the end). State the check result.
5. **Deliver** — write `<source-name>.md` next to the source unless told otherwise; SendUserFile it.

## Failure modes to avoid

- Wall-of-text dump with no headings (structure is the deliverable).
- Silently skipping tables or the final pages of long PDFs.
- Rewriting/summarizing content — this is conversion, not editing, unless asked.
