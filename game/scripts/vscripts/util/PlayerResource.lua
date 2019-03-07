function IsPlayerAbandoned(playerID)
	return USER_DATA[playerID].IsAbandoned == true
end

function CDOTA_PlayerResource:IsPlayerAbandoned(playerID)
	return IsPlayerAbandoned(playerID)
end

function GetTeamPlayerCount(iTeam)
	local counter = 0
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) and PlayerResource:GetTeam(i) == iTeam then
			counter = counter + 1
		end
	end
	return counter
end

function CDOTA_PlayerResource:GetAllPlayerCount()
	local counter = 0
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) and tostring(PlayerResource:GetSteamID(i)) ~= "0" then
			counter = counter + 1
		end
	end
	return counter
end

function CDOTA_PlayerResource:GetAllTeamPlayerIDs()
  return filter(partial(self.IsValidPlayerID, self), range(0, self:GetPlayerCount()))
end

function GetPlayersInTeam(team)
	local players = {}
	for playerId = 0, DOTA_MAX_TEAM_PLAYERS-1  do
		if PlayerResource:IsValidPlayerID(playerId) and (not team or PlayerResource:GetTeam(playerId) == team) and not USER_DATA[playerId].IsAbandoned then
			table.insert(players, playerId)
		end
	end
	return players
end

function GetOneRemainingTeam()
	local teamLeft
	for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		local count = GetTeamPlayerCount(i)
		if count > 0 then
			if teamLeft then
				return
			else
				teamLeft = i
			end
		end
	end
	return teamLeft
end

function CDOTA_PlayerResource:SetPlayerStat(PlayerID, key, value)
	local pd = USER_DATA[PlayerID]
	if not pd.HeroStats then pd.HeroStats = {} end
	pd.HeroStats[key] = value
end

function CDOTA_PlayerResource:GetPlayerStat(PlayerID, key)
	local pd = USER_DATA[PlayerID]
	return pd.HeroStats == nil and 0 or (pd.HeroStats[key] or 0)
end

function CDOTA_PlayerResource:ModifyPlayerStat(PlayerID, key, value)
	local v = PlayerResource:GetPlayerStat(PlayerID, key) + value
	PlayerResource:SetPlayerStat(PlayerID, key, v)
	return v
end
function CDOTA_PlayerResource:SetPlayerTeam(playerID, newTeam)
	local oldTeam = self:GetTeam(playerID)
	local player = self:GetPlayer(playerID)
	local hero = self:GetSelectedHeroEntity(playerID)
	for _,v in ipairs(FindAllOwnedUnits(player)) do
		v:SetTeam(newTeam)
	end
	player:SetTeam(newTeam)
	PlayerResource:UpdateTeamSlot(playerID, newTeam, 1)
	PlayerResource:SetCustomTeamAssignment(playerID, newTeam)
	PlayerResource:RefreshSelection()
	CustomGameEventManager:Send_ServerToAllClients("UpdateTeams", {})
end

function GetTeamAbandonedPlayerCount(iTeam)
	local counter = 0
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) and IsPlayerAbandoned(i) and PlayerResource:GetTeam(i) == iTeam then
			counter = counter + 1
		end
	end
	return counter
end

function CDOTA_PlayerResource:RefreshSelection()
    Timers:CreateTimer(0.03, function()
        FireGameEvent("dota_player_update_selected_unit", {})
    end)
end

function CDOTA_PlayerResource:GetRealSteamID(PlayerID)
	local id = tostring(PlayerResource:GetSteamID(PlayerID))
	return id == "0" and tostring(PlayerID) or id
end