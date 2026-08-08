# Laravel Application Guidance

## Shared context

- This is a Laravel application running on PHP 8.3. Before using a package API, confirm its installed major version with `composer show --direct`, `composer show <vendor/package>`, or `package.json` for JavaScript packages.
- Follow existing code conventions and reuse established components or abstractions before adding new ones.
- Do not add dependencies or new top-level application directories without approval.
- Do not create verification scripts or use Tinker when existing tests prove the behavior.
- Keep documentation changes limited to explicitly requested documentation work.
- Keep replies concise and focused on the work completed.

## Scoped guidance

Read the `CLAUDE.md` file in the directory you are changing. It contains instructions that apply only to that area:

- `app/` — Laravel and PHP application code
- `routes/` — routes, middleware, and API conventions
- `database/` — migrations, factories, and seeders
- `tests/` — PHPUnit testing and verification
- `resources/` — frontend and Vite work

## Skills

Project skills live in `.claude/skills/`. Invoke the relevant skill for its domain:

- `laravel-best-practices` for Laravel PHP implementation or review
- `tailwindcss-development` for Tailwind or UI component work
- `infer-conventions` when documenting or standardizing project conventions

## Project rules

When `.ai/rules` exists, before planning or editing a file:

1. Read `.ai/rules/index.md` and every rule whose glob covers the path in scope.
2. Search `.ai/rules` for relevant keywords.
3. Record durable, project-specific decisions with `record-rule`; do not rely on session memory.

## Laravel Boost

- Prefer Laravel Boost tools when they are available.
- Use `search-docs` before code changes that depend on Laravel or package APIs; use broad, topic-based queries and scope packages when known.
- Use `database-query` for read-only database queries and `database-schema` before database changes.
- Use `get-absolute-url` before sharing an application URL.
- Use `browser-logs` only for recent browser errors.
