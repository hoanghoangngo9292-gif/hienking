-- ================================
-- HIEN VIP FIXLAG - HWID + THỜI HẠN
-- ================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function getHWID()
    return (gethwid and gethwid())
        or (game:GetService("RbxAnalyticsService"):GetClientId())
        or "Unknown"
end

local function isExpired(dateStr)
    if dateStr == "forever" then return false end
    local y, m, d = dateStr:match("(%d+)-(%d+)-(%d+)")
    if not y then return true end
    y, m, d = tonumber(y), tonumber(m), tonumber(d)
    local nowUTC = os.time()
    local nowVN = nowUTC + 7 * 3600
    local t = os.date("!*t", nowVN)
    local todayY, todayM, todayD = t.year, t.month, t.day
    if todayY > y then return true end
    if todayY == y and todayM > m then return true end
    if todayY == y and todayM == m and todayD > d then return true end
    return false
end

local JSONBIN_URL = "https://api.jsonbin.io/v3/b/69f70bdcaaba8821976677a0/latest"
local JSONBIN_KEY = "$2a$10$3dZhQhscBbWpVvSlJLEfve1EAcLFMYAX/TAw06LndJOcKfOLQe2k2"

local function checkWhitelist(hwid)
    local _status = "notwhitelisted"
    local _date = nil
    pcall(function()
        local requesting = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
        if not requesting then return end
        local res = requesting({
            Url = JSONBIN_URL,
            Method = "GET",
            Headers = { ["X-Master-Key"] = JSONBIN_KEY }
        })
        if not res or not res.Body then return end
        local data = game:GetService("HttpService"):JSONDecode(res.Body)
        local hwids = data and data.record and data.record.hwids
        if not hwids then return end
        for _, entry in ipairs(hwids) do
            if entry.hwid == hwid then
                _date = entry.expDate
                _status = isExpired(entry.expDate) and "expired" or "whitelisted"
                return
            end
        end
    end)
    return _status, _date
end

local function daysRemaining(dateStr)
    if dateStr == "forever" then return "Vinh vien" end
    local y, m, d = dateStr:match("(%d+)-(%d+)-(%d+)")
    if not y then return "?" end
    y, m, d = tonumber(y), tonumber(m), tonumber(d)
    local t = os.date("*t")
    local diff = math.floor((os.time({year=y,month=m,day=d,hour=23,min=59,sec=59}) - os.time({year=t.year,month=t.month,day=t.day,hour=0,min=0,sec=0})) / 86400)
    if diff < 0 then return "Het han" end
    return diff .. " ngay"
end

