require("/scripts/vec2.lua")
require("/scripts/FRHelper.lua")

local FR_old_init = init
local FR_old_update = update

function init()
	FR_old_init()
	self.lastYPosition = 0
	self.lastYVelocity = 0
	self.fallDistance = 0

	message.setHandler("FR_getSpecies", function() return self.species end)
end

function update(dt)
	FR_old_update(dt)
	self.isNpc=world.isNpc(entity.id())
	local enabled = status.statusProperty("fr_enabled")
	local race = enabled and status.statusProperty("fr_race") or "_default"
	if enabled == nil then
		status.setStatusProperty("fr_enabled", true)
		race = world.entitySpecies(entity.id())
		status.setStatusProperty("fr_race", race)
	end
	
	if not self.helper or not self.species or self.species ~= race then
		-- If we've done this before, then we're switching races and need to clear these
		if self.helper then
			for _, eff in pairs(self.helper.speciesConfig.special or {}) do
				status.removeEphemeralEffect(eff)
			end
			self.helper:clearPersistent()
		end

		self.species = race
		self.helper = FRHelper:new(self.species, world.entityGender(entity.id()))
		
		-- Script setup
		for map,path in pairs(self.helper.frconfig.scriptMaps) do
			if self.helper.speciesConfig[map] then
				self.helper:loadScript({script=path, args=self.helper.speciesConfig[map]})
			end
		end
		for _,script in pairs(self.helper.speciesConfig.scripts or {}) do
			self.helper:loadScript(script)
		end
		
		-- Apply the persistent effect
		status.setPersistentEffects("FR_racialStats", self.helper.speciesConfig.stats or {})
		
		-- Add any other special effects
		if self.helper.speciesConfig.special then
			for _,thing in pairs(self.helper.speciesConfig.special) do
				status.addEphemeralEffect(thing,math.huge)
			end
		end	
		
		if self.isNpc then
			status.addEphemeralEffect("frnpcspecialhandler",math.huge)
		end
	end
	
	-- Update stuff
	--self.helper:clearPersistent()
	self.helper:applyControlModifiers()
	self.helper:runScripts("racialscript", self, dt)
	
	-- Breath handling
	if entity.entityType() ~= "npc" then
		local mouthPosition = vec2.add(mcontroller.position(), status.statusProperty("mouthPosition"))
		if status.statPositive("breathProtection") or world.breathable(mouthPosition)
			or status.statPositive("waterbreathProtection") and world.liquidAt(mouthPosition)
			then
			status.modifyResource("breath", status.stat("breathRegenerationRate") * dt)
		else
			status.modifyResource("breath", -status.stat("breathDepletionRate") * dt)
		end
	end
end
