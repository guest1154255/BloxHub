-- Variables
local Players = game:GetService("Players"):GetPlayers()
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CGUI = game:GetService("CoreGui")

local teleport = game:GetService("TeleportService")

local LocalPlayer = game.Players.LocalPlayer

local Lighting = game:GetService("Lighting")

local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local Countries = {}

local exec_name = (getexecutor or getexecutorname or getidentityexecutor or identifyexecutor or function() return 'Unknown' end)()

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "BloxHub", HidePremium = false, IntroEnabled = false, SaveConfig = true, ConfigFolder = "HubConfig"})


local success, result = pcall(function()
	Countries = HttpService:JSONDecode(game:HttpGet("http://country.io/names.json"))
    print(Countries)
end)

if game:IsLoaded() then
    print("alrady loaded")
else
    local notLoaded = Instance.new("Message")
    notLoaded.Parent = game:GetService("CoreGui")
    notLoaded.Text = "BloxHub is waiting for the game to load."
    game.Loaded:Wait()

    notLoaded:Destroy()
end

-- Values
_G.target = ""
_G.country = Countries[LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)]
_G.HeadSize = 20
_G.Disabled = false
_G.fling = false
_G.Character = nil
_G.noclip = false
_G.bang_target = ""
_G.bang_speed = 1

_G.banging = false
_G.face_banging = false

local IsOnMobile

if UIS.KeyboardEnabled and UIS.MouseEnabled and not UIS.GamepadEnabled then
    IsOnMobile = false
elseif UIS.TouchEnabled and not UIS.KeyboardEnabled and not UIS.MouseEnabled then
    IsOnMobile = true
end

if UIS.TouchEnabled and UIS.KeyboardEnabled and UIS.MouseEnabled then
    IsOnMobile = false
end

local FLYING = false
local QEfly = true
local fly_speed = 1
local v_fly_speed = 1
local flinging = false
local invisRunning = false

local Noclipping = nil
local flingDied = nil
local Clip = true

local bangAnim
local bang
local bangDied
local bangLoop

local IYMouse = LocalPlayer:GetMouse()

local checked_plrs = {}

-- Functions

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function GetPlayer(name, type)
    if name == nil then
        warn("name is nil")
        return
    end

    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
        if type == "player" then
            if string.find(v.Name:lower(), name) or string.find(v.DisplayName:lower(), name) then
                return v
            end
        elseif type == "name" then
            if string.find(v.Name:lower(), name) or string.find(v.DisplayName:lower(), name) then
                return v.Name
            end
        end
    end
end

