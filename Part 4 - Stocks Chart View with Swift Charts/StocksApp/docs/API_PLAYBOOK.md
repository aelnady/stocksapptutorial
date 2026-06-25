# API Playbook

## Current APIs

- Stock search, quotes, and chart data are accessed through `StocksAPI`.
- `XCAStocksAPI` is the current concrete stock API provider.
- Saved tickers are persisted locally through `TickerListRepository`.

## Future APIs

- AI API through `AIService`.
- News API through `NewsService`.
- Sentiment API or AI-backed sentiment through `SentimentService`.
- Portfolio persistence through `PortfolioRepository`.
- Optional backend API for auth, sync, protected keys, caching, and alerts.

## Authentication

- The current app does not require authentication.
- Add auth only when cloud sync, alerts, or account-based features need it.
- Keep auth state out of SwiftUI views where possible.
- Use dedicated auth services and view models.

## Rate Limiting

- Debounce user-driven search, as the current app already does.
- Avoid repeated quote/chart fetches for unchanged inputs.
- Respect provider limits for stock, news, and AI APIs.
- Add retry policies carefully and avoid request storms.

## Caching

- Cache only when it improves speed, cost, or resilience.
- Keep quote data fresh enough for the UI context.
- Cache chart data by ticker and range if provider limits require it.
- Cache AI responses by input data and prompt version.
- Document cache invalidation rules for each service.

## Offline Support

- Preserve locally saved watchlist and future portfolio data offline.
- Show stale cached data with clear labels if used.
- Make network-dependent sections fail gracefully.
- Avoid blocking the whole app because one API is unavailable.

## Error Handling

- Convert service errors into view model state.
- Use loading, empty, success, and failure states consistently.
- Show retry actions where useful.
- Keep low-level provider errors out of user-facing text unless they help recovery.
- Log enough for debugging without exposing secrets.

## Security

- Never hardcode API keys.
- Do not commit secrets.
- Keep protected API access behind a backend before production.
- Do not log tokens, keys, or sensitive user financial context.
- Use secure storage for user credentials when auth is added.

## Versioning

- Version backend endpoints when they are introduced.
- Version AI prompts and response schemas.
- Track provider schema changes in service implementations.
- Keep model migrations explicit for portfolio and persisted user data.

## Dependency Injection

- Keep external dependencies behind protocols.
- Inject services into view models.
- Keep SwiftUI views free of direct API calls.
- Add mocks before or alongside concrete service implementations.
- Follow the existing `StocksAPI` pattern.

## Testing With Mocks

- Use deterministic mock services for previews and tests.
- Cover success, loading, empty, and failure states.
- Test stale request handling for search and chart range changes.
- Test API mapping separately from UI rendering.
- Keep mock data realistic but small.

## Migration Strategy

- Preserve existing behavior unless a change is requested.
- Introduce new service protocols before replacing providers.
- Migrate persistence formats deliberately and with fallback handling.
- Add backend integration behind existing repository/service protocols.
- Keep each migration small enough that the app remains working after every step.
