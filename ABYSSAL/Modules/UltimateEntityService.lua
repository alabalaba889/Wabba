-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
local UltimateEntityService = {}
UltimateEntityService.__index = UltimateEntityService
local STATES = {Dormant=true, Summoning=true, Following=true, Attacking=true, Commanded=true, Rewriting=true, Dismissed=true}

function UltimateEntityService.new(config, authorization)
    return setmetatable({Config=config, Authorization=authorization, Entities={}}, UltimateEntityService)
end

function UltimateEntityService:Summon(player, model)
    if not self.Authorization.IsAdmin(player, self.Config) then return false, "AdminOnly" end
    if not model or not model:IsA("Model") or not model.PrimaryPart then return false, "InvalidEntityModel" end
    local id = tostring(player.UserId)
    if self.Entities[id] then return false, "EntityAlreadyActive" end
    local entity = model:Clone()
    entity.Name = "ABYSSAL_Entity_" .. id
    entity:SetAttribute("ABYSSALOwnerUserId", player.UserId)
    entity:SetAttribute("ABYSSALState", "Summoning")
    entity.Parent = workspace
    local root = self.Authorization.GetRoot(player)
    if root then entity:PivotTo(root.CFrame * CFrame.new(5, 0, -8)) end
    self.Entities[id] = {ownerUserId=player.UserId, model=entity, state="Summoning", target=nil}
    return true, id
end

function UltimateEntityService:SetState(player, state, target)
    if not self.Authorization.IsAdmin(player, self.Config) then return false, "AdminOnly" end
    if not STATES[state] then return false, "InvalidState" end
    local record = self.Entities[tostring(player.UserId)]
    if not record or not record.model.Parent then return false, "NoActiveEntity" end
    if target ~= nil and not self.Authorization.IsValidTarget(player, target, self.Config.Limits.MaxTargetDistance) then
        return false, "InvalidTarget"
    end
    record.state = state
    record.target = target
    record.model:SetAttribute("ABYSSALState", state)
    if state == "Dismissed" then
        record.model:Destroy()
        self.Entities[tostring(player.UserId)] = nil
    end
    -- Actual pathfinding, combat animation, and reality-editing behavior must be implemented as reviewed state handlers.
    return true
end

function UltimateEntityService:CleanupPlayer(player)
    local key = tostring(player.UserId)
    local record = self.Entities[key]
    if record and record.model then record.model:Destroy() end
    self.Entities[key] = nil
end

return UltimateEntityService