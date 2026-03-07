## Why

The Loot Wishlist tracker section disappears when the game has no other objectives tracked (no quests, world quests, etc.). This happens because the addon creates a raw frame as a child of the ObjectiveTracker's BlocksFrame. When the game decides nothing needs tracking, it hides the entire ObjectiveTrackerFrame — and our child frame vanishes with it. Attempts to force the parent visible create a show/hide fight with the game engine, causing flickering and preventing intentional collapse.

The root cause is that the addon does not participate in the ObjectiveTracker module system introduced in TWW (11.x). Registered tracker modules signal their content to the tracker manager, which keeps the tracker visible when any module has content. Refactoring to use `ObjectiveTrackerModuleMixin` solves the visibility bug natively and eliminates all the manual hook/watcher machinery.

## What Changes

- Replace the raw frame-based tracker section with a proper `ObjectiveTrackerModuleMixin` module registered with the tracker manager
- Remove all manual visibility hooks (`OnHide`/`OnShow` on `ObjectiveTrackerFrame`, `BlocksFrame`, `ContentsFrame`, `SetCollapsed`, legacy collapse/expand functions)
- Remove the UIParent-parented watcher frame
- Remove manual anchor management (`updateAnchor`) — the tracker manager handles stacking
- Remove `IsTrackerContentVisible()` and `getTrackerParent()` — no longer needed
- Map the existing group/item data model to the module's block/line system
- Preserve all existing row interactions: tooltips, shift-click removal, quality colors, add animation
- Preserve the addon's own collapse/expand behavior for the Loot Wishlist section header

## Capabilities

### New Capabilities

_None — this is a refactor of existing capability, not new user-facing behavior._

### Modified Capabilities

- `wishlist-tracker-display`: The tracker section now registers as a native ObjectiveTracker module. This changes how the section anchors, shows/hides, and integrates with the tracker lifecycle — but all user-facing behavior defined in the spec remains the same. Additionally, the section SHALL remain visible when the character has tracked wishlist items even if no other game objectives are being tracked.

## Impact

- **`TrackerUI.lua`**: Major rewrite — replaces frame creation, hooks, watcher, and layout with module-based implementation
- **`TrackerRowStyle.lua`**: May need minor updates if the module line templates use different spacing conventions
- **`TrackerModel.lua`**: No changes — the groups/items data model stays the same
- **`LootWishList.lua`**: Minor change — `TrackerUI.Refresh` call signature may change to match the module update pattern
- **Compatibility**: Requires TWW 11.x ObjectiveTracker API. Legacy pre-TWW tracker support is dropped.
