# TETHER Product North Star

> **TETHER is a relationship intelligence app. People are the product.**

The approved reference design is the source of truth for TETHER's product identity, information hierarchy, interaction model, and visual direction. New screens, features, components, and refactors must reinforce this direction rather than introduce unrelated AI-assistant, productivity, file-management, or generic chatbot concepts.

## Core product promise

**Stronger Bonds. Better You.**

TETHER helps people intentionally maintain the relationships that matter by turning relationship context into timely, actionable intelligence.

## Primary experience hierarchy

1. **Dashboard**
   - Overall relationship health
   - People who need attention today
   - Hero relationship cards
   - Upcoming important dates
   - High-priority next actions

2. **People**
   - Friends, family, and other meaningful relationships
   - Search and filtering
   - Health state
   - Relationship cadence
   - Recency and interaction context

3. **Relationship detail**
   - Person is the hero
   - Relationship health
   - Bond XP / level
   - Interaction history
   - Memories
   - Important dates
   - Notes
   - Next best action
   - One-tap message, call, activity, and note actions

4. **Interaction history**
   - Chronological relationship timeline
   - Interaction type and context
   - XP earned
   - Relationship-health context

5. **Relationship intelligence**
   - WHY this relationship surfaced
   - WHAT signal caused the priority
   - WHAT TETHER recommends
   - ONE-TAP ACTION to act on it

6. **Memory Bank**
   - Personal preferences
   - Interests
   - Life events
   - Shared experiences
   - Context worth remembering

7. **Reminders / planned activities**
   - Cadence-based reminders
   - Important dates
   - Planned relationship activities
   - Follow-up actions

## Hero-card principle

The **person is the hero**, not an AI orb, chatbot, file browser, or generic dashboard metric.

Hero relationship cards should make it immediately obvious:

- Who this person is
- What the relationship is
- How healthy the relationship currently is
- Why TETHER thinks they matter right now
- What action should happen next

## Visual language

- Obsidian / near-black foundation
- Premium high-contrast cards
- Violet / electric-purple as the primary intelligence accent
- Green for healthy relationship signals
- Amber for attention / caution
- Red for at-risk states
- Restrained blue/cyan secondary signals
- Thin luminous rings, subtle glow, and restrained particle/network motifs
- High information density without clutter
- Sophisticated, futuristic, emotionally intelligent—not gadget/sci-fi themed
- People photography and relationship context should remain visually dominant
- Bottom navigation should remain compact and touch-first

## Interaction language

Primary relationship actions should remain immediately accessible:

- Message
- Call
- Plan Activity
- Note
- Add Interaction
- Add Reminder
- Memory Bank

Interactions should feed the relationship model and intelligence engine. Logging meaningful activity should update relationship context, health, and XP where appropriate.

## Intelligence language

Prefer concrete relationship intelligence over generic AI phrasing.

Good:

- `14 days since contact`
- `Birthday in 3 days`
- `Bond health is declining`
- `You usually connect weekly`
- `Send a birthday message or plan something special`

Bad:

- `Your AI companion is thinking...`
- `Ask TETHER anything`
- `AI assistant dashboard`
- Generic productivity recommendations unrelated to relationships

## Architecture constraint

Relationship intelligence must remain separate from persisted relationship metadata.

Do **not** use `Person.tags` as a presentation-layer transport for priority intelligence. Use dedicated intelligence/presentation models such as `RelationshipPriority` and keep domain data clean.

## North-star test

Before shipping a new feature, ask:

> **Does this help the user understand, nurture, remember, or act on an important relationship?**

If the answer is no, the feature does not belong in the core TETHER experience without a strong product justification.
