# Roadmap

## 1. Product Vision

Turn this SwiftUI stocks tutorial app into a production-quality AI-powered investment assistant. The app should help users maintain watchlists, understand stock movements, review portfolio exposure, and get clear AI-assisted explanations of market data. It should remain native, fast, and easy to reason about.

This app should not present AI output as financial advice. AI features should explain, summarize, compare, and educate while keeping the user in control.

## 2. Current App Baseline

The current app already has a useful foundation:

- SwiftUI app entry with a `NavigationStack`.
- MVVM structure with dedicated view models for app state, search, quotes, ticker detail, and charts.
- `StocksAPI` protocol backed by `XCAStocksAPI`.
- Local watchlist persistence through `TickerListRepository`.
- Searchable ticker list.
- Saved ticker watchlist.
- Quote fetching for list rows and detail sheets.
- Swift Charts-based historical price chart.
- Mock services and stubs for previews.

Current limitations:

- No AI layer.
- No portfolio tracking.
- No user authentication.
- No durable cloud sync.
- No news, sentiment, or technical analysis features.
- Limited test coverage.

## 3. Major Milestones

### Milestone 1: Production Foundation

Goal: Keep the current app behavior intact while making the architecture ready for production features.

Deliverables:

- Add explicit service protocols for future AI, news, sentiment, and portfolio features.
- Add focused view model tests for existing search, quotes, and chart transformation behavior.
- Improve error handling and empty states where needed.
- Keep all existing app screens working.

Working state: The app remains a stock search/watchlist/chart app with no visible behavior regressions.

### Milestone 2: AI Stock Insights

Goal: Add AI-generated explanations for individual stocks.

Deliverables:

- Add `AIService` protocol.
- Add mock AI service for previews and testing.
- Add `StockInsightViewModel`.
- Show a concise AI summary inside `StockTickerView`.
- Use existing `Ticker`, `Quote`, selected `ChartRange`, and chart data as structured AI input.

Working state: Users can open a ticker and see an AI-assisted explanation without losing existing quote/chart behavior.

### Milestone 3: Watchlist Intelligence

Goal: Make the watchlist more useful and easier to scan.

Deliverables:

- Add watchlist sorting and grouping options.
- Add AI watchlist summary.
- Add daily movers/highlights for saved tickers.
- Add better loading/error feedback for quote refreshes.

Working state: The main list remains the home screen, now with smarter summaries and controls.

### Milestone 4: Portfolio Tracking

Goal: Let users track holdings, cost basis, gains/losses, and allocation.

Deliverables:

- Add portfolio models for holdings and transactions.
- Add local persistence for portfolio data.
- Add portfolio summary view.
- Add gain/loss calculations.
- Keep watchlist and portfolio concepts separate.

Working state: Users can maintain a simple local portfolio while the watchlist continues to work independently.

### Milestone 5: News, Sentiment, And Technical Analysis

Goal: Add context around why stocks are moving.

Deliverables:

- Add news service protocol and mock implementation.
- Add sentiment service or AI-powered sentiment summary.
- Add basic technical indicators such as moving averages, RSI, and volume trend summaries.
- Add detail-sheet sections for news, sentiment, and technical analysis.

Working state: Stock detail becomes richer while preserving the existing chart and quote sections.

### Milestone 6: Accounts, Sync, And Backend

Goal: Move from local-only data to authenticated, synchronized user data.

Deliverables:

- Add authentication.
- Add cloud-backed watchlist and portfolio sync.
- Add server-side storage for user settings.
- Add backend proxy for AI and market/news APIs to protect secrets.

Working state: Existing local flows continue working, with optional signed-in sync.

## 4. Recommended Folder Structure

Keep the current structure, but grow it deliberately:

```text
StocksApp/
  Models/
    Portfolio/
    AI/
    News/
    TechnicalAnalysis/
  Services/
    StocksAPI.swift
    TickerListRepository.swift
    AIService.swift
    NewsService.swift
    SentimentService.swift
    PortfolioRepository.swift
  View Models/
    StockInsightViewModel.swift
    WatchlistSummaryViewModel.swift
    PortfolioViewModel.swift
    NewsViewModel.swift
    TechnicalAnalysisViewModel.swift
  Views/
    Portfolio/
    AI/
    News/
    TechnicalAnalysis/
    Common/
    Stock Ticker Sheet Views/
  Mocks & Stubs/
```

Rules:

- Keep SwiftUI views under `Views`.
- Keep observable state and async orchestration under `View Models`.
- Keep external dependencies under `Services`.
- Keep app-specific data structures under `Models`.
- Keep preview/test doubles under `Mocks & Stubs`.

## 5. AI Architecture

Add AI through a service boundary:

```swift
protocol AIService {
    func generateStockInsight(input: StockInsightInput) async throws -> StockInsight
    func generateWatchlistSummary(input: WatchlistSummaryInput) async throws -> WatchlistSummary
}
```

Recommended flow:

```text
SwiftUI View -> AI ViewModel -> AIService protocol -> concrete AI provider
```

