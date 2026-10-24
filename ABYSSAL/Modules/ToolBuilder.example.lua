-- Run as a reviewed Studio utility, or adapt into a plugin command.
-- Produces a greybox prototype, not a final polished mesh or animation rig.
local ToolBuilder = {}

local function makePart(parent, name, size, color, material, cframe)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = material
    part.Anchored = false
    part.CanCollide = false
    part.Massless = true
    part.CFrame = cframe
    part.Parent = parent
    return part
end

function ToolBuilder.BuildPrototype(parent)
    local tool = Instance.new("Tool")
    tool.Name = "ABYSSAL"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    local handle = makePart(tool, "Handle", Vector3.new(0.22, 1.3, 0.22),
        Color3.fromRGB(20, 16, 28), Enum.Material.Metal, CFrame.new())
    local blade = makePart(tool, "RIFT_Blade", Vector3.new(0.28, 3.5, 0.12),
        Color3.fromRGB(150, 50, 255), Enum.Material.Neon, CFrame.new(0, 2.3, 0))
    local guard = makePart(tool, "RIFT_Guard", Vector3.new(1.0, 0.18, 0.22),
        Color3.fromRGB(45, 25, 65), Enum.Material.Metal, CFrame.new(0, 0.75, 0))
    for _, part in ipairs({blade, guard}) do
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = handle
        weld.Part1 = part
        weld.Parent = handle
    end
    local glow = Instance.new("PointLight")
    glow.Color = blade.Color
    glow.Brightness = 1.5
    glow.Range = 8
    glow.Parent = blade
    tool.Parent = parent
    return tool
end

return ToolBuilder