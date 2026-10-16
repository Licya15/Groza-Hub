local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Groza Hub",
    LoadingTitle = "Groza Hub",
    LoadingSubtitle = "by El Capo",
    Theme = "Amethyst"
})

-- ================= ГЛАВНАЯ =================
local MainTab = Window:CreateTab("Главная", 4483345998)

MainTab:CreateSlider({
    Name = "Speed Hack",
    Range = {16, 200},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "Walkspeed",
    Callback = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    Suffix = "jump",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

-- ================= ВИЗУАЛ =================
local VisualTab = Window:CreateTab("Visuals", 4483345998)

local espEnabled = false

local function getRole(plr)
    local char = plr.Character
    if not char then return "Unknown", Color3.fromRGB(255, 255, 255) end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        local n = tool.Name:lower()
        if n:find("knife") or n:find("sword") then return "Murderer", Color3.fromRGB(255, 0, 0) end
        if n:find("gun") or n:find("revolver") or n:find("pistol") then return "Sheriff", Color3.fromRGB(0, 100, 255) end
    end
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        local bt = backpack:FindFirstChildWhichIsA("Tool")
        if bt then
            local n = bt.Name:lower()
            if n:find("knife") or n:find("sword") then return "Murderer", Color3.fromRGB(255, 0, 0) end
            if n:find("gun") or n:find("revolver") or n:find("pistol") then return "Sheriff", Color3.fromRGB(0, 100, 255) end
        end
    end
    return "Innocent", Color3.fromRGB(0, 255, 0)
end

local function applyESP(plr)
    if plr == game.Players.LocalPlayer then return end
    if not espEnabled then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local role, color = getRole(plr)

    local hl = char:FindFirstChild("GrozaESP")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "GrozaESP"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.75
        hl.Parent = char
    end
    hl.FillColor = color
    hl.OutlineColor = color

    local bg = head:FindFirstChild("GrozaName")
    if not bg then
        bg = Instance.new("BillboardGui")
        bg.Name = "GrozaName"
        bg.Size = UDim2.new(0, 180, 0, 50)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        bg.MaxDistance = 250
        bg.Parent = head

        local txt = Instance.new("TextLabel")
        txt.Name = "Label"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        txt.TextYAlignment = Enum.TextYAlignment.Top
        txt.Text = role .. "\n" .. plr.Name
        txt.TextColor3 = color
        txt.Parent = bg
    else
        local label = bg:FindFirstChild("Label")
        if label then
            label.Text = role .. "\n" .. plr.Name
            label.TextColor3 = color
        end
    end
end

local function removeESP(plr)
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        local bg = head:FindFirstChild("GrozaName")
        if bg then bg:Destroy() end
    end
    local hl = char:FindFirstChild("GrozaESP")
    if hl then hl:Destroy() end
end

VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        espEnabled = Value
        if Value then
            for _, plr in pairs(game.Players:GetPlayers()) do applyESP(plr) end
        else
            for _, plr in pairs(game.Players:GetPlayers()) do removeESP(plr) end
        end
    end
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if espEnabled then
            for _, plr in pairs(game.Players:GetPlayers()) do applyESP(plr) end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        applyESP(plr)
    end)
end)
game.Players.PlayerRemoving:Connect(removeESP)

-- ================= ТРОЛЛ =================
local TrollTab = Window:CreateTab("Тролл", 4483345998)

local flingEnabled = false
local flingTarget = nil
local selectedFlingName = ""
local flingConnection = nil

local function refreshFlingList()
    local list = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    if _G.FlingDropdown then
        _G.FlingDropdown:Refresh(list, true)
    end
end

_G.FlingDropdown = TrollTab:CreateDropdown({
    Name = "Выбери цель",
    Options = {},
    CurrentOption = "",
    Flag = "FlingTarget",
    Callback = function(Value) selectedFlingName = Value end
})

refreshFlingList()
game.Players.PlayerAdded:Connect(function() task.wait(1) refreshFlingList() end)
game.Players.PlayerRemoving:Connect(function() task.wait(1) refreshFlingList() end)

