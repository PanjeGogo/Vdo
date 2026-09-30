-- PanjeGogo
local gethui = gethui or function()
    return game:GetService("CoreGui")
end
local protectgui = protectgui or function()
end
local cloneref = cloneref or clonereference or function(instance)
    return instance
end
local newcclosure = newcclosure or function(func)
    return func
end
local getcustomasset = getcustomasset or function(path)
    return ""
end

local SimpleUI = {}

SimpleUI.Version = "2.2.7"
SimpleUI.Loaded = SimpleUI.Loaded or {}
SimpleUI.Windows = SimpleUI.Windows or {}

local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer

SimpleUI.Constants = {
    Window = {
        MinSize = Vector2.new(600, 400),
        MaxSize = Vector2.new(1400, 900),
        DefaultAspectRatio = 1.6,
        TopBarHeight = 48,
        FooterHeight = 24,
        TabsWidthOpen = 0.22,
        ContentWidthOpen = 0.78,
        TabsWidthClosed = 55,
        ContentLeftOffsetClosed = 60,
        ContentWidthScaleClosed = 1,
        HorizontalPadding = 10,
        VerticalPadding = 10,
        DefaultScale = 0.75,
        MinScale = 0.5,
        MaxScale = 2,
        TabModes = {
            Fixed = "Fixed",
            Dynamic = "Dynamic",
            Closed = "Closed"
        },
        ResizeModes = {
            BottomRight = "BottomRight",
            Center = "Center"
        },
        TabDynamicThreshold = 2,
        TabIconSizeExpanded = 20,
        TabIconSizeCollapsed = 28,
        ClosedTabHorizontalPadding = 1,
        TabSeparatorGap = 1
    },
    Padding = {
        Small = 4,
        Medium = 8,
        Large = 10,
        ExtraLarge = 12
    },
    Spacing = {
        Tight = 2,
        Normal = 4,
        Relaxed = 6,
        Loose = 8
    },
    Corner = {
        None = 0,
        Small = 3,
        Medium = 4,
        Large = 6,
        HolyFuckingShit = 12,
        Round = 1
    },
    Animation = {
        Fast = 0.15,
        Normal = 0.2,
        Slow = 0.35,
        VerySlow = 0.4,
        Smooth = 0.25
    },
    ZIndex = {
        Background = 1,
        Base = 2,
        Content = 3,
        Control = 4,
        Overlay = 5,
        Modal = 250,
        Notification = 999
    }
}

SimpleUI.WindowControls = {
    MacOS = {
        ButtonSize = UDim2.new(0, 12, 0, 12),
        ButtonSpacing = 8,
        UseImages = false,
        Alignment = "Left",
        Colors = {
            Close = Color3.fromRGB(255, 95, 86),
            Maximize = Color3.fromRGB(40, 201, 64)
        }
    },
    Windows = {
        ButtonSize = UDim2.new(0, 32, 1, 0),
        ButtonSpacing = 0,
        UseImages = true,
        Alignment = "Right",
        Transparency = 1,
        Icons = {
            Maximize = {
                Image = "rbxassetid://9886659001",
                ColorKey = "TextPrimary",
                Size = UDim2.new(0, 16, 0, 16),
                HoverColor = Color3.fromRGB(60, 60, 60),
                PressedColor = Color3.fromRGB(80, 80, 80)
            },
            Close = {
                Image = "rbxassetid://10747384394",
                ColorKey = "TextPrimary",
                Size = UDim2.new(0, 16, 0, 16),
                HoverColor = Color3.fromRGB(232, 17, 35),
                PressedColor = Color3.fromRGB(180, 10, 25)
            }
        }
    }
}

SimpleUI.Themes = {
    Panjepang = {
        Primary = Color3.fromRGB(14, 15, 18),
        Secondary = Color3.fromRGB(24, 25, 30),
        SecondaryHover = Color3.fromRGB(34, 36, 42),
        SecondaryActive = Color3.fromRGB(48, 50, 58),
        SecondaryPressed = Color3.fromRGB(20, 21, 26),
        Tertiary = Color3.fromRGB(30, 32, 38),
        TertiaryHover = Color3.fromRGB(42, 44, 52),
        TertiaryActive = Color3.fromRGB(56, 58, 68),
        TertiaryPressed = Color3.fromRGB(26, 28, 34),
        Quaternary = Color3.fromRGB(18, 19, 24),
        QuaternaryHover = Color3.fromRGB(28, 29, 36),
        Separator = Color3.fromRGB(48, 50, 58),
        SeparatorTransparency = 0.15,
        BoxBackground = Color3.fromRGB(12, 13, 16),
        TextPrimary = Color3.fromRGB(240, 241, 245),
        TextSecondary = Color3.fromRGB(170, 173, 180),
        TextInactive = Color3.fromRGB(115, 117, 125),
        TextActive = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(168, 85, 247),
        TabAccent = Color3.fromRGB(192, 132, 252),
        TabIconActive = Color3.fromRGB(192, 132, 252),
        TabIconHover = Color3.fromRGB(220, 220, 230),
        TabIconInactive = Color3.fromRGB(115, 117, 125),
        FontPrimary = Enum.Font.GothamBold,
        FontSecondary = Enum.Font.GothamMedium,
        FontSizePrimary = 18,
        FontSizeSecondary = 16,
        TransparencyPrimary = 0.02,
        TransparencySecondary = 0.75,
        TransparencyTertiary = 0.45
    },

}
SimpleUI.Themes.DefaultTheme = SimpleUI.Themes.Panjepang

