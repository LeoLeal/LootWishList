## MODIFIED Requirements

### Requirement: Objective tracker shows a Loot Wishlist section

The addon SHALL register a native ObjectiveTracker module using `ObjectiveTrackerModuleMixin` with the tracker manager. The module SHALL report content availability so that the tracker manager keeps the ObjectiveTrackerFrame visible whenever the active character has at least one tracked wishlist item, even if no other game objectives are being tracked. The section SHALL be labeled `Loot Wishlist`.

#### Scenario: Tracker section appears when items are tracked

- **WHEN** the active character has one or more tracked wishlist items
- **THEN** the objective tracker shows a `Loot Wishlist` section containing those items

#### Scenario: Tracker section disappears when no items are tracked

- **WHEN** the active character has no tracked wishlist items
- **THEN** the objective tracker does not show the `Loot Wishlist` section

#### Scenario: Wishlist section keeps tracker visible with no other objectives

- **WHEN** the active character has tracked wishlist items but no quests, world quests, or other game objectives are being tracked
- **THEN** the ObjectiveTrackerFrame remains visible and the `Loot Wishlist` section is displayed

#### Scenario: Wishlist section respects tracker collapse

- **WHEN** the player explicitly collapses the ObjectiveTrackerFrame
- **THEN** the `Loot Wishlist` section is hidden along with all other tracker sections
