## 1. Research & Preparation

- [x] 1.1 Examine TWW ObjectiveTrackerModuleMixin API by reading Blizzard's native tracker module source (e.g. QuestObjectiveTracker, BonusObjectiveTracker) to understand the module registration, HasContents, Update/LayoutContents, header, block, and line patterns
- [x] 1.2 Identify the exact API calls needed: module creation, registration with ObjectiveTrackerManager, header setup, block/line creation, MarkDirty trigger, and module priority/ordering
- [x] 1.3 Read current `TrackerUI.lua` end-to-end and catalog every piece of functionality that must be preserved in the refactored module

## 2. Create the ObjectiveTracker Module

- [x] 2.1 Define the Loot Wishlist tracker module using ObjectiveTrackerModuleMixin in `TrackerUI.lua`, replacing the raw frame creation
- [x] 2.2 Register the module with ObjectiveTrackerManager at appropriate priority (after native sections)
- [x] 2.3 Implement the module's header setup using the `Loot Wishlist` label from `Locales.lua`

## 3. Implement Content Layout

- [x] 3.1 Implement the module's content update method to consume the `groups` data from `TrackerModel.lua` and render source group headers and item lines
- [x] 3.2 Apply `TrackerRowStyle` constants (check atlas, text offsets, spacing) to the module's lines
- [x] 3.3 Apply item quality coloring to item lines using `displayLink` and `ITEM_QUALITY_COLORS`
- [x] 3.4 Implement the section collapse/expand toggle on the module header

## 4. Preserve Row Interactions

- [x] 4.1 Implement tooltip display on hover (GameTooltip with item hyperlink or SetItemByID) for item lines
- [x] 4.2 Implement Shift-click removal on item lines (calls `namespace.RemoveTrackedItem`)
- [x] 4.3 Implement the add animation for newly tracked items using the module's native animation support

## 5. Update Refresh Entry Point

- [x] 5.1 Update `TrackerUI.Refresh` to set the module's groups data and trigger a module update (MarkDirty or equivalent) instead of manual frame show/hide/layout
- [x] 5.2 Update `LootWishList.lua` if the `TrackerUI.Refresh` call signature changes

## 6. Remove Legacy Code

- [x] 6.1 Remove all manual visibility hooks (OnHide/OnShow on ObjectiveTrackerFrame, BlocksFrame, ContentsFrame, SetCollapsed, minimize button, ObjectiveTracker_Collapse/Expand)
- [x] 6.2 Remove the UIParent-parented watcher frame
- [x] 6.3 Remove `updateAnchor`, `getTrackerParent`, `IsTrackerContentVisible`, `IsTrackerExplicitlyCollapsed`, and `ensureTrackerParentVisible` functions
- [x] 6.4 Remove `ensureRow` if replaced by the module's line pool system

## 7. Verification

- [x] 7.1 In-game: verify wishlist section appears when items are tracked and no game objectives exist
- [x] 7.2 In-game: verify wishlist section appears alongside other tracker sections (quests, world quests)
- [x] 7.3 In-game: verify collapsing the ObjectiveTracker hides the wishlist section
- [x] 7.4 In-game: verify expanding the ObjectiveTracker restores the wishlist section
- [x] 7.5 In-game: verify tooltips, shift-click removal, quality colors, and add animation work correctly
- [x] 7.6 In-game: verify the wishlist section's own collapse/expand toggle works
