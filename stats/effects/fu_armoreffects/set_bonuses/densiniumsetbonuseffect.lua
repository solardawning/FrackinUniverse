require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

setName="fu_densiniumset"

weaponBonus={
	{stat = "critChance", amount = 3},
	{stat = "powerMultiplier", effectiveMultiplier = 1.25}
}

armorBonus={
	{stat = "breathProtection", amount = 1},
	{stat = "poisonStatusImmunity", amount = 1},
	{stat = "extremepressureProtection", amount = 1},	
	{stat = "pressureProtection", amount = 1},
	{stat = "gasImmunity", amount = 1}
}

function init()
	setSEBonusInit(setName)
	effectHandlerList.weaponBonusHandle=effect.addStatModifierGroup({})
			
	checkWeapons()

	effectHandlerList.armorBonusHandle=effect.addStatModifierGroup(armorBonus)
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		effect.expire()
	else
		effect.setStatModifierGroup(effectHandlerList.armorBonusHandle,armorBonus)
		checkWeapons()
	end
end

function checkWeapons()
	local weapons=weaponCheck({"densinium"})
	
	if weapons["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
	end
end