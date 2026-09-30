-- PanjeGogo
local SimpleUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PanjeGogo/Vdo/refs/heads/main/theme/Panjepang.lua"))()

local PanModule = {}
do
    function PanModule.equipPan()
        local function findPan(container)
            for _, v in ipairs(container:GetChildren()) do
                if v:GetAttribute("ItemType") == "Pan" then
                    return v
                end
            end
        end

        local pan = findPan(Character) or findPan(Player.Backpack) or findPan(BackpackTwo)
        if pan then
            ReplicatedStorage.Remotes.CustomBackpack.EquipRemote:FireServer(pan)
            return pan
        end
        return nil
    end

    function PanModule.getStatus()
        local ToolUI = PlayerGui:WaitForChild("ToolUI")
        local FillingPan = ToolUI:WaitForChild("FillingPan")
        local FillText = FillingPan:WaitForChild("FillText")

        local function getDefaultStatus()
            return {
                current = 0,
                max = 100,
                isFull = false,
                isEmpty = true
            }
        end

        local function cleanAndParseNumber(raw, fallback)
            if not raw then
                return fallback
            end
            local cleaned = string.gsub(string.gsub(string.gsub(tostring(raw), ",", ""), " ", ""), "%s+", "")
            if cleaned == "" then
                return fallback
            end
            local parsed = tonumber(cleaned)
            return parsed and math.max(0, math.floor(parsed)) or fallback
        end

        if not FillText or not FillText.ContentText then
            return getDefaultStatus()
        end

        local contentText = tostring(FillText.ContentText)
        if contentText == "" then
            return getDefaultStatus()
        end

        local fillNumbers = string.split(contentText, "/")
        if not fillNumbers or #fillNumbers < 2 then
            return getDefaultStatus()
        end

        local current = cleanAndParseNumber(fillNumbers[1], 0)
        local max = math.max(1, cleanAndParseNumber(fillNumbers[2], 100))

        return {
            current = current,
            max = max,
            isFull = current >= max,
            isEmpty = current <= 0
        }
    end

    function PanModule.getRegion(rootPart)
        local PointToRegion = require(ReplicatedStorage.Modules.Location.PointToRegion)
        local region, _ = PointToRegion.GetPanningRegion(rootPart.Position)
        return region
    end

    function PanModule.handleAction(mode, actionType, executeToCompletion, killSwitch)
        executeToCompletion = executeToCompletion or false

        local function validatePan()
            local pan = PanModule.equipPan()
            local folder = pan and pan:FindFirstChild("Scripts")
            if not folder then
                Utility.createNotification("No Pan found.")
                return nil
            end

            local scripts = {}
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                    scripts[child.Name] = child
                end
            end

            if next(scripts) then
                return scripts
            else
                Utility.createNotification("Pan has no scripts.")
                return nil
            end
        end

        local function isInValidRegion(forWhat)
            return Character and Character:FindFirstChild("HumanoidRootPart") and
                       PanModule.getRegion(Character.HumanoidRootPart) == forWhat
        end

        local function shakeUntilNotPanning(shakeScript, killSwitch)
            while LocalCharacter:GetAttribute("Panning") do
                if killSwitch and not killSwitch() then
                    return false
                end
                pcall(function()
                    shakeScript:FireServer()
                end)
                task.wait()
            end
            return true
        end

        local function fillToCompletion(collectScript)
            local scripts = validatePan()
            local shakeScript = scripts and scripts.Shake

            while task.wait() do
                if killSwitch and not killSwitch() then
                    return "KILLED"
                end

                if LocalCharacter:GetAttribute("Panning") then
                    if shakeScript and not shakeUntilNotPanning(shakeScript, killSwitch) then
                        return "KILLED"
                    end
                end

                local status = PanModule.getStatus()
                if status and status.isFull then
                    break
                end

                if not isInValidRegion("Deposit") then
                    break
                end

                pcall(function()
                    collectScript:InvokeServer(1, true)
                end)
            end

            return (not killSwitch or killSwitch()) and "SUCCESS" or "KILLED"
        end

        local function executeSingle(collectScript)
            if killSwitch and not killSwitch() then
                return "KILLED"
            end
            pcall(function()
                collectScript:InvokeServer(1, true)
            end)
            return "SUCCESS"
        end

        local function emptyToCompletion(shakeScript)
            while task.wait() do
                if killSwitch and not killSwitch() then
                    WashAnimation:Stop()
                    return "KILLED"
                end

                if not shakeUntilNotPanning(shakeScript, killSwitch) then
                    WashAnimation:Stop()
                    return "KILLED"
                end

                local status = PanModule.getStatus()
                if not status or status.isEmpty then
                    break
                end

                pcall(function()
                    shakeScript:FireServer()
                end)
            end

            WashAnimation:Stop()
            return (not killSwitch or killSwitch()) and "SUCCESS" or "KILLED"
        end

        local handlers = {
            Dig = function()
                if killSwitch and not killSwitch() then
                    return "KILLED"
                end

                local scripts = validatePan()
                if not scripts then
                    return "FAIL"
                end

                local collectScript = scripts.Collect
                if not collectScript then
                    return "FAIL"
                end

                local status = PanModule.getStatus()
                if status and status.isFull then
                    return "SUCCESS"
                end

                if mode == "Legit" then
                    Utility.createNotification("Legit mode is Work In Progress!")
                    return "FAIL"
                elseif mode == "Instant" then
                    if executeToCompletion then
                        return fillToCompletion(collectScript)
                    else
                        return executeSingle(collectScript)
                    end
                end

                return "FAIL"
            end,

            Wash = function()
                if killSwitch and not killSwitch() then
                    return "KILLED"
                end

                local scripts = validatePan()
                if not scripts then
                    return "FAIL"
                end

                local shakeScript = scripts.Shake
                local panScript = scripts.Pan

                if not shakeScript or not panScript then
                    return "FAIL"
                end

                local status = PanModule.getStatus()
                if status and status.isEmpty then
                    return "SUCCESS"
                end

                pcall(function()
                    panScript:InvokeServer()
                end)

                return emptyToCompletion(shakeScript)
            end
        }

        local handler = handlers[actionType]
        if not handler then
            Utility.createNotification("Invalid action type! Use 'Dig' or 'Wash'.")
            return "FAIL"
        end

        local ok, result = pcall(handler)
        if not ok then
            warn("PanAction failed: " .. tostring(result))
            return "FAIL"
        end

        return result or "SUCCESS"
    end
end

