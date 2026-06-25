# AI Playbook

## Mission Of AI Inside The App

AI should help users understand stock, watchlist, portfolio, chart, news, and sentiment data. It should explain context, summarize signals, and teach financial concepts without presenting itself as a financial advisor or prediction engine.

## AI Principles

- Explain reasoning.
- Never present financial advice.
- Express uncertainty.
- Be transparent.
- Cite data sources whenever possible.
- Prefer concise, plain-language summaries.
- Separate observed facts from interpretation.
- Encourage verification from primary sources.

## Response Style

- Clear, calm, and educational.
- Short enough to scan on mobile.
- Explicit about what data was used.
- Explicit about uncertainty and missing context.
- No hype, pressure, or fear-based language.
- No direct buy/sell/hold instructions.

## Prompt Engineering Philosophy

- Use structured input models instead of ad hoc strings.
- Keep prompts centralized and versionable.
- Include only the data needed for the requested task.
- Ask the model to distinguish facts, interpretation, and uncertainty.
- Require safe wording for investment-related outputs.
- Test prompts with mock and edge-case market data.

## Supported AI Capabilities

- Stock detail summary.
- Chart movement explanation.
- Watchlist daily summary.
- Beginner-friendly explanation of quote metrics.
- News theme summary.
- Sentiment summary from articles.
- Portfolio allocation explanation.

## Future AI Capabilities

- Compare two stocks using structured metrics.
- Explain portfolio concentration and diversification.
- Summarize earnings-call or filing excerpts if source data is available.
- Generate learning prompts for beginner investors.
- Explain technical indicators in plain language.
- Detect unusual watchlist movement and explain possible drivers.

## Safety

- The app is educational and informational only.
- AI output must not be framed as financial advice.
- Avoid trading signals unless clearly labeled as experimental.
- Avoid guarantees, price targets, or certainty about future performance.
- Encourage users to verify information before investing.

## Hallucination Prevention

- Ground responses in provided quote, chart, portfolio, and news data.
- Prefer "not enough information" over guessing.
- Ask for citations or source labels when using news or external data.
- Display source timestamps where possible.
- Avoid generating facts not present in the input.

## Confidence Scoring

- Use confidence labels only when they are meaningful and explainable.
- Prefer qualitative labels such as low, medium, and high.
- Tie confidence to data freshness, source quality, and agreement across inputs.
- Do not imply mathematical precision unless the score is actually computed.

## Caching

- Cache expensive AI responses when the input data and prompt version are unchanged.
- Include ticker, range, quote timestamp, news IDs, prompt version, and model ID in cache keys where appropriate.
- Expire AI summaries when market data changes materially.
- Avoid caching sensitive user portfolio data without a clear privacy model.

## Cost Optimization

- Keep prompts compact.
- Summarize only the visible or requested scope.
- Use smaller/cheaper models for simple summaries if quality is sufficient.
- Batch watchlist summaries when practical.
- Cache repeated outputs.

## Privacy

- Treat watchlists, portfolios, notes, and user prompts as sensitive.
- Do not log sensitive AI inputs by default.
- Avoid sending unnecessary portfolio details to AI services.
- Use a backend proxy before production AI release so secrets stay off-device.
- Provide clear user-facing privacy language before cloud AI features ship.

## Future Multi-Model Architecture

- Route simple summaries to a cost-efficient model.
- Route complex portfolio or news synthesis to a stronger model.
- Keep model selection behind `AIService`.
- Track model name, prompt version, and response metadata for debugging.
- Keep mocks deterministic for previews and tests.
