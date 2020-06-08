require "/vehicles/modularmech/mechpartmanager.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

previewStates = {
  power = "active",
  boost = "idle",
  frontFoot = "preview",
  backFoot = "preview",
  leftArm = "idle",
  rightArm = "idle"
}

function init()
  self.disabledText = config.getParameter("disabledText")
  self.completeText = config.getParameter("completeText")
  self.incompleteText = config.getParameter("incompleteText")

  self.healthFormat = config.getParameter("healthFormat")
  self.bonusHealthFormat = config.getParameter("bonusHealthFormat")
  self.mobilityFormat = config.getParameter("mobilityFormat")
  self.mobilityBoostFormat = config.getParameter("mobilityBoostFormat")
  self.mobilityControlFormat = config.getParameter("mobilityControlFormat")
  self.mobilityJumpFormat = config.getParameter("mobilityJumpFormat")
  self.defenseBoostFormat = config.getParameter("defenseBoostFormat")    
  self.energyBoostFormat = config.getParameter("energyBoostFormat")  
  self.fuelBonusFormat = config.getParameter("fuelBonusFormat") 
  self.energyFormat = config.getParameter("energyFormat")
  self.drainFormat = config.getParameter("drainFormat")
  self.massFormat = config.getParameter("massFormat")
  self.imageBasePath = config.getParameter("imageBasePath")
  
  local getUnlockedMessage = world.sendEntityMessage(player.id(), "mechUnlocked")
  self.unlocked = player.getProperty("mechUnlocked", false)
  
  if getUnlockedMessage:finished() and getUnlockedMessage:succeeded() then
    local unlocked = getUnlockedMessage:result()
    if not unlocked then
      self.disabled = true
      widget.setVisible("imgDisabledOverlay", true)
      widget.setButtonEnabled("btnPrevPrimaryColor", false)
      widget.setButtonEnabled("btnNextPrimaryColor", false)
      widget.setButtonEnabled("btnPrevSecondaryColor", false)
      widget.setButtonEnabled("btnNextSecondaryColor", false)
    else
      widget.setVisible("imgDisabledOverlay", false)
    end
  else
    sb.logError("Mech assembly interface unable to check player mech enabled state!")
  end

  self.partManager = MechPartManager:new()

  self.itemSet = {}
  local getItemSetMessage = world.sendEntityMessage(player.id(), "getMechItemSet")
  if getItemSetMessage:finished() and getItemSetMessage:succeeded() then
    self.itemSet = getItemSetMessage:result()
  else
    sb.logError("Mech assembly interface unable to fetch player mech parts!")
  end

  self.primaryColorIndex = 0
  self.secondaryColorIndex = 0
  local getColorIndexesMessage = world.sendEntityMessage(player.id(), "getMechColorIndexes")
  if getColorIndexesMessage:finished() and getColorIndexesMessage:succeeded() then
    local res = getColorIndexesMessage:result()
    self.primaryColorIndex = res.primary
    self.secondaryColorIndex = res.secondary
  else
    sb.logError("Mech assembly interface unable to fetch player mech paint colors!")
  end

  self.previewCanvas = widget.bindCanvas("cvsPreview")
  
  --compat fix added for cosmetic mech parts july 20 2019
  for partType, itemDescriptor in pairs(self.itemSet) do
  --for partType,_ in pairs({rightArm = "", leftArm = "", body = "", booster = "",legs = "", booster_social = "", body_social = "", legs_social = ""}) do
    widget.setItemSlotItem("itemSlot_" .. partType, itemDescriptor)
  end

  widget.setImage("imgPrimaryColorPreview", colorPreviewImage(self.primaryColorIndex))
  widget.setImage("imgSecondaryColorPreview", colorPreviewImage(self.secondaryColorIndex))

  updatePreview()
  updateComplete()
end

function update(dt)

end

function swapItem(widgetName)
  if self.disabled then return end

  local partType = string.sub(widgetName, 10)

  local currentItem = self.itemSet[partType]
  local swapItem = player.swapSlotItem()

  if not swapItem or self.partManager:partConfig(partType, swapItem) then
    player.setSwapSlotItem(currentItem)
    widget.setItemSlotItem(widgetName, swapItem)
    self.itemSet[partType] = swapItem

    itemSetChanged()
  end
