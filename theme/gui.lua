-- PanjeGogo
-- Prospecting GUI
-- GUI layer only; gameplay logic remains in Prospecting-PanjeGogo.lua.

local GUI = {}

function GUI:Build(context)
    context = context or {}
    local SimpleUI = context.SimpleUI
    local PanModule = context.PanModule
    local Movement = context.Movement
    local SellModule = context.SellModule
    local ExcavationModule = context.ExcavationModule
    local GeodeModule = context.GeodeModule
    local RuneModule = context.RuneModule
    local CraftingModule = context.CraftingModule
    local EnchantModule = context.EnchantModule
    local FavouriteModule = context.FavouriteModule
    local ReforgeModule = context.ReforgeModule
    local FireflyModule = context.FireflyModule
    local ESPModule = context.ESPModule
    local InventoryFilterModule = context.InventoryFilterModule
    local AutoFarmModule = context.AutoFarmModule
    local HuntingModule = context.HuntingModule
    local ServerUtilityModule = context.ServerUtilityModule
    local WaypointModule = context.WaypointModule
    local BarrierRemovalModule = context.BarrierRemovalModule
    local CharacterLock = context.CharacterLock
    local MobileUIModule = context.MobileUIModule
    local Modifiers = context.Modifiers

local amazong = ShoppingMart.new(SimpleUI.Utility:IsMobile() and 0.5 or 0.90)

local window = SimpleUI:CreateWindow({
    Brand = {
        Name = "SimpleScripts"
    },
    DefaultScale = SimpleUI.Utility:IsMobile() and 0.85 or 1.00,
    TabMode = "Dynamic",
    CanResize = true,
    Footer = true,
    FooterItems = {{
        Type = "Text",
        Text = "SimpleUI v" .. SimpleUI.Version .. " - discord.gg/5BUTb4vYm3",
        ColorTier = "TextSecondary",
        Order = 1
    }},
    StartHidden = false,
    IgnoreGuiInset = false,
    DisplayOrder = 1
})

local Tabs = {
    Main = SimpleUI:CreateTab(window, "Main", {
        Description = "Auto Farm and Auto Sell",
        Icon = {
            Image = "rbxassetid://10734975692",
            Size = UDim2.new(0, 16, 0, 16),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        },
        DualScroll = true
    }),
    Hunting = SimpleUI:CreateTab(window, "Hunting", {
        Description = "Treasure map hunting and geode opening",
        Icon = {
            Image = "rbxassetid://16898613613",
            Size = UDim2.new(0, 16, 0, 16),
            ImageRectSize = Vector2.new(48, 48),
            ImageRectOffset = Vector2.new(306, 771),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        },
        DualScroll = true
    }),
    Teleport = SimpleUI:CreateTab(window, "Teleport", {
        Description = "Fast travel network, geode locations, and runes",
        Icon = {
            Image = "rbxassetid://16898613777",
            Size = UDim2.new(0, 16, 0, 16),
            ImageRectSize = Vector2.new(48, 48),
            ImageRectOffset = Vector2.new(771, 98),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        },
        DualScroll = true
    }),
    Tools = SimpleUI:CreateTab(window, "Tools", {
        Description = "Equipment reforging and tool enchantment",
        Icon = {
            Image = "rbxassetid://16898613044",
            Size = UDim2.new(0, 16, 0, 16),
            ImageRectSize = Vector2.new(48, 48),
            ImageRectOffset = Vector2.new(771, 955),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        },
        DualScroll = true
    }),
    Crafting = SimpleUI:CreateTab(window, "Crafting", {
        Description = "Equipment crafting and resource conversion",
        Icon = {
            Image = "rbxassetid://10723396542",
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }
    }),
    Favourite = SimpleUI:CreateTab(window, "Favourite", {
        Description = "Favourite valuable items",
        Icon = {
            Image = "rbxassetid://10734966248",
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }
    }),
    Shop = SimpleUI:CreateTab(window, "Shop", {
        Description = "Amazong - Credits: Jeff Bozo",
        Icon = {
            Image = "rbxassetid://10734952479",
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }
    }),
    Miscellaneous = SimpleUI:CreateTab(window, "Miscellaneous", {
        Description = "Excavation sites, environmental barriers, and utilities",
        Icon = {
            Image = "rbxassetid://10734963191",
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        },
        DualScroll = true
    }),
    Settings = SimpleUI:CreateTab(window, "Settings", {
        Description = "Interface customization and control configuration",
        Icon = {
            Image = "rbxassetid://16898613777",
            Size = UDim2.new(0, 16, 0, 16),
            ImageRectSize = Vector2.new(48, 48),
            ImageRectOffset = Vector2.new(771, 257),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }
    })
}

