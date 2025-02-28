--!native
--!optimize 2
--!nocheck
--!nolint
--#selene: allow(unused_variable, global_usage)
-- Client generated by Zap v0.6.18 (https://github.com/red-blox/zap)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local outgoing_buff: buffer
local outgoing_used: number
local outgoing_size: number
local outgoing_inst: { Instance }
local outgoing_apos: number

local incoming_buff: buffer
local incoming_read: number
local incoming_inst: { Instance }
local incoming_ipos: number

-- thanks to https://dom.rojo.space/binary.html#cframe
local CFrameSpecialCases = {
	CFrame.Angles(0, 0, 0),
	CFrame.Angles(math.rad(90), 0, 0),
	CFrame.Angles(0, math.rad(180), math.rad(180)),
	CFrame.Angles(math.rad(-90), 0, 0),
	CFrame.Angles(0, math.rad(180), math.rad(90)),
	CFrame.Angles(0, math.rad(90), math.rad(90)),
	CFrame.Angles(0, 0, math.rad(90)),
	CFrame.Angles(0, math.rad(-90), math.rad(90)),
	CFrame.Angles(math.rad(-90), math.rad(-90), 0),
	CFrame.Angles(0, math.rad(-90), 0),
	CFrame.Angles(math.rad(90), math.rad(-90), 0),
	CFrame.Angles(0, math.rad(90), math.rad(180)),
	CFrame.Angles(0, math.rad(-90), math.rad(180)),
	CFrame.Angles(0, math.rad(180), math.rad(0)),
	CFrame.Angles(math.rad(-90), math.rad(-180), math.rad(0)),
	CFrame.Angles(0, math.rad(0), math.rad(180)),
	CFrame.Angles(math.rad(90), math.rad(180), math.rad(0)),
	CFrame.Angles(0, math.rad(0), math.rad(-90)),
	CFrame.Angles(0, math.rad(-90), math.rad(-90)),
	CFrame.Angles(0, math.rad(-180), math.rad(-90)),
	CFrame.Angles(0, math.rad(90), math.rad(-90)),
	CFrame.Angles(math.rad(90), math.rad(90), 0),
	CFrame.Angles(0, math.rad(90), 0),
	CFrame.Angles(math.rad(-90), math.rad(90), 0),
}

local function alloc(len: number)
	if outgoing_used + len > outgoing_size then
		while outgoing_used + len > outgoing_size do
			outgoing_size = outgoing_size * 2
		end

		local new_buff = buffer.create(outgoing_size)
		buffer.copy(new_buff, 0, outgoing_buff, 0, outgoing_used)

		outgoing_buff = new_buff
	end

	outgoing_apos = outgoing_used
	outgoing_used = outgoing_used + len

	return outgoing_apos
end

local function read(len: number)
	local pos = incoming_read
	incoming_read = incoming_read + len

	return pos
end

local function save()
	return {
		buff = outgoing_buff,
		used = outgoing_used,
		size = outgoing_size,
		inst = outgoing_inst,
	}
end

local function load(data: {
	buff: buffer,
	used: number,
	size: number,
	inst: { Instance },
})
	outgoing_buff = data.buff
	outgoing_used = data.used
	outgoing_size = data.size
	outgoing_inst = data.inst
end

local function load_empty()
	outgoing_buff = buffer.create(64)
	outgoing_used = 0
	outgoing_size = 64
	outgoing_inst = {}
end

load_empty()

local types = {}

local polling_queues = {}
if not RunService:IsRunning() then
	local noop = function() end
	return table.freeze({
		SendEvents = noop,
		BulkPurchaseAvatarItems = table.freeze({
			Fire = noop
		}),
		UpdateAvatar = table.freeze({
			Fire = noop
		}),
		GetFeaturedItems = table.freeze({
			Call = noop
		}),
	}) :: Events
end
if RunService:IsServer() then
	error("Cannot use the client module on the server!")
end
local remotes = ReplicatedStorage:WaitForChild("ZAP")

local reliable = remotes:WaitForChild("AVALOG_RELIABLE")
assert(reliable:IsA("RemoteEvent"), "Expected AVALOG_RELIABLE to be a RemoteEvent")

export type SerEnumItem = ({
	EnumType: (string),
	Value: (number),
})
function types.write_SerEnumItem(value: SerEnumItem)
	local len_1 = #value.EnumType
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.EnumType, len_1)
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, value.Value)
end
function types.read_SerEnumItem()
	local value;
	value = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.EnumType = buffer.readstring(incoming_buff, read(len_1), len_1)
	value.Value = buffer.readu16(incoming_buff, read(2))
	return value
