--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/QP-Offcial/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end
local run = function(func)
	func()
end
local btext = function(text)
	return text..' '
end

local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end

local function getPlacedBlock(pos)
	if not pos then
		return
	end
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local vapeConnections
if shared.vapeConnections and type(shared.vapeConnections) == "table" then vapeConnections = shared.vapeConnections else vapeConnections = {}; shared.vapeConnections = vapeConnections; end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local lightingService = cloneref(game:GetService('Lighting'))
local marketplaceService = cloneref(game:GetService('MarketplaceService'))
local teleportService = cloneref(game:GetService('TeleportService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local groupService = cloneref(game:GetService('GroupService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local workspace = cloneref(game:GetService('Workspace'))
local debris = cloneref(game:GetService("Debris"))
local coreGui = cloneref(game:GetService('CoreGui'))
local collectionService = cloneref(game:GetService("CollectionService"))

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end
local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

local GuiLibrary = shared.GuiLibrary
local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local activeTweens = {}
local activeAnimationTrack = nil
local activeModel = nil
local emoteActive = false
 

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local XStore = {
	bedtable = {},
	Tweening = false,
	AntiHitting = false
}
XFunctions:SetGlobalData('XStore', XStore)

local function getrandomvalue(tab)
	return #tab > 0 and tab[math.random(1, #tab)] or ''
end

local function GetEnumItems(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

local isAlive = function(plr, healthblacklist)
	plr = plr or lplr
	local alive = false 
	if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
		alive = false
	end
	return alive
end
local function GetMagnitudeOf2Objects(part, part2, bypass)
	local magnitude, partcount = 0, 0
	if not bypass then 
		local suc, res = pcall(function() return part.Position end)
		partcount = suc and partcount + 1 or partcount
		suc, res = pcall(function() return part2.Position end)
		partcount = suc and partcount + 1 or partcount
	end
	if partcount > 1 or bypass then 
		magnitude = bypass and (part - part2).magnitude or (part.Position - part2.Position).magnitude
	end
	return magnitude
end
local function createSequence(args)
    local seq =
        ColorSequence.new(
        {
            ColorSequenceKeypoint.new(args[1], args[2]),
            ColorSequenceKeypoint.new(args[3], args[4])
        }
    )
    return seq
end
local function GetTopBlock(position, smart, raycast, customvector)
	position = position or isAlive(lplr, true) and lplr.Character:WaitForChild("HumanoidRootPart").Position
	if not position then 
		return nil 
	end
	if raycast and not game.Workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = game.Workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and game.Workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end
local function FindEnemyBed(maxdistance, highest)
	local target = nil
	local distance = maxdistance or math.huge
	local whitelistuserteams = {}
	local badbeds = {}
	if not lplr:GetAttribute("Team") then return nil end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr then
			local type, attackable = vape.Libraries.whitelist:get(v)
			if not attackable then
				whitelistuserteams[v:GetAttribute("Team")] = true
			end
		end
	end
	for i,v in pairs(collectionService:GetTagged("bed")) do
			local bedteamstring = string.split(v:GetAttribute("id"), "_")[1]
			if whitelistuserteams[bedteamstring] ~= nil then
			   badbeds[v] = true
		    end
	    end
	for i,v in pairs(collectionService:GetTagged("bed")) do
		if v:GetAttribute("id") and v:GetAttribute("id") ~= lplr:GetAttribute("Team").."_bed" and badbeds[v] == nil and lplr.Character and lplr.Character.PrimaryPart then
			if v:GetAttribute("NoBreak") or v:GetAttribute("PlacedByUserId") and v:GetAttribute("PlacedByUserId") ~= 0 then continue end
			local magdist = GetMagnitudeOf2Objects(lplr.Character.PrimaryPart, v)
			if magdist < distance then
				target = v
				distance = magdist
			end
		end
	end
	local coveredblock = highest and target and GetTopBlock(target.Position, true)
	if coveredblock then
		target = coveredblock.Instance
	end
	for i,v in pairs(game:GetService("Teams"):GetTeams()) do
		if target and v.TeamColor == target.Bed.BrickColor then
			XStore.bedtable[target] = v.Name
		end
	end
	return target
end
local function FindTeamBed()
	local bedstate, res = pcall(function()
		return lplr.leaderstats.Bed.Value
	end)
	return bedstate and res and res ~= nil and res == "✅"
end
local function FindItemDrop(item)
	local itemdist = nil
	local dist = math.huge
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
    for i,v in pairs(collectionService:GetTagged("ItemDrop")) do
		if v and v.Name == item and abletocalculate() then
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v)
			if itemdistance < dist then
			itemdist = v
			dist = itemdistance
		end
		end
	end
	return itemdist
end

local function getItem(itemName, inv)
	for slot, item in (inv or store.inventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
	if not argument then
    local suc, res = pcall(function()
    local notification = GuiLibrary:CreateNotification(title or "QP Vape", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
    notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
    notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    if moduledisable and (module and vape.Modules[module].Enabled) then vape.Modules[module]:Toggle(false) end
    end)
    if hault then while true do task.wait() end end end
end

local function spinParts(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "Middle" or part.Name == "Outer") then
            local tweenInfo, goal
            if part.Name == "Middle" then
                tweenInfo = TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, -360, 0) }
            elseif part.Name == "Outer" then
                tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
                goal = { Orientation = part.Orientation + Vector3.new(0, 360, 0) }
            end
 
            local tween = tweenService:Create(part, tweenInfo, goal)
            tween:Play()
            table.insert(activeTweens, tween)
        end
    end
end
 
local function placeModelUnderLeg()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
 
    if humanoidRootPart then
        local assetsFolder = replicatedStorage:FindFirstChild("Assets")
        if assetsFolder then
            local effectsFolder = assetsFolder:FindFirstChild("Effects")
            if effectsFolder then
                local modelTemplate = effectsFolder:FindFirstChild("NightmareEmote")
                if modelTemplate and modelTemplate:IsA("Model") then
                    local clonedModel = modelTemplate:Clone()
                    clonedModel.Parent = workspace
 
                    if clonedModel.PrimaryPart then
                        clonedModel:SetPrimaryPartCFrame(humanoidRootPart.CFrame - Vector3.new(0, 3, 0))
                    else
                        warn("PrimaryPart not set for NightmareEmote model!")
                        return
                    end
 
                    spinParts(clonedModel)
                    activeModel = clonedModel
                else
                    warn("NightmareEmote model not found or is not a valid model!")
                end
            else
                warn("Effects folder not found in Assets!")
            end
        else
            warn("Assets folder not found in ReplicatedStorage!")
        end
    else
        warn("HumanoidRootPart not found in character!")
    end
end
 
local function playAnimation(animationId)
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        activeAnimationTrack = animator:LoadAnimation(animation)
        activeAnimationTrack:Play()
    else
        warn("Humanoid not found in character!")
    end
end
 
local function stopEffects()
    for _, tween in ipairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
 
    if activeAnimationTrack then
        activeAnimationTrack:Stop()
        activeAnimationTrack = nil
    end
 
    if activeModel then
        activeModel:Destroy()
        activeModel = nil
    end
 
    emoteActive = false
end
 
local function monitorWalking()
    local player = playersService.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
 
    if humanoid then
        humanoid.Running:Connect(function(speed)
            if speed > 0 and emoteActive then
                stopEffects()
            end
        end)
    else
        warn("Humanoid not found in character!")
    end
end
 
local function activateNightmareEmote()
    if emoteActive then
        return
    end
 
    emoteActive = true
    local success, err = pcall(function()
        monitorWalking()
        placeModelUnderLeg()
        playAnimation("rbxassetid://9191822700")
    end)
 
    if not success then
        warn("Error occurred: " .. tostring(err))
        emoteActive = false
    end
end




run(function()
    local InfiniteJump
    local Velocity
    InfiniteJump = vape.Categories.Modules:CreateModule({
        Name = "InfiniteJump",
        Function = function(callback)
            if callback then
				InfiniteJump:Clean(inputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end
					if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
						while inputService:IsKeyDown(Enum.KeyCode.Space) do
							local PrimaryPart = lplr.Character.PrimaryPart
							if entitylib.isAlive and PrimaryPart then
								PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
							end
							wait()
						end
					end
				end))
				if inputService.TouchEnabled then
					local Jumping = false
					local JumpButton = lplr.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
					
					InfiniteJump:Clean(JumpButton.MouseButton1Down:Connect(function()
						Jumping = true
					end))

					InfiniteJump:Clean(JumpButton.MouseButton1Up:Connect(function()
						Jumping = false
					end))

					InfiniteJump:Clean(runService.RenderStepped:Connect(function()
						if Jumping and entitylib.isAlive then
							local PrimaryPart = lplr.Character.PrimaryPart
							PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
						end
					end))
				end
			end
        end,
        Tooltip = "Allows infinite jumping"
    })
    Velocity = InfiniteJump:CreateSlider({
        Name = 'Velocity',
        Min = 50,
        Max = 300,
        Default = 50
    })
end)

run(function()
	local InfernalKill = {Enabled = false}
	InfernalKill = vape.Categories.Modules:CreateModule({
		["Name"] = "EmberExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					local tmp = getItem("infernal_saber")
					if tmp then
						bedwars.Client:Get('HellBladeRelease'):SendToServer({
							weapon = tmp.tool;
							player = game:GetService("Players").LocalPlayer;
							chargeTime = 0.9;
						})
					end
				until not InfernalKill["Enabled"]
			end
		end,
		["Description"] = "Ember Exploit"
	})
end)

run(function()
	local SkyScytheKill = {Enabled = false}
	SkyScytheKill = vape.Categories.Modules:CreateModule({
		["Name"] = "SkyScytheExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					if getItem("sky_scythe") then
						bedwars.Client:Get('SkyScytheSpin'):SendToServer()
					end
				until not SkyScytheKill["Enabled"]
			end
		end,
		["Description"] = "SkyScytheExploit"
	})
end)

run(function()
	local PartyPopperExploit = {Enabled = false}
	PartyPopperExploit = vape.Categories.Modules:CreateModule({
		["Name"] = "PartyPopperExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					bedwars.AbilityController:useAbility('PARTY_POPPER')
				until not PartyPopperExploit["Enabled"]
			end
		end,
		["Description"] = "PartyPopperExploit"
	})
end)

run(function()
	local TrainWhistleExploit = {Enabled = false}
	TrainWhistleExploit = vape.Categories.Modules:CreateModule({
		["Name"] = "TrainWhistleExploit",
		["Function"] = function(callback)
			if callback then
				repeat
					wait()
					bedwars.AbilityController:useAbility('TRAIN_WHISTLE')
				until not TrainWhistleExploit["Enabled"]
			end
		end,
		["Description"] = "TrainWhistleExploit"
	})
end)


-- patched
-- run(function()
-- 	local ProjectileExploit = {Enabled = false}
-- 	local old
-- 	ProjectileExploit = vape.Categories.Modules:CreateModule({
-- 		["Name"] = "ProjectileExploit",
-- 		["Function"] = function(callback)
-- 			if callback then
-- 				old = hookmetamethod(game, "__namecall", function(self, ...)
-- 					if self == replicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ProjectileFire and not checkcaller() then
-- 						local args = {...}
-- 						args[8].drawDurationSeconds = 0/0
-- 					end
-- 					return old(self, ...)
-- 				end)
-- 			else
-- 				if old then
-- 					hookmetamethod(game, '__namecall', old)
-- 				end
-- 			end
-- 		end,
-- 		["Description"] = "ProjectileExploit Thanks Retro.gone"
-- 	})
-- end)

-- patched
-- run(function()
-- 	local SkollKitCrasher = {Enabled = false}
-- 	SkollKitCrasher = vape.Categories.Modules:CreateModule({
-- 		["Name"] = "SkollKitCrasher",
-- 		["Function"] = function(callback)
-- 			if callback then
-- 				repeat
-- 					task.wait()
-- 					game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("VoidHunter_MarkAbilityRequest"):FireServer({
-- 						direction = Vector3.zero;
-- 					})
-- 				until not SkollKitCrasher["Enabled"]
-- 			end
-- 		end,
-- 		["Description"] = "SkollKitCrasher"
-- 	})
-- end)
-- run(function()
-- 	local AntiSkollKitCrasher = {Enabled = false}
-- 	AntiSkollKitCrasher = vape.Categories.Modules:CreateModule({
-- 		["Name"] = "AntiSkollKitCrasher",
-- 		["Function"] = function(callback)
-- 			if callback then
-- 				for i,v in next, getgc() do
-- 					if type(v) == 'function' and debug.info(v,"n") == "useMarkAbility" then
-- 						local RateLimit = {}
-- 						local old
-- 						old = hookfunction(v,function(...)
-- 							local args = {...}
-- 							if not RateLimit[args[2]] then
-- 								RateLimit[args[2]] = tick()
-- 								return old(...)
-- 							elseif RateLimit[args[2]] + 10 < tick() then
-- 								RateLimit[args[2]] = tick()
-- 								return old(...)
-- 							end
-- 						end)
-- 						break
-- 					end
-- 				end
-- 			end
-- 		end,
-- 		["Description"] = "AntiSkollKitCrasher"
-- 	})
-- end)

run(function()
    local NightmareEventButton
    NightmareEventButton = vape.Categories.Modules:CreateModule({
        Name = "Nightmare Emote",
        Description = "Play Nightmare Emote",
        Function = function(callback)
            if callback then
                NightmareEventButton:Toggle(false)
                activateNightmareEmote()
            end
        end
    })
end)

run(function()
    local AdetundeExploit
    local AdetundeExploit_List

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

    AdetundeExploit = vape.Categories.Modules:CreateModule({
        Name = 'AdetundeExploit',
        Function = function(calling)
            if calling then 
                -- Check if in testing mode or equipped kit
                -- if tostring(shared.store.queueType) == "training_room" or shared.store.equippedKit == "adetunde" then
                --     AdetundeExploit["ToggleButton"](false) 
                --     current_upgrador = AdetundeExploit_List.Value
                task.spawn(function()
                    repeat
                        local returning_table = adetunde_remotes[current_upgrador]()
                        
                        if type(returning_table) == "table" then
                            local Speed = returning_table["speed"]
                            local Strength = returning_table["strength"]
                            local Shield = returning_table["shield"]

                            print("Speed: " .. tostring(Speed))
                            print("Strength: " .. tostring(Strength))
                            print("Shield: " .. tostring(Shield))
                            print("Current Upgrador: " .. tostring(current_upgrador))

                            if returning_table[string.lower(current_upgrador)] == 3 then
                                if Strength and Shield and Speed then
                                    if Strength == 3 or Speed == 3 or Shield == 3 then
                                        if (Strength == 3 and Speed == 2 and Shield == 2) or
                                           (Strength == 2 and Speed == 3 and Shield == 2) or
                                           (Strength == 2 and Speed == 2 and Shield == 3) then
                                            -- warningNotification("AdetundeExploit", "Fully upgraded everything possible!", 7)
                                            hasnt_upgraded_everything = false
                                        else
                                            local things = {}
                                            for i, v in pairs(adetunde_remotes) do
                                                table.insert(things, i)
                                            end
                                            for i, v in pairs(things) do
                                                if things[i] == current_upgrador then
                                                    table.remove(things, i)
                                                end
                                            end
                                            local random = things[math.random(1, #things)]
                                            current_upgrador = random
                                        end
                                    end
                                end
                            end
                        else
                            local things = {}
                            for i, v in pairs(adetunde_remotes) do
                                table.insert(things, i)
                            end
                            for i, v in pairs(things) do
                                if things[i] == current_upgrador then
                                    table.remove(things, i)
                                end
                            end
                            local random = things[math.random(1, #things)]
                            current_upgrador = random
                        end
                        task.wait(0.1)
                    until not AdetundeExploit.Enabled or not hasnt_upgraded_everything
                end)
                -- else
                --     AdetundeExploit["ToggleButton"](false)
                --     warningNotification("AdetundeExploit", "Kit required or you need to be in testing mode", 5)
                -- end
            end
        end
    })

    local real_list = {}
    for i, v in pairs(adetunde_remotes) do
        table.insert(real_list, i)
    end

    AdetundeExploit_List = AdetundeExploit:CreateDropdown({
        Name = 'Preferred Upgrade',
        List = real_list,
        Function = function() end,
        Default = "Shield"
    })
end)

run(function()
	local NoNameTag
	NoNameTag = vape.Categories.Modules:CreateModule({
		PerformanceModeBlacklisted = true,
		Name = 'NoNameTag',
        Tooltip = 'Removes your NameTag.',
		Function = function(callback)
			if callback then
				NoNameTag:Clean(runService.RenderStepped:Connect(function()
					pcall(function()
						lplr.Character.Head.Nametag:Destroy()
					end)
				end))
			end
		end,
        Default = false
	})
end)

run(function()
	local DamageIndicator = {}
	local DamageIndicatorColorToggle = {}
	local DamageIndicatorColor = {Hue = 0, Sat = 0, Value = 0}
	local DamageIndicatorTextToggle = {}
	local DamageIndicatorText = {ListEnabled = {}}
	local DamageIndicatorFontToggle = {}
	local DamageIndicatorFont = {Value = 'GothamBlack'}
	local DamageIndicatorTextObjects = {}
    local DamageIndicatorMode1
    local DamageMessages = {
		'Pow!',
		'Pop!',
		'Hit!',
		'Smack!',
		'Bang!',
		'Boom!',
		'Whoop!',
		'Damage!',
		'-9e9!',
		'Whack!',
		'Crash!',
		'Slam!',
		'Zap!',
		'Snap!',
		'Thump!'
	}
	local RGBColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 127, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(148, 0, 211)
	}
	local orgI, mz, vz = 1, 5, 10
    local DamageIndicatorMode = {Value = 'Rainbow'}
	local DamageIndicatorMode2 = {Value = 'Gradient'}
	DamageIndicator = vape.Categories.Modules:CreateModule({
        PerformanceModeBlacklisted = true,
		Name = 'DamageIndicator',
		Function = function(calling)
			if calling then
				task.spawn(function()
					table.insert(DamageIndicator.Connections, workspace.DescendantAdded:Connect(function(v)
						pcall(function()
                            if v.Name ~= 'DamageIndicatorPart' then return end
							local indicatorobj = v:FindFirstChildWhichIsA('BillboardGui'):FindFirstChildWhichIsA('Frame'):FindFirstChildWhichIsA('TextLabel')
							if indicatorobj then
                                if DamageIndicatorColorToggle.Enabled then
                                    -- indicatorobj.TextColor3 = Color3.fromHSV(DamageIndicatorColor.Hue, DamageIndicatorColor.Sat, DamageIndicatorColor.Value)
                                    if DamageIndicatorMode.Value == 'Rainbow' then
                                        if DamageIndicatorMode2.Value == 'Gradient' then
                                            indicatorobj.TextColor3 = Color3.fromHSV(tick() % mz / mz, orgI, orgI)
                                        else
                                            runService.Stepped:Connect(function()
                                                orgI = (orgI % #RGBColors) + 1
                                                indicatorobj.TextColor3 = RGBColors[orgI]
                                            end)
                                        end
                                    elseif DamageIndicatorMode.Value == 'Custom' then
                                        indicatorobj.TextColor3 = Color3.fromHSV(
                                            DamageIndicatorColor.Hue, 
                                            DamageIndicatorColor.Sat, 
                                            DamageIndicatorColor.Value
                                        )
                                    else
                                        indicatorobj.TextColor3 = Color3.fromRGB(127, 0, 255)
                                    end
                                end
                                if DamageIndicatorTextToggle.Enabled then
                                    if DamageIndicatorMode1.Value == 'Custom' then
                                        print(getrandomvalue(DamageIndicatorText.ListEnabled))
                                        local o = getrandomvalue(DamageIndicatorText.ListEnabled)
                                        indicatorobj.Text = o ~= '' and o or indicatorobj.Text
									elseif DamageIndicatorMode1.Value == 'Multiple' then
										indicatorobj.Text = DamageMessages[math.random(orgI, #DamageMessages)]
									else
										indicatorobj.Text = 'Render Intents on top!'
									end
								end
								indicatorobj.Font = DamageIndicatorFontToggle.Enabled and Enum.Font[DamageIndicatorFont.Value] or indicatorobject.Font
							end
						end)
					end))
				end)
			end
		end
	})
    DamageIndicatorMode = DamageIndicator:CreateDropdown({
		Name = 'Color Mode',
		List = {
			'Rainbow',
			'Custom',
			'Lunar'
		},
		HoverText = 'Mode to color the Damage Indicator',
		Value = 'Rainbow',
		Function = function() end
	})
	DamageIndicatorMode2 = DamageIndicator:CreateDropdown({
		Name = 'Rainbow Mode',
		List = {
			'Gradient',
			'Paint'
		},
		HoverText = 'Mode to color the Damage Indicator\nwith Rainbow Color Mode',
		Value = 'Gradient',
		Function = function() end
	})
    DamageIndicatorMode1 = DamageIndicator:CreateDropdown({
		Name = 'Text Mode',
		List = {
            'Custom',
			'Multiple',
			'Lunar'
		},
		HoverText = 'Mode to change the Damage Indicator Text',
		Value = 'Custom',
		Function = function() end
	})
	DamageIndicatorColorToggle = DamageIndicator:CreateToggle({
		Name = 'Custom Color',
		Function = function(calling) pcall(function() DamageIndicatorColor.Object.Visible = calling end) end
	})
	DamageIndicatorColor = DamageIndicator:CreateColorSlider({
		Name = 'Text Color',
		Function = function() end
	})
	DamageIndicatorTextToggle = DamageIndicator:CreateToggle({
		Name = 'Custom Text',
		HoverText = 'random messages for the indicator',
		Function = function(calling) pcall(function() DamageIndicatorText.Object.Visible = calling end) end
	})
	DamageIndicatorText = DamageIndicator:CreateTextList({
		Name = 'Text',
		TempText = 'Indicator Text',
		AddFunction = function() end
	})
	DamageIndicatorFontToggle = DamageIndicator:CreateToggle({
		Name = 'Custom Font',
		Function = function(calling) pcall(function() DamageIndicatorFont.Object.Visible = calling end) end
	})
	DamageIndicatorFont = DamageIndicator:CreateDropdown({
		Name = 'Font',
		List = GetEnumItems('Font'),
		Function = function() end
	})
	DamageIndicatorColor.Object.Visible = DamageIndicatorColorToggle.Enabled
	DamageIndicatorText.Object.Visible = DamageIndicatorTextToggle.Enabled
	DamageIndicatorFont.Object.Visible = DamageIndicatorFontToggle.Enabled
end)

run(function()
	local HealthbarVisuals = {};
	local HealthbarRound = {};
	local HealthbarColorToggle = {};
	local HealthbarGradientToggle = {};
	local HealthbarGradientColor = {};
	local HealthbarHighlight = {};
	local HealthbarHighlightColor = newcolor();
	local HealthbarGradientRotation = {Value = 0};
	local HealthbarTextToggle = {};
	local HealthbarFontToggle = {};
	local HealthbarTextColorToggle = {};
	local HealthbarBackgroundToggle = {};
	local HealthbarText = {ListEnabled = {}};
	local HealthbarInvis = {Value = 0};
	local HealthbarRoundSize = {Value = 4};
	local HealthbarFont = {value = 'LuckiestGuy'};
	local HealthbarColor = newcolor();
	local HealthbarBackground = newcolor();
	local HealthbarTextColor = newcolor();
	local healthbarobjects = Performance.new();
	local oldhealthbar;
	local healthbarhighlight;
	local textconnection;
	local function healthbarFunction()
		if not HealthbarVisuals.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar;
			healthbar.Transparency = (0.1 * HealthbarInvis.Value);
			healthbar.BackgroundColor3 = (HealthbarColorToggle.Enabled and Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value) or healthbar.BackgroundColor3)
			if HealthbarGradientToggle.Enabled then 
				healthbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = (healthbar:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', healthbar))
				gradient.Color = createSequence({0, Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value), 1, Color3.fromHSV(HealthbarGradientColor.Hue, HealthbarGradientColor.Sat, HealthbarGradientColor.Value)})
				gradient.Rotation = HealthbarGradientRotation.Value
				table.insert(healthbarobjects, gradient)
			end
			for i,v in healthbar.Parent:GetChildren() do 
				if v:IsA('Frame') and v:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then
					local corner = Instance.new('UICorner', v);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end
			end
			local healthbarbackground = ({pcall(function() return healthbar.Parent.Parent end)})[2]
			if healthbarbackground and type(healthbarbackground) == 'userdata' then
				healthbar.Transparency = (0.1 * HealthbarInvis.Value);
				if HealthbarHighlight.Enabled then 
					local highlight = Instance.new('UIStroke', healthbarbackground);
					highlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value);
					highlight.Thickness = 1.6; 
					healthbarhighlight = highlight
				end
				if healthbar.Parent.Parent:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					local corner = Instance.new('UICorner', healthbar.Parent.Parent);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end 
				if HealthbarBackgroundToggle.Enabled then
					healthbarbackground.BackgroundColor3 = Color3.fromHSV(HealthbarBackground.Hue, HealthbarBackground.Sat, HealthbarBackground.Value)
				end
			end
			local healthbartext = ({pcall(function() return healthbar.Parent.Parent['1'] end)})[2]
			if healthbartext and type(healthbartext) == 'userdata' then 
				local randomtext = getrandomvalue(HealthbarText.ListEnabled)
				if HealthbarTextColorToggle.Enabled then
					healthbartext.TextColor3 = Color3.fromHSV(HealthbarTextColor.Hue, HealthbarTextColor.Sat, HealthbarTextColor.Value)
				end
				if HealthbarFontToggle.Enabled then 
					healthbartext.Font = Enum.Font[HealthbarFont.Value]
				end
				if randomtext ~= '' and HealthbarTextToggle.Enabled then 
					healthbartext.Text = randomtext:gsub('<health>', isAlive(lplr, true) and tostring(math.round(lplr.Character:GetAttribute('Health') or 0)) or '0')
				else
					pcall(function() healthbartext.Text = tostring(lplr.Character:GetAttribute('Health')) end)
				end
				if not textconnection then 
					textconnection = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
						local randomtext = getrandomvalue(HealthbarText.ListEnabled)
						if randomtext ~= '' then 
							healthbartext.Text = randomtext:gsub('<health>', isAlive() and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
						else
							pcall(function() healthbartext.Text = tostring(math.floor(lplr.Character:GetAttribute('Health'))) end)
						end
					end)
				end
			end
		end
	end
	HealthbarVisuals = vape.Categories.Modules:CreateModule({
		Name = 'HealthbarVisuals',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HealthbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							healthbarFunction()
						end
					end))
					healthbarFunction()
				end)
			else
				pcall(function() textconnection:Disconnect() end)
				pcall(function() oldhealthbar.Parent.Parent.BackgroundColor3 = Color3.fromRGB(41, 51, 65) end)
				pcall(function() oldhealthbar.BackgroundColor3 = Color3.fromRGB(203, 54, 36) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Text = tostring(lplr.Character:GetAttribute('Health')) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].TextColor3 = Color3.fromRGB(255, 255, 255) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Font = Enum.Font.LuckiestGuy end)
				oldhealthbar = nil
				textconnection = nil
				for i,v in healthbarobjects do 
					pcall(function() v:Destroy() end)
				end
				table.clear(healthbarobjects);
				pcall(function() healthbarhighlight:Destroy() end);
				healthbarhighlight = nil;
			end
		end
	})
	HealthbarColorToggle = HealthbarVisuals:CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(calling)
			pcall(function() HealthbarColor.Object.Visible = calling end)
			pcall(function() HealthbarGradientToggle.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarGradientToggle = HealthbarVisuals:CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Main Color',
		Function = function()
			task.spawn(healthbarFunction)
		end
	})
	HealthbarGradientColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Secondary Color',
		Function = function(calling)
			if HealthbarGradientToggle.Enabled then 
				task.spawn(healthbarFunction)
			end
		end
	})
	HealthbarBackgroundToggle = HealthbarVisuals:CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() HealthbarBackground.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarBackground = HealthbarVisuals:CreateColorSlider({
		Name = 'Background Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarTextToggle = HealthbarVisuals:CreateToggle({
		Name = 'Text',
		Function = function(calling)
			pcall(function() HealthbarText.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarText = HealthbarVisuals:CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end,
		RemoveFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarTextColorToggle = HealthbarVisuals:CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() HealthbarTextColor.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarTextColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Text Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarFontToggle = HealthbarVisuals:CreateToggle({
		Name = 'Text Font',
		Function = function(calling)
			pcall(function() HealthbarFont.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end 
	})
	HealthbarFont = HealthbarVisuals:CreateDropdown({
		Name = 'Text Font',
		List = GetEnumItems('Font'),
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarRound = HealthbarVisuals:CreateToggle({
		Name = 'Round',
		Function = function(calling)
			pcall(function() HealthbarRoundSize.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarRoundSize = HealthbarVisuals:CreateSlider({
		Name = 'Corner Size',
		Min = 1,
		Max = 20,
		Default = 5,
		Function = function(value)
			if HealthbarVisuals.Enabled then 
				pcall(function() 
					oldhealthbar.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value);
					oldhealthbar.Parent.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value)  
				end)
			end
		end
	})
	HealthbarHighlight = HealthbarVisuals:CreateToggle({
		Name = 'Highlight',
		Function = function(calling)
			pcall(function() HealthbarHighlightColor.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals:Toggle()
				HealthbarVisuals:Toggle()
			end
		end
	})
	HealthbarHighlightColor = HealthbarVisuals:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			if HealthbarVisuals.Enabled then 
				pcall(function() healthbarhighlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value) end)
			end
		end
	})
	HealthbarInvis = HealthbarVisuals:CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Function = function(value)
			pcall(function() 
				oldhealthbar.Transparency = (0.1 * value);
				oldhealthbar.Parent.Parent.Transparency = (0.1 * HealthbarInvis.Value); 
			end)
		end
	})
	HealthbarBackground.Object.Visible = false;
	HealthbarText.Object.Visible = false;
	HealthbarTextColor.Object.Visible = false;
	HealthbarFont.Object.Visible = false;
	HealthbarRoundSize.Object.Visible = false;
	HealthbarHighlightColor.Object.Visible = false;
end)

run(function()
	local PlayerViewModel = {};
    local viewmodelMode = {};
	local viewmodel = Performance.new()
	local reModel = function(entity)
		for i,v in entity.Character:GetChildren() do
			if v:IsA('BasePart') or v:IsA('Accessory') then
				pcall(function() v.Transparency = 1 end)
			end
		end
		local part = Instance.new("Part", entity.Character)
		part.CanCollide = false

		local mesh = Instance.new("SpecialMesh", part)
		mesh.MeshId = viewmodelMode.Value == 'Among Us' and 'http://www.roblox.com/asset/?id=6235963214' or 'http://www.roblox.com/asset/?id=13004256866'
		mesh.TextureId = viewmodelMode.Value == 'Among Us' and 'http://www.roblox.com/asset/?id=6235963270' or 'http://www.roblox.com/asset/?id=13004256905'
		mesh.Offset = viewmodelMode.Value == 'Rabbit' and Vector3.new(0,1.6,0) or Vector3.new(0,0.3,0)
		mesh.Scale = viewmodelMode.Value == 'Rabbit' and Vector3.new(10, 8, 10) or Vector3.new(0.11, 0.11, 0.11)

		local weld = Instance.new("Weld", part)
		weld.Part0 = part
		weld.Part1 = part.Parent.UpperTorso or part.Parent.Torso
		
		table.insert(viewmodel, task.spawn(function()
			viewmodel[entity.Name] = part
		end))
	end;
	local removeModel = function(ent)
        viewmodel[ent.Name]:Remove()
        for i,v in ent.Character:GetChildren() do
            if v:IsA('BasePart') or v:IsA('Accessory') then
                pcall(function() 
                    if v ~= ent.Character.PrimaryPart then 
                        v.Transparency = 0 
                    end 
                end)
            end
        end
        viewmodel[ent.Name] = nil
		task.wait(1)
	end
	PlayerViewModel = vape.Categories.Modules:CreateModule({
		Name = 'PlayerViewModel',
		Function = function(call)
			if call then
				for i,v in playersService:GetPlayers() do
					table.insert(PlayerViewModel.Connections, v.CharacterAdded:Connect(function()
						pcall(function() removeModel(v) end)
						task.spawn(pcall, reModel, v)
					end))
				end
				table.insert(PlayerViewModel.Connections, playersService.PlayerAdded:Connect(function(v)
					table.insert(PlayerViewModel.Connections, v.CharacterAdded:Connect(function()
						task.spawn(pcall, removeModel, v)
						task.spawn(pcall, reModel, v)
					end))
				end))
				RunLoops:BindToHeartbeat('PlayerVM', function()
					for i,v in playersService:GetPlayers() do
						if isAlive(v) and not viewmodel[v.Name] then
                            if not PlayerViewModel.Enabled then break end
							task.spawn(pcall, reModel, v)
						end
					end
				end)
			else
                RunLoops:UnbindFromHeartbeat('PlayerVM')
                for i,v in playersService:GetPlayers() do
                    task.spawn(pcall, removeModel, v)
                end
			end
		end,
		HoverText = 'Turns you into a curtain model'
	})
    viewmodelMode = PlayerViewModel:CreateDropdown({
        Name = 'Model',
        List = {'Among Us', 'Rabbit'},
        Function = function()
			PlayerViewModel:Toggle()
        end,
        Default = 'Among Us'
    })
end);


run(function()
	local queuecardvisuals = {};
	local queucardvisualsgradientoption = {};
	local queuecardvisualhighlight = {};
	local queuecardmodshighlightcolor = newcolor();
	local queuecardvisualscolor = newcolor();
	local queuecardvisualscolor2 = newcolor();
	local queuecardobjects = Performance.new();
	local queuecardvisualsround = {Value = 4};
	local queuecardfunc: () -> () = function()
		if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end;
		if not queuecardvisuals.Enabled then return end;
		local card: Frame = lplr.PlayerGui.QueueApp:WaitForChild('1', math.huge);
		local cardcorner: UICorner = card:FindFirstChildOfClass('UICorner') or Instance.new('UICorner', card);
		card.BackgroundColor3 = Color3.fromHSV(queuecardvisualscolor.Hue, queuecardvisualscolor.Sat, queuecardvisualscolor.Value);
		cardcorner.CornerRadius = queuecardvisualsround.Value;
		if table.find(queuecardobjects, cardcorner) == nil then 
			table.insert(queuecardobjects, cardcorner);
		end;
		if queucardvisualsgradientoption.Enabled then 
			card.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			local gradient = card:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', card);
			gradient.Color = ColorSequence.new({
				[1] = ColorSequenceKeypoint.new(0, Color3.fromHSV(queuecardvisualscolor.Hue, queuecardvisualscolor.Sat, queuecardvisualscolor.Value)), 
				[2] = ColorSequenceKeypoint.new(1, Color3.fromHSV(queuecardvisualscolor2.Hue, queuecardvisualscolor2.Sat, queuecardvisualscolor2.Value))
			});
			if table.find(queuecardobjects, gradient) == nil then
				table.insert(queuecardobjects, gradient);
			end;
		end;
		if queuecardvisualhighlight.Enabled then 
			local highlight: UIStroke? = card:FindFirstChildOfClass('UIStroke') or Instance.new('UIStroke', card);
			highlight.Thickness = 1.7;
			highlight.Color = Color3.fromHSV(queuecardmodshighlightcolor.Hue, queuecardmodshighlightcolor.Sat, queuecardmodshighlightcolor.Value);
			if table.find(queuecardobjects, highlight) == nil then
				table.insert(queuecardobjects, highlight);
			end;
		else
			pcall(function() card:FindFirstChildOfClass('UIStroke'):Destroy() end)
		end;
	end;
	queuecardvisuals = vape.Categories.Modules:CreateModule({
		Name = 'QueueCardVisuals',
		Function = function(calling: boolean)
			if calling then 
				pcall(queuecardfunc);
				table.insert(queuecardvisuals.Connections, lplr.PlayerGui.ChildAdded:Connect(queuecardfunc));
			else
				queuecardobjects:clear(game.Destroy)
			end
		end
	});
	queucardvisualsgradientoption = queuecardvisuals:CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			pcall(function() queuecardvisualscolor2.Object.Visible = calling end) 
		end
	});
	queuecardvisualsround = queuecardvisuals:CreateSlider({
		Name = 'Rounding',
		Min = 0,
		Max = 20,
		Default = 4,
		Function = function(value: number): ()
			for i: number, v: UICorner? in queuecardobjects do 
				if v.ClassName == 'UICorner' then 
					v.CornerRadius = value;
				end;
			end
		end
	})
	queuecardvisualscolor = queuecardvisuals:CreateColorSlider({
		Name = 'Color',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardvisualscolor2 = queuecardvisuals:CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardvisualhighlight = queuecardvisuals:CreateToggle({
		Name = 'Highlight',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end
	});
	queuecardmodshighlightcolor = queuecardvisuals:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			task.spawn(pcall, queuecardfunc)
		end;
	});
end);

