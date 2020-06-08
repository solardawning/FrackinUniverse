require "/stats/effects/fu_armoreffects/setbonuses_common.lua"
require "/scripts/unifiedGravMod.lua"

setName="fu_spacefarerset2"

weaponList={"mininglaser"}

weaponBonus={
	{stat = "powerMultiplier", effectiveMultiplier = 2.4}
}

armorBonus={
	{stat = "protoImmunity", amount = 1.0},
	{stat = "fireStatusImmunity", amount = 1.0},
	{stat = "gasImmunity", amount = 1.0},
	{stat = "iceslipImmunity", amount = 1.0},
	{stat = "pressureProtection", amount = 1},
	{stat = "extremepressureProtection", amount = 1},		
	{stat = "breathProtection", amount = 1},
	{stat = "defensetechBonus", amount = 0.5},
}

setName="fu_spacefarerset2"

function init()
	setSEBonusInit("fu_spacefarerset2")
	effect.setParentDirectives("fade=F1EA9C;0.00?border=0;F1EA9C00;00000000")
	
	setSEBonusInit(setName)
	effectHandlerList.weaponBonusHandle=effect.addStatModifierGroup({})

	checkWeapons()
	effectHandlerList.armorBonusHandle=effect.addStatModifierGroup(armorBonus)

end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		status.removeEphemeralEffect("gravitynormalizationarmor")
		effect.expire()
	else
		status.addEphemeralEffect("gravitynormalizationarmor")
		checkWeapons()
	end
end

function checkWeapons()
	local weapons=weaponCheck({"mininglaser"})
	if weapons["primary"] and weapons["alt"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
	elseif weapons["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,setBonusMultiply(weaponBonus,0.25))
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
	end
end