local function initializeMainTab()
    local page = Tabs.Main.Page
    local LeftPage = page.Left
    local RightPage = page.Right

    local AutoFarmSection = SimpleUI:CreateSection(LeftPage, "Auto Farm", {
        Style = "box",
        Icon = "rbxassetid://10789587520",
        DefaultExpanded = true,
        TextSize = 15
    })

    SimpleUI:CreateDropdown(AutoFarmSection.Container, "Movement Method", {"Legit", "Tween", "Teleport"}, "Teleport",
        function(selection)
            State.AutoFarm.travelMode = selection
        end, {
            Save = {
                Key = "prospecting.auto_farm.movement_method"
            }
        })

    SimpleUI:CreateButton(AutoFarmSection.Container, "Save Dig Location", function()
        if PanModule.getRegion(HumanoidRootPart) == "Deposit" then
            State.AutoFarm.sandCFrame = HumanoidRootPart.CFrame
            SimpleUI:CreateNotification({
                Type = "Success",
                Title = "Location Saved",
                Description = "Dig location has been saved successfully.",
                Duration = 5
            })
        else
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Invalid Location",
                Description = "You must stand within a deposit area to save this location.",
                Duration = 5
            })
        end
    end)

    SimpleUI:CreateButton(AutoFarmSection.Container, "Save Washing Location", function()
        if PanModule.getRegion(HumanoidRootPart) == "Water" then
            State.AutoFarm.waterCFrame = HumanoidRootPart.CFrame
            SimpleUI:CreateNotification({
                Type = "Success",
                Title = "Location Saved",
                Description = "Washing location has been saved successfully.",
                Duration = 5
            })
        else
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Invalid Location",
                Description = "You must stand within a water region to save this location.",
                Duration = 5
            })
        end
    end)

    SimpleUI:CreateToggle(AutoFarmSection.Container, "Enable Auto Farm", false, function(state)
        if state then
            AutoFarmModule.start()
        else
            AutoFarmModule.stop()
        end
    end)

    SimpleUI:CreateButton(AutoFarmSection.Container, "Unstuck Character", function()
        CharacterLock.unlock()
    end)

    SimpleUI:CreateButton(AutoFarmSection.Container, "Remove Crocodiles", function()
        BarrierRemovalModule.removeCrocodiles()
    end)

    SimpleUI:CreateParagraph(AutoFarmSection.Container, "How Automated Farm Works",
        {"Configure your movement method, set digging and washing locations, then activate the system to begin the continuous cycle.",
         {
            Text = "Teleport mode is significantly faster and recommended for efficiency.",
            IsSubField = true
        }, {
            Text = "You must stand within the correct region before saving each location to ensure proper positioning.",
            IsSubField = true
        }, {
            Text = "Use Unstuck Character if movement freezes or the tweening animation becomes unresponsive.",
            IsSubField = true
        }})

    local SellSection = SimpleUI:CreateSection(RightPage, "Auto Sell", {
        Style = "box",
        Icon = "rbxassetid://2246496691",
        DefaultExpanded = true,
        TextSize = 15
    })

    SimpleUI:CreateDropdown(SellSection.Container, "Selling Trigger Mode", {"Auto", "Threshold", "Duration"}, "Auto",
        function(selection)
            State.Sell.type = selection
            Utility.createNotification("Selling mode changed to: " .. selection)
        end, {
            Save = {
                Key = "prospecting.sell.trigger_mode"
            }
        })

    SimpleUI:CreateTextInput(SellSection.Container, "Configure Threshold or Duration", nil, function(input)
        local result, kind = Utility.validateSellValue(input)
        if result then
            if kind == "time" then
                State.Sell.delay = result
                Utility.createNotification("Inventory will be sold every " .. result .. " seconds.", 10)
            else
                State.Sell.threshold = result
                Utility.createNotification("Inventory will be sold after collecting " .. result .. " items.", 10)
            end
        else
            Utility.createNotification("Enter a value between 10-2000 items or 30 seconds to 1 day.", 10)
        end
    end, {
        Save = {
            Key = "prospecting.sell.trigger_value"
        }
    })

    SimpleUI:CreateButton(SellSection.Container, "Sell All Items Now", function()
        if TaskManager:getMainTask() then
            return Utility.createNotification("Please wait for the current task to finish before selling.", 5)
        end

        if not TaskManager:requestTask("ManualSell", 3) then
            return Utility.createNotification("Unable to initiate selling sequence.", 5)
        end

        task.spawn(function()
            if TaskManager:waitForTurn("ManualSell", 10) and TaskManager:startTask("ManualSell") then
                TaskManager:setCurrentTask("Selling")
                SellModule.sell({}, State.Sell.mode or "Teleport")
                TaskManager:finishTask("ManualSell")
            end
        end)
    end)

    SimpleUI:CreateToggle(SellSection.Container, "Enable Automatic Selling", false, function(state)
        State.Sell.autoSell = state
        State.Sell._lastSell = State.Sell._lastSell or 0
        State.Sell._scheduledSell = false

        if state then
            task.spawn(function()
                while State.Sell.autoSell do
                    if State.Sell.type == "Duration" then
                        local delay = tonumber(State.Sell.delay) or 300
                        if os.clock() - State.Sell._lastSell >= delay then
                            State.Sell._scheduledSell = true
                        end
                    end
                    task.wait(5)
                end
            end)
        end

        Utility.createNotification(state and "Automatic Selling Enabled" or "Automatic Selling Disabled")
    end)

    SimpleUI:CreateParagraph(SellSection.Container, "Selling Configuration",
        {"Select your selling trigger method and configure the corresponding threshold or duration below.", {
            Text = "Auto Mode: Automatically sells when the backpack UI shows your inventory is full.",
            IsSubField = true
        }, {
            Text = "Threshold Mode: Automatically sells when your inventory reaches a specified item count.",
            IsSubField = true
        }, {
            Text = "Duration Mode: Automatically sells at regular intervals you define.",
            IsSubField = true
        }, {
            Text = "Manual Selling: Waits for the current farming task to complete before initiating the sale.",
            IsSubField = true
        }})
end