run(function()
	local Atmosphere: table = {["Enabled"] = false};
	local Toggles: table = {}
	local themeName: any;
	local newobjects: table, oldobjects: table = {}, {}
    local function BeforeShaders()
        return {
            Brightness = lightingService.Brightness,
            ColorShift_Bottom = lightingService.ColorShift_Bottom,
            ColorShift_Top = lightingService.ColorShift_Top,
            OutdoorAmbient = lightingService.OutdoorAmbient,
            TimeOfDay = lightingService.TimeOfDay,
            FogColor = lightingService.FogColor,
            FogEnd = lightingService.FogEnd,
            FogStart = lightingService.FogStart,
            ExposureCompensation = lightingService.ExposureCompensation,
            ShadowSoftness = lightingService.ShadowSoftness,
            Ambient = lightingService.Ambient,
            children = lightingService:GetChildren()
        }
    end
    local function restoreDefault(lightingState)
        lightingService:ClearAllChildren()
        lightingService.Brightness = lightingState.Brightness
        lightingService.ColorShift_Bottom = lightingState.ColorShift_Bottom
        lightingService.ColorShift_Top = lightingState.ColorShift_Top
        lightingService.OutdoorAmbient = lightingState.OutdoorAmbient
        lightingService.TimeOfDay = lightingState.TimeOfDay
        lightingService.FogColor = lightingState.FogColor
        lightingService.FogEnd = lightingState.FogEnd
        lightingService.FogStart = lightingState.FogStart
        lightingService.ExposureCompensation = lightingState.ExposureCompensation
        lightingService.ShadowSoftness = lightingState.ShadowSoftness
        lightingService.Ambient = lightingState.Ambient
        for _, child in next, workspace.ItemDrops:GetChildren() do
            child.Parent = lightingService
        end
    end
	local apidump: table = {
		Sky = {
			SkyboxUp = 'Text',
			SkyboxDn = 'Text',
			SkyboxLf = 'Text',
			SkyboxRt = 'Text',
			SkyboxFt = 'Text',
			SkyboxBk = 'Text',
			SunTextureId = 'Text',
			SunAngularSize = 'Number',
			MoonTextureId = 'Text',
			MoonAngularSize = 'Number',
			StarCount = 'Number'
		},
		Atmosphere = {
			Color = 'Color',
			Decay = 'Color',
			Density = 'Number',
			Offset = 'Number',
			Glare = 'Number',
			Haze = 'Number'
		},
		BloomEffect = {
			Intensity = 'Number',
			Size = 'Number',
			Threshold = 'Number'
		},
		DepthOfFieldEffect = {
			FarIntensity = 'Number',
			FocusDistance = 'Number',
			InFocusRadius = 'Number',
			NearIntensity = 'Number'
		},
		SunRaysEffect = {
			Intensity = 'Number',
			Spread = 'Number'
		},
		ColorCorrectionEffect = {
			TintColor = 'Color',
			Saturation = 'Number',
			Contrast = 'Number',
			Brightness = 'Number'
		}
	}
	local skyThemes: table = {
		Purple = {
			SkyboxBk = 'rbxassetid://8539982183',
			SkyboxDn = 'rbxassetid://8539981943',
			SkyboxFt = 'rbxassetid://8539981721',
			SkyboxLf = 'rbxassetid://8539981424',
			SkyboxRt = 'rbxassetid://8539980766',
			SkyboxUp = 'rbxassetid://8539981085',
			MoonAngularSize = 0,
			SunAngularSize = 0,
			StarCount = 3000,
		},
		Galaxy = {
			SkyboxBk = 'rbxassetid://159454299',
			SkyboxDn = 'rbxassetid://159454296',
			SkyboxFt = 'rbxassetid://159454293',
			SkyboxLf = 'rbxassetid://159454293',
			SkyboxRt = 'rbxassetid://159454293',
			SkyboxUp = 'rbxassetid://159454288',
			SunAngularSize = 0,
		},
		BetterNight = {
			SkyboxBk = 'rbxassetid://155629671',
			SkyboxDn = 'rbxassetid://12064152',
			SkyboxFt = 'rbxassetid://155629677',
			SkyboxLf = 'rbxassetid://155629662',
			SkyboxRt = 'rbxassetid://155629666',
			SkyboxUp = 'rbxassetid://155629686',
			SunAngularSize = 0,
		},
		BetterNight2 = {
			SkyboxBk = 'rbxassetid://248431616',
			SkyboxDn = 'rbxassetid://248431677',
			SkyboxFt = 'rbxassetid://248431598',
			SkyboxLf = 'rbxassetid://248431686',
			SkyboxRt = 'rbxassetid://248431611',
			SkyboxUp = 'rbxassetid://248431605',
			StarCount = 3000,
		},
		MagentaOrange = {
			SkyboxBk = 'rbxassetid://566616113',
			SkyboxDn = 'rbxassetid://566616232',
			SkyboxFt = 'rbxassetid://566616141',
			SkyboxLf = 'rbxassetid://566616044',
			SkyboxRt = 'rbxassetid://566616082',
			SkyboxUp = 'rbxassetid://566616187',
			StarCount = 3000,
		},
		Purple2 = {
			SkyboxBk = 'rbxassetid://8107841671',
			SkyboxDn = 'rbxassetid://6444884785',
			SkyboxFt = 'rbxassetid://8107841671',
			SkyboxLf = 'rbxassetid://8107841671',
			SkyboxRt = 'rbxassetid://8107841671',
			SkyboxUp = 'rbxassetid://8107849791',
			SunTextureId = 'rbxassetid://6196665106',
			MoonTextureId = 'rbxassetid://6444320592',
			MoonAngularSize = 0,
		},
		Galaxy2 = {
			SkyboxBk = 'rbxassetid://14164368678',
			SkyboxDn = 'rbxassetid://14164386126',
			SkyboxFt = 'rbxassetid://14164389230',
			SkyboxLf = 'rbxassetid://14164398493',
			SkyboxRt = 'rbxassetid://14164402782',
			SkyboxUp = 'rbxassetid://14164405298',
			SunTextureId = 'rbxassetid://8281961896',
			MoonTextureId = 'rbxassetid://6444320592',
			SunAngularSize = 0,
			MoonAngularSize = 0,
		},
		Pink = {
			SkyboxBk = 'rbxassetid://271042516',
			SkyboxDn = 'rbxassetid://271077243',
			SkyboxFt = 'rbxassetid://271042556',
			SkyboxLf = 'rbxassetid://271042310',
			SkyboxRt = 'rbxassetid://271042467',
			SkyboxUp = 'rbxassetid://271077958',
		},
		PurpleMountains = {
			SkyboxBk = 'rbxassetid://17901353811',
			SkyboxDn = 'rbxassetid://17901366771',
			SkyboxFt = 'rbxassetid://17901356262',
			SkyboxLf = 'rbxassetid://17901359687',
			SkyboxRt = 'rbxassetid://17901362326',
			SkyboxUp = 'rbxassetid://17901365106',
			SunAngularSize = 0,
		},
		AestheticMountains = {
			SkyboxBk = 'rbxassetid://15470198023',
			SkyboxDn = 'rbxassetid://15470151245',
			SkyboxFt = 'rbxassetid://15470200128',
			SkyboxLf = 'rbxassetid://15470202648',
			SkyboxRt = 'rbxassetid://15470204862',
			SkyboxUp = 'rbxassetid://15470207755',
			MoonAngularSize = 11,
			SunAngularSize = 21,
		},
		OverPlanet = {
			SkyboxBk = 'rbxassetid://165052268',
			SkyboxDn = 'rbxassetid://165052286',
			SkyboxFt = 'rbxassetid://165052328',
			SkyboxLf = 'rbxassetid://165052365',
			SkyboxRt = 'rbxassetid://165052306',
			SkyboxUp = 'rbxassetid://165052345',
			MoonAngularSize = 11,
			SunAngularSize = 21,
			StarCount = 3000,
		},
		Beach = {
			SkyboxBk = 'rbxassetid://173380597',
			SkyboxDn = 'rbxassetid://173380627',
			SkyboxFt = 'rbxassetid://173380642',
			SkyboxLf = 'rbxassetid://173380671',
			SkyboxRt = 'rbxassetid://173380774',
			SkyboxUp = 'rbxassetid://173380790',
			MoonAngularSize = 11,
			SunAngularSize = 21,
		},
		RedNight = {
			SkyboxBk = 'rbxassetid://401664839',
			SkyboxDn = 'rbxassetid://401664862',
			SkyboxFt = 'rbxassetid://401664960',
			SkyboxLf = 'rbxassetid://401664881',
			SkyboxRt = 'rbxassetid://401664901',
			SkyboxUp = 'rbxassetid://401664936',
			SunAngularSize = 0,
		},
		GreenHaze = {
			SkyboxBk = 'rbxassetid://160193404',
			SkyboxDn = 'rbxassetid://160193466',
			SkyboxFt = 'rbxassetid://160193461',
			SkyboxLf = 'rbxassetid://160193469',
			SkyboxRt = 'rbxassetid://160193463',
			SkyboxUp = 'rbxassetid://160193458',
			SunAngularSize = 0,
		},
		Purple3 = {
			SkyboxBk = 'rbxassetid://433274085',
			SkyboxDn = 'rbxassetid://433274194',
			SkyboxFt = 'rbxassetid://433274131',
			SkyboxLf = 'rbxassetid://433274370',
			SkyboxRt = 'rbxassetid://433274429',
			SkyboxUp = 'rbxassetid://433274285',
		},
		DarkishPink = {
			SkyboxBk = 'rbxassetid://570555736',
			SkyboxDn = 'rbxassetid://570555964',
			SkyboxFt = 'rbxassetid://570555800',
			SkyboxLf = 'rbxassetid://570555840',
			SkyboxRt = 'rbxassetid://570555882',
			SkyboxUp = 'rbxassetid://570555929',
		},
		Space = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://166509999',
			SkyboxDn = 'rbxassetid://166510057',
			SkyboxFt = 'rbxassetid://166510116',
			SkyboxLf = 'rbxassetid://166510092',
			SkyboxRt = 'rbxassetid://166510131',
			SkyboxUp = 'rbxassetid://166510114',
		},
		Space2 = {
			SkyboxBk = 'rbxassetid://11844076072',
			SkyboxDn = 'rbxassetid://11844069700',
			SkyboxFt = 'rbxassetid://11844067209',
			SkyboxLf = 'rbxassetid://11844063543',
			SkyboxRt = 'rbxassetid://11844058446',
			SkyboxUp = 'rbxassetid://11844053742',
			MoonTextureId = 'rbxassetid://11844121592',
			SunAngularSize = 11,
			StarCount = 3e3, -- This is a valid way to write 3000 in Lua (scientific notation)
			MoonAngularSize = 20,
		},
		Galaxy3 = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://14543264135',
			SkyboxDn = 'rbxassetid://14543358958',
			SkyboxFt = 'rbxassetid://14543257810',
			SkyboxLf = 'rbxassetid://14543275895',
			SkyboxRt = 'rbxassetid://14543280890',
			SkyboxUp = 'rbxassetid://14543371676',
		},
		NetherWorld = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://14365019002',
			SkyboxDn = 'rbxassetid://14365023350',
			SkyboxFt = 'rbxassetid://14365018399',
			SkyboxLf = 'rbxassetid://14365018705',
			SkyboxRt = 'rbxassetid://14365018143',
			SkyboxUp = 'rbxassetid://14365019327',
		},
		Nebula = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://5260808177',
			SkyboxDn = 'rbxassetid://5260653793',
			SkyboxFt = 'rbxassetid://5260817288',
			SkyboxLf = 'rbxassetid://5260800833',
			SkyboxRt = 'rbxassetid://5260811073',
			SkyboxUp = 'rbxassetid://5260824661',
		},
		PurpleSpace = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://15983968922',
			SkyboxDn = 'rbxassetid://15983966825',
			SkyboxFt = 'rbxassetid://15983965025', -- This was duplicated, I kept this one.
			SkyboxLf = 'rbxassetid://15983967420',
			SkyboxRt = 'rbxassetid://15983966246',
			SkyboxUp = 'rbxassetid://15983964246',
			StarCount = 3000,
		},
		PurpleNight = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://5260808177',
			SkyboxDn = 'rbxassetid://5260653793',
			SkyboxFt = 'rbxassetid://5260817288',
			SkyboxLf = 'rbxassetid://5260800833',
			SkyboxRt = 'rbxassetid://5260800833',
			SkyboxUp = 'rbxassetid://5084576400',
		},
		Aesthetic = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://1417494030',
			SkyboxDn = 'rbxassetid://1417494146',
			SkyboxFt = 'rbxassetid://1417494253',
			SkyboxLf = 'rbxassetid://1417494402',
			SkyboxRt = 'rbxassetid://1417494499',
			SkyboxUp = 'rbxassetid://1417494643',
		},
		Aesthetic2 = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://600830446',
			SkyboxDn = 'rbxassetid://600831635',
			SkyboxFt = 'rbxassetid://600832720',
			SkyboxLf = 'rbxassetid://600886090',
			SkyboxRt = 'rbxassetid://600833862',
			SkyboxUp = 'rbxassetid://600835177',
		},
		Pastel = {
			SunAngularSize = 0,
			MoonAngularSize = 0,
			SkyboxBk = 'rbxassetid://2128458653',
			SkyboxDn = 'rbxassetid://2128462480',
			SkyboxFt = 'rbxassetid://2128458653',
			SkyboxLf = 'rbxassetid://2128462027',
			SkyboxRt = 'rbxassetid://2128462027',
			SkyboxUp = 'rbxassetid://2128462236',
		},
		PurpleClouds = {
			SkyboxBk = 'rbxassetid://570557514',
			SkyboxDn = 'rbxassetid://570557775',
			SkyboxFt = 'rbxassetid://570557559',
			SkyboxLf = 'rbxassetid://570557620',
			SkyboxRt = 'rbxassetid://570557672',
			SkyboxUp = 'rbxassetid://570557727',
		},
		BetterSky = {
			-- The 'if skyobj then' check isn't needed here if this is purely data.
			-- This entry defines properties directly, just like the others.
			SkyboxBk = 'rbxassetid://591058823',
			SkyboxDn = 'rbxassetid://591059876',
			SkyboxFt = 'rbxassetid://591058104',
			SkyboxLf = 'rbxassetid://591057861',
			SkyboxRt = 'rbxassetid://591057625',
			SkyboxUp = 'rbxassetid://591059642',
		},
		DarkClouds = {
			SkyboxBk = 'rbxassetid://190477248',
			SkyboxDn = 'rbxassetid://190477222',
			SkyboxFt = 'rbxassetid://190477200',
			SkyboxLf = 'rbxassetid://190477185',
			SkyboxRt = 'rbxassetid://190477166',
			SkyboxUp = 'rbxassetid://190477146',
			MoonAngularSize = 1.5,
			StarCount = 0,
		},
		Pinkie = {
			SkyboxBk = 'rbxassetid://11555017034',
			SkyboxDn = 'rbxassetid://11555013415',
			SkyboxFt = 'rbxassetid://11555010145',
			SkyboxLf = 'rbxassetid://11555006545',
			SkyboxRt = 'rbxassetid://11555000712',
			SkyboxUp = 'rbxassetid://11554996247',
			MoonAngularSize = 1.5,
			StarCount = 0,
		},
		Hell = {
			SkyboxBk = 'rbxassetid://11730840088',
			SkyboxDn = 'rbxassetid://11730842997',
			SkyboxFt = 'rbxassetid://11730849615',
			SkyboxLf = 'rbxassetid://11730852920',
			SkyboxRt = 'rbxassetid://11730855491',
			SkyboxUp = 'rbxassetid://11730857150',
			MoonAngularSize = 11,
			StarCount = 3000,
		},
		BetterNight3 = {
			MoonTextureId = 'rbxassetid://1075087760',
			SkyboxBk = 'rbxassetid://2670643994',
			SkyboxDn = 'rbxassetid://2670643365',
			SkyboxFt = 'rbxassetid://2670643214',
			SkyboxLf = 'rbxassetid://2670643070',
			SkyboxRt = 'rbxassetid://2670644173',
			SkyboxUp = 'rbxassetid://2670644331',
			MoonAngularSize = 1.5,
			StarCount = 500,
		},
		Orange = {
			SkyboxBk = 'rbxassetid://150939022',
			SkyboxDn = 'rbxassetid://150939038',
			SkyboxFt = 'rbxassetid://150939047',
			SkyboxLf = 'rbxassetid://150939056',
			SkyboxRt = 'rbxassetid://150939063',
			SkyboxUp = 'rbxassetid://150939082',
		},
		DarkMountains = {
			SkyboxBk = 'rbxassetid://5098814730',
			SkyboxDn = 'rbxassetid://5098815227',
			SkyboxFt = 'rbxassetid://5098815653',
			SkyboxLf = 'rbxassetid://5098816155',
			SkyboxRt = 'rbxassetid://5098820352',
			SkyboxUp = 'rbxassetid://5098819127',
		},
		FlamingSunset = {
			SkyboxBk = 'rbxassetid://415688378',
			SkyboxDn = 'rbxassetid://415688193',
			SkyboxFt = 'rbxassetid://415688242',
			SkyboxLf = 'rbxassetid://415688310',
			SkyboxRt = 'rbxassetid://415688274',
			SkyboxUp = 'rbxassetid://415688354',
		},
		Nebula2 = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://16932794531',
			SkyboxDn = 'rbxassetid://16932797813',
			SkyboxFt = 'rbxassetid://16932800523',
			SkyboxLf = 'rbxassetid://16932803722',
			SkyboxRt = 'rbxassetid://16932806825',
			SkyboxUp = 'rbxassetid://16932810138',
		},
		Nebula3 = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://17839210699',
			SkyboxDn = 'rbxassetid://17839215896',
			SkyboxFt = 'rbxassetid://17839218166',
			SkyboxLf = 'rbxassetid://17839220800',
			SkyboxRt = 'rbxassetid://17839223605',
			SkyboxUp = 'rbxassetid://17839226876',
		},
		Nebula4 = {
			MoonAngularSize = 0,
			SunAngularSize = 0,
			SkyboxBk = 'rbxassetid://17103618635',
			SkyboxDn = 'rbxassetid://17103622190',
			SkyboxFt = 'rbxassetid://17103624898',
			SkyboxLf = 'rbxassetid://17103628153',
			SkyboxRt = 'rbxassetid://17103636666',
			SkyboxUp = 'rbxassetid://17103639457',
		},
		NewYork = {
			SkyboxBk = 'rbxassetid://11333973069',
			SkyboxDn = 'rbxassetid://11333969768',
			SkyboxFt = 'rbxassetid://11333964303',
			SkyboxLf = 'rbxassetid://11333971332',
			SkyboxRt = 'rbxassetid://11333982864',
			SkyboxUp = 'rbxassetid://11333967970',
			SunAngularSize = 0,
		},
		Aesthetic3 = {
			SkyboxBk = 'rbxassetid://151165214',
			SkyboxDn = 'rbxassetid://151165197',
			SkyboxFt = 'rbxassetid://151165224',
			SkyboxLf = 'rbxassetid://151165191',
			SkyboxRt = 'rbxassetid://151165206',
			SkyboxUp = 'rbxassetid://151165227',
		},
		FakeClouds = {
			SkyboxBk = 'rbxassetid://8496892810',
			SkyboxDn = 'rbxassetid://8496896250',
			SkyboxFt = 'rbxassetid://8496892810',
			SkyboxLf = 'rbxassetid://8496892810',
			SkyboxRt = 'rbxassetid://8496892810',
			SkyboxUp = 'rbxassetid://8496897504',
			SunAngularSize = 0,
		},
		LunarNight = {
			SkyboxBk = 'rbxassetid://187713366',
			SkyboxDn = 'rbxassetid://187712428',
			SkyboxFt = 'rbxassetid://187712836',
			SkyboxLf = 'rbxassetid://187713755',
			SkyboxRt = 'rbxassetid://187714525',
			SkyboxUp = 'rbxassetid://187712111',
			SunAngularSize = 0,
			StarCount = 0,
		},
		FPSBoost = {
			SkyboxBk = 'rbxassetid://11457548274',
			SkyboxDn = 'rbxassetid://11457548274',
			SkyboxFt = 'rbxassetid://11457548274',
			SkyboxLf = 'rbxassetid://11457548274',
			SkyboxRt = 'rbxassetid://11457548274',
			SkyboxUp = 'rbxassetid://11457548274',
			SunAngularSize = 0,
			StarCount = 3000,
		},
		PurplePlanet = {
			SkyboxBk = 'rbxassetid://16262356578',
			SkyboxDn = 'rbxassetid://16262358026',
			SkyboxFt = 'rbxassetid://16262360469',
			SkyboxLf = 'rbxassetid://16262362003',
			SkyboxRt = 'rbxassetid://16262363873',
			SkyboxUp = 'rbxassetid://16262366016',
			SunAngularSize = 21,
			StarCount = 3000,
		},
		BluePlanet = {
			SkyboxBk = 'rbxassetid://16888989874',
			SkyboxDn = 'rbxassetid://16888991855',
			SkyboxFt = 'rbxassetid://16888995219',
			SkyboxLf = 'rbxassetid://16888998994',
			SkyboxRt = 'rbxassetid://16889000916',
			SkyboxUp = 'rbxassetid://16889004122',
			SunAngularSize = 21,
			StarCount = 3000,
		},
		Mountains = {
			SkyboxBk = 'rbxassetid://15359410490',
			SkyboxDn = 'rbxassetid://15359411132',
			SkyboxFt = 'rbxassetid://15359412131',
			SkyboxLf = 'rbxassetid://15359411633',
			SkyboxRt = 'rbxassetid://15359417656',
			SkyboxUp = 'rbxassetid://15359412677',
			SunAngularSize = 21,
			StarCount = 3000,
		},
		LunarNight2 = {
			SkyboxBk = 'rbxassetid://14365026085',
			SkyboxDn = 'rbxassetid://14365026242',
			SkyboxFt = 'rbxassetid://14365025735',
			SkyboxLf = 'rbxassetid://14365025904',
			SkyboxRt = 'rbxassetid://14365025444',
			SkyboxUp = 'rbxassetid://14365026442',
			SunAngularSize = 21,
			StarCount = 3000,
		},
		FunnyStorm = {
			SkyboxBk = 'rbxassetid://6280934001',
			SkyboxDn = 'rbxassetid://6280935347',
			SkyboxFt = 'rbxassetid://6280936575',
			SkyboxLf = 'rbxassetid://6280938749',
			SkyboxRt = 'rbxassetid://6280940989',
			SkyboxUp = 'rbxassetid://6280942402',
			SunAngularSize = 21,
			StarCount = 3000,
		},
		Flame = {
			SkyboxBk = 'rbxassetid://6286780109',
			SkyboxDn = 'rbxassetid://6286782353',
			SkyboxFt = 'rbxassetid://6286784186',
			SkyboxLf = 'rbxassetid://6286785801',
			SkyboxRt = 'rbxassetid://6286788245',
			SkyboxUp = 'rbxassetid://6286790025',
			SunAngularSize = 21,
			StarCount = 3000,
		},
		BlueSpace = {
			SkyboxBk = 'rbxassetid://16876541778',
			SkyboxDn = 'rbxassetid://16876543880',
			SkyboxFt = 'rbxassetid://16876546384',
			SkyboxLf = 'rbxassetid://16876548320',
			SkyboxRt = 'rbxassetid://16876550345',
			SkyboxUp = 'rbxassetid://16876552681',
			SunAngularSize = 21,
			StarCount = 3000,
		}
	}

    local ILS: any = BeforeShaders()
	local function removeObject(v)
		if not table.find(newobjects, v) then 
			local toggle = Toggles[v.ClassName]
			if toggle and toggle.Toggle["Enabled"] then
				table.insert(oldobjects, v)
				v.Parent = game
			end
		end
	end
	
	local function themes(val)
        local theme = skyThemes[themeName["Value"]]
        if theme then
            local sky = lightingService:FindFirstChild("CustomSky") or Instance.new("Sky", lightingService)
            for v, value in next, theme do
                if v ~= "Atmosphere" then
                    sky[v] = value
                end
            end
        end;
    end;

	Atmosphere = vape.Categories.Modules:CreateModule({
		["Name"] = 'Atmosphere',
		["Function"] = function(callback: boolean): void
			if callback then
				for _, v in lightingService:GetChildren() do
                    if v:IsA('PostEffect') or v:IsA('Sky') or v:IsA('Atmosphere') or v:IsA('Clouds') then
                        v:Destroy()
                    end
                end

                for _, v in workspace:GetDescendants() do
                    if v:IsA("Clouds") then
                        v:Destroy()
                    end;
                end;
				local d: number = 0
				local r: any = workspace.Terrain
				for _, v in lightingService:GetChildren() do
                    if v:IsA('PostEffect') or v:IsA('Sky') or v:IsA('Atmosphere') or v:IsA('Clouds') then -- Added Clouds
                        v:Destroy();
                    end;
                end;
				lightingService.Brightness = d + 1;
                lightingService.EnvironmentDiffuseScale = d + 0.2;
                lightingService.EnvironmentSpecularScale = d + 0.82;

                local sunRays = Instance.new('SunRaysEffect')
                table.insert(newobjects, sunRays)
                pcall(function() sunRays.Parent = lightingService end)

                local atmosphere = Instance.new('Atmosphere')
                table.insert(newobjects, atmosphere)
                pcall(function() atmosphere.Parent = lightingService end)

                local sky = Instance.new('Sky')
                table.insert(newobjects, sky)
                pcall(function() sky.Parent = lightingService end)

                local blur = Instance.new('BlurEffect')
                blur.Size = d + 3.921
                table.insert(newobjects, blur)
                pcall(function() blur.Parent = lightingService end)

                local color_correction = Instance.new('ColorCorrectionEffect')
                color_correction.Saturation = d + 0.092
                table.insert(newobjects, color_correction)
                pcall(function() color_correction.Parent = lightingService end)

                local clouds = Instance.new('Clouds')
                clouds.Cover = d + 0.4
                table.insert(newobjects, clouds)
                pcall(function() clouds.Parent = r end)

                r.WaterTransparency = d + 1
                r.WaterReflectance = d + 1

				themes()
				for _, v in lightingService:GetChildren() do
					removeObject(v)
				end
				Atmosphere:Clean(lightingService.ChildAdded:Connect(function(v)
					task.defer(removeObject, v)
				end))
	
				for className, classData in Toggles do
					if classData.Toggle["Enabled"] then
						local obj: any = Instance.new(className)
						for propName, propData in classData.Objects do
							if propData.Type == 'ColorSlider' then
								obj[propName] = Color3.fromHSV(propData.Hue, propData.Sat, propData.Value)
							else
								if apidump[className][propName] == 'Number' then
									obj[propName] = tonumber(propData.Value) or 0
								else
									obj[propName] = propData.Value
								end
							end
						end
						obj.Name = "Custom" .. className
						table.insert(newobjects, obj)
						task.defer(function()
							pcall(function() obj.Parent = lightingService end)
						end)
					end
				end
			else
                for _, v in newobjects do
                    if v and v.Destroy then
                        v:Destroy()
                    end
                end
                for _, v in oldobjects do
                    pcall(function() v.Parent = lightingService end)
                end
                table.clear(newobjects)
                table.clear(oldobjects)
				for _, v in lightingService:GetChildren() do
                    if v:IsA("ColorCorrectionEffect") then
                        v:Destroy()
                    end
                end
				restoreDefault(ILS)
			end
		end,
		["Tooltip"] = 'Custom lighting objects'
	})
	local skyboxes: table = {}
    for v,_ in next, skyThemes do
        table.insert(skyboxes, v)
    end
	themeName = Atmosphere:CreateDropdown({
        ["Name"] = "Mode",
        ["List"] = skyboxes,
        ["Function"] = function(val) end;
    })
	for i, v in apidump do
		Toggles[i] = {Objects = {}}
		Toggles[i].Toggle = Atmosphere:CreateToggle({
			["Name"] = i,
			["Function"] = function(callback: boolean): void
				if Atmosphere["Enabled"] then
					Atmosphere:Toggle()
					Atmosphere:Toggle()
				end
				for _, toggle in Toggles[i].Objects do
					toggle.Object.Visible = callback
				end
			end
		})
	
		for i2, v2 in v do
			if v2 == 'Text' or v2 == 'Number' then
				Toggles[i].Objects[i2] = Atmosphere:CreateTextBox({
					["Name"] = i2,
					["Function"] = function(enter)
						if Atmosphere["Enabled"] and enter then
							Atmosphere:Toggle()
							Atmosphere:Toggle()
						end
					end,
					["Darker"] = true,
					["Default"] = v2 == 'Number' and '0' or nil,
					["Visible"] = false
				})
			elseif v2 == 'Color' then
				Toggles[i].Objects[i2] = Atmosphere:CreateColorSlider({
					["Name"] = i2,
					["Function"] = function()
						if Atmosphere["Enabled"] then
							Atmosphere:Toggle()
							Atmosphere:Toggle()
						end
					end,
					["Darker"] = true,
					["Visible"] = false
				})
			end
		end
	end