end
export type AvatarItem = ({
	Id: (number),
	Type: (SerEnumItem),
	AssetType: (SerEnumItem),
	Name: (string),
})
function types.write_AvatarItem(value: AvatarItem)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Id)
	types.write_SerEnumItem(value.Type)
	types.write_SerEnumItem(value.AssetType)
	local len_1 = #value.Name
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.Name, len_1)
end
function types.read_AvatarItem()
	local value;
	value = {}
	value.Id = buffer.readf64(incoming_buff, read(8))
	value.Type = types.read_SerEnumItem()
	value.AssetType = types.read_SerEnumItem()
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.Name = buffer.readstring(incoming_buff, read(len_1), len_1)
	return value
end
export type BulkPurchaseAvatarItem = ({
	Id: (string),
	Type: (SerEnumItem),
})
function types.write_BulkPurchaseAvatarItem(value: BulkPurchaseAvatarItem)
	local len_1 = #value.Id
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.Id, len_1)
	types.write_SerEnumItem(value.Type)
end
function types.read_BulkPurchaseAvatarItem()
	local value;
	value = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.Id = buffer.readstring(incoming_buff, read(len_1), len_1)
	value.Type = types.read_SerEnumItem()
	return value
end
export type CatalogItem = ({
	AssetId: (number),
	Name: (string),
	Type: (SerEnumItem),
	AssetType: (SerEnumItem),
})
function types.write_CatalogItem(value: CatalogItem)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.AssetId)
	local len_1 = #value.Name
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.Name, len_1)
	types.write_SerEnumItem(value.Type)
	types.write_SerEnumItem(value.AssetType)
end
function types.read_CatalogItem()
	local value;
	value = {}
	value.AssetId = buffer.readf64(incoming_buff, read(8))
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.Name = buffer.readstring(incoming_buff, read(len_1), len_1)
	value.Type = types.read_SerEnumItem()
	value.AssetType = types.read_SerEnumItem()
	return value
end
export type AccessorySpec = ({
	AssetId: (number),
	AccessoryType: (SerEnumItem),
	Order: ((number)?),
	Puffiness: ((number)?),
	IsLayered: ((boolean)?),
	Position: ((Vector3)?),
	Rotation: ((Vector3)?),
	Scale: ((Vector3)?),
})
function types.write_AccessorySpec(value: AccessorySpec)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.AssetId)
	types.write_SerEnumItem(value.AccessoryType)
	if value.Order == nil then
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 0)
	else
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 1)
		alloc(2)
		buffer.writeu16(outgoing_buff, outgoing_apos, value.Order)
	end
	if value.Puffiness == nil then
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 0)
	else
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 1)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Puffiness)
	end
	if value.IsLayered == nil then
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 0)
	else
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 1)
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, value.IsLayered and 1 or 0)
	end
	if value.Position == nil then
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 0)
	else
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 1)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Position.X)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Position.Y)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Position.Z)
	end
	if value.Rotation == nil then
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 0)
	else
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 1)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Rotation.X)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Rotation.Y)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Rotation.Z)
	end
	if value.Scale == nil then
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 0)
	else
		alloc(1)
		buffer.writeu8(outgoing_buff, outgoing_apos, 1)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.X)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Y)
		alloc(4)
		buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Z)
	end
