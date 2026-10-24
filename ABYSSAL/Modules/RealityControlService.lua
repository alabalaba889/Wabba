-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
-- Gameplay simulation only. No global server pause or unrestricted Workspace mutation.
local RealityControlService = {}
RealityControlService.__index = RealityControlService

function RealityControlService.new(config, authorization, archive)
    return setmetatable({Config=config, Authorization=authorization, Archive=archive, ActiveEffects={}}, RealityControlService)
end

function RealityControlService:CreateGravityZone(player, center, radius, duration, strength)
    if not self.Config.Enabled.RealityControl then return false, "FeatureDisabled" end
    if not self.Authorization.IsAdmin(player, self.Config) then return false, "AdminOnly" end
    if typeof(center) ~= "Vector3" or not self.Authorization.IsWithinDistance(player, center, self.Config.Limits.MaxTargetDistance) then
        return false, "InvalidCenter"
    end
    radius = math.clamp(tonumber(radius) or 30, 8, 100)
    duration = math.clamp(tonumber(duration) or 5, 1, self.Config.Limits.MaxEffectDuration)
    strength = math.clamp(tonumber(strength) or 1, -3, 3)
    local id = tostring(player.UserId) .. ":" .. tostring(math.floor(os.clock() * 100000))
    self.ActiveEffects[id] = {id=id, kind="GravityZone", center=center, radius=radius,
        duration=duration, strength=strength, ownerUserId=player.UserId, expiresAt=os.clock()+duration}
    return true, self.ActiveEffects[id]
end

function RealityControlService:CreateFrozenFrame(player, targetModel, duration)
    if not self.Config.Enabled.RealityControl then return false, "FeatureDisabled" end
    if not self.Authorization.IsAdmin(player, self.Config) then return false, "AdminOnly" end
    if not self.Authorization.IsValidTarget(player, targetModel, self.Config.Limits.MaxTargetDistance) then
        return false, "InvalidTarget"
    end
    local humanoid = self.Authorization.GetLivingHumanoid(targetModel)
    local root = targetModel:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false, "InvalidTarget" end
    duration = math.clamp(tonumber(duration) or 2, 0.25, 4)
    -- This is a limited character freeze. It does not stop server simulation globally.
    local record = {kind="FrozenFrame", target=targetModel, humanoid=humanoid,
        oldWalkSpeed=humanoid.WalkSpeed, oldJumpPower=humanoid.JumpPower,
        oldAutoRotate=humanoid.AutoRotate, expiresAt=os.clock()+duration}
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.AutoRotate = false
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    task.delay(duration, function()
        if humanoid.Parent and humanoid.Health > 0 then
            humanoid.WalkSpeed = record.oldWalkSpeed
            humanoid.JumpPower = record.oldJumpPower
            humanoid.AutoRotate = record.oldAutoRotate
        end
    end)
    return true
end

function RealityControlService:CleanupExpired()
    local now = os.clock()
    for id, effect in pairs(self.ActiveEffects) do
        if now >= effect.expiresAt then self.ActiveEffects[id] = nil end
    end
end

function RealityControlService:CancelOwned(player)
    for id, effect in pairs(self.ActiveEffects) do
        if effect.ownerUserId == player.UserId then self.ActiveEffects[id] = nil end
    end
end

return RealityControlService