local function TP(player)
    if player == "" then return end
    if player == nil then return end

    player = player:lower()

    local v = GetPlayer(player, "player")

    if v == nil then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Player might have left or doesn't have a character.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })

        return
    end

    local localroot = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local char = v.Character
    local root = char:WaitForChild("HumanoidRootPart")
    localroot.CFrame = root.CFrame + Vector3.new(0, 0, -5)

    OrionLib:MakeNotification({
        Name = "Success",
        Content = "Teleported to player ".._G.target,
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function NoClip(speaker)
    if Clip then
        Clip = false
	    wait(0.1)
	    local function NoclipLoop()
		    if Clip == false and speaker.Character ~= nil then
			    for _, child in pairs(speaker.Character:GetDescendants()) do
				    if child:IsA("BasePart") and child.CanCollide == true then
					    child.CanCollide = false
				    end
			    end
		    end
	    end
	    Noclipping = RS.Stepped:Connect(NoclipLoop)
    end
end

function Cl()
    if not Clip then
        if Noclipping == nil then
            return
        else
            local hum = LocalPlayer.Character:WaitForChild("Humanoid")
            Noclipping:Disconnect()

            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    
        Clip = true
    end
end

function sFLY(vfly)
	repeat wait() until LocalPlayer and LocalPlayer.Character and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat wait() until IYMouse
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

	local T = getRoot(LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat wait()
				if not vfly and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and v_fly_speed or fly_speed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and v_fly_speed or fly_speed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and v_fly_speed or fly_speed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and v_fly_speed or fly_speed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and v_fly_speed or fly_speed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and v_fly_speed or fly_speed)*2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

function unfling(speaker)
    Cl()
	if flingDied then
		flingDied:Disconnect()
	end
	flinging = false
	wait(.1)
	local speakerChar = speaker.Character
	if not speakerChar or not getRoot(speakerChar) then return end
	for i,v in pairs(getRoot(speakerChar):GetChildren()) do
		if v.ClassName == 'BodyAngularVelocity' then
			v:Destroy()
		end
	end
	for _, child in pairs(speakerChar:GetDescendants()) do
		if child.ClassName == "Part" or child.ClassName == "MeshPart" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end

function Fling(speaker)
    flinging = false
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(math.huge, 0.3, 0.5)
		end
	end
	NoClip(LocalPlayer)
	wait(.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString()
	bambam.Parent = getRoot(speaker.Character)
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0)
	bambam.P = math.huge
	local Char = speaker.Character:GetChildren()
	for i, v in next, Char do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
			v.Velocity = Vector3.new(0, 0, 0)
		end
	end
	flinging = true
	local function flingDiedF()
		unfling(LocalPlayer)
	end

	flingDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(flingDiedF)

	repeat
		bambam.AngularVelocity = Vector3.new(0,99999,0)
		wait(.2)
		bambam.AngularVelocity = Vector3.new(0,0,0)
		wait(.1)
	until flinging == false
end

local function fixcam(speaker)
    workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end

function Invis(speaker)
    if not invisRunning then return end

	local Player = speaker
	repeat wait(.1) until Player.Character
	_G.Character = Player.Character
    Character = _G.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = Lighting
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = "invis"
	local CF

	local invisFix = RS.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.HumanoidRootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					--Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					--Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	--function Respawn()
	--	IsRunning = false
	--	if IsInvis == true then
	--		pcall(function()
	--			Player.Character = Character
	--			wait()
	--			Character.Parent = workspace
	--			Character:FindFirstChildWhichIsA'Humanoid':Destroy()
	--			IsInvis = false
	--			InvisibleCharacter.Parent = nil
	--			invisRunning = false
	--		end)
	--	elseif IsInvis == false then
	--		pcall(function()
	--			Player.Character = Character
	--			wait()
	--			Character.Parent = workspace
	--			Character:FindFirstChildWhichIsA'Humanoid':Destroy()
	--			TurnVisible(speaker)
	--		end)
	--	end
	--end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass('Humanoid').Died:Connect(function()
		-- Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.HumanoidRootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.HumanoidRootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	fixcam(speaker)
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible(speaker)
        print(Player.Name)
        print(Character.Name)
        print(IsInvis)

		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		local CF = game.Workspace.CurrentCamera.CFrame
		Character = _G.Character
		local CF_1 = Player.Character.HumanoidRootPart.CFrame
		Character.HumanoidRootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = game.Workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
			-- Respawn()
			invisDied:Disconnect()
		end)
		invisRunning = false
	end
	
    
    OrionLib:MakeNotification({
        Name = "Success",
        Content = "You are now invisible to other players.",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

function unmobilefly(speaker)
    pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

function mobile_fly(speaker, vfly)
	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RS.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and v_fly_speed or fly_speed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and v_fly_speed or fly_speed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and v_fly_speed or fly_speed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and v_fly_speed or fly_speed) * 50))
			end
		end
	end)
end

function Full_bright()
    Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

function freeze()
    for i, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.Anchored = true
        end
    end
end

function unfreeze()
    for i, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.Anchored = false
        end
    end
end

function getTorso(x)
    return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function Bang(target, speaker, type)
    if target == "" then return end
    if target == nil then return end

    local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(_G.bang_speed)
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
        _G.bang:Set(false)
        _G.face_bang:Set(false)
        _G.banging = false
        _G.face_banging = false
        _G.noclipTog:Set(false)
        Cl()
	end)

	local player = game.Players:FindFirstChild(target)

    _G.noclipTog:Set(true)
    NoClip(LocalPlayer)

    if type == "bang" then
        local bangOffset = CFrame.new(0, 0, 1.1)

        bangLoop = RS.RenderStepped:Connect(function()
            local success, err = pcall(function()
                bang:AdjustSpeed(_G.bang_speed)
        
                local x = player.Character or player.CharacterAdded:Wait()
    
                local otherRoot = getTorso(x)
                local CF = otherRoot.CFrame * bangOffset

                getRoot(speaker.Character).CFrame = CF
            end)
    
            if not success then
                warn(err)
            end
        end)
    elseif type == "face-bang" then
        local bangOffset = CFrame.new(0, 0, -1.1) * CFrame.Angles(math.rad(180), 0, math.rad(180))

        bangLoop = RS.Stepped:Connect(function()
            local success, err = pcall(function()
                bang:AdjustSpeed(_G.bang_speed)
        
                local x = player.Character or player.CharacterAdded:Wait()
    
                local otherRoot = getTorso(x)

                local CF = otherRoot.CFrame * bangOffset

                getRoot(speaker.Character).CFrame = CF
            end)
    
            if not success then
                warn(err)
            end
        end)
    end
