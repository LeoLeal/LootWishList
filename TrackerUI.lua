local TrackerUI = {}

local function playAddAnimation(frame)
  if frame and frame.headerFrame and frame.headerFrame.AddAnim and frame.headerFrame.AddAnim.Restart then
    frame.headerFrame.AddAnim:Restart()
  elseif type(ObjectiveTracker_PlayBlockAddedAnimation) == "function" then
    ObjectiveTracker_PlayBlockAddedAnimation(frame)
  elseif type(UIFrameFlash) == "function" then
    UIFrameFlash(frame, 0.2, 0.3, 0.8, false, 0, 0)
  end
end

local function applyCollapseButtonState(button, collapsed)
  if not button then
    return
  end

  local normalTexture = button.GetNormalTexture and button:GetNormalTexture() or nil
  local pushedTexture = button.GetPushedTexture and button:GetPushedTexture() or nil

  if normalTexture and normalTexture.SetAtlas then
    if collapsed then
      normalTexture:SetAtlas("ui-questtrackerbutton-secondary-expand", true)
    else
      normalTexture:SetAtlas("ui-questtrackerbutton-secondary-collapse", true)
    end
  end

  if pushedTexture and pushedTexture.SetAtlas then
    if collapsed then
      pushedTexture:SetAtlas("ui-questtrackerbutton-secondary-expand-pressed", true)
    else
      pushedTexture:SetAtlas("ui-questtrackerbutton-secondary-collapse-pressed", true)
    end
  end
end

local function getTrackerParent()
  if ObjectiveTrackerFrame and ObjectiveTrackerFrame.BlocksFrame then
    return ObjectiveTrackerFrame.BlocksFrame
  end

  return ObjectiveTrackerFrame
end

local function ensureRow(namespace, frame, index)
  frame.rows = frame.rows or {}
  local row = frame.rows[index]
  if row then
    return row
  end

  row = CreateFrame("Button", nil, frame)
  row:SetHeight(20)

  row.tick = row:CreateTexture(nil, "ARTWORK")
  row.tick:SetSize(namespace.TrackerRowStyle.CHECK_SIZE, namespace.TrackerRowStyle.CHECK_SIZE)
  row.tick:SetPoint("LEFT", 8, 0)
  row.tick:SetAtlas(namespace.TrackerRowStyle.CHECK_ATLAS, false)

  row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.text:SetPoint("LEFT", 20, 0)
  row.text:SetPoint("RIGHT", -4, 0)
  row.text:SetJustifyH("LEFT")
  row.text:SetWordWrap(false)

  frame.rows[index] = row
  return row
end

local function setCollapseState(frame, collapsed)
  frame.collapsed = collapsed and true or false
  if frame.headerFrame and frame.headerFrame.SetCollapsed then
    frame.headerFrame:SetCollapsed(frame.collapsed)
  else
    applyCollapseButtonState(frame.minimizeButton, frame.collapsed)
  end
end

local function updateAnchor(frame)
  local parent = frame:GetParent()
  if not parent then
    return
  end

  local anchorTarget = nil
  local anchorBottom = nil
  local anchorLeft = nil
  local children = { parent:GetChildren() }
  for _, child in ipairs(children) do
    if child ~= frame and child:IsShown() and child.GetBottom then
      local bottom = child:GetBottom()
      if bottom and (anchorBottom == nil or bottom < anchorBottom) then
        anchorBottom = bottom
        anchorLeft = child.GetLeft and child:GetLeft() or nil
        anchorTarget = child
      end
    end
  end

  frame:ClearAllPoints()
  if anchorTarget then
    local parentLeft = parent.GetLeft and parent:GetLeft() or nil
    local offsetX = 0
    if parentLeft and anchorLeft then
      offsetX = parentLeft - anchorLeft
    end

    frame:SetPoint("TOPLEFT", anchorTarget, "BOTTOMLEFT", offsetX, -10)
  else
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  end
end