end
function types.read_AccessorySpec()
	local value;
	value = {}
	value.AssetId = buffer.readf64(incoming_buff, read(8))
	value.AccessoryType = types.read_SerEnumItem()
	if buffer.readu8(incoming_buff, read(1)) == 1 then
		value.Order = buffer.readu16(incoming_buff, read(2))
	else
		value.Order = nil
	end
	if buffer.readu8(incoming_buff, read(1)) == 1 then
		value.Puffiness = buffer.readf32(incoming_buff, read(4))
	else
		value.Puffiness = nil
	end
	if buffer.readu8(incoming_buff, read(1)) == 1 then
		value.IsLayered = buffer.readu8(incoming_buff, read(1)) == 1
	else
		value.IsLayered = nil
	end
	if buffer.readu8(incoming_buff, read(1)) == 1 then
		value.Position = Vector3.new(buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)))
	else
		value.Position = nil
	end
	if buffer.readu8(incoming_buff, read(1)) == 1 then
		value.Rotation = Vector3.new(buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)))
	else
		value.Rotation = nil
	end
	if buffer.readu8(incoming_buff, read(1)) == 1 then
		value.Scale = Vector3.new(buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)))
	else
		value.Scale = nil
	end
	return value
end
export type EquippedEmote = ({
	Name: (string),
	Slot: (number),
})
function types.write_EquippedEmote(value: EquippedEmote)
	local len_1 = #value.Name
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.Name, len_1)
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, value.Slot)
end
function types.read_EquippedEmote()
	local value;
	value = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.Name = buffer.readstring(incoming_buff, read(len_1), len_1)
	value.Slot = buffer.readu16(incoming_buff, read(2))
	return value
end
export type HumanoidDescriberData = ({
	Accessories: ({ (AccessorySpec) }),
	Emotes: ({ [(string)]: ({ (number) }) }),
	EquippedEmotes: ({ (EquippedEmote) }),
	Face: (number),
	Scale: ({
		BodyType: (number),
		Depth: (number),
		Head: (number),
		Height: (number),
		Proportion: (number),
		Width: (number),
	}),
	Animations: ({
		Walk: (number),
		Run: (number),
		Fall: (number),
		Climb: (number),
		Swim: (number),
		Idle: (number),
		Mood: (number),
		Jump: (number),
	}),
	BodyParts: ({
		Head: (number),
		Torso: (number),
		LeftArm: (number),
		RightArm: (number),
		LeftLeg: (number),
		RightLeg: (number),
	}),
	BodyPartColors: ({
		Head: (Color3),
		Torso: (Color3),
		LeftArm: (Color3),
		RightArm: (Color3),
		LeftLeg: (Color3),
		RightLeg: (Color3),
	}),
	Clothing: ({
		Shirt: (number),
		TShirt: (number),
		Pants: (number),
	}),
})
function types.write_HumanoidDescriberData(value: HumanoidDescriberData)
	local len_1 = #value.Accessories
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	for i_1 = 1, len_1 do
		local val_1 = value.Accessories[i_1]
		types.write_AccessorySpec(val_1)
	end
	local len_pos_1 = alloc(2)
	local len_2 = 0
	for k_1, v_1 in value.Emotes do
		len_2 = len_2 + 1
		local len_3 = #k_1
		alloc(2)
		buffer.writeu16(outgoing_buff, outgoing_apos, len_3)
		alloc(len_3)
		buffer.writestring(outgoing_buff, outgoing_apos, k_1, len_3)
		local len_4 = #v_1
		alloc(2)
		buffer.writeu16(outgoing_buff, outgoing_apos, len_4)
		for i_2 = 1, len_4 do
			local val_2 = v_1[i_2]
			alloc(8)
			buffer.writef64(outgoing_buff, outgoing_apos, val_2)
		end
	end
	buffer.writeu16(outgoing_buff, len_pos_1, len_2)
	local len_5 = #value.EquippedEmotes
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_5)
	for i_3 = 1, len_5 do
		local val_3 = value.EquippedEmotes[i_3]
		types.write_EquippedEmote(val_3)
	end
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Face)
	alloc(4)
	buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.BodyType)
	alloc(4)
	buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Depth)
	alloc(4)
	buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Head)
	alloc(4)
	buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Height)
	alloc(4)
	buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Proportion)
	alloc(4)
	buffer.writef32(outgoing_buff, outgoing_apos, value.Scale.Width)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Walk)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Run)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Fall)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Climb)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Swim)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Idle)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Mood)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Animations.Jump)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.BodyParts.Head)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.BodyParts.Torso)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.BodyParts.LeftArm)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.BodyParts.RightArm)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.BodyParts.LeftLeg)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.BodyParts.RightLeg)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.Head.R * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.Head.G * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.Head.B * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.Torso.R * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.Torso.G * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.Torso.B * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.LeftArm.R * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.LeftArm.G * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.LeftArm.B * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.RightArm.R * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.RightArm.G * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.RightArm.B * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.LeftLeg.R * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.LeftLeg.G * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.LeftLeg.B * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.RightLeg.R * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.RightLeg.G * 255)
	alloc(1)
	buffer.writeu8(outgoing_buff, outgoing_apos, value.BodyPartColors.RightLeg.B * 255)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Clothing.Shirt)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Clothing.TShirt)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Clothing.Pants)
