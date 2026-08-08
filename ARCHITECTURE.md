# TETHER Architecture

TETHER uses a layered Flutter architecture designed to keep the interface premium while keeping business rules testable.

```text
lib/
  core/        shared infrastructure and design system
  models/      domain entities and enums
  services/    business rules and isolated calculations
  providers/   future application state boundaries
  repositories/ future persistence boundaries
  screens/     screen-level composition
  widgets/     reusable presentation components
  animations/  reusable motion primitives
  utils/       small cross-cutting utilities
```

The dashboard currently uses seeded data intentionally. Persistence and state management are deferred to Phase 2 so the foundation does not create a premature storage abstraction.
