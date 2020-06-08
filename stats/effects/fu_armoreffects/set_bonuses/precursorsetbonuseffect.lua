require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

weaponBonus={
	{stat = "powerMultiplier", effectiveMultiplier = 1.15}
}

armorBonus={
	{stat = "breathProtection", amount = 1},
	{stat = "critChance", amount = 5},
	{stat = "pressureProtection", amount = 1},
	{stat = "extremepressureProtection", amount = 1}
}

setName="fu_precursorset"

function init()	
	setSEBonusInit("fu_precursorset")
	effect.setParentDirectives("fade=F1EA9C;0.00?border=0;F1EA9C00;00000000")
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
	local weaponSword=weaponCheck({"energy","precursor"})
	local weaponShield=weaponCheck({"energy","precursor"})

	if weaponSword["either"] or weaponShield["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
	end
end