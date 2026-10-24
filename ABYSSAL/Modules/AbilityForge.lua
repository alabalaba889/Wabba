-- ModuleScript under ServerScriptService/ABYSSAL_Server/Modules
-- Definitions are data only. Never loadstring or execute player-authored Luau.
local AbilityForge = {}
AbilityForge.__index = AbilityForge

local ALLOWED_COMPONENTS = {
    Slash=true, Rift=true, Gravity=true, FreezeFrame=true, SummonBlades=true,
    CelestialPulse=true, Knockback=true, VisualBurst=true, SoundCue=true,
}
local MAX_COMPONENTS = 8

function AbilityForge.new(config, authorization)
    return setmetatable({Config=config, Authorization=authorization, Saved={}}, AbilityForge)
end

function AbilityForge:ValidateDefinition(player, definition)
    if not self.Authorization.IsAdmin(player, self.Config) then return false, "AdminOnly" end
    if type(definition) ~= "table" or type(definition.name) ~= "string" then return false, "InvalidDefinition" end
    if #definition.name < 1 or #definition.name > 40 then return false, "InvalidName" end
    if type(definition.components) ~= "table" or #definition.components < 1 or #definition.components > MAX_COMPONENTS then
        return false, "InvalidComponentCount"
    end
    for _, component in ipairs(definition.components) do
        if type(component) ~= "table" or not ALLOWED_COMPONENTS[component.type] then
            return false, "UnsupportedComponent"
        end
        if component.duration ~= nil and (type(component.duration) ~= "number" or component.duration < 0 or component.duration > 20) then
            return false, "InvalidDuration"
        end
        if component.power ~= nil and (type(component.power) ~= "number" or component.power < 0 or component.power > 100) then
            return false, "InvalidPower"
        end
    end
    return true
end

function AbilityForge:Save(player, definition)
    local ok, reason = self:ValidateDefinition(player, definition)
    if not ok then return false, reason end
    local safe = {name=definition.name, ownerUserId=player.UserId, components={}}
    for _, component in ipairs(definition.components) do
        table.insert(safe.components, {type=component.type, duration=component.duration, power=component.power})
    end
    self.Saved[player.UserId] = self.Saved[player.UserId] or {}
    if #self.Saved[player.UserId] >= 50 then return false, "AbilityLimit" end
    table.insert(self.Saved[player.UserId], safe)
    return true, safe
end

return AbilityForge