local Movement = {}
do
    function Movement.tweenToTarget(target, config)
        local player = Services.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        config = config or {}
        local offset = config.Offset or Vector3.new(0, 0, 0)
        local stopDist = config.StopDistance or 20
        local speed = config.Speed or 24
        local cruiseHeight = config.CruiseHeight or 25
        local minHeight = config.MinHeight or 15
        local maxHeight = config.MaxHeight or 100
        local agentRadius = config.AgentRadius or 3
        local longDistanceThreshold = config.LongDistanceThreshold or 150
        local directFlightThreshold = config.DirectFlightThreshold or 50
        local waypointDistance = config.WaypointDistance or 12
        local smoothness = config.Smoothness or 0.5
        local landingDuration = config.LandingDuration or 1.2
        local hoverDuration = config.HoverDuration or 0.3
        local pathTimeout = config.PathTimeout or 8
        local maxTimeout = config.MaxTimeout or 45
        local adaptiveHeight = config.AdaptiveHeight ~= false
        local useDirectFlight = config.UseDirectFlight ~= false

        local isActive = true
        local waypoints = {}
        local currentWaypointIndex = 1
        local lastWaypointTime = tick()
        local startTime = tick()
        local isLanding = false
        local currentHeight = cruiseHeight
        local bg, bv, bp
        local originalPlatformStand

        local TweenService = SimpleUI.Utility:GetService("TweenService")

        local function setNoclip(state)
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = not state
                end
            end

            if humanoid then
                if state then
                    originalPlatformStand = humanoid.PlatformStand
                    humanoid.PlatformStand = true
                else
                    if originalPlatformStand ~= nil then
                        humanoid.PlatformStand = originalPlatformStand
                    end
                end
            end
        end

        local function cleanup()
            isActive = false
            if bg then
                bg:Destroy()
            end
            if bv then
                bv:Destroy()
            end
            if bp then
                bp:Destroy()
            end
            setNoclip(false)
            if humanoid and originalPlatformStand ~= nil then
                humanoid.PlatformStand = originalPlatformStand
            end
        end

        local function toVector3(t)
            if typeof(t) == "Vector3" then
                return t
            elseif typeof(t) == "Instance" and t:IsA("BasePart") then
                return t.Position
            elseif typeof(t) == "CFrame" then
                return t.Position
            elseif typeof(t) == "table" then
                if t.Position then
                    return t.Position
                elseif t.X and t.Y and t.Z then
                    return Vector3.new(t.X, t.Y, t.Z)
                end
            end
            error("Invalid target type")
        end

        local function getOptimalHeight(position, targetPos)
            if not adaptiveHeight then
                return currentHeight
            end

            local distance = (targetPos - position).Magnitude
            local terrainHeight = 0

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist

            local result = Services.Workspace:Raycast(position, Vector3.new(0, -200, 0), rayParams)
            if result then
                terrainHeight = result.Position.Y
            end

            local baseHeight = math.max(minHeight, terrainHeight + 10)

            if distance > longDistanceThreshold then
                return math.min(maxHeight, baseHeight + 30)
            elseif distance > 75 then
                return math.min(cruiseHeight + 15, baseHeight + 20)
            else
                return math.min(cruiseHeight, baseHeight + 15)
            end
        end

        local function hasObstaclesBetween(start, destination, checkHeight)
            local direction = (destination - start)
            local distance = direction.Magnitude
            local unit = direction.Unit

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist

            local checkPoints = math.max(3, math.floor(distance / 10))

            for i = 1, checkPoints do
                local checkPos = start + unit * (distance * i / checkPoints)
                checkPos = Vector3.new(checkPos.X, checkPos.Y + checkHeight, checkPos.Z)

                local directions = {Vector3.new(0, 0, 0), Vector3.new(agentRadius, 0, 0),
                                    Vector3.new(-agentRadius, 0, 0), Vector3.new(0, 0, agentRadius),
                                    Vector3.new(0, 0, -agentRadius), Vector3.new(0, agentRadius, 0),
                                    Vector3.new(0, -agentRadius, 0)}

                for _, dir in pairs(directions) do
                    local testPos = checkPos + dir
                    local result = Services.Workspace:Raycast(testPos, Vector3.new(0, -checkHeight - 10, 0), rayParams)
                    if result and result.Position.Y > testPos.Y - 5 then
                        return true
                    end

                    local ceilingResult = Services.Workspace:Raycast(testPos, Vector3.new(0, 10, 0), rayParams)
                    if ceilingResult and ceilingResult.Position.Y < testPos.Y + 6 then
                        return true
                    end

                    local forwardRay = Services.Workspace:Raycast(testPos, unit * 10, rayParams)
                    if forwardRay then
                        return true
                    end
                end
            end

            return false
        end

        local function canDirectFly(start, destination)
            if not useDirectFlight then
                return false
            end

            local distance = (destination - start).Magnitude
            if distance > directFlightThreshold then
                return false
            end

            return not hasObstaclesBetween(start, destination, currentHeight)
        end

        local function createPath(destination)
            local startPos = hrp.Position
            local targetPos = destination

            currentHeight = getOptimalHeight(startPos, targetPos)

            if canDirectFly(startPos, targetPos) then
                return {{
                    Position = startPos
                }, {
                    Position = Vector3.new(targetPos.X, targetPos.Y + currentHeight, targetPos.Z),
                    Action = Enum.PathWaypointAction.Walk
                }}
            end

            local groundStart = Vector3.new(startPos.X, startPos.Y, startPos.Z)
            local groundTarget = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)

            local path = Services.PathfindingService:CreatePath({
                AgentRadius = agentRadius,
                AgentHeight = 6,
                AgentCanJump = false,
                AgentCanClimb = false,
                WaypointSpacing = math.max(8, waypointDistance),
                Costs = {
                    Danger = math.huge
                }
            })

            local success, err = pcall(function()
                path:ComputeAsync(groundStart, groundTarget)
            end)

            if success and path.Status == Enum.PathStatus.Success then
                local pathWaypoints = path:GetWaypoints()
                local modifiedWaypoints = {}

                for i, waypoint in ipairs(pathWaypoints) do
                    local elevatedPos = Vector3.new(waypoint.Position.X, waypoint.Position.Y + currentHeight,
                        waypoint.Position.Z)
                    table.insert(modifiedWaypoints, {
                        Position = elevatedPos,
                        Action = waypoint.Action
                    })
                end

                return modifiedWaypoints
            else
                local direction = (targetPos - startPos)
                local distance = direction.Magnitude
                local unit = direction.Unit

                local fallbackWaypoints = {}
                table.insert(fallbackWaypoints, {
                    Position = startPos,
                    Action = Enum.PathWaypointAction.Walk
                })

                local midPoint = startPos + unit * (distance * 0.5)
                local highMidPoint = Vector3.new(midPoint.X, midPoint.Y + currentHeight + 20, midPoint.Z)
                table.insert(fallbackWaypoints, {
                    Position = highMidPoint,
                    Action = Enum.PathWaypointAction.Walk
                })

                table.insert(fallbackWaypoints, {
                    Position = Vector3.new(targetPos.X, targetPos.Y + currentHeight, targetPos.Z),
                    Action = Enum.PathWaypointAction.Walk
                })

                return fallbackWaypoints
            end
        end

        local function initializePhysics()
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(4000, 4000, 4000)
            bg.P = 3000
            bg.D = 500
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp

            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp

            bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(4000, 4000, 4000)
            bp.P = 3000
            bp.D = 500
            bp.Position = hrp.Position + Vector3.new(0, currentHeight, 0)
            bp.Parent = hrp
        end

        local function performLanding(targetPos)
            if isLanding then
                return
            end
            isLanding = true

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist

            local groundResult = Services.Workspace:Raycast(targetPos, Vector3.new(0, -200, 0), rayParams)
            local landingY = groundResult and groundResult.Position.Y + 3 or targetPos.Y

            local hoverPos = Vector3.new(targetPos.X, targetPos.Y + 8, targetPos.Z)
            bp.Position = hoverPos
            task.wait(hoverDuration)

            local finalPos = Vector3.new(targetPos.X, landingY, targetPos.Z)

            local landingTween = TweenService:Create(bp, TweenInfo.new(landingDuration, Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out), {
                Position = finalPos
            })

            local velocityTween = TweenService:Create(bv, TweenInfo.new(landingDuration * 0.8, Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out), {
                Velocity = Vector3.new(0, 0, 0)
            })

            landingTween:Play()
            velocityTween:Play()

            landingTween.Completed:Connect(function()
                task.wait(0.3)
                setNoclip(false)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        end

        local function updatePath(destination)
            waypoints = createPath(destination)
            currentWaypointIndex = 1
            lastWaypointTime = tick()
            return waypoints ~= nil
        end

        local function detectObstacles(position, direction, distance)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist

            local obstacles = {}
            local checkDistance = math.min(distance, 10)

            local rayDirections = {direction, direction:Cross(Vector3.new(0, 1, 0)).Unit * 0.3 + direction * 0.954,
                                   direction:Cross(Vector3.new(0, -1, 0)).Unit * 0.3 + direction * 0.954}

            for i, rayDir in pairs(rayDirections) do
                local result = Services.Workspace:Raycast(position, rayDir * checkDistance, rayParams)
                if result and result.Distance > 2 then
                    table.insert(obstacles, {
                        position = result.Position,
                        normal = result.Normal,
                        distance = result.Distance,
                        direction = i
                    })
                end
            end

            local upwardRay = Services.Workspace:Raycast(position, Vector3.new(0, 10, 0), rayParams)
            if upwardRay and upwardRay.Distance < 8 then
                table.insert(obstacles, {
                    position = upwardRay.Position,
                    normal = upwardRay.Normal,
                    distance = upwardRay.Distance,
                    direction = "ceiling"
                })
            end

            return obstacles
        end

        local function calculateAvoidanceVector(obstacles, currentDirection)
            if #obstacles == 0 then
                return Vector3.new(0, 0, 0)
            end

            local avoidanceVector = Vector3.new(0, 0, 0)
            local totalWeight = 0

            for _, obstacle in pairs(obstacles) do
                if obstacle.distance < 2 then
                    local weight = (2 - obstacle.distance) / 6
                    weight = weight * 0.3

                    local pushDirection = obstacle.normal
                    if obstacle.direction == "ceiling" then
                        pushDirection = Vector3.new(0, -1, 0)
                    elseif pushDirection.Y < 0.2 then
                        pushDirection = pushDirection + Vector3.new(0, 0.4, 0)
                        pushDirection = pushDirection.Unit
                    end

                    avoidanceVector = avoidanceVector + (pushDirection * weight)
                    totalWeight = totalWeight + weight
                end
            end

            if totalWeight > 0 then
                avoidanceVector = avoidanceVector / totalWeight
                avoidanceVector = avoidanceVector * math.min(0.4, totalWeight)
            end

            return avoidanceVector
        end

        local function moveToWaypoint(waypoint)
            local currentPos = hrp.Position
            local targetPos = waypoint.Position
            local direction = (targetPos - currentPos)
            local distance = direction.Magnitude

            if distance <= waypointDistance then
                currentWaypointIndex = currentWaypointIndex + 1
                lastWaypointTime = tick()
                return true
            end

            local baseDirection = direction.Unit
            local obstacles = detectObstacles(currentPos, baseDirection, distance)
            local avoidanceVector = calculateAvoidanceVector(obstacles, baseDirection)

            local finalDirection = baseDirection + avoidanceVector
            finalDirection = finalDirection.Unit

            local velocity = finalDirection * speed
            local currentVel = bv.Velocity
            local smoothedVel = currentVel:lerp(velocity, smoothness)

            bv.Velocity = smoothedVel
            bp.Position = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)

            local lookDirection = Vector3.new(smoothedVel.X, 0, smoothedVel.Z)
            if lookDirection.Magnitude > 0.1 then
                local targetCFrame = CFrame.lookAt(currentPos, currentPos + lookDirection)
                bg.CFrame = bg.CFrame:lerp(targetCFrame, smoothness)
            end

            return false
        end

        local finalTarget = toVector3(target) + offset

        initializePhysics()
        setNoclip(true)

        if not updatePath(finalTarget) then
            cleanup()
            if config.OnComplete then
                config.OnComplete(false, "Initial pathfinding failed")
            end
            return
        end

        local conn = Services.RunService.Heartbeat:Connect(function()
            if not isActive then
                return
            end

            if typeof(target) == "Instance" and target:IsA("BasePart") then
                local newTarget = target.Position + offset
                if (newTarget - finalTarget).Magnitude > 10 then
                    finalTarget = newTarget
                    updatePath(finalTarget)
                end
            end

            local currentPos = hrp.Position
            local distToTarget = (finalTarget - currentPos).Magnitude

            if distToTarget <= stopDist then
                performLanding(finalTarget)
                task.wait(landingDuration + hoverDuration)
                cleanup()
                if config.OnComplete then
                    config.OnComplete(true, "Target reached successfully")
                end
                return
            end

            if tick() - startTime > maxTimeout then
                cleanup()
                if config.OnComplete then
                    config.OnComplete(false, "Maximum timeout exceeded")
                end
                return
            end

            if tick() - lastWaypointTime > pathTimeout then
                if not updatePath(finalTarget) then
                    cleanup()
                    if config.OnComplete then
                        config.OnComplete(false, "Path recalculation failed")
                    end
                    return
                end
            end

            if currentWaypointIndex <= #waypoints then
                moveToWaypoint(waypoints[currentWaypointIndex])
            else
                if distToTarget > stopDist then
                    if not updatePath(finalTarget) then
                        local direction = (finalTarget - currentPos).Unit
                        bv.Velocity = bv.Velocity:lerp(direction * speed, smoothness)
                        bp.Position = finalTarget + Vector3.new(0, currentHeight, 0)
                    end
                end
            end
        end)

        return {
            connection = conn,
            stop = function()
                cleanup()
            end,
            setSpeed = function(newSpeed)
                speed = math.max(5, math.min(50, newSpeed))
            end,
            setTarget = function(newTarget)
                target = newTarget
                finalTarget = toVector3(newTarget) + offset
                updatePath(finalTarget)
            end,
            getProgress = function()
                if #waypoints == 0 then
                    return 0
                end
                return math.min(1, currentWaypointIndex / #waypoints)
            end,
            getCurrentHeight = function()
                return currentHeight
            end,
            getDistanceRemaining = function()
                return (finalTarget - hrp.Position).Magnitude
            end,
            getETA = function()
                local distance = (finalTarget - hrp.Position).Magnitude
                return distance / speed
            end,
            isActive = function()
                return isActive
            end,
            pause = function()
                if bv then
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            end,
            resume = function()
            end,
            result = (hrp.Position - finalTarget).Magnitude <= stopDist
        }
    end

    function Movement.walkToTarget(target, config)
        config = config or {}
        local character = Player.Character or Player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        local route = config.Route or {target.Position or target}
        local stopDist = config.StopDistance or 5
        local shouldContinue = config.ShouldContinue or function()
            return true
        end

        for _, point in ipairs(route) do
            if not shouldContinue() then
                return false
            end

            local position
            if typeof(point) == "Vector3" then
                position = point
            elseif typeof(point) == "CFrame" then
                position = point.Position
            elseif typeof(point) == "table" and point.Position then
                position = point.Position
            end

            if position then
                local done = false
                local reached = false
                local connection
                connection = humanoid.MoveToFinished:Connect(function(ok)
                    reached = ok
                    done = true
                end)

                humanoid:MoveTo(position)

                local timeout = math.max(6, (hrp.Position - position).Magnitude / math.max(humanoid.WalkSpeed, 8) + 4)
                local elapsed = 0
                while not done and elapsed < timeout and shouldContinue() do
                    if (hrp.Position - position).Magnitude <= stopDist then
                        reached = true
                        break
                    end
                    task.wait(0.1)
                    elapsed = elapsed + 0.1
                end

                if connection then
                    connection:Disconnect()
                end

                if not shouldContinue() or not reached then
                    return false
                end
            end
        end

        return true
    end

    function Movement.teleportToTarget(target, options)
        local character = Player.Character or Player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local targetPos
        if typeof(target) == "Vector3" then
            targetPos = target
        elseif typeof(target) == "Instance" and target:IsA("BasePart") then
            targetPos = target.Position
        else
            error("Invalid target type")
        end

        options = options or {}
        local mode = options.Mode or "Standard"
        local fireRemoteFunc = options.FireRemoteFunc
        local timeout = options.Timeout or 10
        local tpWaitTime = options.TeleportWaitTime or 0.03
        local maxFiresPerTeleport = options.MaxFiresPerTeleport or 10
        local offsetRange = options.OffsetRange or 0.25
        local exitDelay = options.ExitDelay or 0.2
        local onComplete = options.OnComplete
        local rubberBandTolerance = options.RubberBandTolerance or 12
        local rubberBandWaitTime = options.RubberBandWaitTime or 0.3

        local success = false

        local function handleRubberBand(expectedPos)
            local currentPos = hrp.Position
            local distance = (currentPos - expectedPos).Magnitude

            if distance > rubberBandTolerance then
                if (currentPos - expectedPos).Magnitude > 350 then
                    SimpleUI:CreateNotification({
                        Type = "Default",
                        Title = "Notification",
                        Description = "Distance is too long, try again while being closer to the target",
                        Duration = 10
                    })
                    return false
                end

                local tweenConfig = {
                    CruiseHeight = 6,
                    MinHeight = 1,
                    MaxHeight = 10,
                    LongDistanceThreshold = 150,
                    DirectFlightThreshold = 50,
                    AdaptiveHeight = true,
                    UseDirectFlight = true,
                    HoverDuration = 0,
                    LandingDuration = 1.2,
                    StopDistance = 10,
                    OnComplete = function(tweenSuccess, message)
                        if typeof(onComplete) == "function" then
                            onComplete(tweenSuccess)
                        end
                    end
                }

                Movement.tweenToTarget(expectedPos, tweenConfig)
                return true
            end

            return false
        end

        if mode == "Standard" then
            local maxAttempts = 10
            local tolerance = 10

            for attempt = 1, maxAttempts do
                hrp.CFrame = CFrame.new(targetPos)
                local startTime = tick()
                local settled = false

                task.wait(rubberBandWaitTime)
                if handleRubberBand(targetPos) then
                    return true
                end

                while tick() - startTime < 1 do
                    task.wait(0.05)
                    local distance = (hrp.Position - targetPos).Magnitude

                    if distance <= tolerance then
                        local stableStart = tick()
                        local stable = true

                        while tick() - stableStart < 0.2 do
                            task.wait(0.05)
                            if (hrp.Position - targetPos).Magnitude > tolerance then
                                if handleRubberBand(targetPos) then
                                    return true
                                end
                                stable = false
                                break
                            end
                        end

                        if stable then
                            settled = true
                            success = true
                            break
                        end
                    end
                end

                if success then
                    break
                end
                if attempt < maxAttempts then
                    task.wait(0.2)
                end
            end

            if success then
                task.wait(rubberBandWaitTime)
                if handleRubberBand(targetPos) then
                    return true
                end
            end

        elseif mode == "Critical" then
            if typeof(fireRemoteFunc) ~= "function" then
                error("Critical mode requires FireRemoteFunc")
            end

            local originalPos = hrp.Position
            local startTime = tick()
            local remoteRunning = true

            local remoteThread = task.spawn(function()
                while task.wait() do
                    local ok, result = pcall(fireRemoteFunc)
                    if ok and typeof(result) == "number" and result > 0 then
                        success = true
                        hrp.CFrame = CFrame.new(originalPos)
                        break
                    end
                end
            end)

            while tick() - startTime < timeout and not success do
                for i = 1, 15 do
                    if success then
                        break
                    end

                    local offset = Vector3.new(math.random() * offsetRange - offsetRange / 2, math.random(5, 10),
                        math.random() * offsetRange - offsetRange / 2)

                    hrp.CFrame = CFrame.new(targetPos + offset)
                    task.wait()
                end

                hrp.CFrame = CFrame.new(originalPos)
                task.wait(1)
            end

            if remoteThread then
                task.cancel(remoteThread)
            end

            hrp.CFrame = CFrame.new(originalPos)
        end

        if typeof(onComplete) == "function" then
            onComplete(success)
        end

        return success
    end
end

local CharacterLock = {}
do
    local storedValues = {}

    function CharacterLock.lock(targetCFrame)
        local char = Player.Character
        if not char then
            return
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end

        hrp.CFrame = targetCFrame
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            storedValues[Player.UserId] = {
                WalkSpeed = hum.WalkSpeed,
                JumpPower = hum.JumpPower
            }

            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum:ChangeState(Enum.HumanoidStateType.Seated)
        end
    end

    function CharacterLock.unlock()
        local char = Player.Character
        if not char then
            return
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local values = storedValues[Player.UserId] or {
                WalkSpeed = 16,
                JumpPower = 50
            }

            hum.WalkSpeed = values.WalkSpeed
            hum.JumpPower = values.JumpPower
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            storedValues[Player.UserId] = nil
        end
    end
end

local MerchantModule = {}
do
    function MerchantModule.isMerchant(npc)
        local imgPass = false
        local icon = npc:FindFirstChild("IconUI")
        local img = icon and icon:FindFirstChild("ImageLabel")
        if img and img.Image == "rbxassetid://2246496691" then
            imgPass = true
        end

        local objPass = false
        local dialog = npc:FindFirstChild("Dialog")
        if dialog and dialog.ClassName == "ObjectValue" and dialog.Value and dialog.Value.Name == "Seller" then
            objPass = true
        end

        return imgPass and objPass
    end

    function MerchantModule.getClosest()
        local NPCs = Services.Workspace:WaitForChild("NPCs")
        local char = Player.Character
        local playerHrp = char and char:FindFirstChild("HumanoidRootPart")
        if not playerHrp then
            return nil, math.huge
        end

        local closest, closestDist = nil, math.huge

        for _, folder in ipairs(NPCs:GetChildren()) do
            for _, npc in ipairs(folder:GetChildren()) do
                if MerchantModule.isMerchant(npc) and npc:FindFirstChild("HumanoidRootPart") then
                    local hrp = npc.HumanoidRootPart
                    local dist = (playerHrp.Position - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = hrp
                    end
                end
            end
        end

        return closest, closestDist
    end

    function MerchantModule.getSellPosition(merchantHrp, options)
        options = options or {}
        if not merchantHrp then
            return nil
        end

        local basePosition = merchantHrp.Position
        local outwardDistance = options.OutwardDistance or 12
        local verticalOffset = options.VerticalOffset or 20
        local char = Player.Character
        local playerHrp = char and char:FindFirstChild("HumanoidRootPart")
        local direction = playerHrp and (playerHrp.Position - basePosition) or nil

        if not direction or direction.Magnitude < 1 then
            direction = -merchantHrp.CFrame.LookVector
        end

        local horizontalDirection = Vector3.new(direction.X, 0, direction.Z)
        if horizontalDirection.Magnitude < 1 then
            horizontalDirection = Vector3.new(0, 0, -1)
        end

        return basePosition + (horizontalDirection.Unit * outwardDistance) + Vector3.new(0, verticalOffset, 0)
    end
end

local SellModule = {}
do
    function SellModule.getInventoryCount()
        local count = 0

        for _, item in ipairs(BackpackTwo:GetChildren()) do
            local t = item:GetAttribute("ItemType")
            if t == "Valuable" or t == "Equipment" then
                count = count + 1
            end
        end

        local character = Player.Character
        if character then
            local equipped = character:FindFirstChildOfClass("Tool")
            if equipped then
                local t = equipped:GetAttribute("ItemType")
                if t == "Valuable" or t == "Equipment" then
                    count = count + 1
                end
            end
        end

        return count
    end

    function SellModule.getBackpackSpaceFromLabel()
        local toolUI = PlayerGui and PlayerGui:FindFirstChild("ToolUI")
        local fillingPan = toolUI and toolUI:FindFirstChild("FillingPan")
        local inventorySpace = fillingPan and fillingPan:FindFirstChild("InventorySpace")

        if not inventorySpace or not inventorySpace:IsA("TextLabel") then
            return nil, nil, nil
        end

        local text = inventorySpace.Text or ""
        local current, max = text:match("([%d,]+)%s*/%s*([%d,]+)")
        current = current and tonumber(current:gsub(",", ""))
        max = max and tonumber(max:gsub(",", ""))

        if not current or not max then
            return nil, nil, text
        end

        return current, max, text
    end

    function SellModule.isBackpackAtCapacity()
        local current, max = SellModule.getBackpackSpaceFromLabel()
        return current ~= nil and max ~= nil and max > 0 and current >= max
    end

    function SellModule.execute()
        return ReplicatedStorage.Remotes.Shop.SellAll:InvokeServer()
    end

    function SellModule.handleVoidRequest()
        Utility.createNotification("Exiting The Void to find merchant...", 5)

        HumanoidRootPart.CFrame = CFrame.new(Map.EventStuff["The Void"].Model.ExitPortal.CFrame.Position +
                                                 Vector3.new(0, 3, 0))

        local maxWait = tick() + 7
        repeat
            task.wait(0.1)
        until (Player:GetAttribute("CurrentArea") == "Fortune River" and Player:GetAttribute("GameplayPaused") == false) or
            tick() > maxWait

        if Player:GetAttribute("CurrentArea") ~= "Fortune River" then
            Utility.createNotification("Failed to exit The Void properly.", 5)
            return false
        end

        task.wait(2)

        local closestHrp
        for i = 1, 4 do
            closestHrp = MerchantModule.getClosest()
            if closestHrp then
                break
            end
            if i < 4 then
                task.wait(1)
            end
        end

        if not closestHrp then
            Utility.createNotification("No merchant found after exiting void.", 5)
            HumanoidRootPart.CFrame = CFrame.new(Map.EventStuff.VoidPortal.Part.CFrame.Position + Vector3.new(0, 3, 0))
            return false
        end

        Utility.createNotification("Found merchant, teleporting and selling..", 5)

        local sellPosition = MerchantModule.getSellPosition(closestHrp)
        local sellSuccess = Movement.teleportToTarget(sellPosition, {
            Mode = "Critical",
            FireRemoteFunc = function()
                Utility.createNotification("Selling all valuables...", 3)
                return SellModule.execute()
            end,
            Timeout = 90
        })

        if sellSuccess then
            local success
            task.wait(3)
            Utility.createNotification("Returning to The Void...", 5)

            local voidportal = Map.EventStuff.VoidPortal
            Movement.teleportToTarget(voidportal.WorldPivot.Position, {
                Mode = "Standard",
                OnComplete = function(moveSuccess)
                    success = moveSuccess or false
                end
            })

            task.wait()
            return success
        end

        return sellSuccess
    end

    function SellModule.sell(config, mode)
        local closestHrp, dist = MerchantModule.getClosest()

        local ServerTime = Services.Workspace:GetServerTimeNow()
        local trialTime = Player:GetAttribute("SellAnywhereTrialTime")
        local requiredDistance = config.RequiredDistance or 45

        if Player:GetAttribute("SellAnywhere") == true or (trialTime and trialTime + 600 > ServerTime) then
            local itemsSold, _ = SellModule.execute()
            if itemsSold and itemsSold > 0 then
                return true
            end
        end

        if not closestHrp and Player:GetAttribute("CurrentArea") == "The Void" then
            return SellModule.handleVoidRequest(config, mode)
        end

        if closestHrp and dist <= requiredDistance then
            SellModule.execute()
            return true
        end

        if not closestHrp then
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Notification",
                Description = "No merchant found nearby.",
                Duration = 5
            })
            return false
        end

        local function applyDefaults(cfg, m)
            local defaults = {}
            if m == "Tween" then
                defaults = {
                    StopDistance = 20,
                    CruiseHeight = 6,
                    MaxHeight = 10,
                    MinHeight = 1,
                    LongDistanceThreshold = 150,
                    DirectFlightThreshold = 50,
                    AdaptiveHeight = true,
                    UseDirectFlight = true,
                    HoverDuration = 0.3,
                    LandingDuration = 1.2
                }
            else
                defaults = {
                    Mode = "Critical",
                    Timeout = 90
                }
            end

            for k, v in pairs(defaults) do
                if cfg[k] == nil then
                    cfg[k] = v
                end
            end
        end

        applyDefaults(config, mode)
        local sellPosition = MerchantModule.getSellPosition(closestHrp)

        if mode == "Tween" then
            local completed = false
            local successSell = false

            config.OnStart = function()
                SimpleUI:CreateNotification({
                    Type = "Default",
                    Title = "Notification",
                    Description = "Tweening to merchant...",
                    Duration = 5
                })
            end

            config.OnComplete = function()
                task.wait(1)
                local _, finalDistance = MerchantModule.getClosest()
                if finalDistance and finalDistance <= requiredDistance then
                    SellModule.execute()
                    successSell = true
                else
                    SimpleUI:CreateNotification({
                        Type = "Error",
                        Title = "Notification",
                        Description = "Could not reach merchant via tween",
                        Duration = 5
                    })
                end
                completed = true
            end

            Movement.tweenToTarget(sellPosition, config)

            repeat
                task.wait()
            until completed

            return successSell
        else
            config.FireRemoteFunc = function()
                return SellModule.execute()
            end
            return Movement.teleportToTarget(sellPosition, config)
        end
    end
