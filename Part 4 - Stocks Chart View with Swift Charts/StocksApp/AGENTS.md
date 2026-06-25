# Engineering Guide

## 1. Project Vision

This is a SwiftUI stocks app for searching tickers, maintaining a watchlist, viewing current quote data, and inspecting stock price charts. Keep the experience simple, fast, and focused on stock discovery and lightweight quote analysis.

## 2. Tech Stack

- UI: SwiftUI.
- Charts: Apple Swift Charts.
- Architecture: MVVM.
- Async work: Swift concurrency with `async`/`await`.
- Reactive search: Combine where already used.
- Stock data: `XCAStocksAPI` through the local `StocksAPI` protocol.
- Persistence: local plist storage through `TickerListRepository`.

## 3. Architecture Standards

- Keep SwiftUI views focused on layout, rendering, and user interaction.
- Keep business logic, fetching, transformations, and state transitions in view models or services.
- Use protocols for external dependencies, matching the existing `StocksAPI` and `TickerListRepository` patterns.
- Inject services into view models so features remain mockable and previewable.
- Do not change existing behavior unless the user asks for that behavior change.

## 4. Folder Organization

- `StocksApp/Views`: SwiftUI screens and reusable view components.
- `StocksApp/Views/Common`: loading, empty, and error UI states.
- `StocksApp/Views/Stock Ticker Sheet Views`: ticker detail sheet, chart, range picker, and quote detail views.
- `StocksApp/View Models`: observable view models and UI state orchestration.
- `StocksApp/Models`: app-specific UI and state models.
- `StocksApp/Services`: networking, persistence, and future AI service protocols/implementations.
- `StocksApp/Extensions`: formatting and convenience extensions.
- `StocksApp/Mocks & Stubs`: mock services and sample data for previews/testing.

## 5. MVVM Rules

- Views should not call APIs directly.
- Views should not parse API responses or transform chart/quote data.
- View models may own `@Published` state, fetch phases, selected values, and user-triggered actions.
- Keep each view model focused: search, list quotes, ticker quote detail, chart data, or future AI insight state.
- Use `FetchPhase` or a similar explicit loading state for async UI flows.

## 6. AI Feature Rules

- Add AI functionality behind an `AIService` protocol in `StocksApp/Services`.
- Do not call AI APIs directly from SwiftUI views.
- Prefer a dedicated view model such as `StockInsightViewModel` for AI-generated summaries, chart commentary, or watchlist insights.
- Feed AI features with structured inputs such as `Ticker`, `Quote`, `ChartViewData`, selected range, and user intent.
- AI output should be clearly presented as generated analysis, not guaranteed financial advice.
- Provide mock AI services for previews and tests.

## 7. Networking Rules

- Keep stock API access behind `StocksAPI`.
- Keep future AI API access behind `AIService`.
- Use `async`/`await` for network calls.
- Surface loading, empty, and error states clearly.
- Avoid duplicating low-level networking code inside view models if it belongs in a service.
- Preserve the existing `XCAStocksAPI` integration unless explicitly asked to replace it.

## 8. Security Rules

- Never hardcode API keys, secrets, tokens, or credentials.
- Do not commit secrets to the repository.
- Prefer environment/configuration injection, secure storage, or caller-provided credentials.
- Do not log sensitive values.
- Treat AI prompts and responses as potentially sensitive if they include user watchlists or financial context.

## 9. Testing Rules

- Use mock services for tests and previews.
- Keep mocks similar to `MockStocksAPI` and `MockTickerListRepository`.
- Add focused tests when changing view model logic, service behavior, chart transformations, or AI prompt construction.
- Prefer deterministic stub data for charts and quote states.
- Verify loading, empty, success, and failure states when adding async features.

## 10. UI/UX Rules

- Keep the app native SwiftUI and consistent with the current compact stocks-app style.
- Preserve the main watchlist, searchable ticker flow, and ticker detail sheet unless asked to redesign them.
- Use existing common state views where practical.
- Keep chart interactions responsive and understandable.
- Avoid adding heavy explanatory text to the UI.
- AI features should assist the stock workflow without overwhelming the quote/chart experience.

## 11. Performance Rules

- Avoid unnecessary network calls; use existing `.task(id:)`, debounce, and refresh patterns carefully.
- Keep chart transformations efficient and scoped to the selected ticker/range.
- Avoid doing expensive work directly in SwiftUI `body`.
- Use caching only when it has a clear purpose and does not stale critical quote/chart behavior.
- Keep watchlist updates lightweight.

## 12. Git Workflow

- Make small, focused changes.
- Avoid unrelated refactors and formatting churn.
- Do not revert user changes unless explicitly asked.
- Check the working tree before broad edits when relevant.
- Use clear commit messages if asked to commit.

## 13. Documentation Expectations

- Update this guide when adding major architectural conventions.
- Use `docs/PRODUCT.md` for product direction, target users, feature scope, and success metrics.
- Use `docs/ROADMAP.md` for milestone planning and implementation sequencing.
- Use `docs/UI_PLAYBOOK.md` for design language, native SwiftUI UX, accessibility, and component consistency.
- Use `docs/AI_PLAYBOOK.md` for AI strategy, response style, safety, prompt design, caching, cost, and privacy.
- Use `docs/API_PLAYBOOK.md` for API integration strategy, dependency injection, caching, rate limits, errors, and migrations.
- Use `docs/RELEASE_NOTES.md`, `docs/IDEAS.md`, and `docs/DECISIONS.md` to track changes, backlog ideas, and important decisions.
- Document new service protocols with concise comments only when the purpose is not obvious.
- Explain new AI features, required configuration, and mock behavior.
- Keep documentation practical and close to the code it describes.

## 14. Future Roadmap

- Add an `AIService` abstraction for generated stock insights.
- Add ticker-level AI summaries in the detail sheet.
- Add chart commentary based on selected range and price movement.
- Add watchlist-level summaries for saved tickers.
- Improve error handling and retry behavior where useful.
- Add focused view model tests for search, quotes, chart transforms, and future AI insights.

## 15. Do Not Do Rules

- Do not move the app away from SwiftUI.
- Do not bypass MVVM by putting business logic in views.
- Do not put networking or AI calls directly inside SwiftUI views.
- Do not hardcode API keys.
- Do not replace `XCAStocksAPI` unless asked.
- Do not introduce large architecture rewrites for small feature requests.
- Do not change existing behavior unless asked.
- Do not add dependencies without a clear reason.

## 16. How Codex Should Respond After Changes

- State which files changed and why.
- Mention whether app code was modified.
- Mention whether tests/builds/previews were run, or why they were not.
- Call out any behavior changes explicitly.
- Keep the summary concise and specific to the requested work.
