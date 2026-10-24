-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
-- Dimensions are bounded regions in the same server, not separate servers.
local HttpService = game:GetService("HttpService")
local DimensionService = {}
DimensionService.__index = DimensionService

function DimensionService.new(config, authorization, workspaceService)
    return setmetatable({Config=config, Authorization=authorization,
        Workspace=workspaceService or workspace, Dimensions={}, ByOwner={}}, DimensionService)
end

function DimensionService:Create(owner, center, size, mode)
    if not self.Config.Enabled.Dimensions then return nil, "FeatureDisabled" end
    if not owner or typeof(center) ~= "Vector3" or typeof(size) ~= "Vector3" then return nil, "InvalidBounds" end
    local list = self.ByOwner[owner.UserId] or {}
    if #list >= self.Config.Limits.MaxDimensionsPerPlayer then return nil, "DimensionLimit" end
    size = Vector3.new(
        math.clamp(size.X, 32, 512),
        math.clamp(size.Y, 24, 256),
        math.clamp(size.Z, 32, 512)
    )
    local id = HttpService:GenerateGUID(false)
    local folder = Instance.new("Folder")
    folder.Name = "ABYSSAL_Dimension_" .. id
    folder:SetAttribute("DimensionId", id)
    folder:SetAttribute("OwnerUserId", owner.UserId)
    folder:SetAttribute("Mode", (mode == "Combat" or mode == "Mirror" or mode == "Creative") and mode or "Personal")
    folder.Parent = self.Workspace
    local region = Instance.new("Part")
    region.Name = "Boundary"
    region.Anchored = true
    region.CanCollide = false
    region.Transparency = 1
    region.Size = size
    region.CFrame = CFrame.new(center)
    region:SetAttribute("ABYSSALManaged", true)
    region.Parent = folder
    local record = {id=id, ownerUserId=owner.UserId, folder=folder, boundary=region,
        center=center, size=size, members={[owner.UserId]=true}, createdAt=os.time(), changeLog={}}
    self.Dimensions[id] = record
    table.insert(list, id)
    self.ByOwner[owner.UserId] = list
    return record
end

function DimensionService:CanEnter(player, id)
    local record = self.Dimensions[id]
    if not record or not record.folder.Parent then return false end
    return record.ownerUserId == player.UserId or self.Authorization.IsAdmin(player, self.Config)
        or record.members[player.UserId] == true
end

function DimensionService:Enter(player, id)
    local record = self.Dimensions[id]
    if not record or not self:CanEnter(player, id) then return false, "NoAccess" end
    local root = self.Authorization.GetRoot(player)
    if not root then return false, "NoCharacter" end
    record.members[player.UserId] = true
    local destination = record.center + Vector3.new(0, math.max(5, record.size.Y/2 - 3), 0)
    player.Character:PivotTo(CFrame.new(destination))
    return true
end

function DimensionService:Remove(id, requester)
    local record = self.Dimensions[id]
    if not record then return false end
    if requester and requester.UserId ~= record.ownerUserId and not self.Authorization.IsAdmin(requester, self.Config) then
        return false
    end
    record.folder:Destroy()
    self.Dimensions[id] = nil
    local list = self.ByOwner[record.ownerUserId] or {}
    for i = #list, 1, -1 do if list[i] == id then table.remove(list, i) end end
    return true
end

return DimensionService