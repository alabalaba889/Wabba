-- Example Script under ServerScriptService/ABYSSAL_Server named ABYSSAL_Bootstrap.
-- Before enabling features, copy all ModuleScripts into the Studio destinations in Docs/STUDIO_INSTALL_MAP.md.
-- This bootstrap demonstrates safe server-owned target selection and service wiring; it is not Studio-tested.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local root = ReplicatedStorage:WaitForChild("ABYSSAL")
local remotes = root:WaitForChild("Remotes")
local config = require(root:WaitForChild("Shared"):WaitForChild("ABYSSAL_Config"))
local modules = script.Parent:WaitForChild("Modules")

local Authorization = require(modules:WaitForChild("AuthorizationService"))
local CombatClass = require(modules:WaitForChild("CombatService"))
local CombatEffectsClass = require(modules:WaitForChild("CombatEffectsService"))
local PortalClass = require(modules:WaitForChild("PortalService"))
local DimensionClass = require(modules:WaitForChild("DimensionService"))
local ArchiveClass = require(modules:WaitForChild("RealityArchiveService"))
local RealityClass = require(modules:WaitForChild("RealityControlService"))
local CelestialClass = require(modules:WaitForChild("CelestialService"))
local EntityClass = require(modules:WaitForChild("UltimateEntityService"))
local ForgeClass = require(modules:WaitForChild("AbilityForge"))

local combat = CombatClass.new(config, Authorization)
local effects = CombatEffectsClass.new(config, Authorization)
local portals = PortalClass.new(config, Authorization)
local dimensions = DimensionClass.new(config, Authorization, workspace)
local archive = ArchiveClass.new(500)
local reality = RealityClass.new(config, Authorization, archive)
local celestials = CelestialClass.new(config, Authorization)
local entities = EntityClass.new(config, Authorization)
local forge = ForgeClass.new(config, Authorization)

local abilityRequest = remotes:WaitForChild("AbilityRequest")
local feedback = remotes:WaitForChild("AbilityFeedback")
local portalRequest = remotes:WaitForChild("PortalRequest")
local dimensionRequest = remotes:WaitForChild("DimensionRequest")
local realityRequest = remotes:WaitForChild("RealityControlRequest")

local ALLOWED_ABILITIES = {
    BasicCombo=true, DimensionalCut=true, FrozenFrame=true,
    DimensionalBlades=true, Contextual=true,
}

local function frontBox(player, distance, height)
    local rootPart = Authorization.GetRoot(player)
    if not rootPart then return nil end
    return rootPart.CFrame * CFrame.new(0, 0, -distance) * CFrame.new(0, height or 0, 0)
end

local function nearestTarget(player, boxCFrame, boxSize)
    local targets = effects:GetTargetsInBox(player, boxCFrame, boxSize)
    return targets[1]
end