end

function itemSetChanged()
  world.sendEntityMessage(player.id(), "setMechItemSet", self.itemSet)
  updatePreview()
  updateComplete()
end

function nextPrimaryColor()
  self.primaryColorIndex = self.partManager:validateColorIndex(self.primaryColorIndex + 1)
  colorSelectionChanged()
end

function prevPrimaryColor()
  self.primaryColorIndex = self.partManager:validateColorIndex(self.primaryColorIndex - 1)
  colorSelectionChanged()
end

function nextSecondaryColor()
  self.secondaryColorIndex = self.partManager:validateColorIndex(self.secondaryColorIndex + 1)
  colorSelectionChanged()
end

function prevSecondaryColor()
  self.secondaryColorIndex = self.partManager:validateColorIndex(self.secondaryColorIndex - 1)
  colorSelectionChanged()
end

function colorSelectionChanged()
  widget.setImage("imgPrimaryColorPreview", colorPreviewImage(self.primaryColorIndex))
  widget.setImage("imgSecondaryColorPreview", colorPreviewImage(self.secondaryColorIndex))
  world.sendEntityMessage(player.id(), "setMechColorIndexes", self.primaryColorIndex, self.secondaryColorIndex)
  updatePreview()
end

function updateComplete()
  if self.disabled then
    widget.setVisible("imgIncomplete", true)
    widget.setText("lblStatus", self.disabledText)
  elseif self.partManager:itemSetComplete(self.itemSet) then
    widget.setVisible("imgIncomplete", false)
    widget.setText("lblStatus", self.completeText)
  else
    widget.setVisible("imgIncomplete", true)
    widget.setText("lblStatus", self.incompleteText)
  end

  for _, partName in ipairs(self.partManager.requiredParts) do
    widget.setVisible("imgMissing_"..partName, not self.itemSet[partName])
  end
end

function colorPreviewImage(colorIndex)
  if colorIndex == 0 then
    return self.imageBasePath .. "paintbar_default.png"
  else
    local img = self.imageBasePath .. "paintbar.png"
    local toColors = self.partManager.paletteConfig.swapSets[colorIndex]
    for i, fromColor in ipairs(self.partManager.paletteConfig.primaryMagicColors) do
      img = string.format("%s?replace=%s=%s", img, fromColor, toColors[i])
    end
    return img
  end
end

