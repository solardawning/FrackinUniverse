require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

weaponBonus={
	{stat = "critChance", amount = 3.5},
	{stat = "maxHealth", effectiveMultiplier = 1.25}
}


armorBonus={
	{stat = "shadowImmunity", amount = 1},
	{stat = "gasImmunity", amount = 1},
	{stat = "ffextremeradiationImmunity", amount = 1},
	{stat = "biomeradiationImmunity", amount = 1},
	{stat = "radiationburnImmunity", amount = 1},
	{stat = "breathAmount", baseMultiplier = 3.50}
}


setName="fu_necroset"


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
	local weaponSword=weaponCheck({"elder","precursor"})

	if weaponSword["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
	end
end