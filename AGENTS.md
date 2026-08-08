# TETHER Agent Instructions

## Architecture
- Flutter + Dart, Android-first.
- Keep UI, state, domain logic, and persistence boundaries separate.
- Prefer small immutable domain models and isolated services.
- Keep configurable relationship logic in services rather than widgets.

## Design
- Premium, futuristic, anime-inspired, emotionally intelligent.
- Obsidian/midnight foundation with restrained neon accents.
- Use centralized tokens from `lib/core/theme`.
- Avoid generic Material 3 styling, excessive blur, particles, and gratuitous animation.
- Preserve readable typography, touch targets, and Android performance.

## Engineering
- Keep files focused and avoid monolithic widgets.
- Business logic belongs in services/models, not presentation widgets.
- Add tests when relationship calculations, XP, cadence, or health-state rules change.

## Roadmap
- Phase 2: profile, relationship timeline, add/edit flows, notes/memories, search, local persistence.
- Phase 3: notifications and reminder orchestration through the persistence boundary.
- Phase 4: real AI integrations; never fabricate AI responses in place of an integration.