local function createBaseUI(titleText, titleColor)
    local gui = Instance.new("ScreenGui"); gui.Name = "SALUNAUI"; gui.Parent = game.CoreGui
    local SSS = Instance.new("Frame"); SSS.Parent = gui; SSS.BackgroundTransparency = 1
    SSS.AnchorPoint = Vector2.new(0.5,0.5); SSS.Position = UDim2.new(0.5,0,0.5,0); SSS.Size = UDim2.new(0,0,0,0)
    local FRAME = Instance.new("Frame"); FRAME.Parent = SSS; FRAME.BackgroundColor3 = Color3.fromRGB(0,0,0)
    FRAME.BackgroundTransparency = 0.2; FRAME.ClipsDescendants = true
    FRAME.Position = UDim2.new(0.183,1,0.119,1); FRAME.Size = UDim2.new(0.631,0,0.756,0)
    Instance.new("UICorner",FRAME).CornerRadius = UDim.new(0.03,0)
    local Owner = Instance.new("ImageLabel"); Owner.Parent = FRAME; Owner.BackgroundTransparency = 1
    Owner.Position = UDim2.new(0.638,0,0.383,0); Owner.Size = UDim2.new(0.276,0,0.518,0)
    Owner.Image = "rbxassetid://108249120255582"; Instance.new("UICorner",Owner).CornerRadius = UDim.new(0.1,0)
    local Cancel = Instance.new("ImageButton"); Cancel.Parent = SSS; Cancel.BackgroundTransparency = 1
    Cancel.Position = UDim2.new(0.814,0,0.06,0); Cancel.Size = UDim2.new(0.048,0,0.1,0)
    Cancel.Image = "http://www.roblox.com/asset/?id=7729954373"
    Cancel.MouseButton1Up:Connect(function()
        TweenService:Create(Cancel,TweenInfo.new(0.1),{Size=UDim2.new(0.038,0,0.08,0)}):Play()
        task.wait(0.2)
        local t = TweenService:Create(SSS,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(0,0,0,0)})
        t:Play(); t.Completed:Connect(function() gui:Destroy() end)
    end)
    local Invalid = Instance.new("TextLabel"); Invalid.Parent = SSS
    Invalid.BackgroundColor3 = Color3.fromRGB(0,0,0); Invalid.BackgroundTransparency = 0.2
    Invalid.Position = UDim2.new(0.216,0,0.011,0); Invalid.Size = UDim2.new(0.564,0,0.102,0)
    Invalid.TextColor3 = titleColor; Invalid.Text = ""; Invalid.TextScaled = true
    Invalid.FontFace.Bold = true; Invalid.Font = Enum.Font.Merriweather
    local Tieude = Instance.new("TextLabel"); Tieude.Parent = FRAME; Tieude.BackgroundTransparency = 1
    Tieude.Position = UDim2.new(0.081,0,0.103,0); Tieude.Size = UDim2.new(0.833,0,0.177,0)
    Tieude.Text = ""; Tieude.TextColor3 = Color3.fromRGB(0,255,127); Tieude.TextScaled = true
    Tieude.FontFace.Bold = true; Tieude.Font = Enum.Font.Merriweather
    local FIXLAG = Instance.new("TextLabel"); FIXLAG.Parent = FRAME; FIXLAG.BackgroundTransparency = 1
    FIXLAG.Position = UDim2.new(0.519,0,0.371,0); FIXLAG.Size = UDim2.new(0.2,0,0.537,0)
    FIXLAG.Text = ""; FIXLAG.TextColor3 = Color3.fromRGB(255,255,0); FIXLAG.TextScaled = true
    FIXLAG.FontFace.Bold = true; FIXLAG.Font = Enum.Font.Merriweather
    local DiscordImage = Instance.new("ImageLabel"); DiscordImage.Parent = FRAME; DiscordImage.BackgroundTransparency = 1
    DiscordImage.Position = UDim2.new(0.397,0,0.403,0); DiscordImage.Size = UDim2.new(0.098,0,0.148,0)
    DiscordImage.Image = "http://www.roblox.com/asset/?id=17056354120"
    Instance.new("UICorner",DiscordImage).CornerRadius = UDim.new(1,0)
    local DISCORD = Instance.new("TextButton"); DISCORD.Parent = FRAME
    DISCORD.BackgroundColor3 = Color3.fromRGB(0,255,127); DISCORD.Position = UDim2.new(0.081,0,0.384,0)
    DISCORD.Size = UDim2.new(0.3,0,0.21,0); DISCORD.BorderSizePixel = 2
    DISCORD.BorderColor3 = Color3.fromRGB(0,200,127); DISCORD.Text = ""; DISCORD.TextScaled = true
    DISCORD.Font = Enum.Font.Merriweather; Instance.new("UICorner",DISCORD).CornerRadius = UDim.new(0.1,0)
    DISCORD.MouseButton1Up:Connect(function()
        local cb = toclipboard or setclipboard
        if cb then cb("discord.gg/x9pATE8Uxe"); DISCORD.Text = "✅ Copied!"
            task.delay(1.5, function() DISCORD.Text = "Discord" end) end
    end)
    local FacebookImage = Instance.new("ImageLabel"); FacebookImage.Parent = FRAME; FacebookImage.BackgroundTransparency = 1
    FacebookImage.Position = UDim2.new(0.397,0,0.71,0); FacebookImage.Size = UDim2.new(0.098,0,0.148,0)
    FacebookImage.Image = "http://www.roblox.com/asset/?id=5265119620"
    Instance.new("UICorner",FacebookImage).CornerRadius = UDim.new(0.2,0)
    local FACEBOOK = Instance.new("TextButton"); FACEBOOK.Parent = FRAME
    FACEBOOK.BackgroundColor3 = Color3.fromRGB(0,255,127); FACEBOOK.Position = UDim2.new(0.081,0,0.691,0)
    FACEBOOK.Size = UDim2.new(0.3,0,0.21,0); FACEBOOK.BorderSizePixel = 2
    FACEBOOK.BorderColor3 = Color3.fromRGB(0,200,127); FACEBOOK.Text = ""; FACEBOOK.TextScaled = true
    FACEBOOK.Font = Enum.Font.Merriweather; Instance.new("UICorner",FACEBOOK).CornerRadius = UDim.new(0.1,0)
    FACEBOOK.MouseButton1Up:Connect(function()
        local cb = toclipboard; if cb then cb("https://www.facebook.com/share/1Akictracm/?mibextid=wwXIfr") end
        FACEBOOK.Text = "✅ Copied!"; task.wait(1.5); FACEBOOK.Text = "Facebook"
    end)
    local openTween = TweenService:Create(SSS,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,1,0)})
    openTween:Play()
    openTween.Completed:Connect(function()
        spawn(function() for i=1,#titleText do Invalid.Text=string.sub(titleText,1,i) task.wait(0.05) end end)
        spawn(function() local msg="Contact Information" for i=1,#msg do Tieude.Text=string.sub(msg,1,i) task.wait(0.07) end end)
        spawn(function() local msg="Discord" for i=1,#msg do DISCORD.Text=string.sub(msg,1,i) task.wait(0.1) end end)
        spawn(function() local msg="Facebook" for i=1,#msg do FACEBOOK.Text=string.sub(msg,1,i) task.wait(0.1) end end)
        spawn(function()
            local alphabet={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
            local target={"F","I","X","L","A","G"}
            local function animate()
                local cur={} for ti=1,#target do for _,a in ipairs(alphabet) do task.wait(0.07) cur[ti]=a FIXLAG.Text=table.concat(cur,"\n") if a==target[ti] then break end end end
            end
            animate()
            while game.CoreGui:FindFirstChild("SALUNAUI") do task.wait(4) animate() end
        end)
    end)
    return SSS, FRAME, gui
end

local function showNotWhitelistedUI()
    local SSS,FRAME,gui = createBaseUI("YOU ARE NOT WHITELISTED!", Color3.fromRGB(255,0,0))
    local HWIDGet = Instance.new("TextButton"); HWIDGet.Parent = SSS
    HWIDGet.BackgroundColor3 = Color3.fromRGB(0,255,127); HWIDGet.BackgroundTransparency = 0.1
    HWIDGet.Position = UDim2.new(0.014,0,0.309,0); HWIDGet.Size = UDim2.new(0.145,0,0.2,0)
    HWIDGet.TextColor3 = Color3.fromRGB(0,0,0); HWIDGet.BorderSizePixel = 2
    HWIDGet.BorderColor3 = Color3.fromRGB(0,200,127); HWIDGet.Text = "Get HWID"
    HWIDGet.TextWrapped = true; HWIDGet.TextScaled = true; HWIDGet.Font = Enum.Font.Merriweather
    Instance.new("UICorner",HWIDGet).CornerRadius = UDim.new(0.1,0)
    HWIDGet.MouseButton1Up:Connect(function()
        local hwid = getHWID(); local cb = toclipboard
        if cb then cb(tostring(hwid)) end
        HWIDGet.Text = "✅ Copied!"; task.wait(1.5); HWIDGet.Text = "Get HWID"
    end)
end

local function showExpiredUI()
    createBaseUI("SCRIPT DA HET HAN SU DUNG!", Color3.fromRGB(255,150,0))
end

local function runFixLag()
    getgenv().Enabled = true
    local Lighting = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")
    local TeleportService = game:GetService("TeleportService")
    local VirtualUser = game:GetService("VirtualUser")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    -- ================================
    -- FPS AUTO-RECOVERY (iPhone + Android + PC)
    -- Tự nhận diện FPS tuột → khôi phục ngay
    -- ================================
    local function setFPSCap(cap)
        pcall(function() if setfpscap then setfpscap(cap) end end)
        pcall(function() if syn and syn.set_fps_cap then syn.set_fps_cap(cap) end end)
        pcall(function() if setfps then setfps(cap) end end)
        pcall(function() if set_fps_cap then set_fps_cap(cap) end end)
        pcall(function() if fluxus and fluxus.set_fps_cap then fluxus.set_fps_cap(cap) end end)
    end

    -- Target FPS theo thiết bị
    -- iPhone/Android (TouchEnabled) = 60, PC = 144
    local targetFPS = isMobile and 60 or 144
    setFPSCap(targetFPS)

    -- ✅ AUTO-RECOVERY: đo FPS thực mỗi 3s
    -- FPS tuột xuống 20-30 → set lại cap lên 60 (mobile) / 144 (PC) ngay
    task.spawn(function()
        while true do
            task.wait(3)
            -- Đo FPS thực trong 1s
            local frames = 0
            local conn = RunService.Heartbeat:Connect(function() frames = frames + 1 end)
            task.wait(1)
            conn:Disconnect()
            local realFPS = frames

            -- Bất kể 20 hay 30 fps → luôn nhảy lên targetFPS (60/144)
            if realFPS < 55 then
                setFPSCap(targetFPS)
                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    settings().Rendering.FrameRateManager = 0
                end)
            end
        end
    end)

    -- ================================
    -- NETWORK OWNER + PHYSICS
    -- ================================
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7,0.3,0.5,0.1,0.1) end
                    for _,part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then pcall(function() part:SetNetworkOwner(LocalPlayer) end) end
                    end
                end
            end)
        end
    end)

    -- ================================
    -- RENDER SETTINGS (set 1 lần, loop nhẹ 30s cho physics)
    -- ================================
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.FrameRateManager = 0
    end)
    task.spawn(function()
        while true do
            task.wait(30)
            pcall(function()
                settings().Physics.AllowSleep = true
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always
            end)
        end
    end)

    -- ================================
    -- GC TIMER (tách khỏi Heartbeat hoàn toàn — tránh stutter)
    -- ================================
    task.spawn(function() while true do task.wait(30) pcall(function() collectgarbage("collect") end) end end)

    task.spawn(function() while true do task.wait(5) pcall(function() settings().Network.IncomingReplicationLag = 0 end) end end)

    -- ================================
    -- LIGHTING
    -- ================================
    Lighting.GlobalShadows = false; Lighting.FogEnd = 1e10; Lighting.FogStart = 1e10
    Lighting.Brightness = 1; Lighting.Ambient = Color3.fromRGB(128,128,128)
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128); Lighting.ClockTime = 14; Lighting.GeographicLatitude = 0
    pcall(function() Lighting.EnvironmentalDiffuseScale = 0 end)
    pcall(function() Lighting.EnvironmentalSpecularScale = 0 end)
    pcall(function() Lighting.ExposureCompensation = 0 end)
    for _,v in pairs(Lighting:GetChildren()) do
        pcall(function()
            if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("BloomEffect") then v:Destroy() end
        end)
    end

    pcall(function() settings().Network.IncomingReplicationLag = 0 end)
    pcall(function()
        workspace.Terrain.CastShadow = false; workspace.Terrain.Decoration = false
        workspace.Terrain.WaterWaveSize = 0; workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0; workspace.Terrain.WaterTransparency = 0
    end)
    pcall(function() workspace.GlobalShadows = false end)
    pcall(function()
        local SS = game:GetService("SoundService")
        SS.AmbientReverb = Enum.ReverbType.NoReverb; SS.DopplerScale = 0
    end)
    -- ================================
    -- HELPER FUNCTIONS
    -- ================================
    local function isNPCPart(v)
        local p = v.Parent
        while p and p ~= workspace do
            if p:FindFirstChildOfClass("Humanoid") then return true end
            p = p.Parent
        end
        return false
    end

    -- FIX: Nhận diện debris/hiệu ứng vỡ đất theo tên phổ biến
    local debrisKeywords = {
        "Debris", "debris", "Crack", "crack", "Break", "break",
        "Shatter", "shatter", "Rubble", "rubble", "Fragment", "fragment",
        "Chunk", "chunk", "Splinter", "splinter", "Crumble", "crumble",
        "Dust", "dust", "Impact", "impact", "Explosion", "explosion",
        "Destroy", "destroy", "Collapse", "collapse", "Broken", "broken",
    }
    local function isDebrisObject(v)
        local name = v.Name or ""
        for _, kw in ipairs(debrisKeywords) do
            if name:find(kw) then return true end
        end
        return false
    end

    -- FIX: Nhận diện công trình/building dễ bị xóa lặp lại
    local buildingKeywords = {
        "Building", "building", "House", "house", "Wall", "wall",
        "Structure", "structure", "Tower", "tower", "Bridge", "bridge",
        "Road", "road", "Platform", "platform",
    }
    local function isBuildingDebris(v)
        -- Chỉ match nếu tên có cả keyword + dấu hiệu tạm thời (số cuối / clone)
        local name = v.Name or ""
        for _, kw in ipairs(buildingKeywords) do
            if name:find(kw) and (name:match("%d+$") or name:find("Clone") or name:find("Temp")) then
                return true
            end
        end
        return false
    end

    local function processObject(v)
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled=false; v.Rate=0
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                if not isNPCPart(v) then v:Destroy() end
            end
            if v:IsA("BasePart") then
                v.CastShadow=false; v.Reflectance=0
                if not isNPCPart(v) then v.Material=Enum.Material.SmoothPlastic end
            end
            if v:IsA("MeshPart") then
                v.RenderFidelity=Enum.RenderFidelity.Automatic
                if not isNPCPart(v) then v.TextureID="" end
            end
            if v:IsA("Sound") then v.RollOffMaxDistance=30; v.Volume=math.min(v.Volume,0.5) end
            if v:IsA("Beam") then v.Enabled=false end
            if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled=false end
            if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v.MaxDistance=30 end
            if v:IsA("SelectionBox") or v:IsA("SelectionSphere") then v:Destroy() end
            if v:IsA("PostEffect") then v:Destroy() end
            -- FIX: Xóa debris/hiệu ứng vỡ đất
            if (v:IsA("BasePart") or v:IsA("Model")) and isDebrisObject(v) and not isNPCPart(v) then
                v:Destroy()
            end
            -- FIX: Xóa công trình tạm thời (clone/temp)
            if (v:IsA("BasePart") or v:IsA("Model")) and isBuildingDebris(v) and not isNPCPart(v) then
                v:Destroy()
            end
        end)
    end

    -- FIX: scan toàn map yield mỗi 50 (từ 100 xuống) cho mượt hơn
    local function fixLag()
        local list = game:GetDescendants(); local i = 0
        for _,v in ipairs(list) do i=i+1; processObject(v); if i%50==0 then task.wait() end end
    end

    task.spawn(fixLag)
    workspace.DescendantAdded:Connect(function(v)
        task.defer(function()
            processObject(v)
            local children = v:GetDescendants()
            for i,child in ipairs(children) do processObject(child); if i%30==0 then task.wait() end end
        end)
    end)
    -- FIX: scan định kỳ 90s thay vì 60s để giảm tải
    task.spawn(function() while true do task.wait(90) task.spawn(fixLag) end end)

    -- ================================
    -- CULLING (ẩn object xa) — FIX tần suất
    -- ================================
    task.spawn(function()
        while true do
            task.wait(8) -- tăng từ 5s lên 8s
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position; local i = 0
                for _,v in ipairs(workspace:GetDescendants()) do
                    i=i+1
                    pcall(function()
                        if v:IsA("BasePart") and v.Parent ~= char then
                            if not isNPCPart(v) then
                                v.LocalTransparencyModifier = (v.Position-pos).Magnitude > 250 and 1 or 0
                            else
                                v.LocalTransparencyModifier = 0
                            end
                        end
                    end)
                    if i%150==0 then task.wait() end
                end
            end
        end
    end)

    -- ================================
    -- OTHER PLAYER CULLING — FIX tần suất
    -- ================================
    task.spawn(function()
        while true do
            task.wait(15) -- tăng từ 10s lên 15s
            local char = LocalPlayer.Character
            local myPos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    pcall(function()
                        local dist = 999
                        if myPos and plr.Character:FindFirstChild("HumanoidRootPart") then
                            dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                        end
                        for _,v in ipairs(plr.Character:GetDescendants()) do
                            pcall(function()
                                if v:IsA("BasePart") then v.LocalTransparencyModifier = dist > 100 and 1 or 0 end
                                if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false end
                            end)
                        end
                    end)
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            pcall(function()
                settings().Physics.AllowSleep = true
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always
            end)
            task.wait(5)
        end
    end)

    -- ================================
    -- ANTI-AFK 4 LỚP ✅
    -- Lớp 1: Bắt sự kiện Idled
    -- Lớp 2: VirtualUser click mỗi 55s
    -- Lớp 3: Di chuyển nhỏ mỗi 110s
    -- Lớp 4: Jump mỗi 180s
    -- ================================
    -- Lớp 1
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
    end)
    -- Lớp 2
    task.spawn(function()
        while true do
            task.wait(55)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0))
            end)
        end
    end)
    -- Lớp 3
    task.spawn(function()
        while true do
            task.wait(110)
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    hrp.CFrame = hrp.CFrame * CFrame.new(0.1,0,0); task.wait(0.2)
                    hrp.CFrame = hrp.CFrame * CFrame.new(-0.1,0,0)
                end
            end)
        end
    end)
    -- Lớp 4
    task.spawn(function()
        while true do
            task.wait(180)
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                end
            end)
        end
    end)

    -- ================================
    -- AUTO REJOIN
    -- ================================
    local savedPlaceId = game.PlaceId; local savedJobId = game.JobId; local rejoining = false
    local function doRejoin()
        if rejoining then return end; rejoining = true; task.wait(3)
        pcall(function() TeleportService:TeleportToPlaceInstance(savedPlaceId,savedJobId,LocalPlayer) end)
        task.wait(5); pcall(function() TeleportService:Teleport(savedPlaceId,LocalPlayer) end)
    end
    LocalPlayer.OnTeleport:Connect(function(state) if state == Enum.TeleportState.RequestedFromServer then doRejoin() end end)
    LocalPlayer.AncestryChanged:Connect(function() if not LocalPlayer:IsDescendantOf(game) then doRejoin() end end)
    pcall(function() game:GetService("NetworkClient").ConnectionFailed:Connect(function() doRejoin() end) end)

    local placeId = game.PlaceId

    -- ================================
    -- 🍏 BLOX FRUIT
    -- ================================
    if placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635 then
        task.spawn(function()
            while true do
                for _,plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        for _,v in pairs(plr.Character:GetDescendants()) do
                            pcall(function() if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false end end)
                        end
                    end
                end
                task.wait(3)
            end
        end)
    end

    -- ================================
    -- ⛵ SAILOR PIECE — ĐÃ FIX HOÀN TOÀN
    -- FIX MỚI: Xóa toàn bộ map (không phải NPC), giữ NPC nguyên vẹn
    -- Tránh Gameplay Paused bằng cách chờ load xong + flag sailorReady
    -- ================================
    if placeId == 11483202072 then

        local sailorReady = false

        local function isSailorNPC(obj)
            local p = obj
            while p and p ~= workspace do
                if p:FindFirstChildOfClass("Humanoid") then return true end
                p = p.Parent
            end
            return false
        end

        local function isMyChar(obj)
            local char = LocalPlayer.Character; if not char then return false end
            local p = obj
            while p do if p == char then return true end; p = p.Parent end
            return false
        end

        -- ✅ XÓA MAP HOÀN TOÀN: Destroy BasePart/Model không phải NPC, không phải char mình
        -- Giữ nguyên NPC (có Humanoid), giữ Terrain
        local function sailorDestroyMap()
            if not sailorReady then return end
            local list = workspace:GetChildren()
            local i = 0
            for _, obj in ipairs(list) do
                i = i + 1
                if not sailorReady then return end
                pcall(function()
                    -- Giữ lại: character mình, NPC, Terrain, Camera
                    if obj == workspace.Terrain then return end
                    if obj == LocalPlayer.Character then return end
                    if obj:IsA("Camera") then return end
                    -- Giữ NPC
                    if obj:FindFirstChildOfClass("Humanoid") then return end
                    -- Các object trong Players (không đụng)
                    -- Xóa BasePart, Model, Folder chứa map
                    if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") then
                        -- Kiểm tra con cháu có Humanoid không trước khi xóa
                        local hasNPC = false
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("Humanoid") then hasNPC = true; break end
                        end
                        if not hasNPC then
                            obj:Destroy()
                        else
                            -- Có NPC bên trong → chỉ xóa những phần không phải NPC
                            for _, child in ipairs(obj:GetChildren()) do
                                pcall(function()
                                    if not child:FindFirstChildOfClass("Humanoid") and not child:IsA("Humanoid") then
                                        if child:IsA("BasePart") or child:IsA("Model") then
                                            -- check deeper
                                            local deepNPC = false
                                            for _, cc in ipairs(child:GetDescendants()) do
                                                if cc:IsA("Humanoid") then deepNPC = true; break end
                                            end
                                            if not deepNPC then child:Destroy() end
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
                if i % 20 == 0 then task.wait() end
            end
        end

        -- Scan nhẹ cho hiệu ứng + lighting sau khi map đã xóa
        local function sailorLightScan()
            if not sailorReady then return end
            local list = workspace:GetDescendants(); local i = 0
            for _,v in ipairs(list) do
                i = i + 1
                if not sailorReady then return end
                pcall(function()
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                        v.Enabled = false
                    elseif v:IsA("Sound") then
                        v.RollOffMaxDistance = 25
                    elseif v:IsA("BasePart") then
                        v.CastShadow = false
                        -- Vẫn cull NPC xa
                        if isSailorNPC(v) and not isMyChar(v) then
                            local char = LocalPlayer.Character
                            local pos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position
                            if pos then
                                v.LocalTransparencyModifier = (v.Position - pos).Magnitude > 120 and 1 or 0
                            end
                        end
                    end
                end)
                if i % 30 == 0 then task.wait() end
            end
        end

        -- Detect teleport → tạm dừng
        LocalPlayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Started then
                sailorReady = false
            end
        end)

        local function initSailor()
            sailorReady = false
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if not char:FindFirstChild("HumanoidRootPart") then
                char:WaitForChild("HumanoidRootPart", 10)
            end
            -- ✅ Chờ 5s để game load map hoàn toàn
            task.wait(5)
            sailorReady = true
            -- Xóa map trước, sau đó scan nhẹ
            task.spawn(sailorDestroyMap)
            task.wait(2)
            task.spawn(sailorLightScan)
        end

        task.spawn(initSailor)
        LocalPlayer.CharacterAdded:Connect(function() task.spawn(initSailor) end)

        -- Scan nhẹ định kỳ mỗi 15s (chỉ scan hiệu ứng + cull NPC)
        task.spawn(function()
            while true do
                task.wait(15)
                if sailorReady then task.spawn(sailorLightScan) end
            end
        end)

        -- Xóa map lại mỗi 30s (map động có thể respawn)
        task.spawn(function()
            while true do
                task.wait(30)
                if sailorReady then task.spawn(sailorDestroyMap) end
            end
        end)

        -- DescendantAdded: delay 3s, xóa nếu không phải NPC
        workspace.DescendantAdded:Connect(function(v)
            if not sailorReady then return end
            task.delay(3, function()
                if not sailorReady then return end
                pcall(function()
                    if isSailorNPC(v) or isMyChar(v) then return end
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("PointLight") or v:IsA("SpotLight") then
                        v.Enabled = false
                    elseif v:IsA("BasePart") then
                        v.CastShadow = false
                    end
                end)
            end)
        end)

        -- Auto respawn khi rơi xuống biển
        task.spawn(function()
            while true do
                task.wait(5)
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        if char.HumanoidRootPart.Position.Y < -200 then LocalPlayer:LoadCharacter() end
                    end
                end)
            end
        end)
    end

    -- ================================
    -- 🧠 STEAL THE BRAINROT BASE
    -- ================================
    if placeId == 119038583929525 then
        task.spawn(function()
            while true do
                task.wait(10)
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        hrp.CFrame = hrp.CFrame * CFrame.new(0.5,0,0); task.wait(0.3)
                        hrp.CFrame = hrp.CFrame * CFrame.new(-0.5,0,0)
                    end
                end)
            end
        end)
    end

    -- ================================
    -- 🇻🇳 CỘNG ĐỒNG VN
    -- ================================
    if placeId == 18192562963 then
        task.spawn(function()
            while true do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local pos = char.HumanoidRootPart.Position
                    for _,v in pairs(workspace:GetDescendants()) do
                        pcall(function() if v:IsA("BasePart") then v.LocalTransparencyModifier = (v.Position-pos).Magnitude > 180 and 1 or 0 end end)
                    end
                end
                task.wait(2)
            end
        end)
    end

    -- ================================
    -- 🐝 BEE SWARM
    -- ================================
    if placeId == 1537690962 then
        local function cleanBeeSwarm()
            for _,v in pairs(workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
                    if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
                    if v:IsA("BasePart") then v.CastShadow=false; v.Reflectance=0; v.Material=Enum.Material.SmoothPlastic end
                    if v.Name=="Bee" or v.Name=="BasicBee" or v.Name=="BumblingBee" then
                        if v:IsA("Model") or v:IsA("BasePart") then
                            pcall(function() v.LocalTransparencyModifier=1 end)
                            for _,p in pairs(v:GetDescendants()) do
                                pcall(function() if p:IsA("ParticleEmitter") or p:IsA("Trail") then p.Enabled=false end end)
                            end
                        end
                    end
                    if v:IsA("Sound") then v.RollOffMaxDistance=20 end
                end)
            end
        end
        cleanBeeSwarm()
        task.spawn(function()
            while true do
                cleanBeeSwarm()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local pos = char.HumanoidRootPart.Position
                    for _,v in pairs(workspace:GetDescendants()) do
                        pcall(function()
                            if v:IsA("BasePart") and v.Parent ~= char then
                                v.LocalTransparencyModifier = (v.Position-pos).Magnitude > 100 and 1 or 0
                            end
                        end)
                    end
                end
                task.wait(4)
            end
        end)
    end

    -- ================================
    -- 🥊 DUDES BATTLEGROUNDS — FIX VỠ ĐẤT TRIỆT ĐỂ V3
    -- PlaceId: 6516141723
    -- Approach: ghi lại thời điểm load xong (loadTime)
    -- Mọi BasePart spawn vào workspace SAU loadTime mà không phải NPC/player → xóa
    -- Dùng Instance.CreationTime không có trong Luau → dùng cách khác:
    -- Track bằng set() khi DescendantAdded fire TRƯỚC loadTime → đó là map thật
    -- ================================
    if placeId == 6516141723 then

        local dudesMyChar = LocalPlayer.Character
        LocalPlayer.CharacterAdded:Connect(function(c) dudesMyChar = c end)

        -- Map thật = object tồn tại trước khi dudesLoaded = true
        local dudesMapSet = {} -- [instance] = true → đây là map thật, giữ lại
        local dudesLoaded = false

        -- Helper: object có phải player/NPC không
        local function isDudesAlive(v)
            if dudesMyChar and (v == dudesMyChar or v:IsDescendantOf(dudesMyChar)) then return true end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and (v == plr.Character or v:IsDescendantOf(plr.Character)) then return true end
            end
            local p = v.Parent
            while p and p ~= workspace do
                if p:FindFirstChildOfClass("Humanoid") then return true end
                p = p.Parent
            end
            return false
        end

        -- Tắt effect (luôn áp dụng dù là map hay debris)
        local function dudesKillFX(v)
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false; v.Rate = 0
                elseif v:IsA("Beam") then v.Enabled = false
                elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = false
                elseif v:IsA("SelectionBox") or v:IsA("SelectionSphere") or v:IsA("PostEffect") then v:Destroy()
                elseif v:IsA("Sound") then v.RollOffMaxDistance = 20; v.Volume = math.min(v.Volume, 0.3)
                elseif v:IsA("BasePart") then v.CastShadow = false; v.Reflectance = 0
                end
            end)
        end

        -- Bước 1: trước khi load xong → ghi tất cả object vào map set
        -- DescendantAdded fire ngay khi object spawn (kể cả trong lúc load)
        local preloadConn = workspace.DescendantAdded:Connect(function(v)
            if not dudesLoaded then
                dudesMapSet[v] = true -- đây là map thật
                dudesKillFX(v)
            end
        end)

        -- Bước 2: build map set từ những gì đã có sẵn + chờ load
        task.spawn(function()
            -- Ghi tất cả object đang có vào map set
            for _, v in ipairs(workspace:GetDescendants()) do
                dudesMapSet[v] = true
                dudesKillFX(v)
            end
            task.wait(4) -- chờ map load hoàn toàn

            -- Thêm tất cả player hiện tại vào safe set
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    dudesMapSet[plr.Character] = true
                    for _, v in ipairs(plr.Character:GetDescendants()) do
                        dudesMapSet[v] = true
                    end
                end
            end

            dudesLoaded = true
            preloadConn:Disconnect() -- không cần nữa
        end)

        -- Bước 3: SAU khi load xong → mọi object mới = debris/skill effect → xóa
        workspace.DescendantAdded:Connect(function(v)
            if not dudesLoaded then return end
            task.defer(function()
                if not v or not v.Parent then return end
                dudesKillFX(v) -- luôn tắt effect

                -- Nếu là player/NPC → bỏ qua
                if isDudesAlive(v) then return end

                -- Nếu không có trong map set → là debris mới → xóa
                if not dudesMapSet[v] then
                    pcall(function()
                        if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("WedgePart")
                        or v:IsA("CornerWedgePart") or v:IsA("TrussPart")
                        or v:IsA("Model") or v:IsA("Part") then
                            v:Destroy()
                        end
                    end)
                end
            end)
        end)

        -- Player mới join hoặc respawn → thêm vào safe set
        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(c)
                task.wait(0.5)
                dudesMapSet[c] = true
                for _, v in ipairs(c:GetDescendants()) do dudesMapSet[v] = true end
            end)
        end)
        LocalPlayer.CharacterAdded:Connect(function(c)
            dudesMyChar = c
            task.wait(0.5)
            dudesMapSet[c] = true
            for _, v in ipairs(c:GetDescendants()) do dudesMapSet[v] = true end
        end)

        -- Cull player xa (10s/lần)
        task.spawn(function()
            while true do
                task.wait(10)
                local char = LocalPlayer.Character
                local myPos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position
                if myPos then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            pcall(function()
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                local dist = hrp and (hrp.Position - myPos).Magnitude or 999
                                for _, v in ipairs(plr.Character:GetDescendants()) do
                                    pcall(function()
                                        if v:IsA("BasePart") then
                                            v.LocalTransparencyModifier = dist > 120 and 1 or 0
                                        end
                                        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                                            v.Enabled = false
                                        end
                                    end)
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end

    -- ================================
    -- NOTIFICATION + UI
    -- ================================
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="HIEN VIP", Text=" Fix Lag + bulonn ✅", Duration=5})
    end)

    -- UI BANNER
    local bannerGui = Instance.new("ScreenGui", game.CoreGui); bannerGui.ResetOnSpawn = false
    local bg = Instance.new("Frame", bannerGui); bg.Size = UDim2.new(0,0,0,0)
    bg.Position = UDim2.new(0.5,-260,0.18,0); bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.3; Instance.new("UICorner", bg)
    local bannerText = Instance.new("TextLabel", bg); bannerText.AnchorPoint = Vector2.new(0.5,0.5)
    bannerText.Position = UDim2.new(0.5,0,0.5,0); bannerText.Size = UDim2.new(0.7,0,0.6,0)
    bannerText.BackgroundTransparency = 1; bannerText.Text = "HIEN VIP FIX LAG SUCCESS"
    bannerText.TextScaled = true; bannerText.Font = Enum.Font.GothamBlack
    bannerText.TextColor3 = Color3.fromRGB(255,255,255); bannerText.TextStrokeTransparency = 0
    bannerText.TextStrokeColor3 = Color3.new(0,0,0)
    local bStroke = Instance.new("UIStroke"); bStroke.Parent = bannerText; bStroke.Thickness = 3; bStroke.Color = Color3.fromRGB(0,255,170)
    local shadow = bannerText:Clone(); shadow.Parent = bg
    shadow.Position = bannerText.Position + UDim2.new(0,2,0,2); shadow.TextColor3 = Color3.new(0,0,0)
    shadow.TextTransparency = 0.6; shadow.TextStrokeTransparency = 1; shadow.ZIndex = 0; bannerText.ZIndex = 1

    local function createElectricGear(pos)
        local gear = Instance.new("ImageLabel", bg); gear.Size = UDim2.new(0,35,0,35); gear.Position = pos
        gear.BackgroundTransparency = 1; gear.Image = "rbxassetid://6031280882"; gear.ImageColor3 = Color3.fromRGB(0,255,170)
        local glow = Instance.new("UIStroke"); glow.Parent = gear; glow.Thickness = 3; glow.Color = Color3.fromRGB(0,255,170)
        local glow2 = Instance.new("UIStroke"); glow2.Parent = gear; glow2.Thickness = 7; glow2.Color = Color3.fromRGB(0,255,170); glow2.Transparency = 0.7
        task.spawn(function()
            while gear.Parent do
                glow.Thickness=6; glow2.Transparency=0.2; task.wait(0.05)
                glow.Thickness=3; glow2.Transparency=0.7; task.wait(0.15)
                gear.ImageColor3=Color3.fromRGB(0,255,170); task.wait(0.05)
                gear.ImageColor3=Color3.fromRGB(0,200,140); task.wait(0.05)
            end
        end)
        return gear
    end
    local gearL = createElectricGear(UDim2.new(0,10,0.5,-17))
    local gearR = createElectricGear(UDim2.new(1,-45,0.5,-17))
    TweenService:Create(bg, TweenInfo.new(0.35,Enum.EasingStyle.Back), {Size=UDim2.new(0,520,0,70)}):Play()
    task.spawn(function() while bg.Parent do gearL.Rotation=gearL.Rotation+2; gearR.Rotation=gearR.Rotation-2; task.wait(0.03) end end)
    task.delay(4, function()
        TweenService:Create(bg,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        TweenService:Create(bannerText,TweenInfo.new(0.5),{TextTransparency=1,TextStrokeTransparency=1}):Play()
        task.wait(0.6); bannerGui:Destroy()
    end)

    -- FPS COUNTER
    local fpsGui = Instance.new("ScreenGui", game.CoreGui); fpsGui.ResetOnSpawn = false; fpsGui.Name = "FPSGui"
    local fpsBg = Instance.new("Frame", fpsGui); fpsBg.Size = UDim2.new(0,80,0,22); fpsBg.Position = UDim2.new(0,10,0,10)
    fpsBg.BackgroundColor3 = Color3.fromRGB(0,0,0); fpsBg.BackgroundTransparency = 0.4; fpsBg.BorderSizePixel = 0
    Instance.new("UICorner", fpsBg)
    local fpsLabel = Instance.new("TextLabel", fpsBg); fpsLabel.Size = UDim2.new(1,0,1,0)
    fpsLabel.BackgroundTransparency = 1; fpsLabel.Text = "FPS: --"; fpsLabel.TextScaled = true
    fpsLabel.Font = Enum.Font.GothamBold; fpsLabel.TextColor3 = Color3.fromRGB(0,255,170)
    fpsLabel.TextStrokeTransparency = 0; fpsLabel.TextStrokeColor3 = Color3.new(0,0,0)
    local lastTick2 = tick(); local frameCount = 0
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1; local now = tick()
        if now - lastTick2 >= 0.5 then
            local fps = math.floor(frameCount / (now - lastTick2)); frameCount = 0; lastTick2 = now
            fpsLabel.TextColor3 = fps >= 50 and Color3.fromRGB(0,255,100) or fps >= 30 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50)
            fpsLabel.Text = "FPS: "..fps
        end
    end)

    -- INFO BAR
    local infoGui = Instance.new("ScreenGui", game.CoreGui); infoGui.ResetOnSpawn = false; infoGui.Name = "InfoBarGui"
    local infoBg = Instance.new("Frame", infoGui); infoBg.Size = UDim2.new(0,0,0,22); infoBg.Position = UDim2.new(0,10,0,36)
    infoBg.BackgroundColor3 = Color3.fromRGB(10,10,20); infoBg.BackgroundTransparency = 0.3; infoBg.BorderSizePixel = 0
    Instance.new("UICorner", infoBg)
    local infoStroke = Instance.new("UIStroke"); infoStroke.Parent = infoBg; infoStroke.Thickness = 1; infoStroke.Color = Color3.fromRGB(0,255,127)
    local infoLabel = Instance.new("TextLabel", infoBg); infoLabel.Size = UDim2.new(1,-8,1,0); infoLabel.Position = UDim2.new(0,4,0,0)
    infoLabel.BackgroundTransparency = 1; infoLabel.TextScaled = true; infoLabel.Font = Enum.Font.GothamBold
    infoLabel.TextColor3 = Color3.fromRGB(0,255,127); infoLabel.TextStrokeTransparency = 0; infoLabel.TextStrokeColor3 = Color3.new(0,0,0)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Text = "👤 " .. ((LocalPlayer and LocalPlayer.Name) or "Unknown") .. "  |  ⏳ " .. ((getgenv().HIENVIP_DATE and daysRemaining(getgenv().HIENVIP_DATE)) or "?")
    task.spawn(function() TweenService:Create(infoBg,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Size=UDim2.new(0,175,0,22)}):Play() end)

    -- DISCORD BUTTON
    local quickGui = Instance.new("ScreenGui", game.CoreGui); quickGui.ResetOnSpawn = false; quickGui.Name = "QuickDiscordGui"
    local quickBtn = Instance.new("TextButton", quickGui); quickBtn.Size = UDim2.new(0,95,0,32); quickBtn.Position = UDim2.new(1,-150,0,-50)
    quickBtn.BackgroundColor3 = Color3.fromRGB(88,101,242); quickBtn.BackgroundTransparency = 0.1; quickBtn.BorderSizePixel = 0
    quickBtn.Text = "DISCORD"; quickBtn.TextScaled = true; quickBtn.Font = Enum.Font.GothamBlack
    quickBtn.TextColor3 = Color3.fromRGB(255,255,255); quickBtn.TextStrokeTransparency = 0; quickBtn.TextStrokeColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", quickBtn)
    quickBtn.MouseButton1Click:Connect(function()
        local cb = toclipboard or setclipboard; if cb then cb("https://discord.gg/x9pATE8Uxe") end
        quickBtn.Text = "✅ Copied!"; quickBtn.BackgroundColor3 = Color3.fromRGB(0,180,100)
        task.delay(0.8, function() quickBtn.Text="DISCORD"; quickBtn.BackgroundColor3=Color3.fromRGB(88,101,242) end)
    end)

    RunService.Heartbeat:Connect(function()
        if not game.CoreGui:FindFirstChild("FPSGui") then fpsGui.Parent = game.CoreGui end
        if not game.CoreGui:FindFirstChild("InfoBarGui") then infoGui.Parent = game.CoreGui end
        if not game.CoreGui:FindFirstChild("QuickDiscordGui") then quickGui.Parent = game.CoreGui end
    end)