-- Helper frameworks
do
    SimpleUI.ErrorHandler = {}
    do
        local ErrorLevels = {
            SILENT = 0,
            WARN = 1,
            ERROR = 2,
            CRITICAL = 3
        }
        SimpleUI.ErrorHandler.Level = ErrorLevels.WARN
        SimpleUI.ErrorHandler.Levels = ErrorLevels
        local Colors = {
            [ErrorLevels.WARN] = "255,255,0",
            [ErrorLevels.ERROR] = "255,100,100",
            [ErrorLevels.CRITICAL] = "255,0,0"
        }

        RunService.Heartbeat:Connect(function()
            local Console = CoreGui:FindFirstChild("DevConsoleMaster")
            if Console then
                for _, v in pairs(Console:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        v.RichText = true
                    end
                end
            end
        end)

        local function RichPrint(Color, Text)
            local RGB = Colors[Color] or "255,255,255"
            print('<font color="rgb(' .. RGB .. ')">' .. tostring(Text) .. '</font>')
        end
        local function FormatError(Context, Message, Level)
            local Prefix = ({
                [ErrorLevels.WARN] = "[SimpleUI:WARN]",
                [ErrorLevels.ERROR] = "[SimpleUI:ERROR]",
                [ErrorLevels.CRITICAL] = "[SimpleUI:CRITICAL]"
            })[Level] or "[SimpleUI]"
            return Prefix .. " " .. Context .. ": " .. Message
        end
        local function LogError(Context, Message, Level)
            if Level == ErrorLevels.SILENT then
                return
            end
            if Level < SimpleUI.ErrorHandler.Level then
                return
            end
            RichPrint(Level, FormatError(Context, Message, Level))
        end
        function SimpleUI.ErrorHandler:Wrap(Func, Context, DefaultReturn)
            return function(...)
                local Success, Result = pcall(Func, ...)
                if not Success then
                    LogError(Context, tostring(Result), ErrorLevels.ERROR)
                    return DefaultReturn
                end
                return Result
            end
        end

        function SimpleUI.ErrorHandler:Guard(Condition, Context, Message, Level)
            if not Condition then
                LogError(Context, Message, Level or ErrorLevels.WARN)
                return false
            end
            return true
        end

        function SimpleUI.ErrorHandler:ValidateType(Value, ExpectedType, ParamName, Context)
            local ActualType = typeof(Value)
            if ActualType ~= ExpectedType then
                LogError(Context,
                    "Invalid type for '" .. ParamName .. "': expected " .. ExpectedType .. ", got " .. ActualType,
                    ErrorLevels.WARN)
                return false
            end
            return true
        end

        function SimpleUI.ErrorHandler:ValidateRange(Value, Min, Max, ParamName, Context)
            if Value < Min or Value > Max then
                LogError(Context,
                    "'" .. ParamName .. "' out of range: " .. tostring(Value) .. " not in [" .. tostring(Min) .. ", " ..
                        tostring(Max) .. "]", ErrorLevels.WARN)
                return false
            end
            return true
        end

        function SimpleUI.ErrorHandler:ValidateInstance(Instance, ExpectedClass, Context)
            if not Instance then
                LogError(Context, "Instance is nil", ErrorLevels.WARN)
                return false
            end
            if not Instance:IsA(ExpectedClass) then
                LogError(Context, "Invalid instance type: expected " .. ExpectedClass .. ", got " .. Instance.ClassName,
                    ErrorLevels.WARN)
                return false
            end
            return true
        end

        function SimpleUI.ErrorHandler:ValidateOptions(Options, Required, Optional, Context)
            Options = Options or {}
            for _, Key in ipairs(Required or {}) do
                if Options[Key] == nil then
                    LogError(Context, "Missing required option: '" .. Key .. "'", ErrorLevels.WARN)
                    return false
                end
            end
            local Allowed = {}
            for _, Key in ipairs(Required or {}) do
                Allowed[Key] = true
            end
            for _, Key in ipairs(Optional or {}) do
                Allowed[Key] = true
            end
            for Key in pairs(Options) do
                if not Allowed[Key] then
                    LogError(Context, "Unknown option: '" .. Key .. "'", ErrorLevels.WARN)
                end
            end
            return true
        end

        function SimpleUI.ErrorHandler:Try(Func, Fallback)
            local Success, Result = pcall(Func)
            if not Success then
                return Fallback and Fallback() or nil
            end
            return Result
        end

        function SimpleUI.ErrorHandler:SetLevel(Level)
            self.Level = Level
        end
    end

    SimpleUI.Security = {}
    do
        local ProtectedFunctions = {}
        local HookedMetatables = {}
        function SimpleUI.Security:WrapFunction(Func)
            if not Func or type(Func) ~= "function" then
                return Func
            end
            if ProtectedFunctions[Func] then
                return ProtectedFunctions[Func]
            end
            local Protected = newcclosure(function(...)
                return Func(...)
            end)
            ProtectedFunctions[Func] = Protected
            return Protected
        end

        function SimpleUI.Security:SafeCallback(Callback, ...)
            if not (Callback and typeof(Callback) == "function") then
                return nil
            end
            local _, Result = xpcall(Callback, function(Error)
                if SimpleUI.ErrorHandler.Level >= SimpleUI.ErrorHandler.Levels.ERROR then
                    SimpleUI.ErrorHandler:Guard(false, "SafeCallback", tostring(Error),
                        SimpleUI.ErrorHandler.Levels.ERROR)
                end
                return Error
            end, ...)
            return Result
        end

        function SimpleUI.Security:ProtectMetatable(Object)
            if not Object or HookedMetatables[Object] then
                return false
            end
            local Success = pcall(function()
                local MT = getmetatable(Object)
                if not MT then
                    return
                end
                local OriginalIndex = MT.__index
                local OriginalNewIndex = MT.__newindex
                local OriginalNamecall = MT.__namecall
                if OriginalIndex then
                    MT.__index = newcclosure(function(self, Key)
                        if type(OriginalIndex) == "function" then
                            return OriginalIndex(self, Key)
                        else
                            return OriginalIndex[Key]
                        end
                    end)
                end
                if OriginalNewIndex then
                    MT.__newindex = newcclosure(function(self, Key, Value)
                        if type(OriginalNewIndex) == "function" then
                            return OriginalNewIndex(self, Key, Value)
                        else
                            OriginalNewIndex[Key] = Value
                        end
                    end)
                end
                if OriginalNamecall then
                    MT.__namecall = newcclosure(function(self, ...)
                        return OriginalNamecall(self, ...)
                    end)
                end
                HookedMetatables[Object] = {
                    OriginalIndex = OriginalIndex,
                    OriginalNewIndex = OriginalNewIndex,
                    OriginalNamecall = OriginalNamecall
                }
            end)
            return Success
        end
    end

    SimpleUI.EventProtection = {} -- Deprecated
    do
        local ProtectedEvents = {}
        function SimpleUI.EventProtection:Protect(Event)
            if not Event or ProtectedEvents[Event] then
                return false
            end
            ProtectedEvents[Event] = true
            local OriginalConnect = Event.Connect
            Event.Connect = newcclosure(function(self, ...)
                return OriginalConnect(self, ...)
            end)
            local OriginalWait = Event.Wait
            Event.Wait = newcclosure(function(self, ...)
                return OriginalWait(self, ...)
            end)
            return true
        end
    end

    SimpleUI.ConnectionRegistry = {}
    do
        function SimpleUI.ConnectionRegistry:New()
            local registry = {
                _connections = {}
            }

            function registry:Add(connection)
                if connection and typeof(connection) == "RBXScriptConnection" then
                    table.insert(self._connections, connection)
                end
                return connection
            end

            function registry:Remove(connection)
                for i, c in ipairs(self._connections) do
                    if c == connection then
                        if c.Connected then
                            c:Disconnect()
                        end
                        table.remove(self._connections, i)
                        return
                    end
                end
            end

            function registry:Cleanup()
                for _, c in ipairs(self._connections) do
                    if c.Connected then
                        c:Disconnect()
                    end
                end
                table.clear(self._connections)
            end

            return registry
        end
    end

    SimpleUI.MetatableProtection = {}
    do
        local ProtectedObjects = {}
        function SimpleUI.MetatableProtection:Protect(Object)
            if not Object or ProtectedObjects[Object] then
                return false
            end
            ProtectedObjects[Object] = true
            return true
        end

        function SimpleUI.MetatableProtection:ProtectUI(ScreenGui)
            if not ScreenGui then
                return false
            end
            self:Protect(ScreenGui)
            for _, Descendant in ipairs(ScreenGui:GetDescendants()) do
                if Descendant:IsA("GuiObject") then
                    self:Protect(Descendant)
                end
            end
            return true
        end
    end

    SimpleUI.Utility = {}
    do
        function SimpleUI.Utility:GetService(ServiceName)
            return cloneref(game:GetService(ServiceName))
        end

        function SimpleUI.Utility:IsMobile()
            return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        end

        function SimpleUI.Utility:CreateInstance(ClassName, Properties, Parent)
            local Instance = Instance.new(ClassName)
            if Properties then
                for Property, Value in pairs(Properties) do
                    Instance[Property] = Value
                end
            end
            if Parent then
                Instance.Parent = Parent
            end
            return Instance
        end

        function SimpleUI.Utility:GenerateId()
            local charset =
                "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>?/`~"
            local rng = Random.new(math.floor(os.clock() * 1e9) + math.floor(tick() * 1e6) + math.random(1, 1e9))
            local length = rng:NextInteger(24, 40)
            local output = table.create(length)
            for i = 1, length do
                local index = rng:NextInteger(1, #charset)
                output[i] = charset:sub(index, index)
            end
            return table.concat(output)
        end

        function SimpleUI.Utility:MergeTables(Base, Override)
            local Result = {}
            for Key, Value in pairs(Base or {}) do
                Result[Key] = type(Value) == "table" and self:MergeTables(Value, {}) or Value
            end
            for Key, Value in pairs(Override or {}) do
                if type(Value) == "table" and type(Result[Key]) == "table" then
                    Result[Key] = self:MergeTables(Result[Key], Value)
                else
                    Result[Key] = Value
                end
            end
            return Result
        end

        function SimpleUI.Utility:ApplyTheme(Properties, ThemeBindings, Theme)
            local Result = {}
            local Bindings = {}
            for Property, Value in pairs(Properties) do
                Result[Property] = Value
            end
            if ThemeBindings then
                for Property, ThemeKey in pairs(ThemeBindings) do
                    if Theme[ThemeKey] then
                        Result[Property] = Theme[ThemeKey]
                        Bindings[Property] = ThemeKey
                    end
                end
            end
            return Result, Bindings
        end

        function SimpleUI.Utility:GetWindowFromElement(Element)
            local Current = Element
            while Current do
                if Current:IsA("ScreenGui") and SimpleUI.Windows[Current] then
                    return SimpleUI.Windows[Current]
                end
                Current = Current.Parent
            end
            return nil
        end

        function SimpleUI.Utility:ParentUI(Element, TargetParent)
            local Success = pcall(function()
                local FinalParent
                pcall(protectgui, Element)
                FinalParent = gethui()
                if TargetParent then
                    if type(TargetParent) == "function" then
                        FinalParent = TargetParent()
                    else
                        FinalParent = TargetParent
                    end
                end
                Element.Parent = FinalParent
            end)
            if not (Success and Element.Parent) then
                Element.Parent = LocalPlayer:WaitForChild("CoreGui", math.huge)
            end
        end

        function SimpleUI.Utility:Tween(object, tweenInfo, properties)
            if not object or not object.Parent then
                return
            end
            TweenService:Create(object, tweenInfo, properties):Play()
        end
    end

    SimpleUI.SaveManager = {}
    do
        SimpleUI.SaveManager.Enabled = true
        SimpleUI.SaveManager.AutoSave = true
        SimpleUI.SaveManager.Folder = "SimpleUI"
        SimpleUI.SaveManager.FileName = tostring(game.PlaceId) .. ".json"
        SimpleUI.SaveManager.Values = {}
        SimpleUI.SaveManager.Loaded = false

        local function hasFilesystem()
            return type(readfile) == "function" and type(writefile) == "function" and type(isfile) == "function" and
                       type(makefolder) == "function" and type(isfolder) == "function"
        end

        local function splitPath(path)
            local parts = {}
            for part in tostring(path or ""):gmatch("[^/\\]+") do
                table.insert(parts, part)
            end
            return parts
        end

        local function ensureFolder(path)
            if not hasFilesystem() then
                return false
            end

            local current = ""
            for _, part in ipairs(splitPath(path)) do
                current = current == "" and part or (current .. "/" .. part)
                if not isfolder(current) then
                    local ok = pcall(makefolder, current)
                    if not ok then
                        return false
                    end
                end
            end
            return true
        end

        local function sanitizeKey(value)
            local text = tostring(value or "value")
            text = text:gsub("%s+", "_"):gsub("[^%w_%-%.:]", "")
            return text ~= "" and text or "value"
        end

        function SimpleUI.SaveManager:IsAvailable()
            return hasFilesystem()
        end

        function SimpleUI.SaveManager:Configure(options)
            options = options or {}
            if options.Enabled ~= nil then
                self.Enabled = options.Enabled == true
            end
            if options.AutoSave ~= nil then
                self.AutoSave = options.AutoSave == true
            end
            if type(options.Folder) == "string" and options.Folder ~= "" then
                self.Folder = options.Folder
            end
            if type(options.FileName) == "string" and options.FileName ~= "" then
                self.FileName = options.FileName
            end
            if type(options.File) == "string" and options.File ~= "" then
                self.FileName = options.File
            end
            self:Load()
            return self
        end

        function SimpleUI.SaveManager:GetPath()
            return self.Folder .. "/" .. self.FileName
        end

        function SimpleUI.SaveManager:Load()
            if self.Loaded then
                return self.Values
            end
            self.Loaded = true
            self.Values = {}

            if not self.Enabled or not self:IsAvailable() then
                return self.Values
            end

            local path = self:GetPath()
            if not isfile(path) then
                return self.Values
            end

            local ok, data = pcall(function()
                local body = readfile(path)
                if type(body) ~= "string" or body == "" then
                    return {}
                end
                return SimpleUI.Utility:GetService("HttpService"):JSONDecode(body)
            end)

            if ok and type(data) == "table" then
                self.Values = data
            end

            return self.Values
        end

        function SimpleUI.SaveManager:Save()
            if not self.Enabled or not self:IsAvailable() then
                return false
            end
            if not ensureFolder(self.Folder) then
                return false
            end

            local ok = pcall(function()
                local body = SimpleUI.Utility:GetService("HttpService"):JSONEncode(self.Values or {})
                writefile(self:GetPath(), body)
            end)
            return ok
        end

        function SimpleUI.SaveManager:Get(key, defaultValue)
            self:Load()
            if self.Values[key] == nil then
                return defaultValue
            end
            return self.Values[key]
        end

        function SimpleUI.SaveManager:Set(key, value)
            if not key then
                return false
            end
            self:Load()
            self.Values[key] = value
            if self.AutoSave then
                return self:Save()
            end
            return true
        end

        function SimpleUI.SaveManager:Remove(key)
            if not key then
                return false
            end
            self:Load()
            self.Values[key] = nil
            if self.AutoSave then
                return self:Save()
            end
            return true
        end

        function SimpleUI.SaveManager:GetBinding(options, componentType, label)
            options = options or {}
            local saveConfig = options.Save
            if saveConfig == nil then
                saveConfig = options.Persist
            end

            local enabled = false
            local key = options.SaveKey or options.Flag
            local applyCallback = true

            if type(saveConfig) == "table" then
                enabled = saveConfig.Enabled ~= false
                key = saveConfig.Key or saveConfig.Flag or saveConfig.Name or key
                if saveConfig.ApplyCallback ~= nil then
                    applyCallback = saveConfig.ApplyCallback == true
                end
            elseif saveConfig == true then
                enabled = true
            end

            if not enabled then
                return {
                    Enabled = false,
                    HasValue = false,
                    ApplyCallback = false
                }
            end

            key = key or (tostring(componentType or "Component") .. ":" .. sanitizeKey(label))
            self:Load()

            return {
                Enabled = self.Enabled and self:IsAvailable(),
                Key = key,
                HasValue = self.Values[key] ~= nil,
                Value = self.Values[key],
                ApplyCallback = applyCallback
            }
        end

        function SimpleUI.SaveManager:WriteBinding(binding, value)
            if not binding or not binding.Enabled or not binding.Key then
                return false
            end
            if value == nil then
                return self:Remove(binding.Key)
            end
            return self:Set(binding.Key, value)
        end
    end

    SimpleUI.ThemeManager = {}
    do
        function SimpleUI.ThemeManager:Initialize(Window)
            local EH = SimpleUI.ErrorHandler
            if not EH:ValidateType(Window, "table", "Window", "ThemeManager:Initialize") then
                return false
            end
            Window.ThemeData = {
                Elements = {},
                CurrentTheme = Window.Theme or SimpleUI.Themes.DefaultTheme
            }
            return true
        end

        function SimpleUI.ThemeManager:GetCurrentTheme(Window)
            local EH = SimpleUI.ErrorHandler
            if not Window then
                EH:Guard(false, "ThemeManager:GetCurrentTheme", "Window is nil, using DefaultTheme", EH.Levels.WARN)
                return SimpleUI.Themes.DefaultTheme
            end
            if not Window.ThemeData then
                EH:Guard(false, "ThemeManager:GetCurrentTheme", "ThemeData not initialized, using DefaultTheme",
                    EH.Levels.WARN)
                return SimpleUI.Themes.DefaultTheme
            end
            return Window.ThemeData.CurrentTheme
        end

        function SimpleUI.ThemeManager:RegisterElement(Window, Element, Bindings)
            local EH = SimpleUI.ErrorHandler
            if not Window or not Window.ThemeData then
                EH:Guard(false, "ThemeManager:RegisterElement", "Invalid window", EH.Levels.WARN)
                return false
            end
            if not Element then
                EH:Guard(false, "ThemeManager:RegisterElement", "Element is nil", EH.Levels.WARN)
                return false
            end
            if not EH:ValidateType(Bindings, "table", "Bindings", "ThemeManager:RegisterElement") then
                return false
            end
            for Property, ThemeKey in pairs(Bindings) do
                if EH:ValidateType(Property, "string", "Property", "ThemeManager:RegisterElement") then
                    local found = false
                    for _, existing in ipairs(Window.ThemeData.Elements) do
                        if existing.Element == Element and existing.Property == Property then
                            existing.ThemeKey = ThemeKey
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(Window.ThemeData.Elements, {
                            Element = Element,
                            Property = Property,
                            ThemeKey = ThemeKey
                        })
                    end
                end
            end
            return true
        end

        function SimpleUI.ThemeManager:RegisterMultiple(Window, Elements)
            local EH = SimpleUI.ErrorHandler
            if not Window then
                EH:Guard(false, "ThemeManager:RegisterMultiple", "Window is nil", EH.Levels.WARN)
                return false
            end
            if not EH:ValidateType(Elements, "table", "Elements", "ThemeManager:RegisterMultiple") then
                return false
            end
            for Element, Bindings in pairs(Elements) do
                EH:Try(function()
                    self:RegisterElement(Window, Element, Bindings)
                end)
            end
            return true
        end

        function SimpleUI.ThemeManager:ApplyToElement(Element, Property, ThemeKey, Theme, Animate)
            local EH = SimpleUI.ErrorHandler
            if not Element or not Element.Parent then
                return false
            end
            if type(ThemeKey) == "function" then
                return EH:Try(function()
                    ThemeKey(Element, Theme)
                    return true
                end, function()
                    return false
                end)
            end
            if not EH:ValidateType(Property, "string", "Property", "ThemeManager:ApplyToElement") then
                return false
            end
            local Value = Theme[ThemeKey]
            if Value == nil then
                EH:Guard(false, "ThemeManager:ApplyToElement",
                    string.format("Theme key '%s' not found", tostring(ThemeKey)), EH.Levels.WARN)
                return false
            end
            return EH:Try(function()
                if Animate and (Property:find("Color") or Property:find("Transparency")) then
                    TweenService:Create(Element,
                        TweenInfo.new(SimpleUI.Constants.Animation.Normal, Enum.EasingStyle.Quad), {
                            [Property] = Value
                        }):Play()
                else
                    Element[Property] = Value
                end
                return true
            end, function()
                EH:Guard(false, "ThemeManager:ApplyToElement", string.format("Failed to apply property '%s'", Property),
                    EH.Levels.WARN)
                return false
            end)
        end

        function SimpleUI.ThemeManager:SetTheme(Window, ThemeName, Animate)
            local EH = SimpleUI.ErrorHandler
            if not Window or not Window.ThemeData then
                EH:Guard(false, "ThemeManager:SetTheme", "Invalid window", EH.Levels.ERROR)
                return false
            end
            if not EH:ValidateType(ThemeName, "string", "ThemeName", "ThemeManager:SetTheme") then
                return false
            end
            local NewTheme = SimpleUI.Themes[ThemeName]
            if not NewTheme then
                EH:Guard(false, "ThemeManager:SetTheme", string.format("Theme '%s' not found", ThemeName),
                    EH.Levels.ERROR)
                return false
            end
            Window.ThemeData.CurrentTheme = NewTheme
            Window.Theme = NewTheme
            local alive = {}
            for _, Entry in ipairs(Window.ThemeData.Elements) do
                if Entry.Element and Entry.Element.Parent then
                    table.insert(alive, Entry)
                end
            end
            Window.ThemeData.Elements = alive
            local ProcessedElements = {}
            for _, Entry in ipairs(Window.ThemeData.Elements) do
                local Element = Entry.Element
                local Property = Entry.Property
                ProcessedElements[Element] = ProcessedElements[Element] or {}
                if not ProcessedElements[Element][Property] then
                    ProcessedElements[Element][Property] = true
                    EH:Try(function()
                        if type(Entry.ThemeKey) == "function" then
                            Entry.ThemeKey(Element, NewTheme)
                        else
                            self:ApplyToElement(Element, Property, Entry.ThemeKey, NewTheme, Animate)
                        end
                    end)
                end
            end
            return true
        end

        function SimpleUI.ThemeManager:GetThemeName(Window)
            local EH = SimpleUI.ErrorHandler
            if not Window or not Window.ThemeData then
                EH:Guard(false, "ThemeManager:GetThemeName", "Invalid window, defaulting to Secondary", EH.Levels.WARN)
                return "Secondary"
            end
            for Name, Theme in pairs(SimpleUI.Themes) do
                if Theme == Window.ThemeData.CurrentTheme then
                    return Name
                end
            end
            EH:Guard(false, "ThemeManager:GetThemeName", "Theme not found in registry, defaulting to Secondary",
                EH.Levels.WARN)
            return "Secondary"
        end
    end

    SimpleUI.ScrollManager = {}
    do
        function SimpleUI.ScrollManager:Update(Container)
            local EH = SimpleUI.ErrorHandler
            if not Container or not Container.Parent then
                return Container
            end
            if not (Container:IsA("Frame") or Container:IsA("ScrollingFrame")) then
                EH:Guard(false, "ScrollManager:Update", "Container must be Frame or ScrollingFrame", EH.Levels.WARN)
                return Container
            end
            local Layout = Container:FindFirstChildWhichIsA("UIListLayout")
            if not Layout then
                return Container
            end
            local Parent = Container.Parent
            if not Parent then
                return Container
            end
            local ContentHeight = Layout.AbsoluteContentSize.Y
            local AvailableHeight = Container.AbsoluteSize.Y
            local NeedsScrolling = ContentHeight > AvailableHeight
            local IsScrollFrame = Container:IsA("ScrollingFrame")
            if NeedsScrolling and not IsScrollFrame then
                local ScrollFrame = SimpleUI.Utility:CreateInstance("ScrollingFrame", {
                    Name = Container.Name,
                    Position = Container.Position,
                    Size = Container.Size,
                    AnchorPoint = Container.AnchorPoint,
                    BackgroundColor3 = Container.BackgroundColor3,
                    BackgroundTransparency = Container.BackgroundTransparency,
                    BorderSizePixel = 0,
                    BorderMode = Enum.BorderMode.Inset,
                    ZIndex = Container.ZIndex,
                    LayoutOrder = Container.LayoutOrder,
                    Visible = Container.Visible,
                    ClipsDescendants = true,
                    ScrollBarThickness = 0,
                    ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200),
                    ScrollBarImageTransparency = 1,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
                    ScrollingEnabled = true,
                    Active = true
                }, Parent)
                for _, Child in ipairs(Container:GetChildren()) do
                    Child.Parent = ScrollFrame
                end
                local ScreenGui = Parent
                while ScreenGui and not ScreenGui:IsA("ScreenGui") do
                    ScreenGui = ScreenGui.Parent
                end
                if ScreenGui and SimpleUI.Windows[ScreenGui] then
                    local Window = SimpleUI.Windows[ScreenGui]
                    if Window.Elements and Window.Elements.Pages then
                        for PageName, Page in pairs(Window.Elements.Pages) do
                            if Page == Container then
                                Window.Elements.Pages[PageName] = ScrollFrame
                                break
                            end
                        end
                    end
                    if Window.ActivePage == Container then
                        Window.ActivePage = ScrollFrame
                    end
                    if Window.Elements.TabsContainer == Container then
                        Window.Elements.TabsContainer = ScrollFrame
                    end
                end
                Container:Destroy()
                Container = ScrollFrame
            elseif not NeedsScrolling and IsScrollFrame then
                Container.ScrollBarThickness = 0
            elseif NeedsScrolling and IsScrollFrame then
                Container.ScrollBarImageTransparency = 1
            end
            if Layout and not Layout:GetAttribute("ScrollUpdateHooked") then
                Layout:SetAttribute("ScrollUpdateHooked", true)
                local UpdateQueued = false
                local LastContentSize = Layout.AbsoluteContentSize
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if UpdateQueued or Layout.AbsoluteContentSize == LastContentSize then
                        return
                    end
                    LastContentSize = Layout.AbsoluteContentSize
                    UpdateQueued = true
                    task.defer(function()
                        UpdateQueued = false
                        if Container and Container.Parent then
                            SimpleUI.ScrollManager:Update(Container)
                        end
                    end)
                end)
            end
            return Container
        end
    end

    SimpleUI.WindowControlBuilder = {}
    do
        function SimpleUI.WindowControlBuilder:Create(ControlType, Style, Parent, Index, TotalControls)
            local Config = SimpleUI.WindowControls[Style]
            if not Config then
                return
            end
            local IconData = Config.Icons and Config.Icons[ControlType] or {}
            local Alignment = Config.Alignment or "Right"
            local BaseColor = Config.Colors and Config.Colors[ControlType] or Color3.fromRGB(45, 45, 45)
            local Spacing = Config.ButtonSpacing or 0
            local IsMobile = SimpleUI.Utility:IsMobile()
            local Position = Alignment == "Left" and
                                 UDim2.new(0, Index * (Config.ButtonSize.X.Offset + Spacing), 0.5, 0) or
                                 UDim2.new(1, -(TotalControls - Index) * (Config.ButtonSize.X.Offset + Spacing), 0.5, 0)
            local Button = SimpleUI.Utility:CreateInstance("TextButton", {
                Name = ControlType .. "Button",
                Size = Config.ButtonSize,
                Position = Position,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = BaseColor,
                BackgroundTransparency = Config.Transparency or 0,
                Text = "",
                BorderSizePixel = 0,
                ClipsDescendants = true,
                AutoButtonColor = false,
                ZIndex = SimpleUI.Constants.ZIndex.Control
            }, Parent)
            if Config.UseImages and IconData.Image then
                SimpleUI.Utility:CreateInstance("ImageLabel", {
                    Size = IconData.Size or UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = IconData.Image,
                    ImageColor3 = IconData.Color or Color3.fromRGB(255, 255, 255),
                    ZIndex = SimpleUI.Constants.ZIndex.Control + 1
                }, Button)
            end
            SimpleUI.Utility:CreateInstance("UICorner", {
                CornerRadius = Alignment == "Left" and UDim.new(1, 0) or UDim.new(0, 0)
            }, Button)
            if not IsMobile then
                if IconData.HoverColor then
                    local IsHovering = false
                    Button.MouseEnter:Connect(function()
                        IsHovering = true
                        Button.BackgroundColor3 = IconData.HoverColor
                    end)
                    Button.MouseLeave:Connect(function()
                        IsHovering = false
                        Button.BackgroundColor3 = BaseColor
                    end)
                    if IconData.PressedColor then
                        Button.Activated:Connect(function()
                            Button.BackgroundColor3 = IconData.PressedColor
                            task.wait(0.1)
                            Button.BackgroundColor3 = IsHovering and IconData.HoverColor or BaseColor
                        end)
                    end
                end
            elseif IconData.PressedColor then
                Button.Activated:Connect(function()
                    Button.BackgroundColor3 = IconData.PressedColor
                    task.wait(0.1)
                    Button.BackgroundColor3 = BaseColor
                end)
            end
            self:BindActions(Button, ControlType, Parent)
            return Button
        end

        function SimpleUI.WindowControlBuilder:BindActions(Button, ControlType, TopBar)
            local EH = SimpleUI.ErrorHandler
            local ParentFrame = TopBar.Parent
            if not ParentFrame or not TopBar then
                EH:Guard(false, "WindowControlBuilder:BindActions", "Invalid frame references", EH.Levels.ERROR)
                return
            end
            if ControlType == "Close" then
                Button.Activated:Connect(function()
                    local ScreenGui = ParentFrame.Parent.Parent
                    if not ScreenGui then
                        return
                    end

                    local FadeDuration = SimpleUI.Constants.Animation.Slow
                    local TweenInfo = TweenInfo.new(FadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    local Tweens = {}

                    for _, Object in ipairs(ScreenGui:GetDescendants()) do
                        if Object:IsA("GuiObject") then
                            local Properties = {
                                Position = UDim2.new(Object.Position.X.Scale - 1.5, Object.Position.X.Offset,
                                    Object.Position.Y.Scale, Object.Position.Y.Offset)
                            }

                            if Object:IsA("Frame") or Object:IsA("ScrollingFrame") or Object:IsA("TextButton") or
                                Object:IsA("TextLabel") then
                                Properties.BackgroundTransparency = 1
                            end
                            if Object:IsA("TextButton") or Object:IsA("TextLabel") then
                                Properties.TextTransparency = 1
                            end
                            if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
                                Properties.ImageTransparency = 1
                            end

                            table.insert(Tweens, TweenService:Create(Object, TweenInfo, Properties))
                        end
                    end

                    for _, Tween in ipairs(Tweens) do
                        Tween:Play()
                    end

                    task.delay(FadeDuration, function()
                        SimpleUI.Windows[ScreenGui] = nil
                        ScreenGui:Destroy()
                    end)
                end)
            end
            if ControlType == "Maximize" then
                Button.Activated:Connect(function()
                    local ScreenGui = ParentFrame.Parent.Parent
                    if not ScreenGui then
                        return
                    end
                    local MainFrame = ScreenGui:FindFirstChild("MainFrame")
                    if not MainFrame then
                        return
                    end
                    if not MainFrame:GetAttribute("OriginalSize") then
                        MainFrame:SetAttribute("OriginalSize", MainFrame.Size)
                        MainFrame:SetAttribute("OriginalPosition", MainFrame.Position)
                        MainFrame:SetAttribute("OriginalAnchorPoint", MainFrame.AnchorPoint)
                    end
                    local IsMaximized = MainFrame:GetAttribute("Maximized") or false
                    MainFrame:SetAttribute("Maximized", not IsMaximized)

                    local TargetSize, TargetPosition, TargetAnchor
                    if not IsMaximized then
                        TargetSize = UDim2.new(0.95, 0, 0.95, 0)
                        TargetPosition = UDim2.new(0.5, 0, 0.5, 0)
                        TargetAnchor = Vector2.new(0.5, 0.5)
                    else
                        TargetSize = MainFrame:GetAttribute("OriginalSize")
                        TargetPosition = MainFrame:GetAttribute("OriginalPosition")
                        TargetAnchor = MainFrame:GetAttribute("OriginalAnchorPoint")
                    end

                    MainFrame.AnchorPoint = TargetAnchor
                    TweenService:Create(MainFrame, TweenInfo.new(SimpleUI.Constants.Animation.Normal,
                        Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = TargetSize,
                        Position = TargetPosition
                    }):Play()
                end)
            end
        end

        function SimpleUI.WindowControlBuilder:RegisterIconBindings(Window, ControlButtons, Options)
            local ControlStyle = Options.ControlStyle or "Windows"
            local Config = SimpleUI.WindowControls[ControlStyle]
            if not Config or not Config.Icons then
                return
            end
            local CurrentTheme = SimpleUI.ThemeManager:GetCurrentTheme(Window)
            for ControlType, Button in pairs(ControlButtons) do
                local IconData = Config.Icons[ControlType]
                if IconData and IconData.ColorKey then
                    local Icon = Button:FindFirstChildWhichIsA("ImageLabel")
                    if Icon then
                        local ColorValue = CurrentTheme[IconData.ColorKey]
                        if ColorValue then
                            Icon.ImageColor3 = ColorValue
                        end
                        SimpleUI.ThemeManager:RegisterElement(Window, Icon, {
                            ImageColor3 = function(Element, Theme)
                                local NewColorValue = Theme[IconData.ColorKey]
                                if NewColorValue then
                                    Element.ImageColor3 = NewColorValue
                                end
                            end
                        })
                    end
                end
            end
        end
    end

    SimpleUI.ComponentBuilder = {}
    do
        function SimpleUI.ComponentBuilder:CreateContainer(Config, Theme)
            if not SimpleUI.ErrorHandler:ValidateInstance(Config.Parent, "GuiObject", "ComponentBuilder:CreateContainer") then
                return nil
            end
            local IsDualScroll = Config.Parent:GetAttribute("IsDualScroll") or false
            local Container = SimpleUI.Utility:CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme[Config.ColorTier or "Secondary"],
                BackgroundTransparency = Theme.TransparencySecondary,
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Control
            }, Config.Parent)
            if Config.MinHeight then
                SimpleUI.Utility:CreateInstance("UISizeConstraint", {
                    MinSize = Vector2.new(0, Config.MinHeight)
                }, Container)
            end
            if Config.CornerRadius then
                SimpleUI.Utility:CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Config.CornerRadius)
                }, Container)
            end
            local Padding = Config.Padding or {}
            if type(Padding) == "number" then
                Padding = {
                    Top = Padding,
                    Bottom = Padding,
                    Left = Padding,
                    Right = Padding
                }
            end
            if type(Padding) == "table" then
                for key, value in pairs(Padding) do
                    if type(value) ~= "number" then
                        Padding[key] = SimpleUI.Constants.Padding.Medium
                    end
                end
            end
            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, Padding.Top or SimpleUI.Constants.Padding.Medium),
                PaddingBottom = UDim.new(0, Padding.Bottom or SimpleUI.Constants.Padding.Medium),
                PaddingLeft = UDim.new(0, Padding.Left or SimpleUI.Constants.Padding.Large),
                PaddingRight = UDim.new(0, IsDualScroll and -8 or (Padding.Right or SimpleUI.Constants.Padding.Medium))
            }, Container)
            local TextZone, InteractiveZone, Layout
            if Config.Layout == "TextLeft" then
                TextZone = SimpleUI.Utility:CreateInstance("Frame", {
                    Size = UDim2.new(Config.TextWidth or 0.65, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay
                }, Container)
                Layout = SimpleUI.Utility:CreateInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Config.HasDescription and Enum.VerticalAlignment.Top or
                        Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, SimpleUI.Constants.Spacing.Relaxed)
                }, TextZone)
                InteractiveZone = Container
            elseif Config.Layout == "Stacked" then
                local ContentFrame = SimpleUI.Utility:CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay
                }, Container)
                Layout = SimpleUI.Utility:CreateInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, Config.Spacing or SimpleUI.Constants.Spacing.Normal)
                }, ContentFrame)
                if not Config.HasDescription then
                    ContentFrame.Position = UDim2.new(0, 0, 0.5, 0)
                    ContentFrame.AnchorPoint = Vector2.new(0, 0.5)
                end
                TextZone = ContentFrame
                InteractiveZone = ContentFrame
            else
                TextZone = Container
                InteractiveZone = Container
            end
            return {
                Container = Container,
                TextZone = TextZone,
                InteractiveZone = InteractiveZone,
                Layout = Layout
            }
        end

        function SimpleUI.ComponentBuilder:CreateLabel(Parent, Text, Theme, Config)
            Config = Config or {}
            if Config and
                not SimpleUI.ErrorHandler:ValidateType(Config, "table", "Config", "ComponentBuilder:CreateLabel") then
                Config = {}
            end
            return SimpleUI.Utility:CreateInstance("TextLabel", {
                Size = UDim2.new(1, Config.WidthOffset or 0, 0, 0),
                BackgroundTransparency = 1,
                Text = Text or "",
                TextColor3 = Theme[Config.ColorTier or "TextPrimary"],
                TextSize = Config.Size or 14,
                Font = Theme[Config.Font or "FontSecondary"],
                TextXAlignment = Config.Align or Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = Config.Order or 1,
                ZIndex = SimpleUI.Constants.ZIndex.Overlay
            }, Parent)
        end

        function SimpleUI.ComponentBuilder:CreateDescription(Parent, Text, Theme, Order)
            if not Text or Text == "" then
                return nil
            end
            return self:CreateLabel(Parent, Text, Theme, {
                ColorTier = "TextSecondary",
                Size = 14,
                Order = Order or 2
            })
        end

        function SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasDescription)
            local Padding = Zones.Container:FindFirstChildOfClass("UIPadding")
            if not Padding then
                return
            end
            if HasDescription then
                Padding.PaddingTop = UDim.new(0, SimpleUI.Constants.Padding.Large)
                Padding.PaddingBottom = UDim.new(0, SimpleUI.Constants.Padding.Large)
                if Zones.Layout then
                    Zones.Layout.Padding = UDim.new(0, SimpleUI.Constants.Spacing.Tight)
                end
                if Zones.TextZone then
                    Zones.TextZone.Position = UDim2.new(0, 0, 0, 0)
                    Zones.TextZone.AnchorPoint = Vector2.new(0, 0)
                end
            else
                Padding.PaddingTop = UDim.new(0, 0)
                Padding.PaddingBottom = UDim.new(0, 0)
                if Zones.Layout then
                    Zones.Layout.Padding = UDim.new(0, 0)
                end
                if Zones.TextZone then
                    Zones.TextZone.Position = UDim2.new(0, 0, 0.5, 0)
                    Zones.TextZone.AnchorPoint = Vector2.new(0, 0.5)
                end
            end
        end
    end

    SimpleUI.DropdownManager = {}
    do
        function SimpleUI.DropdownManager:NormalizeOptions(Options)
            local EH = SimpleUI.ErrorHandler
            if not EH:ValidateType(Options, "table", "Options", "DropdownManager:NormalizeOptions") then
                return {}, {}
            end
            local Normalized = {}
            local DataMap = {}
            for Index, Option in ipairs(Options) do
                if type(Option) == "table" then
                    local DisplayText = Option.Text or Option.text or Option.Label or Option.label or tostring(Option)
                    Normalized[Index] = DisplayText
                    DataMap[DisplayText] = Option
                else
                    Normalized[Index] = tostring(Option)
                    DataMap[tostring(Option)] = Option
                end
            end
            return Normalized, DataMap
        end

        function SimpleUI.DropdownManager:InitializeSelection(DefaultValue, IsMultiSelect, DataMap)
            local EH = SimpleUI.ErrorHandler
            if IsMultiSelect then
                local Selected = {}
                if type(DefaultValue) == "table" then
                    if not EH:ValidateType(DefaultValue, "table", "DefaultValue", "DropdownManager:InitializeSelection") then
                        return Selected
                    end
                    for _, Value in ipairs(DefaultValue) do
                        local Normalized = type(Value) == "table" and
                                               (Value.Text or Value.text or Value.Label or Value.label or
                                                   tostring(Value)) or tostring(Value)
                        if DataMap[Normalized] then
                            Selected[Normalized] = true
                        end
                    end
                end
                return Selected
            else
                if DefaultValue then
                    local Normalized = type(DefaultValue) == "table" and
                                           (DefaultValue.Text or DefaultValue.text or DefaultValue.Label or
                                               DefaultValue.label or tostring(DefaultValue)) or tostring(DefaultValue)
                    return DataMap[Normalized] and Normalized or nil
                end
                return nil
            end
        end

        function SimpleUI.DropdownManager:GetSelectedData(Selection, IsMultiSelect, DataMap)
            if IsMultiSelect then
                local Selected = {}
                for Value, Enabled in pairs(Selection) do
                    if Enabled then
                        table.insert(Selected, DataMap[Value])
                    end
                end
                return Selected
            else
                return DataMap[Selection]
            end
        end

        function SimpleUI.DropdownManager:UpdateDisplayText(DisplayLabel, Selection, IsMultiSelect)
            local EH = SimpleUI.ErrorHandler
            if not DisplayLabel or not DisplayLabel.Parent then
                EH:Guard(false, "DropdownManager:UpdateDisplayText", "Invalid DisplayLabel", EH.Levels.WARN)
                return
            end
            EH:Try(function()
                if IsMultiSelect then
                    local Selected = {}
                    for Value, Enabled in pairs(Selection) do
                        if Enabled then
                            table.insert(Selected, Value)
                        end
                    end
                    DisplayLabel.Text = #Selected > 0 and table.concat(Selected, ", ") or "Select"
                else
                    DisplayLabel.Text = Selection or "Select"
                end
            end)
        end
    end

    SimpleUI.WindowBuilder = {}
    do
        function SimpleUI.WindowBuilder:CreateMainFrame(ScreenGui, Options, Theme)
            local MainFrameProperties, MainFrameBindings = SimpleUI.Utility:ApplyTheme({
                Name = "MainFrame",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Active = true,
                AutoButtonColor = false,
                Position = Options.Position or UDim2.new(0.5, 0, 0.5, 0),
                Size = Options.Size or UDim2.new(0, 650, 0, 600),
                Text = "",
                BorderSizePixel = 0,
                ClipsDescendants = false
            }, {
                BackgroundColor3 = "Primary",
                BackgroundTransparency = "TransparencyPrimary"
            }, Theme)
            local MainFrame = SimpleUI.Utility:CreateInstance("TextButton", MainFrameProperties, ScreenGui)
            SimpleUI.Utility:CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, SimpleUI.Constants.Corner.Large)
            }, MainFrame)
            SimpleUI.Utility:CreateInstance("UISizeConstraint", {
                MinSize = Options.MinSize or SimpleUI.Constants.Window.MinSize,
                MaxSize = Options.MaxSize or SimpleUI.Constants.Window.MaxSize
            }, MainFrame)
            local UIScale = SimpleUI.Utility:CreateInstance("UIScale", {
                Name = "WindowScale",
                Scale = Options.DefaultScale or SimpleUI.Constants.Window.DefaultScale
            }, MainFrame)
            return MainFrame, UIScale, MainFrameBindings
        end

        function SimpleUI.WindowBuilder:CreateTopBar(Parent, Options, Theme)
            local TopBarHeight = Options.TopBarHeight or SimpleUI.Constants.Window.TopBarHeight
            local TopBar = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "TopBar",
                Size = UDim2.new(1, 0, 0, TopBarHeight),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Base,
                ClipsDescendants = false,
                Active = true
            }, Parent)
            local Sep
            local SepBindings
            local SepProps
            if Options.TopBarSeparator ~= false then
                SepProps, SepBindings = SimpleUI.Utility:ApplyTheme({
                    Name = "TopBarSeparator",
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    ZIndex = TopBar.ZIndex + 1
                }, {
                    BackgroundColor3 = "Separator",
                    BackgroundTransparency = "SeparatorTransparency"
                }, Theme)
                Sep = SimpleUI.Utility:CreateInstance("Frame", SepProps, TopBar)
            end
            return TopBar, Sep, SepBindings
        end

        function SimpleUI.WindowBuilder:CreateTitleSection(TopBar, Options, Theme)
            local ControlStyle = Options.ControlStyle or "Windows"
            local HasBrand = Options.Brand ~= nil
            local BrandName = HasBrand and Options.Brand.Name or ""
            local BrandIcon = HasBrand and Options.Brand.Icon or nil

            local BaseLeftOffset = 10
            local IconSize = 40
            local IconGap = 12

            local BrandIconElement = nil
            local BrandInitialElement = nil

            if HasBrand then
                if BrandIcon and type(BrandIcon) == "table" and BrandIcon.Image then
                    local IconData = SimpleUI.IconManager:WrapIcon(BrandIcon)
                    BrandIconElement = SimpleUI.Utility:CreateInstance("ImageLabel", {
                        Name = "BrandIcon",
                        Size = UDim2.new(0, IconSize, 0, IconSize),
                        Position = UDim2.new(0, BaseLeftOffset, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Image = IconData.Url,
                        ImageColor3 = Theme.TextPrimary,
                        ScaleType = Enum.ScaleType.Fit,
                        BorderSizePixel = 0,
                        ZIndex = SimpleUI.Constants.ZIndex.Content + 1
                    }, TopBar)
                else
                    local Initials = BrandName:sub(1, 1):upper()
                    BrandInitialElement = SimpleUI.Utility:CreateInstance("TextLabel", {
                        Name = "BrandInitial",
                        Size = UDim2.new(0, IconSize, 0, IconSize),
                        Position = UDim2.new(0, BaseLeftOffset, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Text = Initials,
                        TextColor3 = Theme.TextPrimary,
                        Font = Enum.Font.GothamBold,
                        TextSize = 42,
                        BorderSizePixel = 0,
                        ZIndex = SimpleUI.Constants.ZIndex.Content
                    }, TopBar)
                end
            end

            local BrandTitleLabel = nil
            if HasBrand and BrandName and BrandName ~= "" then
                BrandTitleLabel = SimpleUI.Utility:CreateInstance("TextLabel", {
                    Name = "BrandTitle",
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Position = UDim2.new(0, BaseLeftOffset + IconSize + IconGap, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Text = BrandName,
                    TextColor3 = Theme.TextPrimary,
                    Font = Theme.FontPrimary,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextTransparency = 1,
                    ZIndex = SimpleUI.Constants.ZIndex.Content
                }, TopBar)

                SimpleUI.Utility:CreateInstance("UISizeConstraint", {
                    MaxSize = Vector2.new(200, math.huge)
                }, BrandTitleLabel)
            end

            local TabInfoContainer = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "TabInfoContainer",
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 0, 0.7, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Content,
                ClipsDescendants = true,
                Visible = true
            }, TopBar)

            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 200)
            }, TabInfoContainer)

            SimpleUI.Utility:CreateInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Padding = UDim.new(0, 2)
            }, TabInfoContainer)

            local TabNameLabel = SimpleUI.Utility:CreateInstance("TextLabel", {
                Name = "TabNameLabel",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = "Select Tab",
                TextColor3 = Theme.TextPrimary,
                Font = Theme.FontPrimary,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                LayoutOrder = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Content
            }, TabInfoContainer)

            local TabDescLabel = SimpleUI.Utility:CreateInstance("TextLabel", {
                Name = "TabDescLabel",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = "",
                TextColor3 = Theme.TextSecondary,
                Font = Theme.FontSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                LayoutOrder = 2,
                ZIndex = SimpleUI.Constants.ZIndex.Content
            }, TabInfoContainer)

            local ControlsContainer = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "ControlsContainer",
                Position = UDim2.new(1, -10, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                Size = UDim2.new(0, 100, 0.7, 0),
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Content,
                ClipsDescendants = false
            }, TopBar)

            return TabInfoContainer, ControlsContainer, TabNameLabel, TabDescLabel, BrandIconElement,
                BrandInitialElement, BrandTitleLabel
        end

        function SimpleUI.WindowBuilder:CreateWindowControls(ControlsContainer, Options, Theme)
            local ControlStyle = Options.ControlStyle or "Windows"
            local Controls = Options.WindowControls or
                                 (ControlStyle == "Windows" and {"Maximize", "Close"} or {"Close", "Maximize"})
            local ControlButtons = {}
            if Controls then
                for Index, ControlType in ipairs(Controls) do
                    local Button = SimpleUI.WindowControlBuilder:Create(ControlType, ControlStyle, ControlsContainer,
                        Index - 1, #Controls)
                    if Button then
                        ControlButtons[ControlType] = Button
                    end
                end
            end
            return ControlButtons
        end

        function SimpleUI.WindowBuilder:CreateContentAreas(MainContainer, MainFrame, TopBar, Options)
            local Const = SimpleUI.Constants.Window
            local TabsWidth = Const.TabsWidthOpen
            local ContentWidth = Const.ContentWidthOpen
            local IsCollapsed = Options.IsCollapsed
            local HorizontalPadding = IsCollapsed and 4 or Options.HorizontalPadding or Const.HorizontalPadding
            local HasBrand = Options.Brand ~= nil

            local TabsContainer = SimpleUI.Utility:CreateInstance("ScrollingFrame", {
                Name = "TabsContainer",
                Position = UDim2.new(0, HorizontalPadding, 0, 0),
                Size = UDim2.new(TabsWidth, -(HorizontalPadding * 1.5), 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Content,
                ClipsDescendants = true,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            }, MainContainer)
            SimpleUI.Utility:CreateInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, SimpleUI.Constants.Padding.Large)
            }, TabsContainer)
            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, 0),
                PaddingBottom = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 1)
            }, TabsContainer)
            local Theme = SimpleUI.ThemeManager:GetCurrentTheme({
                ThemeData = {
                    CurrentTheme = SimpleUI.Themes.DefaultTheme
                }
            })
            local TabsSeparatorProperties, TabsSeparatorBindings = SimpleUI.Utility:ApplyTheme({
                Name = "TabsSeparator",
                Position = UDim2.new(TabsWidth, Const.TabSeparatorGap, 0, HasBrand and 0 or Const.TopBarHeight),
                Size = UDim2.new(0, 1, 1, HasBrand and 0 or -Const.TopBarHeight),
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Content
            }, {
                BackgroundColor3 = "Separator",
                BackgroundTransparency = "SeparatorTransparency"
            }, Theme)
            local TabsSeparator = SimpleUI.Utility:CreateInstance("Frame", TabsSeparatorProperties, MainFrame)
            local ContentsContainer = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "ContentsContainer",
                Position = UDim2.new(TabsWidth, HorizontalPadding, 0, 0),
                Size = UDim2.new(ContentWidth, -(HorizontalPadding * 2), 1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Content,
                ClipsDescendants = true
            }, MainContainer)
            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingBottom = UDim.new(0, SimpleUI.Constants.Padding.Large),
                PaddingLeft = UDim.new(0, SimpleUI.Constants.Padding.Large),
                PaddingRight = UDim.new(0, SimpleUI.Constants.Padding.Large)
            }, ContentsContainer)
            return TabsContainer, ContentsContainer, TabsSeparator, TabsSeparatorBindings
        end

        function SimpleUI.WindowBuilder:CreateMainContainer(Parent, Options, Theme, TopBarHeight, FooterHeight)
            local VerticalPadding = Options.VerticalPadding or SimpleUI.Constants.Window.VerticalPadding
            local FooterOffset = (FooterHeight and FooterHeight > 0) and -(Options.FooterOverlap or 0) or 0
            local MainContainer = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "MainContainer",
                Position = UDim2.new(0, 0, 0, TopBarHeight),
                Size = UDim2.new(1, 0, 1, -(TopBarHeight + FooterOffset)),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Base,
                ClipsDescendants = true
            }, Parent)
            if Options.AcrylicEffect then
                local Blur = SimpleUI.Utility:CreateInstance("Frame", {
                    Name = "BlurBackground",
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0.3,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Background
                }, MainContainer)
                SimpleUI.Utility:CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, SimpleUI.Constants.Corner.Large)
                }, Blur)
                pcall(function()
                    local BlurEffect = Instance.new("BlurEffect")
                    BlurEffect.Size = 24
                    BlurEffect.Parent = Lighting
                end)
            end
            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, VerticalPadding),
                PaddingBottom = UDim.new(0, VerticalPadding),
                PaddingLeft = UDim.new(0, 0),
                PaddingRight = UDim.new(0, 0)
            }, MainContainer)
            return MainContainer
        end

        function SimpleUI.WindowBuilder:SetupDragging(TopBar, MainFrame)
            local IsDragging = false
            local DragStart
            local StartPosition
            TopBar.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType ==
                    Enum.UserInputType.Touch then
                    IsDragging = true
                    DragStart = Input.Position
                    StartPosition = MainFrame.Position
                    Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            IsDragging = false
                        end
                    end)
                end
            end)
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType ==
                    Enum.UserInputType.Touch then
                    IsDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(Input)
                if IsDragging and
                    (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType ==
                        Enum.UserInputType.Touch) then
                    local CurrentPosition = Input.Position
                    local Delta = CurrentPosition - DragStart
                    MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                        StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
                end
            end)
        end

        function SimpleUI.WindowBuilder:CreateFooter(Parent, Options, Theme)
            if not Options.Footer then
                return nil, {}, nil
            end
            local FooterHeight = Options.FooterHeight or 20
            local FooterOverlap = Options.FooterOverlap or -10
            local FooterProperties, FooterBindings = SimpleUI.Utility:ApplyTheme({
                Name = "Footer",
                Position = UDim2.new(0, 0, 1, FooterOverlap),
                AnchorPoint = Vector2.new(0, 0),
                Size = UDim2.new(1, 0, 0, FooterHeight),
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Overlay,
                ClipsDescendants = false
            }, {
                BackgroundColor3 = "Secondary",
                BackgroundTransparency = "TransparencyPrimary"
            }, Theme)
            local Footer = SimpleUI.Utility:CreateInstance("Frame", FooterProperties, Parent)
            SimpleUI.Utility:CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, SimpleUI.Constants.Corner.Large)
            }, Footer)
            local SeparatorBindings = {}
            if Options.FooterSeparator ~= false then
                local SepProps, SepBindings = SimpleUI.Utility:ApplyTheme({
                    Name = "FooterSeparator",
                    Position = UDim2.new(0, 0, 1, FooterOverlap),
                    Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    ZIndex = Footer.ZIndex + 1
                }, {
                    BackgroundColor3 = "Separator",
                    BackgroundTransparency = "SeparatorTransparency"
                }, Theme)
                local Separator = SimpleUI.Utility:CreateInstance("Frame", SepProps, Parent)
                if SepBindings then
                    SeparatorBindings = {
                        Element = Separator,
                        Bindings = SepBindings
                    }
                end
            end
            local ContentFrame = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "FooterContent",
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, Options.CanResize and -24 or 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = Footer.ZIndex + 1
            }, Footer)
            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingLeft = UDim.new(0, SimpleUI.Constants.Padding.Large),
                PaddingRight = UDim.new(0, SimpleUI.Constants.Padding.Large),
                PaddingTop = UDim.new(0, SimpleUI.Constants.Padding.Medium),
                PaddingBottom = UDim.new(0, SimpleUI.Constants.Padding.Medium)
            }, ContentFrame)
            SimpleUI.Utility:CreateInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Options.FooterAlignment or Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, SimpleUI.Constants.Spacing.Normal)
            }, ContentFrame)
            local ResizeContainer
            if Options.CanResize then
                ResizeContainer = SimpleUI.Utility:CreateInstance("Frame", {
                    Name = "FooterResizeArea",
                    AnchorPoint = Vector2.new(1, 1),
                    Position = UDim2.new(1, 1, 1, 1),
                    Size = UDim2.fromOffset(20, 20),
                    BackgroundTransparency = 1,
                    ZIndex = Footer.ZIndex + 3
                }, Footer)
            end
            return Footer, FooterBindings, ContentFrame, SeparatorBindings, ResizeContainer
        end

        function SimpleUI.WindowBuilder:PopulateFooter(Window, Options, Theme)
            if not Window.Elements.FooterContent or not Options.FooterItems then
                return
            end
            for _, Item in ipairs(Options.FooterItems) do
                if Item.Type == "Text" then
                    local TextProperties, TextBindings = SimpleUI.Utility:ApplyTheme({
                        Name = Item.Name or "FooterText",
                        LayoutOrder = Item.Order or 1,
                        Size = UDim2.new(0, 0, 1, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Text = Item.Text or "",
                        TextSize = Item.TextSize or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = Window.Elements.Footer.ZIndex + 2
                    }, {
                        Font = "FontSecondary",
                        TextColor3 = Item.ColorTier or "TextSecondary"
                    }, Theme)
                    local Label = SimpleUI.Utility:CreateInstance("TextLabel", TextProperties,
                        Window.Elements.FooterContent)
                    if Item.Id then
                        Window.Elements[Item.Id] = Label
                    end
                    if TextBindings then
                        SimpleUI.ThemeManager:RegisterElement(Window, Label, TextBindings)
                    end
                elseif Item.Type == "Button" then
                    local ButtonProperties, ButtonBindings = SimpleUI.Utility:ApplyTheme({
                        Name = Item.Name or Item.Text or "FooterButton",
                        LayoutOrder = Item.Order or 1,
                        Size = UDim2.new(0, Item.Width or 80, 1, -8),
                        Text = Item.Text or "Button",
                        TextSize = Item.TextSize or 14,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        ZIndex = Window.Elements.Footer.ZIndex + 2
                    }, {
                        Font = "FontSecondary",
                        TextColor3 = "TextPrimary",
                        BackgroundColor3 = "Tertiary"
                    }, Theme)
                    local Button = SimpleUI.Utility:CreateInstance("TextButton", ButtonProperties,
                        Window.Elements.FooterContent)
                    SimpleUI.Utility:CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, SimpleUI.Constants.Corner.Medium)
                    }, Button)
                    if not SimpleUI.Utility:IsMobile() then
                        Button.MouseEnter:Connect(function()
                            TweenService:Create(Button, TweenInfo.new(0.15), {
                                BackgroundColor3 = Theme.TertiaryHover
                            }):Play()
                        end)
                        Button.MouseLeave:Connect(function()
                            TweenService:Create(Button, TweenInfo.new(0.15), {
                                BackgroundColor3 = Theme.Tertiary
                            }):Play()
                        end)
                    end
                    if Item.Callback then
                        Button.Activated:Connect(function()
                            TweenService:Create(Button, TweenInfo.new(0.1), {
                                BackgroundColor3 = Theme.TertiaryPressed
                            }):Play()
                            task.wait(0.1)
                            TweenService:Create(Button, TweenInfo.new(0.1), {
                                BackgroundColor3 = Theme.Tertiary
                            }):Play()
                            SimpleUI.ErrorHandler:Try(Item.Callback)
                        end)
                    end
                    if Item.Id then
                        Window.Elements[Item.Id] = Button
                    end
                    if ButtonBindings then
                        SimpleUI.ThemeManager:RegisterElement(Window, Button, ButtonBindings)
                    end
                elseif Item.Type == "Spacer" then
                    SimpleUI.Utility:CreateInstance("Frame", {
                        Name = "Spacer",
                        LayoutOrder = Item.Order or 1,
                        Size = UDim2.new(0, Item.Width or 10, 1, 0),
                        BackgroundTransparency = 1
                    }, Window.Elements.FooterContent)
                end
            end
        end

        function SimpleUI.WindowBuilder:SetupResizing(MainFrame, UIScale, Options, ResizeParent, ResizeMode, Theme)
            if not Options.CanResize or not ResizeParent then
                return nil, nil
            end

            local IsCenter = ResizeMode == SimpleUI.Constants.Window.ResizeModes.Center

            local ResizeHandle = SimpleUI.Utility:CreateInstance("TextButton", {
                Name = "ResizeHandle",
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(1, 1),
                BackgroundTransparency = 0.8,
                BackgroundColor3 = Color3.fromRGB(100, 100, 110),
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                ZIndex = SimpleUI.Constants.ZIndex.Modal
            }, ResizeParent)

            SimpleUI.Utility:CreateInstance("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }, ResizeHandle)

            local IconImage = SimpleUI.Utility:CreateInstance("ImageLabel", {
                Size = UDim2.fromScale(0.7, 0.7),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://16898613613",
                ImageRectSize = Vector2.new(48, 48),
                ImageRectOffset = Vector2.new(967, 49),
                ImageColor3 = Theme.TextPrimary or Color3.fromRGB(200, 200, 210),
                ZIndex = SimpleUI.Constants.ZIndex.Modal + 1
            }, ResizeHandle)

            local StartPos
            local FrameSize
            local FramePos
            local Dragging = false
            local Changed

            ResizeHandle.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~=
                    Enum.UserInputType.Touch then
                    return
                end

                StartPos = input.Position
                FrameSize = MainFrame.Size
                FramePos = MainFrame.Position
                Dragging = true

                if IsCenter then
                    MainFrame.AnchorPoint = Vector2.new(0, 0)
                    MainFrame.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset - FrameSize.X.Offset / 2,
                        FramePos.Y.Scale, FramePos.Y.Offset - FrameSize.Y.Offset / 2)
                    FramePos = MainFrame.Position
                end

                Changed = input.Changed:Connect(function()
                    if input.UserInputState ~= Enum.UserInputState.End then
                        return
                    end

                    Dragging = false
                    if IsCenter then
                        local centerX = FramePos.X.Offset + MainFrame.Size.X.Offset / 2
                        local centerY = FramePos.Y.Offset + MainFrame.Size.Y.Offset / 2
                        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                        MainFrame.Position = UDim2.new(FramePos.X.Scale, centerX, FramePos.Y.Scale, centerY)
                    end
                    if Changed and Changed.Connected then
                        Changed:Disconnect()
                        Changed = nil
                    end
                end)
            end)

            UserInputService.InputChanged:Connect(function(input)
                if not MainFrame.Visible then
                    Dragging = false
                    if Changed and Changed.Connected then
                        Changed:Disconnect()
                        Changed = nil
                    end
                    return
                end

                if Dragging and
                    (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType ==
                        Enum.UserInputType.Touch) then
                    local Delta = input.Position - StartPos

                    local newWidth = math.clamp(FrameSize.X.Offset + Delta.X, SimpleUI.Constants.Window.MinSize.X,
                        SimpleUI.Constants.Window.MaxSize.X)
                    local newHeight = math.clamp(FrameSize.Y.Offset + Delta.Y, SimpleUI.Constants.Window.MinSize.Y,
                        SimpleUI.Constants.Window.MaxSize.Y)

                    MainFrame.Size = UDim2.new(FrameSize.X.Scale, newWidth, FrameSize.Y.Scale, newHeight)
                end
            end)

            return ResizeHandle, IconImage, {
                [ResizeHandle] = {
                    BackgroundColor3 = "TextSecondary"
                },
                [IconImage] = {
                    ImageColor3 = "TextPrimary"
                }
            }
        end

        function SimpleUI.WindowBuilder:SetupScrollUpdates(WindowInstance)
            task.defer(function()
                local function UpdateContainers()
                    task.wait()
                    WindowInstance.Elements.TabsContainer = SimpleUI.ScrollManager:Update(WindowInstance.Elements
                                                                                              .TabsContainer)
                    if WindowInstance.ActivePage then
                        WindowInstance.ActivePage = SimpleUI.ScrollManager:Update(WindowInstance.ActivePage)
                    end
                end
                UpdateContainers()
                WindowInstance.Elements.TabsContainer.ChildAdded:Connect(UpdateContainers)
                WindowInstance.Elements.TabsContainer.ChildRemoved:Connect(UpdateContainers)
                WindowInstance.Elements.ContentsContainer.ChildAdded:Connect(function(Child)
                    if Child:IsA("Frame") then
                        local Layout = Child:FindFirstChildWhichIsA("UIListLayout")
                        if Layout then
                            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                                if Child == WindowInstance.ActivePage then
                                    WindowInstance.ActivePage = SimpleUI.ScrollManager:Update(Child)
                                end
                            end)
                        end
                        local function UpdatePage()
                            if Child == WindowInstance.ActivePage then
                                task.wait()
                                WindowInstance.ActivePage = SimpleUI.ScrollManager:Update(Child)
                            end
                        end
                        Child.ChildAdded:Connect(UpdatePage)
                        Child.ChildRemoved:Connect(UpdatePage)
                    end
                end)
            end)
        end
    end

    SimpleUI.SectionManager = {}
    do
        function SimpleUI.SectionManager:CreateSimpleSection(Page, Text, Options, Theme, Window, Style)
            local LABEL_HEIGHT = 26
            local TEXT_SIZE = Options.TextSize or 19
            local LABEL_TEXT = Text or "Section"

            local StyleDefs = {
                sidebar = {
                    SectionHeight = LABEL_HEIGHT + 4,
                    Indent = 10
                },
                notch = {
                    SectionHeight = LABEL_HEIGHT + 4,
                    Indent = 16
                },
                filled = {
                    SectionHeight = LABEL_HEIGHT + 8,
                    Indent = 14
                },
                inset = {
                    SectionHeight = LABEL_HEIGHT + 6,
                    Indent = 10
                },
                stepped = {
                    SectionHeight = LABEL_HEIGHT + 10,
                    Indent = 8
                },
                panel = {
                    SectionHeight = LABEL_HEIGHT + 8,
                    Indent = 14
                }
            }

            local Def = StyleDefs[Style] or {
                SectionHeight = LABEL_HEIGHT + 4,
                Indent = 0
            }
            local SECTION_HEIGHT = Def.SectionHeight
            local INDENT = Def.Indent
            local LabelY = math.floor((SECTION_HEIGHT - LABEL_HEIGHT) / 2)

            local AccentElement, AccentBindings, ExtraElements = nil, {}, {}

            local Section = SimpleUI.Utility:CreateInstance("Frame", {
                Name = "Section",
                Size = UDim2.new(1, 0, 0, SECTION_HEIGHT),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = SimpleUI.Constants.ZIndex.Control
            }, Page)

            local LabelProperties, LabelBindings = SimpleUI.Utility:ApplyTheme({
                Size = UDim2.new(1, -INDENT, 0, LABEL_HEIGHT),
                Position = UDim2.new(0, INDENT, 0, LabelY),
                Text = LABEL_TEXT,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Overlay
            }, {
                Font = "FontPrimary",
                TextColor3 = "TextActive"
            }, Theme)
            local Label = SimpleUI.Utility:CreateInstance("TextLabel", LabelProperties, Section)

            if Style == "sidebar" then
                local Thickness = Options.BarThickness or 3
                local BarProps, BarBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(0, Thickness, 0, LABEL_HEIGHT),
                    Position = UDim2.new(0, 0, 0, LabelY),
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Bar = SimpleUI.Utility:CreateInstance("Frame", BarProps, Section)
                SimpleUI.Utility:CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }, Bar)
                AccentElement, AccentBindings = Bar, BarBindings

            elseif Style == "notch" then
                local NOTCH_SIZE = 6
                local NotchProps, NotchBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(0, NOTCH_SIZE, 0, NOTCH_SIZE),
                    Position = UDim2.new(0, 2, 0, LabelY + math.floor((LABEL_HEIGHT - NOTCH_SIZE) / 2)),
                    Rotation = 45,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Notch = SimpleUI.Utility:CreateInstance("Frame", NotchProps, Section)
                AccentElement, AccentBindings = Notch, NotchBindings

            elseif Style == "filled" then
                local STRIPE_WIDTH = Options.StripeWidth or 4

                local BgProps, BgBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0.88,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 2
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Bg = SimpleUI.Utility:CreateInstance("Frame", BgProps, Section)
                SimpleUI.Utility:CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }, Bg)
                SimpleUI.Utility:CreateInstance("UIGradient", {
                    Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0),
                                                       NumberSequenceKeypoint.new(0.6, 0),
                                                       NumberSequenceKeypoint.new(1, 1)}),
                    Rotation = 0
                }, Bg)

                local StripeProps, StripeBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(0, STRIPE_WIDTH, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 1
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Stripe = SimpleUI.Utility:CreateInstance("Frame", StripeProps, Section)
                SimpleUI.Utility:CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 2)
                }, Stripe)

                AccentElement, AccentBindings = Stripe, StripeBindings
                table.insert(ExtraElements, {
                    Element = Bg,
                    Bindings = BgBindings
                })

            elseif Style == "inset" then
                local FillProps, FillBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0.92,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 2
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Fill = SimpleUI.Utility:CreateInstance("Frame", FillProps, Section)

                local TopProps, TopBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 1
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local TopLine = SimpleUI.Utility:CreateInstance("Frame", TopProps, Section)

                local BotProps, BotBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 1
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local BotLine = SimpleUI.Utility:CreateInstance("Frame", BotProps, Section)

                AccentElement, AccentBindings = TopLine, TopBindings
                table.insert(ExtraElements, {
                    Element = BotLine,
                    Bindings = BotBindings
                })
                table.insert(ExtraElements, {
                    Element = Fill,
                    Bindings = FillBindings
                })

            elseif Style == "stepped" then
                local LINE_Y = SECTION_HEIGHT - 3
                local CAP_HEIGHT = 3
                local CAP_WIDTH = Options.CapWidth or 36

                local CapProps, CapBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(0, CAP_WIDTH, 0, CAP_HEIGHT),
                    Position = UDim2.new(0, 0, 0, LINE_Y - CAP_HEIGHT + 1),
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Cap = SimpleUI.Utility:CreateInstance("Frame", CapProps, Section)
                SimpleUI.Utility:CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 2)
                }, Cap)

                local HairProps, HairBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, -CAP_WIDTH, 0, 1),
                    Position = UDim2.new(0, CAP_WIDTH, 0, LINE_Y),
                    BackgroundTransparency = 0.55,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 1
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Hair = SimpleUI.Utility:CreateInstance("Frame", HairProps, Section)

                AccentElement, AccentBindings = Cap, CapBindings
                table.insert(ExtraElements, {
                    Element = Hair,
                    Bindings = HairBindings
                })

            elseif Style == "panel" then
                local STRIPE_WIDTH = Options.StripeWidth or 3

                local BgProps, BgBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0.78,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 2
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Bg = SimpleUI.Utility:CreateInstance("Frame", BgProps, Section)
                SimpleUI.Utility:CreateInstance("UIGradient", {
                    Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0),
                                                       NumberSequenceKeypoint.new(0.45, 0),
                                                       NumberSequenceKeypoint.new(1, 1)}),
                    Rotation = 0
                }, Bg)

                local StripeProps, StripeBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(0, STRIPE_WIDTH, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 1
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Stripe = SimpleUI.Utility:CreateInstance("Frame", StripeProps, Section)

                local BottomProps, BottomBindings = SimpleUI.Utility:ApplyTheme({
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    BackgroundTransparency = 0.65,
                    BorderSizePixel = 0,
                    ZIndex = SimpleUI.Constants.ZIndex.Overlay - 1
                }, {
                    BackgroundColor3 = "Accent"
                }, Theme)
                local Bottom = SimpleUI.Utility:CreateInstance("Frame", BottomProps, Section)

                AccentElement, AccentBindings = Stripe, StripeBindings
                table.insert(ExtraElements, {
                    Element = Bg,
                    Bindings = BgBindings
                })
                table.insert(ExtraElements, {
                    Element = Bottom,
                    Bindings = BottomBindings
                })
            end

            if Window then
                local Batch = {
                    [Label] = LabelBindings
                }
                if AccentElement then
                    Batch[AccentElement] = AccentBindings
                end
                for _, Entry in ipairs(ExtraElements) do
                    Batch[Entry.Element] = Entry.Bindings
                end
                SimpleUI.ThemeManager:RegisterMultiple(Window, Batch)
            end

            return {
                SetText = function(self, NewText)
                    Label.Text = NewText
                end,

                SetTextSize = function(self, Size)
                    Label.TextSize = Size
                end,

                SetVisible = function(self, Visible)
                    Section.Visible = Visible
                end,

                GetElements = function(self)
                    return {
                        Section = Section,
                        Label = Label,
                        Accent = AccentElement
                    }
                end
            }
        end

        function SimpleUI.SectionManager:CreateBoxSection(Page, Text, Options, Theme, Window)
            if not Page or not Page.Parent then
                SimpleUI.ErrorHandler:Guard(false, "CreateBoxSection", "Page is nil or unparented",
                    SimpleUI.ErrorHandler.Levels.ERROR)
                return nil
            end
            Options = type(Options) == "table" and Options or {}
            Theme = type(Theme) == "table" and Theme or SimpleUI.Themes.DefaultTheme
            Text = type(Text) == "string" and Text or "Section"

            local U = SimpleUI.Utility
            local TM = SimpleUI.ThemeManager
            local CORNER = SimpleUI.Constants.Corner.Medium
            local PAD = SimpleUI.Constants.Padding
            local ZI = SimpleUI.Constants.ZIndex
            local HEADER_H = 36
            local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local IsExpanded = Options.DefaultExpanded ~= false

            local function GetWindowScale()
                if Window and Window.Scale and typeof(Window.Scale) == "Instance" then
                    local ok, scale = pcall(function()
                        return Window.Scale.Scale
                    end)
                    if ok and type(scale) == "number" and scale > 0 then
                        return scale
                    end
                end
                return 1
            end

            local function Tween(Object, Properties)
                if not Object or not Object.Parent then
                    return
                end
                local ok, err = pcall(function()
                    TweenService:Create(Object, TWEEN_INFO, Properties):Play()
                end)
                if not ok then
                    SimpleUI.ErrorHandler:Guard(false, "CreateBoxSection:Tween", tostring(err),
                        SimpleUI.ErrorHandler.Levels.WARN)
                end
            end

            local Section = U:CreateInstance("Frame", {
                Name = "BoxSection",
                Size = UDim2.new(1, 0, 0, HEADER_H),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = ZI.Control
            }, Page)

            local Border = U:CreateInstance("Frame", {
                Name = "Border",
                Size = UDim2.new(1, 0, 0, HEADER_H),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.BoxBackground or Theme.Secondary,
                BackgroundTransparency = Theme.TransparencySecondary,
                BorderSizePixel = 0,
                ZIndex = ZI.Control
            }, Section)
            U:CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, CORNER)
            }, Border)

            local Stroke = U:CreateInstance("UIStroke", {
                Color = Theme.Separator,
                Thickness = 1,
                Transparency = Theme.SeparatorTransparency,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }, Border)

            local HeaderContainer = U:CreateInstance("Frame", {
                Name = "HeaderContainer",
                Size = UDim2.new(1, 0, 0, HEADER_H),
                BackgroundTransparency = 1,
                ZIndex = ZI.Control + 1
            }, Border)
            U:CreateInstance("UIPadding", {
                PaddingLeft = UDim.new(0, PAD.Medium),
                PaddingRight = UDim.new(0, PAD.Medium)
            }, HeaderContainer)

            local HeaderContent = U:CreateInstance("Frame", {
                Name = "HeaderContent",
                Size = UDim2.new(1, -(20 + PAD.Medium), 1, 0),
                BackgroundTransparency = 1,
                ZIndex = ZI.Control + 1
            }, HeaderContainer)
            U:CreateInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, PAD.Medium)
            }, HeaderContent)

            local IconContainer = nil
            if Options.Icon then
                IconContainer = U:CreateInstance("Frame", {
                    Name = "IconContainer",
                    Size = UDim2.new(0, 20, 0, 20),
                    BackgroundTransparency = 1,
                    ZIndex = ZI.Control + 1,
                    LayoutOrder = 1
                }, HeaderContent)

                local rawIcon = Options.Icon
                local iconData = SimpleUI.IconManager:WrapIcon(
                    type(rawIcon) == "table" and rawIcon or {
                        Image = rawIcon
                    })

                if iconData then
                    U:CreateInstance("ImageLabel", {
                        Name = "Icon",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Image = iconData.Url,
                        ImageColor3 = (type(rawIcon) == "table" and rawIcon.ImageColor3) or Theme.TextPrimary,
                        ImageRectOffset = iconData.ImageRectOffset,
                        ImageRectSize = iconData.ImageRectSize,
                        ZIndex = ZI.Control + 1
                    }, IconContainer)
                end
            end

            local Title = U:CreateInstance("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Text,
                TextColor3 = Theme.TextActive,
                Font = Theme.FontPrimary,
                TextSize = type(Options.TextSize) == "number" and Options.TextSize or 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = ZI.Control + 1,
                LayoutOrder = 2
            }, HeaderContent)

            local Arrow = U:CreateInstance("ImageLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10709790948",
                ImageColor3 = Theme.TextPrimary,
                Rotation = IsExpanded and 0 or -90,
                ZIndex = ZI.Control + 1
            }, HeaderContainer)

            local Content = U:CreateInstance("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, HEADER_H),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                ZIndex = ZI.Control + 1
            }, Border)

            Content:SetAttribute("IsDualScroll", false)

            local ContentPadding = U:CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, PAD.Medium),
                PaddingBottom = UDim.new(0, PAD.Large),
                PaddingLeft = UDim.new(0, PAD.Medium),
                PaddingRight = UDim.new(0, PAD.Medium)
            }, Content)

            local ListLayout = U:CreateInstance("UIListLayout", {
                Padding = UDim.new(0, SimpleUI.Constants.Spacing.Loose),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, Content)

            local ClickButton = U:CreateInstance("TextButton", {
                Name = "ClickButton",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = ZI.Modal
            }, HeaderContainer)

            local function CalculateContentHeight()
                local scale = GetWindowScale()
                local logicalContent = ListLayout.AbsoluteContentSize.Y / scale
                return logicalContent + ContentPadding.PaddingTop.Offset + ContentPadding.PaddingBottom.Offset
            end

            local function SetExpandedSize()
                if not IsExpanded then
                    return
                end
                local contentH = CalculateContentHeight()
                local totalH = HEADER_H + contentH
                Tween(Content, {
                    Size = UDim2.new(1, 0, 0, contentH)
                })
                Tween(Border, {
                    Size = UDim2.new(1, 0, 0, totalH)
                })
                Tween(Section, {
                    Size = UDim2.new(1, 0, 0, totalH)
                })
            end

            local function SetCollapsedSize()
                Tween(Content, {
                    Size = UDim2.new(1, 0, 0, 0)
                })
                Tween(Border, {
                    Size = UDim2.new(1, 0, 0, HEADER_H)
                })
                Tween(Section, {
                    Size = UDim2.new(1, 0, 0, HEADER_H)
                })
            end

            local ToggleDebounce = false

            local function Toggle()
                if ToggleDebounce then
                    return
                end
                ToggleDebounce = true
                task.delay(0.1, function()
                    ToggleDebounce = false
                end)

                IsExpanded = not IsExpanded
                Tween(Arrow, {
                    Rotation = IsExpanded and 0 or -90
                })
                if IsExpanded then
                    SetExpandedSize()
                else
                    SetCollapsedSize()
                end
            end

            ClickButton.Activated:Connect(Toggle)

            local resizePending = false
            local function RequestResize()
                if not IsExpanded or resizePending then
                    return
                end
                resizePending = true
                task.defer(function()
                    resizePending = false
                    if Section.Parent then
                        SetExpandedSize()
                    end
                end)
            end

            Content.ChildAdded:Connect(RequestResize)
            Content.ChildRemoved:Connect(RequestResize)
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RequestResize)

            if Window and Window.Scale and typeof(Window.Scale) == "Instance" then
                Window.Scale:GetPropertyChangedSignal("Scale"):Connect(function()
                    if IsExpanded and Section.Parent then
                        local contentH = CalculateContentHeight()
                        local totalH = HEADER_H + contentH
                        Content.Size = UDim2.new(1, 0, 0, contentH)
                        Border.Size = UDim2.new(1, 0, 0, totalH)
                        Section.Size = UDim2.new(1, 0, 0, totalH)
                    end
                end)
            end

            if IsExpanded then
                task.defer(SetExpandedSize)
            end

            if Window then
                local themeTargets = {
                    [Border] = {
                        BackgroundColor3 = "BoxBackground",
                        BackgroundTransparency = "TransparencySecondary"
                    },
                    [Stroke] = {
                        Color = "Separator",
                        Transparency = "SeparatorTransparency"
                    },
                    [Title] = {
                        TextColor3 = "TextActive",
                        Font = "FontPrimary"
                    },
                    [Arrow] = {
                        ImageColor3 = "TextPrimary"
                    }
                }

                if IconContainer then
                    local iconEl = IconContainer:FindFirstChild("Icon")
                    if iconEl then
                        local hasExplicitColor = type(Options.Icon) == "table" and Options.Icon.ImageColor3 ~= nil
                        if not hasExplicitColor then
                            themeTargets[iconEl] = {
                                ImageColor3 = "TextPrimary"
                            }
                        end
                    end
                end

                TM:RegisterMultiple(Window, themeTargets)
            end

            return {
                Container = Content,
                Section = Section,
                Header = HeaderContainer,
                Title = Title,
                Arrow = Arrow,
                IconContainer = IconContainer,

                SetExpanded = function(_, value)
                    if type(value) ~= "boolean" then
                        return
                    end
                    if value ~= IsExpanded then
                        Toggle()
                    end
                end,

                IsExpanded = function()
                    return IsExpanded
                end,

                Refresh = function()
                    if IsExpanded then
                        SetExpandedSize()
                    end
                end,

                SetTitle = function(_, newText)
                    if type(newText) == "string" then
                        Title.Text = newText
                    end
                end
            }
        end
    end

    SimpleUI.IconManager = {}
    do
        function SimpleUI.IconManager:WrapIcon(IconInput)
            if not IconInput then
                return nil
            end

            if type(IconInput) == "table" and IconInput.Image then
                return {
                    Url = IconInput.Image,
                    ImageRectOffset = IconInput.ImageRectOffset or Vector2.zero,
                    ImageRectSize = IconInput.ImageRectSize or Vector2.zero
                }
            end

            return {
                Url = tostring(IconInput),
                ImageRectOffset = Vector2.zero,
                ImageRectSize = Vector2.zero
            }
        end
    end

    SimpleUI.NotificationManager = {}
    do
        local ActiveNotifications = {}

        function SimpleUI.NotificationManager:Initialize()
            if self.Initialized then
                return
            end
            self.Initialized = true
            self.Container = nil
            self.ScreenGui = nil
        end

        function SimpleUI.NotificationManager:GetScreenGui()
            if self.ScreenGui and self.ScreenGui.Parent then
                return self.ScreenGui
            end

            local ScreenGui = SimpleUI.Utility:CreateInstance("ScreenGui", {
                Name = SimpleUI.Utility:GenerateId(),
                ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                DisplayOrder = SimpleUI.Constants.ZIndex.Notification
            })

            SimpleUI.Utility:ParentUI(ScreenGui)
            self.ScreenGui = ScreenGui
            return ScreenGui
        end

        function SimpleUI.NotificationManager:GetContainer()
            if self.Container and self.Container.Parent then
                return self.Container
            end

            local ScreenGui = self:GetScreenGui()
            local Scale = SimpleUI.Utility:IsMobile() and 0.5 or 1

            local Parent = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Notification
            }, ScreenGui)

            SimpleUI.Utility:CreateInstance("UIScale", {
                Scale = Scale
            }, Parent)

            self.Container = Parent

            local Holder = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Position = UDim2.new(1, -20, 0, 20),
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.new(0, 360, 1, -40),
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Notification
            }, Parent)

            SimpleUI.Utility:CreateInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            }, Holder)

            pcall(protectgui, Parent)

            return Parent
        end

        function SimpleUI.NotificationManager:GetHolder()
            local Container = self:GetContainer()
            for _, Child in ipairs(Container:GetChildren()) do
                if Child:IsA("Frame") then
                    local Layout = Child:FindFirstChildOfClass("UIListLayout")
                    if Layout then
                        return Child
                    end
                end
            end
            return Container
        end

        function SimpleUI.NotificationManager:CreateNotificationUI(Config)
            local Theme = SimpleUI.Themes.Obsidian
            local Holder = self:GetHolder()
            local IsMobile = SimpleUI.Utility:IsMobile()
            local HasDuration = Config.Duration and Config.Duration > 0

            local TypeColors = {
                Default = Theme.Accent,
                Info = Color3.fromRGB(30, 144, 255),
                Success = Color3.fromRGB(40, 187, 109),
                Warning = Color3.fromRGB(255, 193, 7),
                Error = Color3.fromRGB(220, 60, 69)
            }
            local TypeTags = {
                Default = "NOTICE",
                Info = "INFO",
                Success = "SUCCESS",
                Warning = "WARNING",
                Error = "ERROR"
            }

            local Accent = TypeColors[Config.Type] or Config.Color or Theme.Accent
            local LightAccent = Accent:Lerp(Color3.new(1, 1, 1), 0.4)
            local TagText = Config.Tag or TypeTags[Config.Type] or "NOTICE"
            local BasePad = IsMobile and 8 or 10
            local SidePad = IsMobile and 10 or 12

            local Notification = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = SimpleUI.Constants.ZIndex.Notification,
                LayoutOrder = tick()
            }, Holder)

            local AccentBar = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = SimpleUI.Constants.ZIndex.Notification + 1
            }, Notification)

            local Shadow = SimpleUI.Utility:CreateInstance("ImageLabel", {
                Name = SimpleUI.Utility:GenerateId(),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 20, 1, 20),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7717391613",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = 1,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                ZIndex = SimpleUI.Constants.ZIndex.Notification - 1
            }, Notification)

            local Content = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Position = UDim2.new(0, 3, 0, 0),
                Size = UDim2.new(1, -3, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Notification + 2
            }, Notification)

            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingTop = UDim.new(0, BasePad),
                PaddingBottom = UDim.new(0, BasePad),
                PaddingLeft = UDim.new(0, SidePad),
                PaddingRight = UDim.new(0, IsMobile and 26 or 30)
            }, Content)

            local TextContainer = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Notification + 2
            }, Content)

            SimpleUI.Utility:CreateInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, IsMobile and 2 or 3)
            }, TextContainer)

            local TitleRow = SimpleUI.Utility:CreateInstance("Frame", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.new(1, Config.Closable ~= false and -(IsMobile and 22 or 26) or 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Notification + 2
            }, TextContainer)

            SimpleUI.Utility:CreateInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            }, TitleRow)

            local TitleLabel = SimpleUI.Utility:CreateInstance("TextLabel", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.new(0, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                Text = Config.Title or "Notification",
                TextColor3 = Theme.TextActive,
                TextTransparency = 1,
                TextSize = IsMobile and 12 or 13,
                Font = Theme.FontPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = false,
                RichText = true,
                LineHeight = 1.1,
                LayoutOrder = 1,
                ZIndex = SimpleUI.Constants.ZIndex.Notification + 3
            }, TitleRow)

            local Tag = SimpleUI.Utility:CreateInstance("TextLabel", {
                Name = SimpleUI.Utility:GenerateId(),
                Size = UDim2.new(0, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = Accent,
                BackgroundTransparency = 1,
                Text = TagText,
                TextColor3 = LightAccent,
                TextTransparency = 1,
                TextSize = IsMobile and 8 or 9,
                Font = Theme.FontPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 2,
                ZIndex = SimpleUI.Constants.ZIndex.Notification + 3
            }, TitleRow)

            SimpleUI.Utility:CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 3)
            }, Tag)
            SimpleUI.Utility:CreateInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2)
            }, Tag)

            local DescriptionLabel = nil
            if Config.Description then
                DescriptionLabel = SimpleUI.Utility:CreateInstance("TextLabel", {
                    Name = SimpleUI.Utility:GenerateId(),
                    Size = UDim2.new(1, Config.Closable ~= false and -(IsMobile and 22 or 26) or 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = Config.Description,
                    TextColor3 = Theme.TextSecondary,
                    TextTransparency = 1,
                    TextSize = IsMobile and 11 or 12,
                    Font = Theme.FontSecondary,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    RichText = true,
                    LineHeight = 1.2,
                    LayoutOrder = 2,
                    ZIndex = SimpleUI.Constants.ZIndex.Notification + 3
                }, TextContainer)
            end

            if Config.Closable ~= false then
                local CloseBtn = SimpleUI.Utility:CreateInstance("TextButton", {
                    Name = SimpleUI.Utility:GenerateId(),
                    Position = UDim2.new(1, 0, 0, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    Size = UDim2.new(0, IsMobile and 16 or 18, 0, IsMobile and 16 or 18),
                    BackgroundTransparency = 1,
                    Text = "×",
                    Font = Theme.FontPrimary,
                    TextSize = IsMobile and 18 or 20,
                    TextColor3 = Theme.TextInactive,
                    TextTransparency = 1,
                    AutoButtonColor = false,
                    ZIndex = SimpleUI.Constants.ZIndex.Notification + 5
                }, Content)

                CloseBtn.MouseEnter:Connect(function()
                    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
                        TextColor3 = Color3.fromRGB(255, 85, 85),
                        Rotation = 90
                    }):Play()
                end)
                CloseBtn.MouseLeave:Connect(function()
                    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
                        TextColor3 = Theme.TextInactive,
                        Rotation = 0
                    }):Play()
                end)
                CloseBtn.Activated:Connect(function()
                    SimpleUI.NotificationManager:Dismiss(Notification)
                end)
            end

            if Config.Callback then
                local ClickArea = SimpleUI.Utility:CreateInstance("TextButton", {
                    Name = SimpleUI.Utility:GenerateId(),
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = SimpleUI.Constants.ZIndex.Notification
                }, Notification)

                ClickArea.Activated:Connect(function()
                    SimpleUI.ErrorHandler:Try(function()
                        Config.Callback(Notification)
                    end)
                end)
                ClickArea.MouseEnter:Connect(function()
                    TweenService:Create(Notification, TweenInfo.new(0.15), {
                        BackgroundColor3 = Theme.SecondaryHover
                    }):Play()
                end)
                ClickArea.MouseLeave:Connect(function()
                    TweenService:Create(Notification, TweenInfo.new(0.15), {
                        BackgroundColor3 = Theme.Secondary
                    }):Play()
                end)
            end

            task.defer(function()
                task.wait()

                local TextH = 0
                for _, Child in ipairs(TextContainer:GetChildren()) do
                    if Child:IsA("TextLabel") or Child:IsA("Frame") then
                        TextH = TextH + Child.AbsoluteSize.Y
                    end
                end
                local Layout = TextContainer:FindFirstChildOfClass("UIListLayout")
                local ChildCount = 0
                for _, Child in ipairs(TextContainer:GetChildren()) do
                    if Child:IsA("TextLabel") or Child:IsA("Frame") then
                        ChildCount = ChildCount + 1
                    end
                end
                if Layout and ChildCount > 1 then
                    TextH = TextH + Layout.Padding.Offset * (ChildCount - 1)
                end

                local MinH = IsMobile and 38 or 42
                local CardH = math.max(TextH + BasePad * 2, MinH)
                local BarH = HasDuration and 2 or 0

                Notification.Size = UDim2.new(1, 0, 0, CardH + BarH)
                Notification.Position = UDim2.new(0, 0, 0, 0)
                Notification.BackgroundTransparency = 1
                Shadow.ImageTransparency = 1

                for _, Child in ipairs(Notification:GetDescendants()) do
                    if Child:IsA("TextLabel") or Child:IsA("TextButton") then
                        Child.TextTransparency = 1
                    elseif Child:IsA("ImageLabel") and Child.Name ~= Shadow.Name then
                        Child.ImageTransparency = 1
                    elseif Child:IsA("Frame") and Child ~= Notification then
                        Child.BackgroundTransparency = 1
                    end
                end

                local SlideInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local Tweens = {}

                table.insert(Tweens, TweenService:Create(Notification, SlideInfo, {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0
                }))
                table.insert(Tweens, TweenService:Create(Shadow, SlideInfo, {
                    ImageTransparency = 0.75
                }))
                table.insert(Tweens, TweenService:Create(AccentBar, SlideInfo, {
                    BackgroundTransparency = 0
                }))
                table.insert(Tweens, TweenService:Create(Tag, SlideInfo, {
                    TextTransparency = 0,
                    BackgroundTransparency = 0.78
                }))

                for _, Child in ipairs(Notification:GetDescendants()) do
                    if Child:IsA("TextLabel") and Child.Name ~= Tag.Name then
                        table.insert(Tweens, TweenService:Create(Child, SlideInfo, {
                            TextTransparency = 0
                        }))
                    elseif Child:IsA("TextButton") then
                        table.insert(Tweens, TweenService:Create(Child, SlideInfo, {
                            TextTransparency = 0
                        }))
                    end
                end

                for _, Tween in ipairs(Tweens) do
                    Tween:Play()
                end

                if HasDuration then
                    local ProgressBar = SimpleUI.Utility:CreateInstance("Frame", {
                        Name = SimpleUI.Utility:GenerateId(),
                        Position = UDim2.new(0, 0, 1, -BarH),
                        Size = UDim2.new(1, 0, 0, BarH),
                        BackgroundColor3 = Accent,
                        BorderSizePixel = 0,
                        ZIndex = SimpleUI.Constants.ZIndex.Notification + 4
                    }, Notification)

                    TweenService:Create(ProgressBar, TweenInfo.new(Config.Duration, Enum.EasingStyle.Linear), {
                        Size = UDim2.new(0, 0, 0, BarH)
                    }):Play()

                    task.delay(Config.Duration, function()
                        if Notification and Notification.Parent then
                            SimpleUI.NotificationManager:Dismiss(Notification)
                        end
                    end)
                end
            end)

            return {
                Container = Notification,
                Title = TitleLabel,
                Description = DescriptionLabel,
                Tag = Tag,
                Content = Content,
                AccentBar = AccentBar
            }
        end

        function SimpleUI.NotificationManager:Dismiss(Notification)
            if not Notification or not Notification.Parent then
                return false
            end

            local FadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local Shadow = Notification:FindFirstChild("Shadow")
            local Tweens = {}

            table.insert(Tweens, TweenService:Create(Notification, FadeInfo, {
                BackgroundTransparency = 1
            }))
            if Shadow then
                table.insert(Tweens, TweenService:Create(Shadow, FadeInfo, {
                    ImageTransparency = 1
                }))
            end

            for _, o in ipairs(Notification:GetDescendants()) do
                if o:IsA("TextLabel") or o:IsA("TextButton") then
                    table.insert(Tweens, TweenService:Create(o, FadeInfo, {
                        TextTransparency = 1,
                        BackgroundTransparency = 1
                    }))
                elseif o:IsA("ImageLabel") and o ~= Shadow then
                    table.insert(Tweens, TweenService:Create(o, FadeInfo, {
                        ImageTransparency = 1
                    }))
                elseif o:IsA("Frame") and o ~= Notification then
                    table.insert(Tweens, TweenService:Create(o, FadeInfo, {
                        BackgroundTransparency = 1
                    }))
                end
            end

            for _, Tween in ipairs(Tweens) do
                Tween:Play()
            end

            task.delay(0.35, function()
                if not Notification or not Notification.Parent then
                    return
                end
                TweenService:Create(Notification, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                task.wait(0.15)
                if Notification and Notification.Parent then
                    Notification:Destroy()
                end
            end)

            return true
        end

        function SimpleUI.NotificationManager:DismissAll()
            local Holder = self:GetHolder()
            local ToRemove = {}
            for _, Child in ipairs(Holder:GetChildren()) do
                if Child:IsA("Frame") then
                    table.insert(ToRemove, Child)
                end
            end
            for _, Child in ipairs(ToRemove) do
                self:Dismiss(Child)
            end
        end
    end

    SimpleUI.MarkdownParser = {}
    do
        function SimpleUI.MarkdownParser:ConvertToRichText(Markdown)
            local Text = Markdown
            Text = Text:gsub("### (.-)\n", '<font size="18"><b>%1</b></font>\n')
            Text = Text:gsub("## (.-)\n", '<font size="20"><b>%1</b></font>\n')
            Text = Text:gsub("# (.-)\n", '<font size="22"><b>%1</b></font>\n')
            Text = Text:gsub("%*%*%*(.-)%*%*%*", "<b><i>%1</i></b>")
            Text = Text:gsub("%*%*(.-)%*%*", "<b>%1</b>")
            Text = Text:gsub("%*(.-)%*", "<i>%1</i>")
            Text = Text:gsub("__(.-)__", "<b>%1</b>")
            Text = Text:gsub("_(.-)_", "<i>%1</i>")
            Text = Text:gsub("~~(.-)~~", "<s>%1</s>")
            Text = Text:gsub("`([^`]+)`",
                '<font face="RobotoMono"><stroke color="rgb(50,50,60)" joins="miter" thickness="3" transparency="0">%1</stroke></font>')
            Text = Text:gsub("```(.-)```", function(Code)
                return
                    '<font face="RobotoMono" size="13"><stroke color="rgb(50,50,60)" joins="miter" thickness="3" transparency="0">' ..
                        Code .. '</stroke></font>'
            end)
            Text = Text:gsub("%[(.-)%]%((.-)%)", '<font color="rgb(100,150,255)"><u>%1</u></font>')
            Text = Text:gsub("^%- (.-)\n", "• %1\n")
            Text = Text:gsub("\n%- (.-)\n", "\n• %1\n")
            Text = Text:gsub("\n%- (.-)", "\n• %1")
            Text = Text:gsub("^%* (.-)\n", "• %1\n")
            Text = Text:gsub("\n%* (.-)\n", "\n• %1\n")
            Text = Text:gsub("\n%* (.-)", "\n• %1")
            Text = Text:gsub("^%d+%. (.-)\n", "%1\n")
            Text = Text:gsub("\n%d+%. (.-)\n", "\n%1\n")
            Text = Text:gsub("%-%-%-+", "────────────────────────")
            Text = Text:gsub("%*%*%*+", "────────────────────────")
            return Text
        end
    end
end

function SimpleUI:CreateWindow(options)
    options = options or {}

    local theme = type(options.Theme) == "string" and (self.Themes[options.Theme] or self.Themes.DefaultTheme) or
                      type(options.Theme) == "table" and options.Theme or self.Themes.DefaultTheme

    local scale = math.clamp(options.DefaultScale or self.Constants.Window.DefaultScale, self.Constants.Window.MinScale,
        self.Constants.Window.MaxScale)

    local screenGui = self.Utility:CreateInstance("ScreenGui", {
        Name = options.Name or self.Utility:GenerateId(),
        ResetOnSpawn = false,
        DisplayOrder = options.DisplayOrder or 1,
        IgnoreGuiInset = options.IgnoreGuiInset or false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    self.Utility:ParentUI(screenGui)

    local mainFrame, uiScale, mainFrameBindings = self.WindowBuilder:CreateMainFrame(screenGui, options, theme)
    local topBarHeight = options.TopBarHeight or self.Constants.Window.TopBarHeight
    local footerHeight = options.Footer and (options.FooterHeight or 10) or 0

    local topBar, topBarSeparator, topBarSeparatorBindings = self.WindowBuilder:CreateTopBar(mainFrame, options, theme)

    local tabInfoContainer, controlsContainer, tabNameLabel, tabDescLabel, brandIconElement, brandInitialElement,
        brandTitleLabel = self.WindowBuilder:CreateTitleSection(topBar, options, theme)

    local controlButtons = self.WindowBuilder:CreateWindowControls(controlsContainer, options, theme)

    local footer, footerBindings, footerContent, separatorBindings, resizeContainer =
        self.WindowBuilder:CreateFooter(mainFrame, options, theme)
    local ResizeMode = options.ResizeMode or self.Constants.Window.ResizeModes.BottomRight

    local mainContainer = self.WindowBuilder:CreateMainContainer(mainFrame, options, theme, topBarHeight, footerHeight)

    local tabsContainer, contentsContainer, tabsSeparator, tabsSeparatorBindings =
        self.WindowBuilder:CreateContentAreas(mainContainer, mainFrame, topBar, options)

    local window = {
        _connections = SimpleUI.ConnectionRegistry:New(),
        Theme = theme,
        TabMode = options.TabMode or self.Constants.Window.TabModes.Fixed,
        TabsExpanded = true,
        ActiveTab = nil,
        ActivePage = nil,
        TabCallbacks = {},
        Scale = uiScale,
        Elements = {
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            TopBar = topBar,
            TabInfoContainer = tabInfoContainer,
            TitleLabel = tabNameLabel,
            SubtitleLabel = tabDescLabel,
            BrandIcon = brandIconElement,
            BrandInitial = brandInitialElement,
            BrandTitle = brandTitleLabel,
            ControlsContainer = controlsContainer,
            ControlButtons = controlButtons,
            Footer = footer,
            FooterContent = footerContent,
            FooterResizeArea = resizeContainer,
            MainContainer = mainContainer,
            TabsContainer = tabsContainer,
            TabsSeparator = tabsSeparator,
            ContentsContainer = contentsContainer,
            Tabs = {},
            Pages = {}
        },

        GetScale = function()
            return uiScale.Scale
        end,

        SetScale = function(self, value, animate)
            value = math.clamp(tonumber(value) or 1, SimpleUI.Constants.Window.MinScale,
                SimpleUI.Constants.Window.MaxScale)

            if animate then
                TweenService:Create(uiScale, TweenInfo.new(SimpleUI.Constants.Animation.Normal, Enum.EasingStyle.Sine,
                    Enum.EasingDirection.Out), {
                    Scale = value
                }):Play()
            else
                uiScale.Scale = value
            end
        end,

        SetTheme = function(self, themeName, animate)
            if type(themeName) ~= "string" then
                return
            end
            SimpleUI.ThemeManager:SetTheme(self, themeName, animate ~= false)
        end,

        GetTheme = function(self)
            return SimpleUI.ThemeManager:GetThemeName(self)
        end,

        SetTabMode = function(self, mode, animate, threshold)
            threshold = threshold or SimpleUI.Constants.Window.TabDynamicThreshold
            local modes = SimpleUI.Constants.Window.TabModes

            if not modes[mode] then
                SimpleUI.ErrorHandler:Guard(false, "SetTabMode",
                    string.format("Invalid tab mode '%s', using Dynamic", tostring(mode)),
                    SimpleUI.ErrorHandler.Levels.WARN)
                mode = modes.Dynamic
            end

            self.TabMode = mode
            local duration = SimpleUI.Constants.Animation.Smooth
            local const = SimpleUI.Constants.Window

            local function updateTopBarLayout(expanded, tweenDuration)
                if not tabsSeparator then
                    return
                end

                local hasBrand = options.Brand ~= nil
                local xScale, xOffset

                if expanded then
                    xScale = const.TabsWidthOpen
                    xOffset = const.TabSeparatorGap
                    if tabNameLabel then
                        TweenService:Create(tabNameLabel, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                            TextTransparency = 1
                        }):Play()
                    end
                    if tabDescLabel then
                        TweenService:Create(tabDescLabel, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                            TextTransparency = 1
                        }):Play()
                    end
                    TweenService:Create(tabsSeparator,
                        TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(0, 1, 1, -topBarHeight),
                            Position = UDim2.new(xScale, xOffset, 0, topBarHeight)
                        }):Play()

                    if brandTitleLabel then
                        TweenService:Create(brandTitleLabel, TweenInfo.new(tweenDuration * 0.8, Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                    end

                    if tabInfoContainer then
                        TweenService:Create(tabInfoContainer, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out), {
                            Position = UDim2.new(xScale, xOffset + 1, 0.5, 0)
                        }):Play()
                    end
                else
                    xOffset = const.TabsWidthClosed + const.ClosedTabHorizontalPadding + const.TabSeparatorGap

                    if tabNameLabel then
                        TweenService:Create(tabNameLabel, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                            TextTransparency = 0
                        }):Play()
                    end
                    if tabDescLabel then
                        TweenService:Create(tabDescLabel, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                            TextTransparency = 0
                        }):Play()
                    end

                    TweenService:Create(tabsSeparator,
                        TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(0, 1, 1, hasBrand and 0 or -topBarHeight),
                            Position = UDim2.new(0, xOffset, 0, hasBrand and 0 or topBarHeight)
                        }):Play()

                    if brandTitleLabel then
                        TweenService:Create(brandTitleLabel, TweenInfo.new(tweenDuration * 0.5, Enum.EasingStyle.Quad,
                            Enum.EasingDirection.In), {
                            TextTransparency = 1
                        }):Play()
                    end

                    if tabInfoContainer then
                        TweenService:Create(tabInfoContainer, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, xOffset + 1, 0.5, 0)
                        }):Play()
                    end
                end
            end

            local function setExpanded(expanded, tweenDuration)
                self.TabsExpanded = expanded
                tweenDuration = tweenDuration and duration or 0

                updateTopBarLayout(expanded, tweenDuration)

                local hPad = const.HorizontalPadding
                local tabsSize, tabsPos, contentsPos, contentsSize

                if expanded then
                    tabsSize = UDim2.new(const.TabsWidthOpen, -(hPad * 0.5), 1, 0)
                    tabsPos = UDim2.new(0, hPad * 0.5, 0, 0)
                    contentsPos = UDim2.new(const.TabsWidthOpen, hPad, 0, 0)
                    contentsSize = UDim2.new(const.ContentWidthOpen, -(hPad * 2), 1, 0)
                else
                    local contentLeft = const.ContentLeftOffsetClosed
                    tabsSize = UDim2.new(0, const.TabsWidthClosed, 1, 0)
                    tabsPos = UDim2.new(0, const.ClosedTabHorizontalPadding, 0, 0)
                    contentsPos = UDim2.new(0, contentLeft, 0, 0)
                    contentsSize = UDim2.new(1, -(contentLeft + hPad), 1, 0)
                end

                TweenService:Create(tabsContainer,
                    TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = tabsSize,
                        Position = tabsPos
                    }):Play()

                TweenService:Create(contentsContainer,
                    TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = contentsPos,
                        Size = contentsSize
                    }):Play()

                for _, tabData in pairs(self.Elements.Tabs) do
                    if type(tabData) == "table" and tabData.Container then

                        local isActive = tabData.Container == self.ActiveTab

                        if not isActive then
                            local currentTheme = SimpleUI.ThemeManager:GetCurrentTheme(self)
                            local targetColor = expanded and currentTheme.Secondary or currentTheme.Secondary
                            local targetTransparency = expanded and (currentTheme.TransparencySecondary or 0.8) or 1

                            TweenService:Create(tabData.Container, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad),
                                {
                                    BackgroundColor3 = targetColor,
                                    BackgroundTransparency = targetTransparency
                                }):Play()
                        end

                        TweenService:Create(tabData.Container, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                            Size = UDim2.new(1, -8, 0, expanded and 32 or 44)
                        }):Play()

                        if tabData.Icon then
                            local iconSize = expanded and const.TabIconSizeExpanded or 24
                            TweenService:Create(tabData.Icon, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                                Size = UDim2.new(0, iconSize, 0, iconSize)
                            }):Play()
                        end

                        if tabData.TextLabel then
                            if expanded then
                                tabData.TextLabel.Visible = true
                                TweenService:Create(tabData.TextLabel,
                                    TweenInfo.new(tweenDuration * 0.5, Enum.EasingStyle.Quad), {
                                        TextTransparency = 0
                                    }):Play()
                            else
                                TweenService:Create(tabData.TextLabel,
                                    TweenInfo.new(tweenDuration * 0.5, Enum.EasingStyle.Quad), {
                                        TextTransparency = 1
                                    }):Play()
                                task.delay(tweenDuration * 0.5, function()
                                    if not self.TabsExpanded then
                                        tabData.TextLabel.Visible = false
                                    end
                                end)
                            end
                        end

                        if tabData.ContentContainer then
                            TweenService:Create(tabData.ContentContainer,
                                TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), expanded and {
                                    Position = UDim2.new(0, 0, 0, 0),
                                    AnchorPoint = Vector2.new(0, 0)
                                } or {
                                    Position = UDim2.new(0.5, 0, 0.5, 0),
                                    AnchorPoint = Vector2.new(0.5, 0.5)
                                }):Play()
                        end

                        if tabData.AccentLine then
                            local isActive = tabData.Container == self.ActiveTab
                            if isActive then
                                TweenService:Create(tabData.AccentLine,
                                    TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                                        BackgroundTransparency = expanded and 1 or 0
                                    }):Play()
                            end
                        end
                    end
                end

                task.delay(tweenDuration, function()
                    for _, tabData in pairs(self.Elements.Tabs) do
                        if type(tabData) == "table" and tabData.RefreshVisuals then
                            tabData.RefreshVisuals()
                        end
                    end
                end)
            end

            if mode == modes.Fixed then
                setExpanded(true, animate)
            elseif mode == modes.Closed then
                setExpanded(false, animate)
            elseif mode == modes.Dynamic then
                setExpanded(false, animate)
                local mouseInside = false
                local expandConnection = nil

                local function scheduleExpand()
                    if expandConnection then
                        expandConnection:Disconnect()
                    end
                    expandConnection = task.spawn(function()
                        task.wait(threshold)
                        if mouseInside and self.TabMode == modes.Dynamic then
                            setExpanded(true, true)
                        end
                        expandConnection = nil
                    end)
                end

                tabsContainer.MouseEnter:Connect(function()
                    if self.TabMode ~= modes.Dynamic then
                        return
                    end
                    mouseInside = true
                    scheduleExpand()
                end)

                tabsContainer.MouseLeave:Connect(function()
                    mouseInside = false
                    if expandConnection then
                        task.cancel(expandConnection)
                        expandConnection = nil
                    end
                    if self.TabMode == modes.Dynamic then
                        setExpanded(false, true)
                    end
                end)
            end
        end,

        AddFooterText = function(self, config)
            if not footer or not footerContent then
                return nil
            end
            config = config or {}

            local currentTheme = SimpleUI.ThemeManager:GetCurrentTheme(self)
            local properties, bindings = SimpleUI.Utility:ApplyTheme({
                Name = config.Name or "FooterText",
                LayoutOrder = config.Order or 1,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = config.Text or "",
                TextSize = config.TextSize or 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = footer.ZIndex + 2
            }, {
                Font = "FontSecondary",
                TextColor3 = config.ColorTier or "TextSecondary"
            }, currentTheme)

            local label = SimpleUI.Utility:CreateInstance("TextLabel", properties, footerContent)
            if bindings then
                SimpleUI.ThemeManager:RegisterElement(self, label, bindings)
            end
            return label
        end,

        SetFooterText = function(self, element, newText)
            if element and element:IsA("TextLabel") then
                element.Text = tostring(newText)
            end
        end,

        AddFooterButton = function(self, config)
            if not footer or not footerContent then
                return nil
            end
            config = config or {}

            local currentTheme = SimpleUI.ThemeManager:GetCurrentTheme(self)
            local buttonText = config.Text or "Button"
            local callback = config.Callback or function()
            end

            local properties, bindings = SimpleUI.Utility:ApplyTheme({
                Name = config.Name or buttonText,
                LayoutOrder = config.Order or 1,
                Size = UDim2.new(0, config.Width or 80, 1, -8),
                Text = buttonText,
                TextSize = config.TextSize or 14,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                ZIndex = footer.ZIndex + 2
            }, {
                Font = "FontSecondary",
                TextColor3 = "TextPrimary",
                BackgroundColor3 = "Tertiary"
            }, currentTheme)

            local button = SimpleUI.Utility:CreateInstance("TextButton", properties, footerContent)
            SimpleUI.Utility:CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, SimpleUI.Constants.Corner.Medium)
            }, button)

            if not SimpleUI.Utility:IsMobile() then
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.15), {
                        BackgroundColor3 = currentTheme.TertiaryHover
                    }):Play()
                end)
                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.15), {
                        BackgroundColor3 = currentTheme.Tertiary
                    }):Play()
                end)
            end

            button.Activated:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.1), {
                    BackgroundColor3 = currentTheme.TertiaryPressed
                }):Play()
                task.wait(0.1)
                TweenService:Create(button, TweenInfo.new(0.1), {
                    BackgroundColor3 = currentTheme.Tertiary
                }):Play()
                SimpleUI.ErrorHandler:Try(function()
                    SimpleUI.Security:SafeCallback(callback())
                end)
            end)

            if bindings then
                SimpleUI.ThemeManager:RegisterElement(self, button, bindings)
            end
            return button
        end,

        ClearFooter = function(self)
            if footerContent then
                for _, child in ipairs(footerContent:GetChildren()) do
                    if not child:IsA("UIListLayout") then
                        child:Destroy()
                    end
                end
            end
        end,

        SetFooterAlignment = function(self, alignment)
            if footerContent then
                local layout = footerContent:FindFirstChildOfClass("UIListLayout")
                if layout then
                    layout.HorizontalAlignment = alignment
                end
            end
        end,

        Hide = function(self)
            mainFrame.Visible = false
        end,

        Show = function(self)
            mainFrame.Visible = true
        end,

        Toggle = function(self)
            mainFrame.Visible = not mainFrame.Visible
        end,

        Destroy = function(self)
            self._connections:Cleanup()
            SimpleUI.Windows[screenGui] = nil
            screenGui:Destroy()
        end,

        IsVisible = function(self)
            return mainFrame.Visible
        end,

        SetOpacity = function(self, value, animate)
            value = math.clamp(tonumber(value) or 1, 0, 1)
            local tweenDuration = animate and SimpleUI.Constants.Animation.Normal or 0

            for _, element in ipairs({topBar, mainContainer, footer}) do
                if element then
                    local originalTransparency = element:GetAttribute("OriginalTransparency")
                    if not originalTransparency then
                        originalTransparency = element.BackgroundTransparency
                        element:SetAttribute("OriginalTransparency", originalTransparency)
                    end

                    local newTransparency = 1 - ((1 - originalTransparency) * value)

                    if animate then
                        TweenService:Create(element, TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad), {
                            BackgroundTransparency = newTransparency
                        }):Play()
                    else
                        element.BackgroundTransparency = newTransparency
                    end
                end
            end
        end,

        EnableBlur = function(self, intensity)
            pcall(function()
                intensity = math.clamp(tonumber(intensity) or 24, 0, 56)
                local existing = Lighting:FindFirstChild("SimpleUIBlur")
                if existing then
                    existing.Size = intensity
                else
                    local blur = Instance.new("BlurEffect")
                    blur.Name = "SimpleUIBlur"
                    blur.Size = intensity
                    blur.Parent = Lighting
                end
            end)
        end,

        DisableBlur = function(self)
            pcall(function()
                local existing = Lighting:FindFirstChild("SimpleUIBlur")
                if existing then
                    existing:Destroy()
                end
            end)
        end
    }

    self.Windows[screenGui] = window
    self.ThemeManager:Initialize(window)

    if mainFrameBindings then
        self.ThemeManager:RegisterElement(window, mainFrame, mainFrameBindings)
    end
    if footer and footerBindings then
        self.ThemeManager:RegisterElement(window, footer, footerBindings)
    end
    if separatorBindings and separatorBindings.Element then
        self.ThemeManager:RegisterElement(window, separatorBindings.Element, separatorBindings.Bindings)
    end
    if topBarSeparatorBindings then
        self.ThemeManager:RegisterElement(window, topBarSeparator, topBarSeparatorBindings)
    end
    if tabsSeparatorBindings then
        self.ThemeManager:RegisterElement(window, tabsSeparator, tabsSeparatorBindings)
    end

    if tabNameLabel then
        self.ThemeManager:RegisterElement(window, tabNameLabel, {
            TextColor3 = "TextPrimary",
            Font = "FontPrimary"
        })
    end

    if tabDescLabel then
        self.ThemeManager:RegisterElement(window, tabDescLabel, {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        })
    end

    if brandTitleLabel then
        self.ThemeManager:RegisterElement(window, brandTitleLabel, {
            TextColor3 = "TextPrimary",
            Font = "FontPrimary"
        })
    end

    if brandInitialElement then
        self.ThemeManager:RegisterElement(window, brandInitialElement, {
            TextColor3 = "TextPrimary"
        })
    end

    self.WindowControlBuilder:RegisterIconBindings(window, controlButtons, options)

    self.WindowBuilder:SetupDragging(topBar, mainFrame)

    local resizeHandle, resizeIcon, resizeBindings = self.WindowBuilder:SetupResizing(mainFrame, uiScale, options,
        window.Elements.FooterResizeArea, ResizeMode, theme)

    self.WindowBuilder:SetupScrollUpdates(window)

    if resizeBindings then
        self.ThemeManager:RegisterMultiple(window, resizeBindings)
    end

    for _, methodName in ipairs({"Destroy", "SetTheme", "SetScale", "Hide", "Show", "Toggle", "IsVisible", "SetTitle",
                                 "SetSubtitle", "AddFooterButton", "ClearFooter", "SetFooterAlignment", "SetOpacity",
                                 "EnableBlur", "DisableBlur", "SetTabMode", "PopulateFooter"}) do
        if window[methodName] then
            window[methodName] = self.Security:WrapFunction(window[methodName])
        end
    end

    if footer and options.FooterItems then
        self.WindowBuilder:PopulateFooter(window, options, theme)
    end

    if options.StartHidden then
        mainFrame.Visible = false
    end

    if options.TabMode then
        window:SetTabMode(options.TabMode, true, options.TabDynamicThreshold)
    end

    if options.InitialOpacity then
        window:SetOpacity(options.InitialOpacity, false)
    end

    return window
