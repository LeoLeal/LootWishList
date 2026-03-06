local ItemResolver = {}

function ItemResolver.getWishlistKey(itemData)
  if itemData == nil then
    return nil
  end

  local itemId = itemData.itemID or itemData.itemId or itemData.id
  if itemId == nil then
    return nil
  end

  return "item:" .. tostring(itemId)
end

function ItemResolver.getItemIdFromLink(itemLink)
  if type(itemLink) ~= "string" then
    return nil
  end

  local itemId = itemLink:match("item:(%d+)")
  if itemId == nil then
    return nil
  end

  return tonumber(itemId)
end

function ItemResolver.normalizeItemData(itemData)
  if itemData == nil then
    return nil
  end

  local itemId = itemData.itemID or itemData.itemId or ItemResolver.getItemIdFromLink(itemData.itemLink)
  if itemId == nil then
    return nil
  end

  return {
    itemID = itemId,
    wishlistKey = ItemResolver.getWishlistKey({ itemID = itemId }),
    itemLink = itemData.itemLink,
    itemName = itemData.itemName,
    itemLevel = itemData.itemLevel,
    instanceName = itemData.instanceName,
  }
end

function ItemResolver.getTooltipRef(item)
  if item == nil then
    return nil
  end

  if type(item.itemLink) == "string" and item.itemLink ~= "" then
    return item.itemLink
  end

  local itemId = item.itemID or item.itemId or item.id
  if itemId ~= nil then
    return "item:" .. tostring(itemId)
  end

  return nil
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.ItemResolver = ItemResolver
end

return ItemResolver