function updatePreview()
  -- assemble vehicle and animation config
  local params = self.partManager:buildVehicleParameters(self.itemSet, self.primaryColorIndex, self.secondaryColorIndex)
  local animationConfig = root.assetJson("/vehicles/modularmech/modularmech.animation")
  util.mergeTable(animationConfig, params.animationCustom)

  -- build list of parts to preview
  local previewParts = {}
  for partName, partConfig in pairs(animationConfig.animatedParts.parts) do
    local partImageSet = params.partImages
    if partName:sub(1, 7) == "leftArm" and params.parts.leftArm and params.parts.leftArm.backPartImages then
      partImageSet = util.replaceTag(params.parts.leftArm.backPartImages, "armName", "leftArm")
    elseif partName:sub(1, 7) == "rightArm" and params.parts.rightArm and params.parts.rightArm.backPartImages then
      partImageSet = util.replaceTag(params.parts.rightArm.frontPartImages, "armName", "rightArm")
    end

    if partImageSet[partName] and partImageSet[partName] ~= "" then
      local partProperties = partConfig.properties or {}
      if partConfig.partStates then
        for stateName, stateConfig in pairs(partConfig.partStates) do
          if previewStates[stateName] and stateConfig[previewStates[stateName]] then
            partProperties = util.mergeTable(partProperties, stateConfig[previewStates[stateName]].properties or {})
            break
          end
        end
      end

      if partProperties.image then
        local partImage = "/vehicles/modularmech/" .. util.replaceTag(partProperties.image, "partImage", partImageSet[partName])
        table.insert(previewParts, {
            centered = partProperties.centered,
            zLevel = partProperties.zLevel or 0,
            image = partImage,
            offset = vec2.mul(partProperties.offset or {0, 0}, 8)
          })
      end
    end
  end

  table.sort(previewParts, function(a, b) return a.zLevel < b.zLevel end)

  -- replace directive tags in preview images
  previewParts = util.replaceTag(previewParts, "directives", "")
  for partName, directives in pairs(params.partDirectives) do
    previewParts = util.replaceTag(previewParts, partName.."Directives", directives)
  end

  -- draw preview images
  self.previewCanvas:clear()

  local canvasCenter = vec2.mul(widget.getSize("cvsPreview"), 0.5)

  for _, part in ipairs(previewParts) do
    local pos = vec2.add(canvasCenter, part.offset)
    self.previewCanvas:drawImage(part.image, pos, nil, nil, part.centered)
  end

  if self.partManager:itemSetComplete(self.itemSet) then
    widget.setVisible("lblDrain", true)
    widget.setVisible("lblMass", true)
    
    widget.setVisible("imgHealthBar", true)
    widget.setVisible("lblHealth", true)  
    widget.setVisible("imgEnergyBar", true)
    widget.setVisible("lblEnergy", true)

    local massTotal = (params.parts.body.stats.mechMass or 0) + (params.parts.booster.stats.mechMass or 0) + (params.parts.legs.stats.mechMass or 0) + (params.parts.leftArm.stats.mechMass or 0) + (params.parts.rightArm.stats.mechMass or 0)

    self.defenseBoost = 0
    self.energyBoost = 0
    self.mobilityBoostValue = 0
    self.mobilityControlValue = 0
    self.mobilityJumpValue = 0
    self.fuelCost = 1
    self.fuelBoost = 0
    
	if params.parts.hornName == 'mechdefensefield' then 
	  self.defenseBoost = 50
	elseif params.parts.hornName == 'mechdefensefield2' then 
	  self.defenseBoost = 100
	elseif params.parts.hornName == 'mechdefensefield3' then 
	  self.defenseBoost = 150
	elseif params.parts.hornName == 'mechdefensefield4' then 
	  self.defenseBoost = 200
	elseif params.parts.hornName == 'mechdefensefield5' then 
	  self.defenseBoost = 250
	end    
        --total bonus to health from defense
        self.defenseModifier = self.defenseBoost + (massTotal*2) 
        --compute health/defense
        local healthMax = math.floor(((((150 * (params.parts.body.stats.healthBonus or 1)) + massTotal) * params.parts.body.stats.protection) + (self.defenseModifier or 0)) )
        
	if params.parts.hornName == 'mechenergyfield' then 
	  self.energyBoost = 50
	elseif params.parts.hornName == 'mechenergyfield2' then 
	  self.energyBoost = 100
	elseif params.parts.hornName == 'mechenergyfield3' then 
	  self.energyBoost = 150
	elseif params.parts.hornName == 'mechenergyfield4' then 
	  self.energyBoost = 200
	elseif params.parts.hornName == 'mechenergyfield5' then 
	  self.energyBoost = 250
	end    

	if params.parts.hornName == 'mechchipfeather' then 
	  massTotal = massTotal * 0.4
	  healthMax = healthMax * 0.75
	end	
	if massTotal > 22 then
	  self.energyBoost = self.energyBoost * (massTotal/50)
	end

	if params.parts.hornName == 'mechmobility' then 
	  self.mobilityBoostValue = 10
	  self.mobilityControlValue = 10
	  self.mobilityJumpValue = 0
	elseif params.parts.hornName == 'mechmobility2' then 
	  self.mobilityBoostValue = 20
	  self.mobilityControlValue = 20
	  self.mobilityJumpValue = 0
	elseif params.parts.hornName == 'mechmobility3' then 
	  self.mobilityBoostValue = 30
	  self.mobilityControlValue = 30
	  self.mobilityJumpValue = 0
	elseif params.parts.hornName == 'mechmobility4' then 
	  self.mobilityBoostValue = 40
	  self.mobilityControlValue = 40
	  self.mobilityJumpValue = 0
	elseif params.parts.hornName == 'mechmobility5' then 
	  self.mobilityBoostValue = 50	
	  self.mobilityControlValue = 50
	  self.mobilityJumpValue = 0
	elseif params.parts.hornName == 'mechchipcontrol' then 
	  self.mobilityBoostValue = -20
	  self.mobilityControlValue = 20
	  self.mobilityJumpValue = 20	
	elseif params.parts.hornName == 'mechchipspeed' then 
	  self.mobilityBoostValue = 40
	  self.mobilityControlValue = -20
	  self.mobilityJumpValue = -20		  
	end    

    --compute fuel module bonuses
	if params.parts.hornName == 'mechchipfuel' then 
	  healthMax = healthMax * 0.8
	  self.energyBoost = 300
	elseif params.parts.hornName == 'mechchiprefueler' then
	  self.fuelCost = 0.8
	elseif params.parts.hornName == 'mechchipovercharge' then 
	  self.fuelCost = 2.5
	  self.mobilityBoostValue = 80	  
	end   

    --compute energy
    local energyMax = math.floor(50 + (params.parts.body.energyMax or 0) * (params.parts.body.stats.energyBonus or 1)) +(self.energyBoost)
    
    --compute energy drain
    local energyDrain = params.parts.body.energyDrain + params.parts.leftArm.energyDrain + params.parts.rightArm.energyDrain
    energyDrain = energyDrain * 0.6
    
    --mass affects drain
    massMod = massTotal/200
    
    --final energy drain after modules
    energyDrain = (energyDrain * (1 + massMod)) * (self.fuelCost or 1)

    --check mobility boosts
    local mobilityMax = self.mobilityBoostValue or 0
    local mobilityBoostMax = self.mobilityBoostValue or 0
    local mobilityControlMax = self.mobilityControlValue or 0
    local mobilityJumpMax = self.mobilityJumpValue or 0
    local fuelBonusMax = self.fuelCost or 0
    
    widget.setText("lblHealth", string.format(self.healthFormat, math.floor(healthMax)))
    widget.setText("lblEnergy", string.format(self.energyFormat, math.floor(energyMax)))
    
    --display boost totals if present.
    widget.setVisible("lblModuleBonuses", true)
    widget.setVisible("lblDefenseBoost", true)
    widget.setVisible("lblEnergyBoost", true)
    --widget.setVisible("lblMobility", false)
    widget.setVisible("lblMobilityBoost", true)
    widget.setVisible("lblMobilityControl", true)
    widget.setVisible("lblMobilityJump", true)
    widget.setVisible("lblFuelBonus", true)
    widget.setText("lblDefenseBoost", string.format(self.defenseBoostFormat, math.floor(self.defenseModifier)))
    widget.setText("lblEnergyBoost", string.format(self.energyBoostFormat, math.floor(self.energyBoost)))
    --widget.setText("lblMobility", string.format(self.mobilityFormat, math.floor(mobilityMax)).."%")
    widget.setText("lblMobilityBoost", string.format(self.mobilityBoostFormat, math.floor(mobilityBoostMax)).."%")
    widget.setText("lblMobilityControl", string.format(self.mobilityControlFormat, math.floor(mobilityControlMax)).."%")
    widget.setText("lblMobilityJump", string.format(self.mobilityJumpFormat, math.floor(mobilityJumpMax)).."%")
    widget.setText("lblFuelBonus", string.format(self.fuelBonusFormat, fuelBonusMax))
    widget.setText("lblDrain", string.format(self.drainFormat, energyDrain))
    widget.setText("lblMass", string.format(self.massFormat, massTotal))
  else
    widget.setVisible("imgHealthBar", false)
    widget.setVisible("lblHealth", false)  
    widget.setVisible("lblHealthBonus", false)
    widget.setVisible("lblSpeedPenalty", false)
    widget.setVisible("lblMobility", false)
    widget.setVisible("lblDefenseBoost", false)
    widget.setVisible("lblEnergyBoost", false)
    widget.setVisible("imgEnergyBar", false)
    widget.setVisible("lblEnergyPenalty", false)  
    widget.setVisible("lblEnergy", false)
    widget.setVisible("lblDrain", false)
    widget.setVisible("lblMass", false)
  end
end
