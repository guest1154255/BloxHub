-- Variables
local Players = game:GetService("Players"):GetPlayers()
local RS = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

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

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1

local Noclipping = nil
local Clip = true

local IYMouse = LocalPlayer:GetMouse()

local checked_plrs = {}

-- Functions

local function TP(player)
    player = player:lower()

    for i, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Model") then
            if v.Name:lower() == player then
                local localroot = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                local char = v
                local root = char:WaitForChild("HumanoidRootPart")
                localroot.CFrame = root.CFrame + Vector3.new(0, 0, -5)
                OrionLib:MakeNotification({
                    Name = "Success",
                    Content = "Teleported to player ".._G.target,
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })

                checked_plrs = {}
                return
            else
                table.insert(checked_plrs, v.Name)

                for names, v in ipairs(checked_plrs) do
                    if names == i then
                        OrionLib:MakeNotification({
                            Name = "Error",
                            Content = "Player doesn't have a character or player wasn't found.",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })

                        checked_plrs = {}
                    end
                end
            end
        end
    end
end

function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function NoClip(speaker)
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

function Cl()
    if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
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
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
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
            _G.target = Value
            
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Selected target: ".._G.target,
                Image = "rbxassetid://4483345998",
                Time = 5
            })
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
            sFLY(false)
        else
            NOFLY()
        end
    end
})

Gen:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        if Value then
            NoClip(LocalPlayer)
        else
            Cl()
        end
    end
})

Gen:AddToggle({
    Name = "Infinite health",
    Default = false,
    Callback = function(Value)
        if Value then
            LocalPlayer.Character.Humanoid.Health = 9223372036854775807
        else
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
})

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
                LocalPlayer.Backpack:WaitForChild("Jerk Off"):Destroy()
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
                LocalPlayer.Backpack:WaitForChild("Jerk Off R15"):Destroy()
            end
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
Info:AddLabel("BloxHub version: test v1.5")
Info:AddLabel("Player's country: ".._G.country)

OrionLib:Init()