local function initializeHuntingTab()
    local page = Tabs.Hunting.Page
    local LeftPage = page.Left
    local RightPage = page.Right

    local TreasureSection = SimpleUI:CreateSection(LeftPage, "Treasure Hunting", {
        Style = "box",
        Icon = "rbxassetid://6947202399",
        DefaultExpanded = true,
        TextSize = 15
    })

    local treasureStatus = SimpleUI:CreateParagraph(TreasureSection.Container, "Hunt Status",
        {"Idle", "No maps detected"})

    local function setTreasureStatus(status, detail)
        treasureStatus:SetFields({"Status: " .. status, detail})
    end

    local function getTreasureStatusText()
        local status = HuntingModule.getTreasureHuntStatus()
        local mapText = status.currentMap and ("Current map: " .. status.currentMap) or "Searching for maps"
        return "Maps completed: " .. status.mapsCompleted, mapText
    end

    local function isAutoFarmWashPending()
        if not (State.AutoFarm.active and State.AutoFarm.running) then
            return false
        end

        local currentTask = TaskManager:getCurrentTask()
        local nextTask = TaskManager:getNextTask()
        if currentTask == "WashPan" or nextTask == "WashPan" then
            return true
        end

        local ok, panStatus = pcall(function()
            return PanModule.getStatus()
        end)

        return ok and panStatus and panStatus.isFull == true
    end

    local function waitForAutoFarmWash()
        if not isAutoFarmWashPending() then
            return true
        end

        local startedAt = tick()
        setTreasureStatus("Waiting", "Pan is ready to wash; finishing wash before treasure hunt")

        while State.Hunting.autoTreasure and isAutoFarmWashPending() do
            if tick() - startedAt > 120 then
                setTreasureStatus("Waiting", "Wash has not completed yet; treasure hunt will retry soon")
                return false
            end
            task.wait(0.5)
        end

        return State.Hunting.autoTreasure
    end

    local function pauseAutoFarmForTreasure()
        if State.Hunting.autoTreasurePausedFarm then
            return true
        end

        if not waitForAutoFarmWash() then
            return false
        end

        if AutoFarmModule.pause("TreasureHunt") then
            State.Hunting.autoTreasurePausedFarm = true
            setTreasureStatus("Pausing Farm", "Treasure map found; auto farm is paused until maps are cleared")
            task.wait(0.35)
        end

        return true
    end

    local function resumeAutoFarmFromTreasure()
        if not State.Hunting.autoTreasurePausedFarm then
            return
        end

        State.Hunting.autoTreasurePausedFarm = false
        if AutoFarmModule.resume("TreasureHunt") and State.AutoFarm.active then
            setTreasureStatus("Resuming Farm", "Treasure maps cleared; auto farm resumed")
            task.wait(0.5)
        end
    end

    SimpleUI:CreateParagraph(TreasureSection.Container, "Treasure Hunt Instructions",
        {"Ensure you have a treasure map in your inventory before starting.", {
            Text = "The system will automatically navigate to the map location and collect items.",
            IsSubField = true
        }, {
            Text = "Hunt completes when the map is consumed.",
            IsSubField = true
        }})

    SimpleUI:CreateButton(TreasureSection.Container, "Start Treasure Hunt", function()
        if State.Hunting.autoTreasure then
            setTreasureStatus("Auto Running", "Disable auto treasure hunt before starting a manual hunt")
            return
        end

        if HuntingModule.isTreasureHunting() then
            setTreasureStatus("Already Running", "Hunt in progress")
            return
        end

        local map = HuntingModule.findNextMap()
        if not map then
            setTreasureStatus("Failed", "No treasure maps found in inventory")
            return
        end

        if HuntingModule.startTreasureHunting() then
            setTreasureStatus("Active", "Hunting in progress")
            task.spawn(function()
                while HuntingModule.isTreasureHunting() do
                    local progress, mapText = getTreasureStatusText()
                    treasureStatus:SetFields({"Status: Active", progress, {
                        Text = mapText,
                        IsSubField = true
                    }})
                    task.wait(1)
                end
                setTreasureStatus("Completed", "Hunt finished - " .. HuntingModule.treasureState.mapsCompleted ..
                    " maps hunted")
            end)
        else
            setTreasureStatus("Failed", "Unable to start hunt")
        end
    end)

    SimpleUI:CreateButton(TreasureSection.Container, "Stop Treasure Hunt", function()
        State.Hunting.autoTreasure = false

        if not HuntingModule.isTreasureHunting() then
            resumeAutoFarmFromTreasure()
            setTreasureStatus("Idle", "No hunt in progress")
            return
        end
        HuntingModule.stopTreasureHunting()
        resumeAutoFarmFromTreasure()
        setTreasureStatus("Stopped", "Hunt halted")
    end)

    SimpleUI:CreateToggle(TreasureSection.Container, "Enable Auto Treasure Hunt", false, function(state)
        State.Hunting.autoTreasure = state

        if not state then
            if HuntingModule.isTreasureHunting() then
                HuntingModule.stopTreasureHunting()
            end
            resumeAutoFarmFromTreasure()
            setTreasureStatus("Idle", "Auto treasure hunt disabled")
            return
        end

        if State.Hunting.autoTreasureRunning then
            setTreasureStatus("Already Running", "Auto treasure hunt is already active")
            return
        end

        State.Hunting.autoTreasureRunning = true
        setTreasureStatus("Starting", "Initializing auto treasure hunt...")

        task.spawn(function()
            while State.Hunting.autoTreasure do
                local ok, err = pcall(function()
                    if HuntingModule.isTreasureHunting() then
                        local progress, mapText = getTreasureStatusText()
                        treasureStatus:SetFields({"Status: Active", progress, {
                            Text = mapText,
                            IsSubField = true
                        }})
                        task.wait(1)
                        return
                    end

                    local map = HuntingModule.findNextMap()
                    if not map then
                        resumeAutoFarmFromTreasure()
                        setTreasureStatus("Waiting", "No treasure maps found, checking again soon")
                        task.wait(3)
                        return
                    end

                    if not pauseAutoFarmForTreasure() then
                        task.wait(2)
                        return
                    end
                    setTreasureStatus("Preparing", "Starting hunt on map: " .. map.Name)
                    task.wait(0.25)

                    if not HuntingModule.startTreasureHunting({
                        PreserveCount = true
                    }) then
                        setTreasureStatus("Retrying", "Could not start hunt yet")
                        task.wait(2)
                        return
                    end

                    local deadline = tick() + 180
                    local lastMapGUID = nil
                    while State.Hunting.autoTreasure and HuntingModule.isTreasureHunting() do
                        local status = HuntingModule.getTreasureHuntStatus()
                        if status.currentMapGUID and status.currentMapGUID ~= lastMapGUID then
                            lastMapGUID = status.currentMapGUID
                            deadline = tick() + 180
                        end

                        local progress, mapText = getTreasureStatusText()
                        treasureStatus:SetFields({"Status: Active", progress, {
                            Text = mapText,
                            IsSubField = true
                        }})

                        if tick() >= deadline then
                            setTreasureStatus("Timeout", "Hunt took too long, restarting cycle")
                            HuntingModule.stopTreasureHunting()
                            break
                        end

                        task.wait(1)
                    end
                end)

                if not ok then
                    warn("AutoTreasure Error: " .. tostring(err))
                    resumeAutoFarmFromTreasure()
                    State.Hunting.autoTreasure = false
                    setTreasureStatus("Error", "Auto treasure hunt stopped after an error")
                    break
                end

                task.wait(0.35)
            end

            if HuntingModule.isTreasureHunting() then
                HuntingModule.stopTreasureHunting()
            end

            resumeAutoFarmFromTreasure()
            State.Hunting.autoTreasure = false
            State.Hunting.autoTreasureRunning = false
            setTreasureStatus("Idle", "Auto treasure hunt disabled")
        end)
    end)

    local GeodeSection = SimpleUI:CreateSection(RightPage, "Geode Extraction", {
        Style = "box",
        Icon = "rbxassetid://9019175526",
        DefaultExpanded = true,
        TextSize = 15
    })

    local geodeStatus = SimpleUI:CreateParagraph(GeodeSection.Container, "Extraction Status",
        {"Idle", "No geodes located"})

    local inventoryDisplay = SimpleUI:CreateParagraph(GeodeSection.Container, "Inventory Status",
        {HuntingModule.getFormattedInventoryStatus()})

    SimpleUI:CreateParagraph(GeodeSection.Container, "Geode Extraction Guide",
        {"Geodes are automatically detected when available in your inventory.", {
            Text = "The system will equip geodes and automate clicking to extract contents.",
            IsSubField = true
        }, {
            Text = "Extraction continues until all geodes are depleted or backpack is full.",
            IsSubField = true
        }})

    SimpleUI:CreateButton(GeodeSection.Container, "Start Geode Opening", function()
        if HuntingModule.isGeodeOpening() then
            geodeStatus:SetFields({"Status: Already Running", "Geode extraction in progress"})
            return
        end

        local hasGeode = HuntingModule.findGeodeInBackpack() ~= nil
        local isEquipped = HuntingModule.isGeodeEquipped()
        local inHotbar = HuntingModule.isGeodeInHotbar()

        if not hasGeode and not isEquipped and not inHotbar then
            geodeStatus:SetFields({"Status: Failed", "No geodes found in inventory, hotbar, or equipped"})
            return
        end

        HuntingModule.updateInventoryCache()

        if HuntingModule.isBackpackFull() then
            geodeStatus:SetFields({"Status: Failed", "Backpack is full, cannot extract geodes"})
            return
        end

        if HuntingModule.startGeodeOpening() then
            geodeStatus:SetFields({"Status: Active", "Opening geodes"})
            inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})

            task.spawn(function()
                while HuntingModule.isGeodeOpening() do
                    inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})
                    task.wait(0.5)
                end
                inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})
            end)
        else
            geodeStatus:SetFields({"Status: Failed", "Unable to start geode opening"})
        end
    end)

    SimpleUI:CreateButton(GeodeSection.Container, "Stop Geode Opening", function()
        if not HuntingModule.isGeodeOpening() then
            geodeStatus:SetFields({"Status: Idle", "No extraction in progress"})
            return
        end

        HuntingModule.stopGeodeOpening()
        geodeStatus:SetFields({"Status: Stopped", "Extraction halted"})
        HuntingModule.updateInventoryCache()
        inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})
    end)

    SimpleUI:CreateButton(GeodeSection.Container, "Sell All Items", function()
        if TaskManager:getMainTask() then
            return Utility.createNotification("Please wait for current task to finish before selling.", 5)
        end

        if not TaskManager:requestTask("ManualSell", 3) then
            return Utility.createNotification("Unable to initiate selling sequence.", 5)
        end

        task.spawn(function()
            if TaskManager:waitForTurn("ManualSell", 10) and TaskManager:startTask("ManualSell") then
                TaskManager:setCurrentTask("Selling")
                SellModule.sell({}, State.Sell.mode or "Teleport")
                TaskManager:finishTask("ManualSell")
            end
        end)
    end)

    SimpleUI:CreateToggle(GeodeSection.Container, "Enable Auto Opening", false, function(state)
        State.Hunting.autoGeode = state

        if state then
            HuntingModule.updateInventoryCache()

            task.spawn(function()
                while State.Hunting.autoGeode do
                    local hasGeode = HuntingModule.findGeodeInBackpack() ~= nil
                    local isEquipped = HuntingModule.isGeodeEquipped()
                    local inHotbar = HuntingModule.isGeodeInHotbar()
                    local isFull = HuntingModule.isBackpackFull()

                    inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})

                    if isFull then
                        if HuntingModule.isGeodeOpening() then
                            HuntingModule.stopGeodeOpening()
                        end
                        geodeStatus:SetFields({"Status: Paused", "Backpack full, waiting for space"})
                    elseif hasGeode or isEquipped or inHotbar then
                        if not HuntingModule.isGeodeOpening() then
                            HuntingModule.startGeodeOpening()
                            geodeStatus:SetFields({"Status: Running", "Auto-opening in progress"})
                        end
                    else
                        if HuntingModule.isGeodeOpening() then
                            HuntingModule.stopGeodeOpening()
                        end
                        geodeStatus:SetFields({"Status: Waiting", "Waiting for geodes to arrive"})

                        if HuntingModule.waitForGeodes(5) then
                            if HuntingModule.startGeodeOpening() then
                                geodeStatus:SetFields({"Status: Running", "Auto-opening in progress"})
                            end
                        end
                    end

                    HuntingModule.updateInventoryCache()
                    task.wait(1)
                end

                if HuntingModule.isGeodeOpening() then
                    HuntingModule.stopGeodeOpening()
                end
                HuntingModule.updateInventoryCache()
                geodeStatus:SetFields({"Status: Idle", "Auto-opening disabled"})
                inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})
            end)
        else
            if HuntingModule.isGeodeOpening() then
                HuntingModule.stopGeodeOpening()
            end
            HuntingModule.updateInventoryCache()
            geodeStatus:SetFields({"Status: Idle", "Auto-opening disabled"})
            inventoryDisplay:SetFields({HuntingModule.getFormattedInventoryStatus()})
        end
    end)