end

function SimpleUI:CreateTab(Window, Name, Options)
    if not Window or not Window.Elements or not Window.Elements.TabsContainer then
        return
    end
    Options = Options or {}
    local Theme = self.ThemeManager:GetCurrentTheme(Window)
    local IsMobile = self.Utility:IsMobile()

    if not Window.TabActivationLock then
        Window.TabActivationLock = false
    end

    local Tab = self.Utility:CreateInstance("TextButton", {
        Name = Name,
        Size = UDim2.new(1, -8, 0, Window.TabsExpanded and 32 or 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = self.Constants.ZIndex.Content,
        LayoutOrder = #Window.Elements.Tabs
    }, Window.Elements.TabsContainer)
    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, Tab)

    local AccentLine = self.Utility:CreateInstance("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(0, 2, 0, 24),
        Position = UDim2.new(0, -4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.TabAccent or Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Control + 2
    }, Tab)
    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, AccentLine)

    local ContentContainer = self.Utility:CreateInstance("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Content + 1
    }, Tab)
    self.Utility:CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    }, ContentContainer)
    self.Utility:CreateInstance("UIPadding", {
        PaddingLeft = UDim.new(0, self.Constants.Padding.Large),
        PaddingRight = UDim.new(0, self.Constants.Padding.Large)
    }, ContentContainer)

    local Icon = nil
    local IconSize = 0

    if Options.Icon and type(Options.Icon) == "table" and Options.Icon.Image then
        IconSize = Window.TabsExpanded and self.Constants.Window.TabIconSizeExpanded or 24
        local IconData = self.IconManager:WrapIcon(Options.Icon)

        Icon = self.Utility:CreateInstance("ImageLabel", {
            Name = "TabIcon",
            Image = IconData.Url,
            ImageColor3 = Theme.TextInactive,
            Size = UDim2.new(0, IconSize, 0, IconSize),
            ImageTransparency = 0,
            ImageRectOffset = IconData.ImageRectOffset,
            ImageRectSize = IconData.ImageRectSize,
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            ZIndex = self.Constants.ZIndex.Control
        }, ContentContainer)
    end

    local TextLabel = self.Utility:CreateInstance("TextLabel", {
        Name = "TabText",
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -(IconSize > 0 and (IconSize + 8) or 0), 1, 0),
        AutomaticSize = Enum.AutomaticSize.None,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Font = Theme.FontSecondary,
        TextColor3 = Theme.TextInactive,
        LayoutOrder = 2,
        ZIndex = self.Constants.ZIndex.Control
    }, ContentContainer)

    local Page = self:CreatePage(Window, Name, Options)

    local TabState = {
        IsHovering = false
    }

    local function UpdateActiveBrandDisplay(TabName, TabOptions)
        local TabNameLabel = Window.Elements.TitleLabel
        local TabDescLabel = Window.Elements.SubtitleLabel

        if TabNameLabel then
            TabNameLabel.Text = TabName
        end
        if TabDescLabel then
            TabDescLabel.Text = TabOptions.Description or ""
        end
    end

    local function RefreshTabVisuals()
        local CurrentTheme = self.ThemeManager:GetCurrentTheme(Window)
        local IsCollapsed = not Window.TabsExpanded
        local IsActive = Window.ActiveTab == Tab

        if IsActive then
            Tab.BackgroundColor3 = CurrentTheme.SecondaryActive
            Tab.BackgroundTransparency = 0
            TextLabel.TextColor3 = CurrentTheme.TextActive
            if Icon then
                Icon.ImageColor3 = CurrentTheme.TabIconActive or CurrentTheme.TextActive
            end
            if IsCollapsed then
                AccentLine.BackgroundTransparency = 0
            else
                AccentLine.BackgroundTransparency = 1
            end
            UpdateActiveBrandDisplay(Name, Options)
        elseif TabState.IsHovering then
            Tab.BackgroundColor3 = CurrentTheme.Secondary
            Tab.BackgroundTransparency = 0
            TextLabel.TextColor3 = CurrentTheme.TextPrimary
            if Icon then
                Icon.ImageColor3 = CurrentTheme.TabIconHover or CurrentTheme.TextPrimary
            end
            AccentLine.BackgroundTransparency = 1
        else
            if IsCollapsed then
                Tab.BackgroundColor3 = CurrentTheme.Secondary
                Tab.BackgroundTransparency = 1
            else
                Tab.BackgroundColor3 = CurrentTheme.Secondary
                Tab.BackgroundTransparency = CurrentTheme.TransparencySecondary or 0.8
            end
            TextLabel.TextColor3 = CurrentTheme.TextInactive
            if Icon then
                Icon.ImageColor3 = CurrentTheme.TabIconInactive or CurrentTheme.TextInactive
            end
            AccentLine.BackgroundTransparency = 1
        end
    end

    if not IsMobile then
        Tab.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                TabState.IsHovering = true
                RefreshTabVisuals()
            end
        end)
        Tab.MouseLeave:Connect(function()
            TabState.IsHovering = false
            RefreshTabVisuals()
        end)
    end

    Tab.Activated:Connect(function()
        if Window.TabActivationLock then
            return
        end
        if Window.ActiveTab == Tab then
            return
        end

        Window.TabActivationLock = true

        if Window.ActivePage then
            local pageToHide = Window.ActivePage
            if type(pageToHide) == "table" and pageToHide.Container then
                pageToHide = pageToHide.Container
            end
            pageToHide.Visible = false
        end

        Window.ActiveTab = Tab

        local CurrentPage = Window.Elements.ContentsContainer:FindFirstChild(Name .. "Page")
        if CurrentPage then
            Page = CurrentPage
            if type(Page) == "table" and Page._isDualScroll then
                Page.Left = self.ScrollManager:Update(Page.Left)
                Page.Right = self.ScrollManager:Update(Page.Right)
            else
                Page = self.ScrollManager:Update(Page)
            end
            Window.Elements.Pages[Name] = Page
        end
        Window.ActivePage = Page
        local pageToShow = Window.ActivePage
        if type(pageToShow) == "table" and pageToShow.Container then
            pageToShow = pageToShow.Container
        end
        pageToShow.Visible = true

        for TabName, TabData in pairs(Window.Elements.Tabs) do
            TabData.State.IsHovering = false
            TabData.RefreshVisuals()
        end

        task.delay(0.15, function()
            Window.TabActivationLock = false
        end)
    end)

    Window.Elements.Tabs[Name] = {
        Container = Tab,
        Icon = Icon,
        ContentContainer = ContentContainer,
        TextLabel = TextLabel,
        AccentLine = AccentLine,
        Page = Page,
        RefreshVisuals = RefreshTabVisuals,
        State = TabState
    }

    local ThemeBindings = {
        [AccentLine] = {
            BackgroundColor3 = function(Element, CurrentTheme)
                Element.BackgroundColor3 = CurrentTheme.TabAccent or CurrentTheme.Accent
            end
        },
        [TextLabel] = {
            Font = "FontSecondary"
        },
        [Tab] = {
            BackgroundColor3 = function(Element, CurrentTheme)
                RefreshTabVisuals()
            end,
            BackgroundTransparency = function(Element, CurrentTheme)
                RefreshTabVisuals()
            end
        }
    }

    if Icon then
        ThemeBindings[Icon] = {
            ImageColor3 = function(Element, CurrentTheme)
                RefreshTabVisuals()
            end
        }
    end

    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end

    if not Window.ActiveTab then
        Window.ActiveTab = Tab
        Window.ActivePage = Page
        local pageToShow = Window.ActivePage
        if type(pageToShow) == "table" and pageToShow.Container then
            pageToShow = pageToShow.Container
        end
        pageToShow.Visible = true
    else
        Page.Visible = false
    end

    RefreshTabVisuals()

    return {
        Tab = Tab,
        Page = Page,
        Icon = Icon,
        AccentLine = AccentLine
    }