end
function types.read_HumanoidDescriberData()
	local value;
	value = {}
	value.Accessories = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	for i_1 = 1, len_1 do
		local val_1
		val_1 = types.read_AccessorySpec()
		value.Accessories[i_1] = val_1
	end
	value.Emotes = {}
	for _ = 1, buffer.readu16(incoming_buff, read(2)) do
		local key_1
		local val_2
		local len_2 = buffer.readu16(incoming_buff, read(2))
		key_1 = buffer.readstring(incoming_buff, read(len_2), len_2)
		val_2 = {}
		local len_3 = buffer.readu16(incoming_buff, read(2))
		for i_2 = 1, len_3 do
			local val_3
			val_3 = buffer.readf64(incoming_buff, read(8))
			val_2[i_2] = val_3
		end
		value.Emotes[key_1] = val_2
	end
	value.EquippedEmotes = {}
	local len_4 = buffer.readu16(incoming_buff, read(2))
	for i_3 = 1, len_4 do
		local val_4
		val_4 = types.read_EquippedEmote()
		value.EquippedEmotes[i_3] = val_4
	end
	value.Face = buffer.readf64(incoming_buff, read(8))
	value.Scale = {}
	value.Scale.BodyType = buffer.readf32(incoming_buff, read(4))
	value.Scale.Depth = buffer.readf32(incoming_buff, read(4))
	value.Scale.Head = buffer.readf32(incoming_buff, read(4))
	value.Scale.Height = buffer.readf32(incoming_buff, read(4))
	value.Scale.Proportion = buffer.readf32(incoming_buff, read(4))
	value.Scale.Width = buffer.readf32(incoming_buff, read(4))
	value.Animations = {}
	value.Animations.Walk = buffer.readf64(incoming_buff, read(8))
	value.Animations.Run = buffer.readf64(incoming_buff, read(8))
	value.Animations.Fall = buffer.readf64(incoming_buff, read(8))
	value.Animations.Climb = buffer.readf64(incoming_buff, read(8))
	value.Animations.Swim = buffer.readf64(incoming_buff, read(8))
	value.Animations.Idle = buffer.readf64(incoming_buff, read(8))
	value.Animations.Mood = buffer.readf64(incoming_buff, read(8))
	value.Animations.Jump = buffer.readf64(incoming_buff, read(8))
	value.BodyParts = {}
	value.BodyParts.Head = buffer.readf64(incoming_buff, read(8))
	value.BodyParts.Torso = buffer.readf64(incoming_buff, read(8))
	value.BodyParts.LeftArm = buffer.readf64(incoming_buff, read(8))
	value.BodyParts.RightArm = buffer.readf64(incoming_buff, read(8))
	value.BodyParts.LeftLeg = buffer.readf64(incoming_buff, read(8))
	value.BodyParts.RightLeg = buffer.readf64(incoming_buff, read(8))
	value.BodyPartColors = {}
	value.BodyPartColors.Head = Color3.fromRGB(buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)))
	value.BodyPartColors.Torso = Color3.fromRGB(buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)))
	value.BodyPartColors.LeftArm = Color3.fromRGB(buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)))
	value.BodyPartColors.RightArm = Color3.fromRGB(buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)))
	value.BodyPartColors.LeftLeg = Color3.fromRGB(buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)))
	value.BodyPartColors.RightLeg = Color3.fromRGB(buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)), buffer.readu8(incoming_buff, read(1)))
	value.Clothing = {}
	value.Clothing.Shirt = buffer.readf64(incoming_buff, read(8))
	value.Clothing.TShirt = buffer.readf64(incoming_buff, read(8))
	value.Clothing.Pants = buffer.readf64(incoming_buff, read(8))
	return value
