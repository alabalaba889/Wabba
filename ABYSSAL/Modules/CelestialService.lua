-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
-- This is the authoritative gameplay catalog. Visual planet models/effects are separate assets.
local CelestialService = {}
CelestialService.__index = CelestialService

function CelestialService.new(config, authorization)
    return setmetatable({Config=config, Authorization=authorization, Active={}, LastUsed={}}, CelestialService)
end

function CelestialService:GetCatalog()
    return self.Config.Celestials
end

function CelestialService:Activate(player, bodyName, targetPosition)
    if not self.Config.Enabled.CelestialPowers then return false, "FeatureDisabled" end
    if not self.Authorization.IsAdmin(player, self.Config) then return false, "AdminOnly" end
    local body = self.Config.Celestials[bodyName]
    if not body then return false, "UnknownCelestial" end
    if typeof(targetPosition) ~= "Vector3" then return false, "InvalidTargetPosition" end
    if not self.Authorization.IsWithinDistance(player, targetPosition, self.Config.Limits.MaxTargetDistance) then
        return false, "TargetTooFar"
    end
    local key = tostring(player.UserId) .. ":" .. bodyName
    local now = os.clock()
    if now < (self.LastUsed[key] or 0) then return false, "Cooldown" end
    self.LastUsed[key] = now + body.cooldown
    local id = key .. ":" .. tostring(math.floor(now * 1000))
    local record = {id=id, name=bodyName, effect=body.effect, ownerUserId=player.UserId,
        position=targetPosition, startedAt=now, duration=math.clamp(body.duration or 8, 2, self.Config.Limits.MaxEffectDuration)}
    self.Active[id] = record
    -- Bootstrap should broadcast this record to clients for local VFX and invoke a reviewed server effect handler.
    return true, record
end

function CelestialService:Finish(id)
    local record = self.Active[id]
    if not record then return false end
    self.Active[id] = nil
    return true
end

function CelestialService:CleanupPlayer(player)
    local prefix = tostring(player.UserId) .. ":"
    for key in pairs(self.LastUsed) do if string.sub(key, 1, #prefix) == prefix then self.LastUsed[key] = nil end end
    for id, record in pairs(self.Active) do if record.ownerUserId == player.UserId then self.Active[id] = nil end end
end

return CelestialService