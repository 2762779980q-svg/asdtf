-- ── Load Library ──────────────────────────────────────────────────────────────
local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau"))()

-- ── Services ──────────────────────────────────────────────────────────────────
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local function char() return LP.Character end
local function hum() local c = char(); return c and c:FindFirstChildOfClass("Humanoid") end
local function hrp() local c = char(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ── Notification ──────────────────────────────────────────────────────────────
local Notification = NeverLose:CreateNotification()

-- ── Window ────────────────────────────────────────────────────────────────────
local window = NeverLose:CreateWindow({
    Logo = NeverLose.GlobalLogo,
    Name = "Emden Hub",
    Content = "V1.0",
    Size = NeverLose.Scales.Default,
    ConfigFolder = "EmdenHubConfigs",
    Enable3DRenderer = false,
    Keybind = "RightAlt"
})

-- ── Tabs ──────────────────────────────────────────────────────────────────────
local Combat = window:AddTab({ Icon = 'crosshairs', Name = "战斗" })
local Visual = window:AddTab({ Icon = 'eye', Name = "视觉" })
--local AutoLoop = window:AddTab({ Icon = 'rotate', Name = "自动循环" })
--local CounterTab = window:AddTab({ Icon = 'shield', Name = "反击" })
--local SpamTab = window:AddTab({ Icon = 'repeat', Name = "连发" })
--local RKey = window:AddTab({ Icon = 'keyboard', Name = "R键" })
--local Protect = window:AddTab({ Icon = 'shield-check', Name = "保护" })
--local AllSkills = window:AddTab({ Icon = 'layers', Name = "全角色技能" })

-- ════════════════════════════════════════════════════════════════════════════
--  战斗
-- ════════════════════════════════════════════════════════════════════════════
local staminaConnection = nil
local cframeSpeedEnabled = false
local cframeSpeed = 100

local CombatMain = Combat:AddSection({ Name = "基础战斗" })
CombatMain:AddLabel('无限耐久'):AddToggle({ Default = false, Callback = function(v)
    if v then
        if staminaConnection then staminaConnection:Disconnect() end
        staminaConnection = RunService.Heartbeat:Connect(function()
            local args = { [1] = 50 }
            RS:WaitForChild("Client"):WaitForChild("Communication"):WaitForChild("ChangeStamia"):Fire(unpack(args))
        end)
        Notification.new({ Title = "无限耐久", Content = "已开启", Duration = 2 })
    else
        if staminaConnection then
            staminaConnection:Disconnect()
            staminaConnection = nil
        end
        Notification.new({ Title = "无限耐久", Content = "已关闭", Duration = 2 })
    end
end })

local CombatSpeed = Combat:AddSection({ Name = "CFrame加速" })
CombatSpeed:AddLabel('CFrame加速'):AddToggle({ Default = false, Callback = function(v) cframeSpeedEnabled = v end })
CombatSpeed:AddLabel('速度'):AddSlider({ Default = 100, Min = 10, Max = 500, Callback = function(v) cframeSpeed = v end })

local CombatHit = Combat:AddSection({ Name = "打人" })
local hitTargetName = ""
local hitLoopEnabled = false
local hitLoopConnection = nil
local hitDropdown = nil
local hitLoopLastTime = nil

local function GetNearestTargetName()
    local nearestName, nearestDist = nil, math.huge
    local charsContainer = Workspace:FindFirstChild("Characters")
    if not charsContainer then return nil end
    local myRoot = hrp()
    if not myRoot then return nil end
    local myChar = char()
    for _, charModel in pairs(charsContainer:GetChildren()) do
        if charModel:IsA("Model") and charModel ~= myChar then
            local root = charModel:FindFirstChild("HumanoidRootPart") or charModel:FindFirstChild("Head")
            if root then
                local dist = (myRoot.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestName = charModel.Name
                end
            end
        end
    end
    return nearestName
end

local function ExecuteHit()
    local targetName = hitTargetName
    if targetName == "" or targetName == "最近玩家" then
        targetName = GetNearestTargetName()
        if not targetName then
            Notification.new({ Title = "打人", Content = "附近没有玩家", Duration = 1.5 })
            return
        end
    end
    local target = workspace:WaitForChild("Characters"):WaitForChild(targetName)
    if not target then
        Notification.new({ Title = "打人", Content = "目标不存在: " .. targetName, Duration = 1.5 })
        return
    end
    local args = {
        [1] = {
            [1] = {
                [1] = {["Hit"] = target:WaitForChild("RightUpperLeg"), ["Model"] = target, ["HitType"] = 1},
                [2] = {["Hit"] = target:WaitForChild("LeftUpperLeg"), ["Model"] = target, ["HitType"] = 1},
                [3] = {["Hit"] = target:WaitForChild("LowerTorso"), ["Model"] = target, ["HitType"] = 1},
                [4] = {["Hit"] = target:WaitForChild("UpperTorso"), ["Model"] = target, ["HitType"] = 1},
                [5] = {["Hit"] = target:WaitForChild("LeftHand"), ["Model"] = target, ["HitType"] = 1},
                [6] = {["Hit"] = target:WaitForChild("LeftLowerArm"), ["Model"] = target, ["HitType"] = 1},
                [7] = {["Hit"] = target:WaitForChild("LeftUpperArm"), ["Model"] = target, ["HitType"] = 1},
                [8] = {["Hit"] = target:WaitForChild("HumanoidRootPart"), ["Model"] = target, ["HitType"] = 1},
                [9] = {["Hit"] = target:WaitForChild("RightLowerArm"), ["Model"] = target, ["HitType"] = 1},
                [10] = {["Hit"] = target:WaitForChild("RightHand"), ["Model"] = target, ["HitType"] = 1}
            },
            [2] = "\137"
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
end

CombatHit:AddButton({ Icon = 'refresh', Name = '刷新玩家列表', Callback = function()
    local options = {"最近玩家"}
    local charsContainer = Workspace:FindFirstChild("Characters")
    if charsContainer then
        for _, char in pairs(charsContainer:GetChildren()) do
            if char:IsA("Model") then
                table.insert(options, char.Name)
            end
        end
    end
    if #options > 1 then
        if hitDropdown then
            pcall(function() hitDropdown:SetValues(options) end)
            pcall(function() hitDropdown:SetValue("最近玩家") end)
        end
        hitTargetName = "最近玩家"
        Notification.new({ Title = "打人", Content = "已加载 " .. (#options - 1) .. " 个玩家, 默认: 最近玩家", Duration = 2 })
    else
        Notification.new({ Title = "打人", Content = "未找到玩家", Duration = 2 })
    end
end })

hitDropdown = CombatHit:AddLabel('选择目标'):AddDropdown({
    Default = "最近玩家",
    Values = {"最近玩家"},
    Callback = function(v) hitTargetName = v end
})

hitTargetName = "最近玩家"

-- 启动时自动加载玩家列表
task.spawn(function()
    task.wait(2)
    local options = {"最近玩家"}
    local charsContainer = Workspace:FindFirstChild("Characters")
    if charsContainer then
        for _, char in pairs(charsContainer:GetChildren()) do
            if char:IsA("Model") then
                table.insert(options, char.Name)
            end
        end
    end
    if #options > 1 and hitDropdown then
        pcall(function() hitDropdown:SetValues(options) end)
        pcall(function() hitDropdown:SetValue("最近玩家") end)
    end
end)

CombatHit:AddButton({ Icon = 'crosshair', Name = '执行攻击', Callback = ExecuteHit })

CombatHit:AddLabel('循环打人 (0.05s)'):AddToggle({ Default = false, Callback = function(v)
    hitLoopEnabled = v
    if v then
        if hitLoopConnection then hitLoopConnection:Disconnect() end
        hitLoopConnection = RunService.Heartbeat:Connect(function()
            if hitLoopEnabled then
                local now = os.clock()
                if not hitLoopLastTime then hitLoopLastTime = now end
                if now - hitLoopLastTime >= 0.05 then
                    hitLoopLastTime = now
                    pcall(ExecuteHit)
                end
            end
        end)
        hitLoopLastTime = nil
        Notification.new({ Title = "打人", Content = "循环打人已开启", Duration = 2 })
    else
        if hitLoopConnection then
            hitLoopConnection:Disconnect()
            hitLoopConnection = nil
        end
        hitLoopLastTime = nil
        Notification.new({ Title = "打人", Content = "循环打人已关闭", Duration = 2 })
    end
end })

CombatMain:AddButton({ Icon = 'play', Name = '示例按钮', Callback = function()
    Notification.new({ Title = "Emden Hub", Content = "按钮已触发", Duration = 2 })
end })

-- ════════════════════════════════════════════════════════════════════════════
--  隐身
-- ════════════════════════════════════════════════════════════════════════════
local invisEnabled = false
local invisDepth = -15
local invisConnection = nil
local invisClone = nil
local invisRealChar = nil
local invisHighlight = nil

local function startInvis()
    invisRealChar = char()
    if not invisRealChar or not invisRealChar:FindFirstChild("HumanoidRootPart") or not invisRealChar:FindFirstChildOfClass("Humanoid") then
        Notification.new({Title = "隐身失败", Content = "没有角色", Duration = 2})
        return
    end
    invisEnabled = true
    invisRealChar.Archivable = true
    local spawnCFrame = invisRealChar.HumanoidRootPart.CFrame
    invisClone = invisRealChar:Clone()
    invisClone.Name = LP.Name .. "_Ghost"
    invisClone.Parent = Workspace
    invisClone.HumanoidRootPart.CFrame = spawnCFrame

    local cloneAnimator = invisClone:FindFirstChildOfClass("Animator")
    local realAnimator = invisRealChar:FindFirstChildOfClass("Animator")
    if cloneAnimator and realAnimator then
        for _, track in ipairs(realAnimator:GetPlayingAnimationTracks()) do
            if track.Animation then
                local cloneTrack = cloneAnimator:LoadAnimation(track.Animation)
                cloneTrack:Play(); cloneTrack:AdjustSpeed(track.Speed)
                cloneTrack.TimePosition = track.TimePosition
            end
        end
    end
    local realHum = invisRealChar:FindFirstChildOfClass("Humanoid")
    local cloneHum = invisClone:FindFirstChildOfClass("Humanoid")
    if realHum and cloneHum then
        cloneHum.WalkSpeed = realHum.WalkSpeed
        cloneHum.JumpPower = realHum.JumpPower
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "InvisibilityHighlight"
    highlight.Adornee = invisRealChar
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = invisRealChar
    invisHighlight = highlight

    for _, part in ipairs(invisClone:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true; part.Anchored = false end
    end

    LP.Character = invisClone
    Workspace.CurrentCamera.CameraSubject = invisClone:FindFirstChildOfClass("Humanoid")

    invisConnection = RunService.Heartbeat:Connect(function()
        if not invisEnabled or not invisRealChar or not invisClone then return end
        local cloneHRP = invisClone:FindFirstChild("HumanoidRootPart")
        local realHRP = invisRealChar:FindFirstChild("HumanoidRootPart")
        for _, part in ipairs(invisRealChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end

        if cloneHRP and realHRP then
            local targetCFrame = cloneHRP.CFrame * CFrame.new(0, invisDepth, 0) * CFrame.Angles(math.pi, 0, 0)
            if (realHRP.Position - targetCFrame.Position).Magnitude > 0.5 then
                invisRealChar:PivotTo(targetCFrame)
            else
                realHRP.CFrame = targetCFrame
            end
            realHRP.AssemblyLinearVelocity = Vector3.zero
            realHRP.AssemblyAngularVelocity = Vector3.zero
        end

        local cAnim = invisClone:FindFirstChildOfClass("Animator")
        local rAnim = invisRealChar:FindFirstChildOfClass("Animator")
        if cAnim and rAnim then
            local cTracks = cAnim:GetPlayingAnimationTracks()
            local rTracks = rAnim:GetPlayingAnimationTracks()
            for _, ct in ipairs(cTracks) do
                local found = false
                for _, rt in ipairs(rTracks) do
                    if ct.Animation and rt.Animation and ct.Animation.AnimationId == rt.Animation.AnimationId then found = true; break end
                end
                if not found then ct:Stop() end
            end
            for _, rt in ipairs(rTracks) do
                if rt.Animation then
                    local exists = false
                    for _, ct in ipairs(cTracks) do
                        if ct.Animation and ct.Animation.AnimationId == rt.Animation.AnimationId then
                            ct:AdjustSpeed(rt.Speed); ct.TimePosition = rt.TimePosition; exists = true; break
                        end
                    end
                    if not exists then
                        local nt = cAnim:LoadAnimation(rt.Animation)
                        nt:Play(); nt:AdjustSpeed(rt.Speed)
                    end
                end
            end
        end
        local rHum = invisRealChar:FindFirstChildOfClass("Humanoid")
        local cHum = invisClone:FindFirstChildOfClass("Humanoid")
        if rHum and cHum then cHum.WalkSpeed = rHum.WalkSpeed; cHum.JumpPower = rHum.JumpPower end

        if invisHighlight then
            local depth = math.abs(invisDepth)
            if depth <= 10 then invisHighlight.FillColor = Color3.fromRGB(0, 255, 0)
            elseif depth <= 20 then invisHighlight.FillColor = Color3.fromRGB(255, 255, 0)
            else invisHighlight.FillColor = Color3.fromRGB(255, 100, 0) end
        end
    end)
    Notification.new({Title = "隐身", Content = "已开启 | 本体倒立隐藏", Duration = 2})
end

local function stopInvis()
    invisEnabled = false
    if invisConnection then invisConnection:Disconnect(); invisConnection = nil end
    if invisHighlight then invisHighlight:Destroy(); invisHighlight = nil end
    if invisRealChar and invisRealChar.Parent then
        LP.Character = invisRealChar
        Workspace.CurrentCamera.CameraSubject = invisRealChar:FindFirstChildOfClass("Humanoid")
        if invisClone and invisClone:FindFirstChild("HumanoidRootPart") and invisRealChar:FindFirstChild("HumanoidRootPart") then
            invisRealChar:PivotTo(invisClone:FindFirstChild("HumanoidRootPart").CFrame)
        end
        for _, part in ipairs(invisRealChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    end
    if invisClone then invisClone:Destroy(); invisClone = nil end
    Notification.new({Title = "隐身", Content = "已关闭", Duration = 2})
end

local CombatInvis = Combat:AddSection({ Name = "隐身" })
CombatInvis:AddLabel('隐身模式'):AddToggle({ Default = false, Callback = function(v)
    if v then startInvis() else stopInvis() end
end })
CombatInvis:AddLabel('地下深度'):AddSlider({ Min = -30, Max = -5, Default = -15, Callback = function(v) invisDepth = v end })

-- ════════════════════════════════════════════════════════════════════════════
--  视觉 (ESP)
-- ════════════════════════════════════════════════════════════════════════════
local VisualMain = Visual:AddSection({ Name = "玩家ESP" })

local espEnabled = false
local espBoxEnabled = true
local espNameEnabled = true
local espDistanceEnabled = true
local espHealthEnabled = false
local espTracerEnabled = false
local espDrawings = {}

local function clearESP()
    for _, d in ipairs(espDrawings) do
        pcall(function() d:Remove() end)
    end
    espDrawings = {}
end

local function updateESP()
    clearESP()
    if not espEnabled then return end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    local myChar = char()
    local charsContainer = Workspace:FindFirstChild("Characters")
    if not charsContainer then return end

    for _, target in ipairs(charsContainer:GetChildren()) do
        if not target:IsA("Model") or target == myChar then continue end

        local head = target:FindFirstChild("Head")
        local root = target:FindFirstChild("HumanoidRootPart")
        local targetHum = target:FindFirstChildOfClass("Humanoid")
        if not head or not root then continue end

        local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
        local rootPos = camera:WorldToViewportPoint(root.Position)

        if not onScreen then continue end

        local myRoot = hrp()
        local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
        local scale = math.clamp(1000 / math.max(dist, 1), 0.5, 3)

        -- 人体尺寸估算
        local topPos = camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, 1.5, 0)).Position)
        local bottomPos = camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3, 0)).Position)
        local height = math.abs(bottomPos.Y - topPos.Y)
        local width = height * 0.6
        local x, yTop = headPos.X, topPos.Y

        -- 方框
        if espBoxEnabled then
            local box = Drawing.new("Square")
            box.Visible = true
            box.Color = Color3.fromRGB(255, 255, 255)
            box.Thickness = 2
            box.Filled = false
            box.Position = Vector2.new(x - width / 2, yTop)
            box.Size = Vector2.new(width, height)
            table.insert(espDrawings, box)
        end

        -- 名字
        if espNameEnabled then
            local nameTxt = Drawing.new("Text")
            nameTxt.Visible = true
            nameTxt.Text = target.Name
            nameTxt.Color = Color3.fromRGB(255, 255, 255)
            nameTxt.Size = math.clamp(14 * scale, 11, 20)
            nameTxt.Center = true
            nameTxt.Outline = true
            nameTxt.OutlineColor = Color3.fromRGB(0, 0, 0)
            nameTxt.Position = Vector2.new(x, yTop - 22 * scale)
            table.insert(espDrawings, nameTxt)
        end

        -- 距离
        if espDistanceEnabled then
            local distTxt = Drawing.new("Text")
            distTxt.Visible = true
            distTxt.Text = string.format("[%.0fm]", dist)
            distTxt.Color = Color3.fromRGB(180, 180, 255)
            distTxt.Size = math.clamp(12 * scale, 10, 18)
            distTxt.Center = true
            distTxt.Outline = true
            distTxt.OutlineColor = Color3.fromRGB(0, 0, 0)
            distTxt.Position = Vector2.new(x, yTop - 22 * scale - 16 * scale)
            table.insert(espDrawings, distTxt)
        end

        -- 血量条
        if espHealthEnabled and targetHum then
            local healthPercent = math.clamp(targetHum.Health / targetHum.MaxHealth, 0, 1)
            local barW = 3
            local barX = x - width / 2 - 5
            local barY = yTop

            -- 背景
            local barBg = Drawing.new("Square")
            barBg.Visible = true
            barBg.Color = Color3.fromRGB(30, 30, 30)
            barBg.Filled = true
            barBg.Position = Vector2.new(barX, barY)
            barBg.Size = Vector2.new(barW, height)
            table.insert(espDrawings, barBg)

            -- 血量
            local barFill = Drawing.new("Square")
            local r = healthPercent < 0.5 and 255 or (255 * (1 - healthPercent) * 2)
            local g = healthPercent > 0.5 and 255 or (255 * healthPercent * 2)
            barFill.Visible = true
            barFill.Color = Color3.fromRGB(r, g, 0)
            barFill.Filled = true
            barFill.Position = Vector2.new(barX, barY + height * (1 - healthPercent))
            barFill.Size = Vector2.new(barW, height * healthPercent)
            table.insert(espDrawings, barFill)

            -- 边框
            local barOutline = Drawing.new("Square")
            barOutline.Visible = true
            barOutline.Color = Color3.fromRGB(0, 0, 0)
            barOutline.Thickness = 1
            barOutline.Filled = false
            barOutline.Position = Vector2.new(barX, barY)
            barOutline.Size = Vector2.new(barW, height)
            table.insert(espDrawings, barOutline)
        end

        -- 追踪线
        if espTracerEnabled then
            local viewport = camera.ViewportSize
            local line = Drawing.new("Line")
            line.Visible = true
            line.Color = Color3.fromRGB(255, 255, 255, 100)
            line.Thickness = 1
            line.From = Vector2.new(viewport.X / 2, viewport.Y)
            line.To = Vector2.new(x, bottomPos.Y)
            table.insert(espDrawings, line)
        end
    end
end

VisualMain:AddLabel('ESP总开关'):AddToggle({ Default = false, Callback = function(v) espEnabled = v; if not v then clearESP() end end })
VisualMain:AddLabel('方框'):AddToggle({ Default = true, Callback = function(v) espBoxEnabled = v end })
VisualMain:AddLabel('名字'):AddToggle({ Default = true, Callback = function(v) espNameEnabled = v end })
VisualMain:AddLabel('距离'):AddToggle({ Default = true, Callback = function(v) espDistanceEnabled = v end })
VisualMain:AddLabel('血量'):AddToggle({ Default = false, Callback = function(v) espHealthEnabled = v end })
VisualMain:AddLabel('追踪线'):AddToggle({ Default = false, Callback = function(v) espTracerEnabled = v end })

-- ════════════════════════════════════════════════════════════════════════════
--  快速互动
-- ════════════════════════════════════════════════════════════════════════════
local ProximityPromptService = game:GetService("ProximityPromptService")
local isFastInteract = false
local fastInteractConnection = nil
local interactDistance = 100

local function setFastInteract(enabled)
    isFastInteract = enabled
    if enabled then
        if fastInteractConnection then fastInteractConnection:Disconnect() end
        fastInteractConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
            if not prompt:GetAttribute("oHT") then prompt:SetAttribute("oHT", prompt.HoldDuration) end
            if not prompt:GetAttribute("oMD") then prompt:SetAttribute("oMD", prompt.MaxActivationDistance) end
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = interactDistance
        end)
        for _, p in ipairs(game:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                if not p:GetAttribute("oHT") then p:SetAttribute("oHT", p.HoldDuration) end
                if not p:GetAttribute("oMD") then p:SetAttribute("oMD", p.MaxActivationDistance) end
                p.HoldDuration = 0
                p.MaxActivationDistance = interactDistance
            end
        end
        Notification.new({ Title = "快速互动", Content = "已开启", Duration = 2 })
    else
        if fastInteractConnection then fastInteractConnection:Disconnect(); fastInteractConnection = nil end
        pcall(function()
            for _, p in ipairs(game:GetDescendants()) do
                if p and p.Parent and p:IsA("ProximityPrompt") then
                    pcall(function()
                        local o = p:GetAttribute("oHT")
                        if o then p.HoldDuration = o; p:SetAttribute("oHT", nil) end
                        local d = p:GetAttribute("oMD")
                        if d then p.MaxActivationDistance = d; p:SetAttribute("oMD", nil) end
                    end)
                end
            end
        end)
        Notification.new({ Title = "快速互动", Content = "已关闭", Duration = 2 })
    end
end

local FastInteractSection = Combat:AddSection({ Name = "快速互动" })
FastInteractSection:AddLabel('快速互动'):AddToggle({ Default = false, Callback = function(v) setFastInteract(v) end })
FastInteractSection:AddLabel('互动距离'):AddSlider({ Min = 10, Max = 5000, Default = 100, Callback = function(v) interactDistance = v end })

-- ════════════════════════════════════════════════════════════════════════════
--  HEARTBEAT
-- ════════════════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if cframeSpeedEnabled then
        local r = hrp()
        local h = hum()
        if r and h then
            local moveDir = h.MoveDirection
            if moveDir.Magnitude > 0 then
                r.CFrame = r.CFrame + moveDir.Unit * cframeSpeed * 0.016
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(updateESP)
end)

Notification.new({ Title = "Emden Hub", Content = "已加载! RightAlt开关", Duration = 3 })