end
export type FeaturedItem = ({
	TransactionHash: (string),
	Bid: (number),
	StartTime: (number),
	EndTime: (number),
	Power: (number),
	Id: (number),
	ItemType: (SerEnumItem),
})
function types.write_FeaturedItem(value: FeaturedItem)
	local len_1 = #value.TransactionHash
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.TransactionHash, len_1)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Bid)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.StartTime)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.EndTime)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Power)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Id)
	types.write_SerEnumItem(value.ItemType)
end
function types.read_FeaturedItem()
	local value;
	value = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.TransactionHash = buffer.readstring(incoming_buff, read(len_1), len_1)
	value.Bid = buffer.readf64(incoming_buff, read(8))
	value.StartTime = buffer.readf64(incoming_buff, read(8))
	value.EndTime = buffer.readf64(incoming_buff, read(8))
	value.Power = buffer.readf64(incoming_buff, read(8))
	value.Id = buffer.readf64(incoming_buff, read(8))
	value.ItemType = types.read_SerEnumItem()
	return value
end
export type FeaturedCreator = ({
	TransactionHash: (string),
	Bid: (number),
	StartTime: (number),
	EndTime: (number),
	Power: (number),
	Id: (number),
	CreatorType: (SerEnumItem),
})
function types.write_FeaturedCreator(value: FeaturedCreator)
	local len_1 = #value.TransactionHash
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	alloc(len_1)
	buffer.writestring(outgoing_buff, outgoing_apos, value.TransactionHash, len_1)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Bid)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.StartTime)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.EndTime)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Power)
	alloc(8)
	buffer.writef64(outgoing_buff, outgoing_apos, value.Id)
	types.write_SerEnumItem(value.CreatorType)
end
function types.read_FeaturedCreator()
	local value;
	value = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	value.TransactionHash = buffer.readstring(incoming_buff, read(len_1), len_1)
	value.Bid = buffer.readf64(incoming_buff, read(8))
	value.StartTime = buffer.readf64(incoming_buff, read(8))
	value.EndTime = buffer.readf64(incoming_buff, read(8))
	value.Power = buffer.readf64(incoming_buff, read(8))
	value.Id = buffer.readf64(incoming_buff, read(8))
	value.CreatorType = types.read_SerEnumItem()
	return value