end

function SimpleUI:CreatePage(Window, Name, Options)
    if not Window or not Window.Elements or not Window.Elements.ContentsContainer then
        return
    end
    Options = Options or {}
    local IsDualScroll = Options.DualScroll or false

    if not IsDualScroll then
        local Page = self.Utility:CreateInstance("Frame", {
            Name = Name .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = self.Constants.ZIndex.Content,
            ClipsDescendants = false
        }, Window.Elements.ContentsContainer)
        self.Utility:CreateInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, self.Constants.Spacing.Loose)
        }, Page)
        self.Utility:CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2)
        }, Page)
        Window.Elements.Pages[Name] = Page
        task.defer(function()
            if Window.ActivePage then
                local pageToUpdate = Window.ActivePage
                if type(pageToUpdate) == "table" and pageToUpdate.Container then
                    pageToUpdate = pageToUpdate.Container
                end
                Window.ActivePage = self.ScrollManager:Update(pageToUpdate)
            end
        end)
        return Page
    else
        local PageContainer = self.Utility:CreateInstance("Frame", {
            Name = Name .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = self.Constants.ZIndex.Content,
            ClipsDescendants = false
        }, Window.Elements.ContentsContainer)

        self.Utility:CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2)
        }, PageContainer)

        self.Utility:CreateInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }, PageContainer)

        local LeftPage = self.Utility:CreateInstance("Frame", {
            Name = Name .. "PageLeft",
            Size = UDim2.new(0.5, -4, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = self.Constants.ZIndex.Content,
            ClipsDescendants = false,
            LayoutOrder = 1
        }, PageContainer)

        self.Utility:CreateInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, self.Constants.Spacing.Loose)
        }, LeftPage)

        self.Utility:CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2)
        }, LeftPage)
        local RightPage = self.Utility:CreateInstance("Frame", {
            Name = Name .. "PageRight",
            Size = UDim2.new(0.5, -4, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = self.Constants.ZIndex.Content,
            ClipsDescendants = false,
            LayoutOrder = 2
        }, PageContainer)

        self.Utility:CreateInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, self.Constants.Spacing.Loose)
        }, RightPage)

        self.Utility:CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2)
        }, RightPage)
        local PageWrapper = {
            Container = PageContainer,
            Left = LeftPage,
            Right = RightPage,
            _isDualScroll = true
        }

        Window.Elements.Pages[Name] = PageWrapper

        task.defer(function()
            PageWrapper.Left = self.ScrollManager:Update(PageWrapper.Left)
            PageWrapper.Right = self.ScrollManager:Update(PageWrapper.Right)
        end)

        return PageWrapper
    end
