local TrackerModel = {}

local function compareGroupLabels(otherLabel, left, right)
  if left == right then
    return false
  end

  if left == otherLabel then
    return false
  end

  if right == otherLabel then
    return true
  end

  return left < right
end

local function buildDisplayText(item)
  local prefix = item.isPossessed == true and "" or "- "

  if item.bestLootedItemLevel ~= nil then
    return string.format("%s%s (%s)", prefix, item.itemName, tostring(item.bestLootedItemLevel))
  end

  return prefix .. item.itemName
end

function TrackerModel.buildGroups(items, otherLabel)
  local groupsByLabel = {}
  otherLabel = otherLabel or "Other"

  for _, item in ipairs(items) do
    local label = item.groupLabel or "Other"
    if groupsByLabel[label] == nil then
      groupsByLabel[label] = {
        label = label,
        items = {},
      }
    end

    table.insert(groupsByLabel[label].items, {
      itemID = item.itemID,
      itemName = item.itemName,
      displayText = buildDisplayText(item),
      showTick = item.isPossessed == true,
      bestLootedItemLevel = item.bestLootedItemLevel,
      groupLabel = label,
      tooltipRef = item.tooltipRef,
      displayLink = item.displayLink,
    })
  end

  local labels = {}
  for label in pairs(groupsByLabel) do
    table.insert(labels, label)
  end

  table.sort(labels, function(left, right)
    return compareGroupLabels(otherLabel, left, right)
  end)

  local orderedGroups = {}
  for _, label in ipairs(labels) do
    table.insert(orderedGroups, groupsByLabel[label])
  end

  return orderedGroups
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.TrackerModel = TrackerModel
end

return TrackerModel