function TrackerUI.Initialize(namespace)
  local parent = getTrackerParent()
  if not parent or namespace.trackerFrame then
    return
  end

  local frame = CreateFrame("Frame", "LootWishListTrackerFrame", parent)
  frame:SetWidth(260)
  frame:SetHeight(1)

  frame.headerFrame = CreateFrame("Frame", nil, frame, "ObjectiveTrackerModuleHeaderTemplate")
  frame.headerFrame:SetPoint("TOPLEFT", 0, 10)
  frame.headerFrame:SetPoint("TOPRIGHT", 0, 10)
  frame.headerFrame:SetHeight(26)

  if frame.headerFrame.Glow and frame.headerFrame.Text then
    frame.headerFrame.Glow:ClearAllPoints()
    frame.headerFrame.Glow:SetPoint("LEFT", frame.headerFrame.Text, "LEFT", -2, 0)
  end

  if frame.headerFrame.Shine and frame.headerFrame.Background then
    frame.headerFrame.Shine:ClearAllPoints()
    frame.headerFrame.Shine:SetPoint("LEFT", frame.headerFrame.Background, "LEFT", 8, 1)
  end

  frame.minimizeButton = frame.headerFrame.MinimizeButton
  frame.header = frame.headerFrame.Text or frame.headerFrame.HeaderText

  frame.headerButton = CreateFrame("Button", nil, frame.headerFrame)
  frame.headerButton:SetAllPoints(frame.headerFrame)
  frame.headerButton:SetScript("OnClick", function()
    setCollapseState(frame, not frame.collapsed)
    TrackerUI.Refresh(namespace, frame.groups or {})
  end)

  if frame.minimizeButton then
    frame.minimizeButton:SetScript("OnClick", function()
      setCollapseState(frame, not frame.collapsed)
      TrackerUI.Refresh(namespace, frame.groups or {})
    end)
  end

  setCollapseState(frame, false)
  updateAnchor(frame)

  namespace.trackerFrame = frame

  local function onTrackerHide()
    if namespace.trackerFrame then
      namespace.trackerFrame:Hide()
    end
  end

  local function onTrackerShow()
    if namespace.trackerFrame then
      TrackerUI.Refresh(namespace, (namespace.trackerFrame.groups or {}))
    end
  end

  -- Hook ObjectiveTracker_Update for re-anchoring.
  if type(ObjectiveTracker_Update) == "function" then
    hooksecurefunc("ObjectiveTracker_Update", function()
      if namespace.trackerFrame then
        if TrackerUI.IsTrackerContentVisible() then
          if namespace.trackerFrame:IsShown() then
            updateAnchor(namespace.trackerFrame)
          end
        else
          namespace.trackerFrame:Hide()
        end
      end
    end)
  end

  if ObjectiveTrackerFrame then
    ObjectiveTrackerFrame:HookScript("OnHide", onTrackerHide)
    ObjectiveTrackerFrame:HookScript("OnShow", onTrackerShow)

    -- Hook SetCollapsed (TWW 11.x method on ObjectiveTrackerFrame).
    if type(ObjectiveTrackerFrame.SetCollapsed) == "function" then
      hooksecurefunc(ObjectiveTrackerFrame, "SetCollapsed", function(_, collapsed)
        if collapsed then
          onTrackerHide()
        else
          onTrackerShow()
        end
      end)
    end

    -- Hook the header minimize button if present (TWW).
    local header = ObjectiveTrackerFrame.Header
    if header then
      local minBtn = header.MinimizeButton or header.CollapseButton
      if minBtn and minBtn.HookScript then
        minBtn:HookScript("OnClick", function()
          if TrackerUI.IsTrackerContentVisible() then
            onTrackerShow()
          else
            onTrackerHide()
          end
        end)
      end
    end

    -- Legacy: BlocksFrame hide/show.
    local blocksFrame = ObjectiveTrackerFrame.BlocksFrame
    if blocksFrame and blocksFrame.HookScript then
      blocksFrame:HookScript("OnHide", onTrackerHide)
      blocksFrame:HookScript("OnShow", onTrackerShow)
    end

    -- TWW: ContentsFrame hide/show.
    local contentsFrame = ObjectiveTrackerFrame.ContentsFrame
    if contentsFrame and contentsFrame.HookScript then
      contentsFrame:HookScript("OnHide", onTrackerHide)
      contentsFrame:HookScript("OnShow", onTrackerShow)
    end
  end

  -- Legacy global functions.
  if type(ObjectiveTracker_Collapse) == "function" then
    hooksecurefunc("ObjectiveTracker_Collapse", onTrackerHide)
  end
  if type(ObjectiveTracker_Expand) == "function" then
    hooksecurefunc("ObjectiveTracker_Expand", onTrackerShow)
  end

  -- Watcher parented to UIParent so it always runs.
  local watcher = CreateFrame("Frame", nil, UIParent)
  watcher:SetSize(0, 0)
  watcher:SetAlpha(0)
  watcher:SetScript("OnUpdate", function()
    local tf = namespace.trackerFrame
    if not tf or not tf:IsShown() then return end
    if not TrackerUI.IsTrackerContentVisible() then
      tf:Hide()
    end
  end)