end

function SimpleUI:CreateSection(Page, Text, Options)
    if not Page then
        return
    end
    Options = Options or {}
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local Window = self.Utility:GetWindowFromElement(Page)
    local Style = Options.Style or "solid"

    if Style == "box" then
        return self.SectionManager:CreateBoxSection(Page, Text, Options, Theme, Window)
    else
        return self.SectionManager:CreateSimpleSection(Page, Text, Options, Theme, Window, Style)
    end
end

function SimpleUI:CreateButton(Page, Text, Callback, Options)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateButton") then
        return nil
    end
    if not EH:ValidateType(Text, "string", "Text", "CreateButton") then
        Text = "Button"
    end
    if Callback then
        Callback = (EH:ValidateType(Callback, "function", "Callback", "CreateButton") == false) and nil or Callback
    end
    Options = Options or {}
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local IsMobile = self.Utility:IsMobile()
    local Window = self.Utility:GetWindowFromElement(Page)
    local HasDescription = Options.Description and Options.Description ~= ""

    local Zones = self.ComponentBuilder:CreateContainer({
        Parent = Page,
        Layout = "TextLeft",
        TextWidth = 0.85,
        MinHeight = 35,
        Padding = HasDescription and {
            Top = self.Constants.Padding.Large,
            Bottom = self.Constants.Padding.Large,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        } or {
            Top = 2,
            Bottom = 2,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        },
        Spacing = HasDescription and self.Constants.Spacing.Tight or 0,
        HasDescription = HasDescription,
        CornerRadius = self.Constants.Corner.Medium,
        ColorTier = "Secondary"
    }, Theme)

    local Title = self.ComponentBuilder:CreateLabel(Zones.TextZone, Text, Theme, {
        ColorTier = "TextPrimary",
        Size = 15,
        Order = 1
    })

    local Description = HasDescription and
                            self.ComponentBuilder:CreateDescription(Zones.TextZone, Options.Description, Theme, 2) or
                            nil

    local ArrowContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0.15, -self.Constants.Padding.Large, 1, 0),
        Position = UDim2.new(0.85, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.Container)

    local Arrow = self.Utility:CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://113826256227095",
        ImageRectOffset = Vector2.new(448, 192),
        ImageRectSize = Vector2.new(64, 64),
        ImageColor3 = Theme.TextPrimary,
        ZIndex = self.Constants.ZIndex.Overlay
    }, ArrowContainer)

    local ThemeBindings = {
        [Zones.Container] = {
            BackgroundColor3 = "Secondary",
            BackgroundTransparency = "TransparencySecondary"
        },
        [Title] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [Arrow] = {
            ImageColor3 = "TextPrimary"
        }
    }
    if Description then
        ThemeBindings[Description] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        }
    end
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end

    local State = "Base"
    local IsHeld = false

    local function UpdateButtonState(NewState)
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        local ColorGoal = CurrentTheme.Secondary
        local ArrowOffset = 0

        if NewState == "Hover" then
            ColorGoal = CurrentTheme.SecondaryHover
            ArrowOffset = -2
        elseif NewState == "Pressed" then
            ColorGoal = CurrentTheme.SecondaryPressed
            ArrowOffset = 2
        end

        TweenService:Create(Zones.Container, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundColor3 = ColorGoal
        }):Play()

        TweenService:Create(Arrow, TweenInfo.new(0.15, Enum.EasingStyle.Back, NewState == "Pressed" and
            Enum.EasingDirection.In or Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -10 + ArrowOffset, 0.5, 0)
        }):Play()
    end

    local InteractButton = self.Utility:CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = self.Constants.ZIndex.Modal
    }, Zones.Container)

    if not IsMobile then
        InteractButton.MouseEnter:Connect(function()
            if not IsHeld then
                State = "Hover"
                UpdateButtonState(State)
            end
        end)
        InteractButton.MouseLeave:Connect(function()
            if IsHeld then
                IsHeld = false
            end
            State = "Base"
            UpdateButtonState(State)
        end)
        InteractButton.MouseButton1Down:Connect(function()
            IsHeld = true
            State = "Pressed"
            UpdateButtonState(State)
        end)
        InteractButton.MouseButton1Up:Connect(function()
            if IsHeld then
                IsHeld = false
                State = "Hover"
                UpdateButtonState(State)
                if Callback then
                    EH:Try(Callback)
                end
            end
        end)
    else
        InteractButton.Activated:Connect(function()
            State = "Pressed"
            UpdateButtonState(State)
            task.delay(0.15, function()
                State = "Base"
                UpdateButtonState(State)
            end)
            if Callback then
                EH:Try(Callback)
            end
        end)
    end

    return {
        SetTitle = function(self, NewText)
            if EH:ValidateType(NewText, "string", "NewText", "Button:SetTitle") then
                Title.Text = NewText
            end
        end,
        SetDescription = function(self, NewDescription)
            local HadDescription = Description ~= nil and Description.Visible
            local HasNewDescription = NewDescription and NewDescription ~= ""
            if Description and NewDescription then
                Description.Text = NewDescription
                Description.Visible = true
            elseif Description and not NewDescription then
                Description.Visible = false
            elseif not Description and NewDescription then
                Description = SimpleUI.ComponentBuilder:CreateDescription(Zones.TextZone, NewDescription, Theme, 2)
                if Window then
                    SimpleUI.ThemeManager:RegisterElement(Window, Description, {
                        TextColor3 = "TextSecondary",
                        Font = "FontSecondary"
                    })
                end
            end
            if HadDescription ~= HasNewDescription then
                SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasNewDescription)
            end
        end,
        SetCallback = function(self, NewCallback)
            if EH:ValidateType(NewCallback, "function", "NewCallback", "Button:SetCallback") then
                Callback = NewCallback
            end
        end,
        SetVisible = function(self, Visible)
            if EH:ValidateType(Visible, "boolean", "Visible", "Button:SetVisible") then
                Zones.Container.Visible = Visible
            end
        end,
        GetElements = function(self)
            return {
                Container = Zones.Container,
                Title = Title,
                Description = Description,
                Arrow = Arrow
            }
        end,
        GetState = function(self)
            return State
        end
    }
end

function SimpleUI:CreateToggle(Page, Text, DefaultValue, Callback, Options)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateToggle") then
        return nil
    end
    if not EH:ValidateType(Text, "string", "Text", "CreateToggle") then
        Text = "Toggle"
    end
    if DefaultValue ~= nil and not EH:ValidateType(DefaultValue, "boolean", "DefaultValue", "CreateToggle") then
        DefaultValue = false
    end
    if Callback then
        Callback = (EH:ValidateType(Callback, "function", "Callback", "CreateToggle") == false) and nil or Callback
    end
    Options = Options or {}
    local SaveBinding = self.SaveManager:GetBinding(Options, "Toggle", Text)
    if SaveBinding.Enabled and type(SaveBinding.Value) == "boolean" then
        DefaultValue = SaveBinding.Value
    end
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local Window = self.Utility:GetWindowFromElement(Page)
    local HasDescription = Options.Description and Options.Description ~= ""

    local Zones = self.ComponentBuilder:CreateContainer({
        Parent = Page,
        Layout = "TextLeft",
        TextWidth = 0.75,
        MinHeight = 35,
        Padding = HasDescription and {
            Top = self.Constants.Padding.Large,
            Bottom = self.Constants.Padding.Large,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        } or {
            Top = 2,
            Bottom = 2,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        },
        Spacing = HasDescription and self.Constants.Spacing.Tight or 0,
        HasDescription = HasDescription,
        CornerRadius = self.Constants.Corner.Medium,
        ColorTier = "Secondary"
    }, Theme)

    local Label = self.ComponentBuilder:CreateLabel(Zones.TextZone, Text, Theme, {
        ColorTier = "TextPrimary",
        Size = 14,
        Order = 1
    })

    local Description = HasDescription and
                            self.ComponentBuilder:CreateDescription(Zones.TextZone, Options.Description, Theme, 2) or
                            nil

    local SwitchContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0.25, -self.Constants.Padding.Large, 1, 0),
        Position = UDim2.new(0.75, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.Container)

    local Switch = self.Utility:CreateInstance("TextButton", {
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.SecondaryPressed,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = self.Constants.ZIndex.Overlay
    }, SwitchContainer)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, Switch)

    local Indicator = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.TextInactive,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Modal
    }, Switch)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, Indicator)

    local State = DefaultValue or false

    local function UpdateToggle(Animate)
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        local PositionGoal = State and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local ColorGoal = State and CurrentTheme.Accent or CurrentTheme.SecondaryPressed
        local IndicatorColorGoal = State and CurrentTheme.TextActive or CurrentTheme.TextInactive

        if Animate then
            TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = PositionGoal
            }):Play()
            TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = ColorGoal
            }):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = IndicatorColorGoal
            }):Play()
        else
            Indicator.Position = PositionGoal
            Switch.BackgroundColor3 = ColorGoal
            Indicator.BackgroundColor3 = IndicatorColorGoal
        end
    end

    local ThemeBindings = {
        [Zones.Container] = {
            BackgroundColor3 = "Secondary",
            BackgroundTransparency = "TransparencySecondary"
        },
        [Label] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [Switch] = {
            BackgroundColor3 = function()
                UpdateToggle(false)
            end
        },
        [Indicator] = {
            BackgroundColor3 = function()
                UpdateToggle(false)
            end
        }
    }
    if Description then
        ThemeBindings[Description] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        }
    end
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end

    UpdateToggle(false)

    if Callback and ((SaveBinding.HasValue and SaveBinding.ApplyCallback) or (not SaveBinding.HasValue and State)) then
        EH:Try(function()
            Callback(State)
        end)
    end

    Switch.Activated:Connect(function()
        State = not State
        UpdateToggle(true)
        SimpleUI.SaveManager:WriteBinding(SaveBinding, State)
        if Callback then
            EH:Try(function()
                Callback(State)
            end)
        end
    end)

    return {
        GetState = function(self)
            return State
        end,
        SetState = function(self, Value)
            if EH:ValidateType(Value, "boolean", "Value", "Toggle:SetState") then
                State = Value
                UpdateToggle(true)
                SimpleUI.SaveManager:WriteBinding(SaveBinding, State)
            end
        end,
        SetDescription = function(self, NewDescription)
            local HadDescription = Description ~= nil and Description.Visible
            local HasNewDescription = NewDescription and NewDescription ~= ""
            if Description and NewDescription then
                Description.Text = NewDescription
                Description.Visible = true
            elseif Description and not NewDescription then
                Description.Visible = false
            elseif not Description and NewDescription then
                Description = SimpleUI.ComponentBuilder:CreateDescription(Zones.TextZone, NewDescription, Theme, 2)
                if Window then
                    SimpleUI.ThemeManager:RegisterElement(Window, Description, {
                        TextColor3 = "TextSecondary",
                        Font = "FontSecondary"
                    })
                end
            end
            if HadDescription ~= HasNewDescription then
                SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasNewDescription)
            end
        end,
        GetElements = function(self)
            return {
                Container = Zones.Container,
                Label = Label,
                Description = Description,
                Switch = Switch,
                Indicator = Indicator
            }
        end
    }
end

