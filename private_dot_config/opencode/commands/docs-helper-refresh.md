---
description: Re-discover tools and update project documentation sources
---

## Task

Refresh the project-specific docs-helper by re-discovering tools and updating documentation sources.

## Steps

1. **Re-discover tools/libraries** using @explore agent. Scan for:
   - Package managers: Brewfile, package.json, Cargo.toml, go.mod, pyproject.toml, requirements.txt, Gemfile, composer.json, pom.xml, build.gradle
   - Config files: .eslintrc, tsconfig.json, .prettierrc, rustfmt.toml, .editorconfig, Makefile, Dockerfile, docker-compose.yml
   - AGENTS.md / CLAUDE.md / README mentions of tools
   - Shell configs (fish, bash, zsh), editor configs (nvim, vim, vscode)
   - CI/CD configs (.github/workflows, .gitlab-ci.yml, Jenkinsfile)
   - Any other tool-specific configuration files

2. **Find official documentation URLs** for each discovered tool:
   - Web search for official docs (prefer official sources over tutorials/blogs)
   - Verify URLs point to official documentation

3. **Read existing AGENTS.md** to compare with previous sources

4. **Update AGENTS.md**:
   - Find and replace the "## Project Documentation Sources" section
   - If section doesn't exist, append it
   - Preserve all other AGENTS.md content exactly as-is
   - Format:
     ```markdown

     ## Project Documentation Sources

     - **toolname**: https://official-docs-url/
     ```

5. **Update `.opencode/agents/docs-helper.md`**:
   - Replace the "## Project Documentation Sources" section with new list
   - Keep all other content intact

6. **Report to user**: "Refreshed docs-helper. Found X tools (Y new, Z removed)."
   - List newly added tools
   - List removed tools
   - List unchanged tools
