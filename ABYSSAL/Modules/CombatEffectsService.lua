-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
local CombatEffectsService = {}
CombatEffectsService.__index = CombatEffectsService

function CombatEffectsService.new(config, authorization)
    return setmetatable({Config=config, Authorization=authorization}, CombatEffectsService)
end

function CombatEffectsService:GetTargetsInBox(attacker, boxCFrame, boxSize)
    local root = self.Authorization.GetRoot(attacker)
    if not root or typeof(boxCFrame) ~= "CFrame" or typeof(boxSize) ~= "Vector3" then return {} end
    if (root.Position - boxCFrame.Position).Magnitude > self.Config.Limits.MaxTargetDistance then return {} end
    boxSize = Vector3.new(math.clamp(boxSize.X, 1, 30), math.clamp(boxSize.Y, 1, 25), math.clamp(boxSize.Z, 1, 35))
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {attacker.Character}
    local parts = workspace:GetPartBoundsInBox(boxCFrame, boxSize, params)
    local found, targets = {}, {}
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and not found[model] and #targets < self.Config.Limits.MaxTargetsPerAbility
            and self.Authorization.IsValidTarget(attacker, model, self.Config.Limits.MaxTargetDistance) then
            found[model] = true
            table.insert(targets, model)
        end
    end
    return targets
end

function CombatEffectsService:DamageTargets(attacker, targets, damage)
    if type(targets) ~= "table" then return 0 end
    damage = math.clamp(tonumber(damage) or 0, 0, 100)
    local count = 0
    for _, target in ipairs(targets) do
        if count >= self.Config.Limits.MaxTargetsPerAbility then break end
        if self.Authorization.IsValidTarget(attacker, target, self.Config.Limits.MaxTargetDistance) then
            local humanoid = self.Authorization.GetLivingHumanoid(target)
            if humanoid then humanoid:TakeDamage(damage); count += 1 end
        end
    end
    return count
end

function CombatEffectsService:ApplyKnockback(attacker, target, force)
    if not self.Authorization.IsValidTarget(attacker, target, self.Config.Limits.MaxTargetDistance) then return false end
    local aRoot = self.Authorization.GetRoot(attacker)
    local tRoot = target:FindFirstChild("HumanoidRootPart")
    if not aRoot or not tRoot then return false end
    force = math.clamp(tonumber(force) or 0, 0, self.Config.Limits.MaxForce)
    local direction = tRoot.Position - aRoot.Position
    if direction.Magnitude < 0.01 then direction = aRoot.CFrame.LookVector end
    tRoot:ApplyImpulse((direction.Unit + Vector3.new(0, 0.25, 0)).Unit * force * tRoot.AssemblyMass)
    return true
end

return CombatEffectsService