local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent
local Skilift = require(Avalog.Parent.Skilift)
local Signal = require(Avalog.Parent.Signal)
local Stator = require(Avalog.Parent.Stator)
local Sift = require(Avalog.Parent.Sift)

local function NewPlayerDataStore(Options)
	local PlayerDataStore = {
		Store = Skilift.store(Options),

		Profiles = {},

		Loaded = Signal.new(),
		Unloaded = Signal.new(),
	}

	function PlayerDataStore:Load(Player: Player)
		if PlayerDataStore.Profiles[Player] ~= nil then
			return
		end

		local Profile = {
			Session = PlayerDataStore.Store:load(`{Player.UserId}`),
			Data = Stator(nil, {}),
		}

		Profile.Session:userid(Player.UserId)

		Profile.Session:updated(function(Data)
			Profile.Data:Update(function()
				return Sift.Dictionary.copyDeep(Data)
			end)
		end)

		PlayerDataStore.Profiles[Player] = Profile
		PlayerDataStore.Loaded:Fire(Player, Profile)
	end

	function PlayerDataStore:Unload(Player: Player)
		local Profile = PlayerDataStore:Get(Player)

		if Profile ~= nil then
			Profile.Session:stop()
			PlayerDataStore.Profiles[Player] = nil

			PlayerDataStore.Unloaded:Fire(Player)
		end
	end

	function PlayerDataStore:Get(Player: Player)
		return PlayerDataStore.Profiles[Player]
	end

	function PlayerDataStore:Start()
		for _, Player in ipairs(Players:GetPlayers()) do
			PlayerDataStore:Load(Player)
		end

		Players.PlayerAdded:Connect(function(Player)
			PlayerDataStore:Load(Player)
		end)

		Players.PlayerRemoving:Connect(function(Player)
			PlayerDataStore:Unload(Player)
		end)
	end

	return PlayerDataStore
end

return NewPlayerDataStore
