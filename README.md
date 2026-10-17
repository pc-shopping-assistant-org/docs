# Project documentation

## AI service

Start at [AI service documentation](04-ai/README.md).

The manual follows **Overview → First steps → Fundamentals → Guides → Reference**.
It describes the current Stateful ReAct V2 architecture; delivery logs are separate.

- [Architecture](02-architecture/ai-architecture.md): components, responsibilities and one chat lifecycle.
- [First steps](04-ai/getting-started.md): local setup and first request.
- [Guides](04-ai/README.md#guides): build, compare, research and extend.
- [Reference](04-ai/README.md#reference): HTTP/tool/data/policy contracts.
- [Delivery](04-ai/README.md#project-delivery): roadmap, evidence and history.

## Ecommerce and project specification

[Deployment](02-architecture/deployment.md): server infrastructure/local development,
GHCR apps profile, external runtime env and release-only SSH delivery.

| Folder | Purpose |
| --- | --- |
| 01-overview | Scope, requirements and glossary |
| 01-business | Business rules, use cases and workflows |
| 02-architecture | System boundaries and architecture decisions |
| 03-data | Database models, constraints and canonical data contracts |
| 05-api | Transport and integration contracts |
| 06-evaluation | Test/evaluation criteria and experiment evidence |
| 07-research / 08-thesis | References and thesis materials |

## Documentation conventions

- One page answers one question; concepts explain, guides teach, references define.
- Use examples/flows before implementation details; link source only when it helps locate a change.
- One rule has one canonical owner; other pages link, not duplicate formulas/contracts.
- Describe implemented behavior and label unsupported/planned features explicitly.
- Keep test counts, issue/slice history and delivery status out of concept pages.
- ADRs retain rationale; roadmap retains gates; status/tracker retain evidence.
- Code/spec conflicts must be recorded, not silently resolved.
- Keep existing public paths where possible; verify local links/anchors after restructuring.
- Source READMEs provide entry points; clone docs beside ai-service for workspace-relative links.
