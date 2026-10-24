-- ModuleScript / manifest for reviewed asset IDs and effect presets.
-- Replace nil asset IDs only with assets you own or have permission to use.
local Catalog = {
    Theme = {Primary=Color3.fromRGB(12, 8, 20), Accent=Color3.fromRGB(165, 55, 255),
        Secondary=Color3.fromRGB(70, 0, 125), White=Color3.fromRGB(230, 220, 255)},
    Effects = {
        RiftSlash={lifetime=0.45, scale=1.0, particles=40, lightBrightness=2},
        FrozenFrame={lifetime=2.0, scale=1.2, particles=24, lightBrightness=1.4},
        DimensionalBlades={lifetime=1.5, scale=1.0, particles=32, lightBrightness=2.2},
        SolarCorona={lifetime=8.0, scale=3.0, particles=100, lightBrightness=3},
        LunarEclipse={lifetime=7.0, scale=2.4, particles=55, lightBrightness=1.6},
        JupiterImplosion={lifetime=4.0, scale=4.0, particles=120, lightBrightness=3},
    },
    Sounds = {Slash=nil, PortalOpen=nil, PortalClose=nil, RealityPulse=nil, CelestialSummon=nil},
    Animations = {R6={}, R15={}},
}
return Catalog