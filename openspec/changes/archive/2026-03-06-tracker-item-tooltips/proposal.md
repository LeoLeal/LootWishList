## Why

Tracked items in the `Loot Wishlist` section are currently actionable and visually informative, but they do not expose the familiar Blizzard item tooltip on hover. Adding pure Blizzard item tooltips to tracker rows lets players inspect tracked loot from the Objective Tracker without opening the Adventure Guide or introducing addon-specific tooltip clutter.

## What Changes

- Add hover behavior for tracked item rows in the `Loot Wishlist` section so they show the standard Blizzard item tooltip.
- Use the game's default tooltip anchoring rather than a custom tracker-relative anchor.
- Prefer the best available item reference for tooltip resolution, using saved item metadata when available and stable item identity fallback when needed.
- Prefer the best owned item link for tracker-row display styling when the character already has a higher-quality or otherwise better version of a tracked item.
- Keep tooltip presentation entirely Blizzard-native: no wishlist-only lines, markers, or custom footer text.

## Capabilities

### New Capabilities
- `tracker-item-tooltips`: Show pure Blizzard item tooltips from wishlist tracker rows using default tooltip anchoring and best-available item references.

### Modified Capabilities
- `wishlist-tracker-display`: Extend tracker row behavior so hovering tracked items opens the standard Blizzard item tooltip without adding custom tooltip content, and so row display styling prefers the best owned item link when available.

## Impact

- Affects `TrackerUI.lua`, saved item metadata usage from `WishlistStore.lua`, item reference fallback from `ItemResolver.lua`, tracker row display-link selection, and tracker interaction expectations in the Objective Tracker.
- Introduces tooltip hover behavior that must stay compatible with Blizzard tooltip ownership and placement rules.
- Extends tracker-display requirements without changing wishlist persistence, source grouping, or loot event behavior.
