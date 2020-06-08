require "/scripts/vec2.lua"

function init()
  self.pickupRange = config.getParameter("pickupRange")
  self.snapRange = config.getParameter("snapRange")
  self.snapSpeed = config.getParameter("snapSpeed")
  self.snapForce = config.getParameter("snapForce")
  self.restoreBase = config.getParameter("restoreBase",0)
  self.restoreBase2 = config.getParameter("restoreBase2",0)
  self.restorePercentage = config.getParameter("restorePercentage",0)
  self.restorePercentage2 = config.getParameter("restorePercentage2",0)
  self.targetEntity = nil
  self.pickedUp = false
end

function update(dt)
  if self.pickedUp then return end

  if not self.targetEntity then
    findTarget()
  end

  if self.targetEntity then
    if world.entityExists(self.targetEntity) then
      local targetPos = world.entityPosition(self.targetEntity)
      local toTarget = world.distance(targetPos, mcontroller.position())
      local targetDist = vec2.mag(toTarget)
      if targetDist <= self.pickupRange then
      
        if (self.restoreBase > 0) or (self.restorePercentage > 0) then
          world.sendEntityMessage(self.targetEntity, "restoreHealth", self.restoreBase, self.restorePercentage)
        end
        if (self.restoreBase2 > 0) or (self.restorePercentage2 > 0) then
	        world.sendEntityMessage(self.targetEntity, "restoreEnergy", self.restoreBase2, self.restorePercentage2)        
        end

        self.pickedUp = true
        projectile.die()
      else
        mcontroller.approachVelocity(vec2.mul(vec2.div(toTarget, targetDist), self.snapSpeed), self.snapForce)
      end
    else
      self.targetEntity = nil
      mcontroller.setVelocity({0, 0})
    end
  end

  script.setUpdateDelta(self.targetEntity and 1 or 10)
end

function findTarget()
  local candidates = world.entityQuery(mcontroller.position(), self.snapRange, {includedTypes = {"Vehicle"}, boundMode = "position", order = "nearest"})
  for i, eid in ipairs(candidates) do
    if world.entityName(eid) == "modularmech" then
      self.targetEntity = eid
    end
  end
end