end)



run(function() -- pasted from old render once again
	local HotbarVisuals: vapemodule = {};
	local HotbarRounding: vapeminimodule = {};
	local HotbarHighlight: vapeminimodule = {};
	local HotbarColorToggle: vapeminimodule = {};
	local HotbarHideSlotIcons: vapeminimodule = {};
	local HotbarSlotNumberColorToggle: vapemodule = {};
	local HotbarSpacing: vapeslider = {Value = 0};
	local HotbarInvisibility: vapeslider = {Value = 4};
	local HotbarRoundRadius: vapeslider = {Value = 3};
	local HotbarAnimations: vapeminimodule = {};
	local HotbarColor: vapeminimodule = {};
	local HotbarHighlightColor: vapeminimodule = {};
	local HotbarSlotNumberColor: vapeminimodule = {};
	local hotbarcoloricons: securetable = Performance.new();
	local hotbarsloticons: securetable = Performance.new();
	local hotbarobjects: securetable = Performance.new();
	local HotbarVisualsGradient: vapeminimodule = {};
	local hotbarslotgradients: securetable = Performance.new();
	local HotbarMinimumRotation: vapeslider = {Value = 0};
	local HotbarMaximumRotation: vapeslider = {Value = 60};
	local HotbarAnimationSpeed: vapeslider = {Value = 8};
	local HotbarVisualsHighlightSize: vapeslider = {Value = 0};
	local HotbarVisualsGradientColor: vapecolorslider = {};
	local HotbarVisualsGradientColor2: vapecolorslider = {};
	local HotbarAnimationThreads: securetable = Performance.new();
	local inventoryiconobj;
	local hotbarFunction = function()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			inventoryiconobj = inventoryicons;
			pcall(function() inventoryicons:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, HotbarSpacing.Value) end);
			for i,v in inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				table.insert(hotbarcoloricons, sloticon.Parent);
				sloticon.Parent.Transparency = (0.1 * HotbarInvisibility.Value);
				if HotbarColorToggle.Enabled and not HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
				end
				local gradient;
				if HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end;
					if gradient then 
						HotbarAnimationThreads[gradient] = task.spawn(function()
							repeat
								task.wait();
								if not HotbarAnimations.Enabled then 
									continue;
								end;
								local integers: table = {
									[1] = HotbarMinimumRotation.Value + math.random(1, 15),
									[2] = HotbarMaximumRotation.Value - math.random(1, 14)
								};
								for i: number, v: number in integers do 
									local rotationtween: Tween = tweenService:Create(gradient, TweenInfo.new(0.1 * HotbarAnimationSpeed.Value), {Rotation = v});
									rotationtween:Play();
									rotationtween.Completed:Wait();
									task.wait(0.3);
								end;
							until (not HotbarVisuals.Enabled)
						end);
					end;
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 + (0.1 * HotbarVisualsHighlightSize.Value);
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarVisuals = vape.Categories.Modules:CreateModule({
		Name = 'HotbarVisuals',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
				table.insert(HotbarVisuals.Connections, runService.RenderStepped:Connect(function()
					for i,v in hotbarcoloricons do 
						pcall(function() v.Transparency = (0.1 * HotbarInvisibility.Value) end); 
					end	
				end))
			else
				HotbarAnimationThreads:clear(task.cancel);
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarVisuals:CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarVisualsGradient = HotbarVisuals:CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarVisualsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsGradientColor2.Object.Visible = calling end)
			HotbarMinimumRotation.Object.Visible = calling and HotbarAnimations.Enabled;
			HotbarMaximumRotation.Object.Visible = calling and HotbarAnimations.Enabled;
			HotbarAnimationSpeed.Object.Visible = calling and HotbarAnimations.Enabled;
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarVisualsGradientColor = HotbarVisuals:CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	});
	HotbarAnimations = HotbarVisuals:CreateToggle({
		Name = 'Animations',
		HoverText = 'Animates hotbar gradient rotation.',
		Function = function(calling: boolean)
			HotbarMinimumRotation.Object.Visible = calling;
			HotbarMaximumRotation.Object.Visible = calling;
			HotbarAnimationSpeed.Object.Visible = calling;
		end
	});
	HotbarVisualsGradientColor2 = HotbarVisuals:CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	});
	HotbarMinimumRotation = HotbarVisuals:CreateSlider({
		Name = 'Minimum',
		Min = 0,
		Max = 75,
		Function = function(...) end
	});
	HotbarMaximumRotation = HotbarVisuals:CreateSlider({
		Name = 'Maximum',
		Min = 10,
		Max = 100,
		Function = function(...) end
	});
	HotbarAnimationSpeed = HotbarVisuals:CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 15,
		Default = 8,
		Function = function(...) end
	});
	HotbarColor = HotbarVisuals:CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarVisuals:CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarRoundRadius = HotbarVisuals:CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	});
	HotbarHighlight = HotbarVisuals:CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsHighlightSize.Object.Visible = calling end);
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarHighlightColor = HotbarVisuals:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	});
	HotbarVisualsHighlightSize = HotbarVisuals:CreateSlider({
		Name = 'Highlight Size',
		Min = 0,
		Max = 8,
		Function = function(value: number)
			for i: number, v: UIStroke? in hotbarobjects do 
				if v.ClassName == 'UIStroke' and HotbarHighlight.Enabled then 
					pcall(function() v.Thickness = 1.3 + (0.1 * value) end)
				end
			end
		end
	});
	HotbarHideSlotIcons = HotbarVisuals:CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarVisuals.Enabled then 
				HotbarVisuals:Toggle()
				HotbarVisuals:Toggle()
			end
		end
	})
	HotbarInvisibility = HotbarVisuals:CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Default = 4,
		Function = function(value)
			for i,v in hotbarcoloricons do 
				pcall(function() v.Transparency = (0.1 * value) end); 
			end
		end
	})
	HotbarSpacing = HotbarVisuals:CreateSlider({
		Name = 'Spacing',
		Min = 0,
		Max = 5,
		Function = function(value)
			if HotbarVisuals.Enabled then 
				pcall(function() inventoryiconobj:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, value) end)
			end
		end
	});

	HotbarAnimationThreads.oncleanevent:Connect(task.cancel);
	HotbarColor.Object.Visible = false;
	HotbarRoundRadius.Object.Visible = false;
	HotbarHighlightColor.Object.Visible = false;
	HotbarMinimumRotation.Object.Visible = false;
	HotbarMaximumRotation.Object.Visible = false;
	HotbarAnimationSpeed.Object.Visible = false;
