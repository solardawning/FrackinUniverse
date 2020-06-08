function init()
	script.setUpdateDelta(5)
	if not world.entityType(entity.id()) then return end
	animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
	animator.setParticleEmitterActive("drips", true)
	effect.setParentDirectives("fade=300030=0.8")
	baseHandler=effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = -0.20}
	})
	bonusHandler=effect.addStatModifierGroup({})
	self.healingRate = 1
	self.frEnabled=status.statusProperty("fr_enabled")
	self.species = status.statusProperty("fr_race") or world.entitySpecies(entity.id())
	self.didInit=true
end

function update(dt)
	if not self.didInit then init() end

	if self.frEnabled and (self.species == "glitch") then
		self.healingRate = 0.015
		effect.setStatModifierGroup(bonusHandler,{{stat="healthRegen",amount=status.stat("maxHealth")*self.healingRate}})
		--status.modifyResourcePercentage("health", self.healingRate * dt)

		--sb.logInfo("tarslow")
		mcontroller.controlModifiers({
			groundMovementModifier = 1,
			speedModifier = 1,
			airJumpModifier = 1,
			liquidImpedance = 0.01
		})
	else
		mcontroller.controlModifiers({
			groundMovementModifier = 0.5,
			speedModifier = 0.65,
			airJumpModifier = 0.80
		})        
	end

end

function uninit()
	if bonusHandler then
		effect.removeStatModifierGroup(bonusHandler)
	end
	if baseHandler then
		effect.removeStatModifierGroup(baseHandler)
	end
end