end
export type FeaturedData = ({
	Items: ({ (FeaturedItem) }),
	Creators: ({ (FeaturedCreator) }),
})
function types.write_FeaturedData(value: FeaturedData)
	local len_1 = #value.Items
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
	for i_1 = 1, len_1 do
		local val_1 = value.Items[i_1]
		types.write_FeaturedItem(val_1)
	end
	local len_2 = #value.Creators
	alloc(2)
	buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
	for i_2 = 1, len_2 do
		local val_2 = value.Creators[i_2]
		types.write_FeaturedCreator(val_2)
	end
end
function types.read_FeaturedData()
	local value;
	value = {}
	value.Items = {}
	local len_1 = buffer.readu16(incoming_buff, read(2))
	for i_1 = 1, len_1 do
		local val_1
		val_1 = types.read_FeaturedItem()
		value.Items[i_1] = val_1
	end
	value.Creators = {}
	local len_2 = buffer.readu16(incoming_buff, read(2))
	for i_2 = 1, len_2 do
		local val_2
		val_2 = types.read_FeaturedCreator()
		value.Creators[i_2] = val_2
	end
	return value
end

local function SendEvents()
	if outgoing_used ~= 0 then
		local buff = buffer.create(outgoing_used)
		buffer.copy(buff, 0, outgoing_buff, 0, outgoing_used)

		reliable:FireServer(buff, outgoing_inst)

		outgoing_buff = buffer.create(64)
		outgoing_used = 0
		outgoing_size = 64
		table.clear(outgoing_inst)
	end
end

RunService.Heartbeat:Connect(SendEvents)

local reliable_events = table.create(1)
local reliable_event_queue: { [number]: { any } } = table.create(1)
local function_call_id = 0
reliable_event_queue[0] = table.create(255)
reliable.OnClientEvent:Connect(function(buff, inst)
	incoming_buff = buff
	incoming_inst = inst
	incoming_read = 0
	incoming_ipos = 0
	local len = buffer.len(buff)
	while incoming_read < len do
		local id = buffer.readu8(buff, read(1))
		if id == 0 then
			local call_id = buffer.readu8(incoming_buff, read(1))
			local value
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				value = {}
				local len_1 = buffer.readu16(incoming_buff, read(2))
				for i_1 = 1, len_1 do
					local val_1
					val_1 = types.read_FeaturedItem()
					value[i_1] = val_1
				end
			else
				value = nil
			end
			local thread = reliable_event_queue[0][call_id]
			-- When using actors it's possible for multiple Zap clients to exist, but only one called the Zap remote function.
			if thread then
				task.spawn(thread, value)
			end
			reliable_event_queue[0][call_id] = nil
		else
			error("Unknown event id")
		end
	end
end)
table.freeze(polling_queues)

local returns = {
	SendEvents = SendEvents,
	BulkPurchaseAvatarItems = {
		Fire = function(Value: ({ (BulkPurchaseAvatarItem) }))
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			local len_2 = #Value
			assert(len_2 >= 1)
			assert(len_2 <= 20)
			alloc(2)
			buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
			for i_2 = 1, len_2 do
				local val_2 = Value[i_2]
				types.write_BulkPurchaseAvatarItem(val_2)
			end
		end,
	},
	UpdateAvatar = {
		Fire = function(Value: (HumanoidDescriberData))
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 1)
			types.write_HumanoidDescriberData(Value)
		end,
	},
	GetFeaturedItems = {
		Call = function(Value: (number), Value2: (number)): ((({ (FeaturedItem) })?))
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 2)
			function_call_id += 1
			function_call_id %= 256
			if reliable_event_queue[0][function_call_id] then
				function_call_id -= 1
				error("Zap has more than 256 calls awaiting a response, and therefore this packet has been dropped")
			end
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, function_call_id)
			alloc(4)
			buffer.writeu32(outgoing_buff, outgoing_apos, Value)
			alloc(4)
			buffer.writeu32(outgoing_buff, outgoing_apos, Value2)
			reliable_event_queue[0][function_call_id] = coroutine.running()
			return coroutine.yield()
		end,
	},
}
type Events = typeof(returns)
return returns
