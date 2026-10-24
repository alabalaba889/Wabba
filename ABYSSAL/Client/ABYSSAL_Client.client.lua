-- LocalScript under StarterPlayer/StarterPlayerScripts/ABYSSAL_Client
-- This only sends intent. The server must validate every request before applying gameplay.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("ABYSSAL")
local remotes = root:WaitForChild("Remotes")
local abilityRequest = remotes:WaitForChild("AbilityRequest")
local feedback = remotes:WaitForChild("AbilityFeedback")

local keyMap = {
    [Enum.KeyCode.Z] = "DimensionalCut",
    [Enum.KeyCode.X] = "FrozenFrame",
    [Enum.KeyCode.C] = "DimensionalBlades",
    [Enum.KeyCode.V] = "Contextual",
    [Enum.KeyCode.Q] = "Portal",
    [Enum.KeyCode.E] = "Reality",
}
local localDebounce = {}

local function requestAbility(ability)
    if localDebounce[ability] then return end
    localDebounce[ability] = true
    abilityRequest:FireServer({ability=ability})
    task.delay(0.15, function() localDebounce[ability] = nil end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        requestAbility("BasicCombo")
    else
        local ability = keyMap[input.KeyCode]
        if ability then requestAbility(ability) end
    end
end)

feedback.OnClientEvent:Connect(function(status, message)
    if status == "Error" then
        warn("[ABYSSAL] " .. tostring(message))
    end
end)

-- Mobile buttons should call requestAbility() from Activated events.
-- Build a ScreenGui with large touch targets for Attack, Rift, Freeze, Blades, Portal, Reality.
-- Avoid sending target Instances or destination CFrames from the client as trusted data.