end

local ExcavationModule = {}
do
    function ExcavationModule.refreshData()
        if State.Excavation.waiting then
            return
        end
        State.Excavation.waiting = true

        local UpdateRemote = ReplicatedStorage.Remotes.Excavation.UpdateExcavationData
        local con

        con = UpdateRemote.OnClientEvent:Connect(function(d)
            State.Excavation.data = d
            State.Excavation.waiting = false
            con:Disconnect()
        end)

        UpdateRemote:FireServer()
    end

    function ExcavationModule.getCurrentStatus()
        if not State.Excavation.data then
            ExcavationModule.refreshData()
        end

        repeat
            task.wait()
        until State.Excavation.data

        local d = State.Excavation.data
        local ce = d.CurrentExcavation
        local marker = Services.Workspace:FindFirstChild("Marker")

        if marker then
            local ui = marker:FindFirstChild("UI")
            if ui then
                local n = ui:FindFirstChild("ExcavationName")
                if n and typeof(n.Text) == "string" and n.Text ~= "" then
                    return "Finished", n.Text
                end
            end
        end

        if ce and ce ~= "" then
            return "Active", ce
        end

        return "None", nil
    end

    function ExcavationModule.canStart()
        local status = ExcavationModule.getCurrentStatus()
        return status == "None"
    end

    function ExcavationModule.claim()
        local status, name = ExcavationModule.getCurrentStatus()
        if status ~= "Finished" or not name then
            return false
        end

        local ClaimRemote = ReplicatedStorage.Remotes.Excavation.ClaimExcavation
        local ok = ClaimRemote:InvokeServer(name)

        if ok then
            task.wait(2)
            ExcavationModule.refreshData()
            return true
        end

        return false
    end

    function ExcavationModule.start()
        if not State.Excavation.selected then
            return false, "No excavation selected."
        end

        local d = State.Excavation.data
        if not d then
            ExcavationModule.refreshData()
            repeat
                task.wait()
            until State.Excavation.data
            d = State.Excavation.data
        end

        local unlocked = d.UnlockedExcavationSites
        if not table.find(unlocked, State.Excavation.selected) then
            return false, "You haven't unlocked this excavation."
        end

        if not ExcavationModule.canStart() then
            if d.CurrentExcavation and d.CurrentExcavation ~= "" then
                return false, "Cannot start — active excavation: " .. d.CurrentExcavation
            else
                return false, "Cannot start — check for unclaimed excavation."
            end
        end

        local StartRemote = ReplicatedStorage.Remotes.Excavation.StartExcavation
        local ok = StartRemote:InvokeServer(State.Excavation.selected)

        if ok then
            ExcavationModule.refreshData()
            return true
        end

        return false, "Server rejected the request."
    end

    function ExcavationModule.autoStartCycle()
        local status = ExcavationModule.getCurrentStatus()

        if status == "Finished" then
            ExcavationModule.claim()
            task.wait(1)
            status = ExcavationModule.getCurrentStatus()
        end

        if status == "None" then
            return ExcavationModule.start()
        end

        return false, status == "Active" and "Excavation already active." or "Waiting for excavation state."
    end

    function ExcavationModule.getNames()
        local t = {}
        for name in pairs(Excavations.Sites) do
            table.insert(t, name)
        end
        return t
    end
end