abilityRequest.OnServerEvent:Connect(function(player, payload)
    if type(payload) ~= "table" or type(payload.ability) ~= "string" then
        feedback:FireClient(player, "Error", "InvalidRequest")
        return
    end
    local ability = payload.ability
    if ability == "Portal" then
        feedback:FireClient(player, "Error", "UsePortalRequest")
        return
    elseif ability == "Reality" then
        feedback:FireClient(player, "Error", "UseRealityControlRequest")
        return
    elseif ability == "Celestial" then
        feedback:FireClient(player, "Error", "UseCelestialRequest")
        return
    end
    if not ALLOWED_ABILITIES[ability] then
        feedback:FireClient(player, "Error", "UnknownAbility")
        return
    end
    local valid, reason = combat:ValidateRequest(player, {ability=ability})
    if not valid then feedback:FireClient(player, "Error", reason); return end

    if ability == "BasicCombo" then
        local box = frontBox(player, 4, 0)
        if not box then feedback:FireClient(player, "Error", "NoCharacter"); return end
        local targets = effects:GetTargetsInBox(player, box, Vector3.new(5, 5, 7))
        effects:DamageTargets(player, targets, 10)
    elseif ability == "DimensionalCut" then
        local box = frontBox(player, 7, 0)
        if not box then feedback:FireClient(player, "Error", "NoCharacter"); return end
        local targets = effects:GetTargetsInBox(player, box, Vector3.new(7, 6, 12))
        effects:DamageTargets(player, targets, 25)
        for _, target in ipairs(targets) do effects:ApplyKnockback(player, target, 700) end
    elseif ability == "DimensionalBlades" then
        local box = frontBox(player, 8, 0)
        if not box then feedback:FireClient(player, "Error", "NoCharacter"); return end
        local targets = effects:GetTargetsInBox(player, box, Vector3.new(10, 8, 14))
        effects:DamageTargets(player, targets, 18)
    elseif ability == "FrozenFrame" then
        if not config.Enabled.RealityControl then feedback:FireClient(player, "Error", "FeatureDisabled"); return end
        if not Authorization.IsAdmin(player, config) then feedback:FireClient(player, "Error", "AdminOnly"); return end
        local box = frontBox(player, 7, 0)
        local target = box and nearestTarget(player, box, Vector3.new(8, 7, 12))
        if not target then feedback:FireClient(player, "Error", "NoTarget"); return end
        local ok, why = reality:CreateFrozenFrame(player, target, 2)
        if not ok then feedback:FireClient(player, "Error", why); return end
    end
    feedback:FireClient(player, "Accepted", ability)
end)

portalRequest.OnServerEvent:Connect(function(player, payload)
    if type(payload) ~= "table" or type(payload.action) ~= "string" then
        feedback:FireClient(player, "Error", "InvalidPortalRequest"); return
    end
    if not Authorization.IsAdmin(player, config) then feedback:FireClient(player, "Error", "AdminOnly"); return end
    if payload.action == "CloseOwned" then portals:CloseOwnedBy(player); feedback:FireClient(player, "Accepted", "PortalsClosed"); return end
    feedback:FireClient(player, "Error", "PortalPlacementUIRequired")
end)

dimensionRequest.OnServerEvent:Connect(function(player, payload)
    if not Authorization.IsAdmin(player, config) then feedback:FireClient(player, "Error", "AdminOnly"); return end
    if type(payload) ~= "table" or payload.action ~= "Create" then feedback:FireClient(player, "Error", "InvalidDimensionRequest"); return end
    local rootPart = Authorization.GetRoot(player)
    if not rootPart then feedback:FireClient(player, "Error", "NoCharacter"); return end
    local center = rootPart.Position + rootPart.CFrame.LookVector * 35
    local record, reason = dimensions:Create(player, center, Vector3.new(64, 32, 64), "Personal")
    if not record then feedback:FireClient(player, "Error", reason); return end
    feedback:FireClient(player, "Accepted", "DimensionCreated")
end)

realityRequest.OnServerEvent:Connect(function(player, payload)
    if not Authorization.IsAdmin(player, config) then feedback:FireClient(player, "Error", "AdminOnly"); return end
    if type(payload) ~= "table" or type(payload.action) ~= "string" then feedback:FireClient(player, "Error", "InvalidRealityRequest"); return end
    if payload.action == "GravityZone" then
        local rootPart = Authorization.GetRoot(player)
        if not rootPart then feedback:FireClient(player, "Error", "NoCharacter"); return end
        local center = rootPart.Position + rootPart.CFrame.LookVector * 25
        local ok, result = reality:CreateGravityZone(player, center, 35, 5, 1)
        if not ok then feedback:FireClient(player, "Error", result); return end
        feedback:FireClient(player, "Accepted", "GravityZoneRegistered")
    else
        feedback:FireClient(player, "Error", "UnsupportedRealityAction")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    combat:CleanupPlayer(player)
    portals:CloseOwnedBy(player)
    celestials:CleanupPlayer(player)
    entities:CleanupPlayer(player)
    reality:CancelOwned(player)
end)

print("[ABYSSAL] Example services wired. Features still need Studio setup, visuals, tests, and reviewed production handlers.")