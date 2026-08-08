# TETHER

TETHER is a premium, futuristic, anime-inspired relationship intelligence app built with Flutter.

## Current build

**Phase 3 — Relationship intelligence engine** is now underway on the feature branch:

- Relationship profiles with bond health and XP gauges
- Interaction logging for conversations and calls
- Bond XP automatically increases when interactions are logged
- Health state automatically recalculates from relationship activity
- Last interaction timestamps persist across app restarts
- Cadence-based reminder service for daily, weekly, and occasional relationships
- Dashboard search across names and tags
- Dashboard health filters for thriving, strong, steady, and attention states
- Add/edit relationship flows
- Notes, memories, tags, and important dates in the domain model
- Local persistence through `SharedPreferences`
- Provider/repository boundaries for application state and persistence
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
