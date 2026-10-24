-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
-- Portals are registered server-side; clients must never choose arbitrary destinations.
local HttpService = game:GetService("HttpService")
local PortalService = {}
PortalService.__index = PortalService

function PortalService.new(config, authorization)
    return setmetatable({Config=config, Authorization=authorization, Portals={}, ByOwner={}}, PortalService)
end

function PortalService:Create(owner, entranceCFrame, exitCFrame, lifetime)
    if not self.Config.Enabled.Portals then return nil, "FeatureDisabled" end
    if not owner or typeof(entranceCFrame) ~= "CFrame" or typeof(exitCFrame) ~= "CFrame" then
        return nil, "InvalidPortal"
    end
    local list = self.ByOwner[owner.UserId] or {}
    if #list >= self.Config.Limits.MaxActivePortalsPerPlayer then return nil, "PortalLimit" end
    lifetime = math.clamp(tonumber(lifetime) or 0, 0, 3600) -- 0 means manually closed
    local id = HttpService:GenerateGUID(false)
    local record = {id=id, ownerUserId=owner.UserId, entrance=entranceCFrame,
        exit=exitCFrame, expiresAt=(lifetime > 0 and os.clock()+lifetime or nil), enabled=true}
    self.Portals[id] = record
    table.insert(list, id)
    self.ByOwner[owner.UserId] = list
    return record
end

function PortalService:Get(id)
    local record = self.Portals[id]
    if not record or not record.enabled then return nil end
    if record.expiresAt and os.clock() >= record.expiresAt then
        self:Close(id)
        return nil
    end
    return record
end

function PortalService:Traverse(player, id, character)
    local record = self:Get(id)
    if not record then return false, "PortalUnavailable" end
    if not player or not character or player.Character ~= character then return false, "InvalidCharacter" end
    if player.UserId ~= record.ownerUserId and not self.Authorization.IsAdmin(player, self.Config) then
        return false, "NoPermission"
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false, "NoRoot" end
    local destination = record.exit + Vector3.new(0, 3, 0)
    character:PivotTo(CFrame.new(destination.Position, destination.Position + record.exit.LookVector))
    return true
end

function PortalService:Close(id)
    local record = self.Portals[id]
    if not record then return false end
    record.enabled = false
    self.Portals[id] = nil
    local list = self.ByOwner[record.ownerUserId] or {}
    for i = #list, 1, -1 do if list[i] == id then table.remove(list, i) end end
    return true
end

function PortalService:CloseOwnedBy(player)
    local list = table.clone(self.ByOwner[player.UserId] or {})
    for _, id in ipairs(list) do self:Close(id) end
    self.ByOwner[player.UserId] = nil
end

return PortalService