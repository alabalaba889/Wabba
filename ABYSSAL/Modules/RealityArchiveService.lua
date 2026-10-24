-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
-- Only changes explicitly registered through this service can be restored.
local RealityArchiveService = {}
RealityArchiveService.__index = RealityArchiveService

local ALLOWED_PROPERTIES = {
    Transparency = true, Color = true, Material = true, Reflectance = true,
    Anchored = true, CanCollide = true, CastShadow = true, Size = true, CFrame = true,
}

function RealityArchiveService.new(maxRecords)
    return setmetatable({MaxRecords=math.clamp(tonumber(maxRecords) or 500, 50, 5000),
        Records={}, Sequence=0}, RealityArchiveService)
end

function RealityArchiveService:RecordProperty(instance, property, newValue, actorUserId)
    if typeof(instance) ~= "Instance" or not instance:IsA("BasePart") then return false, "UnsupportedInstance" end
    if not ALLOWED_PROPERTIES[property] then return false, "UnsupportedProperty" end
    local ok, oldValue = pcall(function() return instance[property] end)
    if not ok then return false, "ReadFailed" end
    self.Sequence += 1
    local record = {id=self.Sequence, instance=instance, property=property, oldValue=oldValue,
        newValue=newValue, actorUserId=actorUserId, timestamp=os.time(), undone=false}
    local setOk = pcall(function() instance[property] = newValue end)
    if not setOk then return false, "WriteFailed" end
    table.insert(self.Records, record)
    while #self.Records > self.MaxRecords do table.remove(self.Records, 1) end
    return true, record.id
end

function RealityArchiveService:Undo(recordId, requesterUserId, isAdmin)
    for i = #self.Records, 1, -1 do
        local record = self.Records[i]
        if record.id == recordId and not record.undone then
            if not record.instance or not record.instance.Parent then return false, "InstanceGone" end
            if not isAdmin and record.actorUserId ~= requesterUserId then return false, "NoPermission" end
            local ok = pcall(function() record.instance[record.property] = record.oldValue end)
            if not ok then return false, "RestoreFailed" end
            record.undone = true
            return true
        end
    end
    return false, "RecordNotFound"
end

function RealityArchiveService:UndoLatestByActor(actorUserId, count, isAdmin)
    count = math.clamp(tonumber(count) or 1, 1, 100)
    local undone = 0
    for i = #self.Records, 1, -1 do
        local record = self.Records[i]
        if undone >= count then break end
        if not record.undone and (isAdmin or record.actorUserId == actorUserId) then
            local ok = self:Undo(record.id, actorUserId, isAdmin)
            if ok then undone += 1 end
        end
    end
    return undone
end

return RealityArchiveService