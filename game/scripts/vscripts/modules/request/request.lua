if not request then
	request = class({})
	request.http = "http://memesofdota.ru/request.php" --IsInToolsMode() and "http://localhost/request.php" or 
	request.authKey = GetDedicatedServerKey("authKey")
end
 
ModuleRequire(...,"data")
function request:GetDataServer(callback,pID,GetType,customUrl,newData)
	if pID and tostring(PlayerResource:GetSteamID(pID)) == "0" then 
		print('[Request] PlayerID = '..pID..', Is Bot, not requestion!') 
		return 
	end
	local data = json.encode({
		SteamID = #tostring(pID) > 8 and tostring(pID) or tostring(PlayerResource:GetSteamID(pID or 0)),
		authKey = self.authKey,
		getIndex = tostring(GetType or GET_STATE_PLAYER),
		data = newData,
		Debug = IsInToolsMode(),
	})
    local GetRequest = CreateHTTPRequestScriptVM("GET", customUrl or request.http)
	GetRequest:SetHTTPRequestGetOrPostParameter("Info", data )
	GetRequest:Send(function(get)
        if get.StatusCode ~= 200 then  
        	print("Error, Status code = ",get.StatusCode) 
        	if GetType == GET_TYPE_BUY_WEARABLES then
        		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID),"WearableUpdate", {err = get.StatusCode}) 
        	end
        	return 
        end
		local obj, pos, err = json.decode(get.Body)
        if callback and obj and type(obj) == "table" then
			callback(obj)
        end
    end)
end

function request:SetWinner( Team )
	GameRules:SetSafeToLeave(true)
	GameRules:SetGameWinner( Team )
	Timers:CreateTimer(0.6,function()
		request:OnGameEnd(Team )
	end)
end

function request:SendDataByServer(data,customUrl)
	data.authKey = self.authKey
	data.Debug = IsInToolsMode()
	data = json.encode(data)
    local SendData = CreateHTTPRequestScriptVM("POST", customUrl or request.http)
	SendData:SetHTTPRequestGetOrPostParameter("Info", data)
	SendData:Send(function(get)
        if get.StatusCode ~= 200 then
			print("Error,Status Code = ", get.StatusCode)
			return 
		end
		if not get.Body  then
			print('Error,Body = ',get.Body )
			print("Status Code", get.StatusCode)
			return
		end	
    end)
end
function request:GetNews()
	request:GetDataServer(function(data)
		CustomNetTables:SetTableValue("request", "News", data)
	end,nil,GET_TYPE_NEWS)
end

function request:IsWinner(pID,teamWin) 
	return PlayerResource:GetTeam(pID) == teamWin
end

function request:PreLoad()
	request.CountLimit = math.max(math.round((math.max(PlayerResource:GetAllPlayerCount(),2) - 1)/3),1)
	for i=0,DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) then
			request:GetDataServer(function(data)
				CustomNetTables:SetTableValue("request", tostring(i), data)
			end ,i)
		end
	end
	request:CreateTopRatingTable()	
	--request:GetNews()
	CustomGameEventManager:Send_ServerToAllClients("request", {})
end 

function request:CreateTopRatingTable()
	request:GetDataServer(function(data)
		CustomNetTables:SetTableValue("request", "TopRating", data)
	end,nil,GET_STATE_TOP)
end

function request:GetDataMatches()
	local data = {
		MatchID = tostring(GameRules:GetMatchID());
		Version = VAMPIRZ_VERSION,
		Duration = GetDotaFormatTime(),
		PlayersData = {},
	}
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			data.PlayersData[tostring(PlayerResource:GetSteamID(i))] = {
				heroHealing = PlayerResource:GetHealing(i),
				kills = PlayerResource:GetKills(i),
				deaths = PlayerResource:GetDeaths(i),
				assists = PlayerResource:GetAssists(i),
				Team = tonumber(PlayerResource:GetTeam(i)),
				IsWinner = request:IsWinner(i,TeamWin or PlayerResource:GetTeam(i)),
				Items = {},
			}
			for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
				local item = hero:GetItemInSlot(item_slot)
				if item then
					data.PlayersData[tostring(PlayerResource:GetSteamID(i))].Items[item_slot] = {
						name = item:GetAbilityName(),
						charges = item:GetCurrentCharges() > 0 and item:GetCurrentCharges() or nil
					}
				end
			end
		end
	end
	return data
end 

function request:GetPlayerData(pID)
	return CustomNetTables:GetTableValue("request", tostring(pID))
end 

function request:OnGameEnd(TeamWin)
	for pID=0,DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(pID) and tostring(PlayerResource:GetSteamID(pID)) ~= "0" then
			local UserData = {
				kills = tostring(PlayerResource:GetKills(pID)),
				deaths = tostring(PlayerResource:GetDeaths(pID)),
				assists = tostring(PlayerResource:GetAssists(pID)),
				IsAlpha = Vampires:IsAlpha(pID),
				IsVampire = Vampires:IsVampire(pID),
				IsLeave = IsPlayerAbandoned(pID),
				Blood = Vampires:IsVampire(pID) and tostring(Vampires:GetBlood(pID)) or nil,
				Gold = not Vampires:IsVampire(pID) and tostring(Gold:GetGold(pID)) or nil,
				DurationLife = not Vampires:IsVampire(pID) and not Vampires:IsAlpha(pID)  and USER_DATA[pID]['DurationLife'] and tostring(USER_DATA[pID]['DurationLife']) or nil,
				IsWin = not USER_DATA[pID]["Lose"] and not USER_DATA[pID]["UsableCheat"] and request:IsWinner(pID,TeamWin),
				IsCheat =  USER_DATA[pID]["UsableCheat"] or GameRules:IsCheatMode(),
				HeroName = PlayerResource:GetSelectedHeroEntity(pID):GetUnitName(),
				Position = USER_DATA[pID]["DeathNumber"],
				MaxPositions = math.max(PlayerResource:GetAllPlayerCount(),2) - 1,
				CountLose = request.CountLimit,
				IsSoloGame = PlayerResource:GetAllPlayerCount() <= 1,
			}
			if IsInToolsMode() then
				UserData.IsCheat = false
			end

			request:GetDataServer(function(data)
				local t = request:GetPlayerData(pID) or {}
				local table = {
					DurationLife = UserData.DurationLife,
					MMR = data.MMR,
					OLD_MMR = data.OLD_MMR,
					Coin = data.NewCoin,
					Rank = data.Rank or 'TBD',
					OLD_Rank = t.Rank or "TBD",
					IsWin = UserData.IsWin,
					--LevelXp = data.Level,
					--Xp = data.Xp,
					--OldXp = data.OldXp or 0,
					--maxXp = data.maxXp,
				}
				CustomNetTables:SetTableValue("game_state_end", tostring(pID), table)

			end,pID,GET_STATE_END_GAME,nil,UserData)
		end
	end
end 

--request:PreLoad()

--request:OnGameEnd(3)
