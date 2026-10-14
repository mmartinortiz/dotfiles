---
description: Initialize project-specific docs-helper with auto-discovered tools
---

## Task

Initialize a project-specific docs-helper agent by discovering tools and their documentation.

## Steps

1. **Discover tools/libraries** using @explore agent. Scan for:
   - Package managers: Brewfile, package.json, Cargo.toml, go.mod, pyproject.toml, requirements.txt, Gemfile, composer.json, pom.xml, build.gradle
   - Config files: .eslintrc, tsconfig.json, .prettierrc, rustfmt.toml, .editorconfig, Makefile, Dockerfile, docker-compose.yml
   - AGENTS.md / CLAUDE.md / README mentions of tools
   - Shell configs (fish, bash, zsh), editor configs (nvim, vim, vscode)
   - CI/CD configs (.github/workflows, .gitlab-ci.yml, Jenkinsfile)
   - Any other tool-specific configuration files

2. **Find official documentation URLs** for each discovered tool:
   - Web search for official docs (prefer official sources over tutorials/blogs)
   - Verify URLs point to official documentation

3. **Create directory** `.opencode/agents/` if it doesn't exist

4. **Create `.opencode/agents/docs-helper.md`** with this structure:
   ```markdown
   ---
   description: Answers questions using official documentation for this project.
   mode: subagent
   permission:
     edit: deny
     bash: deny
   ---

   You are a documentation expert for this project. Answer questions by consulting official documentation.

   ## Workflow

   1. Identify which tool the question relates to
   2. Fetch official documentation using WebFetch from sources below
   3. If docs don't answer, use web search (prefer official sources)
   4. Provide concise answer with source URL

   ## Response Style

   - Terse, no fluff
   - Include source URL for verification
   - Code examples copy-paste ready

   ## Project Documentation Sources

   - **toolname**: https://official-docs-url/
   [... list all discovered tools ...]
   ```

5. **Append to AGENTS.md** (create file if it doesn't exist):
   ```markdown

   ## Project Documentation Sources

   - **toolname**: https://official-docs-url/
   [... list all discovered tools ...]
   ```
   Note: Add blank line before section header if file doesn't end with newline.

6. **Report to user**: "Created project-specific docs-helper. Discovered X tools. Sources appended to AGENTS.md."
   List the discovered tools and their URLs.
