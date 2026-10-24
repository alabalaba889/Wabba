# ABYSSAL implementation tracker

## Source files now present
- [x] Initial hierarchy installer
- [x] Configuration + 20-body celestial catalog
- [x] Admin authorization helper
- [x] Combat cooldown / target validation module
- [x] Server hitbox / damage / knockback helpers
- [x] Portal registry and permission-checked traversal helper
- [x] In-server dimension registry
- [x] Reversible BasePart property archive
- [x] Bounded reality-zone and character-freeze helpers
- [x] Celestial request registry
- [x] Component-based Ability Forge validation
- [x] PC keyboard input bridge
- [x] VFX/SFX/animation manifest
- [x] Celestial effect concept matrix

## Not complete yet
- [ ] Full server bootstrap that wires every service and every RemoteEvent
- [ ] Full mobile ScreenGui with responsive buttons
- [ ] Real dual-sword Tool model, handle/attachments and equip/unequip logic
- [ ] Actual combo hit timing, blocking, hit reactions and server animation replication
- [ ] Production portal geometry, collision/traversal detection, portal closing UI
- [ ] Dimension entry/exit UI, per-player membership and safe cleanup on player leaving
- [ ] Visual planet meshes, particle emitters, beams, trails, lighting transitions and audio assets
- [ ] R6/R15 animation assets and fallbacks
- [ ] Reality restoration for Lighting, Terrain, models, physics and failed transactions
- [ ] Ultimate entity AI/state machine and command interface
- [ ] Admin UI and safe target selection
- [ ] Studio test place, multi-client tests, exploit/remote-spam tests and performance profiling

## Acceptance checks before enabling features
1. Only configured numeric UserIds can use admin-only abilities.
2. Every RemoteEvent rejects malformed, out-of-range and over-limit requests.
3. Every temporary effect has a cleanup path even if the character dies or leaves.
4. A failed effect restores every property it changed.
5. R6 and R15 both work, or the unsupported rig receives a clear fallback.
6. Mobile controls are usable without covering the Roblox movement/jump controls.
7. Run at least two clients in a private test server and verify the server, not the client, owns damage and permissions.

Features in config stay disabled until their complete handlers have been wired and tested.