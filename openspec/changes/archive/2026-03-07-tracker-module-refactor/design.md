## Context

The Loot Wishlist tracker section is currently implemented as a raw `Frame` parented to `ObjectiveTrackerFrame.BlocksFrame`. It manually hooks 8+ visibility events (`OnHide`/`OnShow` on `ObjectiveTrackerFrame`, `BlocksFrame`, `ContentsFrame`, `SetCollapsed`, minimize buttons, legacy collapse/expand functions) and runs a UIParent-parented watcher frame to synchronize visibility. It also manually scans sibling frames to compute anchor position (`updateAnchor`).

This approach breaks when the game has no native objectives tracked: the game hides `ObjectiveTrackerFrame` entirely, cascading to hide the wishlist section. Forcing the parent visible creates a fight with the game engine.

In TWW 11.x, the ObjectiveTracker uses a module system based on `ObjectiveTrackerModuleMixin`. Registered modules signal content availability to `ObjectiveTrackerManager`, which keeps the tracker visible when any module has content and manages layout/stacking automatically.

## Goals / Non-Goals

**Goals:**

- Eliminate the visibility bug where the wishlist disappears when no game objectives are tracked
- Register the Loot Wishlist as a native ObjectiveTracker module so the tracker manager handles visibility and layout
- Remove all manual visibility hooks and the watcher frame
- Remove manual anchor computation — use the module system's built-in stacking
- Preserve all user-facing behavior: grouping, row styling, tooltips, shift-click removal, add animation, section collapse

**Non-Goals:**

- Backward compatibility with pre-TWW (pre-11.x) ObjectiveTracker API — the addon already targets retail TWW
- Changing the data model in `TrackerModel.lua` or `TrackerRowStyle.lua`
- Adding new user-facing features

## Decisions

### Decision 1: Use ObjectiveTrackerModuleMixin directly

**Choice**: Create a module by mixing in `ObjectiveTrackerModuleMixin` and registering with the tracker manager.

**Rationale**: This is the standard pattern used by all native TWW tracker modules (quest, campaign, world quest, bonus objective, etc.). It provides automatic visibility management, stacking, and collapse handling.

**Alternatives considered**:

- _Hook-based workaround_: Tried and failed — fighting the game's show/hide cycle creates flickering and prevents intentional collapse
- _Reparenting to UIParent_: Works but disconnects from the tracker visually and architecturally

### Decision 2: Map groups to header blocks and items to content lines

**Choice**: Each source group becomes a block header (using `ObjectiveTrackerModuleHeaderMixin` or equivalent), each item becomes a content line within that block.

**Rationale**: Matches the native tracker pattern where quests have headers and objectives appear as lines below. Leverages the module's built-in line pooling and layout.

### Decision 3: Keep TrackerModel and TrackerRowStyle unchanged

**Choice**: The module's `Update` method consumes the same `groups` data structure from `TrackerModel.lua` and uses the same constants from `TrackerRowStyle.lua`.

**Rationale**: These modules are pure data/constants with no frame API coupling. They work correctly today and don't need changes.

### Decision 4: Replace Refresh entry point with module Update

**Choice**: Instead of `TrackerUI.Refresh(namespace, groups)` called from `LootWishList.lua`, the module's content is updated by setting the groups data and calling the module's `MarkDirty` or equivalent update trigger.

**Rationale**: The tracker manager calls `Update` on modules during its update cycle. We set the data and mark dirty; the manager handles the rest.

## Risks / Trade-offs

**Risk: ObjectiveTrackerModuleMixin is a semi-internal API** → The mixin is used by all native modules but isn't formally documented for addon use. Blizzard could change it between major patches. **Mitigation**: The API has been stable since TWW launch, many popular addons use it, and the pattern closely mirrors Blizzard's own modules. If the API breaks, the fix would be localized to `TrackerUI.lua`.

**Risk: Module registration order affects display position** → The wishlist section may appear at an unexpected position in the tracker. **Mitigation**: The tracker manager supports ordering via module priority. We can set a priority that places the wishlist after native sections.

**Risk: Line template customization limits** → The native line templates may not perfectly match current row styling (check atlas, text offsets). **Mitigation**: Custom line templates can be defined or the module's lines can be post-processed with the existing `TrackerRowStyle` constants.

**Trade-off: Dropping pre-TWW support** → The legacy hooks (`ObjectiveTracker_Update`, `ObjectiveTracker_Collapse/Expand`, `BlocksFrame`) will be removed. Players on older clients would lose tracker functionality. Since the addon targets `_retail_` (which is TWW), this is acceptable.