end);


run(function()
	local BlockIn
	
	local function getBedNear()
		local localPosition = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero
		for _, v in collectionService:GetTagged('bed') do
			if (localPosition - v.Position).Magnitude < 20 and v:GetAttribute('Team'..(lplr:GetAttribute('Team') or -1)..'NoBreak') then
				return v
			end
		end
	end
	
	local function getBlocks()
		local blocks = {}
		for _, item in store.inventory.inventory.items do
			local block = bedwars.ItemMeta[item.itemType].block
			if block then
				table.insert(blocks, {item.itemType, block.health})
			end
		end
		table.sort(blocks, function(a, b) 
			return a[2] < b[2]
		end)
		return blocks
	end
	
	local function getPyramid(size, grid)
		return {
			Vector3.new(3, 0, 0);
			Vector3.new(0, 0, 3);
			Vector3.new(-3, 0, 0);
			Vector3.new(0, 0, -3);
			Vector3.new(3, 3, 0);
			Vector3.new(0, 3, 3);
			Vector3.new(-3, 3, 0);
			Vector3.new(0, 3, -3);
			Vector3.new(0, 6, 0);
		}
	end
	
	BlockIn = vape.Categories.Modules:CreateModule({
		Name = 'BlockIn',
		Function = function(callback)
			if callback then
				me = entitylib.isAlive and entitylib.character.RootPart.Position or nil
				if me then
					for i, block in getBlocks() do
						for _, pos in getPyramid(i, 3) do
							if not BlockIn.Enabled then break end
							if getPlacedBlock(me + pos) then continue end
							bedwars.placeBlock(me + pos, block[1], false)
						end
					end
					if BlockIn.Enabled then 
						BlockIn:Toggle() 
					end
				else
					notif('BlockIn', 'Unable to locate me', 5)
					BlockIn:Toggle()
				end
			end
		end,
		Tooltip = 'Automatically places strong blocks around the me.'
	})
end)

