-- Example Script under ServerScriptService/ABYSSAL_Server.
-- Adapt require paths to the actual ModuleScript locations before enabling.
-- This file is deliberately an example: review all remotes and handlers in Studio first.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local root = ReplicatedStorage:WaitForChild("ABYSSAL")
local remotes = root:WaitForChild("Remotes")
local config = require(root:WaitForChild("Shared"):WaitForChild("ABYSSAL_Config"))
local modules = script.Parent:WaitForChild("Modules")
local Authorization = require(modules:WaitForChild("AuthorizationService"))
local CombatServiceClass = require(modules:WaitForChild("CombatService"))
local combat = CombatServiceClass.new(config, Authorization)

local abilityRequest = remotes:WaitForChild("AbilityRequest")
local feedback = remotes:WaitForChild("AbilityFeedback")

local ALLOWED_ABILITIES = {
    BasicCombo=true, DimensionalCut=true, FrozenFrame=true,
    DimensionalBlades=true, Contextual=true, Portal=true, Reality=true,
}

abilityRequest.OnServerEvent:Connect(function(player, payload)
    if type(payload) ~= "table" or type(payload.ability) ~= "string" or not ALLOWED_ABILITIES[payload.ability] then
        feedback:FireClient(player, "Error", "InvalidRequest")
        return
    end
    local valid, reason = combat:ValidateRequest(player, payload)
    if not valid then
        feedback:FireClient(player, "Error", reason)
        return
    end
    -- TODO: dispatch only to reviewed server handlers. Do not treat this validation as implemented combat.
    feedback:FireClient(player, "Accepted", payload.ability)
end)

Players.PlayerRemoving:Connect(function(player)
    combat:CleanupPlayer(player)
end)

print("[ABYSSAL] Example bootstrap loaded. Combat dispatch is intentionally not implemented yet.")