end

function Unbang()
    if bangDied ~= nil then
        bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangLoop:Disconnect()
    else
        warn("bangdied isnt loaded")
    end
end

local function Server_info()
    local font = Font.fromEnum(Enum.Font.Gotham)
    local weight = Enum.FontWeight.Bold

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "Server info"
    GUI.IgnoreGuiInset = true
    GUI.ResetOnSpawn = false
    GUI.Parent = CGUI

    local main = Instance.new("Frame")
    main.Name = "main"
    main.Position = UDim2.new(0.415, 0, 0.268, 0)
    main.Size = UDim2.new(0.325, 0, 0.463, 0)
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    main.Parent = GUI

    local Head = Instance.new("TextLabel")
    Head.Name = "Head"
    Head.Size = UDim2.new(1, 0, 0.057, 0)
    Head.BackgroundTransparency = 1
    Head.FontFace = font
    Head.FontFace.Weight = weight
    Head.TextColor3 = Color3.fromRGB(255, 255, 255)
    Head.TextScaled = true
    Head.Text = "Server info"
    Head.Parent = main

    local JobID = Instance.new("TextLabel")
    JobID.Name = "JobID"
    JobID.Position = UDim2.new(0.028, 0, 0.148, 0)
    JobID.Size = UDim2.new(0.769, 0, 0.05, 0)
    JobID.BackgroundTransparency = 1
    JobID.FontFace = font
    JobID.FontFace.Weight = weight
    JobID.TextXAlignment = Enum.TextXAlignment.Left
    JobID.TextColor3 = Color3.new(255, 255, 255)
    JobID.TextScaled = true
    JobID.Text = "Job ID: "..game.JobId
    JobID.Parent = main

    local Region = Instance.new("TextLabel")
    Region.Name = "Region"
    Region.Position = UDim2.new(0.028, 0, 0.211, 0)
    Region.Size = UDim2.new(0.769, 0, 0.05, 0)
    Region.BackgroundTransparency = 1
    Region.FontFace = font
    Region.FontFace.Weight = weight
    Region.TextXAlignment = Enum.TextXAlignment.Left
    Region.TextColor3 = Color3.new(255, 255, 255)
    Region.TextScaled = true

    local e = HttpService:JSONDecode(game:HttpGet("https://ipconfig.io/json"))

    Region.Text = "Server region (local): "..e["region_name"]..", "..e["country"]
    Region.Parent = main

    local Age = Instance.new("TextLabel")
    Age.Name = "Age"
    Age.Position = UDim2.new(0.028, 0, 0.277, 0)
    Age.Size = UDim2.new(0.769, 0, 0.05, 0)
    Age.BackgroundTransparency = 1
    Age.FontFace = font
    Age.FontFace.Weight = weight
    Age.TextXAlignment = Enum.TextXAlignment.Left
    Age.TextColor3 = Color3.new(255, 255, 255)
    Age.TextScaled = true
    Age.Text = "Age (local): "..
        string.format("%02d", tostring(math.floor((workspace.DistributedGameTime / 86400)))).." Days "..
		string.format("%02d", tostring(math.floor((workspace.DistributedGameTime / 3600)))).." Hours "..
		string.format("%02d", tostring(math.floor((workspace.DistributedGameTime / 60)))).." Minutes "..
		string.format("%02d", tostring(math.floor(workspace.DistributedGameTime))).." Seconds "

    Age.Parent = main

    local ee = Instance.new("TextLabel")
    ee.Name = "E"
    ee.Position = UDim2.new(0.012, 0, 0.569, 0)
    ee.Size = UDim2.new(0.971, 0, 0.098, 0)
    ee.Rotation = 30
    ee.BackgroundTransparency = 1
    ee.FontFace = font
    ee.FontFace.Weight = weight
    ee.TextColor3 = Color3.new(255, 255, 255)
    ee.TextScaled = true
    ee.Text = "Coming soon"
    ee.Parent = main

    local Rejoin = Instance.new("TextButton")
    Rejoin.Name = "Rejoin"
    Rejoin.Position = UDim2.new(0, 0, 0.948, 0)
    Rejoin.Size = UDim2.new(0.202, 0, 0.052, 0)
    Rejoin.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Rejoin.FontFace = font
    Rejoin.FontFace.Weight = weight
    Rejoin.Text = "Rejoin"
    Rejoin.TextColor3 = Color3.fromRGB(255, 255, 255)
    Rejoin.TextScaled = true
    Rejoin.Parent = main

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Position = UDim2.new(0.886, 0, 0, 0)
    Close.Size = UDim2.new(0.114, 0, 0.084, 0)
    Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    Close.FontFace = font
    Close.FontFace.Weight = weight
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextScaled = true
    Close.Parent = main

    Rejoin.MouseButton1Click:Connect(function()
        teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    Close.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    while task.wait(1) do
        Age.Text = "Age (local): "..
        string.format("%02d", tostring(math.floor((workspace.DistributedGameTime / 86400)))).." Days "..
		string.format("%02d", tostring(math.floor((workspace.DistributedGameTime / 3600)))).." Hours "..
		string.format("%02d", tostring(math.floor((workspace.DistributedGameTime / 60)))).." Minutes "..
		string.format("%02d", tostring(math.floor(workspace.DistributedGameTime))).." Seconds "
    end
end

-- RS

game:GetService('RunService').RenderStepped:Connect(function()
    if _G.Disabled then
        for i,v in next, game:GetService('Players'):GetPlayers() do
            if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                pcall(function()
                    v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
                    v.Character.HumanoidRootPart.Transparency = 0.7
                    v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really black")
                    v.Character.HumanoidRootPart.Material = "Neon"
                    v.Character.HumanoidRootPart.CanCollide = false
                end)
            end
        end
    end
end)

-- Tabs

local Gen = Window:MakeTab({
    Name = "General",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Fun = Window:MakeTab({
    Name = "Fun stuff",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Info = Window:MakeTab({
    Name = "Information",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- MVS only

if game.PlaceId == 12355337193 then
    local special = Window:MakeTab({
        Name = "MVS Special",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    special:AddLabel("Bigger hitboxes")

    special:AddSlider({
        Name = "Hitbox size",
        Min = 20,
        Max = 120,
        Default = 20,
        Color = Color3.fromRGB(0, 200, 0),
        Increment = 1,
        ValueName = "",
        Callback = function(Value)
            _G.HeadSize = Value
        end
    })

    special:AddToggle({
        Name = "Enable",
        Default = false,
        Callback = function(Value)
            _G.Disabled = Value

            if not _G.Disabled then
                for i,v in next, game:GetService('Players'):GetPlayers() do
                    if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                        pcall(function()
                            print(v.Character.HumanoidRootPart.OriginalSize)

                            v.Character.HumanoidRootPart.Size = Vector3.new(2, 2.1, 1)
                            v.Character.HumanoidRootPart.Transparency = 1
                            v.Character.HumanoidRootPart.Material = "Plastic"
                            v.Character.HumanoidRootPart.CanCollide = false
                        end)
                    end
                end
            end
        end
    })
end

-- For General
Gen:AddLabel("Teleport to a player")

Gen:AddTextbox({
    Name = "Player (usernames only)",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        if Value == "" then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please include a player.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            _G.target = GetPlayer(Value:lower(), "name")
            print(_G.target)

            if _G.target ~= nil then
                if _G.target == LocalPlayer.Name then
                    OrionLib:MakeNotification({
                        Name = "Error",
                        Content = "Cannot teleport to yourself!",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                    return
                else
                    OrionLib:MakeNotification({
                        Name = "Success",
                        Content = "Selected target: ".._G.target,
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                    return
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Did not find player",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
    
                return
            end
        end
    end
})

Gen:AddButton({
    Name = "TP to",
    Callback = function()
        TP(_G.target)
    end
})

Gen:AddLabel("Common")

Gen:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        if Value then
            if not IsOnMobile then
                sFLY(false)
            else
                mobile_fly(LocalPlayer, false)
            end
        else
            if not IsOnMobile then
                NOFLY()
            else
                unmobilefly(LocalPlayer)
            end
        end
    end
})

Gen:AddToggle({
    Name = "Vehicle fly",
    Default = false,
    Callback = function(val)
        if val then
            if not IsOnMobile then
                sFLY(true)
            else
                mobile_fly(LocalPlayer, true)
            end
        else
            if not IsOnMobile then
                NOFLY()
            else
                unmobilefly(LocalPlayer)
            end
        end
    end
})

local fly_speed = Gen:AddSlider({
    Name = "Fly speed (applies for vehicle fly too.)",
    Min = 1,
    Max = 500,
    Default = 10,
    Color = Color3.fromRGB(0, 200, 0),
    Increment = 1,
    ValueName = "speed",
    Callback = function(val)
        fly_speed = val
        v_fly_speed = val
    end
})

Gen:AddButton({
    Name = "Reset",
    Callback = function()
        fly_speed:Set(10)
    end
})

_G.noclipTog = Gen:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        if Value then
            NoClip(LocalPlayer)
            _G.noclip = Value
        else
            if not _G.noclip then return end
            _G.noclip = Value
            Cl()
        end
    end
})

local fling_toggle = Gen:AddToggle({
    Name = "Fling (players must have collision)",
    Default = false,
    Callback = function(val)
        if val then
            Fling(LocalPlayer)
        else
            unfling(LocalPlayer)
        end
    end
})

Gen:AddToggle({
    Name = "Invisible",
    Default = false,
    Callback = function(val)
        if val then
            invisRunning = true
            Invis(LocalPlayer)
        else
            if not invisRunning then return end
            TurnVisible(LocalPlayer)
        end
    end
})

Gen:AddButton({
    Name = "Full brightness",
    Callback = function()
        Full_bright()
    end
})

-- When died

LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(function()
    if _G.fling then
        fling_toggle:Set(false)
    end
end)

Gen:AddLabel("Change your properties")
local speed = Gen:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(0, 200, 0),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        
        hum.WalkSpeed = Value
    end
})

Gen:AddButton({
    Name = "Reset",
    Callback = function()
        speed:Set(16)
    end
})

local jump = Gen:AddSlider({
    Name = "Jump Power",
    Min = 0,
    Max = 250,
    Default = 50,
    Color = Color3.fromRGB(0, 200, 0),
    Increment = 1,
    ValueName = "",
    Callback = function(Value)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        
        hum.JumpPower = Value
    end
})

Gen:AddButton({
    Name = "Reset",
    Callback = function()
        jump:Set(50)
    end
})

local grav = Gen:AddSlider({
    Name = "Gravity",
    Min = 0,
    Max = 300,
    Default = 196.2,
    Color = Color3.fromRGB(0, 200, 0),
    Increment = 1,
    ValueName = "",
    Callback = function(Value)
        local work = game.Workspace
        work.Gravity = Value
    end
})

Gen:AddButton({
    Name = "Reset",
    Callback = function()
        grav:Set(196.2)
    end
})
-- For Fun

Fun:AddLabel("Jerk off")

Fun:AddToggle({
    Name = "Jerk Off [R6]",
    Default = false,
    Callback = function(Value)
        if Value then
            loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))("Spider Script")
        else
            if not LocalPlayer.Backpack:FindFirstChild("Jerk Off") then
                return
            else
                LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools()
                
                for items, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if item.Name == "Jerk Off" then
                        item:Destroy()
                    end
                end
            end
        end
    end
})

Fun:AddToggle({
    Name = "Jerk Off [R15]",
    Default = false,
    Callback = function(Value)
        if Value then
            loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
        else
            if not LocalPlayer.Backpack:FindFirstChild("Jerk Off R15") then
                return
            else
                LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools()

                for items, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if item.Name == "Jerk Off R15" then
                        item:Destroy()
                    end
                end
            end
        end
    end
})

Fun:AddLabel("Bang")

Fun:AddTextbox({
    Name = "Player",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        if Value == "" then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please include a player.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            _G.bang_target = GetPlayer(Value:lower(), "name")

            if _G.bang_target ~= nil then
                if _G.bang_target == LocalPlayer.Name then
                    OrionLib:MakeNotification({
                        Name = "Error",
                        Content = "Cannot teleport to yourself!",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                    return
                else
                    OrionLib:MakeNotification({
                        Name = "Success",
                        Content = "Selected target: ".._G.bang_target,
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                    return
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Did not find player",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
    
                return
            end
        end
    end
})

Fun:AddSlider({
    Name = "Bang speed",
    Min = 1,
    Max = 100,
    Default = 3,
    Color = Color3.new(200, 0, 0),
    Increment = 1,
    ValueName = "",
    Callback = function(val)
        _G.bang_speed = val
    end
})

_G.bang = Fun:AddToggle({
    Name = "Bang",
    Default = false,
    Callback = function(val)
        if _G.face_banging then _G.face_banging = false Unbang() _G.face_bang:Set(false) end
        _G.banging = val

        if val then
            Bang(_G.bang_target, LocalPlayer, "bang")
        else
            Unbang()
        end
    end
})

_G.face_bang = Fun:AddToggle({
    Name = "Front bang",
    Default = false,
    Callback = function(val)
        if _G.banging then _G.banging = false Unbang() _G.bang:Set(false) end
        _G.face_banging = val

        if val then
            Bang(_G.bang_target, LocalPlayer, "face-bang")
        else
            Unbang()
        end
    end
})

Fun:AddLabel("Buggy but cool")

Fun:AddButton({
    Name = "Backflip/frontflip script",
    Callback = function()
    --[[ Info ]]--

    local ver = "2.00"
    local scriptname = "feFlip"


    --[[ Keybinds ]]--

    local FrontflipKey = Enum.KeyCode.Z
    local BackflipKey = Enum.KeyCode.X
    local AirjumpKey = Enum.KeyCode.C


    --[[ Dependencies ]]--

    local ca = game:GetService("ContextActionService")
    local zeezy = game:GetService("Players").LocalPlayer
    local h = 0.0174533
    local antigrav


    --[[ Functions ]]--

    function zeezyFrontflip(act,inp,obj)
    	if inp == Enum.UserInputState.Begin then
    		zeezy.Character.Humanoid:ChangeState("Jumping")
    		wait()
    		zeezy.Character.Humanoid.Sit = true
    		for i = 1,360 do 
    			delay(i/720,function()
    			zeezy.Character.Humanoid.Sit = true
    				zeezy.Character.HumanoidRootPart.CFrame = zeezy.Character.HumanoidRootPart.CFrame * CFrame.Angles(-h,0,0)
    			end)
    		end
    		wait(0.55)
    		zeezy.Character.Humanoid.Sit = false
    	end
    end

    function zeezyBackflip(act,inp,obj)
    	if inp == Enum.UserInputState.Begin then
    		zeezy.Character.Humanoid:ChangeState("Jumping")
    		wait()
    		zeezy.Character.Humanoid.Sit = true
    		for i = 1,360 do
    			delay(i/720,function()
    			zeezy.Character.Humanoid.Sit = true
    				zeezy.Character.HumanoidRootPart.CFrame = zeezy.Character.HumanoidRootPart.CFrame * CFrame.Angles(h,0,0)
    			end)
    		end
    		wait(0.55)
    		zeezy.Character.Humanoid.Sit = false
    	end
    end

    function zeezyAirjump(act,inp,obj)
    	if inp == Enum.UserInputState.Begin then
    		zeezy.Character:FindFirstChildOfClass'Humanoid':ChangeState("Seated")
    		wait()
    		zeezy.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")	
    	end
    end


    --[[ Binds ]]--

    ca:BindAction("zeezyFrontflip",zeezyFrontflip,false,FrontflipKey)
    ca:BindAction("zeezyBackflip",zeezyBackflip,false,BackflipKey)
    ca:BindAction("zeezyAirjump",zeezyAirjump,false,AirjumpKey)

    --[[ Load Message ]]--

    print(scriptname .. " " .. ver .. " loaded successfully")
    print("made by Zeezy#7203")

    local notifSound = Instance.new("Sound",workspace)
    notifSound.PlaybackSpeed = 1.5
    notifSound.Volume = 0.15
    notifSound.SoundId = "rbxassetid://170765130"
    notifSound.PlayOnRemove = true
    notifSound:Destroy()
    game.StarterGui:SetCore("SendNotification", {Title = "feFlip", Text = "feFlip loaded successfully!", Icon = "rbxassetid://505845268", Duration = 5, Button1 = "Okay"})
    end
})

Fun:AddToggle({
    Name = "Freeze yourself",
    Default = false,
    Callback = function(val)
        if val then
            freeze()
        else
            unfreeze()
        end
    end
})

Fun:AddLabel("Chat bypassers")

Fun:AddButton({
    Name = "SigmaBypasser",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/shakk-code/SigmaBypasser/refs/heads/main/source', true))()
    end
})

Fun:AddButton({
    Name = "BetterBypasser",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Synergy-Networks/products/main/BetterBypasser/loader.lua",true))()
    end
})

-- Info

Info:AddLabel("--- INFO ---")
Info:AddLabel("Executor: "..exec_name)
Info:AddLabel("BloxHub version: v2.2")
Info:AddLabel("Player's country: ".._G.country)

Info:AddButton({
    Name = "Server info",
    Callback = function()
        Server_info()
    end
})

OrionLib:Init()
