require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

setName="fu_cuteset"

weaponBonus={
	{stat = "powerMultiplier", effectiveMultiplier = 1.20}
}

armorBonus={
	{stat = "shadowImmunity", amount = 1}
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
		checkWeapons()
	end
end

function checkWeapons()
	local weapons=weaponCheck({"energy"})
	if weapons["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
		return true
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
		return false
	end
end
