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