local GeodeModule = {}
do
    function GeodeModule.isCollected(geode)
        return not geode or not geode.Parent
    end

    function GeodeModule.getModels()
        local geodeFolder = Services.Workspace:FindFirstChild("Geode")
        if not geodeFolder then
            return {}
        end

        local geodeModels = {}
        for _, child in pairs(geodeFolder:GetChildren()) do
            if child:IsA("Model") then
                table.insert(geodeModels, child)
            end
        end

        return geodeModels
    end

    function GeodeModule.getTeleportPosition(geodeModel)
        local cf, size = geodeModel:GetBoundingBox()
        return cf.Position
    end

    function GeodeModule.teleportToPosition(position)
        local character = Player.Character
        if not character then
            return false
        end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return false
        end

        humanoidRootPart.CFrame = CFrame.new(position)
        return true
    end

    function GeodeModule.teleportToNext(geodeStatus)
        local geodeModels = GeodeModule.getModels()

        if #geodeModels == 0 then
            if geodeStatus then
                geodeStatus:SetFields({"No geodes found"})
            end
            return false
        end

        if State.Geode.currentIndex > #geodeModels then
            State.Geode.currentIndex = 1
        end

        local targetGeode = geodeModels[State.Geode.currentIndex]

        if GeodeModule.isCollected(targetGeode) then
            State.Geode.currentIndex = State.Geode.currentIndex + 1
            return false
        end

        local geodePosition = GeodeModule.getTeleportPosition(targetGeode)

        if GeodeModule.teleportToPosition(geodePosition) then
            if geodeStatus then
                geodeStatus:SetFields({string.format("Teleported to: %s (%d/%d)", targetGeode.Name,
                    State.Geode.currentIndex, #geodeModels)})
            end
            return true
        else
            if geodeStatus then
                geodeStatus:SetFields({"Failed to teleport – Character not found"})
            end
            return false
        end
    end
end

local RuneModule = {}
do
    function RuneModule.getList()
        local folder = Map:FindFirstChild("FindableRunes")
        return folder and folder:GetChildren() or {}
    end

    function RuneModule.teleportToNext(runeStatus)
        local list = RuneModule.getList()

        if #list == 0 then
            if runeStatus then
                runeStatus:SetFields({"No runes found in workspace"})
            end
            return
        end

        State.Rune.currentIndex = State.Rune.currentIndex + 1
        if State.Rune.currentIndex > #list then
            State.Rune.currentIndex = 1
        end

        local rune = list[State.Rune.currentIndex]
        if not rune or not rune:IsA("Model") then
            if runeStatus then
                runeStatus:SetFields({"Invalid rune"})
            end
            return
        end

        local target = rune:FindFirstChild("MainPart")
        if not target or not target:IsA("BasePart") then
            if runeStatus then
                runeStatus:SetFields({"Rune has no MainPart"})
            end
            return
        end

        local char = Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            if runeStatus then
                runeStatus:SetFields({"No HumanoidRootPart"})
            end
            return
        end

        root.CFrame = target.CFrame + Vector3.new(0, 3, 0)

        if runeStatus then
            runeStatus:SetFields({string.format("Teleported to rune %d/%d", State.Rune.currentIndex, #list)})
        end
    end
end

local CraftingModule = {}
do
    local Modifiers = require(ReplicatedStorage.GameInfo.Modifiers)

    local function determineQuality(selected, recipe)
        local totalScore = 0
        local totalCount = 0
        for materialName, req in pairs(recipe.Materials) do
            local sel = selected[materialName]
            if not sel then
                return nil
            end
            for i = 1, #sel do
                local tool = sel[i]
                local d = tool:FindFirstChild("ItemData")
                if d then
                    local w = d:GetAttribute("Weight") or 0
                    local mod = d:GetAttribute("Modifier")
                    if mod and Modifiers[mod] then
                        w = w * Modifiers[mod].Multiplier
                    end
                    totalScore = totalScore + ((w - (req.MinWeight or 0)) / req.QualityStep + 1)
                    totalCount = totalCount + 1
                end
            end
            if #sel < req.Amount then
                return nil
            end
        end
        if totalCount == 0 then
            return nil
        end
        return math.clamp(math.floor(totalScore / totalCount), 1, 5)
    end

    local function getTools()
        local tools = {}
        local backpack = BackpackTwo:GetChildren()
        for i = 1, #backpack do
            tools[#tools + 1] = backpack[i]
        end
        local char = Character
        if char then
            local t = char:FindFirstChildOfClass("Tool")
            if t then
                tools[#tools + 1] = t
            end
        end
        return tools
    end

    local function effectiveWeight(tool)
        local d = tool:FindFirstChild("ItemData")
        if not d then
            return 0
        end
        local w = d:GetAttribute("Weight") or 0
        local mod = d:GetAttribute("Modifier")
        if mod and Modifiers[mod] then
            w = w * Modifiers[mod].Multiplier
        end
        return w
    end

    function CraftingModule.getModifierNames()
        local t = {}
        for k in pairs(Modifiers) do
            t[#t + 1] = k
        end
        return t
    end

    function CraftingModule.getOreNames()
        local t = {}
        for _, obj in ipairs(ReplicatedStorage.Items.Valuables:GetChildren()) do
            t[#t + 1] = obj.Name
        end
        return t
    end

    function CraftingModule.getDiscoveredRecipes()
        local ids = {}
        local waiting = true
        local conn
        conn = ReplicatedStorage.Remotes.Crafting.UpdateDiscoveredEquipment.OnClientEvent:Connect(function(data)
            ids = data
            waiting = false
            conn:Disconnect()
        end)
        ReplicatedStorage.Remotes.Crafting.UpdateDiscoveredEquipment:FireServer()
        local t = 0
        while waiting and t < 5 do
            task.wait(0.1)
            t = t + 0.1
        end

        local recipes = {}
        for _, item in ipairs(ReplicatedStorage.Items.Equipment:GetChildren()) do
            local equipData = item:FindFirstChild("EquipmentData")
            if equipData and equipData:IsA("ModuleScript") then
                local ok, data = pcall(require, equipData)
                if ok and data.Materials then
                    local hidden = item:GetAttribute("Hidden")
                    local admin = item:GetAttribute("AdminLimited")
                    local xmas = item:GetAttribute("ChristmasLimited")
                    local add = false
                    if hidden then
                        if table.find(ids, item:GetAttribute("ItemID")) then
                            add = true
                        end
                    elseif not admin and not xmas then
                        add = true
                    end
                    if add then
                        recipes[#recipes + 1] = {
                            Name = item.Name,
                            Item = item,
                            Data = data
                        }
                    end
                end
            end
        end

        table.sort(recipes, function(a, b)
            return a.Name < b.Name
        end)
        return recipes
    end

    function CraftingModule.getOwned(materialName, minWeight)
        local owned = {}
        local tools = getTools()
        for i = 1, #tools do
            local tool = tools[i]
            if tool.Name == materialName then
                local d = tool:FindFirstChild("ItemData")
                if d then
                    local w = d:GetAttribute("Weight") or 0
                    if w >= (minWeight or 0) then
                        owned[#owned + 1] = tool
                    end
                end
            end
        end
        return owned
    end

    function CraftingModule.selectBest(recipe)
        local selected = {}
        for materialName, req in pairs(recipe.Materials) do
            local owned = CraftingModule.getOwned(materialName, req.MinWeight)
            table.sort(owned, function(a, b)
                return effectiveWeight(a) > effectiveWeight(b)
            end)
            selected[materialName] = {}
            local limit = math.min(req.Amount, #owned)
            for i = 1, limit do
                selected[materialName][i] = owned[i]
            end
        end
        return selected
    end

    function CraftingModule.buildFields(eq, selected)
        local recipe = eq.Data
        local fields = {}
        local LINE = "- - - - - - - - - - - - - -"

        fields[#fields + 1] = eq.Name
        fields[#fields + 1] = {
            Text = "Price:" .. Utility.formatPrice(recipe.Price or 0),
            IsSubField = true
        }
        fields[#fields + 1] = {
            Text = LINE,
            IsSubField = true
        }

        local allReady = true
        local missingCount = 0

        for materialName, req in pairs(recipe.Materials) do
            local owned = CraftingModule.getOwned(materialName, req.MinWeight)
            local sel = selected[materialName] or {}
            local count = 0
            for i = 1, #sel do
                if sel[i] and sel[i].Parent then
                    count = count + 1
                end
            end

            if count < req.Amount then
                allReady = false
                missingCount = missingCount + (req.Amount - count)
            end

            local icon = count >= req.Amount and "[+]" or "[-]"
            local label
            if req.MinWeight and req.MinWeight > 0 then
                label = string.format("%s %s [+%dkg]  %d/%d  (%d owned)", icon, materialName, req.MinWeight, count,
                    req.Amount, #owned)
            else
                label = string.format("%s %s  %d/%d  (%d owned)", icon, materialName, count, req.Amount, #owned)
            end
            fields[#fields + 1] = {
                Text = label,
                IsSubField = true
            }
        end

        fields[#fields + 1] = {
            Text = LINE,
            IsSubField = true
        }

        if allReady then
            local quality = determineQuality(selected, recipe)

            if quality then
                local stars = string.rep("☆", quality) .. string.rep(".", 5 - quality)
                local qualityNames = {"Poor", "Common", "Good", "Great", "Perfect"}
                fields[#fields + 1] = "Quality: [" .. stars .. "]  " .. qualityNames[quality]

                if recipe.Stats then
                    local ok, ItemStatsInfo = pcall(require, ReplicatedStorage.GameInfo.ItemStatsInfo)
                    local ok2, FormatNumber = pcall(require, ReplicatedStorage.Modules.Utility.FormatNumber)
                    if ok and ok2 then
                        for statName, statData in pairs(recipe.Stats) do
                            local info = ItemStatsInfo[statName]
                            if info then
                                local minVal = statData.Min + statData.QualityStep * (quality - 1)
                                local maxVal = statData.Min + statData.QualityStep * quality
                                local statText
                                if info.Percentage then
                                    statText = string.format("  %s: %.0f%% - %.0f%%", info.DisplayName, minVal * 100,
                                        maxVal * 100)
                                else
                                    statText = string.format("  %s: %s - %s", info.DisplayName,
                                        FormatNumber.Format(minVal), FormatNumber.Format(maxVal))
                                end
                                fields[#fields + 1] = {
                                    Text = statText,
                                    IsSubField = true
                                }
                            end
                        end
                    end
                end

                if quality < 5 then
                    fields[#fields + 1] = {
                        Text = "Use heavier materials for better quality",
                        IsSubField = true
                    }
                else
                    fields[#fields + 1] = {
                        Text = "Maximum quality achieved",
                        IsSubField = true
                    }
                end
            else
                fields[#fields + 1] = "Quality: [.....]  Unknown"
            end

            fields[#fields + 1] = {
                Text = LINE,
                IsSubField = true
            }
            fields[#fields + 1] = "Ready to craft"
        else
            fields[#fields + 1] = "Missing " .. missingCount .. " material" .. (missingCount == 1 and "" or "s")
        end

        return fields
    end

    function CraftingModule.canCraft(recipe, selected)
        for materialName, req in pairs(recipe.Materials) do
            local sel = selected[materialName] or {}
            local count = 0
            for i = 1, #sel do
                if sel[i] and sel[i].Parent then
                    count = count + 1
                end
            end
            if count < req.Amount then
                return false
            end
        end
        return true
    end

    function CraftingModule.craft(equipmentItem, selected)
        local ok, result, _, craftedItem = pcall(function()
            return ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(equipmentItem, selected)
        end)
        if not ok then
            return false, "Remote failed"
        end
        if not result then
            return false, "Server rejected"
        end
        return true, craftedItem
    end
end

local EnchantModule = {}
do
    function EnchantModule.getNames(type)
        if type == "pan" then
            local enchantsModule = require(ReplicatedStorage.GameInfo.Enchants)
            local names = {}
            for name in pairs(enchantsModule) do
                names[#names + 1] = name
            end
            table.sort(names)
            return names
        elseif type == "shovel" then
            local shovelEnchantsModule = require(ReplicatedStorage.GameInfo.ShovelEnchants)
            local names = {}
            for name in pairs(shovelEnchantsModule) do
                names[#names + 1] = name
            end
            table.sort(names)
            return names
        end
        return {}
    end

    function EnchantModule.findPanMaterial(materialName)
        if not BackpackTwo then
            return nil
        end
        return BackpackTwo:FindFirstChild(materialName)
    end

    function EnchantModule.findShovelMaterial(modifier)
        if not BackpackTwo then
            return nil
        end

        for _, tool in ipairs(BackpackTwo:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Aetherite" then
                local itemData = tool:FindFirstChild("ItemData")
                if itemData and itemData:GetAttribute("Modifier") == modifier then
                    return tool
                end
            end
        end

        return nil
    end

    function EnchantModule.enchant(remote, item, itemName)
        local ok, result = pcall(function()
            return remote:InvokeServer(item)
        end)

        if ok then
            Utility.createNotification("Successfully enchanted with " .. tostring(result) .. " using " .. itemName, 4)
            return result
        else
            Utility.createNotification("Error enchanting " .. itemName, 3)
            return nil
        end
    end

    function EnchantModule.performAuto(findFunc, remote, itemName, target, flag)
        task.spawn(function()
            while flag[1] do
                local item = findFunc()
                if not item then
                    flag[1] = false
                    Utility.createNotification("Item not found: " .. itemName, 3)
                    break
                end

                local enchant = EnchantModule.enchant(remote, item, itemName)
                if enchant then
                    if enchant == target then
                        flag[1] = false
                        Utility.createNotification("Got target enchant: " .. enchant, 5)
                        break
                    end
                end

                task.wait(1.5)
            end
        end)
    end
end

local FavouriteModule = {}
do
    function FavouriteModule.isLocked(item)
        return item:GetAttribute("Locked") == true
    end

    function FavouriteModule.toggle(item)
        ReplicatedStorage.Remotes.Inventory.ToggleLock:FireServer(item)
    end

    function FavouriteModule.favourite(item)
        if not FavouriteModule.isLocked(item) then
            FavouriteModule.toggle(item)
        end
    end

    function FavouriteModule.matchesModifier(item, modifier)
        return item:FindFirstChild("ItemData"):GetAttribute("Modifier") == modifier
    end

    function FavouriteModule.matchesOre(item, oreName)
        return item.Name == oreName
    end

    function FavouriteModule.isValuable(item)
        return item:GetAttribute("ItemType") == "Valuable"
    end
end

local ReforgeModule = {}
do
    function ReforgeModule.updateInfo(guid, infoDisplay)
        local function safeSetFields(fields)
            pcall(function()
                infoDisplay:SetFields(fields)
            end)
        end

        if not guid then
            safeSetFields({"No equipment selected"})
            return
        end

        if not BackpackTwo or not BackpackTwo.GetChildren then
            safeSetFields({"Backpack unavailable"})
            return
        end

        local equipment
        for _, child in ipairs(BackpackTwo:GetChildren() or {}) do
            if child and child.GetAttribute and child:GetAttribute("GUID") == guid then
                equipment = child
                break
            end
        end

        if not equipment then
            safeSetFields({"Equipment not found"})
            return
        end

        local fields = {}
        table.insert(fields, "Name: " .. tostring(equipment.Name or "Unknown"))

        local reforges = (equipment:FindFirstChild("ItemData") and equipment.ItemData:GetAttribute("Reforges")) or 0
        table.insert(fields, "Reforges: " .. tostring(reforges))

        local cost
        pcall(function()
            cost = ReplicatedStorage.Remotes.Crafting.GetReforgeCost:InvokeServer(equipment)
        end)
        table.insert(fields, "Price: " .. Utility.formatPrice(cost or 0))

        local statRolls
        pcall(function()
            statRolls = equipment:FindFirstChild("StatRolls")
        end)

        if statRolls and statRolls.GetAttributes then
            table.insert(fields, "Stats:")
            local attributes = {}
            pcall(function()
                attributes = statRolls:GetAttributes()
            end)

            for attrName, attrValue in pairs(attributes or {}) do
                table.insert(fields, {
                    Text = tostring(attrName) .. ": " .. tostring(attrValue),
                    IsSubField = true
                })
            end
        end

        safeSetFields(fields)
    end

    function ReforgeModule.perform(guid)
        if not guid then
            Utility.createNotification("Select an Equipment from your Backpack first!")
            return
        end

        if not BackpackTwo or not BackpackTwo.GetChildren then
            Utility.createNotification("Backpack unavailable.")
            return
        end

        local equipment
        for _, child in ipairs(BackpackTwo:GetChildren() or {}) do
            if child and child.GetAttribute and child:GetAttribute("GUID") == guid then
                equipment = child
                break
            end
        end

        if not equipment then
            Utility.createNotification("Selected equipment not found.")
            return
        end

        local success, result = pcall(function()
            return CraftingRemotes.ReforgeEquipment:InvokeServer(equipment)
        end)

        if not success then
            Utility.createNotification("Reforge failed: " .. tostring(result))
            return
        end

        Utility.createNotification("Reforge successful!")

        local newEquipment
        local timeout = 2
        local startTime = os.clock()

        while os.clock() - startTime < timeout do
            for _, child in ipairs(BackpackTwo:GetChildren() or {}) do
                if child and child.GetAttribute and child:GetAttribute("GUID") == guid then
                    newEquipment = child
                    break
                end
            end
            if newEquipment then
                break
            end
            task.wait(0.1)
        end

        if not newEquipment then
            Utility.createNotification("Reforge succeeded, but updated item not found.")
            return
        end

        pcall(function()
            CraftingRemotes.GetReforgeCost:InvokeServer(newEquipment)
        end)

        return guid
    end
end

local FireflyModule = {}
do
    function FireflyModule.craft(amount)
        if typeof(amount) ~= "number" or amount < 1 or amount >= 1000 then
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Invalid Amount",
                Description = "Craft amount must be between 1 and 999."
            })
            return false
        end

        local stones = {}
        for _, tool in ipairs(BackpackTwo:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Firefly Stone" then
                table.insert(stones, tool)
            end
        end

        if #stones < amount then
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Insufficient Materials",
                Description = "Not enough Firefly Stones."
            })
            return false
        end

        local flareTable = Map:WaitForChild("LushCaverns"):WaitForChild("AbyssAssets"):WaitForChild("FlareTable")
        local prompt = flareTable:FindFirstChild("Prompt", true)

        if not prompt or not fireproximityprompt then
            SimpleUI:CreateNotification({
                Type = "Error",
                Title = "Executor Unsupported",
                Description = "fireproximityprompt is unavailable."
            })
            return false
        end

        if not HumanoidRootPart then
            return false
        end

        local distance = (HumanoidRootPart.Position - flareTable:GetPivot().Position).Magnitude

        if distance > 20 then
            SimpleUI:CreateNotification({
                Type = "Warning",
                Title = "Too Far Away",
                Description = "Go to the Firefly crafting table."
            })
            return false
        elseif distance > 10 then
            SimpleUI:CreateNotification({
                Type = "Info",
                Title = "Get Closer",
                Description = "Move closer to the crafting table."
            })
            return false
        end

        prompt.HoldDuration = 0

        SimpleUI:CreateNotification({
            Type = "Info",
            Title = "Crafting Started",
            Description = "Crafting Firefly Flares..."
        })

        local EquipRemote = ReplicatedStorage.Remotes.CustomBackpack.EquipRemote

        for i = 1, amount do
            if not Character or not HumanoidRootPart then
                break
            end

            local currentDistance = (HumanoidRootPart.Position - flareTable:GetPivot().Position).Magnitude
            if currentDistance > 20 then
                break
            end

            local tool = stones[i]
            if not tool or not tool.Parent then
                break
            end

            pcall(function()
                EquipRemote:FireServer(tool)
            end)

            task.wait(0.05)

            pcall(function()
                fireproximityprompt(prompt)
            end)

            task.wait(0.15)
        end

        SimpleUI:CreateNotification({
            Type = "Success",
            Title = "Crafting Complete",
            Description = "Firefly crafting process finished."
        })

        return true
    end
end

local ESPModule = {}
do
    function ESPModule.createBillboard(target, name, color, player)
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESPBillboard"
        bb.Adornee = target
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 2.6, 0)
        bb.Size = UDim2.fromOffset(200, 24)
        bb.Parent = target

        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.fromScale(1, 1)
        frame.Parent = bb

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 4)
        padding.PaddingRight = UDim.new(0, 4)
        padding.Parent = frame

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 5)
        layout.Parent = frame

        if player then
            local avatar = Instance.new("ImageLabel")
            avatar.BackgroundTransparency = 1
            avatar.Size = UDim2.fromOffset(16, 16)
            avatar.Image = Services.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size48x48)
            avatar.Parent = frame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = avatar
        end

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextColor3 = color or Color3.new(1, 1, 1)
        nameLabel.Text = name
        nameLabel.AutomaticSize = Enum.AutomaticSize.X
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.BackgroundTransparency = 1
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 11
        distLabel.TextXAlignment = Enum.TextXAlignment.Left
        distLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        distLabel.AutomaticSize = Enum.AutomaticSize.X
        distLabel.Parent = frame

        local conn
        conn = Services.RunService.RenderStepped:Connect(function()
            if not bb.Parent or not target.Parent then
                conn:Disconnect()
                return
            end
            local d = (Camera.CFrame.Position - target.Position).Magnitude
            distLabel.Text = string.format("%dm", d + 0.5)
        end)

        return bb
    end

    function ESPModule.enablePlayers()
        local function attachESP(plr)
            if plr == Player then
                return
            end

            local char = plr.Character
            if not char then
                return
            end

            local head = char:FindFirstChild("Head")
            if not head then
                return
            end

            if State.ESP.Players[plr] then
                State.ESP.Players[plr]:Destroy()
            end

            State.ESP.Players[plr] = ESPModule.createBillboard(head, plr.Name, Color3.fromRGB(255, 255, 255), plr)
        end

        local function hookPlayer(plr)
            if plr == Player then
                return
            end

            if plr.Character then
                attachESP(plr)
            end

            State.ESP.Connections["Char_" .. plr.UserId] = plr.CharacterAdded:Connect(function()
                attachESP(plr)
            end)

            plr.CharacterRemoving:Connect(function()
                if State.ESP.Players[plr] then
                    State.ESP.Players[plr]:Destroy()
                    State.ESP.Players[plr] = nil
                end
            end)
        end

        for _, plr in ipairs(Services.Players:GetPlayers()) do
            hookPlayer(plr)
        end

        State.ESP.Connections.PlayerAdded = Services.Players.PlayerAdded:Connect(hookPlayer)

        State.ESP.Connections.PlayerRemoving = Services.Players.PlayerRemoving:Connect(function(plr)
            if State.ESP.Players[plr] then
                State.ESP.Players[plr]:Destroy()
                State.ESP.Players[plr] = nil
            end

            local conn = State.ESP.Connections["Char_" .. plr.UserId]
            if conn then
                conn:Disconnect()
                State.ESP.Connections["Char_" .. plr.UserId] = nil
            end
        end)
    end

    function ESPModule.disablePlayers()
        for _, bb in pairs(State.ESP.Players) do
            if bb then
                bb:Destroy()
            end
        end

        for _, conn in pairs(State.ESP.Connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end

        State.ESP.Players = {}
        State.ESP.Connections = {}
    end

    function ESPModule.enableTotems()
        local folder = Services.Workspace:FindFirstChild("ActiveTotems")
        if not folder then
            return
        end

        local function addTotem(model)
            if model:IsA("Model") then
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local color = model:GetAttribute("NameColor")
                    if typeof(color) ~= "Color3" then
                        color = Color3.fromRGB(150, 200, 255)
                    end
                    local bb = ESPModule.createBillboard(part, model.Name, color)
                    State.ESP.Totems[model] = bb
                end
            end
        end

        for _, m in ipairs(folder:GetChildren()) do
            addTotem(m)
        end

        State.ESP.Connections.TotemAdded = folder.ChildAdded:Connect(addTotem)
        State.ESP.Connections.TotemRemoved = folder.ChildRemoved:Connect(function(m)
            if State.ESP.Totems[m] then
                State.ESP.Totems[m]:Destroy()
                State.ESP.Totems[m] = nil
            end
        end)
    end

    function ESPModule.disableTotems()
        for _, v in pairs(State.ESP.Totems) do
            v:Destroy()
        end

        if State.ESP.Connections.TotemAdded then
            State.ESP.Connections.TotemAdded:Disconnect()
        end

        if State.ESP.Connections.TotemRemoved then
            State.ESP.Connections.TotemRemoved:Disconnect()
        end

        State.ESP.Totems = {}
    end

    function ESPModule.clearAll()
        local function clearFromFolder(folder)
            if not folder then
                return
            end
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("BillboardGui") and obj.Name == "ESPBillboard" then
                    obj:Destroy()
                end
            end
        end

        clearFromFolder(Services.Workspace:FindFirstChild("ActiveTotems"))
        clearFromFolder(Services.Workspace:FindFirstChild("Characters"))

        for _, bb in pairs(State.ESP.Players or {}) do
            if bb and bb.Parent then
                bb:Destroy()
            end
        end
        State.ESP.Players = {}

        for _, bb in pairs(State.ESP.Totems or {}) do
            if bb and bb.Parent then
                bb:Destroy()
            end
        end
        State.ESP.Totems = {}

        for _, conn in pairs(State.ESP.Connections or {}) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        State.ESP.Connections = {}
    end
end

local InventoryFilterModule = {}
do
    function InventoryFilterModule.create()
        local inventory = PlayerGui.BackpackGui.Backpack.Inventory
        local scrollingFrame = inventory.ScrollingFrame
        local gridFrame = scrollingFrame.UIGridFrame

        local existingPanel = inventory:FindFirstChild("FilterPanel")
        if existingPanel then
            existingPanel:Destroy()
            task.wait()
        end

        local filterPanel = Instance.new("Frame")
        filterPanel.Name = "FilterPanel"
        filterPanel.Parent = inventory
        filterPanel.AnchorPoint = Vector2.new(0, 0)
        filterPanel.Position = UDim2.new(1, 0.02, 0, -30)
        filterPanel.Size = UDim2.new(0.22, 0, 1.08, 0)
        filterPanel.BackgroundTransparency = 1
        filterPanel.BorderSizePixel = 0

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 0)
        padding.PaddingBottom = UDim.new(0.04, 0)
        padding.PaddingLeft = UDim.new(0.06, 0)
        padding.PaddingRight = UDim.new(0.06, 0)
        padding.Parent = filterPanel

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0.018, 0)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = filterPanel

        local fontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold,
            Enum.FontStyle.Italic)

        local title = Instance.new("TextLabel")
        title.Name = "CurrentFilter"
        title.Parent = filterPanel
        title.Size = UDim2.new(1, 0, 0.16, 0)
        title.BackgroundTransparency = 1
        title.Text = "Filter: All Items"
        title.TextWrapped = true
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Center
        title.FontFace = fontFace
        title.TextScaled = true
        title.LineHeight = 1
        title.TextColor3 = Color3.fromRGB(245, 245, 245)
        title.LayoutOrder = 1

        local titleStroke = Instance.new("UIStroke")
        titleStroke.Color = Color3.fromRGB(0, 0, 0)
        titleStroke.Thickness = 1
        titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        titleStroke.Parent = title

        local function createFilterButton(text, color, order)
            local button = Instance.new("TextButton")
            button.Name = text .. "Filter"
            button.Parent = filterPanel
            button.Size = UDim2.new(1, 0, 0.075, 0)
            button.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
            button.BorderSizePixel = 0
            button.Text = text
            button.FontFace = fontFace
            button.TextScaled = true
            button.LineHeight = 1
            button.TextColor3 = color
            button.AutoButtonColor = false
            button.LayoutOrder = order

            local stroke = Instance.new("UIStroke")
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Color = color
            stroke.Thickness = 1
            stroke.Parent = button

            return button
        end

        local FILTER_BUTTONS = {{"Ores", Color3.fromRGB(190, 190, 190)}, {"Equipments", Color3.fromRGB(255, 90, 90)},
                                {"Totems/Relics", Color3.fromRGB(120, 220, 120)},
                                {"Geodes", Color3.fromRGB(90, 170, 255)}, {"Maps", Color3.fromRGB(200, 160, 255)},
                                {"Others", Color3.fromRGB(200, 120, 255)}, {"All Items", Color3.fromRGB(245, 245, 245)}}

        local ICON_CATEGORY = {
            ["rbxassetid://71590406800942"] = "Equipments",
            ["rbxassetid://128090935503267"] = "Equipments",
            ["rbxassetid://95192688083586"] = "Equipments",
            ["rbxassetid://84287308918508"] = "Ores",
            ["rbxassetid://18624930841"] = "Totems/Relics",
            ["rbxassetid://6947202399"] = "Totems/Relics",
            ["rbxassetid://9019175526"] = "Geodes",
            ["rbxassetid://8360687671"] = "Maps"
        }

        local connections = {}
        local itemCache = {}
        local currentFilter = "All Items"
        local isUpdating = false
        local filterChanged = false

        local PADDING = 10
        local originalCanvasSize = scrollingFrame.CanvasSize

        local function getCategory(button)
            local icon = button:FindFirstChild("TypeIcon")
            if icon and icon:IsA("ImageLabel") then
                return ICON_CATEGORY[icon.Image] or "Others"
            end
            return "Others"
        end

        local function cacheItem(button)
            if not itemCache[button] then
                itemCache[button] = {
                    pos = button.Position,
                    vis = button.Visible,
                    cat = getCategory(button)
                }
            end
            return itemCache[button]
        end

        local function getAllItems()
            local items = {}
            for _, child in ipairs(gridFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    table.insert(items, child)
                end
            end
            return items
        end

        local function calculateLayout(visibleItems)
            if #visibleItems == 0 then
                return 0
            end

            local firstItem = visibleItems[1]
            local itemWidth = firstItem.AbsoluteSize.X
            local itemHeight = firstItem.AbsoluteSize.Y
            local frameWidth = gridFrame.AbsoluteSize.X

            local cols = math.max(1, math.floor((frameWidth + PADDING) / (itemWidth + PADDING)))
            local rows = math.ceil(#visibleItems / cols)

            for i, item in ipairs(visibleItems) do
                local row = math.floor((i - 1) / cols)
                local col = (i - 1) % cols
                item.Position = UDim2.fromOffset(col * (itemWidth + PADDING), row * (itemHeight + PADDING))
            end

            return rows * (itemHeight + PADDING)
        end

        local function applyFilter(filter)
            if isUpdating then
                return
            end
            isUpdating = true

            local savedScroll = scrollingFrame.CanvasPosition
            currentFilter = filter
            local items = getAllItems()

            if filter == "All Items" then
                for _, item in ipairs(items) do
                    local cached = itemCache[item]
                    if cached then
                        item.Visible = cached.vis
                        item.Position = cached.pos
                    else
                        item.Visible = true
                    end
                end
                scrollingFrame.CanvasSize = originalCanvasSize
            else
                local visible = {}
                for _, item in ipairs(items) do
                    local cached = cacheItem(item)
                    if cached.cat == filter then
                        item.Visible = true
                        table.insert(visible, item)
                    else
                        item.Visible = false
                    end
                end
                local canvasHeight = calculateLayout(visible)
                scrollingFrame.CanvasSize = UDim2.fromOffset(0, canvasHeight)
            end

            if filterChanged then
                scrollingFrame.CanvasPosition = Vector2.zero
                filterChanged = false
            else
                scrollingFrame.CanvasPosition = savedScroll
            end

            isUpdating = false
        end

        local debounce = false
        local function onItemsChanged(child)
            if debounce then
                return
            end
            if not child:IsA("TextButton") then
                return
            end

            debounce = true
            task.wait(0.05)

            for _, item in ipairs(getAllItems()) do
                cacheItem(item)
            end

            applyFilter(currentFilter)
            debounce = false
        end

        for _, item in ipairs(getAllItems()) do
            cacheItem(item)
        end

        for i, data in ipairs(FILTER_BUTTONS) do
            local text, color = data[1], data[2]
            local button = createFilterButton(text, color, i + 1)

            table.insert(connections, button.MouseButton1Click:Connect(function()
                filterChanged = true
                title.Text = "Filter: " .. text
                applyFilter(text)
            end))

            table.insert(connections, button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end))

            table.insert(connections, button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
            end))
        end

        table.insert(connections, gridFrame.ChildAdded:Connect(onItemsChanged))
        table.insert(connections, gridFrame.ChildRemoved:Connect(onItemsChanged))

        table.insert(connections, filterPanel.Destroying:Connect(function()
            for _, conn in ipairs(connections) do
                if conn.Connected then
                    conn:Disconnect()
                end
            end
            table.clear(connections)
            table.clear(itemCache)
        end))
    end

    function InventoryFilterModule.destroy()
        local inventory = PlayerGui.BackpackGui.Backpack.Inventory
        local existingPanel = inventory:FindFirstChild("FilterPanel")
        if existingPanel then
            existingPanel:Destroy()
        end
    end
end

local MobileUIModule = {}
do
    function MobileUIModule.createToggleButton(window, forceMobile)
        if not forceMobile and not SimpleUI.Utility:IsMobile() then
            return
        end

        local TweenService = SimpleUI.Utility:GetService("TweenService")
        local UserInputService = SimpleUI.Utility:GetService("UserInputService")

        local folderName = "SimpleScripts"
        local fileName = folderName .. "/logo.png"
        local iconUrl = "https://raw.githubusercontent.com/dawnpetal/website/refs/heads/main/assets/images/logo.png"
        local logoAsset

        local canUseFilesystem = makefolder and isfolder and listfiles and isfile and delfile and writefile and
                                     getcustomasset

        if canUseFilesystem then
            if not isfolder(folderName) then
                makefolder(folderName)
            end

            for _, file in ipairs(listfiles("")) do
                local cleanFile = file:gsub("^/", "")
                if cleanFile:lower():find("simpleui") and isfile(cleanFile) then
                    delfile(cleanFile)
                end
            end

            if not isfile(fileName) then
                local success, imageData = pcall(function()
                    return game:HttpGet(iconUrl)
                end)
                if success and imageData then
                    writefile(fileName, imageData)
                end
            end

            logoAsset = getcustomasset(fileName)
        end

        local toggleButton = Instance.new("ImageButton")
        toggleButton.Name = "ToggleUIButton"
        toggleButton.Size = UDim2.new(0, 40, 0, 40)
        toggleButton.Position = UDim2.new(0, 30, 0.5, -20)
        toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
        toggleButton.BackgroundTransparency = 1
        toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.ScaleType = Enum.ScaleType.Fit
        toggleButton.Active = true
        toggleButton.Image = logoAsset or "rbxassetid://10734900011"
        toggleButton.Parent = window.Elements.ScreenGui

        local dragging = false
        local dragStart, startPos
        local hasMoved = false
        local normalSize = UDim2.new(0, 40, 0, 40)
        local pressSize = UDim2.new(0, 50, 0, 50)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        if toggleButton and TweenService then
            toggleButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType ==
                    Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = toggleButton.Position
                    hasMoved = false
                    TweenService:Create(toggleButton, tweenInfo, {
                        Size = pressSize
                    }):Play()
                end
            end)

            toggleButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType ==
                    Enum.UserInputType.Touch then
                    dragging = false
                    TweenService:Create(toggleButton, tweenInfo, {
                        Size = normalSize
                    }):Play()
                    if not hasMoved then
                        if window.IsVisible() then
                            window.Hide()
                        else
                            window.Show()
                        end
                    end
                end
            end)
        end

        if UserInputService then
            UserInputService.InputChanged:Connect(function(input)
                if dragging and
                    (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType ==
                        Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                        hasMoved = true
                        toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end
            end)
        end
    end
end

local LegitWaypointReader = {}
do
    LegitWaypointReader.Routes = {
        [tostring(game.PlaceId)] = {
            Default = {
                Dig = {},
                Wash = {},
                Merchant = {}
            }
        }
    }

    local function toPosition(point)
        if typeof(point) == "Vector3" then
            return point
        elseif typeof(point) == "CFrame" then
            return point.Position
        elseif typeof(point) == "table" then
            if point.Position then
                return toPosition(point.Position)
            elseif point.X and point.Y and point.Z then
                return Vector3.new(point.X, point.Y, point.Z)
            end
        end
        return nil
    end

    function LegitWaypointReader:getAreaKey()
        local area = Player:GetAttribute("CurrentArea")
        return area and tostring(area) or "Default"
    end

    function LegitWaypointReader:getAreaRoutes()
        local placeRoutes = self.Routes[tostring(game.PlaceId)] or self.Routes[game.PlaceId] or {}
        local areaKey = self:getAreaKey()
        return placeRoutes[areaKey] or placeRoutes.Default or placeRoutes
    end

    function LegitWaypointReader:getVariants(category)
        local routes = self:getAreaRoutes()
        return routes[category] or routes[string.lower(category)] or {}
    end

    function LegitWaypointReader:buildRoute(category, targetCFrame)
        local variants = self:getVariants(category)
        local selected = {}

        if type(variants) == "table" and #variants > 0 then
            if type(variants[1]) == "table" and not variants[1].X and not variants[1].Position then
                selected = variants[math.random(1, #variants)] or {}
            else
                selected = variants
            end
        end

        local route = {}
        for _, point in ipairs(selected) do
            local position = toPosition(point)
            if position then
                table.insert(route, position)
            end
        end

        table.insert(route, targetCFrame.Position)
        return route
    end
end

local AutoFarmModule = {}
do
    function AutoFarmModule.moveToLocation(targetCFrame, routeType)
        local completed = false
        local success = false

        local targetObj = {
            Position = targetCFrame.Position,
            CFrame = targetCFrame
        }

        local controller

        if State.AutoFarm.travelMode == "Legit" then
            success = Movement.walkToTarget(targetObj, {
                Route = LegitWaypointReader:buildRoute(routeType or "Dig", targetCFrame),
                StopDistance = 5,
                ShouldContinue = function()
                    return State.AutoFarm.active and not State.AutoFarm.interrupted
                end
            })
            completed = true
        elseif State.AutoFarm.travelMode == "Tween" then
            controller = Movement.tweenToTarget(targetObj, {
                CruiseHeight = 4,
                MinHeight = 1,
                MaxHeight = 6,
                LongDistanceThreshold = 100,
                DirectFlightThreshold = 30,
                AdaptiveHeight = false,
                UseDirectFlight = true,
                HoverDuration = 0,
                LandingDuration = 0.3,
                StopDistance = 5,
                OnComplete = function(ok)
                    success = ok or false
                    completed = true
                end
            })
        else
            Movement.teleportToTarget(targetObj.Position, {
                Mode = "Standard",
                OnComplete = function(ok)
                    success = ok or false
                    completed = true
                end
            })
        end

        local elapsed = 0
        while not completed and elapsed < 45 and State.AutoFarm.active and not State.AutoFarm.interrupted do
            task.wait(0.05)
            elapsed = elapsed + 0.05
        end

        if not completed and controller and controller.stop then
            controller.stop()
        end

        if success and not State.AutoFarm.interrupted then
            CharacterLock.lock(targetCFrame)
            State.AutoFarm.locked = true
        end

        return success and not State.AutoFarm.interrupted
    end

    function AutoFarmModule.doAction(actionType, expectedRegion)
        local ok, result = pcall(function()
            local pan = PanModule.equipPan()
            if not pan then
                return false
            end

            if PanModule.getRegion(HumanoidRootPart) ~= expectedRegion then
                return false
            end

            local killSwitch = function()
                return State.AutoFarm.active and not State.AutoFarm.interrupted
            end

            local r = PanModule.handleAction(State.AutoFarm.actionMode, actionType, true, killSwitch)
            return r ~= "MAX_RETRY_FAIL" and r ~= "KILLED"
        end)

        return ok and result
    end

    function AutoFarmModule.performTask(taskName, nextTask, targetCFrame, actionType, expectedRegion)
        TaskManager:setCurrentTask(taskName)
        TaskManager:setNextTask(nextTask)

        if not AutoFarmModule.moveToLocation(targetCFrame, actionType) then
            return false
        end

        task.wait(0.1)

        if State.AutoFarm.interrupted then
            return false
        end

        TaskManager:setCurrentTask(nextTask or actionType)
        TaskManager:setNextTask("AutoFarm")

        if not AutoFarmModule.doAction(actionType, expectedRegion) then
            return false
        end

        TaskManager:setCurrentTask("AutoFarm")
        return true
    end

    function AutoFarmModule.checkAndDoSell()
        if not State.Sell.autoSell then
            return
        end

        local shouldSell = false
        local mode = State.Sell.type or "Auto"

        if mode == "Auto" then
            shouldSell = SellModule.isBackpackAtCapacity()
        elseif mode == "Threshold" then
            shouldSell = SellModule.getInventoryCount() >= (tonumber(State.Sell.threshold) or 50)
        elseif mode == "Duration" then
            shouldSell = State.Sell._scheduledSell or
                             (os.clock() - (State.Sell._lastSell or 0) >= (tonumber(State.Sell.delay) or 300))
        end

        if shouldSell then
            if SellModule.sell({}, State.Sell.mode or "Teleport") then
                State.Sell._lastSell = os.clock()
                State.Sell._scheduledSell = false

                if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    CharacterLock.lock(Player.Character.HumanoidRootPart.CFrame)
                    State.AutoFarm.locked = true
                end
            end
        end
    end

    function AutoFarmModule.teardown()
        if State.AutoFarm.locked then
            CharacterLock.unlock()
            State.AutoFarm.locked = false
        end

        State.AutoFarm.interrupted = false
        State.AutoFarm.interruptReason = nil

        if TaskManager:getMainTask() == "AutoFarm" then
            TaskManager:finishTask("AutoFarm")
        end

        TaskManager:clearSubTasks()
        State.AutoFarm.running = false
    end

    function AutoFarmModule.pause(reason)
        if not (State.AutoFarm.active and State.AutoFarm.running) then
            return false
        end

        State.AutoFarm.interrupted = true
        State.AutoFarm.interruptReason = reason or "Pause"

        if State.AutoFarm.locked then
            CharacterLock.unlock()
            State.AutoFarm.locked = false
        end

        return true
    end

    function AutoFarmModule.resume(reason)
        if reason and State.AutoFarm.interruptReason and State.AutoFarm.interruptReason ~= reason then
            return false
        end

        if not State.AutoFarm.interrupted then
            State.AutoFarm.interruptReason = nil
            return false
        end

        State.AutoFarm.interrupted = false
        State.AutoFarm.interruptReason = nil
        return true
    end

    function AutoFarmModule.start()
        if State.AutoFarm.running then
            return
        end

        State.AutoFarm.active = true
        State.AutoFarm.running = true
        State.AutoFarm.interrupted = false
        State.AutoFarm.interruptReason = nil

        if not State.AutoFarm.travelMode or State.AutoFarm.travelMode == "" then
            Utility.createNotification("❌ Select travel mode!")
            State.AutoFarm.active = false
            State.AutoFarm.running = false
            return
        end

        if not State.AutoFarm.actionMode or State.AutoFarm.actionMode == "" then
            Utility.createNotification("❌ Select farming mode!")
            State.AutoFarm.active = false
            State.AutoFarm.running = false
            return
        end

        if not (State.AutoFarm.sandCFrame and State.AutoFarm.waterCFrame) then
            Utility.createNotification("❌ Set locations!")
            State.AutoFarm.active = false
            State.AutoFarm.running = false
            return
        end

        Utility.createNotification("🚀 Starting!")

        task.spawn(function()
            while State.AutoFarm.active do
                local acquired = TaskManager:requestTask("AutoFarm", 1)

                if acquired then
                    local hasTurn = TaskManager:waitForTurn("AutoFarm", 5)

                    if hasTurn then
                        local started = TaskManager:startTask("AutoFarm")

                        if started then
                            while State.AutoFarm.active and TaskManager:canRun("AutoFarm") do
                                if State.AutoFarm.interrupted then
                                    if State.AutoFarm.locked then
                                        CharacterLock.unlock()
                                        State.AutoFarm.locked = false
                                    end

                                    while State.AutoFarm.interrupted and State.AutoFarm.active do
                                        task.wait(0.1)
                                    end
                                end

                                local ok = pcall(function()
                                    local panStatus = PanModule.getStatus()
                                    if not panStatus then
                                        task.wait(0.05)
                                        return
                                    end

                                    AutoFarmModule.checkAndDoSell()

                                    if panStatus.isFull then
                                        if not AutoFarmModule.performTask("MovingToWater", "WashPan",
                                            State.AutoFarm.waterCFrame, "Wash", "Water") then
                                            if not State.AutoFarm.interrupted then
                                                State.AutoFarm.active = false
                                            end
                                        end
                                    else
                                        if not AutoFarmModule.performTask("MovingToSand", "DigSand",
                                            State.AutoFarm.sandCFrame, "Dig", "Deposit") then
                                            if not State.AutoFarm.interrupted then
                                                State.AutoFarm.active = false
                                            end
                                        end
                                    end
                                end)

                                if not ok then
                                    if State.AutoFarm.locked then
                                        CharacterLock.unlock()
                                        State.AutoFarm.locked = false
                                    end
                                    task.wait(0.05)
                                end

                                task.wait(0.01)
                            end

                            TaskManager:finishTask("AutoFarm")
                        else
                            task.wait(0.1)
                        end
                    end
                else
                    task.wait(0.1)
                end
            end

            AutoFarmModule.teardown()
            Utility.createNotification("🛑 Stopped")
        end)
    end

    function AutoFarmModule.stop()
        State.AutoFarm.active = false
        State.AutoFarm.interrupted = false
        State.AutoFarm.interruptReason = nil
    end
end

local HuntingModule = {}
do
    HuntingModule.geodeState = {
        isOpening = false,
        currentGeode = nil,
        startTime = nil,
        cachedInventoryCount = 0,
        cachedMaxCapacity = 0
    }

    HuntingModule.treasureState = {
        isHunting = false,
        mapsCompleted = 0,
        currentMap = nil,
        currentMapGUID = nil,
        previousShovelName = nil,
        previousShovelGUID = nil,
        startTime = nil
    }

    function HuntingModule.getInventoryCount()
        local count = 0
        for _, item in ipairs(BackpackTwo:GetChildren()) do
            local t = item:GetAttribute("ItemType")
            if t == "Valuable" or t == "Equipment" then
                count = count + 1
            end
        end
        local character = Character
        if character then
            local equipped = character:FindFirstChildOfClass("Tool")
            if equipped then
                local t = equipped:GetAttribute("ItemType")
                if t == "Valuable" or t == "Equipment" then
                    count = count + 1
                end
            end
        end
        return count
    end

    function HuntingModule.updateInventoryCache()
        HuntingModule.geodeState.cachedInventoryCount = HuntingModule.getInventoryCount()
        HuntingModule.geodeState.cachedMaxCapacity = Player:GetAttribute("InventorySize") or 100
    end

    function HuntingModule.getCachedInventoryCount()
        return HuntingModule.geodeState.cachedInventoryCount
    end

    function HuntingModule.getCachedMaxCapacity()
        return HuntingModule.geodeState.cachedMaxCapacity
    end

    function HuntingModule.isBackpackFull()
        return HuntingModule.getCachedInventoryCount() >= HuntingModule.getCachedMaxCapacity()
    end

    function HuntingModule.findGeodeInBackpack()
        for _, item in ipairs(BackpackTwo:GetChildren()) do
            if item.Name == "Geode" then
                return item
            end
        end
        return nil
    end

    function HuntingModule.isGeodeEquipped()
        if not Character then
            return false
        end
        for _, item in ipairs(Character:GetChildren()) do
            if item:GetAttribute("ItemType") == "Geode" then
                return true
            end
        end
        return false
    end

    function HuntingModule.isGeodeInHotbar()
        for _, item in ipairs(Player.Backpack:GetChildren()) do
            if item.Name == "Geode" then
                return true
            end
        end
        return false
    end

    function HuntingModule.waitForGeodeInCharacter(timeout)
        timeout = timeout or 50
        if not Character then
            return false
        end
        local elapsed = 0
        while elapsed < timeout do
            for _, item in ipairs(Character:GetChildren()) do
                if item:GetAttribute("ItemType") == "Geode" then
                    return true
                end
            end
            task.wait(0.01)
            elapsed = elapsed + 1
        end
        return false
    end

    function HuntingModule.isGeodeDepleted()
        if not Character then
            return true
        end
        for _, item in ipairs(Character:GetChildren()) do
            if item:GetAttribute("ItemType") == "Geode" then
                local stacks = item:GetAttribute("Stacks")
                if stacks and stacks > 0 then
                    return false
                end
            end
        end
        return true
    end

    function HuntingModule.waitForGeodes(maxWait)
        maxWait = maxWait or 30
        local elapsed = 0
        while elapsed < maxWait do
            if HuntingModule.findGeodeInBackpack() ~= nil then
                return true
            end
            task.wait(0.5)
            elapsed = elapsed + 0.5
        end
        return false
    end

    function HuntingModule.startGeodeOpening()
        if HuntingModule.geodeState.isOpening then
            return false
        end

        local geode = HuntingModule.findGeodeInBackpack()
        if not geode and not HuntingModule.isGeodeEquipped() and not HuntingModule.isGeodeInHotbar() then
            return false
        end

        HuntingModule.updateInventoryCache()
        HuntingModule.geodeState.isOpening = true
        HuntingModule.geodeState.startTime = tick()

        task.spawn(function()
            while HuntingModule.geodeState.isOpening do
                if HuntingModule.isBackpackFull() then
                    break
                end

                local geode = HuntingModule.findGeodeInBackpack()
                if not geode then
                    break
                end

                pcall(function()
                    ReplicatedStorage.Remotes.CustomBackpack.EquipRemote:FireServer(geode)
                end)

                if not HuntingModule.waitForGeodeInCharacter() then
                    break
                end

                local clickCount = 0
                while HuntingModule.geodeState.isOpening do
                    if HuntingModule.isGeodeDepleted() or HuntingModule.isBackpackFull() then
                        break
                    end
                    Services.VirtualUser:ClickButton1(Vector2.new(math.random(100, 900), math.random(100, 700)))
                    clickCount = clickCount + 1
                    if clickCount % 100 == 0 then
                        HuntingModule.updateInventoryCache()
                    end
                    task.wait(0.01)
                end
            end

            HuntingModule.geodeState.isOpening = false
            HuntingModule.geodeState.currentGeode = nil
        end)

        return true
    end

    function HuntingModule.stopGeodeOpening()
        HuntingModule.geodeState.isOpening = false
    end

    function HuntingModule.isGeodeOpening()
        return HuntingModule.geodeState.isOpening
    end

    function HuntingModule.getFormattedInventoryStatus()
        local toolUI = Player.PlayerGui:FindFirstChild("ToolUI")
        if toolUI then
            local fillingPan = toolUI:FindFirstChild("FillingPan")
            if fillingPan then
                local inventorySpace = fillingPan:FindFirstChild("InventorySpace")
                if inventorySpace and inventorySpace:IsA("TextLabel") then
                    return inventorySpace.Text
                end
            end
        end
        return "Inventory: N/A"
    end

    function HuntingModule.getPan()
        if not Character then
            return nil
        end
        local equipped = Character:FindFirstChildOfClass("Tool")
        if equipped and equipped:GetAttribute("ItemType") == "Pan" then
            return equipped
        end
        for _, v in ipairs(BackpackTwo:GetChildren()) do
            if v:GetAttribute("ItemType") == "Pan" then
                ReplicatedStorage.Remotes.CustomBackpack.EquipRemote:FireServer(v)
                task.wait(0.5)
                return v
            end
        end
        return nil
    end

    function HuntingModule.findNextMap()
        for _, v in ipairs(BackpackTwo:GetChildren()) do
            if v:GetAttribute("ItemType") == "TreasureMap" then
                return v
            end
        end
        return nil
    end

    function HuntingModule.findTool(predicate)
        local containers = {Character, Player.Backpack, BackpackTwo}
        for _, container in ipairs(containers) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") and predicate(item) then
                        return item
                    end
                end
            end
        end
        return nil
    end

    function HuntingModule.equipTool(tool)
        if not tool then
            return false
        end

        ReplicatedStorage.Remotes.CustomBackpack.EquipRemote:FireServer(tool)
        task.wait(0.35)
        return true
    end

    function HuntingModule.getEquippedShovel()
        if not Character then
            return nil
        end

        local equipped = Character:FindFirstChildOfClass("Tool")
        if equipped and (equipped:GetAttribute("ItemType") == "Shovel" or equipped.Name:find("Shovel")) then
            return equipped
        end
        return nil
    end

    function HuntingModule.storeCurrentShovel()
        local shovel = HuntingModule.getEquippedShovel()
        HuntingModule.treasureState.previousShovelName = shovel and shovel.Name or nil
        HuntingModule.treasureState.previousShovelGUID = shovel and shovel:GetAttribute("GUID") or nil
    end

    function HuntingModule.restoreStoredShovel()
        local guid = HuntingModule.treasureState.previousShovelGUID
        local name = HuntingModule.treasureState.previousShovelName

        if not guid and not name then
            return false
        end

        local shovel = HuntingModule.findTool(function(tool)
            return tool:GetAttribute("ItemType") == "Shovel" and
                       ((guid and tool:GetAttribute("GUID") == guid) or (name and tool.Name == name))
        end)

        HuntingModule.treasureState.previousShovelName = nil
        HuntingModule.treasureState.previousShovelGUID = nil
        return HuntingModule.equipTool(shovel)
    end

    function HuntingModule.prepareTreasureTool()
        HuntingModule.storeCurrentShovel()

        local rustyShovel = HuntingModule.findTool(function(tool)
            return tool.Name == "Rusty Shovel" or tool:GetAttribute("Name") == "Rusty Shovel"
        end)

        if rustyShovel then
            HuntingModule.equipTool(rustyShovel)
            return rustyShovel
        end

        return HuntingModule.getPan()
    end

    function HuntingModule.getTreasureCollectTool()
        local rustyShovel = HuntingModule.findTool(function(tool)
            return tool.Name == "Rusty Shovel" or tool:GetAttribute("Name") == "Rusty Shovel"
        end)

        if rustyShovel and rustyShovel.Parent ~= Character then
            HuntingModule.equipTool(rustyShovel)
        end

        local equipped = Character and Character:FindFirstChildOfClass("Tool") or nil
        if equipped and equipped:FindFirstChild("Scripts") and equipped.Scripts:FindFirstChild("Collect") then
            return equipped
        end

        return HuntingModule.getPan()
    end

    function HuntingModule.huntSingleMap(map)
        if not map or not map.Parent then
            return false
        end

        local location = map:GetAttribute("Location")
        if not location then
            return false
        end

        local mapGUID = map:GetAttribute("GUID")
        if not mapGUID then
            return false
        end

        local treasureTool = HuntingModule.getTreasureCollectTool()
        if not treasureTool then
            return false
        end

        local targetCFrame = typeof(location) == "CFrame" and location or CFrame.new(location)
        local collect = treasureTool:FindFirstChild("Scripts") and treasureTool.Scripts:FindFirstChild("Collect")

        if not collect then
            return false
        end

        local startTime = tick()
        local timeout = 120
        local lastCollectTime = 0

        while HuntingModule.treasureState.isHunting and (tick() - startTime) < timeout do
            local currentMap = BackpackTwo:FindFirstChild(map.Name)

            if not currentMap then
                task.wait(0.5)
                return true
            end

            if currentMap:GetAttribute("GUID") ~= mapGUID then
                task.wait(0.5)
                return true
            end

            if not Character or not Character:FindFirstChild("HumanoidRootPart") then
                break
            end

            Character.HumanoidRootPart.CFrame = targetCFrame

            if tick() - lastCollectTime > 0.02 then
                pcall(function()
                    collect:InvokeServer(0)
                end)
                lastCollectTime = tick()
            end

            task.wait(0.01)
        end

        return false
    end

    function HuntingModule.startTreasureHunting(options)
        options = options or {}
        if HuntingModule.treasureState.isHunting then
            return false
        end

        HuntingModule.treasureState.isHunting = true
        if not options.PreserveCount then
            HuntingModule.treasureState.mapsCompleted = 0
        end
        HuntingModule.treasureState.currentMap = nil
        HuntingModule.treasureState.currentMapGUID = nil
        HuntingModule.treasureState.startTime = tick()
        HuntingModule.prepareTreasureTool()

        task.spawn(function()
            while HuntingModule.treasureState.isHunting do
                local map = HuntingModule.findNextMap()
                if not map then
                    break
                end

                HuntingModule.treasureState.currentMap = map.Name
                HuntingModule.treasureState.currentMapGUID = map:GetAttribute("GUID")

                local success = HuntingModule.huntSingleMap(map)

                if success then
                    HuntingModule.treasureState.mapsCompleted = HuntingModule.treasureState.mapsCompleted + 1
                    task.wait(1)
                else
                    break
                end
            end

            HuntingModule.treasureState.isHunting = false
            HuntingModule.treasureState.currentMap = nil
            HuntingModule.treasureState.currentMapGUID = nil
            HuntingModule.restoreStoredShovel()
        end)

        return true
    end

    function HuntingModule.stopTreasureHunting()
        HuntingModule.treasureState.isHunting = false
        HuntingModule.treasureState.currentMap = nil
        HuntingModule.treasureState.currentMapGUID = nil
    end

    function HuntingModule.isTreasureHunting()
        return HuntingModule.treasureState.isHunting
    end

    function HuntingModule.getTreasureHuntStatus()
        return {
            isHunting = HuntingModule.treasureState.isHunting,
            mapsCompleted = HuntingModule.treasureState.mapsCompleted,
            currentMap = HuntingModule.treasureState.currentMap,
            currentMapGUID = HuntingModule.treasureState.currentMapGUID,
            duration = HuntingModule.treasureState.startTime and (tick() - HuntingModule.treasureState.startTime) or 0
        }
    end
end

local ServerUtilityModule = {}
do
    function ServerUtilityModule.rejoin()
        if #Services.Players:GetPlayers() <= 1 then
            Player:Kick("Rejoining...")
            task.wait()
            Services.TeleportService:Teleport(game.PlaceId, Player)
        else
            Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
        end
    end

    function ServerUtilityModule.serverHop()
        local servers = {}
        local req = Services.HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"))

        for _, v in pairs(req.data or {}) do
            if v.id ~= game.JobId and v.playing < v.maxPlayers then
                table.insert(servers, v.id)
            end
        end

        if #servers > 0 then
            Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(#servers)], Player)
        else
            Utility.createNotification("No available servers found", 4)
        end
    end

    function ServerUtilityModule.setupAntiAFK(enabled)
        local GC = getconnections or get_signal_cons

        if enabled then
            if GC then
                for _, c in pairs(GC(Player.Idled)) do
                    if c.Disable then
                        c:Disable()
                    end
                    if c.Disconnect then
                        c:Disconnect()
                    end
                end
            else
                local VirtualUser = cloneref and cloneref(game:GetService("VirtualUser")) or
                                        game:GetService("VirtualUser")
                getgenv().AntiAFKConnection = Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if getgenv().AntiAFKConnection then
                getgenv().AntiAFKConnection:Disconnect()
                getgenv().AntiAFKConnection = nil
            end
        end
    end
end

local WaypointModule = {}
do
    function WaypointModule.getList()
        local waypointFolder = Map:FindFirstChild("Waypoints")
        if not waypointFolder then
            return {}
        end

        local waypoints = {}
        for _, wp in pairs(waypointFolder:GetChildren()) do
            if wp:IsA("Model") then
                table.insert(waypoints, wp.Name)
            end
        end

        return waypoints
    end

    function WaypointModule.teleport(selection)
        local waypointFolder = Map:FindFirstChild("Waypoints")
        if not waypointFolder then
            return
        end

        local attr = Player:GetAttribute("CurrentArea")
        local currentWaypoint = nil

        for _, w in pairs(waypointFolder:GetChildren()) do
            if string.find(string.lower(attr), string.lower(w.Name)) then
                currentWaypoint = w
                break
            end
        end

        currentWaypoint = currentWaypoint or waypointFolder["Museum"]
        local targetWaypoint = waypointFolder:FindFirstChild(selection)

        if currentWaypoint and targetWaypoint then
            ReplicatedStorage.Remotes.Misc.FastTravel:FireServer(currentWaypoint, targetWaypoint)
        end
    end

    function WaypointModule.unlockAll()
        if not fireproximityprompt then
            return SimpleUI:CreateNotification({
                Title = "Not supported",
                Type = "Error",
                Description = "Your exploit does not support fireproximityprompt",
                Duration = 4
            })
        end

        local waypointFolder = Map:FindFirstChild("Waypoints")
        if not waypointFolder then
            return
        end

        local waypoints = waypointFolder:GetChildren()
        local FastTravelDataRemote = ReplicatedStorage.Remotes.Misc.GetFastTravelData
        local unlocked = {}

        FastTravelDataRemote.OnClientEvent:Connect(function(data)
            unlocked = data
        end)

        FastTravelDataRemote:FireServer()

        local function unlock(model)
            local prompt = model:FindFirstChild("WaypointPrompt", true)
            if not prompt then
                return
            end

            while unlocked[model.Name] ~= true do
                HumanoidRootPart.CFrame = model:GetPivot() + Vector3.new(0, 5, 0)
                fireproximityprompt(prompt)
                Services.RunService.Heartbeat:Wait()
            end
        end

        task.spawn(function()
            while true do
                for _, model in ipairs(waypoints) do
                    if not unlocked[model.Name] then
                        unlock(model)
                    end
                end

                task.wait(1)
                FastTravelDataRemote:FireServer()

                if next(unlocked) and not table.find(unlocked, false) then
                    break
                end
            end
        end)
    end
end

local BarrierRemovalModule = {}
do
    BarrierRemovalModule._states = {}

    local function rememberPart(cache, part)
        if cache[part] then
            return
        end

        cache[part] = {
            CanCollide = part.CanCollide,
            CanTouch = part.CanTouch,
            CanQuery = part.CanQuery,
            Transparency = part.Transparency
        }
    end

    function BarrierRemovalModule.getVines()
        return Map and Map:FindFirstChild("LushCaverns") and Map.LushCaverns:FindFirstChild("Vines")
    end

    function BarrierRemovalModule.getAbyssalGate()
        local abyssAssets = Map and Map:FindFirstChild("LushCaverns") and Map.LushCaverns:FindFirstChild("AbyssAssets")
        return abyssAssets and abyssAssets:FindFirstChild("Gate")
    end

    function BarrierRemovalModule.getMountainBlock()
        local mountains = Map and Map:FindFirstChild("Mountains")
        local added = mountains and mountains:FindFirstChild("Added")
        return added and added:FindFirstChild("GateBlockScript") and added.GateBlockScript:FindFirstChild("GateBlockage")
    end

    function BarrierRemovalModule.setBarrierEnabled(key, root, enabled)
        if not root then
            return false
        end

        local cache = BarrierRemovalModule._states[key] or {}
        BarrierRemovalModule._states[key] = cache

        local objects = root:IsA("BasePart") and {root} or root:GetDescendants()
        for _, object in ipairs(objects) do
            if object:IsA("BasePart") then
                if enabled then
                    local saved = cache[object]
                    if saved then
                        object.CanCollide = saved.CanCollide
                        object.CanTouch = saved.CanTouch
                        object.CanQuery = saved.CanQuery
                        object.Transparency = saved.Transparency
                    end
                else
                    rememberPart(cache, object)
                    object.CanCollide = false
                    object.CanTouch = false
                    object.CanQuery = false
                    object.Transparency = math.max(object.Transparency, 0.75)
                end
            end
        end

        if enabled then
            for part in pairs(cache) do
                if not part.Parent then
                    cache[part] = nil
                end
            end
        end

        return true
    end

    function BarrierRemovalModule.toggleVines(disabled)
        return BarrierRemovalModule.setBarrierEnabled("vines", BarrierRemovalModule.getVines(), not disabled)
    end

    function BarrierRemovalModule.toggleAbyssalGate(disabled)
        return BarrierRemovalModule.setBarrierEnabled("abyssalGate", BarrierRemovalModule.getAbyssalGate(), not disabled)
    end

    function BarrierRemovalModule.toggleMountainBlock(disabled)
        return BarrierRemovalModule.setBarrierEnabled("peakObstruction", BarrierRemovalModule.getMountainBlock(),
            not disabled)
    end

    function BarrierRemovalModule.removeCrocodiles()
        local crocsFolder = Map and Map:FindFirstChild("Crocodiles")
        if crocsFolder then
            crocsFolder:Destroy()
            Utility.createNotification("Crocodiles removed!")
            return
        end
        Utility.createNotification("Crocodiles not found, already removed?")
    end
end


local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PanjeGogo/Vdo/refs/heads/main/theme/gui.lua"))()

GUI:Build({
    SimpleUI = SimpleUI,
    PanModule = PanModule,
    Movement = Movement,
    SellModule = SellModule,
    ExcavationModule = ExcavationModule,
    GeodeModule = GeodeModule,
    RuneModule = RuneModule,
    CraftingModule = CraftingModule,
    EnchantModule = EnchantModule,
    FavouriteModule = FavouriteModule,
    ReforgeModule = ReforgeModule,
    FireflyModule = FireflyModule,
    ESPModule = ESPModule,
    InventoryFilterModule = InventoryFilterModule,
    AutoFarmModule = AutoFarmModule,
    HuntingModule = HuntingModule,
    ServerUtilityModule = ServerUtilityModule,
    WaypointModule = WaypointModule,
    BarrierRemovalModule = BarrierRemovalModule,
    CharacterLock = CharacterLock,
    MobileUIModule = MobileUIModule,
    Modifiers = Modifiers,
})
