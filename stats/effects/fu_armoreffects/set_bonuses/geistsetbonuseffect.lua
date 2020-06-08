setName="fu_geistset"

weaponBonus={
	{stat = "critChance", amount = 1.5}
}

armorEffect={
	{stat = "maxHealth", effectiveMultiplier = 1.25},
	{stat = "sulphuricImmunity", amount = 1},
	{stat = "breathProtection", amount = 1}
}

require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
	setSEBonusInit(setName)
	effectHandlerList.weaponBonusHandle=effect.addStatModifierGroup({})

	checkWeapons()
	effectHandlerList.armorEffectHandle=effect.addStatModifierGroup(armorEffect)
end

function update(dt)
	if not checkSetWorn(self.setBonusCheck) then
		effect.expire()
	else
		
		checkWeapons()
	end
end

function checkWeapons()
	local weapons=weaponCheck({"dagger","broadsword","axe","hammer","shortsword","greataxe","spear","shortspear","quarterstaff","katana","flail","scythe","mace","longsword","daikatana"})
	
	if (weapons["either"] and weapons["twoHanded"]) or (weapons["primary"] and weapons["alt"]) then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,setBonusMultiply(weaponBonus,2))
	elseif weapons["either"] then
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,weaponBonus)
	else
		effect.setStatModifierGroup(effectHandlerList.weaponBonusHandle,{})
	end
end