function SimpleUI:CreateTextInput(Page, Text, DefaultValue, Callback, Options)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateTextInput") then
        return nil
    end
    if not EH:ValidateType(Text, "string", "Text", "CreateTextInput") then
        Text = "Input"
    end
    if DefaultValue and not EH:ValidateType(DefaultValue, "string", "DefaultValue", "CreateTextInput") then
        DefaultValue = ""
    end
    if Callback then
        Callback = (EH:ValidateType(Callback, "function", "Callback", "CreateTextInput") == false) and nil or Callback
    end

    Options = Options or {}
    local SaveBinding = self.SaveManager:GetBinding(Options, "TextInput", Text)
    if SaveBinding.Enabled and type(SaveBinding.Value) == "string" then
        DefaultValue = SaveBinding.Value
    end
    local InputType = Options.Type or "Text"
    local ValidTypes = {
        Text = true,
        Numbers = true,
        Decimals = true,
        Alphanumeric = true
    }
    if not ValidTypes[InputType] then
        InputType = "Text"
    end

    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local IsMobile = self.Utility:IsMobile()
    local Window = self.Utility:GetWindowFromElement(Page)
    local HasDescription = Options.Description and Options.Description ~= ""

    local Zones = self.ComponentBuilder:CreateContainer({
        Parent = Page,
        Layout = "TextLeft",
        TextWidth = 0.55,
        MinHeight = 35,
        Padding = HasDescription and {
            Top = self.Constants.Padding.Large,
            Bottom = self.Constants.Padding.Large,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        } or {
            Top = 2,
            Bottom = 2,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        },
        Spacing = HasDescription and self.Constants.Spacing.Tight or 0,
        HasDescription = HasDescription,
        CornerRadius = self.Constants.Corner.Medium,
        ColorTier = "Secondary"
    }, Theme)

    local Label = self.ComponentBuilder:CreateLabel(Zones.TextZone, Text, Theme, {
        ColorTier = "TextPrimary",
        Size = 14,
        Order = 1
    })

    local Description = HasDescription and
                            self.ComponentBuilder:CreateDescription(Zones.TextZone, Options.Description, Theme, 2) or
                            nil

    local InputContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0.45, -self.Constants.Padding.Large, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.Container)

    local InputBox = self.Utility:CreateInstance("TextBox", {
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = DefaultValue or "",
        PlaceholderText = Options.Placeholder or "Enter text...",
        TextColor3 = Theme.TextPrimary,
        PlaceholderColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Theme.FontSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = self.Constants.ZIndex.Overlay
    }, InputContainer)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, InputBox)

    self.Utility:CreateInstance("UIPadding", {
        PaddingLeft = UDim.new(0, self.Constants.Padding.Medium),
        PaddingRight = UDim.new(0, self.Constants.Padding.Medium)
    }, InputBox)

    local Underline = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Modal
    }, InputBox)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, Underline)

    local ErrorLabel = self.Utility:CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 11,
        Font = Theme.FontSecondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextWrapped = true,
        Visible = false,
        ZIndex = self.Constants.ZIndex.Overlay
    }, InputContainer)

    local ThemeBindings = {
        [Zones.Container] = {
            BackgroundColor3 = "Secondary",
            BackgroundTransparency = "TransparencySecondary"
        },
        [Label] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [InputBox] = {
            TextColor3 = "TextPrimary",
            PlaceholderColor3 = "TextSecondary",
            BackgroundColor3 = "Tertiary",
            Font = "FontSecondary"
        },
        [Underline] = {
            BackgroundColor3 = "Tertiary"
        }
    }
    if Description then
        ThemeBindings[Description] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        }
    end
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end

    local IsFocused = false
    local LastValidValue = DefaultValue or ""

    local ValidationPatterns = {
        Numbers = "^%-?%d+$",
        Decimals = "^%-?%d*%.?%d*$",
        Alphanumeric = "^[%a%d]+$"
    }

    local function validateInput(inputValue)
        if InputType == "Text" then
            return true
        end
        if inputValue == "" or (InputType == "Decimals" and inputValue == "-") then
            return true
        end

        local pattern = ValidationPatterns[InputType]
        return pattern and string.match(inputValue, pattern) ~= nil
    end

    local function showError(message)
        ErrorLabel.Text = message
        ErrorLabel.Visible = true
        TweenService:Create(InputBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        }):Play()
    end

    local function clearError()
        ErrorLabel.Visible = false
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        TweenService:Create(InputBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = CurrentTheme.Tertiary
        }):Play()
    end

    local function updateHover(state)
        if IsFocused then
            return
        end
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        TweenService:Create(InputBox, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and CurrentTheme.TertiaryHover or CurrentTheme.Tertiary
        }):Play()
    end

    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        local currentText = InputBox.Text
        if not validateInput(currentText) then
            InputBox.Text = LastValidValue
            showError("Invalid " .. InputType)
        else
            LastValidValue = currentText
            if IsFocused then
                clearError()
            end
        end
    end)

    InputBox.Focused:Connect(function()
        IsFocused = true
        clearError()
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        TweenService:Create(Underline, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundColor3 = CurrentTheme.Accent,
            Size = UDim2.new(1, 0, 0, 3)
        }):Play()
        TweenService:Create(InputBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = CurrentTheme.TertiaryHover
        }):Play()
    end)

    InputBox.FocusLost:Connect(function()
        IsFocused = false
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        TweenService:Create(Underline, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundColor3 = CurrentTheme.TertiaryPressed,
            Size = UDim2.new(1, 0, 0, 2)
        }):Play()
        updateHover(false)
        if validateInput(InputBox.Text) then
            SimpleUI.SaveManager:WriteBinding(SaveBinding, InputBox.Text)
            if Callback then
                EH:Try(function()
                    Callback(InputBox.Text)
                end)
            end
        else
            InputBox.Text = LastValidValue
        end
    end)

    if not IsMobile then
        InputBox.MouseEnter:Connect(function()
            updateHover(true)
        end)
        InputBox.MouseLeave:Connect(function()
            updateHover(false)
        end)
    end

    if SaveBinding.HasValue and SaveBinding.ApplyCallback and Callback then
        EH:Try(function()
            Callback(InputBox.Text)
        end)
    end

    return {
        GetValue = function(self)
            return InputBox.Text
        end,
        SetValue = function(self, Value)
            if EH:ValidateType(Value, "string", "Value", "TextInput:SetValue") and validateInput(Value) then
                InputBox.Text = Value
                LastValidValue = Value
                clearError()
                SimpleUI.SaveManager:WriteBinding(SaveBinding, Value)
            end
        end,
        SetPlaceholder = function(self, Placeholder)
            if EH:ValidateType(Placeholder, "string", "Placeholder", "TextInput:SetPlaceholder") then
                InputBox.PlaceholderText = Placeholder
            end
        end,
        Clear = function(self)
            InputBox.Text = ""
            LastValidValue = ""
            clearError()
            SimpleUI.SaveManager:WriteBinding(SaveBinding, "")
        end,
        GetInputType = function(self)
            return InputType
        end,
        SetInputType = function(self, NewType)
            if ValidTypes[NewType] then
                InputType = NewType
                clearError()
            end
        end,
        SetDescription = function(self, NewDescription)
            local HadDescription = Description ~= nil and Description.Visible
            local HasNewDescription = NewDescription and NewDescription ~= ""
            if Description and NewDescription then
                Description.Text = NewDescription
                Description.Visible = true
            elseif Description and not NewDescription then
                Description.Visible = false
            elseif not Description and NewDescription then
                Description = SimpleUI.ComponentBuilder:CreateDescription(Zones.TextZone, NewDescription, Theme, 2)
                if Window then
                    SimpleUI.ThemeManager:RegisterElement(Window, Description, {
                        TextColor3 = "TextSecondary",
                        Font = "FontSecondary"
                    })
                end
            end
            if HadDescription ~= HasNewDescription then
                SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasNewDescription)
            end
        end,
        GetElements = function(self)
            return {
                Container = Zones.Container,
                Label = Label,
                Description = Description,
                InputBox = InputBox,
                Underline = Underline,
                ErrorLabel = ErrorLabel
            }
        end
    }
end

function SimpleUI:CreateKeybind(Page, Text, DefaultKey, Callback, Options)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateKeybind") then
        return nil
    end
    if not EH:ValidateType(Text, "string", "Text", "CreateKeybind") then
        Text = "Keybind"
    end
    if DefaultKey and typeof(DefaultKey) ~= "EnumItem" then
        EH:Guard(false, "CreateKeybind", "DefaultKey must be a KeyCode Enum", EH.Levels.WARN)
        DefaultKey = nil
    elseif DefaultKey and DefaultKey.EnumType ~= Enum.KeyCode then
        EH:Guard(false, "CreateKeybind", "DefaultKey must be a KeyCode (not " .. tostring(DefaultKey.EnumType) .. ")",
            EH.Levels.WARN)
        DefaultKey = nil
    end
    if Callback then
        Callback = (EH:ValidateType(Callback, "function", "Callback", "CreateKeybind") == false) and nil or Callback
    end
    Options = Options or {}
    local SaveBinding = self.SaveManager:GetBinding(Options, "Keybind", Text)
    if SaveBinding.Enabled and type(SaveBinding.Value) == "string" then
        local SavedKey = Enum.KeyCode[SaveBinding.Value]
        if SavedKey then
            DefaultKey = SavedKey
        end
    end
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local IsMobile = self.Utility:IsMobile()
    local Window = self.Utility:GetWindowFromElement(Page)
    local HasDescription = Options.Description and Options.Description ~= ""

    local Zones = self.ComponentBuilder:CreateContainer({
        Parent = Page,
        Layout = "TextLeft",
        TextWidth = 0.65,
        MinHeight = 35,
        Padding = HasDescription and {
            Top = self.Constants.Padding.Large,
            Bottom = self.Constants.Padding.Large,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        } or {
            Top = 2,
            Bottom = 2,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        },
        Spacing = HasDescription and self.Constants.Spacing.Tight or 0,
        HasDescription = HasDescription,
        CornerRadius = self.Constants.Corner.Medium,
        ColorTier = "Secondary"
    }, Theme)

    local Label = self.ComponentBuilder:CreateLabel(Zones.TextZone, Text, Theme, {
        ColorTier = "TextPrimary",
        Size = 14,
        Order = 1
    })

    local Description = HasDescription and
                            self.ComponentBuilder:CreateDescription(Zones.TextZone, Options.Description, Theme, 2) or
                            nil

    local DisplayContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0.35, -self.Constants.Padding.Large, 1, 0),
        Position = UDim2.new(0.65, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.Container)

    local Display = self.Utility:CreateInstance("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = self.Constants.ZIndex.Overlay
    }, DisplayContainer)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, Display)

    self.Utility:CreateInstance("UIPadding", {
        PaddingLeft = UDim.new(0, self.Constants.Padding.Medium),
        PaddingRight = UDim.new(0, self.Constants.Padding.Medium)
    }, Display)

    local DisplayLabel = self.Utility:CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSecondary,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = self.Constants.ZIndex.Modal
    }, Display)

    local ThemeBindings = {
        [Zones.Container] = {
            BackgroundColor3 = "Secondary",
            BackgroundTransparency = "TransparencySecondary"
        },
        [Label] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [DisplayLabel] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        }
    }
    if Description then
        ThemeBindings[Description] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        }
    end
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end

    local CurrentKey = DefaultKey
    local IsListening = false
    local BindConnection
    local InputConnection

    local function UpdateDisplay()
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        if IsListening then
            DisplayLabel.Text = "Press a key..."
            TweenService:Create(Display, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = CurrentTheme.Accent
            }):Play()
            TweenService:Create(DisplayLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                TextColor3 = CurrentTheme.TextActive
            }):Play()
        else
            DisplayLabel.Text = CurrentKey and CurrentKey.Name or "None"
            TweenService:Create(Display, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = CurrentTheme.Tertiary
            }):Play()
            TweenService:Create(DisplayLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                TextColor3 = CurrentTheme.TextPrimary
            }):Play()
        end
    end

    local function SetupBind()
        if BindConnection then
            BindConnection:Disconnect()
        end
        if CurrentKey and Callback then
            BindConnection = UserInputService.InputBegan:Connect(
                function(Input, GameProcessed)
                    if not GameProcessed and Input.KeyCode == CurrentKey then
                        EH:Try(function()
                            Callback(CurrentKey)
                        end)
                    end
                end)
        end
    end

    Display.Activated:Connect(function()
        if IsListening then
            return
        end
        IsListening = true
        UpdateDisplay()
        InputConnection = UserInputService.InputBegan:Connect(
            function(Input, GameProcessed)
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    CurrentKey = Input.KeyCode
                    IsListening = false
                    if InputConnection then
                        InputConnection:Disconnect()
                        InputConnection = nil
                    end
                    UpdateDisplay()
                    SetupBind()
                    SimpleUI.SaveManager:WriteBinding(SaveBinding, CurrentKey and CurrentKey.Name or nil)
                end
            end)
    end)

    if not IsMobile then
        Display.MouseEnter:Connect(function()
            if not IsListening then
                local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
                TweenService:Create(Display, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CurrentTheme.TertiaryHover
                }):Play()
            end
        end)
        Display.MouseLeave:Connect(function()
            if not IsListening then
                local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
                TweenService:Create(Display, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CurrentTheme.Tertiary
                }):Play()
            end
        end)
    end

    UpdateDisplay()
    SetupBind()

    if Window then
        self.ThemeManager:RegisterElement(Window, Display, {
            BackgroundColor3 = function(Element, Theme)
                if not IsListening then
                    Element.BackgroundColor3 = Theme.Tertiary
                end
            end
        })
    end

    return {
        GetKey = function(self)
            return CurrentKey
        end,
        SetKey = function(self, Key)
            if Key and typeof(Key) ~= "EnumItem" then
                EH:Guard(false, "Keybind:SetKey", "Key must be a KeyCode Enum", EH.Levels.WARN)
                return
            end
            CurrentKey = Key
            UpdateDisplay()
            SetupBind()
            SimpleUI.SaveManager:WriteBinding(SaveBinding, CurrentKey and CurrentKey.Name or nil)
        end,
        Clear = function(self)
            CurrentKey = nil
            UpdateDisplay()
            if BindConnection then
                BindConnection:Disconnect()
                BindConnection = nil
            end
            SimpleUI.SaveManager:WriteBinding(SaveBinding, nil)
        end,
        SetDescription = function(self, NewDescription)
            local HadDescription = Description ~= nil and Description.Visible
            local HasNewDescription = NewDescription and NewDescription ~= ""
            if Description and NewDescription then
                Description.Text = NewDescription
                Description.Visible = true
            elseif Description and not NewDescription then
                Description.Visible = false
            elseif not Description and NewDescription then
                Description = SimpleUI.ComponentBuilder:CreateDescription(Zones.TextZone, NewDescription, Theme, 2)
                if Window then
                    SimpleUI.ThemeManager:RegisterElement(Window, Description, {
                        TextColor3 = "TextSecondary",
                        Font = "FontSecondary"
                    })
                end
            end
            if HadDescription ~= HasNewDescription then
                SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasNewDescription)
            end
        end,
        GetElements = function(self)
            return {
                Container = Zones.Container,
                Label = Label,
                Description = Description,
                Display = Display,
                DisplayLabel = DisplayLabel
            }
        end
    }
end

function SimpleUI:CreateSlider(Page, Text, Min, Max, DefaultValue, Callback, Options)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateSlider") then
        return nil
    end
    if not EH:ValidateType(Text, "string", "Text", "CreateSlider") then
        Text = "Slider"
    end
    if not EH:ValidateType(Min, "number", "Min", "CreateSlider") then
        Min = 0
    end
    if not EH:ValidateType(Max, "number", "Max", "CreateSlider") then
        Max = 100
    end
    if Min >= Max then
        EH:Guard(false, "CreateSlider", "Min must be less than Max, swapping values", EH.Levels.WARN)
        Min, Max = Max, Min
    end
    if DefaultValue then
        if not EH:ValidateType(DefaultValue, "number", "DefaultValue", "CreateSlider") then
            DefaultValue = Min
        else
            DefaultValue = math.clamp(DefaultValue, Min, Max)
        end
    else
        DefaultValue = Min
    end
    if Callback then
        Callback = (EH:ValidateType(Callback, "function", "Callback", "CreateSlider") == false) and nil or Callback
    end
    Options = Options or {}
    local SaveBinding = self.SaveManager:GetBinding(Options, "Slider", Text)
    if SaveBinding.Enabled and type(SaveBinding.Value) == "number" then
        DefaultValue = math.clamp(SaveBinding.Value, Min, Max)
    end
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local Window = self.Utility:GetWindowFromElement(Page)
    local Increment = Options.Increment or 1
    if not EH:ValidateType(Increment, "number", "Increment", "CreateSlider") then
        Increment = 1
    elseif Increment <= 0 then
        EH:Guard(false, "CreateSlider", "Increment must be positive, using 1", EH.Levels.WARN)
        Increment = 1
    end
    local HasDescription = Options.Description and Options.Description ~= ""
    local Zones = self.ComponentBuilder:CreateContainer({
        Parent = Page,
        Layout = "Stacked",
        MinHeight = 50,
        Padding = HasDescription and {
            Top = self.Constants.Padding.Large,
            Bottom = self.Constants.Padding.Large,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        } or {
            Top = 2,
            Bottom = 2,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        },
        Spacing = HasDescription and self.Constants.Spacing.Normal or self.Constants.Spacing.Tight,
        HasDescription = HasDescription,
        CornerRadius = self.Constants.Corner.Medium,
        ColorTier = "Secondary"
    }, Theme)
    local LabelContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.TextZone)
    local Label = self.ComponentBuilder:CreateLabel(LabelContainer, Text, Theme, {
        ColorTier = "TextPrimary",
        Size = 14,
        WidthOffset = -60
    })
    local ValueLabel = self.Utility:CreateInstance("TextLabel", {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = tostring(DefaultValue or Min),
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Theme.FontSecondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = self.Constants.ZIndex.Overlay
    }, LabelContainer)
    local Description = HasDescription and
                            self.ComponentBuilder:CreateDescription(Zones.TextZone, Options.Description, Theme, 2) or
                            nil
    local TrackContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.TextZone)
    local Track = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.TertiaryPressed,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Overlay
    }, TrackContainer)
    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, Track)
    local Fill = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Modal
    }, Track)
    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, Fill)
    local Thumb = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TextActive,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Notification
    }, Track)
    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, Thumb)
    local ThemeBindings = {
        [Zones.Container] = {
            BackgroundColor3 = "Secondary",
            BackgroundTransparency = "TransparencySecondary"
        },
        [Label] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [ValueLabel] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        },
        [Track] = {
            BackgroundColor3 = "TertiaryPressed"
        },
        [Fill] = {
            BackgroundColor3 = "Accent"
        },
        [Thumb] = {
            BackgroundColor3 = "TextActive"
        }
    }
    if Description then
        ThemeBindings[Description] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        }
    end
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end
    local IsDragging = false
    local Value = DefaultValue or Min
    local function RoundToIncrement(Number)
        return math.floor(Number / Increment + 0.5) * Increment
    end
    local function UpdateSlider(NewValue)
        Value = math.clamp(RoundToIncrement(NewValue), Min, Max)
        local Percent = (Value - Min) / (Max - Min)
        Fill.Size = UDim2.new(Percent, 0, 1, 0)
        Thumb.Position = UDim2.new(Percent, 0, 0.5, 0)
        ValueLabel.Text = tostring(Value)
        SimpleUI.SaveManager:WriteBinding(SaveBinding, Value)
        if Callback then
            EH:Try(function()
                Callback(Value)
            end)
        end
    end
    local function HandleInput(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = true
            local Percent = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            UpdateSlider(Min + (Max - Min) * Percent)
        end
    end
    Track.InputBegan:Connect(HandleInput)
    Thumb.InputBegan:Connect(HandleInput)
    UserInputService.InputChanged:Connect(function(Input)
        if IsDragging and
            (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Percent = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            UpdateSlider(Min + (Max - Min) * Percent)
        end
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = false
        end
    end)
    UpdateSlider(Value)
    return {
        GetValue = function(self)
            return Value
        end,
        SetValue = function(self, NewValue)
            if EH:ValidateType(NewValue, "number", "NewValue", "Slider:SetValue") then
                UpdateSlider(NewValue)
            end
        end,
        SetMin = function(self, NewMin)
            if EH:ValidateType(NewMin, "number", "NewMin", "Slider:SetMin") then
                if NewMin < Max then
                    Min = NewMin
                    UpdateSlider(Value)
                else
                    EH:Guard(false, "Slider:SetMin", "Min must be less than Max", EH.Levels.WARN)
                end
            end
        end,
        SetMax = function(self, NewMax)
            if EH:ValidateType(NewMax, "number", "NewMax", "Slider:SetMax") then
                if NewMax > Min then
                    Max = NewMax
                    UpdateSlider(Value)
                else
                    EH:Guard(false, "Slider:SetMax", "Max must be greater than Min", EH.Levels.WARN)
                end
            end
        end,
        SetDescription = function(self, NewDescription)
            local HadDescription = Description ~= nil and Description.Visible
            local HasNewDescription = NewDescription and NewDescription ~= ""
            if Description and NewDescription then
                Description.Text = NewDescription
                Description.Visible = true
            elseif Description and not NewDescription then
                Description.Visible = false
            elseif not Description and NewDescription then
                Description = SimpleUI.ComponentBuilder:CreateDescription(Zones.TextZone, NewDescription, Theme, 2)
                if Window then
                    SimpleUI.ThemeManager:RegisterElement(Window, Description, {
                        TextColor3 = "TextSecondary",
                        Font = "FontSecondary"
                    })
                end
            end
            if HadDescription ~= HasNewDescription then
                SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasNewDescription)
            end
        end,
        GetElements = function(self)
            return {
                Container = Zones.Container,
                Label = Label,
                ValueLabel = ValueLabel,
                Description = Description,
                Track = Track,
                Fill = Fill,
                Thumb = Thumb
            }
        end
    }
end

function SimpleUI:CreateParagraph(Page, Title, Fields, Options)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateParagraph") then
        return nil
    end
    if not EH:ValidateType(Title, "string", "Title", "CreateParagraph") then
        Title = "Paragraph"
    end
    if Fields and not EH:ValidateType(Fields, "table", "Fields", "CreateParagraph") then
        Fields = {}
    end
    Options = Options or {}
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local Window = self.Utility:GetWindowFromElement(Page)
    local Container = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = Theme.TransparencySecondary,
        BorderSizePixel = 0,
        ZIndex = self.Constants.ZIndex.Control
    }, Page)
    if not Container then
        EH:Guard(false, "CreateParagraph", "Failed to create container", EH.Levels.ERROR)
        return nil
    end
    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, Container)
    self.Utility:CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, self.Constants.Padding.Large),
        PaddingBottom = UDim.new(0, self.Constants.Padding.Large),
        PaddingLeft = UDim.new(0, self.Constants.Padding.Large),
        PaddingRight = UDim.new(0, self.Constants.Padding.Large)
    }, Container)
    local ContentFrame = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Container)
    self.Utility:CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, self.Constants.Spacing.Normal)
    }, ContentFrame)
    local TitleLabel = self.Utility:CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = Title or "Paragraph",
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        LayoutOrder = 0,
        ZIndex = self.Constants.ZIndex.Overlay,
        TextColor3 = Theme.TextActive,
        Font = Theme.FontPrimary
    }, ContentFrame)
    local ThemeBindings = {
        [Container] = {
            BackgroundColor3 = function(Element, CurrentTheme)
                Element.BackgroundColor3 = CurrentTheme.Secondary
            end,
            BackgroundTransparency = function(Element, CurrentTheme)
                Element.BackgroundTransparency = CurrentTheme.TransparencySecondary
            end
        },
        [TitleLabel] = {
            TextColor3 = function(Element, CurrentTheme)
                Element.TextColor3 = CurrentTheme.TextActive
            end,
            Font = "FontPrimary"
        }
    }
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end
    local FieldElements = {}
    local FieldCounter = 0
    local function CreateField(FieldData, LayoutOrder)
        if type(FieldData) ~= "table" and type(FieldData) ~= "string" then
            EH:Guard(false, "Paragraph:CreateField", "Invalid field data type", EH.Levels.WARN)
            return nil
        end
        FieldCounter = FieldCounter + 1
        local FieldId = "Field_" .. FieldCounter
        local IsSubField = FieldData.IsSubField or false
        local FieldText = type(FieldData) == "string" and FieldData or (FieldData.Text or "")
        if not EH:ValidateType(FieldText, "string", "FieldText", "Paragraph:CreateField") then
            FieldText = ""
        end
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        local Field = self.Utility:CreateInstance("TextLabel", {
            Size = UDim2.new(1, IsSubField and -20 or 0, 0, 0),
            Position = IsSubField and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = FieldText,
            TextSize = IsSubField and 13 or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            TextWrapped = true,
            LayoutOrder = LayoutOrder or (FieldCounter + 1),
            ZIndex = self.Constants.ZIndex.Overlay,
            TextColor3 = IsSubField and CurrentTheme.TextSecondary or CurrentTheme.TextActive,
            Font = CurrentTheme.FontSecondary
        }, ContentFrame)
        if not Field then
            EH:Guard(false, "Paragraph:CreateField", "Failed to create field", EH.Levels.WARN)
            return nil
        end
        if Window then
            self.ThemeManager:RegisterElement(Window, Field, {
                TextColor3 = function(Element, CurrentTheme)
                    Element.TextColor3 = IsSubField and CurrentTheme.TextSecondary or CurrentTheme.TextActive
                end,
                Font = "FontSecondary"
            })
        end
        FieldElements[FieldId] = {
            Element = Field,
            Data = type(FieldData) == "table" and FieldData or {
                Text = FieldData,
                IsSubField = false
            },
            Id = FieldId
        }
        return FieldId, Field
    end
    if Fields and type(Fields) == "table" then
        for Index, FieldData in ipairs(Fields) do
            EH:Try(function()
                CreateField(FieldData, Index)
            end)
        end
    end
    return {
        AddField = function(self, Text, IsSubField, Position)
            if not EH:ValidateType(Text, "string", "Text", "Paragraph:AddField") then
                return nil
            end
            return EH:Try(function()
                return CreateField({
                    Text = Text,
                    IsSubField = IsSubField or false
                }, Position or (FieldCounter + 2))
            end)
        end,
        RemoveField = function(self, FieldId)
            if not EH:ValidateType(FieldId, "string", "FieldId", "Paragraph:RemoveField") then
                return false
            end
            if not FieldElements[FieldId] then
                EH:Guard(false, "Paragraph:RemoveField", string.format("Field '%s' not found", FieldId), EH.Levels.WARN)
                return false
            end
            return EH:Try(function()
                FieldElements[FieldId].Element:Destroy()
                FieldElements[FieldId] = nil
                return true
            end, function()
                return false
            end)
        end,
        SetField = function(self, FieldId, Text)
            if not EH:ValidateType(FieldId, "string", "FieldId", "Paragraph:SetField") then
                return false
            end
            if not EH:ValidateType(Text, "string", "Text", "Paragraph:SetField") then
                return false
            end
            if not FieldElements[FieldId] then
                EH:Guard(false, "Paragraph:SetField", string.format("Field '%s' not found", FieldId), EH.Levels.WARN)
                return false
            end
            return EH:Try(function()
                FieldElements[FieldId].Element.Text = Text
                FieldElements[FieldId].Data.Text = Text
                return true
            end, function()
                return false
            end)
        end,
        GetField = function(self, FieldId)
            if not EH:ValidateType(FieldId, "string", "FieldId", "Paragraph:GetField") then
                return nil
            end
            return FieldElements[FieldId] and FieldElements[FieldId].Data.Text or nil
        end,
        FindField = function(self, SearchText)
            if not EH:ValidateType(SearchText, "string", "SearchText", "Paragraph:FindField") then
                return nil
            end
            for Id, FieldData in pairs(FieldElements) do
                if FieldData.Data.Text:find(SearchText, 1, true) then
                    return Id, FieldData.Data.Text
                end
            end
            return nil
        end,
        GetAllFields = function(self)
            local Result = {}
            for Id, FieldData in pairs(FieldElements) do
                table.insert(Result, {
                    Id = Id,
                    Text = FieldData.Data.Text,
                    IsSubField = FieldData.Data.IsSubField
                })
            end
            return Result
        end,
        SetFields = function(self, NewFields)
            if not EH:ValidateType(NewFields, "table", "NewFields", "Paragraph:SetFields") then
                return false
            end
            return EH:Try(function()
                for Id, FieldData in pairs(FieldElements) do
                    FieldData.Element:Destroy()
                end
                FieldElements = {}
                FieldCounter = 0
                if NewFields and type(NewFields) == "table" then
                    for Index, FieldData in ipairs(NewFields) do
                        CreateField(FieldData, Index)
                    end
                end
                return true
            end, function()
                return false
            end)
        end,
        ClearFields = function(self)
            return EH:Try(function()
                for Id, FieldData in pairs(FieldElements) do
                    FieldData.Element:Destroy()
                end
                FieldElements = {}
                FieldCounter = 0
                return true
            end, function()
                return false
            end)
        end,
        SetTitle = function(self, NewTitle)
            if not EH:ValidateType(NewTitle, "string", "NewTitle", "Paragraph:SetTitle") then
                return false
            end
            TitleLabel.Text = NewTitle
            return true
        end,
        GetFieldCount = function(self)
            local Count = 0
            for _ in pairs(FieldElements) do
                Count = Count + 1
            end
            return Count
        end,
        GetElements = function(self)
            return {
                Container = Container,
                ContentFrame = ContentFrame,
                TitleLabel = TitleLabel,
                Fields = FieldElements
            }
        end
    }
end

