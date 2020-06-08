require "/stats/effects/fu_armoreffects/setbonuses_common.lua"
require "/scripts/vec2.lua"

armorBonus={
	{stat = "maxHealth", effectiveMultiplier = 1.25},
	{stat = "powerMultiplier", effectiveMultiplier = 1.15}
}

armorEffect={
	{stat = "sulphuricImmunity", amount = 1},
	{stat = "poisonStatusImmunity", amount = 1}
}

setName="fu_corruptset"

function init()
	setSEBonusInit(setName)
	effectHandlerList.armorEffectHandle=effect.addStatModifierGroup(armorEffect)

	effectHandlerList.armorBonusHandle=effect.addStatModifierGroup({})
	checkArmor()
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		status.removeEphemeralEffect("scouteyecultistblast")
		effect.expire()
	else
		status.addEphemeralEffect("scouteyecultistblast")
		checkArmor()
	end
end

function checkArmor()
	if checkBiome({"lightless","penumbra","aethersea","moon_shadow"."shadow","midnight"}) then
		effect.setStatModifierGroup(effectHandlerList.armorBonusHandle,armorBonus)
	else
		effect.setStatModifierGroup(effectHandlerList.armorBonusHandle,{})
	end
end
