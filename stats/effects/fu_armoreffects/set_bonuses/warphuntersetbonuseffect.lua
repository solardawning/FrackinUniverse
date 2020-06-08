require "/stats/effects/fu_armoreffects/setbonuses_common.lua"
require "/scripts/unifiedGravMod.lua"

setName="fu_warphunterset"
setEffects={"gravitynormalizationarmor"}

weaponBonus={
	{stat = "powerMultiplier", effectiveMultiplier = 3.4}
}

armorBonus={
	{stat = "protoImmunity", amount = 1.0},
	{stat = "fireStatusImmunity", amount = 1.0},
	{stat = "gasImmunity", amount = 1.0},
	{stat = "iceslipImmunity", amount = 1.0},
	{stat = "pressureProtection", amount = 1},
	{stat = "extremepressureProtection", amount = 1},		
	{stat = "breathProtection", amount = 1},
	{stat = "gravrainImmunity", amount = 1}
}

setName="fu_warphunterset"

function init()
	setSEBonusInit("fu_warphunterset",setEffects)
	effect.setParentDirectives("fade=F1EA9C;0.00?border=0;F1EA9C00;00000000")
	
	setSEBonusInit(setName)
	effectHandlerList.weaponBonusHandle=effect.addStatModifierGroup({})

	checkWeapons()
	applySetEffects()

	effectHandlerList.armorBonusHandle=effect.addStatModifierGroup(armorBonus)
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		status.removeEphemeralEffect("gravitynormalizationarmor")
		effect.expire()
	else
		checkWeapons()
		status.addEphemeralEffect("gravitynormalizationarmor")
	end
end

function checkWeapons()
	local weapons=weaponCheck({"mininglaser"})
	
	if (weapons["either"] and weapons["twoHanded"]) or (weapons["primary"] and weapons["alt"]) then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
	elseif weapons["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,setBonusMultiply(weaponBonus,0.25))
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
	end
end
