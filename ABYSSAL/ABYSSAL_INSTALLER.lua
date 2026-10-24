-- ABYSSAL INSTALLER — foundation scaffold
-- Run this source in Roblox Studio's Command Bar while NOT play-testing.
-- It creates the initial project hierarchy only. It does not delete existing game content.
-- After installation, inspect the created objects before publishing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")

local function getOrCreate(parent, className, name)
    local existing = parent:FindFirstChild(name)
    if existing and existing.ClassName == className then
        return existing
    end
    if existing then
        warn(("[ABYSSAL] '%s' exists under %s with class %s; leaving it untouched.")
            :format(name, parent:GetFullName(), existing.ClassName))
        return nil
    end
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

local root = getOrCreate(ReplicatedStorage, "Folder", "ABYSSAL")
local remotes = root and getOrCreate(root, "Folder", "Remotes")
local shared = root and getOrCreate(root, "Folder", "Shared")
local assets = root and getOrCreate(root, "Folder", "Assets")
local serverRoot = getOrCreate(ServerScriptService, "Folder", "ABYSSAL_Server")
local serverModules = serverRoot and getOrCreate(serverRoot, "Folder", "Modules")
local privateAssets = getOrCreate(ServerStorage, "Folder", "ABYSSAL_PrivateAssets")
local tool = getOrCreate(StarterPack, "Tool", "ABYSSAL")
-- Create a LocalScript slot; paste Client/ABYSSAL_Client.client.lua into it manually.
-- Studio security can prevent scripts from writing Source from the ordinary Command Bar.
local clientRoot = getOrCreate(StarterPlayer.StarterPlayerScripts, "LocalScript", "ABYSSAL_Client")

if remotes then
    for _, remoteName in ipairs({
        "AbilityRequest",
        "AbilityFeedback",
        "PortalRequest",
        "DimensionRequest",
        "RealityControlRequest",
    }) do
        getOrCreate(remotes, "RemoteEvent", remoteName)
    end
end

if shared then
    local config = getOrCreate(shared, "ModuleScript", "ABYSSAL_Config")
    if config and config.Source == "" then
        config.Source = [=[
local Config = {}

Config.Version = "0.1.0-foundation"
Config.WeaponName = "ABYSSAL"
Config.AdminUserIds = {} -- Add trusted numeric UserIds before enabling admin-only powers.
Config.AbilityCooldowns = {
    DimensionalCut = 2.0,
    FrozenFrame = 8.0,
    DimensionalBlades = 12.0,
}
Config.Limits = {
    MaxTargetDistance = 180,
    MaxActivePortalsPerPlayer = 4,
    MaxDimensionObjects = 150,
}
Config.Features = {
    Combat = false,
    Portals = false,
    Dimensions = false,
    RealityControl = false,
    CelestialPowers = false,
}

return Config
]=]
    end
end

if serverModules then
    local readme = getOrCreate(serverModules, "ModuleScript", "README_ModulePlan")
    if readme and readme.Source == "" then
        readme.Source = [=[
-- ABYSSAL server module plan.
-- Implement separate, reviewed modules here:
-- AuthorizationService, CombatService, PortalService, DimensionService,
-- RealityArchiveService, CelestialService, AbilityForgeService.
-- All ability requests must be validated on the server.
-- Do not execute user-authored arbitrary Luau code.
return {
    Status = "Scaffold only",
    NextStep = "Implement and test each service independently",
}
]=]
    end
end

if tool then
    tool.RequiresHandle = false
    tool.CanBeDropped = false
end

print("[ABYSSAL] Foundation hierarchy created. This is a scaffold, not the complete weapon.")
print("[ABYSSAL] Paste the repository client script into StarterPlayerScripts/ABYSSAL_Client if its Source is empty.")
print("[ABYSSAL] Review the Output window and inspect every created instance before publishing.")
