# ABYSSAL — Roblox Studio project

**Status:** foundation + implementation modules in progress. These files are source components, not a published, tested Roblox model.

## Design
- **RIFT**: spatial cuts, portals, dimensional blades and dimension travel.
- **NULL**: gravity zones, frozen-frame simulation and reality effects.
- Black / neon-violet cosmic visual direction; effects should be client-rendered where possible.
- PC and mobile controls; R6/R15 support requires rig-aware animation assets and testing.
- Admin actions must be checked on the server using numeric Roblox UserIds.

## Files
- `ABYSSAL_Config.lua`: shared limits, cooldowns and celestial catalog.
- `AuthorizationService.lua`: server-side admin and distance checks.
- `CombatService.lua`: cooldowns and server-side target validation.
- `PortalService.lua`: registered portal pairs and controlled traversal requests.
- `DimensionService.lua`: bounded in-server dimension regions.
- `RealityArchiveService.lua`: snapshots and reversible property changes.
- `CelestialService.lua`: catalog and server-side ability dispatch for 20 celestial bodies.
- `AbilityForge.lua`: validated component-based ability definitions (never executes arbitrary code).
- `ABYSSAL_Client.client.lua`: input bridge and mobile/keyboard request examples.
- `ABYSSAL_INSTALLER.lua`: creates the starter hierarchy only.

## Important installation note
Roblox Studio may block writing `ModuleScript.Source` from the ordinary Command Bar due to script security permissions. If it does, create the instances in Studio and paste each file's contents into the matching Script/ModuleScript manually, or package this as a Studio plugin with appropriate permissions. Do not disable Studio security to force it.

## Current limitations
- These source modules need to be placed into the indicated Roblox services and wired together in a bootstrap Script.
- The celestial catalog describes gameplay effects; it does **not** create polished planet meshes, skyboxes, sounds, animations, or particle assets automatically.
- Dimensions are isolated regions in the same server, not separate servers. Physics and server workload are shared.
- Time stop is a gameplay simulation for registered objects/characters, not a literal pause of the Roblox server.
- Reality changes must be applied through the archive service to make restoration possible.
- Test in a private place with multiple clients before publishing. No Studio runtime test is claimed by this repository update.

## Suggested hierarchy
```
ReplicatedStorage/ABYSSAL/Shared/ABYSSAL_Config (ModuleScript)
ReplicatedStorage/ABYSSAL/Remotes/{AbilityRequest, AbilityFeedback, PortalRequest, DimensionRequest, RealityControlRequest} (RemoteEvents)
ServerScriptService/ABYSSAL_Server/Modules/{AuthorizationService, CombatService, PortalService, DimensionService, RealityArchiveService, CelestialService, AbilityForge} (ModuleScripts)
ServerScriptService/ABYSSAL_Server/ABYSSAL_Bootstrap (Script)
StarterPack/ABYSSAL (Tool)
StarterPlayer/StarterPlayerScripts/ABYSSAL_Client (LocalScript)
```

Never use display names as the security identity; fill `AdminUserIds` with trusted numeric UserIds. All client requests are untrusted.