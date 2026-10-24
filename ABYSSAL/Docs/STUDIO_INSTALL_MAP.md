# Roblox Studio placement map

The repository folders are source organization; Roblox Studio does not automatically import them as Instances.

| Repository file | Roblox Studio destination |
|---|---|
| `Modules/ABYSSAL_Config.lua` | `ReplicatedStorage/ABYSSAL/Shared/ABYSSAL_Config` (ModuleScript) |
| `Modules/AuthorizationService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/AuthorizationService` |
| `Modules/CombatService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/CombatService` |
| `Modules/CombatEffectsService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/CombatEffectsService` |
| `Modules/PortalService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/PortalService` |
| `Modules/DimensionService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/DimensionService` |
| `Modules/RealityArchiveService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/RealityArchiveService` |
| `Modules/RealityControlService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/RealityControlService` |
| `Modules/CelestialService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/CelestialService` |
| `Modules/AbilityForge.lua` | `ServerScriptService/ABYSSAL_Server/Modules/AbilityForge` |
| `Modules/UltimateEntityService.lua` | `ServerScriptService/ABYSSAL_Server/Modules/UltimateEntityService` |
| `Modules/VFXCatalog.lua` | `ReplicatedStorage/ABYSSAL/Shared/VFXCatalog` (ModuleScript) |
| `Modules/ServerBootstrap.example.lua` | Adapt into `ServerScriptService/ABYSSAL_Server/ABYSSAL_Bootstrap` (Script) |
| `Client/ABYSSAL_Client.client.lua` | `StarterPlayer/StarterPlayerScripts/ABYSSAL_Client` (LocalScript) |
| `Client/MobileControls.client.lua` | `StarterPlayer/StarterPlayerScripts/ABYSSAL_MobileControls` (LocalScript) |
| `Modules/ToolBuilder.example.lua` | Run only as a reviewed Studio utility; it creates a greybox prototype |

Create the RemoteEvents in `ReplicatedStorage/ABYSSAL/Remotes` with the exact names in the installer. The ordinary Command Bar may not be permitted to write script source; paste file contents manually if Studio blocks it.

Before enabling a feature flag, wire its service to the appropriate remote, add cleanup paths, configure the admin numeric UserId, and test with multiple clients in a private place.