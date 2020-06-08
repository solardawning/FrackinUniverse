function init()
  script.setUpdateDelta(20)
  self.tickTime = 3.0
  self.tickTimer = self.tickTime
  self.baseTime = setEffectTime()
  activateVisualEffects()
  
  effect.addStatModifierGroup({
      { stat = "fallDamageMultiplier", amount = -0.5 },
      { stat = "cosmicResistance", amount = -0.25 },
      { stat = "grit", effectiveMultiplier = 0 }
  })    
end

function setEffectTime()
  return self.tickTimer * math.min(1 - status.stat("poisonResistance",0), 0.45)
end

function activateVisualEffects()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  if entity.entityType()=="player" then
  local statusTextRegion = { 0, 1, 0, 1 }
  animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)
  animator.burstParticleEmitter("statustext")
  end
end

function deactivateVisualEffects()
  animator.setParticleEmitterActive("drips", false)
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
  end

  if ( status.stat("poisonResistance",0)  >= 0.50 ) and ( status.stat("radioactiveResistance",0)  >= 0.25 ) then
    deactivateVisualEffects()
    effect.expire()
  end

  effect.setParentDirectives("fade=EEEEEE="..self.tickTimer * 0.4)

end

function uninit()

end