run(function()
    local ChatTag = {}
    ChatTag = vape.Categories.Render:CreateModule({
        Name = "ChatTag",
        Function = function(callback)
            if callback then
                textChatService.OnIncomingMessage = function(message: string?)
                    local prop = Instance.new("TextChatMessageProperties")
                    if message.TextSource and message.TextSource.UserId == lplr.UserId then
                        prop.PrefixText = "<font color='#0000ff'>[RainWare V6]</font> " .. (message.PrefixText or "")
                    end
                    return prop
                end
            else
                textChatService.OnIncomingMessage = nil
            end
        end,
        Tooltip = "Adds a tag next to your name when you chat."
    })
end)

run(function()
    local Ambience1: table = {}
    Ambience1 = vape.Categories.Render:CreateModule({
        ["Name"] = "Ambience 1",
        ["Function"] = function(callback: boolean): void
            if callback then
                local sky = Instance.new("Sky")
                sky.Name = "Ambience 1"
                local id = "rbxassetid://122785120445164"
                sky.SkyboxBk = id
                sky.SkyboxDn = id
                sky.SkyboxFt = id
                sky.SkyboxLf = id
                sky.SkyboxRt = id
                sky.SkyboxUp = id
                sky.Parent = lightingService
            else
                local sky = lightingService:FindFirstChild("Ambience 1")
                if sky then sky:Destroy() end
            end
        end,
        ["Tooltip"] = "Ambience 1"
    })
end)


