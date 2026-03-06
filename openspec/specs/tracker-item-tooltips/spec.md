## Purpose

Define how tracked wishlist items in the Objective Tracker expose the standard Blizzard item tooltip on hover, using default tooltip anchor behavior and best-available item references, with no addon-specific tooltip content.

## Requirements

### Requirement: Tracker rows show the standard Blizzard item tooltip on hover

When the user hovers a tracked item row in the `Loot Wishlist` section, the addon SHALL show that item's standard Blizzard item tooltip.

#### Scenario: Hover tracked row with a resolved item reference

- **WHEN** the user hovers a tracked item row and the addon can resolve an item reference for that row
- **THEN** the standard Blizzard item tooltip is shown for that item

#### Scenario: Hover tracked row with no resolved item reference

- **WHEN** the user hovers a tracked item row and the addon cannot resolve a usable item reference
- **THEN** the addon does not show custom fallback tooltip text

### Requirement: Tracker row tooltips use the game's default anchor behavior

The addon SHALL use the game's default item-tooltip anchor behavior for wishlist tracker rows and SHALL NOT force a custom anchor relative to the tracker row.

#### Scenario: Hover tracked row

- **WHEN** the user hovers a tracked item row in the `Loot Wishlist` section
- **THEN** the tooltip uses Blizzard's default anchor behavior rather than a tracker-specific custom anchor

### Requirement: Tooltip content remains purely Blizzard-native

The addon SHALL NOT inject wishlist-specific lines, labels, markers, or footer text into the tooltip shown from tracker rows.

#### Scenario: Tooltip is shown from a tracker row

- **WHEN** the addon shows an item tooltip from a tracked row
- **THEN** the tooltip contents remain the standard Blizzard item tooltip without addon-specific text additions
