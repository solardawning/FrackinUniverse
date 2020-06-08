require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

setName="fu_darkmatterset"

armorBonus={
	{stat = "critDamage", amount = 0.5},
	{stat = "darknessImmunity", amount = 1}
}

function init()
	setSEBonusInit(setName)
	effectHandlerList.armorBonusHandle=effect.addStatModifierGroup(armorBonus)
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		effect.expire()
	else
		setRegen(0.004)
	end
end
