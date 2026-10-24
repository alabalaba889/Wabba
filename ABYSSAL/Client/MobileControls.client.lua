-- LocalScript under StarterPlayer/StarterPlayerScripts; optional companion to ABYSSAL_Client.
-- Creates a compact touch-only HUD. Server-side remotes must still validate every request.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
if not UserInputService.TouchEnabled then return end

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ABYSSAL"):WaitForChild("Remotes")
local request = remotes:WaitForChild("AbilityRequest")
local gui = Instance.new("ScreenGui")
gui.Name = "ABYSSAL_MobileControls"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local specs = {
    {label="ATACAR", ability="BasicCombo"},
    {label="RIFT", ability="DimensionalCut"},
    {label="FRAME", ability="FrozenFrame"},
    {label="LÂMINAS", ability="DimensionalBlades"},
    {label="PORTAL", ability="Portal"},
    {label="REALIDADE", ability="Reality"},
}
local holder = Instance.new("Frame")
holder.Name = "AbilityButtons"
holder.AnchorPoint = Vector2.new(1, 1)
holder.Position = UDim2.new(1, -18, 1, -110)
holder.Size = UDim2.fromOffset(230, 160)
holder.BackgroundTransparency = 1
holder.Parent = gui

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromOffset(72, 48)
layout.CellPadding = UDim2.fromOffset(5, 5)
layout.FillDirectionMaxCells = 3
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = holder

for i, spec in ipairs(specs) do
    local button = Instance.new("TextButton")
    button.Name = spec.ability
    button.LayoutOrder = i
    button.Text = spec.label
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(245, 235, 255)
    button.BackgroundColor3 = Color3.fromRGB(27, 12, 42)
    button.AutoButtonColor = true
    button.Parent = holder
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(160, 60, 255)
    stroke.Thickness = 1.5
    stroke.Parent = button
    button.Activated:Connect(function()
        request:FireServer({ability=spec.ability})
    end)
end
