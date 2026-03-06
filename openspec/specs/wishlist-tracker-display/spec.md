## Purpose

Define how tracked wishlist items are rendered in the Objective Tracker, including grouping, row presentation, and removal interactions.

## Requirements

### Requirement: Objective tracker shows a Loot Wishlist section

The addon SHALL render tracked wishlist items inside the objective tracker under a section labeled `Loot Wishlist`. The section SHALL be visible whenever the active character has at least one tracked item.

#### Scenario: Tracker section appears when items are tracked

- **WHEN** the active character has one or more tracked wishlist items
- **THEN** the objective tracker shows a `Loot Wishlist` section containing those items

#### Scenario: Tracker section disappears when no items are tracked

- **WHEN** the active character has no tracked wishlist items
- **THEN** the objective tracker does not show the `Loot Wishlist` section

### Requirement: Tracker items are grouped by loot source

The addon SHALL group tracked items in the objective tracker by their identified loot source, such as the dungeon or raid where the item drops. If no loot source can be identified for a tracked item, the addon SHALL place that item under an `Other` group.

#### Scenario: Item with identified source is grouped under that source

- **WHEN** a tracked item has a known dungeon or raid source
- **THEN** the objective tracker displays that item under a group named for that source

#### Scenario: Item with unknown source falls back to Other

- **WHEN** a tracked item does not have an identified loot source
- **THEN** the objective tracker displays that item under the `Other` group

### Requirement: Tracker rows show current possession and best looted item level separately

The addon SHALL show a green tick for a tracked item only when the active character currently possesses any version of that item in equipped slots, bags, or bank when bank data is known. The addon SHALL append the highest remembered looted item level in parentheses when that value is known, even if the item is not currently possessed. Hovering a tracked item row SHALL show the standard Blizzard item tooltip for that row using the game's default tooltip anchor behavior, with no addon-specific tooltip lines. When a best owned item link is available, the tracker row SHALL use that link for display styling instead of an older tracked journal link.

#### Scenario: Tracked item is currently possessed

- **WHEN** the active character currently has any version of a tracked item equipped, in bags, or in known bank contents
- **THEN** the objective tracker row shows a green tick for that item

#### Scenario: Tracked item is no longer possessed

- **WHEN** the active character no longer has any version of a tracked item equipped, in bags, or in known bank contents
- **THEN** the objective tracker row does not show the green tick for that item

#### Scenario: Best looted item level remains after the item is gone

- **WHEN** the addon knows the highest looted item level for a tracked item but the character does not currently possess the item
- **THEN** the objective tracker still shows the item level in parentheses without the green tick

#### Scenario: Best owned version controls row styling

- **WHEN** the character owns a higher-quality or otherwise better version of a tracked item than the originally tracked journal link
- **THEN** the tracker row uses the best owned item link for display styling so row quality color matches the best known owned version

#### Scenario: Hover tracked item row shows default item tooltip

- **WHEN** the user hovers a tracked item row in the `Loot Wishlist` section and the addon can resolve that item
- **THEN** the standard Blizzard item tooltip is shown using the game's default tooltip anchor behavior without addon-specific tooltip text

### Requirement: Tracker rows support direct removal

The addon SHALL allow the user to remove a tracked item from the wishlist by Shift-clicking that item in the objective tracker.

#### Scenario: Shift-click removes a tracked item

- **WHEN** the user Shift-clicks a tracked item in the `Loot Wishlist` section
- **THEN** the addon removes the item from the active character's wishlist and updates the tracker accordingly

### Requirement: Newly added tracker items use native tracker animation

When an item is newly added to the `Loot Wishlist` section, the addon SHALL reuse the same style of add-entry animation used by the native objective tracker when a new quest is tracked.

#### Scenario: Newly tracked item appears in the tracker

- **WHEN** the user adds an item to the wishlist and it appears in the objective tracker for the first time
- **THEN** the item entry uses the native objective-tracker add animation style rather than a custom animation

### Requirement: Tracker visuals prefer native Blizzard UI assets

The addon SHALL prefer Blizzard-provided UI assets and visual patterns for tracker presentation, including indicators and row styling, unless a native asset cannot express the required behavior.

#### Scenario: Tracker row is rendered

- **WHEN** the addon renders a wishlist row in the objective tracker
- **THEN** it uses native Blizzard visual patterns where practical instead of bespoke addon-specific visuals
