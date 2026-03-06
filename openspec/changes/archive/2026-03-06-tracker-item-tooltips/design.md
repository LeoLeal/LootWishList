## Context

The addon already renders tracked loot rows in the Objective Tracker and stores lightweight item metadata such as item identity, source label, and item link when known. Users can see tracked items in the wishlist section, but they cannot inspect those items from the tracker itself without returning to the Adventure Guide or finding the item elsewhere in the UI.

Tooltip support is a cross-cutting change because it touches tracker-row interaction, saved metadata quality, and item identity fallback behavior. It must also preserve the addon's existing architectural rule of preferring Blizzard-native UI behavior over addon-defined presentation, especially for tooltip placement and content.

## Goals / Non-Goals

**Goals:**
- Show the standard Blizzard item tooltip when the user hovers a tracked row in the `Loot Wishlist` section.
- Use the game's default tooltip anchor behavior rather than a custom tracker-relative anchor.
- Resolve the tooltip from the best available item reference, preferring a saved item link and falling back to a stable item identity path when needed.
- Prefer the best owned item link for tracker-row visual styling so row quality color matches the player's best known version when one is owned.
- Keep tooltip content purely Blizzard-native, with no wishlist-specific injected lines or custom footer text.

**Non-Goals:**
- Adding tooltip decoration, wishlist markers, or extra addon text inside the tooltip.
- Adding click actions from tooltip interactions.
- Expanding tooltip support to every possible item-bearing UI surface in the addon.
- Changing tracker storage semantics beyond what is needed to preserve or derive a usable item reference.

## Decisions

### 1. Treat tooltip support as tracker-row interaction, not a global tooltip system

The initial behavior should live in tracker-row hover handlers inside `TrackerUI.lua` rather than introducing a global tooltip decorator module. This keeps the feature scoped to the user interaction discussed and avoids unnecessary coupling with every tooltip source in the game.

Alternatives considered:
- Global tooltip hooks for all item tooltips: rejected because the requirement is specific to tracker rows and should remain implementation-light.
- A separate tooltip UI module: deferred because tracker-row hover behavior can be implemented cleanly without a broader architecture change.

### 2. Prefer saved item links, then fall back to stable item identity

Tracker rows should use the best available item reference for opening the Blizzard tooltip. A saved item link should be preferred because it gives the richest tooltip fidelity. If no link is present, the row should fall back to an item-ID-based lookup path derived from stable identity.

Alternatives considered:
- Use item IDs only: rejected because tooltips may be less faithful to the actual tracked item metadata.
- Persist full tooltip-specific state: rejected because tooltip support should reuse existing wishlist metadata rather than storing presentation-focused state.

### 3. Prefer the best owned item link for tracker-row display styling

Tracker rows should not color or style the tracked item name from an older tracked journal link when the character already owns a better version of the same underlying item. If a best owned item link is available, the tracker row should use that link for display styling so quality color and displayed item-level progress remain coherent.

Alternatives considered:
- Always style rows from the originally tracked Adventure Guide link: rejected because a blue tracked link paired with an epic best-owned item level creates a misleading mixed state.
- Use plain uncolored item names always: rejected because the addon already benefits from Blizzard item-link styling and should preserve that when coherent.

### 4. Preserve Blizzard ownership of tooltip placement and contents

The addon should ask Blizzard to show the item tooltip and should not override the anchor point or inject extra lines. This matches the desired UX: hovering a tracker row should feel like hovering a standard item-bearing element elsewhere in the game.

Alternatives considered:
- Anchor the tooltip relative to the tracker row: rejected because the user explicitly wants the game's default tooltip anchor.
- Add wishlist-specific lines to the tooltip: rejected because the desired behavior is a pure Blizzard tooltip.

### 5. Keep failure behavior quiet and defensive

If an item reference cannot be resolved cleanly at hover time, the addon should fail quietly by not showing a broken or partial custom tooltip. Hover handlers should be defensive because tooltip data availability can vary with item cache state and UI context.

Alternatives considered:
- Show fallback addon text like `Wishlist item`: rejected because it would violate the pure Blizzard tooltip requirement.

## Risks / Trade-offs

- [Saved item links may be missing for older tracked items] -> Fall back to stable item identity and item-ID-based tooltip resolution.
- [Tracked journal links and best owned links may represent different quality tiers of the same item] -> Prefer best owned item links for row styling so visual quality matches the player's best version.
- [Tooltip APIs may behave differently depending on item cache state] -> Keep hover logic defensive and prefer Blizzard-owned tooltip resolution paths.
- [Tracker rows already have Shift-click removal behavior] -> Ensure hover behavior stays additive and does not interfere with existing click semantics.
- [Future tooltip expansion could blur module boundaries] -> Keep this change scoped to tracker rows only.

## Migration Plan

No explicit data migration is required if existing tracked rows already have usable item links. If some existing wishlist entries lack an item link, the implementation should tolerate that by using fallback item identity resolution rather than requiring a saved-variable upgrade.

## Open Questions

- Which Blizzard tooltip API path is the most reliable for item-ID fallback while still preserving default anchor behavior in the tracker context?
- Should tracker rows opportunistically refresh stored item links when a fallback item-ID tooltip lookup succeeds?
