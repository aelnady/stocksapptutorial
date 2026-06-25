# Product Vision

Turn this SwiftUI stocks tutorial app into a production-quality AI-powered investment assistant. The product should help users understand market data, maintain a focused watchlist, review portfolio exposure, and learn from clear AI-assisted explanations.

The app should feel native, fast, trustworthy, and calm. It should make investing concepts easier to understand without pretending to know the future.

# Mission

Help everyday investors make sense of stocks and portfolios through simple native tools, reliable market data, and responsible AI explanations.

# Target Audience

- Beginner investors learning how to read stock quotes and charts.
- Casual investors who maintain a watchlist and want quick context.
- Long-term investors who want portfolio visibility without complexity.
- iPhone users who prefer a native Apple experience.
- Learners who want AI summaries that explain market data in plain language.

# User Personas

## Beginner Learner

Wants to understand ticker symbols, price changes, charts, and basic market terms without being overwhelmed.

## Casual Watchlist User

Tracks a handful of companies and wants quick answers about what changed today and why it may matter.

## Portfolio Tracker

Owns positions and wants simple visibility into allocation, gains/losses, and exposure.

## Research-Oriented User

Wants news, sentiment, technical indicators, and AI summaries in one place before doing deeper research elsewhere.

# Problems We Solve

- Stock apps often show dense data without explanation.
- Beginners struggle to connect quote changes, chart movement, and news.
- Watchlists can become passive lists of numbers.
- Portfolio exposure is hard to understand without clear summaries.
- AI can be useful but risky if it sounds too certain or acts like advice.

# Product Principles

- Simplicity first.
- AI explains, not predicts.
- Native Apple experience.
- Fast and responsive.
- Trust over hype.
- User control over automation.
- Clear uncertainty over false confidence.
- Privacy and security by default.
- Every feature should improve understanding.

# Product Stages

## Stage 1: Stabilize The App

- Preserve existing watchlist, search, quote, and chart behavior.
- Improve reliability, error states, and test coverage.
- Keep the app in SwiftUI and MVVM.

## Stage 2: Modernize UI

- Refine typography, spacing, list rows, chart layout, and sheet structure.
- Add consistent loading, empty, and error states.
- Improve accessibility, Dynamic Type, and Dark Mode behavior.

## Stage 3: AI Foundation

- Add `AIService` and mock AI services.
- Add AI stock insights in the ticker detail sheet.
- Keep AI output educational and clearly labeled.

## Stage 4: Portfolio Management

- Add local holdings and transaction tracking.
- Calculate allocation, cost basis, and gain/loss.
- Keep portfolio separate from the watchlist.

## Stage 5: News & Sentiment

- Add news service protocols and article models.
- Summarize news and sentiment responsibly.
- Cite sources where possible.

## Stage 6: Technical Analysis

- Add simple, explainable indicators such as moving averages and volume trends.
- Avoid complex trading signals unless clearly marked as experimental.

## Stage 7: Cloud Sync

- Add optional authentication.
- Sync watchlists, portfolios, notes, preferences, and alerts.
- Move protected API access behind a backend.

## Stage 8: App Store Release

- Polish onboarding, privacy messaging, disclaimers, and performance.
- Finalize app metadata, screenshots, and review-ready compliance language.

# Core Features

- Search for stock tickers.
- Add and remove watchlist symbols.
- View saved tickers with current quote data.
- Open a ticker detail sheet.
- Inspect stock charts across multiple ranges.
- View quote metrics and market state.
- Persist the local watchlist.
- Use mock services for previews and testing.

# Future Features

- AI stock insights.
- AI watchlist summary.
- Portfolio holdings and transactions.
- Portfolio allocation and gain/loss views.
- News and sentiment summaries.
- Technical analysis summaries.
- Price alerts.
- Per-symbol notes.
- Cloud sync.
- Backend proxy for protected API access.

# Out Of Scope

- Direct brokerage trading.
- Automated trade execution.
- Personalized financial advice.
- Tax advice.
- Legal advice.
- Guaranteed predictions.
- Options, futures, crypto, or derivatives workflows unless explicitly added later.
- Social trading feeds.

# Success Metrics

- Users can add and review watchlist tickers quickly.
- Stock detail screens remain understandable and responsive.
- AI summaries help users understand data without replacing judgment.
- Users can verify AI claims through source data or links.
- Loading, empty, and error states are reliable.
- App performance remains smooth as features grow.
- No secrets are committed or bundled.
- Preview and test coverage expands with major features.

# Product Philosophy

This app should be an investment learning and research companion, not an oracle. It should reduce confusion, organize context, and explain market information in plain language. The product wins by being useful, cautious, native, and trustworthy.

When in doubt, choose clarity over density, explanation over prediction, and user trust over flashy automation.

# Investment Disclaimer

This app is for educational and informational use only. It should not present AI output as financial advice. AI summaries should explain reasoning and uncertainty. Trading signals should be avoided unless clearly labeled as experimental. Users should verify information from primary sources before making investment decisions.
