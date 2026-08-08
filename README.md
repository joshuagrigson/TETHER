# TETHER

TETHER is a premium, futuristic, anime-inspired relationship intelligence app built with Flutter.

## Current build

**Phase 2 — Relationship intelligence surface** is now implemented on the feature branch:

- Relationship profiles with bond health and XP gauges
- Interaction timeline model and seeded timeline presentation
- Memories, tags, important dates, and notes in the domain model
- Add-note flow directly from a relationship profile
- Edit relationship flow
- Repository boundary for relationship data
- ChangeNotifier provider for application state
- Dashboard cards now open real relationship profiles
- Flutter CI for analysis and unit tests

## Architecture

- `lib/core` — routing, theme, shared infrastructure
- `lib/models` — immutable domain models
- `lib/repositories` — persistence/data boundaries
- `lib/services` — isolated business logic
- `lib/providers` — application state boundaries
- `lib/screens` — screen composition
- `lib/widgets` — reusable UI components
- `lib/animations` — animation primitives
- `lib/utils` — utilities

## Design direction

Obsidian/midnight surfaces, restrained neon accents, premium futuristic anime influence, high information density without visual clutter, and touch-first Android interaction.