run(function()
    local Ambience2: table = {}
    Ambience2 = vape.Categories.Render:CreateModule({
        ["Name"] = "Ambience 2",
        ["Function"] = function(callback: boolean): void
            if callback then
                local sky = Instance.new("Sky")
                sky.Name = "Ambience 2"
                local id = "rbxassetid://121826915456627"
                sky.SkyboxBk = id
                sky.SkyboxDn = id
                sky.SkyboxFt = id
                sky.SkyboxLf = id
                sky.SkyboxRt = id
                sky.SkyboxUp = id
                sky.Parent = lightingService
            else
                local sky = lightingService:FindFirstChild("Ambience 2")
                if sky then sky:Destroy() end
            end
        end,
        ["Tooltip"] = "Ambience 2"
    })
end)
																																																														
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "RainWare V6 Rewrite";
    Text = "Loaded!";
    Duration = 10;
})

run(function()
    local ZoomUnlocker: table = {};
    ZoomUnlocker = vape.Categories.Utility:CreateModule({
        Name = "Zoom Unlocker",
        Function = function(callback)
	    if callback then
            	lplr.CameraMaxZoomDistance = enabled and math.huge or 128
	    end;
        end,
        Tooltip = "Makes it so you can zoom infinitely"
    })
end)

run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local loopConn
    local invisibilityEnabled = false

    local function modifyHRP(onEnable)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        if onEnable then
            hrp.Transparency = 0.3
            hrp.Color = Color3.new(1, 1, 1)
            hrp.Material = Enum.Material.Plastic
        else
            hrp.Transparency = 1
        end

        hrp.CanCollide = true
        hrp.Anchored = false
    end

    local function setCharacterVisibility(isVisible)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = isVisible and 0 or 1
            elseif part:IsA("Decal") then
                part.Transparency = isVisible and 0 or 1
            elseif part:IsA("LayerCollector") then
                part.Enabled = isVisible
            end
        end
    end

    local function startLoop(Character)
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid or Humanoid.RigType == Enum.HumanoidRigType.R6 then return end

        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then return end

        if loopConn then loopConn:Disconnect() end

        loopConn = RunService.Heartbeat:Connect(function()
            if not invisibilityEnabled or not Character or not Humanoid or not RootPart then return end

            -- 
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                elseif part:IsA("LayerCollector") then
                    part.Enabled = false
                end
            end

            -- 
            local oldcf = RootPart.CFrame
            local oldcamoffset = Humanoid.CameraOffset
            local newcf = RootPart.CFrame - Vector3.new(0, Humanoid.HipHeight + (RootPart.Size.Y / 2) - 1, 0)

            RootPart.CFrame = newcf * CFrame.Angles(0, 0, math.rad(180))
            Humanoid.CameraOffset = Vector3.new(0, -5, 0)

            local anim = Instance.new("Animation")
            anim.AnimationId = "http://www.roblox.com/asset/?id=11360825341"
            local loaded = Humanoid.Animator:LoadAnimation(anim)
            loaded.Priority = Enum.AnimationPriority.Action4
            loaded:Play()
            loaded.TimePosition = 0
            loaded:AdjustSpeed(0)

            RunService.RenderStepped:Wait()
            loaded:Stop()

            Humanoid.CameraOffset = oldcamoffset
            RootPart.CFrame = oldcf
        end)
    end

    Invisibility = vape.Categories.Blatant:CreateModule({
        Name = 'Invisibility',
        Function = function(callback)
            invisibilityEnabled = callback
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if callback then
                vape:CreateNotification('Invisibilty', 'You are now invisible Disable when Respawned and toggle it again or you are visible', 6)
                modifyHRP(true)
                setCharacterVisibility(false)
                startLoop(character)
            else
                if loopConn then
                    loopConn:Disconnect()
                    loopConn = nil
                end
                modifyHRP(false)
                setCharacterVisibility(true)
            end
        end,
        Default = false,
        Tooltip = ""
    })

    LocalPlayer.CharacterAdded:Connect(function()
        if invisibilityEnabled then
            task.wait(0.5)
            Invisibility.Function(true)
        end
    end)