end

function TrackerUI.IsTrackerContentVisible()
  if not ObjectiveTrackerFrame then return false end

  -- TWW 11.x: direct collapsed property checks.
  if ObjectiveTrackerFrame.isCollapsed then return false end
  if ObjectiveTrackerFrame.collapsed then return false end

  -- TWW 11.x: IsCollapsed method.
  if type(ObjectiveTrackerFrame.IsCollapsed) == "function" then
    if ObjectiveTrackerFrame:IsCollapsed() then return false end
  end

  -- Frame not shown at all.
  if not ObjectiveTrackerFrame:IsShown() then return false end

  -- Legacy: BlocksFrame hidden.
  local blocksFrame = ObjectiveTrackerFrame.BlocksFrame
  if blocksFrame and not blocksFrame:IsShown() then return false end

  -- TWW: ContentsFrame hidden.
  local contentsFrame = ObjectiveTrackerFrame.ContentsFrame
  if contentsFrame and not contentsFrame:IsShown() then return false end

  -- Last resort: check if our parent is actually visible on screen.
  local parent = getTrackerParent()
  if parent and type(parent.IsVisible) == "function" then
    if not parent:IsVisible() then return false end
  end

  return true
end

function TrackerUI.Refresh(namespace, groups)
  if not namespace.trackerFrame then
    TrackerUI.Initialize(namespace)
  end

  local frame = namespace.trackerFrame
  if not frame then
    return
  end

  if not groups or #groups == 0 then
    frame:Hide()
    return
  end

  frame.groups = groups

  -- Never show the frame when the parent tracker is collapsed or hidden.
  if not TrackerUI.IsTrackerContentVisible() then
    return
  end

  frame:Show()
  frame.header:SetText(namespace.GetText("LOOT_WISHLIST"))
  updateAnchor(frame)

  local rowIndex = 1
  local yOffset = -(frame.headerFrame and frame.headerFrame:GetHeight() or 26)
  local seenKeys = {}
  frame.knownRows = frame.knownRows or {}
  local addedNewItem = false

  if frame.collapsed then
    for index = 1, #(frame.rows or {}) do
      frame.rows[index]:Hide()
      frame.rows[index]:SetScript("OnMouseUp", nil)
      frame.rows[index]:SetScript("OnEnter", nil)
      frame.rows[index]:SetScript("OnLeave", nil)
      frame.rows[index].itemKey = nil
    end

    frame:SetHeight(20)
    return
  end

  yOffset = yOffset + 4

  for _, group in ipairs(groups) do
    local headerRow = ensureRow(namespace, frame, rowIndex)
    headerRow:SetPoint("TOPLEFT", 0, yOffset)
    headerRow:SetPoint("TOPRIGHT", 0, yOffset)
    headerRow.tick:Hide()
    headerRow.text:SetFontObject(GameFontNormal)
    headerRow.text:SetTextColor(GameFontNormal:GetTextColor())
    headerRow.text:SetText(group.label)
    headerRow.itemKey = nil
    headerRow:Show()
    yOffset = yOffset - 20
    rowIndex = rowIndex + 1

    for _, item in ipairs(group.items) do
      local itemRow = ensureRow(namespace, frame, rowIndex)
      local rowLayout = namespace.TrackerRowStyle.getRowLayout(item.showTick)
      itemRow:SetPoint("TOPLEFT", 0, yOffset)
      itemRow:SetPoint("TOPRIGHT", 0, yOffset)
      itemRow.tick:SetShown(item.showTick)
      itemRow.tick:ClearAllPoints()
      itemRow.tick:SetPoint("LEFT", rowLayout.checkLeftOffset, 0)
      if item.showTick then
        itemRow.text:ClearAllPoints()
        itemRow.text:SetPoint("LEFT", rowLayout.textLeftOffset, 0)
        itemRow.text:SetPoint("RIGHT", -4, 0)
      else
        itemRow.text:ClearAllPoints()
        itemRow.text:SetPoint("LEFT", rowLayout.textLeftOffset, 0)
        itemRow.text:SetPoint("RIGHT", -4, 0)
      end
      itemRow.text:SetFontObject(GameFontHighlight)
      itemRow.text:SetText(item.displayText)
      if item.displayLink and type(GetItemInfo) == "function" then
        local _, _, itemQuality = GetItemInfo(item.displayLink)
        if itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemQuality] then
          local qc = ITEM_QUALITY_COLORS[itemQuality]
          itemRow.text:SetTextColor(qc.r, qc.g, qc.b)
        else
          itemRow.text:SetTextColor(GameFontHighlight:GetTextColor())
        end
      else
        itemRow.text:SetTextColor(GameFontHighlight:GetTextColor())
      end
      itemRow.itemKey = item.itemID
      itemRow:Show()
      itemRow:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and IsShiftKeyDown() then
          namespace.RemoveTrackedItem(item.itemID)
        end
      end)
      local tooltipRef = item.displayLink or item.tooltipRef
      local itemID = item.itemID
      itemRow:SetScript("OnEnter", function(self)
        if GameTooltip then
          GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
          if type(tooltipRef) == "string" and tooltipRef:find("item:") then
            GameTooltip:SetHyperlink(tooltipRef)
          elseif itemID then
            if GameTooltip.SetItemByID then
              GameTooltip:SetItemByID(itemID)
            end
          end
          GameTooltip:Show()
        end
      end)
      itemRow:SetScript("OnLeave", function()
        if GameTooltip then
          GameTooltip:Hide()
        end
      end)

      local uniqueKey = tostring(group.label) .. ":" .. tostring(item.itemID)
      seenKeys[uniqueKey] = true
      if not frame.knownRows[uniqueKey] then
        frame.knownRows[uniqueKey] = true
        addedNewItem = true
      end

      yOffset = yOffset - 20
      rowIndex = rowIndex + 1
    end
  end

  for knownKey in pairs(frame.knownRows) do
    if not seenKeys[knownKey] then
      frame.knownRows[knownKey] = nil
    end
  end

  for index = rowIndex, #(frame.rows or {}) do
    frame.rows[index]:Hide()
    frame.rows[index]:SetScript("OnMouseUp", nil)
    frame.rows[index]:SetScript("OnEnter", nil)
    frame.rows[index]:SetScript("OnLeave", nil)
    frame.rows[index].itemKey = nil
  end

  frame:SetHeight(math.abs(yOffset) + 4)

  if addedNewItem then
    playAddAnimation(frame)
  end
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.TrackerUI = TrackerUI
end

return TrackerUI