Guidelines:

- Do not call AI APIs directly from SwiftUI views.
- Do not hardcode API keys.
- Use structured input models rather than raw string concatenation.
- Keep prompts centralized and testable.
- Add `MockAIService` before adding visible AI UI.
- Clearly label AI output as generated analysis.
- Avoid making buy/sell recommendations unless a future compliance strategy is defined.

## Investment Disclaimer And AI Safety

- This app is for educational and informational use.
- It should not present AI output as financial advice.
- AI summaries should explain reasoning and uncertainty.
- Trading signals should be avoided unless clearly labeled as experimental.
- Users should verify information from primary sources before making investment decisions.

## 6. Portfolio Architecture

Portfolio should be separate from the watchlist.

Recommended models:

- `Portfolio`
- `Holding`
- `Transaction`
- `PortfolioPosition`
- `PortfolioSummary`

Recommended services:

- `PortfolioRepository`
- `PortfolioValuationService`

Responsibilities:

- Repository stores user-entered holdings and transactions.
- Valuation service combines holdings with live quote data.
- View model computes display state, allocation, gain/loss, and loading states.
- Views render portfolio summary, positions, and transaction entry.

Start local-first with plist, JSON, SwiftData, or another deliberate persistence option. Move to cloud sync later.

## 7. Watchlist Improvements

Practical improvements:

- Sort by symbol, name, price change, percent change, or recently added.
- Add manual reorder support.
- Add sections for gainers, losers, and unchanged tickers.
- Add watchlist refresh status.
- Add AI daily watchlist summary.
- Add per-symbol notes.
- Add price alerts in a later milestone.

Keep the current saved ticker list behavior intact while adding these capabilities.

## 8. Stock Detail Improvements

Improve `StockTickerView` without turning it into a crowded dashboard.

Recommended additions:

- AI stock summary.
- Key quote metrics section.
- Company profile summary.
- News list.
- Sentiment summary.
- Technical analysis summary.
- Better chart range persistence and selected point display.
- Optional comparison against market indices or another ticker.

Each section should have its own view and view model when it owns async data.

## 9. News And Sentiment Features

Add news behind a service protocol:

```swift
protocol NewsService {
    func fetchNews(symbol: String) async throws -> [NewsArticle]
}
```

Sentiment can be separate or AI-backed:

```swift
protocol SentimentService {
    func summarizeSentiment(articles: [NewsArticle], quote: Quote?) async throws -> SentimentSummary
}
```

Features:

- Latest company news.
- News summaries.
- Positive/neutral/negative sentiment label.
- AI explanation of major themes.
- Links to full articles.

Keep source attribution visible for news content.

## 10. Technical Analysis Features

Start with simple, explainable indicators:

- Moving averages.
- Price trend over selected range.
- Volume trend.
- Relative strength style summary.
- Support/resistance estimates only if clearly labeled as approximate.

Architecture:

- `TechnicalAnalysisService` can compute indicators locally from `ChartData`.
- `TechnicalAnalysisViewModel` prepares display state.
- `TechnicalAnalysisView` renders compact summaries below the chart.

Avoid adding complex trading signals before the app has tests and clear disclaimers.

## 11. Authentication And Persistence

Current persistence is local plist storage for tickers. Production persistence should grow in stages:

Stage 1:

- Keep local watchlist persistence.
- Add local portfolio persistence.
- Add migration-safe storage decisions before changing file formats.

Stage 2:

- Add optional sign-in.
- Sync watchlist, portfolio, notes, and preferences.

Stage 3:

- Use backend-managed credentials and API access.
- Add account deletion/export support.

Never store API secrets in the app bundle.

## 12. Future Cloud Backend

A backend becomes useful when adding AI, auth, sync, and paid APIs.

Backend responsibilities:

- Protect AI API keys and market/news API keys.
- Store authenticated user watchlists and portfolios.
- Cache expensive market/news/AI responses.
- Rate-limit requests.
- Provide audit-friendly AI request logs without storing unnecessary sensitive data.
- Support notification workflows for alerts.

The app should talk to the backend through service protocols, not directly from views.

## 13. Testing Strategy

Priorities:

- Unit test view models.
- Unit test chart data transformations.
- Unit test portfolio calculations.
- Unit test AI prompt/input construction.
- Use mock services for networking, AI, news, and persistence.
- Add snapshot or preview coverage for major UI states where practical.

Important states to test:

- Loading.
- Empty.
- Success.
- Failure.
- Stale request ignored after range/query changes.
- Portfolio gain/loss edge cases.

## 14. Suggested First 5 Implementation Tasks

1. Add `AIService`, AI input/output models, and `MockAIService` without adding visible UI.
2. Add `StockInsightViewModel` with loading, success, empty, and error states.
3. Add a compact AI insight section to `StockTickerView` using mock previews first.
4. Add view model tests for `ChartViewModel.transformChartViewData` and AI insight state transitions.
5. Add local portfolio models and a `PortfolioRepository` protocol, without changing the existing watchlist behavior.