function SimpleUI:CreateDropdown(Page, Text, Options, DefaultValue, Callback, DropdownOptions)
    local EH = self.ErrorHandler
    if not EH:ValidateInstance(Page, "GuiObject", "CreateDropdown") then
        return nil
    end
    if not EH:ValidateType(Text, "string", "Text", "CreateDropdown") then
        Text = "Dropdown"
    end
    if not EH:ValidateType(Options, "table", "Options", "CreateDropdown") then
        Options = {}
    end
    if #Options == 0 then
        EH:Guard(false, "CreateDropdown", "Options array is empty", EH.Levels.WARN)
    end
    if Callback and not EH:ValidateType(Callback, "function", "Callback", "CreateDropdown") then
        Callback = nil
    end
    DropdownOptions = DropdownOptions or {}
    local Theme = self.ThemeManager:GetCurrentTheme(self.Utility:GetWindowFromElement(Page))
    local IsMobile = self.Utility:IsMobile()
    local Window = self.Utility:GetWindowFromElement(Page)
    local IsMultiSelect = DropdownOptions.MultiSelect or false
    local ChangedEvent = Instance.new("BindableEvent")
    local HasDescription = DropdownOptions.Description and DropdownOptions.Description ~= ""
    local SaveBinding = self.SaveManager:GetBinding(DropdownOptions, "Dropdown", Text)
    if SaveBinding.Enabled then
        if IsMultiSelect and type(SaveBinding.Value) == "table" then
            DefaultValue = SaveBinding.Value
        elseif not IsMultiSelect and type(SaveBinding.Value) == "string" then
            DefaultValue = SaveBinding.Value
        end
    end

    local Zones = self.ComponentBuilder:CreateContainer({
        Parent = Page,
        Layout = "TextLeft",
        TextWidth = 0.55,
        MinHeight = 35,
        Padding = HasDescription and {
            Top = self.Constants.Padding.Large,
            Bottom = self.Constants.Padding.Large,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        } or {
            Top = 2,
            Bottom = 2,
            Left = self.Constants.Padding.Large,
            Right = self.Constants.Padding.Small
        },
        Spacing = HasDescription and self.Constants.Spacing.Tight or 0,
        HasDescription = HasDescription,
        CornerRadius = self.Constants.Corner.Medium,
        ColorTier = "Secondary"
    }, Theme)

    local Label = self.ComponentBuilder:CreateLabel(Zones.TextZone, Text, Theme, {
        ColorTier = "TextPrimary",
        Size = 14,
        Order = 1
    })

    local Description = HasDescription and
                            self.ComponentBuilder:CreateDescription(Zones.TextZone, DropdownOptions.Description, Theme,
            2) or nil

    local DisplayContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0.45, -self.Constants.Padding.Large, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.Constants.ZIndex.Overlay
    }, Zones.Container)

    local Display = self.Utility:CreateInstance("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = self.Constants.ZIndex.Overlay
    }, DisplayContainer)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, Display)

    local DisplayLabel = self.Utility:CreateInstance("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = self.Constants.ZIndex.Modal
    }, Display)

    local Arrow = self.Utility:CreateInstance("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709790948",
        ImageColor3 = Theme.TextPrimary,
        ZIndex = self.Constants.ZIndex.Modal
    }, Display)

    local ThemeBindings = {
        [Zones.Container] = {
            BackgroundColor3 = "Secondary",
            BackgroundTransparency = "TransparencySecondary"
        },
        [Label] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [Display] = {
            BackgroundColor3 = "Tertiary"
        },
        [DisplayLabel] = {
            TextColor3 = "TextPrimary",
            Font = "FontSecondary"
        },
        [Arrow] = {
            ImageColor3 = "TextPrimary"
        }
    }
    if Description then
        ThemeBindings[Description] = {
            TextColor3 = "TextSecondary",
            Font = "FontSecondary"
        }
    end
    if Window then
        self.ThemeManager:RegisterMultiple(Window, ThemeBindings)
    end

    local ScreenGui = Page
    while ScreenGui do
        if ScreenGui:IsA("ScreenGui") then
            break
        end
        ScreenGui = ScreenGui.Parent
    end
    if not ScreenGui then
        EH:Guard(false, "CreateDropdown", "Failed to find ScreenGui parent", EH.Levels.ERROR)
        return nil
    end

    local ListContainer = self.Utility:CreateInstance("Frame", {
        Size = UDim2.new(0, Display.AbsoluteSize.X, 0, 0),
        BackgroundColor3 = Theme.Tertiary,
        BackgroundTransparency = Theme.TransparencyPrimary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = self.Constants.ZIndex.Modal,
        ClipsDescendants = true
    }, ScreenGui)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, ListContainer)

    local SearchBox = self.Utility:CreateInstance("TextBox", {
        Size = UDim2.new(1, -8, 0, 30),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = Theme.TextPrimary,
        PlaceholderColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Theme.FontSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Visible = false,
        ZIndex = self.Constants.ZIndex.Modal + 1
    }, ListContainer)

    self.Utility:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, self.Constants.Corner.Medium)
    }, SearchBox)

    self.Utility:CreateInstance("UIPadding", {
        PaddingLeft = UDim.new(0, self.Constants.Padding.Medium),
        PaddingRight = UDim.new(0, self.Constants.Padding.Medium)
    }, SearchBox)

    if Window then
        self.ThemeManager:RegisterMultiple(Window, {
            [ListContainer] = {
                BackgroundColor3 = "Tertiary",
                BackgroundTransparency = "TransparencyPrimary"
            },
            [SearchBox] = {
                BackgroundColor3 = "Tertiary",
                TextColor3 = "TextPrimary",
                PlaceholderColor3 = "TextSecondary",
                Font = "FontSecondary"
            }
        })
    end

    local ScrollList = self.Utility:CreateInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollBarImageColor3 = Theme.TextSecondary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = self.Constants.ZIndex.Modal + 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, ListContainer)

    self.Utility:CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, self.Constants.Spacing.Tight)
    }, ScrollList)

    self.Utility:CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, IsMobile and 0 or 1),
        PaddingBottom = UDim.new(0, IsMobile and 0 or 1),
        PaddingLeft = UDim.new(0, IsMobile and 0 or 1),
        PaddingRight = UDim.new(0, IsMobile and 0 or 1)
    }, ScrollList)

    local NormalizedOptions, OptionDataMap = self.DropdownManager:NormalizeOptions(Options)
    local SelectedValues = self.DropdownManager:InitializeSelection(DefaultValue, IsMultiSelect, OptionDataMap)
    local IsOpen = false
    local IsToggling = false
    local InputBlocker = nil
    local TargetHeight = 0
    local HasSearch = false
    local InputConnection
    local DisplayState = "Base"

    local function UpdateDisplayColor()
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        local ColorGoal = CurrentTheme.Tertiary
        local ArrowRotation = 0

        if DisplayState == "Hover" then
            ColorGoal = CurrentTheme.TertiaryHover
        elseif DisplayState == "Active" then
            ColorGoal = CurrentTheme.TertiaryActive
            ArrowRotation = 180
        elseif DisplayState == "Pressed" then
            ColorGoal = CurrentTheme.TertiaryPressed
        end

        TweenService:Create(Display, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundColor3 = ColorGoal
        }):Play()

        TweenService:Create(Arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Rotation = ArrowRotation
        }):Play()
    end

    if not IsMobile then
        Display.MouseEnter:Connect(function()
            if not IsOpen then
                DisplayState = "Hover"
                UpdateDisplayColor()
            end
        end)
        Display.MouseLeave:Connect(function()
            if not IsOpen then
                DisplayState = "Base"
                UpdateDisplayColor()
            end
        end)
        Display.MouseButton1Down:Connect(function()
            DisplayState = "Pressed"
            UpdateDisplayColor()
        end)
        Display.MouseButton1Up:Connect(function()
            if not IsOpen then
                DisplayState = "Hover"
            end
            UpdateDisplayColor()
        end)
    end

    local function CloseDropdown()
        if InputBlocker then
            InputBlocker:Destroy()
            InputBlocker = nil
        end
        if not IsOpen then
            return
        end
        IsOpen = false
        DisplayState = "Base"
        UpdateDisplayColor()

        TweenService:Create(ListContainer, TweenInfo.new(self.Constants.Animation.Fast, Enum.EasingStyle.Quad,
            Enum.EasingDirection.In), {
            Size = UDim2.new(0, Display.AbsoluteSize.X, 0, 0)
        }):Play()
        task.wait(self.Constants.Animation.Fast)
        ListContainer.Visible = false
        SearchBox.Text = ""

        if InputConnection then
            InputConnection:Disconnect()
            InputConnection = nil
        end
    end

    local function UpdateDisplay()
        self.DropdownManager:UpdateDisplayText(DisplayLabel, SelectedValues, IsMultiSelect)
    end

    local function SerializeSelection()
        if IsMultiSelect then
            local values = {}
            for OptionText, Selected in pairs(SelectedValues) do
                if Selected then
                    table.insert(values, OptionText)
                end
            end
            table.sort(values)
            return values
        end
        return SelectedValues
    end

    local function FilterOptions(Query)
        Query = Query:lower()
        for _, Child in ipairs(ScrollList:GetChildren()) do
            if Child:IsA("Frame") then
                local OptionButton = Child:FindFirstChild("TextButton")
                if OptionButton then
                    if Query == "" or OptionButton.Text:lower():find(Query, 1, true) then
                        Child.Visible = true
                    else
                        Child.Visible = false
                    end
                end
            end
        end
    end

    local function UpdateListPosition()
        local DisplayPos = Display.AbsolutePosition
        local DisplaySize = Display.AbsoluteSize
        local ScreenSize = ScreenGui.AbsoluteSize
        local BaseMaxHeight = 160
        local Layout = ScrollList:FindFirstChildOfClass("UIListLayout")
        local ContentHeight = Layout and Layout.AbsoluteContentSize.Y + 16 or 0
        HasSearch = ContentHeight > BaseMaxHeight
        SearchBox.Visible = HasSearch

        if HasSearch then
            ScrollList.Size = UDim2.new(1, 0, 1, -38)
            ScrollList.Position = UDim2.new(0, 0, 0, 38)
        else
            ScrollList.Size = UDim2.new(1, 0, 1, 0)
            ScrollList.Position = UDim2.new(0, 0, 0, 0)
        end

        TargetHeight = math.min(BaseMaxHeight, ContentHeight) + (HasSearch and 38 or 0)

        local YPos = DisplayPos.Y + DisplaySize.Y + 4
        if YPos + TargetHeight > ScreenSize.Y then
            YPos = DisplayPos.Y - TargetHeight - 4
        end

        ListContainer.Size = UDim2.new(0, DisplaySize.X, 0, 0)
        ListContainer.Position = UDim2.new(0, DisplayPos.X, 0, YPos)
    end

    local function CreateOption(OptionText, Index)
        local CurrentTheme = Window and self.ThemeManager:GetCurrentTheme(Window) or Theme
        local OptionContainer = self.Utility:CreateInstance("Frame", {
            Size = UDim2.new(1, -8, 0, IsMobile and 24 or 30),
            BackgroundTransparency = 1,
            ZIndex = self.Constants.ZIndex.Modal + 2,
            LayoutOrder = Index
        }, ScrollList)

        local OptionButton = self.Utility:CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = CurrentTheme.Tertiary,
            BorderSizePixel = 0,
            Text = OptionText,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = IsMobile and 8 or 13,
            Font = CurrentTheme.FontSecondary,
            TextTruncate = Enum.TextTruncate.SplitWord,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = self.Constants.ZIndex.Modal + 3
        }, OptionContainer)

        self.Utility:CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, self.Constants.Corner.Small)
        }, OptionButton)

        self.Utility:CreateInstance("UIPadding", {
            PaddingLeft = UDim.new(0, IsMobile and 4 or 6),
            PaddingRight = UDim.new(0, IsMobile and 2 or self.Constants.Padding.Small)
        }, OptionButton)

        local Indicator = self.Utility:CreateInstance("Frame", {
            Size = UDim2.new(0, IsMobile and 1 or 2, 0.35, 0),
            Position = UDim2.new(0, IsMobile and 0.1 or 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = CurrentTheme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = self.Constants.ZIndex.Modal + 4
        }, OptionContainer)

        self.Utility:CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }, Indicator)

        if Window then
            self.ThemeManager:RegisterElement(Window, OptionButton, {
                BackgroundColor3 = "Tertiary",
                TextColor3 = "TextPrimary",
                Font = "FontSecondary"
            })
            self.ThemeManager:RegisterElement(Window, Indicator, {
                BackgroundColor3 = "Accent"
            })
        end

        if IsMultiSelect then
            local function UpdateIndicator()
                Indicator.Visible = SelectedValues[OptionText] or false
            end
            OptionButton.Activated:Connect(function()
                SelectedValues[OptionText] = not SelectedValues[OptionText]
                UpdateIndicator()
                UpdateDisplay()
                local Selected = SimpleUI.DropdownManager:GetSelectedData(SelectedValues, IsMultiSelect, OptionDataMap)
                SimpleUI.SaveManager:WriteBinding(SaveBinding, SerializeSelection())
                if Callback then
                    EH:Try(function()
                        Callback(Selected)
                    end)
                end
                ChangedEvent:Fire(Selected)
            end)
            UpdateIndicator()
        else
            Indicator.Visible = SelectedValues == OptionText
            OptionButton.Activated:Connect(function()
                for _, Child in ipairs(ScrollList:GetChildren()) do
                    if Child:IsA("Frame") then
                        local Ind = Child:FindFirstChild("Frame")
                        if Ind then
                            Ind.Visible = false
                        end
                    end
                end
                SelectedValues = OptionText
                Indicator.Visible = true
                UpdateDisplay()
                CloseDropdown()
                local Selected = SimpleUI.DropdownManager:GetSelectedData(SelectedValues, IsMultiSelect, OptionDataMap)
                SimpleUI.SaveManager:WriteBinding(SaveBinding, SerializeSelection())
                if Callback then
                    EH:Try(function()
                        Callback(Selected)
                    end)
                end
                ChangedEvent:Fire(Selected)
            end)
        end

        if not IsMobile then
            OptionButton.MouseEnter:Connect(function()
                local CurrentTheme = Window and SimpleUI.ThemeManager:GetCurrentTheme(Window) or Theme
                TweenService:Create(OptionButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CurrentTheme.TertiaryHover
                }):Play()
            end)
            OptionButton.MouseLeave:Connect(function()
                local CurrentTheme = Window and SimpleUI.ThemeManager:GetCurrentTheme(Window) or Theme
                TweenService:Create(OptionButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CurrentTheme.Tertiary
                }):Play()
            end)
            OptionButton.MouseButton1Down:Connect(function()
                local CurrentTheme = Window and SimpleUI.ThemeManager:GetCurrentTheme(Window) or Theme
                OptionButton.BackgroundColor3 = CurrentTheme.TertiaryPressed
            end)
            OptionButton.MouseButton1Up:Connect(function()
                local CurrentTheme = Window and SimpleUI.ThemeManager:GetCurrentTheme(Window) or Theme
                OptionButton.BackgroundColor3 = CurrentTheme.TertiaryHover
            end)
        end
    end

    for Index, OptionText in ipairs(NormalizedOptions) do
        CreateOption(OptionText, Index)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        FilterOptions(SearchBox.Text)
    end)

    UpdateDisplay()
    UpdateDisplayColor()

    if SaveBinding.HasValue and SaveBinding.ApplyCallback and Callback then
        EH:Try(function()
            Callback(SimpleUI.DropdownManager:GetSelectedData(SelectedValues, IsMultiSelect, OptionDataMap))
        end)
    end

    Display.Activated:Connect(function()
        if IsToggling then
            return
        end
        IsToggling = true
        if IsOpen then
            CloseDropdown()
        else
            IsOpen = true
            InputBlocker = EH:Try(function()
                return self.Utility:CreateInstance("TextButton", {
                    Name = "DropdownInputBlocker",
                    Size = UDim2.fromScale(1, 1),
                    Position = UDim2.fromScale(0, 0),
                    Text = "",
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    ZIndex = self.Constants.ZIndex.Modal - 1
                }, ScreenGui)
            end)
            if InputBlocker then
                InputBlocker.Activated:Connect(function()
                    CloseDropdown()
                end)
            end
            DisplayState = "Active"
            UpdateDisplayColor()
            UpdateListPosition()
            ListContainer.Visible = true
            TweenService:Create(ListContainer, TweenInfo.new(self.Constants.Animation.Normal, Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out), {
                Size = UDim2.new(0, Display.AbsoluteSize.X, 0, TargetHeight)
            }):Play()
            task.wait()
            InputConnection = UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType ==
                    Enum.UserInputType.Touch then
                    local MousePos = Input.Position
                    local ListPos = ListContainer.AbsolutePosition
                    local ListSize = ListContainer.AbsoluteSize
                    local DisplayPos = Display.AbsolutePosition
                    local DisplaySize = Display.AbsoluteSize
                    local InList = MousePos.X >= ListPos.X and MousePos.X <= ListPos.X + ListSize.X and MousePos.Y >=
                                       ListPos.Y and MousePos.Y <= ListPos.Y + ListSize.Y
                    local InDisplay = MousePos.X >= DisplayPos.X and MousePos.X <= DisplayPos.X + DisplaySize.X and
                                          MousePos.Y >= DisplayPos.Y and MousePos.Y <= DisplayPos.Y + DisplaySize.Y
                    if not InList and not InDisplay and not IsToggling then
                        CloseDropdown()
                    end
                end
            end)
        end
        task.wait(0.1)
        IsToggling = false
    end)

    return {
        GetValue = function(self)
            return SimpleUI.DropdownManager:GetSelectedData(SelectedValues, IsMultiSelect, OptionDataMap)
        end,
        SetValue = function(self, Value)
            if IsMultiSelect then
                SelectedValues = {}
                if EH:ValidateType(Value, "table", "Value", "Dropdown:SetValue") then
                    for _, V in ipairs(Value) do
                        local Normalized = type(V) == "table" and
                                               (V.Text or V.text or V.Label or V.label or tostring(V)) or tostring(V)
                        if OptionDataMap[Normalized] then
                            SelectedValues[Normalized] = true
                        end
                    end
                end
            else
                local Normalized = type(Value) == "table" and
                                       (Value.Text or Value.text or Value.Label or Value.label or tostring(Value)) or
                                       tostring(Value)
                if OptionDataMap[Normalized] then
                    SelectedValues = Normalized
                end
            end
            for _, Child in ipairs(ScrollList:GetChildren()) do
                if Child:IsA("Frame") then
                    local Ind = Child:FindFirstChild("Frame")
                    local Opt = Child:FindFirstChild("TextButton")
                    if Ind and Opt then
                        if IsMultiSelect then
                            Ind.Visible = SelectedValues[Opt.Text] or false
                        else
                            Ind.Visible = SelectedValues == Opt.Text
                        end
                    end
                end
            end
            UpdateDisplay()
            SimpleUI.SaveManager:WriteBinding(SaveBinding, SerializeSelection())
            ChangedEvent:Fire(Value)
            if Callback then
                EH:Try(function()
                    Callback(SimpleUI.DropdownManager:GetSelectedData(SelectedValues, IsMultiSelect, OptionDataMap))
                end)
            end
        end,
        SetOptions = function(self, NewOptions)
            if not EH:ValidateType(NewOptions, "table", "NewOptions", "Dropdown:SetOptions") then
                return
            end
            for _, Child in ipairs(ScrollList:GetChildren()) do
                if Child:IsA("Frame") then
                    Child:Destroy()
                end
            end
            Options = NewOptions
            NormalizedOptions, OptionDataMap = SimpleUI.DropdownManager:NormalizeOptions(Options)
            for Index, OptionText in ipairs(NormalizedOptions) do
                CreateOption(OptionText, Index)
            end
            if IsMultiSelect then
                local ValidSelected = {}
                for Value, Enabled in pairs(SelectedValues) do
                    if OptionDataMap[Value] then
                        ValidSelected[Value] = Enabled
                    end
                end
                SelectedValues = ValidSelected
            else
                if not OptionDataMap[SelectedValues] and NormalizedOptions[1] then
                    SelectedValues = nil
                end
            end
            UpdateDisplay()
        end,
        SetDescription = function(self, NewDescription)
            local HadDescription = Description ~= nil and Description.Visible
            local HasNewDescription = NewDescription and NewDescription ~= ""
            if Description and NewDescription then
                Description.Text = NewDescription
                Description.Visible = true
            elseif Description and not NewDescription then
                Description.Visible = false
            elseif not Description and NewDescription then
                Description = SimpleUI.ComponentBuilder:CreateDescription(Zones.TextZone, NewDescription, Theme, 2)
                if Window then
                    SimpleUI.ThemeManager:RegisterElement(Window, Description, {
                        TextColor3 = "TextSecondary",
                        Font = "FontSecondary"
                    })
                end
            end
            if HadDescription ~= HasNewDescription then
                SimpleUI.ComponentBuilder:UpdateDescriptionPadding(Zones, HasNewDescription)
            end
        end,
        Close = function(self)
            CloseDropdown()
        end,
        GetElements = function(self)
            return {
                Container = Zones.Container,
                Label = Label,
                Description = Description,
                Display = Display,
                DisplayLabel = DisplayLabel,
                Arrow = Arrow,
                ListContainer = ListContainer,
                SearchBox = SearchBox,
                ScrollList = ScrollList
            }
        end,
        Changed = ChangedEvent.Event
    }
end

function SimpleUI:CreateNotification(Options)
    local EH = self.ErrorHandler
    Options = Options or {}
    if not EH:ValidateType(Options, "table", "Options", "CreateNotification") then
        Options = {}
    end

    local Title = Options.Title
    if not EH:ValidateType(Title, "string", "Title", "CreateNotification") then
        Title = "Notification"
    end

    local Description = Options.Description
    if Description and not EH:ValidateType(Description, "string", "Description", "CreateNotification") then
        Description = nil
    end

    local Duration = Options.Duration or 5
    if not EH:ValidateType(Duration, "number", "Duration", "CreateNotification") then
        Duration = 5
    else
        Duration = math.clamp(Duration, 0, 300)
    end

    local Tag = Options.Tag
    if Tag and not EH:ValidateType(Tag, "string", "Tag", "CreateNotification") then
        Tag = nil
    end

    local Type = Options.Type
    if Type and not EH:ValidateType(Type, "string", "Type", "CreateNotification") then
        Type = nil
    end

    local Theme = type(Options.Theme) == "string" and (self.Themes[Options.Theme] or self.Themes.DefaultTheme) or
                      type(Options.Theme) == "table" and Options.Theme or self.Themes.DefaultTheme

    local Color = Options.Color
    if Color and typeof(Color) ~= "Color3" then
        Color = Theme.Accent
    else
        Color = Color or Theme.Accent
    end

    local Callback = Options.Callback
    if Callback and not EH:ValidateType(Callback, "function", "Callback", "CreateNotification") then
        Callback = nil
    end

    local Closable = Options.Closable ~= false

    self.NotificationManager:Initialize()

    local NotificationUI = self.NotificationManager:CreateNotificationUI({
        Title = Title,
        Description = Description,
        Theme = Theme,
        Color = Color,
        Type = Type,
        Tag = Tag,
        Callback = Callback,
        Closable = Closable,
        Duration = Duration
    })

    return {
        Dismiss = function(self)
            SimpleUI.NotificationManager:Dismiss(NotificationUI.Container)
        end,
        SetTitle = function(self, NewTitle)
            if EH:ValidateType(NewTitle, "string", "NewTitle", "Notification:SetTitle") then
                NotificationUI.Title.Text = NewTitle
            end
        end,
        SetDescription = function(self, NewDescription)
            if NotificationUI.Description then
                if NewDescription and
                    EH:ValidateType(NewDescription, "string", "NewDescription", "Notification:SetDescription") then
                    NotificationUI.Description.Text = NewDescription
                    NotificationUI.Description.Visible = true
                else
                    NotificationUI.Description.Visible = false
                end
            end
        end,
        SetTag = function(self, NewTag)
            if EH:ValidateType(NewTag, "string", "NewTag", "Notification:SetTag") and NotificationUI.Tag then
                NotificationUI.Tag.Text = NewTag
            end
        end,
        GetElements = function(self)
            return {
                Container = NotificationUI.Container,
                Card = NotificationUI.Card,
                Title = NotificationUI.Title,
                Description = NotificationUI.Description,
                Tag = NotificationUI.Tag,
                Content = NotificationUI.Content,
                ProgressFill = NotificationUI.ProgressFill
            }
        end
    }
end

-- ================= STANDALONE PREREQUISITES =================

local TaskManager = (function()
local TaskManager = {
    mainTask = nil,
    currentSubTask = nil,
    nextSubTask = nil,
    taskQueue = {},
    isRunning = false
}

function TaskManager:requestTask(taskName, priority)
    priority = priority or 1
    if self.mainTask == taskName then
        return false
    end
    table.insert(self.taskQueue, {
        name = taskName,
        priority = priority,
        timestamp = tick()
    })
    table.sort(self.taskQueue, function(a, b)
        if a.priority == b.priority then
            return a.timestamp < b.timestamp
        end
        return a.priority > b.priority
    end)
    return true
end

function TaskManager:startTask(taskName)
    if self.mainTask and self.mainTask ~= taskName then
        return false
    end
    self.mainTask = taskName
    self.isRunning = true
    return true
end

function TaskManager:finishTask(taskName)
    if self.mainTask == taskName then
        self.mainTask = nil
        self.currentSubTask = nil
        self.nextSubTask = nil
        self.isRunning = false
        if # self.taskQueue > 0 then
            local nextTask = table.remove(self.taskQueue, 1)
            task.wait(1)
        end
    end
end

function TaskManager:pauseTask(taskName)
    if self.mainTask == taskName then
        self.isPaused = true
        return true
    end
    return false
end

function TaskManager:resumeTask(taskName)
    if self.mainTask == taskName then
        self.isPaused = false
        return true
    end
    return false
end

function TaskManager:canRun(taskName)
    return (not self.isRunning or self.mainTask == taskName) and not self.isPaused
end

function TaskManager:waitForTurn(taskName, maxWait)
    maxWait = maxWait or 30
    local startTime = tick()
    while not self:canRun(taskName) and (tick() - startTime) < maxWait do
        task.wait(1)
    end
    return self:canRun(taskName)
end

function TaskManager:setCurrentTask(subtask)
    self.currentSubTask = subtask
end

function TaskManager:setNextTask(subtask)
    self.nextSubTask = subtask
end

function TaskManager:getCurrentTask()
    return self.currentSubTask
end

function TaskManager:getNextTask()
    return self.nextSubTask
end

function TaskManager:getMainTask()
    return self.mainTask
end

function TaskManager:clearSubTasks()
    self.currentSubTask = nil
    self.nextSubTask = nil
end

return TaskManager

end)()

