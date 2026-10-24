-- Place as ModuleScript: ReplicatedStorage/ABYSSAL/Shared/ABYSSAL_Config
local Config = {}

Config.Version = "0.2.0-module-foundation"
Config.WeaponName = "ABYSSAL"
Config.AdminUserIds = {} -- Add trusted numeric UserIds. Never use usernames for server authorization.
Config.Enabled = {
    Combat = true,
    Portals = false, -- Enable only after the server services are wired and tested.
    Dimensions = false,
    RealityControl = false,
    CelestialPowers = false,
}
Config.Cooldowns = {
    BasicCombo = 0.35, DimensionalCut = 2, FrozenFrame = 8,
    DimensionalBlades = 12, Contextual = 3, Portal = 5, Reality = 8,
    GravityZone = 15, Celestial = 25, Ultimate = 90,
}
Config.Limits = {
    MaxTargetDistance = 180,
    MaxActivePortalsPerPlayer = 4,
    MaxDimensionsPerPlayer = 2,
    MaxDimensionObjects = 150,
    MaxTargetsPerAbility = 8,
    MaxEffectDuration = 20,
    MaxForce = 2500,
    MaxCelestialScale = 300,
}
Config.Controls = {
    PC = {Primary = "MouseButton1", DimensionalCut = "Z", FrozenFrame = "X",
        DimensionalBlades = "C", Contextual = "V", Portal = "Q", Reality = "E"},
    Mobile = {"Attack", "Rift", "Freeze", "Blades", "Portal", "Reality"},
}
Config.Celestials = {
    Sun = {kind="Star", effect="ThermalGravity", cooldown=35},
    Moon = {kind="NaturalSatellite", effect="TidalGravity", cooldown=25},
    Jupiter = {kind="Planet", effect="GiantGravity", cooldown=40},
    Mercury = {kind="Planet", effect="HeatBurst", cooldown=22},
    Venus = {kind="Planet", effect="AtmosphericPressure", cooldown=25},
    Mars = {kind="Planet", effect="RedDustShockwave", cooldown=24},
    Saturn = {kind="Planet", effect="RingBlade", cooldown=35},
    Uranus = {kind="Planet", effect="AxisDistortion", cooldown=30},
    Neptune = {kind="Planet", effect="BluePressureWave", cooldown=30},
    Pluto = {kind="DwarfPlanet", effect="FrozenOrbit", cooldown=22},
    Phobos = {kind="NaturalSatellite", effect="RapidImpact", cooldown=18},
    Deimos = {kind="NaturalSatellite", effect="ShadowOrbit", cooldown=18},
    Europa = {kind="NaturalSatellite", effect="IcePrison", cooldown=24},
    Io = {kind="NaturalSatellite", effect="VolcanicBurst", cooldown=24},
    Ganymede = {kind="NaturalSatellite", effect="MagneticPulse", cooldown=26},
    Callisto = {kind="NaturalSatellite", effect="CraterField", cooldown=24},
    Titan = {kind="NaturalSatellite", effect="AmberFog", cooldown=26},
    Enceladus = {kind="NaturalSatellite", effect="IceGeyser", cooldown=22},
    Ceres = {kind="DwarfPlanet", effect="AsteroidField", cooldown=20},
    Eris = {kind="DwarfPlanet", effect="DarkOrbit", cooldown=28},
}
return Config