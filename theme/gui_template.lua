-- PanjeGogo
-- SimpleUI reusable GUI template
-- Copy/rename this file when starting a new script.
-- This file is intentionally independent from Prospecting's gameplay modules.

local SimpleUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/PanjeGogo/Vdo/refs/heads/main/theme/Panjepang.lua"
))()

local GUI = {}

function GUI:Build(context)
    context = context or {}

    local window = SimpleUI:CreateWindow({
        Brand = {
            Name = context.Name or "PanjeGogo"
        },

        DefaultScale = SimpleUI.Utility:IsMobile() and 0.85 or 1.00,
        TabMode = "Dynamic",
        CanResize = true,
        Footer = true,

        FooterItems = {{
            Type = "Text",
            Text = "SimpleUI v" .. SimpleUI.Version,
            ColorTier = "TextSecondary",
            Order = 1
        }},

        StartHidden = false,
        IgnoreGuiInset = false,
        DisplayOrder = 1
    })

    local Tabs = {}

    -- MAIN TAB
    Tabs.Main = SimpleUI:CreateTab(window, "Main", {
        Description = "Main controls",
        Icon = {
            Name = "home"
        },
        DualScroll = true
    })

    local mainPage = Tabs.Main.Page
    local mainLeft = mainPage.Left or mainPage
    local mainRight = mainPage.Right or mainPage

    local controlSection = SimpleUI:CreateSection(mainLeft, "Controls", {
        Description = "Basic controls"
    })

    SimpleUI:CreateButton(
        controlSection.Container,
        "Example Button",
        function()
            SimpleUI:CreateNotification({
                Type = "Info",
                Title = "Example",
                Description = "Button callback berhasil dipanggil.",
                Duration = 3
            })
        end
    )

    SimpleUI:CreateToggle(
        controlSection.Container,
        "Example Toggle",
        false,
        function(enabled)
            SimpleUI:CreateNotification({
                Type = enabled and "Success" or "Info",
                Title = "Toggle",
                Description = enabled and "Toggle aktif." or "Toggle nonaktif.",
                Duration = 2
            })
        end
    )

    local optionSection = SimpleUI:CreateSection(mainRight, "Options", {
        Description = "Input examples"
    })

    local exampleDropdown = SimpleUI:CreateDropdown(
        optionSection.Container,
        "Example Dropdown",
        {"Option A", "Option B", "Option C"},
        "Option A",
        function(value)
            SimpleUI:CreateNotification({
                Type = "Info",
                Title = "Dropdown",
                Description = "Dipilih: " .. tostring(value),
                Duration = 2
            })
        end
    )

    SimpleUI:CreateTextInput(
        optionSection.Container,
        "Example Text",
        "",
        function(value)
            SimpleUI:CreateNotification({
                Type = "Info",
                Title = "Text Input",
                Description = "Value: " .. tostring(value),
                Duration = 2
            })
        end
    )

    local infoSection = SimpleUI:CreateSection(mainRight, "Information", {
        Description = "Dynamic information"
    })

    local infoParagraph = SimpleUI:CreateParagraph(
        infoSection.Container,
        "Status",
        {
            Status = "Ready",
            Mode = "Template"
        }
    )

    -- SETTINGS TAB
    Tabs.Settings = SimpleUI:CreateTab(window, "Settings", {
        Description = "Script settings",
        Icon = {
            Name = "settings"
        }
    })

    local settingsSection = SimpleUI:CreateSection(
        Tabs.Settings.Page,
        "Settings",
        {
            Description = "Example settings section"
        }
    )

    SimpleUI:CreateButton(
        settingsSection.Container,
        "Update Information",
        function()
            if infoParagraph and infoParagraph.SetFields then
                infoParagraph.SetFields({
                    Status = "Updated",
                    Mode = "Template",
                    Time = os.date("%H:%M:%S")
                })
            end
        end
    )

    -- Example for dynamically changing dropdown options.
    if exampleDropdown and exampleDropdown.SetOptions then
        -- Keep the example disabled by default.
        -- Replace this with your own logic when needed.
        context.SetExampleOptions = function(options)
            exampleDropdown.SetOptions(options)
        end
    end

    return {
        Window = window,
        Tabs = Tabs,
        InfoParagraph = infoParagraph,
        SetExampleOptions = context.SetExampleOptions
    }
end

return GUI
