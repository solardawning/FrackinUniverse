function init()
  script.setUpdateDelta(5)
	if not world.entitySpecies(entity.id()) then return end
  self.movementParams = mcontroller.baseParameters()
  self.protectionBonus = config.getParameter("protectionBonus", 0)
  
  baseValue = config.getParameter("healthBonus",0)*(status.resourceMax("health"))
  baseValue2 = config.getParameter("energyBonus",0)*(status.resourceMax("energy"))
  
  self.tickDamagePercentage = 0.01
  self.tickTime = config.getParameter("tickTime",0)
  self.tickTimer = self.tickTime
  
  self.healthRegen = config.getParameter("healthRegen",0)
  
  self.xiBonus = status.stat("xiBonus") --apply racial bonus effect to results
  self.frEnabled=status.statusProperty("fr_enabled")
	self.species = status.statusProperty("fr_race") or world.entitySpecies(entity.id())
  if not self.frEnabled or ((status.stat("isHerbivore")==1 or status.stat("isRobot")==1 or status.stat("isOmnivore")==1 or status.stat("isSugar")==1) and (not(status.stat("isRadien")==1))) then
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "foodtyperad")
  end
  
  self.didInit=true
end

function update(dt)
	if not self.didInit then init() end
	 if self.frEnabled and (self.species == "radien" or self.species == "novakid" or self.species == "thelusian") then
	   applyEffects()
	   animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
	   animator.setParticleEmitterActive("healing", true)	   
	 else
	   if (self.frEnabled or not self.species == "radien") and (self.tickTimer <= 0) then
	     applyPenalty()
	     animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
	     animator.setParticleEmitterActive("drips", true)	     
	   else
	     self.tickTimer = self.tickTimer - dt
	   end
	 end
end


function applyPenalty()
      self.tickTimer = self.tickTime
      status.applySelfDamageRequest({
	damageType = "IgnoresDef",
	damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
	damageSourceKind = "poison",
	sourceEntityId = entity.id()
      })
      effect.setParentDirectives("fade=806e4f="..self.tickTimer * 0.25)
      mcontroller.controlModifiers({ airJumpModifier = 0.08, speedModifier = 0.08 })    
end

function applyEffects()
    self.appliedHeal = self.healthRegen + self.xiBonus
    self.appliedHunger = 1.08 + self.xiBonus
    status.setPersistentEffects("floranpower1", { {stat = "healthRegen", amount = self.appliedHeal },{stat = "foodDelta", effectiveMultiplier = -self.appliedHunger} })

    --radiens dont get full when near these plants. eat up!
    if status.isResource("food") then
		self.foodValue = status.resourcePercentage("food")
	else
		self.foodValue = 0.50
	end
    status.removeEphemeralEffect("wellfed")
	if status.isResource("food") then
		if status.resourcePercentage("food") > 0.99 then status.setResourcePercentage("food", 0.99) end
	end
end

function uninit()
  status.clearPersistentEffects("floranpower1")
  animator.setParticleEmitterActive("drips", false)  
end
