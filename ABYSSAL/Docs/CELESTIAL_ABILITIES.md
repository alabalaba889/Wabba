# ABYSSAL Celestial Ability Matrix

All effects below are **in-game simulations**. They do not move real celestial bodies or change the actual Roblox server physics globally.

| Body | Gameplay effect | Visual direction |
|---|---|---|
| Sun | Thermal/gravity field; red-orange lighting pulse; bounded damage-over-time | Corona, heat haze, solar flares |
| Moon | Tidal/gravity pulse; upward pull; water wave if a compatible water system exists | Eclipse, red moon, cracked-ground decals |
| Jupiter | Heavy gravity/compression zone; final implosion pulse | Great Red Spot rotation, bands, ring debris |
| Mercury | Fast heat burst | Bright metallic trail, short flare |
| Venus | Dense atmosphere/pressure field | Amber clouds and distortion |
| Mars | Red dust shockwave | Dust wall and crater decals |
| Saturn | Orbiting ring blades | Rings and icy fragments |
| Uranus | Axis/trajectory distortion | Tilted cyan rings |
| Neptune | Blue pressure wave | Deep-blue storm and mist |
| Pluto | Short frozen-orbit trap | Icy crystal field |
| Phobos | Rapid impact strike | Small moon streak and impact ring |
| Deimos | Shadow orbit and decoy | Dim satellite silhouettes |
| Europa | Ice prison | Ice shell and frost burst |
| Io | Volcanic burst | Lava fissures and ash |
| Ganymede | Magnetic pulse | Magnetic arcs and field lines |
| Callisto | Crater field | Multi-point impact decals |
| Titan | Amber fog zone | Orange haze and silhouette distortion |
| Enceladus | Ice geyser | Cryovolcanic columns |
| Ceres | Asteroid field | Small orbiting rocks |
| Eris | Dark orbit / brief visibility distortion | Black-violet eclipse ring |

## Required implementation per body
1. Server-side permission, cooldown, range, target count, and effect-duration checks.
2. Client-side VFX assets, local camera effects, and sound cues.
3. Server gameplay effect with bounded force/damage and cleanup on timeout/player exit.
4. Optional world changes must use RealityArchiveService and restore on cancellation.
5. Add a cancel/restore path; never leave lighting, gravity, parts, or forces changed after failure.

## Signature sequences
- **Sun:** summon miniature stylized sun near selected point; warm color grade; bounded heat zone; remove zone and restore lighting after duration.
- **Moon:** gravity pulse and simulated water wave. Ground cracks are decals/temporary parts, not destructive terrain edits by default.
- **Jupiter:** large sky projection rather than a physically huge collidable sphere; local gravity field with capped force; implosion is a VFX finish, not server-wide destruction.

## Still required
The catalog is data only. Polished meshes, rigged animations, particle emitters, sounds, target selection UI, damage handlers, and multiplayer tests remain separate implementation work.