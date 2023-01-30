```Lua linenums="1"
-- [Fusion imports omitted for clarity]

type Set<T> = {[T]: true}

-- Defining a component for each row of the player list.
-- Each row represents a player currently logged into the server.
-- We set the `Name` to the player's name so the rows can be sorted by name.

type PlayerListRowProps = {
	Player: Player
}

local function PlayerListRow(props: PlayerListRowProps)
	return New "TextLabel" {
		Name = props.Player.DisplayName,

		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		
		Text = props.Player.DisplayName,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamMedium,
		FontSize = 16,
		TextXAlignment = "Right",
		TextTruncate = "AtEnd",

		[Children] = New "UIPadding" {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10)
		}
	}
end

-- Defining a component for the entire player list.
-- It should take in a set of all logged-in players, and it should be a state
-- object so the set of players can change as players join and leave.

type PlayerListProps = {
	PlayerSet: Fusion.StateObject<Set<Player>>
}

local function PlayerList(props: PlayerListProps)
	return New "Frame" {
		Name = "PlayerList",

		Position = UDim2.fromScale(1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.fromOffset(300, 0),
		AutomaticSize = "Y",

		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(0, 0, 0),

		[Children] = {
			New "UICorner" {},
			New "UIListLayout" {
				SortOrder = "Name",
				FillDirection = "Vertical"
			},

			ForPairs(props.PlayerSet, function(player, _)
				return player, PlayerListRow {
					Player = player
				}
			end, Fusion.cleanup)
		}
	}
end

-- To create the PlayerList component, first we need a state object that stores
-- the set of logged-in players, and updates as players join and leave.

local Players = game:GetService("Players")

local playerSet = Value()
local function updatePlayerSet()
	local newPlayerSet = {}
	for _, player in Players:GetPlayers() do
		newPlayerSet[player] = true
	end
	playerSet:set(newPlayerSet)
end
local playerConnections = {
	Players.PlayerAdded:Connect(updatePlayerSet),
	Players.PlayerRemoving:Connect(updatePlayerSet)
}
updatePlayerSet()

-- Now, we can create the component and pass in `playerSet`.
-- Don't forget to clean up your connections when your UI is destroyed; to do
-- that, we're using the `[Cleanup]` key to clean up `playerConnections` later.

local gui = New "ScreenGui" {
	Name = "PlayerListGui",
	Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"),

	[Cleanup] = playerConnections,

	[Children] = PlayerList {
		PlayerSet = playerSet
	}
}

```