end

-- ================================
-- 🔐 KHỞI CHẠY
-- ================================
local myHWID = getHWID()
local myName = game:GetService("Players").LocalPlayer.Name

local loadGui = Instance.new("ScreenGui", game.CoreGui); loadGui.ResetOnSpawn = false
local loadBg = Instance.new("Frame", loadGui); loadBg.Size = UDim2.new(0,200,0,36); loadBg.Position = UDim2.new(0.5,-100,0,10)
loadBg.BackgroundColor3 = Color3.fromRGB(10,10,20); loadBg.BackgroundTransparency = 0.2; loadBg.BorderSizePixel = 0
Instance.new("UICorner", loadBg)
local loadStroke = Instance.new("UIStroke"); loadStroke.Parent = loadBg; loadStroke.Color = Color3.fromRGB(0,255,127); loadStroke.Thickness = 1.5
local loadLabel = Instance.new("TextLabel", loadBg); loadLabel.Size = UDim2.new(1,0,1,0); loadLabel.BackgroundTransparency = 1
loadLabel.TextScaled = true; loadLabel.Font = Enum.Font.GothamBold
loadLabel.TextColor3 = Color3.fromRGB(0,255,127); loadLabel.TextStrokeTransparency = 0; loadLabel.TextStrokeColor3 = Color3.new(0,0,0)

task.spawn(function()
    local dots={".","..",".."};local i=1
    while loadGui.Parent do loadLabel.Text="⏳ HIEN VIP đang kiểm tra"..dots[i]; i=i%3+1; task.wait(0.4) end
end)

task.spawn(function()
    local status, myDate = checkWhitelist(myHWID)
    pcall(function() loadGui:Destroy() end)
    if status == "whitelisted" then
        getgenv().HIENVIP_DATE = myDate
        local remaining = daysRemaining(myDate)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HIEN VIP - Xin chào " .. myName .. "!",
                Text = "Thời hạn: " .. remaining,
                Duration = 5
            })
        end)
        runFixLag()
    elseif status == "expired" then
        showExpiredUI()
    else
        showNotWhitelistedUI()
    end
end)
