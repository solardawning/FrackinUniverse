function init()
  activateVisualEffects()
end

function update(dt)

end

function activateVisualEffects()
if entity.entityType()=="player" then
  local statusTextRegion = { 0, 1, 0, 1 }
  animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)
  animator.burstParticleEmitter("statustext")
  end
end

function uninit()

end