local ShoppingMart = (function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local function getSafeContainer()
    if gethui then
        local success, result = pcall(gethui)
        if success and result then
            return result
        end
    end

    local success, coreGui = pcall(function()
        return self:getService("CoreGui")
    end)
    if success and coreGui then
        return coreGui
    end

    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local playerGui = getSafeContainer()

local Theme = {
    Background = Color3.fromRGB(14, 14, 16),
    Surface = Color3.fromRGB(22, 22, 26),
    SurfaceAlt = Color3.fromRGB(30, 30, 34),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(150, 150, 160),
    Accent = Color3.fromRGB(255, 107, 0),
    AccentDark = Color3.fromRGB(200, 80, 0),
    Success = Color3.fromRGB(52, 199, 89),
    Danger = Color3.fromRGB(255, 59, 48),
    Stroke = Color3.fromRGB(45, 45, 50),
    ShardPrice = Color3.fromRGB(245, 170, 210)
}

local NumberFormatter = {}
NumberFormatter.Suffixes = {{1e21, "Sx"}, {1e18, "Qi"}, {1e15, "Qa"}, {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "k"}}

function NumberFormatter.Format(n)
    n = math.floor(n + 0.5)
    for _, data in ipairs(NumberFormatter.Suffixes) do
        if n >= data[1] then
            local value = math.floor((n / data[1]) * 100) / 100
            local str = tostring(value):gsub("%.0+$", ""):gsub("(%..-)0+$", "%1")
            return str .. data[2]
        end
    end
    return tostring(n)
end

local ItemCatalog = {}

function ItemCatalog.Build()
    local catalog = {
        Pans = {},
        Shovels = {},
        Sluices = {},
        Potions = {},
        Totems = {},
        Others = {}
    }

    local icons = {
        Pans = "rbxassetid://10789587520",
        Shovels = "rbxassetid://10098013519",
        Sluices = "rbxassetid://7964618035",
        Potions = "rbxassetid://16181402439",
        Totems = "rbxassetid://18624930841",
        Utility = "rbxassetid://12392897830"
    }

    local purchRoot = Workspace:FindFirstChild("Purchasable")
    if not purchRoot then
        return catalog
    end

    for _, region in ipairs(purchRoot:GetChildren()) do
        if region:IsA("Folder") and #region:GetChildren() > 0 then
            for _, item in ipairs(region:GetChildren()) do
                if item:IsA("Model") then
                    local shopItem = item:FindFirstChild("ShopItem")
                    if shopItem then
                        local stats = shopItem:FindFirstChild("Stats")
                        if stats then
                            local isShardPrice = shopItem:GetAttribute("Price") == nil and
                                                     shopItem:GetAttribute("ShardPrice") ~= nil
                            local price = shopItem:GetAttribute(isShardPrice and "ShardPrice" or "Price")
                            local description = shopItem:GetAttribute("Description")
                            local category

                            if price then
                                category = ItemCatalog.DetermineCategory(item, stats)
                            else
                                category = "Others"
                            end

                            local iconImage = icons[category] or icons.Utility

                            if price then
                                table.insert(catalog[category], {
                                    name = item.Name,
                                    description = description,
                                    price = price,
                                    currency = isShardPrice and "ƒ" or "$",
                                    category = category,
                                    model = item,
                                    shopItem = shopItem,
                                    iconImage = iconImage
                                })
                            else
                                for attrName, attrValue in pairs(shopItem:GetAttributes()) do
                                    if typeof(attrValue) == "number" and attrName ~= "Price" and attrName ~=
                                        "ShardPrice" then
                                        table.insert(catalog.Others, {
                                            name = item.Name,
                                            description = description,
                                            price = attrValue,
                                            currency = attrName,
                                            category = "Others",
                                            model = item,
                                            shopItem = shopItem,
                                            iconImage = icons.Utility
                                        })
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return catalog
end

local CATEGORY_FOLDERS = {
    Pans = ReplicatedStorage.Items.Pans,
    Totems = ReplicatedStorage.Items.Totems,
    Potions = ReplicatedStorage.Potions,
    Shovels = ReplicatedStorage.Shovels,
    Sluices = ReplicatedStorage.Items.Sluices
}

function ItemCatalog.DetermineCategory(item)
    if not item then
        return "Others"
    end

    local itemNameLower = item.Name:lower()

    for category, folder in pairs(CATEGORY_FOLDERS) do
        if folder then
            for _, child in folder:GetChildren() do
                if child.Name:lower() == itemNameLower then
                    return category
                end
            end
        end
    end

    return "Others"
end

local ShoppingMartClass = {}
ShoppingMartClass.__index = ShoppingMartClass
ShoppingMartClass.buying = false

function ShoppingMartClass.new(uiScale)
    local self = setmetatable({}, ShoppingMartClass)

    self.shoppingCart = {}
    self.selectedCategory = "All"
    self.uiScale = uiScale
    self.gui = nil

    self:CreateUI()

    return self
end

function ShoppingMartClass:CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

function ShoppingMartClass:CreatePadding(all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all)
    padding.PaddingBottom = UDim.new(0, all)
    padding.PaddingLeft = UDim.new(0, all)
    padding.PaddingRight = UDim.new(0, all)
    return padding
end

function ShoppingMartClass:UpdateScrollCanvas(scrollFrame, layout)
    local contentSize = layout.AbsoluteContentSize
    local padding = scrollFrame:FindFirstChildOfClass("UIPadding")
    local padTop = padding and padding.PaddingTop.Offset or 0
    local padBottom = padding and padding.PaddingBottom.Offset or 0
    local buffer = 20
    scrollFrame.CanvasSize = UDim2.fromOffset(0, (contentSize.Y / self.uiScale) + padTop + padBottom + buffer)
end
function ShoppingMartClass:AddToCart(itemData)
    for _, cartItem in ipairs(self.shoppingCart) do
        if cartItem.name == itemData.name then
            cartItem.quantity = cartItem.quantity + 1
            return
        end
    end

    table.insert(self.shoppingCart, {
        name = itemData.name,
        price = itemData.price,
        currency = itemData.currency,
        category = itemData.category,
        model = itemData.model,
        shopItem = itemData.shopItem,
        quantity = 1
    })
end

function ShoppingMartClass:RemoveFromCart(itemName)
    for i, cartItem in ipairs(self.shoppingCart) do
        if cartItem.name == itemName then
            table.remove(self.shoppingCart, i)
            return
        end
    end
end

function ShoppingMartClass:UpdateCartQuantity(itemName, delta)
    for i, cartItem in ipairs(self.shoppingCart) do
        if cartItem.name == itemName then
            cartItem.quantity = math.max(0, cartItem.quantity + delta)
            if cartItem.quantity == 0 then
                table.remove(self.shoppingCart, i)
            end
            return
        end
    end
end

function ShoppingMartClass:CalculateTotals()
    local totals = {}
    for _, cartItem in ipairs(self.shoppingCart) do
        totals[cartItem.currency] = (totals[cartItem.currency] or 0) + (cartItem.price * cartItem.quantity)
    end
    return totals
end

function ShoppingMartClass:GetItemCount()
    local count = 0
    for _, cartItem in ipairs(self.shoppingCart) do
        count = count + cartItem.quantity
    end
    return count
end

function ShoppingMartClass:ClearCart()
    self.shoppingCart = {}
end

function ShoppingMartClass:CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShoppingMartUI_" .. tostring(os.clock())
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.DisplayOrder = 100

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 920, 0, 620)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local scale = Instance.new("UIScale")
    scale.Scale = self.uiScale
    scale.Parent = mainFrame

    self:CreateCorner(16).Parent = mainFrame
    self:CreateTopBar(mainFrame)

    local inputBlocker = Instance.new("TextButton")
    inputBlocker.Name = "InputBlocker"
    inputBlocker.Size = UDim2.new(1, 0, 1, 0)
    inputBlocker.Position = UDim2.new(0, 0, 0, 0)
    inputBlocker.BackgroundTransparency = 1
    inputBlocker.Text = ""
    inputBlocker.AutoButtonColor = false
    inputBlocker.BorderSizePixel = 0
    inputBlocker.Visible = false
    inputBlocker.Parent = mainFrame

    self.inputBlocker = inputBlocker

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -32, 1, -72)
    contentFrame.Position = UDim2.new(0, 16, 0, 64)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0.65, -8, 1, 0)
    leftPanel.BackgroundTransparency = 1
    leftPanel.Parent = contentFrame

    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0.35, -8, 1, 0)
    rightPanel.Position = UDim2.new(0.65, 8, 0, 0)
    rightPanel.BackgroundColor3 = Theme.Surface
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = contentFrame

    self:CreateCorner(12).Parent = rightPanel

    self:CreateCategoryBar(leftPanel)
    self:CreateItemsPanel(leftPanel)
    self:CreateCartPanel(rightPanel)

    screenGui.Parent = playerGui
    self.gui = screenGui

    self:UpdateItemDisplay()
    self:UpdateCart()
end

function ShoppingMartClass:CreateTopBar(parent)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 56)
    topBar.BackgroundColor3 = Theme.Surface
    topBar.BorderSizePixel = 0
    topBar.Parent = parent

    local topCover = Instance.new("Frame")
    topCover.Size = UDim2.new(1, 0, 0, 1)
    topCover.Position = UDim2.new(0, 0, 1, 0)
    topCover.BackgroundColor3 = Theme.AccentDark
    topCover.BorderSizePixel = 0
    topCover.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "WALMART WOHOOO"
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 36, 0, 36)
    closeButton.Position = UDim2.new(1, -46, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(0, 0.5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "x"
    closeButton.TextColor3 = Theme.TextSecondary
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 0
    closeButton.AutoButtonColor = false
    closeButton.Parent = topBar

    self:CreateCorner(8).Parent = closeButton

    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Theme.Accent
        closeButton.TextColor3 = Theme.TextPrimary
    end)

    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = Theme.Surface
        closeButton.TextColor3 = Theme.TextSecondary
    end)

    closeButton.MouseButton1Click:Connect(function()
        self.gui.Enabled = false
    end)

    local UserInputService = game:GetService("UserInputService")

    local dragging, dragStart, startPos = false, nil, nil

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input:GetPropertyChangedSignal("UserInputState"):Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and
            (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
        end
    end)
end

function ShoppingMartClass:CreateCategoryBar(parent)
    local categoryBar = Instance.new("ScrollingFrame")
    categoryBar.Name = "CategoryBar"
    categoryBar.Size = UDim2.new(1, 0, 0, 40)
    categoryBar.BackgroundTransparency = 1
    categoryBar.BorderSizePixel = 0
    categoryBar.ScrollBarThickness = 0
    categoryBar.Active = true
    categoryBar.ScrollingDirection = Enum.ScrollingDirection.X
    categoryBar.CanvasSize = UDim2.new(0, 0, 0, 40)
    categoryBar.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 8)
    layout.Parent = categoryBar

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self:UpdateScrollCanvas(categoryBar, layout)
    end)

    local categories = {"All", "Pans", "Shovels", "Sluices", "Potions", "Totems", "Others"}

    for _, category in ipairs(categories) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 0, 0, 32)
        button.AutomaticSize = Enum.AutomaticSize.X
        button.BackgroundColor3 = category == self.selectedCategory and Theme.Accent or Theme.Surface
        button.Text = category
        button.TextColor3 = category == self.selectedCategory and Theme.TextPrimary or Theme.TextSecondary
        button.TextSize = 13
        button.Font = Enum.Font.GothamBold
        button.BorderSizePixel = 0
        button.Parent = categoryBar

        local padding = self:CreatePadding(0)
        padding.PaddingLeft = UDim.new(0, 14)
        padding.PaddingRight = UDim.new(0, 14)
        padding.Parent = button

        self:CreateCorner(16).Parent = button

        button.MouseButton1Click:Connect(function()
            self.selectedCategory = category
            for _, btn in ipairs(categoryBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = btn.Text == self.selectedCategory and Theme.Accent or Theme.Surface
                    btn.TextColor3 = btn.Text == self.selectedCategory and Theme.TextPrimary or Theme.TextSecondary
                end
            end
            self:UpdateItemDisplay()
        end)
    end
end

function ShoppingMartClass:CreateItemsPanel(parent)
    local itemsScrollFrame = Instance.new("ScrollingFrame")
    itemsScrollFrame.Name = "ItemsScrollFrame"
    itemsScrollFrame.Size = UDim2.new(1, 0, 1, -48)
    itemsScrollFrame.Position = UDim2.new(0, 0, 0, 48)
    itemsScrollFrame.BackgroundTransparency = 1
    itemsScrollFrame.BorderSizePixel = 0
    itemsScrollFrame.ScrollBarThickness = 4
    itemsScrollFrame.ScrollBarImageColor3 = Theme.Stroke
    itemsScrollFrame.Active = true
    itemsScrollFrame.Parent = parent

    local padding = self:CreatePadding(12)
    padding.Parent = itemsScrollFrame

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 170, 0, 210)
    grid.CellPadding = UDim2.new(0, 12, 0, 12)
    grid.SortOrder = Enum.SortOrder.Name
    grid.Parent = itemsScrollFrame

    grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self:UpdateScrollCanvas(itemsScrollFrame, grid)
    end)
end

function ShoppingMartClass:CreateCartPanel(parent)
    local cartTitle = Instance.new("TextLabel")
    cartTitle.Size = UDim2.new(1, -24, 0, 32)
    cartTitle.Position = UDim2.new(0, 12, 0, 12)
    cartTitle.BackgroundTransparency = 1
    cartTitle.Text = "Your Cart"
    cartTitle.TextColor3 = Theme.TextPrimary
    cartTitle.TextSize = 16
    cartTitle.Font = Enum.Font.GothamBold
    cartTitle.TextXAlignment = Enum.TextXAlignment.Left
    cartTitle.Parent = parent

    local cartScrollFrame = Instance.new("ScrollingFrame")
    cartScrollFrame.Name = "CartScrollFrame"
    cartScrollFrame.Size = UDim2.new(1, -24, 1, -180)
    cartScrollFrame.Position = UDim2.new(0, 12, 0, 52)
    cartScrollFrame.BackgroundTransparency = 1
    cartScrollFrame.BorderSizePixel = 0
    cartScrollFrame.Active = true
    cartScrollFrame.ScrollBarThickness = 4
    cartScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 205)
    cartScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    cartScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    cartScrollFrame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = cartScrollFrame

    self:CreateCheckoutFrame(parent)
end

function ShoppingMartClass:CreateCheckoutFrame(parent)
    local checkoutFrame = Instance.new("Frame")
    checkoutFrame.Name = "CheckoutFrame"
    checkoutFrame.Size = UDim2.new(1, -24, 0, 120)
    checkoutFrame.Position = UDim2.new(0, 12, 1, -132)
    checkoutFrame.BackgroundColor3 = Theme.SurfaceAlt
    checkoutFrame.BorderSizePixel = 0
    checkoutFrame.Parent = parent

    self:CreateCorner(12).Parent = checkoutFrame

    local totalLabel = Instance.new("TextLabel")
    totalLabel.Name = "TotalLabel"
    totalLabel.Size = UDim2.new(1, -24, 0, 24)
    totalLabel.Position = UDim2.new(0, 12, 0, 12)
    totalLabel.BackgroundTransparency = 1
    totalLabel.Text = "Total: $0"
    totalLabel.TextColor3 = Theme.TextPrimary
    totalLabel.TextSize = 18
    totalLabel.Font = Enum.Font.GothamBold
    totalLabel.TextXAlignment = Enum.TextXAlignment.Left
    totalLabel.Parent = checkoutFrame

    local itemCountLabel = Instance.new("TextLabel")
    itemCountLabel.Name = "ItemCountLabel"
    itemCountLabel.Size = UDim2.new(1, -24, 0, 18)
    itemCountLabel.Position = UDim2.new(0, 12, 0, 38)
    itemCountLabel.BackgroundTransparency = 1
    itemCountLabel.Text = "0 items"
    itemCountLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
    itemCountLabel.TextSize = 13
    itemCountLabel.Font = Enum.Font.Gotham
    itemCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemCountLabel.Parent = checkoutFrame

    local checkoutButton = Instance.new("TextButton")
    checkoutButton.Name = "CheckoutButton"
    checkoutButton.Size = UDim2.new(1, -24, 0, 44)
    checkoutButton.Position = UDim2.new(0, 12, 0, 64)
    checkoutButton.BackgroundColor3 = Theme.Accent
    checkoutButton.Text = "Checkout"
    checkoutButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkoutButton.TextSize = 15
    checkoutButton.Font = Enum.Font.GothamBold
    checkoutButton.BorderSizePixel = 0
    checkoutButton.Parent = checkoutFrame

    self:CreateCorner(10).Parent = checkoutButton

    checkoutButton.MouseButton1Click:Connect(function()
        self:ProcessCheckout(checkoutButton)
    end)
end

function ShoppingMartClass:CreateItemCard(itemData)
    local card = Instance.new("Frame")
    card.Name = "Item_" .. itemData.name
    card.BackgroundColor3 = Theme.Surface
    card.BorderSizePixel = 0

    self:CreateCorner(16).Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Parent = card

    self:CreatePadding(12).Parent = card

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(1, 0, 0, 70)
    iconFrame.BackgroundColor3 = Theme.SurfaceAlt
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = card

    self:CreateCorner(12).Parent = iconFrame

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = itemData.iconImage or ""
    icon.ImageColor3 = Theme.TextSecondary
    icon.Parent = iconFrame

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 40)
    name.Position = UDim2.new(0, 0, 0, 78)
    name.BackgroundTransparency = 1
    name.Text = itemData.name
    name.TextColor3 = Theme.TextPrimary
    name.TextSize = 14
    name.Font = Enum.Font.GothamBold
    name.TextWrapped = true
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local priceFrame = Instance.new("Frame")
    priceFrame.Size = UDim2.new(1, 0, 0, 24)
    priceFrame.Position = UDim2.new(0, 0, 1, -62)
    priceFrame.BackgroundTransparency = 1
    priceFrame.Parent = card

    local price = Instance.new("TextLabel")
    price.Size = UDim2.new(0.5, 0, 1, 0)
    price.BackgroundTransparency = 1
    price.Text = itemData.currency .. NumberFormatter.Format(itemData.price)
    price.TextColor3 = itemData.currency == "ƒ" and Theme.ShardPrice or Theme.Accent
    price.TextSize = 17
    price.Font = Enum.Font.GothamBold
    price.TextXAlignment = Enum.TextXAlignment.Left
    price.TextTruncate = Enum.TextTruncate.AtEnd
    price.Parent = priceFrame

    local tagLabel = Instance.new("TextLabel")
    tagLabel.Size = UDim2.new(0.5, 0, 1, 0)
    tagLabel.Position = UDim2.new(0.5, 0, 0, 0)
    tagLabel.BackgroundTransparency = 1
    tagLabel.Text = itemData.category
    tagLabel.TextColor3 = Theme.TextSecondary
    tagLabel.TextSize = 11
    tagLabel.Font = Enum.Font.Gotham
    tagLabel.TextXAlignment = Enum.TextXAlignment.Right
    tagLabel.TextTruncate = Enum.TextTruncate.AtEnd
    tagLabel.Parent = priceFrame

    local buyButton = Instance.new("TextButton")
    buyButton.Size = UDim2.new(1, 0, 0, 38)
    buyButton.Position = UDim2.new(0, 0, 1, -38)
    buyButton.BackgroundColor3 = Theme.Accent
    buyButton.Text = "ADD TO CART"
    buyButton.TextColor3 = Theme.TextPrimary
    buyButton.TextSize = 14
    buyButton.Font = Enum.Font.GothamBold
    buyButton.BorderSizePixel = 0
    buyButton.Parent = card

    self:CreateCorner(12).Parent = buyButton

    buyButton.MouseButton1Click:Connect(function()
        self:AddToCart(itemData)
        self:UpdateCart()

        buyButton.Text = "ADDED"
        buyButton.BackgroundColor3 = Theme.Success
        task.wait(1)
        buyButton.Text = "ADD TO CART"
        buyButton.BackgroundColor3 = Theme.Accent
    end)

    return card
end

function ShoppingMartClass:CreateCartItem(cartItem)
    local frame = Instance.new("Frame")
    frame.Name = "CartItem_" .. cartItem.name
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.BackgroundColor3 = Theme.SurfaceAlt
    frame.BorderSizePixel = 0

    self:CreateCorner(10).Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -36, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = cartItem.name
    title.TextColor3 = Theme.TextPrimary
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = frame

    local removeButton = Instance.new("ImageButton")
    removeButton.Size = UDim2.new(0, 14, 0, 14)
    removeButton.Position = UDim2.new(1, -25, 0.2, 0)
    removeButton.Image = "rbxassetid://10747362393"
    removeButton.ImageColor3 = Theme.Danger
    removeButton.BackgroundTransparency = 1
    removeButton.Parent = frame

    removeButton.MouseButton1Click:Connect(function()
        self:RemoveFromCart(cartItem.name)
        self:UpdateCart()
    end)

    local price = Instance.new("TextLabel")
    price.Size = UDim2.new(0.5, 0, 0, 20)
    price.Position = UDim2.new(0, 10, 1, -28)
    price.BackgroundTransparency = 1
    price.Text = cartItem.currency .. NumberFormatter.Format(cartItem.price * cartItem.quantity)
    price.TextColor3 = cartItem.currency == "ƒ" and Theme.ShardPrice or Theme.Accent
    price.TextSize = 15
    price.Font = Enum.Font.GothamBold
    price.TextXAlignment = Enum.TextXAlignment.Left
    price.TextYAlignment = Enum.TextYAlignment.Center
    price.Parent = frame

    local qtyFrame = Instance.new("Frame")
    qtyFrame.Size = UDim2.new(0, 72, 0, 20)
    qtyFrame.Position = UDim2.new(1, -82, 1, -28)
    qtyFrame.BackgroundTransparency = 1
    qtyFrame.Parent = frame

    local minusButton = Instance.new("TextButton")
    minusButton.Size = UDim2.new(0, 20, 1, 0)
    minusButton.BackgroundTransparency = 1
    minusButton.Text = "−"
    minusButton.TextColor3 = Theme.TextPrimary
    minusButton.TextSize = 16
    minusButton.Font = Enum.Font.GothamBold
    minusButton.BorderSizePixel = 0
    minusButton.Parent = qtyFrame

    minusButton.MouseButton1Click:Connect(function()
        self:UpdateCartQuantity(cartItem.name, -1)
        self:UpdateCart()
    end)

    local qtyLabel = Instance.new("TextLabel")
    qtyLabel.Size = UDim2.new(0, 32, 1, 0)
    qtyLabel.Position = UDim2.new(0, 20, 0, 0)
    qtyLabel.BackgroundTransparency = 1
    qtyLabel.Text = tostring(cartItem.quantity)
    qtyLabel.TextColor3 = Theme.TextPrimary
    qtyLabel.TextSize = 14
    qtyLabel.Font = Enum.Font.GothamBold
    qtyLabel.TextXAlignment = Enum.TextXAlignment.Center
    qtyLabel.TextYAlignment = Enum.TextYAlignment.Center
    qtyLabel.Parent = qtyFrame

    local plusButton = Instance.new("TextButton")
    plusButton.Size = UDim2.new(0, 20, 1, 0)
    plusButton.Position = UDim2.new(1, -20, 0, 0)
    plusButton.BackgroundTransparency = 1
    plusButton.Text = "+"
    plusButton.TextColor3 = Theme.TextPrimary
    plusButton.TextSize = 16
    plusButton.Font = Enum.Font.GothamBold
    plusButton.BorderSizePixel = 0
    plusButton.Parent = qtyFrame

    plusButton.MouseButton1Click:Connect(function()
        self:UpdateCartQuantity(cartItem.name, 1)
        self:UpdateCart()
    end)

    return frame
end

function ShoppingMartClass:UpdateCart()
    if not self.gui then
        return
    end

    local cartScrollFrame = self.gui.MainFrame.ContentFrame.RightPanel.CartScrollFrame
    local checkoutFrame = self.gui.MainFrame.ContentFrame.RightPanel.CheckoutFrame

    for _, child in ipairs(cartScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, cartItem in ipairs(self.shoppingCart) do
        local cartItemFrame = self:CreateCartItem(cartItem)
        cartItemFrame.Parent = cartScrollFrame
    end

    local totals = self:CalculateTotals()
    local totalText = ""
    for currency, amount in pairs(totals) do
        if totalText ~= "" then
            totalText = totalText .. " + "
        end
        totalText = totalText .. currency .. NumberFormatter.Format(amount)
    end

    local totalLabel = checkoutFrame:FindFirstChild("TotalLabel")
    local itemCountLabel = checkoutFrame:FindFirstChild("ItemCountLabel")

    if totalLabel then
        totalLabel.Text = "Total: " .. (totalText ~= "" and totalText or "$0")
    end

    if itemCountLabel then
        local count = self:GetItemCount()
        itemCountLabel.Text = count .. " item" .. (count ~= 1 and "s" or "")
    end
end

function ShoppingMartClass:UpdateItemDisplay()
    if not self.gui then
        return
    end

    local itemsScrollFrame = self.gui.MainFrame.ContentFrame.LeftPanel.ItemsScrollFrame

    for _, child in ipairs(itemsScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local catalog = ItemCatalog.Build()

    for category, items in pairs(catalog) do
        if self.selectedCategory == "All" or self.selectedCategory == category then
            for _, itemData in ipairs(items) do
                local card = self:CreateItemCard(itemData)
                card.Parent = itemsScrollFrame
            end
        end
    end
end

function ShoppingMartClass:ProcessCheckout(button)
    if self.buying or #self.shoppingCart == 0 then
        return
    end

    self.buying = true

    button.Text = "Processing..."
    button.BackgroundColor3 = Theme.AccentDark

    for _, cartItem in ipairs(self.shoppingCart) do
        for i = 1, cartItem.quantity do
            if cartItem.shopItem then
                local remote = ReplicatedStorage.Remotes.Shop.BuyItem
                pcall(function()
                    remote:InvokeServer(cartItem.shopItem)
                end)
                task.wait(0.1)
            end
        end
    end

    self:ClearCart()
    self:UpdateCart()

    button.Text = "Completed"
    button.BackgroundColor3 = Theme.Success
    task.wait(1.5)
    button.Text = "Checkout"
    button.BackgroundColor3 = Theme.Accent

    self.buying = false
end

function ShoppingMartClass:Toggle()
    if self.gui then
        self.gui.Enabled = not self.gui.Enabled
    end
end

function ShoppingMartClass:Show()
    if self.gui then
        self.gui.Enabled = true
        self.inputBlocker.Visible = true
    end
end

function ShoppingMartClass:Hide()
    if self.gui then
        self.gui.Enabled = false
        self.inputBlocker.Visible = false
    end
end

return ShoppingMartClass
end)()



SimpleUI:CreateNotification({
    Title = "Validated!",
    Type = "Success",
    Description = "Pre-requisites validated, script will start soon! Powered by SimpleUI",
    Duration = 3
})

SimpleUI:CreateNotification({
    Title = "UI keybind",
    Type = "Info",
    Description = "Default UI visibility toggle is the Q button on PC",
    Duration = 10
})

local Services = {
    Players = SimpleUI.Utility:GetService("Players"),
    ReplicatedStorage = SimpleUI.Utility:GetService("ReplicatedStorage"),
    PathfindingService = SimpleUI.Utility:GetService("PathfindingService"),
    TeleportService = SimpleUI.Utility:GetService("TeleportService"),
    Workspace = SimpleUI.Utility:GetService("Workspace"),
    RunService = SimpleUI.Utility:GetService("RunService"),
    HttpService = SimpleUI.Utility:GetService("HttpService"),
    Lighting = SimpleUI.Utility:GetService("Lighting"),
    VirtualUser = SimpleUI.Utility:GetService("VirtualUser")
}

local Player = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Characters = Services.Workspace:WaitForChild("Characters")
local PlayerGui = Player:WaitForChild("PlayerGui")
local BackpackTwo = Player:WaitForChild("BackpackTwo")
local Map = Services.Workspace:WaitForChild("Map")

local ReplicatedStorage = Services.ReplicatedStorage
local PanningAnimations = ReplicatedStorage.Assets.Animations.Panning
local Excavations = require(ReplicatedStorage.GameInfo.Excavations)
local CraftingRemotes = ReplicatedStorage.Remotes.Crafting

local Character, LocalCharacter, HumanoidRootPart, Humanoid, Animator, WashAnimation

local function bindCharacter(char)
    Character = char
    LocalCharacter = Characters:WaitForChild(Player.Name)
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Animator = Humanoid:WaitForChild("Animator")
    WashAnimation = Animator:LoadAnimation(PanningAnimations.Wash)
end

bindCharacter(Player.Character or Player.CharacterAdded:Wait())
Player.CharacterAdded:Connect(bindCharacter)

local State = {
    AutoFarm = {
        active = false,
        actionMode = "Instant",
        travelMode = "Teleport",
        sandCFrame = nil,
        waterCFrame = nil,
        locked = false,
        interrupted = false,
        interruptReason = nil,
        running = false
    },

    Sell = {
        mode = "Teleport",
        type = "Auto",
        threshold = 300,
        delay = 60,
        autoSell = false,
        _lastSell = nil,
        _scheduledSell = nil
    },

    Excavation = {
        selected = nil,
        data = nil,
        autoClaim = false,
        autoStart = false,
        autoStartRunning = false,
        waiting = false
    },

    Crafting = {
        selectedEquipment = nil,
        selectedMaterials = {},
        discoveredRecipes = {},
        autocraft = false,
        autocraftRunning = false,
        selectBestOres = false
    },

    ESP = {
        Players = {},
        Totems = {},
        Connections = {}
    },

    Barriers = {
        vines = false,
        abyssalGate = false,
        peakObstruction = false
    },

    Pan = {
        current = 0,
        max = 100,
        isFull = false
    },

    Geode = {
        currentIndex = 1,
        autoLoopEnabled = false,
        lastTeleportTime = 0,
        teleportConnection = nil
    },

    Rune = {
        currentIndex = 0,
        autoLoopEnabled = false,
        lastTeleportTime = 0,
        teleportConnection = nil
    },

    Hunting = {
        autoGeode = false,
        autoTreasure = false,
        autoTreasureRunning = false,
        autoTreasurePausedFarm = false
    }
}

local Config = {
    GEODE_AUTO_LOOP_DELAY = 0.01,
    RUNE_AUTO_LOOP_DELAY = 1
}

local Utility = {}
do
    function Utility.createNotification(content, duration)
        SimpleUI:CreateNotification({
            Type = "Default",
            Title = "Notification",
            Description = content or "[DEBUG] TEST",
            Duration = duration or 5
        })
    end

    function Utility.formatPrice(price, isShardPrice)
        local symbol = isShardPrice and "ƒ" or "$"
        local suffixes = {{1e21, "Sx"}, {1e18, "Q"}, {1e15, "qd"}, {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}

        for _, data in ipairs(suffixes) do
            if price >= data[1] then
                return string.format("%s%.1f%s", symbol, price / data[1], data[2])
            end
        end

        return symbol .. tostring(price)
    end

    function Utility.validateSellValue(str)
        if not str or str == "" then
            return nil, nil
        end

        local n, u = str:lower():match("^(%d+)%s*(%a*)$")
        n = tonumber(n)
        if not n then
            return nil, nil
        end
        u = (u or ""):gsub("s+$", "")

        local multipliers = {
            [""] = 1,
            s = 1,
            sec = 1,
            secs = 1,
            second = 1,
            seconds = 1,
            m = 60,
            min = 60,
            mins = 60,
            minute = 60,
            minutes = 60,
            h = 3600,
            hr = 3600,
            hrs = 3600,
            hour = 3600,
            hours = 3600,
            d = 86400,
            day = 86400,
            days = 86400
        }

        if u ~= "" then
            local seconds = n * (multipliers[u] or 0)
            if seconds >= 30 and seconds <= 86400 then
                return seconds, "time"
            end
            return nil, nil
        end

        if n >= 10 and n <= 2000 then
            return n, "value"
        end

        return nil, nil
    end

    function Utility.encodeJSON(value, indentLevel)
        indentLevel = indentLevel or 0
        local indent = string.rep("    ", indentLevel)
        local nextIndent = string.rep("    ", indentLevel + 1)

        if typeof(value) == "table" then
            local isArray = (#value > 0)
            local buffer = {}

            if isArray then
                table.insert(buffer, "[")
                for i, v in ipairs(value) do
                    table.insert(buffer,
                        nextIndent .. Utility.encodeJSON(v, indentLevel + 1) .. (i < #value and "," or ""))
                end
                table.insert(buffer, indent .. "]")
            else
                table.insert(buffer, "{")
                local keys = {}
                for k in pairs(value) do
                    table.insert(keys, k)
                end
                table.sort(keys, function(a, b)
                    return tostring(a) < tostring(b)
                end)

                for i, k in ipairs(keys) do
                    local v = value[k]
                    local keyStr = ("%q"):format(tostring(k))
                    local entry = nextIndent .. keyStr .. ": " .. Utility.encodeJSON(v, indentLevel + 1)
                    if i < #keys then
                        entry = entry .. ","
                    end
                    table.insert(buffer, entry)
                end
                table.insert(buffer, indent .. "}")
            end

            return table.concat(buffer, "\n")
        elseif typeof(value) == "string" then
            return ("%q"):format(value)
        elseif typeof(value) == "boolean" or typeof(value) == "number" then
            return tostring(value)
        elseif value == nil then
            return "null"
        else
            return ("%q"):format("<unsupported>")
        end
    end
end



return SimpleUI
