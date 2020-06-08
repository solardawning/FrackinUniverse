setName="fu_krakenset"

armorBonus2={
	{stat = "critChance", amount = 4},
	{stat = "powerMultiplier", effectiveMultiplier = 1.15}
}

armorBonus={
	{stat = "sulphuricImmunity", amount = 1},
	{stat = "gasImmunity", amount = 1},
	{stat = "poisonStatusImmunity", amount = 1},
	{stat = "biooozeImmunity", amount = 1},
	{stat = "breathProtection", amount = 1}
}

require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
	setSEBonusInit(setName)

	effectHandlerList.armorBonusHandle=effect.addStatModifierGroup(armorBonus)
	effectHandlerList.armorBonus2Handle=effect.addStatModifierGroup({})
	checkBiome()
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		status.removeEphemeralEffect("swimboost2")
		effect.expire()
	else
		status.addEphemeralEffect("swimboost2")
		checkBiome()
	end

end

function checkBiome()
	if checkBiome({"ocean","sulphuricocean","aethersea","nitrogensea","strangesea","tidewater"}) then
		effect.setStatModifierGroup(effectHandlerList.armorBonus2Handle,armorBonus2)
		mcontroller.controlModifiers({speedModifier = 1.05})
	else
		effect.setStatModifierGroup(effectHandlerList.armorBonus2Handle,{})
	end
end