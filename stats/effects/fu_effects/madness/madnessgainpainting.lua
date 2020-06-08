function init()
	self.applyToTypes = {"player", "npc"}
	self.baseValue = config.getParameter("baseValue")
	self.valBonus = config.getParameter("valBonus") - ((config.getParameter("mentalProtection") or 0) * 10)
	self.timer = 10
	self.afk = 0
	self.myspeed = 0
	animator.setParticleEmitterOffsetRegion("insane", mcontroller.boundBox())
	animator.setParticleEmitterEmissionRate("insane", config.getParameter("emissionRate", 3))
	animator.setParticleEmitterActive("insane", true)
	activateVisualEffects()

	effect.addStatModifierGroup({{stat = "madnessModifier", amount = (status.stat("madnessModifier") or 0) * 1.25}})  

	script.setUpdateDelta(3)
end

function allowedType()
	local entityType = entity.entityType()
	for _,applyType in ipairs(self.applyToTypes) do
		if entityType == applyType then
			return true
		end
	end
end

function update(dt)
	self.timer = self.timer - dt
	if (status.stat("maxEnergy")) then
		if (self.timer <= 0) then
		self.healthDamage = ((math.max(1.0 - status.stat("mentalProtection"),0))*10) + status.stat("madnessModifier")
		self.timer = 30
		self.totalValue = self.baseValue + self.valBonus + math.random(1,6)
		self.myspeed = mcontroller.xVelocity() --check speed, dont drop madness if we are afking
			if  entity.entityType() =="player" then
				if self.myspeed < 5 then
					if self.afk > 2000 then -- do not go higher than this value
						self.afk = 2000 
					end
					self.afk = self.afk + 1
					world.spawnItem("fumadnessresource",entity.position(),self.totalValue)
					animator.playSound("madness")
					activateVisualEffects()
					status.applySelfDamageRequest({
						damageType = "IgnoresDef",
						damage = self.healthDamage,
						damageSourceKind = "shadow",
						sourceEntityId = entity.id()
					})          
				else
					self.afk = self.afk -50  --movement decrements the penalty
					if self.afk < 1 then
						self.afk = 0
					end
				end       
			end
		end
	else
		effect.expire()
	end
end


function activateVisualEffects()
	effect.setParentDirectives("fade=765e72=0.4")
	if entity.entityType()=="player" then
		local statusTextRegion = { 0, 1, 0, 1 }
		animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)
		animator.burstParticleEmitter("statustext")
	end
end


function uninit()

end