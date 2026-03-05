--[[
    Car Spawner estilo FiveM (círculo en el suelo) para Roblox
    -----------------------------------------------------------
    - Crea un círculo de spawner en el suelo.
    - Al acercarte aparece un ProximityPrompt para abrir el menú.
    - Permite elegir varios coches (incluyendo Toyota RAV4, Opel Corsa, BMW M2 CS,
      deportivos y marcas españolas).
    - Genera matrícula española aleatoria (formato 1234 BCD).

    Uso recomendado:
    - Ejecutar en un LocalScript (StarterPlayerScripts) o desde executor.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local SPAWN_CFRAME = CFrame.new(0, 3, 0)
local SPAWN_CIRCLE_SIZE = Vector3.new(16, 1, 16)

local VEHICLES = {
    {
        name = "Toyota RAV4",
        color = Color3.fromRGB(210, 210, 215),
        size = Vector3.new(7.5, 1.8, 13),
        wheelBase = 4.2,
        topSpeed = 88,
    },
    {
        name = "Opel Corsa",
        color = Color3.fromRGB(240, 70, 70),
        size = Vector3.new(6.5, 1.5, 10.5),
        wheelBase = 3.6,
        topSpeed = 80,
    },
    {
        name = "BMW M2 CS",
        color = Color3.fromRGB(65, 125, 255),
        size = Vector3.new(6.8, 1.4, 11),
        wheelBase = 3.7,
        topSpeed = 110,
    },
    {
        name = "SEAT León Cupra",
        color = Color3.fromRGB(255, 255, 255),
        size = Vector3.new(6.8, 1.5, 11.2),
        wheelBase = 3.8,
        topSpeed = 90,
    },
    {
        name = "CUPRA Formentor",
        color = Color3.fromRGB(100, 100, 105),
        size = Vector3.new(7.3, 1.7, 12),
        wheelBase = 4,
        topSpeed = 95,
    },
    {
        name = "Ferrari 488",
        color = Color3.fromRGB(220, 35, 35),
        size = Vector3.new(6.9, 1.2, 11.4),
        wheelBase = 3.9,
        topSpeed = 120,
    },
    {
        name = "Lamborghini Huracán",
        color = Color3.fromRGB(255, 170, 40),
        size = Vector3.new(7, 1.2, 11.8),
        wheelBase = 4,
        topSpeed = 125,
    },
    {
        name = "Porsche 911 Turbo S",
        color = Color3.fromRGB(35, 35, 35),
        size = Vector3.new(6.8, 1.3, 11.3),
        wheelBase = 3.8,
        topSpeed = 118,
    },
}

local LICENSE_LETTERS = "BCDFGHJKLMNPRSTVWXYZ"

local function randomPlate()
    local numbers = string.format("%04d", math.random(0, 9999))
    local chars = {}

    for _ = 1, 3 do
        local index = math.random(1, #LICENSE_LETTERS)
        table.insert(chars, string.sub(LICENSE_LETTERS, index, index))
    end

    return numbers .. " " .. table.concat(chars)
end

local function createWheel(parent, offset)
    local wheel = Instance.new("Part")
    wheel.Shape = Enum.PartType.Cylinder
    wheel.Size = Vector3.new(1.8, 1.8, 1.2)
    wheel.Color = Color3.fromRGB(25, 25, 25)
    wheel.Material = Enum.Material.SmoothPlastic
    wheel.Orientation = Vector3.new(0, 0, 90)
    wheel.Position = offset
    wheel.Parent = parent
    return wheel
end

local function weld(a, b)
    local wc = Instance.new("WeldConstraint")
    wc.Part0 = a
    wc.Part1 = b
    wc.Parent = a
end

local activeVehicle

local function spawnVehicle(vehicleData)
    if activeVehicle and activeVehicle.Parent then
        activeVehicle:Destroy()
    end

    local model = Instance.new("Model")
    model.Name = vehicleData.name:gsub("%s+", "") .. "_" .. localPlayer.Name

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = vehicleData.size
    body.Color = vehicleData.color
    body.Material = Enum.Material.Metal
    body.TopSurface = Enum.SurfaceType.Smooth
    body.BottomSurface = Enum.SurfaceType.Smooth
    body.CFrame = SPAWN_CFRAME
    body.Parent = model

    local roof = Instance.new("Part")
    roof.Name = "Roof"
    roof.Size = Vector3.new(vehicleData.size.X * 0.72, vehicleData.size.Y * 0.65, vehicleData.size.Z * 0.42)
    roof.Color = Color3.fromRGB(20, 20, 24)
    roof.Material = Enum.Material.SmoothPlastic
    roof.CFrame = body.CFrame * CFrame.new(0, vehicleData.size.Y * 0.65, 0)
    roof.Parent = model

    local seat = Instance.new("VehicleSeat")
    seat.Name = "DriverSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.Color = Color3.fromRGB(35, 35, 35)
    seat.CFrame = body.CFrame * CFrame.new(0, vehicleData.size.Y * 0.7, 0)
    seat.MaxSpeed = vehicleData.topSpeed
    seat.Torque = 55000
    seat.TurnSpeed = 2
    seat.Parent = model

    local plate = Instance.new("Part")
    plate.Name = "Plate"
    plate.Size = Vector3.new(2.8, 0.6, 0.1)
    plate.Color = Color3.fromRGB(245, 245, 245)
    plate.Material = Enum.Material.SmoothPlastic
    plate.CFrame = body.CFrame * CFrame.new(0, 0.1, vehicleData.size.Z / 2 + 0.05)
    plate.Parent = model

    local plateGui = Instance.new("SurfaceGui")
    plateGui.Face = Enum.NormalId.Front
    plateGui.CanvasSize = Vector2.new(280, 80)
    plateGui.Parent = plate

    local plateText = Instance.new("TextLabel")
    plateText.Size = UDim2.fromScale(1, 1)
    plateText.BackgroundTransparency = 1
    plateText.Font = Enum.Font.GothamBlack
    plateText.TextScaled = true
    plateText.TextColor3 = Color3.fromRGB(15, 15, 15)
    plateText.Text = randomPlate()
    plateText.Parent = plateGui

    local halfX = vehicleData.size.X / 2 - 0.4
    local halfZ = vehicleData.wheelBase

    local wheelFL = createWheel(model, body.Position + Vector3.new(-halfX, -1.1, -halfZ))
    local wheelFR = createWheel(model, body.Position + Vector3.new(halfX, -1.1, -halfZ))
    local wheelBL = createWheel(model, body.Position + Vector3.new(-halfX, -1.1, halfZ))
    local wheelBR = createWheel(model, body.Position + Vector3.new(halfX, -1.1, halfZ))

    for _, part in ipairs({roof, seat, plate, wheelFL, wheelFR, wheelBL, wheelBR}) do
        weld(body, part)
    end

    model.PrimaryPart = body
    model.Parent = workspace
    activeVehicle = model

    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = body.CFrame * CFrame.new(0, 4, -6)
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "SpanishCarSpawnerGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(390, 430)
panel.Position = UDim2.new(0.03, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 40)
title.Position = UDim2.fromOffset(8, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(240, 244, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Spawner de Coches (estilo FiveM)"
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -16, 0, 20)
subtitle.Position = UDim2.fromOffset(8, 42)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(166, 176, 200)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Matrícula española automática"
subtitle.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Position = UDim2.new(1, -40, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local listContainer = Instance.new("ScrollingFrame")
listContainer.Size = UDim2.new(1, -16, 1, -78)
listContainer.Position = UDim2.fromOffset(8, 68)
listContainer.BackgroundColor3 = Color3.fromRGB(23, 28, 39)
listContainer.BorderSizePixel = 0
listContainer.ScrollBarThickness = 6
listContainer.CanvasSize = UDim2.new(0, 0, 0, #VEHICLES * 48 + 12)
listContainer.Parent = panel

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 10)
listCorner.Parent = listContainer

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listContainer

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = listContainer

for i, vehicle in ipairs(VEHICLES) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.LayoutOrder = i
    button.BackgroundColor3 = Color3.fromRGB(40, 52, 75)
    button.TextColor3 = Color3.fromRGB(242, 245, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Text = "Spawn " .. vehicle.name
    button.Parent = listContainer

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        spawnVehicle(vehicle)
    end)
end

closeButton.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

local spawnerPad = Instance.new("Part")
spawnerPad.Name = "CarSpawnerPad"
spawnerPad.Shape = Enum.PartType.Cylinder
spawnerPad.Size = SPAWN_CIRCLE_SIZE
spawnerPad.Material = Enum.Material.Neon
spawnerPad.Color = Color3.fromRGB(56, 118, 255)
spawnerPad.Anchored = true
spawnerPad.CanCollide = false
spawnerPad.CFrame = SPAWN_CFRAME * CFrame.Angles(0, 0, math.rad(90))
spawnerPad.Parent = workspace

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Abrir spawner"
prompt.ObjectText = "Coches"
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 12
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.Parent = spawnerPad

prompt.Triggered:Connect(function(player)
    if player == localPlayer then
        panel.Visible = true
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F7 then
        panel.Visible = not panel.Visible
    end
end)
