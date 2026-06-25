# UI Playbook

## Design Direction

The app should feel like a polished native iOS stocks assistant: calm, readable, quick, and useful. It should modernize the current tutorial UI without losing the compact watchlist and detail-sheet workflow.

## Apple Human Interface Guidelines

- Prefer native SwiftUI controls and platform conventions.
- Use familiar iOS navigation, sheets, lists, buttons, search, and refresh behavior.
- Respect safe areas, system spacing, and standard interaction patterns.
- Keep controls predictable and easy to discover.

## Clean Typography

- Use system fonts.
- Use clear hierarchy between ticker symbols, company names, prices, deltas, and section headings.
- Avoid oversized text inside compact stock rows or data panels.
- Support Dynamic Type without truncating important financial values.

## Card-Based Layouts

- Use cards for grouped content such as AI insights, portfolio summaries, news items, and metric groups.
- Keep cards simple and information-dense.
- Avoid nesting cards inside cards.
- Use modest corner radii and subtle borders/backgrounds.

## Native Controls

- Use `List`, `ScrollView`, `Button`, `Menu`, `Picker`, `NavigationStack`, `.searchable`, `.refreshable`, and sheets where appropriate.
- Prefer native controls before custom controls.
- Keep chart range selection simple and tappable.

## Minimal Visual Clutter

- Prioritize the user's current task.
- Avoid decorative UI that does not improve comprehension.
- Keep dense financial information grouped and scannable.
- Use whitespace to separate sections, not to create a marketing layout.

## Accessibility

- Support VoiceOver labels for chart controls, price changes, add/remove buttons, and AI sections.
- Ensure sufficient contrast in Light and Dark Mode.
- Do not communicate gains/losses by color alone.
- Keep tap targets comfortable.

## Dynamic Type

- Test important screens with larger text sizes.
- Allow multi-line company names and section copy where needed.
- Avoid fixed-height containers that clip text.
- Keep numbers readable at all supported sizes.

## Dark Mode

- Use system colors where possible.
- Verify chart lines, grid lines, cards, and text in both Light and Dark Mode.
- Avoid custom colors that only work in one appearance.

## Color Philosophy

- Use green/red carefully for positive/negative movement.
- Pair color with symbols, text, or labels for accessibility.
- Use accent color for primary interactive elements.
- Keep AI sections visually distinct but calm.

## Animation Philosophy

- Use animation sparingly and purposefully.
- Favor subtle transitions for loading, section expansion, and chart interactions.
- Avoid motion that distracts from financial data.
- Respect Reduce Motion.

## Loading States

- Show lightweight loading indicators for quote, chart, AI, news, and portfolio sections.
- Preserve existing content when refreshing if possible.
- Avoid full-screen loading when only one section is updating.

## Empty States

- Explain what is missing and what the user can do next.
- Keep empty watchlist messaging short.
- Use empty states for no news, no portfolio holdings, and no AI insight available.

## Error States

- Show concise errors with retry actions where useful.
- Keep technical details out of user-facing copy unless needed.
- Do not let one failed section break the whole screen.

## Navigation Principles

- Keep the watchlist as the main home screen.
- Use sheets for focused ticker details if the interaction remains lightweight.
- Add tabs only when portfolio/news/settings become substantial enough to justify them.
- Keep deep navigation shallow and reversible.

## Component Consistency

- Reuse common loading, empty, and error views.
- Reuse row patterns for stocks, holdings, news, and metrics.
- Keep spacing, typography, and button styles consistent.
- Extract components when repeated UI starts to drift.

## Charts

- Keep charts readable before making them advanced.
- Preserve range controls.
- Make selected-point interactions clear.
- Add technical indicators gradually and with labels.
- Avoid overcrowding charts with too many overlays.

## Forms

- Use native form controls for portfolio transactions, notes, alerts, and settings.
- Validate inputs clearly.
- Keep financial entry fields precise and localized where practical.

## Lists

- Keep list rows compact but readable.
- Support refresh where data changes frequently.
- Show price, change, and context consistently.
- Avoid row designs that shift layout while loading.

## Future Design System Ideas

- Shared metric card component.
- Shared stock row component variants.
- Shared section header style.
- Shared AI insight card.
- Shared news article row.
- Shared portfolio summary card.
- Design tokens for spacing, colors, and typography.
