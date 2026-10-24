-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
local CombatService = {}
CombatService.__index = CombatService

function CombatService.new(config, authorization)
    return setmetatable({
        Config = config, Authorization = authorization,
        Cooldowns = {}, ComboState = {},
    }, CombatService)
end

function CombatService:CanUse(player, abilityName)
    if not player or type(abilityName) ~= "string" then return false, "InvalidRequest" end
    local duration = self.Config.Cooldowns[abilityName]
    if type(duration) ~= "number" then return false, "UnknownAbility" end
    local now = os.clock()
    self.Cooldowns[player.UserId] = self.Cooldowns[player.UserId] or {}
    local readyAt = self.Cooldowns[player.UserId][abilityName] or 0
    if now < readyAt then return false, "Cooldown" end
    self.Cooldowns[player.UserId][abilityName] = now + duration
    return true
end

function CombatService:ValidateRequest(player, payload)
    if type(payload) ~= "table" or type(payload.ability) ~= "string" then
        return false, "MalformedPayload"
    end
    if not self.Config.Enabled.Combat then return false, "FeatureDisabled" end
    local ok, reason = self:CanUse(player, payload.ability)
    if not ok then return false, reason end
    if payload.target and not self.Authorization.IsValidTarget(
        player, payload.target, self.Config.Limits.MaxTargetDistance
    ) then
        return false, "InvalidTarget"
    end
    return true
end

function CombatService:ApplyDamage(attacker, target, amount)
    if type(amount) ~= "number" then return false end
    amount = math.clamp(amount, 0, 100)
    if not self.Authorization.IsValidTarget(attacker, target, self.Config.Limits.MaxTargetDistance) then
        return false
    end
    local humanoid = self.Authorization.GetLivingHumanoid(target)
    if not humanoid then return false end
    humanoid:TakeDamage(amount)
    return true
end

function CombatService:CleanupPlayer(player)
    self.Cooldowns[player.UserId] = nil
    self.ComboState[player.UserId] = nil
end

return CombatService