end

local function initializeTeleportTab()
    local page = Tabs.Teleport.Page
    local LeftPage = page.Left
    local RightPage = page.Right

    local WaypointsSection = SimpleUI:CreateSection(LeftPage, "Fast Travel", {
        Style = "box",
        Icon = "rbxassetid://102208106546256",
        DefaultExpanded = true,
        TextSize = 15
    })

    local waypointsDropdown = SimpleUI:CreateDropdown(WaypointsSection.Container, "Select Destination",
        WaypointModule.getList(), nil, function(selection)
            WaypointModule.teleport(selection)
        end, {
            Description = "Choose a waypoint to initiate fast travel. Refresh the list to load newly unlocked destinations."
        })

    SimpleUI:CreateButton(WaypointsSection.Container, "Refresh Destinations", function()
        waypointsDropdown:SetOptions(WaypointModule.getList())
    end)

    SimpleUI:CreateButton(WaypointsSection.Container, "Unlock All Waypoints", function()
        WaypointModule.unlockAll()
    end)

    SimpleUI:CreateButton(WaypointsSection.Container, "Emergency Return", function()
        local waypointFolder = Map:FindFirstChild("Waypoints")
        if waypointFolder then
            ReplicatedStorage.Remotes.Misc.FastTravel:FireServer(waypointFolder["Museum"],
                waypointFolder["Rubble Creek"])
        end
    end, {
        Description = "Instantly return to the starter town in emergencies or when stuck in difficult terrain."
    })

    local GeodesSection = SimpleUI:CreateSection(RightPage, "Geode Locations", {
        Style = "box",
        Icon = "rbxassetid://9019175526",
        DefaultExpanded = false,
        TextSize = 15
    })

    local geodeStatus = SimpleUI:CreateParagraph(GeodesSection.Container, "Geode Scanner", {"Scanning..."})

    local geodes = GeodeModule.getModels()
    geodeStatus:SetFields({#geodes > 0 and ("Found " .. #geodes .. " geodes") or "No geodes found"})

    SimpleUI:CreateButton(GeodesSection.Container, "Teleport to Next Geode", function()
        GeodeModule.teleportToNext(geodeStatus)
    end)

    SimpleUI:CreateToggle(GeodesSection.Container, "Auto Teleport to Geodes", false, function(state)
        State.Geode.autoLoopEnabled = state

        if State.Geode.teleportConnection then
            State.Geode.teleportConnection:Disconnect()
            State.Geode.teleportConnection = nil
        end

        if not state then
            local list = GeodeModule.getModels()
            geodeStatus:SetFields({#list > 0 and ("Found " .. #list .. " geodes") or "No geodes found"})
            return
        end

        geodeStatus:SetFields({"Auto Navigation: Active"})
        State.Geode.lastTeleportTime = tick()

        State.Geode.teleportConnection = Services.RunService.Heartbeat:Connect(function()
            if tick() - State.Geode.lastTeleportTime >= Config.GEODE_AUTO_LOOP_DELAY then
                GeodeModule.teleportToNext(geodeStatus)
                State.Geode.lastTeleportTime = tick()
            end
        end)
    end)

    local RunesSection = SimpleUI:CreateSection(RightPage, "Runes", {
        Style = "box",
        Icon = "rbxassetid://104824630248708",
        DefaultExpanded = false,
        TextSize = 15
    })

    local runeStatus = SimpleUI:CreateParagraph(RunesSection.Container, "Rune Tracker", {"Scanning..."})

    local runes = RuneModule.getList()
    runeStatus:SetFields({#runes > 0 and ("Found " .. #runes .. " runes") or "No runes found"})

    SimpleUI:CreateButton(RunesSection.Container, "Teleport to Next Rune", function()
        RuneModule.teleportToNext(runeStatus)
    end)

    SimpleUI:CreateToggle(RunesSection.Container, "Auto Teleport to Runes", false, function(state)
        State.Rune.autoLoopEnabled = state

        if State.Rune.teleportConnection then
            State.Rune.teleportConnection:Disconnect()
            State.Rune.teleportConnection = nil
        end

        if not state then
            local list = RuneModule.getList()
            runeStatus:SetFields({#list > 0 and ("Found " .. #list .. " runes") or "No runes found"})
            return
        end

        runeStatus:SetFields({"Auto Navigation: Active"})
        State.Rune.lastTeleportTime = tick()

        State.Rune.teleportConnection = Services.RunService.Heartbeat:Connect(function()
            if tick() - State.Rune.lastTeleportTime >= Config.RUNE_AUTO_LOOP_DELAY then
                RuneModule.teleportToNext(runeStatus)
                State.Rune.lastTeleportTime = tick()
            end
        end)
    end)
end

local function initializeToolsTab()
    local page = Tabs.Tools.Page
    local LeftPage = page.Left
    local RightPage = page.Right

    local ReforgeSection = SimpleUI:CreateSection(LeftPage, "Equipment Reforging", {
        Style = "box",
        Icon = "rbxassetid://10516069182",
        DefaultExpanded = true,
        TextSize = 15
    })

    local selectedGUID = nil
    local equipmentInfo = SimpleUI:CreateParagraph(ReforgeSection.Container, "Equipment Details", {})

    local equipmentReforgeDropdown = SimpleUI:CreateDropdown(ReforgeSection.Container, "Choose Equipment", {}, nil,
        function(selection)
            if type(selection) ~= "table" then
                selectedGUID = nil
                ReforgeModule.updateInfo(nil, equipmentInfo)
                return
            end
            selectedGUID = selection.guid
            ReforgeModule.updateInfo(selectedGUID, equipmentInfo)
        end)

    SimpleUI:CreateButton(ReforgeSection.Container, "Load Inventory Equipment", function()
        local equipmentOptions = {}
        local nameCounts = {}

        if BackpackTwo and BackpackTwo.GetChildren then
            for _, child in ipairs(BackpackTwo:GetChildren() or {}) do
                if child and child.GetAttribute and child:GetAttribute("ItemType") == "Equipment" then
                    local baseName = tostring(child.Name or "Unknown")
                    nameCounts[baseName] = (nameCounts[baseName] or 0) + 1

                    local displayName = baseName
                    if nameCounts[baseName] > 1 then
                        displayName = baseName .. " #" .. nameCounts[baseName]
                    end

                    table.insert(equipmentOptions, {
                        text = displayName,
                        guid = child:GetAttribute("GUID")
                    })
                end
            end
        end

        selectedGUID = nil
        pcall(function()
            equipmentReforgeDropdown:SetOptions(equipmentOptions)
        end)
        ReforgeModule.updateInfo(nil, equipmentInfo)
    end)

    SimpleUI:CreateButton(ReforgeSection.Container, "Reforge Selected Equipment", function()
        local guid = ReforgeModule.perform(selectedGUID)
        if guid then
            ReforgeModule.updateInfo(guid, equipmentInfo)
            pcall(function()
                equipmentReforgeDropdown:SetOptions({})
            end)
        end
    end)

    local PanEnchantsSection = SimpleUI:CreateSection(RightPage, "Pan Enchantment", {
        Style = "box",
        Icon = "rbxassetid://87273393473760",
        DefaultExpanded = true,
        TextSize = 15
    })

    local selectedMaterial = "Aurorite"
    local targetPanEnchant = "Prismatic"
    local autoEnchantingPan = {false}

    local PanEnchantRemote = ReplicatedStorage.Remotes.Crafting.Enchant

    SimpleUI:CreateDropdown(PanEnchantsSection.Container, "Enchantment Material", {{
        text = "Aetherite"
    }, {
        text = "Aurorite"
    }}, "Aurorite", function(selection)
        if selection and selection.text then
            selectedMaterial = selection.text
        end
    end)

    SimpleUI:CreateDropdown(PanEnchantsSection.Container, "Target Enchantment", EnchantModule.getNames("pan"), nil,
        function(selection)
            targetPanEnchant = selection
        end, {
            Description = "Select your desired enchantment. Book-exclusive enchantments OBVIOUSLY cannot be obtained through this method."
        })

    SimpleUI:CreateButton(PanEnchantsSection.Container, "Apply Enchantment", function()
        local match = EnchantModule.findPanMaterial(selectedMaterial)
        if not match then
            Utility.createNotification("The selected material was not found in your inventory.", 3)
            return
        end
        EnchantModule.enchant(PanEnchantRemote, match, selectedMaterial)
    end)

    SimpleUI:CreateButton(PanEnchantsSection.Container, "Auto Enchant Until Target", function()
        if autoEnchantingPan[1] then
            autoEnchantingPan[1] = false
            Utility.createNotification("Pan enchantment process has been stopped.", 2)
            return
        end

        autoEnchantingPan[1] = true
        Utility.createNotification("Automatically enchanting pan until " .. targetPanEnchant .. " is achieved.", 3)

        EnchantModule.performAuto(function()
            return EnchantModule.findPanMaterial(selectedMaterial)
        end, PanEnchantRemote, selectedMaterial, targetPanEnchant, autoEnchantingPan)
    end)

    local ShovelEnchantsSection = SimpleUI:CreateSection(RightPage, "Shovel Enchantment", {
        Style = "box",
        Icon = "rbxassetid://10098013519",
        DefaultExpanded = false,
        TextSize = 15
    })

    local selectedShovelModifier = "Iridescent"
    local targetShovelEnchant = "WellBalanced"
    local autoEnchantingShovel = {false}

    local ShovelEnchantRemote = ReplicatedStorage.Remotes.Crafting.EnchantShovel

    SimpleUI:CreateDropdown(ShovelEnchantsSection.Container, "Aetherite Modifier", {{
        text = "Iridescent"
    }, {
        text = "Voidtorn"
    }, {
        text = "Electrified"
    }}, nil, function(sel)
        if sel and sel.text then
            selectedShovelModifier = sel.text
        end
    end)

    SimpleUI:CreateDropdown(ShovelEnchantsSection.Container, "Target Enchantment", EnchantModule.getNames("shovel"),
        nil, function(selection)
            targetShovelEnchant = selection
        end)

    SimpleUI:CreateButton(ShovelEnchantsSection.Container, "Apply Enchantment", function()
        local shovel = EnchantModule.findShovelMaterial(selectedShovelModifier)
        if not shovel then
            Utility.createNotification("The selected Aetherite variant is not in your inventory.", 3)
            return
        end
        EnchantModule.enchant(ShovelEnchantRemote, shovel, selectedShovelModifier .. " Aetherite")
    end)

    SimpleUI:CreateButton(ShovelEnchantsSection.Container, "Auto Enchant Until Target", function()
        if autoEnchantingShovel[1] then
            autoEnchantingShovel[1] = false
            Utility.createNotification("Shovel enchantment process has been stopped.", 2)
            return
        end

        autoEnchantingShovel[1] = true
        Utility.createNotification("Automatically enchanting shovel until " .. targetShovelEnchant .. " is achieved.", 3)

        EnchantModule.performAuto(function()
            return EnchantModule.findShovelMaterial(selectedShovelModifier)
        end, ShovelEnchantRemote, selectedShovelModifier .. " Aetherite", targetShovelEnchant, autoEnchantingShovel)
    end)

    SimpleUI:CreateButton(LeftPage, "Stop All Enchanting", function()
        if autoEnchantingPan then
            autoEnchantingPan[1] = false
        end
        if autoEnchantingShovel then
            autoEnchantingShovel[1] = false
        end
        Utility.createNotification("All active enchantment processes have been terminated.", 3)
    end, {
        Description = "Immediately halts all automatic enchanting for both pan and shovel tools in case of interruption or preference change."
    })
end

local function initializeCraftingTab()
    local page = Tabs.Crafting.Page

    SimpleUI:CreateSection(page, "Equipment Crafting")

    local craftingStatus = SimpleUI:CreateParagraph(page, "Crafting Status",
        {"No equipment selected", "Select an equipment to begin"})

    local function tick()
        local eq = State.Crafting.selectedEquipment
        if not eq then
            craftingStatus:SetFields({"No equipment selected", "Select an equipment to begin"})
            return
        end

        if State.Crafting.selectBestOres then
            State.Crafting.selectedMaterials = CraftingModule.selectBest(eq.Data)
        end

        local fields = CraftingModule.buildFields(eq, State.Crafting.selectedMaterials)
        craftingStatus:SetFields(fields)
    end

    local equipmentDropdown = SimpleUI:CreateDropdown(page, "Select Equipment", {}, nil, function(selection)
        for _, recipe in ipairs(State.Crafting.discoveredRecipes) do
            if recipe.Name == selection then
                State.Crafting.selectedEquipment = recipe
                State.Crafting.selectedMaterials = {}
                tick()
                return
            end
        end
    end)

    SimpleUI:CreateButton(page, "Load Discovered Recipes", function()
        State.Crafting.discoveredRecipes = CraftingModule.getDiscoveredRecipes()
        local options = {}
        for i = 1, #State.Crafting.discoveredRecipes do
            options[#options + 1] = State.Crafting.discoveredRecipes[i].Name
        end
        equipmentDropdown:SetOptions(options)
        Utility.createNotification("Loaded " .. #options .. " recipes", 3)
    end)

    SimpleUI:CreateToggle(page, "Auto Select Best Materials", false, function(state)
        State.Crafting.selectBestOres = state
        tick()
    end, {
        Description = "Automatically select highest quality materials when equipment is chosen"
    })

    SimpleUI:CreateButton(page, "Craft Equipment", function()
        local eq = State.Crafting.selectedEquipment
        if not eq then
            Utility.createNotification("No equipment selected", 3)
            return
        end
        if State.Crafting.selectBestOres then
            State.Crafting.selectedMaterials = CraftingModule.selectBest(eq.Data)
        end
        if not CraftingModule.canCraft(eq.Data, State.Crafting.selectedMaterials) then
            Utility.createNotification("Missing materials", 3)
            return
        end
        local success, result = CraftingModule.craft(eq.Item, State.Crafting.selectedMaterials)
        State.Crafting.selectedMaterials = {}
        task.wait(0.5)
        tick()
        if success then
            Utility.createNotification("Crafted " .. eq.Name .. "!", 3)
        else
            Utility.createNotification("Failed: " .. tostring(result), 3)
        end
    end)

    SimpleUI:CreateToggle(page, "Enable Automatic Crafting", false, function(state)
        State.Crafting.autocraft = state
        if not state or State.Crafting.autocraftRunning then
            return
        end
        State.Crafting.autocraftRunning = true

        task.spawn(function()
            while State.Crafting.autocraft do
                local eq = State.Crafting.selectedEquipment
                if not eq then
                    task.wait(1)
                else
                    if State.Crafting.selectBestOres then
                        State.Crafting.selectedMaterials = CraftingModule.selectBest(eq.Data)
                    end

                    tick()

                    if CraftingModule.canCraft(eq.Data, State.Crafting.selectedMaterials) then
                        local success, result = CraftingModule.craft(eq.Item, State.Crafting.selectedMaterials)
                        State.Crafting.selectedMaterials = {}
                        task.wait(0.5)
                        tick()
                        if success then
                            task.wait(0.5)
                        else
                            Utility.createNotification("Autocraft failed: " .. tostring(result), 3)
                            task.wait(3)
                        end
                    else
                        task.wait(2)
                    end
                end
            end
            State.Crafting.autocraftRunning = false
        end)
    end, {
        Description = "Continuously craft selected equipment when materials are available"
    })

    SimpleUI:CreateSection(page, "Firefly Flare Conversion")

    local fireflyAmount = 1
    local FireflyCrafting = false

    SimpleUI:CreateTextInput(page, "Conversion Amount", "1", function(input)
        local value = tonumber(input)
        if not value or value ~= math.floor(value) or value < 1 or value >= 1000 then
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Invalid Amount",
                Description = "Enter a whole number between 1 and 999."
            })
            return
        end
        fireflyAmount = value
    end, {
        Description = "One Firefly Stone produces one Firefly Flare."
    })

    SimpleUI:CreateButton(page, "Begin Conversion", function()
        if FireflyCrafting then
            SimpleUI:CreateNotification({
                Type = "Warning",
                Title = "Already Converting",
                Description = "Conversion already in progress."
            })
            return
        end
        FireflyCrafting = true
        task.spawn(function()
            FireflyModule.craft(fireflyAmount)
            FireflyCrafting = false
        end)
    end, {
        Description = "Convert Firefly Stones to Firefly Flares at the conversion table."
    })

    SimpleUI:CreateButton(page, "Stop Conversion", function()
        if not FireflyCrafting then
            SimpleUI:CreateNotification({
                Type = "Info",
                Title = "Idle",
                Description = "No conversion running."
            })
            return
        end
        FireflyModule.stop()
        SimpleUI:CreateNotification({
            Type = "Warning",
            Title = "Stopping",
            Description = "Halting conversion."
        })
    end)

    SimpleUI:CreateParagraph(page, "Conversion Requirements",
        {"You must be near the firefly conversion table to begin."})
end

local function initializeFavouriteTab()
    local page = Tabs.Favourite.Page

    SimpleUI:CreateSection(page, "Item Preservation System")

    local selectedModifiers = {}
    local selectedOre = nil
    local autoFavEnabled = false

    SimpleUI:CreateDropdown(page, "Select Modifier(s)", CraftingModule.getModifierNames(), nil, function(values)
        selectedModifiers = {}
        for _, v in pairs(values or {}) do
            table.insert(selectedModifiers, v)
        end
    end, {
        MultiSelect = true
    })

    SimpleUI:CreateButton(page, "Preserve Items By Modifier", function()
        if #selectedModifiers == 0 then
            SimpleUI:CreateNotification({
                Type = "Warning",
                Title = "No Modifiers Selected",
                Description = "Select at least one modifier first."
            })
            return
        end

        for _, item in pairs(BackpackTwo:GetChildren()) do
            for _, modifier in ipairs(selectedModifiers) do
                if FavouriteModule.isValuable(item) and FavouriteModule.matchesModifier(item, modifier) then
                    FavouriteModule.favourite(item)
                    break
                end
            end
        end

        SimpleUI:CreateNotification({
            Type = "Success",
            Title = "Complete",
            Description = "Items with selected modifiers have been preserved."
        })
    end)

    SimpleUI:CreateDropdown(page, "Select Ore Type", CraftingModule.getOreNames(), nil, function(value)
        selectedOre = value
    end)

    SimpleUI:CreateButton(page, "Preserve Items By Ore", function()
        if not selectedOre then
            SimpleUI:CreateNotification({
                Type = "Warning",
                Title = "No Ore Selected",
                Description = "Select an ore type first."
            })
            return
        end

        for _, item in pairs(BackpackTwo:GetChildren()) do
            if FavouriteModule.isValuable(item) and FavouriteModule.matchesOre(item, selectedOre) then
                FavouriteModule.favourite(item)
            end
        end

        SimpleUI:CreateNotification({
            Type = "Success",
            Title = "Complete",
            Description = "All matching ore items have been preserved."
        })
    end)

    SimpleUI:CreateButton(page, "Preserve Ore with Modifiers", function()
        if not selectedOre or #selectedModifiers == 0 then
            SimpleUI:CreateNotification({
                Type = "Warning",
                Title = "Selection Incomplete",
                Description = "Select both an ore type and at least one modifier."
            })
            return
        end

        for _, item in pairs(BackpackTwo:GetChildren()) do
            if FavouriteModule.isValuable(item) and FavouriteModule.matchesOre(item, selectedOre) then
                for _, modifier in ipairs(selectedModifiers) do
                    if FavouriteModule.matchesModifier(item, modifier) then
                        FavouriteModule.favourite(item)
                        break
                    end
                end
            end
        end

        SimpleUI:CreateNotification({
            Type = "Success",
            Title = "Complete",
            Description = "Matching items have been preserved."
        })
    end)

    SimpleUI:CreateToggle(page, "Enable Automatic Preservation", false, function(state)
        autoFavEnabled = state
    end, {
        Description = "Automatically preserve items as they are obtained."
    })

    BackpackTwo.ChildAdded:Connect(function(item)
        if not autoFavEnabled then
            return
        end
        if not FavouriteModule.isValuable(item) then
            return
        end

        if selectedOre and #selectedModifiers > 0 then
            if FavouriteModule.matchesOre(item, selectedOre) then
                for _, modifier in ipairs(selectedModifiers) do
                    if FavouriteModule.matchesModifier(item, modifier) then
                        task.wait(0.1)
                        FavouriteModule.favourite(item)
                        break
                    end
                end
            end
        elseif selectedOre then
            if FavouriteModule.matchesOre(item, selectedOre) then
                task.wait(0.1)
                FavouriteModule.favourite(item)
            end
        elseif #selectedModifiers > 0 then
            for _, modifier in ipairs(selectedModifiers) do
                if FavouriteModule.matchesModifier(item, modifier) then
                    task.wait(0.1)
                    FavouriteModule.favourite(item)
                    break
                end
            end
        end
    end)

    SimpleUI:CreateParagraph(page, "Preservation Guide", {"Select Modifier: Choose which modifiers to protect.",
                                                          "Preserve Items By Modifier: Protects all items with selected modifiers.",
                                                          "Select Ore Type: Choose an ore category.",
                                                          "Preserve Items By Ore: Protects all items of that ore.",
                                                          "Preserve Ore with Modifiers: Requires both ore and modifier selections.",
                                                          "Enable Automatic Preservation: Protects newly obtained items based on your selections."})
end

local function initializeShopTab()
    local page = Tabs.Shop.Page

    SimpleUI:CreateSection(page, "Marketplace")

    SimpleUI:CreateParagraph(page, "Marketplace Access", {"Browse and purchase items from the amazong marketplace."})

    SimpleUI:CreateButton(page, "Open Marketplace", function()
        amazong:Toggle()
    end)
end

local function initializeMiscellaneousTab()
    local page = Tabs.Miscellaneous.Page
    local LeftPage = page.Left
    local RightPage = page.Right

    local ExcavationSection = SimpleUI:CreateSection(LeftPage, "Archaeological Sites", {
        Style = "box",
        Icon = "rbxassetid://14257565324",
        DefaultExpanded = true,
        TextSize = 15
    })

    local excavationStatus = SimpleUI:CreateParagraph(ExcavationSection.Container, "Site Status",
        {"Idle", "No site selected"})

    SimpleUI:CreateDropdown(ExcavationSection.Container, "Select Excavation Site", ExcavationModule.getNames(), nil,
        function(s)
            State.Excavation.selected = s
            excavationStatus:SetFields({"Status: Ready", "Selected: " .. tostring(s)})
        end, {
            Save = {
                Key = "prospecting.excavation.selected_site"
            }
        })

    SimpleUI:CreateButton(ExcavationSection.Container, "Begin Excavation", function()
        if not State.Excavation.selected then
            excavationStatus:SetFields({"Status: Error", "No site selected"})
            return
        end

        local ok, msg = ExcavationModule.start()
        if ok then
            excavationStatus:SetFields({"Status: Running", "Site: " .. State.Excavation.selected})
        else
            excavationStatus:SetFields({"Status: Failed", tostring(msg)})
        end
    end)

    SimpleUI:CreateToggle(ExcavationSection.Container, "Auto Claim Rewards", true, function(state)
        State.Excavation.autoClaim = state
        excavationStatus:SetFields({"Status: " .. (state and "Auto-Claim Enabled" or "Auto-Claim Disabled"),
                                    "Site: " .. tostring(State.Excavation.selected)})

        if not state then
            return
        end

        task.spawn(function()
            while State.Excavation.autoClaim do
                if ExcavationModule.getCurrentStatus() == "Finished" then
                    ExcavationModule.claim()
                end
                task.wait(1)
            end
        end)
    end, {
        Save = {
            Key = "prospecting.excavation.auto_claim"
        }
    })

    SimpleUI:CreateToggle(ExcavationSection.Container, "Auto Start Excavation", false, function(state)
        State.Excavation.autoStart = state

        if not state then
            excavationStatus:SetFields({"Status: Auto-Start Disabled", "Site: " .. tostring(State.Excavation.selected)})
            return
        end

        if State.Excavation.autoStartRunning then
            excavationStatus:SetFields({"Status: Auto-Start Running", "Site: " .. tostring(State.Excavation.selected)})
            return
        end

        State.Excavation.autoStartRunning = true
        excavationStatus:SetFields({"Status: Auto-Start Enabled", "Site: " .. tostring(State.Excavation.selected)})

        task.spawn(function()
            while State.Excavation.autoStart do
                if not State.Excavation.selected then
                    excavationStatus:SetFields({"Status: Waiting", "Select an excavation site to auto-start"})
                    task.wait(2)
                    continue
                end

                local ok, msg = ExcavationModule.autoStartCycle()
                if ok then
                    excavationStatus:SetFields({"Status: Running", "Site: " .. tostring(State.Excavation.selected)})
                elseif msg ~= "Excavation already active." then
                    excavationStatus:SetFields({"Status: Waiting", tostring(msg)})
                end

                task.wait(5)
            end

            State.Excavation.autoStartRunning = false
        end)
    end, {
        Save = {
            Key = "prospecting.excavation.auto_start"
        }
    })

    local PlayerSettingsSection = SimpleUI:CreateSection(LeftPage, "Character Settings", {
        Style = "box",
        Icon = {
            Image = "rbxassetid://16898613869",
            Size = UDim2.new(0, 16, 0, 16),
            ImageRectSize = Vector2.new(48, 48),
            ImageRectOffset = Vector2.new(404, 869)
        },
        DefaultExpanded = false,
        TextSize = 15
    })

    SimpleUI:CreateSection(PlayerSettingsSection.Container, "Humanoid Properties")

    local jumpPower = (Humanoid and Humanoid.JumpPower) or 50
    local walkSpeedValue = Humanoid and Humanoid.WalkSpeed or 16

    local function applySavedHumanoidSettings()
        if not Humanoid then
            return
        end

        Humanoid.WalkSpeed = walkSpeedValue
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = jumpPower
    end

    SimpleUI:CreateSlider(PlayerSettingsSection.Container, "Movement Speed", 0, 100, walkSpeedValue, function(val)
        pcall(function()
            walkSpeedValue = val
            applySavedHumanoidSettings()
        end)
    end, {
        Save = {
            Key = "prospecting.character.walk_speed"
        }
    })

    if Humanoid then
        Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Humanoid.WalkSpeed ~= walkSpeedValue then
                Humanoid.WalkSpeed = walkSpeedValue
            end
        end)
    end

    SimpleUI:CreateSlider(PlayerSettingsSection.Container, "Jump Height", 1, 100, jumpPower, function(val)
        pcall(function()
            jumpPower = val
            applySavedHumanoidSettings()
        end)
    end, {
        Save = {
            Key = "prospecting.character.jump_power"
        }
    })

    if Humanoid then
        Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if Humanoid.JumpPower ~= jumpPower then
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = jumpPower
            end
        end)
    end

    Player.CharacterAdded:Connect(function()
        task.wait(1)
        applySavedHumanoidSettings()
    end)

    SimpleUI:CreateSlider(PlayerSettingsSection.Container, "Camera Field of View", 30, 120, Camera.FieldOfView,
        function(value)
            Camera.FieldOfView = value
        end, {
            Increment = 1,
            Save = {
                Key = "prospecting.character.camera_fov"
            }
        })

    local fogDensity = 0.1
    local atmosphere = Services.Lighting:FindFirstChildWhichIsA("Atmosphere") or
                           Instance.new("Atmosphere", Services.Lighting)

    Services.RunService.RenderStepped:Connect(function()
        if atmosphere then
            atmosphere.Density = math.clamp(fogDensity, 0, 1)
        end
    end)

    SimpleUI:CreateSlider(PlayerSettingsSection.Container, "Environmental Fog Density", 0.30, 1, 0.40, function(value)
        fogDensity = value
    end, {
        Increment = 0.01,
        Save = {
            Key = "prospecting.character.fog_density"
        }
    })

    local RemoveBarriersSection = SimpleUI:CreateSection(RightPage, "Environmental Barriers", {
        Style = "box",
        Icon = {
            Image = "rbxassetid://16898613869",
            Size = UDim2.new(0, 16, 0, 16),
            ImageRectSize = Vector2.new(48, 48),
            ImageRectOffset = Vector2.new(820, 355)
        },
        DefaultExpanded = false,
        TextSize = 15
    })

    SimpleUI:CreateToggle(RemoveBarriersSection.Container, "Disable Vine Blockades", false, function(state)
        State.Barriers.vines = state
        if not BarrierRemovalModule.toggleVines(state) then
            Utility.createNotification("Vine blockades were not found.", 4)
        end
    end, {
        Description = "Temporarily disables vine collision without deleting the objects.",
        Save = {
            Key = "prospecting.barriers.vines"
        }
    })

    SimpleUI:CreateToggle(RemoveBarriersSection.Container, "Disable Abyssal Gate", false, function(state)
        State.Barriers.abyssalGate = state
        if not BarrierRemovalModule.toggleAbyssalGate(state) then
            Utility.createNotification("Abyssal Gate was not found.", 4)
        end
    end, {
        Description = "Temporarily disables the Abyssal Gate collision and can restore it.",
        Save = {
            Key = "prospecting.barriers.abyssal_gate"
        }
    })

    SimpleUI:CreateToggle(RemoveBarriersSection.Container, "Disable Peak Obstruction", false, function(state)
        State.Barriers.peakObstruction = state
        if not BarrierRemovalModule.toggleMountainBlock(state) then
            Utility.createNotification("Peak obstruction was not found.", 4)
        end
    end, {
        Description = "Temporarily disables the summit blockage and can restore it.",
        Save = {
            Key = "prospecting.barriers.peak_obstruction"
        }
    })

    local ServerSection = SimpleUI:CreateSection(RightPage, "Server Management", {
        Style = "box",
        Icon = "rbxassetid://10723405749",
        DefaultExpanded = true,
        TextSize = 15
    })

    SimpleUI:CreateToggle(ServerSection.Container, "Enable Anti-AFK Protection", true, function(state)
        ServerUtilityModule.setupAntiAFK(state)
    end)

    SimpleUI:CreateButton(ServerSection.Container, "Rejoin Current Server", function()
        ServerUtilityModule.rejoin()
    end)

    SimpleUI:CreateButton(ServerSection.Container, "Server Hop", function()
        ServerUtilityModule.serverHop()
    end)

    local EspBox = SimpleUI:CreateSection(RightPage, "ESP", {
        Style = "box",
        DefaultExpanded = false,
        TextSize = 15
    })

    SimpleUI:CreateToggle(EspBox.Container, "Highlight Players", false, function(enabled)
        if enabled then
            ESPModule.enablePlayers()
        else
            ESPModule.disablePlayers()
        end
    end)

    SimpleUI:CreateToggle(EspBox.Container, "Highlight Totems", false, function(enabled)
        if enabled then
            ESPModule.enableTotems()
        else
            ESPModule.disableTotems()
        end
    end)

    SimpleUI:CreateButton(EspBox.Container, "Clear All Highlights", function()
        ESPModule.clearAll()
    end)
end

local function initializeSettingsTab()
    local page = Tabs.Settings.Page

    SimpleUI:CreateSection(page, "Interface Customization")

    SimpleUI:CreateToggle(page, "Enable Inventory Filtering", true, function(state)
        if state then
            InventoryFilterModule.create()
        else
            InventoryFilterModule.destroy()
        end
    end, {
        Save = {
            Key = "prospecting.settings.inventory_filter"
        }
    })

    SimpleUI:CreateSlider(page, "Interface Scale", 0.5, 2, window.GetScale(), function(value)
        window:SetScale(value, true)
    end, {
        Increment = 0.001,
        Save = {
            Key = "prospecting.settings.interface_scale"
        }
    })

    local themes = {}
    for name in pairs(SimpleUI.Themes) do
        themes[#themes + 1] = name
    end

    SimpleUI:CreateDropdown(page, "Select Color Theme", themes, nil, function(val)
        window:SetTheme(val, true)
    end, {
        Description = "Choose from " .. (#themes > 0 and #themes or "a variety of") .. " available themes.",
        Save = {
            Key = "prospecting.settings.theme"
        }
    })

    if not SimpleUI.Utility:IsMobile() then
        SimpleUI:CreateKeybind(page, "Toggle Interface Visibility", Enum.KeyCode.Q, function(key)
            window.Toggle()
        end, {
            Save = {
                Key = "prospecting.settings.toggle_keybind"
            }
        })
    end
end

initializeMainTab()
initializeHuntingTab()
initializeTeleportTab()
initializeToolsTab()
initializeCraftingTab()
initializeFavouriteTab()
initializeShopTab()
initializeMiscellaneousTab()
initializeSettingsTab()

if SimpleUI.Utility:IsMobile() then
    MobileUIModule.createToggleButton(window)
end

end


return GUI
