require "/scripts/vec2.lua"

function init()
	initCommonParameters()
end

function initCommonParameters()
	self.energyCost = config.getParameter("energyCost")
	self.energyCostPerSecond = config.getParameter("energyCostPerSecond")
	self.deactiveDelayMax = 0.6
	self.deactiveDelay = 1
	self.deactiveReady = false
end

function uninit()
	deactivate()
end


function applyTechBonus()
	self.bonusDamage = 1 + status.stat("phasetechBonus",0) -- apply bonus from certain items and armor
end

function update(args)
	applyTechBonus()
	if not self.specialLast and args.moves["special1"] then
		attemptActivation()
	end
	self.specialLast = args.moves["special1"]

	if args.moves["primaryFire"] or args.moves["altFire"] or status.resource("energy") <=0 then
		self.deactiveReady = true
	end

	if self.deactiveReady then
		self.deactiveDelay = self.deactiveDelay - args.dt;
		if self.deactiveDelay <= 0 then
			deactivate()
			self.deactiveReady = false
		end
	end

	if self.active then
		status.setResourcePercentage("energyRegenBlock", 1.0)
		if status.resourceLocked("energy") then
			deactivate()
			self.deactiveReady = false
		end
	elseif not self.active and world.getProperty("hide[" .. tostring(entity.id()) .. "]") then
		world.setProperty("hide[" .. tostring(entity.id()) .. "]", nil)
	end
end

function attemptActivation()
	if not self.active then
		activate()
	elseif self.active then
		deactivate()
	end
end

function activate()
	if status.resourceLocked("energy") then return end
	if not self.active then
		status.addPersistentEffect("booster", "phaseattackstat", math.huge)
		world.setProperty("hide[" .. tostring(entity.id()) .. "]", true)
		animator.playSound("activate")
	end

	self.active = true
	self.deactiveDelay = self.deactiveDelayMax
end

function deactivate()
	if self.active then
		status.clearPersistentEffects("booster")
		world.setProperty("hide[" .. tostring(entity.id()) .. "]", nil)
		animator.playSound("deactivate")
	end

	self.active = false
end

function generateSkillEffect()
	status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
end