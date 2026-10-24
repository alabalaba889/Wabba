-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
local Players = game:GetService("Players")
local AuthorizationService = {}

function AuthorizationService.IsAdmin(player, config)
    if not player or not player:IsA("Player") then return false end
    for _, userId in ipairs(config.AdminUserIds or {}) do
        if type(userId) == "number" and player.UserId == userId then
            return true
        end
    end
    return false
end

function AuthorizationService.GetRoot(player)
    local character = player and player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

function AuthorizationService.IsWithinDistance(player, position, maxDistance)
    local root = AuthorizationService.GetRoot(player)
    if not root or typeof(position) ~= "Vector3" then return false end
    if type(maxDistance) ~= "number" or maxDistance <= 0 then return false end
    return (root.Position - position).Magnitude <= maxDistance
end

function AuthorizationService.GetLivingHumanoid(model)
    if not model or not model:IsA("Model") then return nil end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then return humanoid end
    return nil
end

function AuthorizationService.IsValidTarget(player, target, maxDistance)
    if not target or not target:IsA("Model") then return false end
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    local ownRoot = AuthorizationService.GetRoot(player)
    if not targetRoot or not ownRoot or not AuthorizationService.GetLivingHumanoid(target) then return false end
    if target == player.Character then return false end
    return (targetRoot.Position - ownRoot.Position).Magnitude <= maxDistance
end

function AuthorizationService.FindPlayerByUserId(userId)
    if type(userId) ~= "number" then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.UserId == userId then return player end
    end
    return nil
end

return AuthorizationService