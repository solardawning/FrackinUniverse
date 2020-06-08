function init()
	tryRun()
	script.setUpdateDelta(1)
end

function update(dt)
	tryRun()
end

function tryRun()
	if world.entityType(entity.id()) == "player" then
		handleDarkStats()
		animator.setParticleEmitterActive("smoke", thisCanRun())
	end
end

function uninit()
	if world.entityType(entity.id()) == "player" then
		animator.setParticleEmitterActive("smoke", false)
		handleDarkStats(true)
	end
end

function handleDarkStats(terminate)
	darklevel=config.getParameter("darklevel",1)
	darkpriority=config.getParameter("darkpriority",1)

	if not terminate then
		local dP=status.statusProperty("darkpriority") or 0
		local dL=status.statusProperty("darklevel") or 0
		if dL<darklevel then
			status.setStatusProperty("darklevel",darklevel)
			dL=darklevel
			status.setStatusProperty("darkpriority",darklevel)
			dP=darkpriority
		end
		if dP<darkpriority then
			status.setStatusProperty("darkpriority",darklevel)
			dP=darkpriority
		end
	else
		status.setStatusProperty("darkpriority",0)
		status.setStatusProperty("darklevel",0)
	end
end

function thisCanRun()
	local dP=status.statusProperty("darkpriority") or 0
	local dL=status.statusProperty("darklevel") or 0
	return ((dP==darkpriority) and (dL==darklevel))
end