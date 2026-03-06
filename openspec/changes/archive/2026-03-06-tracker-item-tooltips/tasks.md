## 1. Tooltip item resolution

- [x] 1.1 Review existing tracker-row item metadata and identify the best available item reference path for tooltip display.
- [x] 1.2 Add fallback tooltip item resolution that prefers saved item links and falls back to stable item identity when a full link is unavailable.
- [x] 1.3 Define tracker-row display-link selection that prefers the best owned item link for row styling and falls back to the tracked/base link when no owned link is available.

## 2. Tracker row hover behavior

- [x] 2.1 Add hover handlers to tracker rows so tracked items request the standard Blizzard item tooltip on mouse enter.
- [x] 2.2 Ensure tooltip placement uses the game's default anchor behavior rather than a custom tracker-relative anchor.
- [x] 2.3 Hide the tooltip cleanly on mouse leave without affecting existing click interactions such as `Shift+Click` removal.

## 3. Tooltip presentation safeguards

- [x] 3.1 Verify that tracker-row tooltips remain pure Blizzard item tooltips with no addon-specific text injection.
- [x] 3.2 Add or update tests for tooltip resolution helper behavior where local testing is possible, and document any live-client-only verification needed.
- [x] 3.3 Verify that tracker row quality color follows the best owned item link when a better owned version exists, rather than the originally tracked journal link.