local function startFlingLoop(targetPlr)
    if flingConnection then flingConnection:Disconnect() end
    flingTarget = targetPlr

    flingConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flingEnabled then
            if flingConnection then flingConnection:Disconnect() flingConnection = nil end
            return
        end
        if not flingTarget or not flingTarget.Character then return end

        local targetHrp = flingTarget.Character:FindFirstChild("HumanoidRootPart")
        local myChar = game.Players.LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not targetHrp or not myHrp then return end

        if targetHrp.Position.Y > 500 or targetHrp.Position.Magnitude > 3000 then return end

        local angle = tick() * 1000
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(math.cos(angle) * 2, 0, math.sin(angle) * 2)
        targetHrp.CFrame = targetHrp.CFrame * CFrame.new(math.cos(angle) * 5, math.sin(angle) * 5, math.cos(angle) * 5)
        targetHrp.Velocity = Vector3.new(math.cos(angle) * 1000, 1000, math.sin(angle) * 1000)
        targetHrp.RotVelocity = Vector3.new(999999, 999999, 999999)
    end)
end

TrollTab:CreateToggle({
    Name = "Fling Selected",
    CurrentValue = false,
    Flag = "FlingSelected",
    Callback = function(Value)
        flingEnabled = Value
        if Value then
            if not selectedFlingName or selectedFlingName == "" then
                Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока", Duration = 3})
                flingEnabled = false
                return
            end
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr.Name == selectedFlingName then
                    startFlingLoop(plr)
                    break
                end
            end
        else
            if flingConnection then flingConnection:Disconnect() flingConnection = nil end
        end
    end
})

TrollTab:CreateButton({
    Name = "Fling Murderer",
    Callback = function()
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character then
                local char = plr.Character
                local isMurderer = false
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("sword")) then isMurderer = true end
                local backpack = plr:FindFirstChild("Backpack")
                if backpack then
                    local bt = backpack:FindFirstChildWhichIsA("Tool")
                    if bt and (bt.Name:lower():find("knife") or bt.Name:lower():find("sword")) then isMurderer = true end
                end
                if isMurderer then
                    flingEnabled = true
                    startFlingLoop(plr)
                    break
                end
            end
        end
    end
})

TrollTab:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character then
                local char = plr.Character
                local isSheriff = false
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("pistol")) then isSheriff = true end
                local backpack = plr:FindFirstChild("Backpack")
                if backpack then
                    local bt = backpack:FindFirstChildWhichIsA("Tool")
                    if bt and (bt.Name:lower():find("gun") or bt.Name:lower():find("revolver") or bt.Name:lower():find("pistol")) then isSheriff = true end
                end
                if isSheriff then
                    flingEnabled = true
                    startFlingLoop(plr)
                    break
                end
            end
        end
    end
})

TrollTab:CreateButton({
    Name = "Fling All",
    Callback = function()
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(999999, 999999, 999999)
                    hrp.RotVelocity = Vector3.new(999999, 999999, 999999)
                end
            end
        end
    end
})

local antiFlingEnabled = false
local antiFlingLoop = nil

TrollTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Flag = "AntiFling",
    Callback = function(Value)
        antiFlingEnabled = Value
        if Value then
            if antiFlingLoop then antiFlingLoop:Disconnect() end
            antiFlingLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not antiFlingEnabled then
                    if antiFlingLoop then antiFlingLoop:Disconnect() antiFlingLoop = nil end
                    return
                end
                local c = game.Players.LocalPlayer.Character
                if not c then return end
                local h = c:FindFirstChild("HumanoidRootPart")
                if not h then return end
                for _, obj in pairs(h:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyForce") or obj:IsA("BodyGyro") then
                        if obj.Name ~= "GrozaFlyVelocity" and obj.Name ~= "GrozaFlyGyro" then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
                if h.Velocity.Magnitude > 60 then
                    h.Velocity = Vector3.new(0, h.Velocity.Y, 0)
                    h.RotVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            if antiFlingLoop then antiFlingLoop:Disconnect() antiFlingLoop = nil end
        end
    end
})
