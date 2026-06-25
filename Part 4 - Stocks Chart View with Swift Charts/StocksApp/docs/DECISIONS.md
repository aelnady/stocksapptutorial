# Decisions

Use this file to record important product and engineering decisions.

## Template

### Date

YYYY-MM-DD

### Decision

Short statement of the decision.

### Context

What problem or opportunity led to the decision?

### Options Considered

- Option A
- Option B
- Option C

### Rationale

Why this option was chosen.

### Consequences

- What this enables.
- What tradeoffs it creates.
- What should be revisited later.

## Log

### Date

2026-06-25

### Decision

Keep external stock, AI, news, sentiment, and persistence dependencies behind service protocols.

### Context

The current app already uses `StocksAPI` and `TickerListRepository`, which keeps view models testable and previews mockable.

### Options Considered

- Call external APIs directly from SwiftUI views.
- Construct concrete API clients directly inside each view model.
- Use protocol-based services and inject dependencies.

### Rationale

Protocol-based services match the existing project style, support mock services, and keep future AI and backend integrations isolated.

### Consequences

- New features should start with service protocols and mocks.
- View models remain responsible for state orchestration.
- SwiftUI views stay focused on presentation and interaction.