end)																																																													

run(function()
    local Rain: table = {};
    local function Roof(cframe: CFrame): BasePart?
        local ray: Ray = Ray.new(cframe.Position, Vector3.new(0, 150, 0));
        return workspace:FindPartOnRayWithIgnoreList(ray, {lplr.Character});
    end;

    local function Particle(cframe: CFrame)
        local Spread: Vector3 = Vector3.new(
            math.random(-100, 100),
            math.random(-100, 100),
            math.random(-100, 100)
        );
        local Part: Part = Instance.new("Part") ;
        Part.Parent = workspace.CurrentCamera ;
        local Smoke: Smoke = Instance.new("Smoke", Part);
        Part.CanCollide = false;
        Part.Transparency = 0.25;
        Part.Reflectance = 0.15;
        Part.BrickColor = BrickColor.new("Steel blue");
        Part.FormFactor = Enum.FormFactor.Custom;
        Part.Size = Vector3.new(0.15, 2, 0.15);
        Part.CFrame = CFrame.new(
            cframe.Position + (cframe:vectorToWorldSpace(Vector3.new(0, 1, 0)).Unit * 150) + Spread
        ) * CFrame.Angles(0, math.atan2(cframe.Position.X, cframe.Position.Z) + math.pi, 0)
        Smoke.RiseVelocity = -25;
        Smoke.Opacity = 0.25;
        Smoke.Size = 25;
        debris:AddItem(Part, 3);
        Instance.new("BlockMesh", Part);
        Part.Touched:Connect(function(Hit)
            Part:Destroy();
        end);
    end;

    Rain = vape.Categories.Modules:CreateModule({
        ["Name"] = "Rain",
        ["Tooltip"] = "Rains, because this is rainware",
        ["Function"] = function(callback: boolean): void
            if callback then
                task.spawn(function()
                    repeat
                        task.wait();
                    until lplr.Character and lplr.Character:FindFirstChild("UpperTorso"); 
                    local Torso: UpperTorso? = lplr.Character:FindFirstChild("UpperTorso"); 
                    local RainSound: Sound = Instance.new("Sound");
                    RainSound.Name = "RainSound";
                    RainSound.SoundId = "rbxassetid://236148388";
                    RainSound.Looped = true;
                    RainSound.Volume = 0.05;
                    RainSound.Parent = workspace.CurrentCamera;
                    RainSound:Play();
                    repeat
                        if Roof(Torso.CFrame) == nil then
                            for _ = 1, 5 do
                                if (workspace.CurrentCamera.CFrame.Position - Torso.CFrame.Position).Magnitude > 100 then 
                                    Particle(workspace.CurrentCamera.CFrame); 
                                    Particle(Torso.CFrame);
                                else
                                    Particle(Torso.CFrame);
                                end;
                            end;
                        else
                            if Roof(workspace.CurrentCamera.CFrame) == nil then 
                                for _ = 1, 5 do
                                    Particle(workspace.CurrentCamera.CFrame); 
                                end;
                            end;
                        end;
                        task.wait(0);
                    until not Rain["Enabled"];
                    if RainSound and RainSound:IsDescendantOf(workspace.CurrentCamera) then
                        RainSound:Stop();
                        RainSound:Destroy();
                    end;
                end);
            end;
        end;
    })
end)

pcall(setclipboard, "https://discord.gg/54d2xCp7Mg");
																																																														local BetterStrafe
