local addon, ns = ...
local _TEXTURE = [[Interface\AddOns\oUF_Starlon\textures\statusbar]]
local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")
local core = LibCore:New({}, addon, 2)

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

local Shared = function(self, unit, isSingle)
	self.menu = menu

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"AnyUp"

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(.3, .3, .3, 1)

	-- Health bar
	local fs1 = self:CreateFontString()
	fs1:SetFontObject(GameTooltipTextSmall)
	fs1.value = [[
return Name(unit)
]]
	fs1:SetPoint("CENTER")

	local fs2 = self:CreateFontString()
	fs2.value = [[
return Guild(unit)
]]
	fs2:SetPoint("BOTTOM", fs1, "TOP")
	fs2:SetFontObject(GameTooltipTextSmall)
	self.ScriptableText = {fs1, fs2}

	self.core = core

	self:SetSize(260, 48)
end

local UnitSpecific = {
}

do
	local PLAYER_UPDATE_RESTING = function(self)
		if(IsResting()) then
			self:SetBackdropBorderColor(.3, .3, .8)
		else
			local r, g, b = UnitSelectionColor(self.unit)
			self:SetBackdropBorderColor(r, g, b)
		end
	end

	UnitSpecific.player = function(self, ...)
		Shared(self, ...)

		self:RegisterEvent("PLAYER_UPDATE_RESTING", PLAYER_UPDATE_RESTING)
	end
end

oUF:RegisterStyle("Starlon", Shared)
for unit,layout in next, UnitSpecific do
	-- Capitalize the unit name, so it looks better.
	oUF:RegisterStyle('Starlon - ' .. unit:gsub("^%l", string.upper), layout)
end

-- A small helper to change the style into a unit specific, if it exists.
local spawnHelper = function(self, unit, ...)
	if(UnitSpecific[unit]) then
		self:SetActiveStyle('Starlon - ' .. unit:gsub("^%l", string.upper))
	else
		self:SetActiveStyle'Starlon'
	end

	local object = self:Spawn(unit)
	object:SetPoint(...)
	return object
end

oUF:Factory(function(self)
	spawnHelper(self, 'player', "CENTER", UIParent)
end)
