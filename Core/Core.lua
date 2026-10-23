---@diagnostic disable-next-line: deprecated
local E = unpack(ElvUI);
local L = E.Libs.ACL:GetLocale("ElvUI_DmgAtNameplates", E:GetLocale())
local NP = E:GetModule('NamePlates');
local EP = E.Libs.EP
local DAN = E:GetModule('DmgAtNameplates')
local LSM = E.Libs.LSM

local CreateFrame = CreateFrame
local mtfl, mtpw, mtrn = math.floor, math.pow, math.random
local tostring, tonumber = tostring, tonumber
local format = string.format
local next, select, pairs, ipairs = next, select, pairs, ipairs
local tinsert, tremove = table.insert, table.remove
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local band = bit.band

local SMALL_HIT_EXPIRY_WINDOW = 30
local SMALL_HIT_MULTIPIER = 0.5

local ANIMATION_VERTICAL_DISTANCE = 75

local ANIMATION_ARC_X_MIN = 50
local ANIMATION_ARC_X_MAX = 150
local ANIMATION_ARC_Y_TOP_MIN = 10
local ANIMATION_ARC_Y_TOP_MAX = 50
local ANIMATION_ARC_Y_BOTTOM_MIN = 10
local ANIMATION_ARC_Y_BOTTOM_MAX = 50

local ANIMATION_RAINFALL_X_MAX = 75
local ANIMATION_RAINFALL_Y_MIN = 50
local ANIMATION_RAINFALL_Y_MAX = 100
local ANIMATION_RAINFALL_Y_START_MIN = 5
local ANIMATION_RAINFALL_Y_START_MAX = 15

local AutoAttack = select(1, GetSpellInfo(6603))
local AutoAttackPet = select(1, GetSpellInfo(315235))

local AutoShot = select(1, GetSpellInfo(75))
local targetUnitType
DAN.DmgTextFrame = CreateFrame("Frame", nil, UIParent)
DAN.DmgTextFrame:SetFrameStrata("MEDIUM")
DAN.DmgTextFrame:SetFrameLevel(DAN.DmgTextFrame:GetFrameLevel() + 1)

DAN.ElvUI_ToPlayerFrame = CreateFrame("Frame", nil, UIParent)
DAN.ElvUI_ToPlayerFrame:SetPoint("CENTER",UIParent,"CENTER",300,0)
DAN.ElvUI_ToPlayerFrame:SetSize(300,32)

DAN.ElvUI_ToTargetFrame = CreateFrame("Frame", nil, UIParent)
DAN.ElvUI_ToTargetFrame:SetPoint("CENTER",UIParent,"CENTER",-300,0)
DAN.ElvUI_ToTargetFrame:SetSize(300,32)

local animating = {}

local DAMAGE_TYPE_COLORS = {
	[SCHOOL_MASK_PHYSICAL] = "FFFF00",
	[SCHOOL_MASK_HOLY] = "FFE680",
	[SCHOOL_MASK_FIRE] = "FF8000",
	[SCHOOL_MASK_NATURE] = "4DFF4D",
	[SCHOOL_MASK_FROST] = "80FFFF",
	[SCHOOL_MASK_FROST + SCHOOL_MASK_FIRE] = "FF80FF",
	[SCHOOL_MASK_SHADOW] = "8080FF",
	[SCHOOL_MASK_ARCANE] = "FF80FF",
	[AutoAttack] = "FFFFFF",
	[AutoShot] = "FFFFFF",
	["pet"] = "CC8400"
}
local MISS_EVENT_STRINGS = {
	["ABSORB"] = L["Absorb"],
	["BLOCK"] = L["Block"],
	["DEFLECT"] = L["Deflect"],
	["DODGE"] = L["Dodge"],
	["EVADE"] = L["Evade"],
	["IMMUNE"] = L["Immune"],
	["MISS"] = L["Miss"],
	["PARRY"] = L["Parry"],
	["REFLECT"] = L["Reflected"],
	["RESIST"] = L["Resisted"]
}

function DAN:GetUnitTypeByFlag(flag)
	local sReturn = ""
	flag = flag or 0
	if band(flag, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
		sReturn = "Player"
	elseif band (flag, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
		sReturn = "NPC"
	end
	if band(flag, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 then
		sReturn = sReturn.."Friend"
	elseif (band(flag, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0) or (band(flag, COMBATLOG_OBJECT_REACTION_NEUTRAL) > 0) then
		sReturn = sReturn.."Enemy"
	end
	return sReturn
end

function DAN:rgbToHex(r, g, b)
	return format("%02x%02x%02x", mtfl(255 * r), mtfl(255 * g), mtfl(255 * b))
end

function DAN:hexToRGB(hex)
	return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, 1
end
function DAN:CSEP(number)
	-- https://stackoverflow.com/questions/10989788/lua-format-integer
	local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)');
	int = int:reverse():gsub("(%d%d%d)", "%1,");
	return minus..int:reverse():gsub("^,", "")..fraction;
end

-- damage spell events
local dse = {
	DAMAGE_SHIELD = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	SPELL_BUILDING_DAMAGE = true,
	RANGE_DAMAGE = true
}
--miss spell events
local mse = {
	SPELL_MISSED = true,
	SPELL_PERIODIC_MISSED = true,
	RANGE_MISSED = true,
	SPELL_BUILDING_MISSED = true,
}
-- heal spell events
local hse = {
	SPELL_HEAL = true,
	SPELL_PERIODIC_HEAL = true

}
--spell interrupt
local csi = {
	SPELL_INTERRUPT = true
}

local pguid

function DAN:GetFontPath(fontName)
	local fontPath = LSM:Fetch("font", fontName) or "Fonts\\FRIZQT__.TTF"
	return fontPath
end
local platesByGUID, guidByPlate = {}, {}

local function ForgetPlate(plate)
	local frame = plate and (plate.ElvUIFrame or plate)
	local guid = frame and guidByPlate[frame]
	if guid and platesByGUID[guid] == frame then platesByGUID[guid] = nil end
	if frame then guidByPlate[frame] = nil end
end

local function IndexPlate(plate)
	ForgetPlate(plate)
	local frame = plate and (plate.ElvUIFrame or plate)
	if frame and frame.guid and frame:IsShown() then
		platesByGUID[frame.guid] = frame
		guidByPlate[frame] = frame.guid
	end
end

local function DetachTexts(frame)
	local cx, cy = UIParent:GetCenter()
	for fontString in pairs(animating) do
		if fontString.nameplateFrame == frame then
			local x, y = fontString:GetCenter()
			if x and fontString.offsetX then
				fontString.startX = x - cx - fontString.offsetX
				fontString.startY = y - cy - fontString.offsetY
				fontString.anchorFrame, fontString.nameplateFrame, fontString.anchorGUID = UIParent, nil, nil
			else
				DAN:DeleteFontString(fontString)
			end
		end
	end
end

local function HidePlate(plate)
	local frame = plate and (plate.ElvUIFrame or plate)
	if frame then DetachTexts(frame) end
	ForgetPlate(plate)
end

function DAN:InitializePlateIndex()
	hooksecurefunc(NP, "OnShow", IndexPlate)
	hooksecurefunc(NP, "OnHide", HidePlate)
	for frame in pairs(NP.VisiblePlates) do IndexPlate(frame) end
end

function DAN:GetNameplateFrame(guid)
	local frame = guid and platesByGUID[guid]
	if frame and frame:IsShown() and frame.guid == guid and (not frame.unit or UnitGUID(frame.unit) == guid) then
		return frame
	end
end

function DAN:GetFrame(whoguid, whoname, whoflag, tguid, tname, tflag)
	if not pguid or not tguid then return end
	if tguid == pguid then return self.ElvUI_ToPlayerFrame end
	if whoguid == pguid or self:IsSourceMyPet(whoguid, whoflag) then
		local frame = self:GetNameplateFrame(tguid)
		if frame then return frame end
		if UnitGUID("target") == tguid then return self.ElvUI_ToTargetFrame end
	end
end
local fontStringCache = {}
function DAN:GetFontString(frame)
	local fontString = tremove(fontStringCache)
	if not fontString then
		fontString = DAN.DmgTextFrame:CreateFontString(nil, "OVERLAY")
		fontString:SetShadowOffset(0, 0)
		fontString.icon = DAN.DmgTextFrame:CreateTexture(nil, "OVERLAY")
		fontString.icon:SetTexCoord(0.062, 0.938, 0.062, 0.938)
	end
	fontString:Show()
	fontString.icon:Hide()

	local x, y = frame:GetSize()
	fontString.startX = mtrn(-mtfl(x / 2), mtfl(x / 2))
	fontString.startY = mtrn(-mtfl(y / 2), mtfl(y / 2))
	return fontString
end

function DAN:DeleteFontString(fontString)
	animating[fontString] = nil
	fontString:Hide()
	fontString:ClearAllPoints()
	fontString.icon:Hide()
	fontString.icon:ClearAllPoints()
	fontString.anchorFrame, fontString.nameplateFrame, fontString.anchorGUID = nil, nil, nil
	fontString.offsetX, fontString.offsetY = nil, nil
	fontString.pow = nil
	tinsert(fontStringCache, fontString)
end

local function inQuad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

local function inQuint(t, b, c, d)
	t = t / d
	return c * mtpw(t, 5) + b
end

local function outQuint(t, b, c, d)
	t = t / d - 1
	return c * (mtpw(t, 5) + 1) + b
end

local function inExpo(t, b, c, d)
	if t == 0 then return b end
	return c * mtpw(2, 10 * (t / d - 1)) + b - c * 0.001
end

local function verticalPath(elapsed, duration, distance)
	return 0, inQuad(elapsed, 0, distance, duration)
end

local function arcPath(elapsed, duration, xDist, yStart, yTop, yBottom)
	local x, y
	local progress = elapsed / duration

	x = progress * xDist

	local a = -2 * yStart + 4 * yTop - 2 * yBottom
	local b = -3 * yStart + 4 * yTop - yBottom

	y = -a * mtpw(progress, 2) + b * progress + yStart

	return x, y
end

local function powSizing(elapsed, duration, start, middle, finish)
	local size = finish
	if elapsed < duration then
		if elapsed / duration < 0.5 then
			size = outQuint(elapsed, start, middle - start, duration / 2)
		else
			size = inQuint(elapsed - duration / 2, middle, finish - middle, duration / 2)
		end
	end
	return size
end

local function AnimationOnUpdate()
	local now = GetTime()
	if next(animating) then
		for fontString, _ in pairs(animating) do
			local elapsed = now - fontString.animatingStartTime
			local plate = fontString.nameplateFrame
			if elapsed > fontString.animatingDuration or (plate and (plate.guid ~= fontString.anchorGUID or not plate:IsShown())) then
				DAN:DeleteFontString(fontString)
			else
				local startAlpha = fontString.startAlpha or 1
				local alpha = inExpo(elapsed, startAlpha, -startAlpha, fontString.animatingDuration)
				fontString:SetAlpha(alpha)
				if fontString.icon and fontString.icon:IsShown() then fontString.icon:SetAlpha(alpha) end

				if fontString.pow then
					local height = fontString.startHeight
					if elapsed < fontString.animatingDuration / 6 then
						fontString:SetText(fontString.DANText)
						local size =
							powSizing(elapsed, fontString.animatingDuration / 6, height / 2, height * 2, height)
						fontString:SetTextHeight(size)
					else
						fontString.pow = nil
						fontString:SetTextHeight(height)
						fontString:SetFont(fontString.fontPath, fontString.DANFontSize, fontString.fontOutline)
						fontString:SetText(fontString.DANText)
					end
				end

				local xOffset, yOffset = 0, 0
				if fontString.animation == "verticalUp" then
					xOffset, yOffset = verticalPath(elapsed, fontString.animatingDuration, fontString.distance)
				elseif fontString.animation == "verticalDown" then
					xOffset, yOffset = verticalPath(elapsed, fontString.animatingDuration, -fontString.distance)
				elseif fontString.animation == "fountain" then
					xOffset, yOffset = arcPath(elapsed, fontString.animatingDuration, fontString.arcXDist, 0, fontString.arcTop, fontString.arcBottom)
				elseif fontString.animation == "rainfall" then
					_, yOffset = verticalPath(elapsed, fontString.animatingDuration, -fontString.distance)
					xOffset = fontString.rainfallX
					yOffset = yOffset + fontString.rainfallStartY
				end

				if fontString.anchorFrame and fontString.anchorFrame:IsShown() then
					fontString.offsetX, fontString.offsetY = xOffset, yOffset
					fontString:SetPoint("CENTER", fontString.anchorFrame, "CENTER", fontString.startX + xOffset, fontString.startY + yOffset)
				else
					DAN:DeleteFontString(fontString)
				end
			end
		end
	else
		DAN.DmgTextFrame:SetScript("OnUpdate", nil)
	end
end

local arcDirection = 1
function DAN:Animate(fontString, anchorFrame, duration, animation)
	animation = animation or "verticalUp"

	fontString.animation = animation
	fontString.animatingDuration = duration
	fontString.animatingStartTime = GetTime()
	fontString.anchorFrame = anchorFrame

	if animation == "verticalUp" then
		fontString.distance = ANIMATION_VERTICAL_DISTANCE
	elseif animation == "verticalDown" then
		fontString.distance = ANIMATION_VERTICAL_DISTANCE
	elseif animation == "fountain" then
		fontString.arcTop = mtrn(ANIMATION_ARC_Y_TOP_MIN, ANIMATION_ARC_Y_TOP_MAX)
		fontString.arcBottom = -mtrn(ANIMATION_ARC_Y_BOTTOM_MIN, ANIMATION_ARC_Y_BOTTOM_MAX)
		fontString.arcXDist = arcDirection * mtrn(ANIMATION_ARC_X_MIN, ANIMATION_ARC_X_MAX)

		arcDirection = arcDirection * -1
	elseif animation == "rainfall" then
		fontString.distance = mtrn(ANIMATION_RAINFALL_Y_MIN, ANIMATION_RAINFALL_Y_MAX)
		fontString.rainfallX = mtrn(-ANIMATION_RAINFALL_X_MAX, ANIMATION_RAINFALL_X_MAX)
		fontString.rainfallStartY = -mtrn(ANIMATION_RAINFALL_Y_START_MIN, ANIMATION_RAINFALL_Y_START_MAX)
	end

	animating[fontString] = true

	-- start onupdate if it's not already running
	if DAN.DmgTextFrame:GetScript("OnUpdate") == nil then
		DAN.DmgTextFrame:SetScript("OnUpdate", AnimationOnUpdate)
	end
end

function DAN:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName, etype)
	if not f or animation == "disabled" then return end
	local fontString = self:GetFontString(f)

	fontString.DANText = text
	fontString.DANFontSize = size
	fontString.fontPath = self:GetFontPath(etype and self.db[etype].font or self.db.font)
	fontString.fontOutline = etype and self.db[etype].fontOutline or self.db.fontOutline
	fontString.startAlpha = alpha or 1
	fontString:SetAlpha(fontString.startAlpha)
	fontString:SetFont(fontString.fontPath, size, fontString.fontOutline)
	fontString:SetText(text)

	fontString.startHeight = fontString:GetStringHeight()
	if fontString.startHeight <= 0 then
		fontString.startHeight = 5
	end
	fontString.pow = pow

	if self.db.showIcon then
		local texture = select(3, GetSpellInfo(spellId or spellName))
		if not texture and spellName then
			texture = select(3, GetSpellInfo(spellName))
		end
		if texture then
			local icon = fontString.icon
			icon:SetTexture(texture)
			icon:SetSize(size, size)
			icon:SetPoint("LEFT", fontString, "RIGHT", 0, 0)
			icon:SetAlpha(fontString.startAlpha)
			icon:Show()
		end
	end

	local anchor = f.Health and f.Health:IsShown() and f.Health or f
	fontString.nameplateFrame = f.guid and f or nil
	fontString.anchorGUID = f.guid
	self:Animate(fontString, anchor, self.db.duration, animation)
end

function DAN:FormatAmount(amount)
	local textFormat = self.db.textFormat
	if textFormat == "kkk" then
		return format("%.1fk", amount / 1000)
	elseif textFormat == "csep" then
		return self:CSEP(amount)
	end
	return amount
end

local numDamageEvents = 0
local lastDamageEventTime
local runningAverageDamageEvents = 0
function DAN:DamageEvent(f, spellName, amount, school, crit, spellId, whog, whoName)
	if not f then return end
	local db = self.db

	if targetUnitType == "PlayerEnemy" or targetUnitType == "NPCEnemy" then
		if not db.showDmgToEnemy then return end
	elseif targetUnitType == "PlayerFriend" or targetUnitType == "NPCFriend" then
		if not db.showDmgToFriend then return end
	end

	local animation
	if spellName == AutoAttack or spellName == AutoShot or spellName == AutoAttackPet then
		animation = crit and (db.autoAttackPlusCritAnimation or "verticalUp") or (db.autoAttack or "fountain")
	else
		animation = crit and (db.critAnimation or "fountain") or (db.commonDMGAnimation or "fountain")
	end

	local color = (spellName == AutoAttack or spellName == AutoShot) and DAMAGE_TYPE_COLORS[spellName]
		or DAMAGE_TYPE_COLORS[school] or "ffff00"
	local text = "|cff" .. color .. self:FormatAmount(amount) .. "|r"
	if whog ~= pguid and db.showFromAnotherPlayer and whoName then
		text = whoName .. "  " .. text
	end

	local size, alpha
	if db.showOffTargetText and f.guid and f.guid ~= UnitGUID("target") then
		size = db.showOffTargetTextSize or 20
		alpha = db.showOffTargetTextAlpha or 1
	else
		size = db.fontSize or 20
		alpha = db.fontAlpha or 1
	end

	if db.smallHits or db.smallHitsHide then
		local now = GetTime()
		if not lastDamageEventTime or lastDamageEventTime + SMALL_HIT_EXPIRY_WINDOW < now then
			numDamageEvents = 0
			runningAverageDamageEvents = 0
		end
		runningAverageDamageEvents = ((runningAverageDamageEvents * numDamageEvents) + amount) / (numDamageEvents + 1)
		numDamageEvents = numDamageEvents + 1
		lastDamageEventTime = now
		if (crit and amount / 2 or amount) < SMALL_HIT_MULTIPIER * runningAverageDamageEvents then
			if db.smallHitsHide then return end
			size = size * (db.smallHitsScale or 1)
		end
	end

	if size < 5 then
		size = 5
	end

	self:DisplayText(f, text, size, alpha, animation, spellId, crit and true or false, spellName)
end

function DAN:HealEvent(f, spellName, amount, crit, spellId, overheal)
	if not f then return end
	local db = self.db
	local text
	if amount == overheal then
		if not db.showOverHeal then return end
		text = format(L["OverhealFormat"], self:FormatAmount(overheal))
	else
		text = self:FormatAmount(amount)
	end
	local animation = crit and (db.healCrit or "verticalUp") or (db.noHealCrit or "fountain")
	self:DisplayText(f, "|cff" .. (db.healColor or "ffff00") .. text .. "|r", db.fontSize or 20, 1, animation, spellId, false, spellName)
end

function DAN:CategoryEvent(f, etype, label, spellId, spellName, pow)
	if not f then return end
	local db = self.db[etype]
	self:DisplayText(f, "|cff" .. (db.fontColor or "ffff00") .. label .. "|r", db.fontSize or 20, db.fontAlpha or 1,
		db.animation or "verticalDown", spellId, pow, spellName, etype)
end

function DAN:MissEvent(f, spellName, missType, spellId, isPet)
	if missType == "ABSORB" then return end
	local label = MISS_EVENT_STRINGS[missType] or ACTION_SPELL_MISSED_MISS
	self:CategoryEvent(f, "miss", isPet and format(L["PetMissFormat"], label) or label, spellId, spellName, true)
end

local relevantEvents = { SWING_DAMAGE = true, SWING_MISSED = true, SPELL_DISPEL = true }
for _, events in ipairs({ dse, mse, hse, csi }) do
	for event in pairs(events) do relevantEvents[event] = true end
end

local AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local BITMASK_PETS = COMBATLOG_OBJECT_TYPE_PET + COMBATLOG_OBJECT_TYPE_GUARDIAN

function DAN:IsSourceMyPet(whoguid, whoflag)
	whoflag = whoflag or 0
	if band(whoflag, AFFILIATION_MINE) == 0 or (pguid and whoguid == pguid) then
		return false
	end
	if band(whoflag, BITMASK_PETS) > 0 then
		return true
	end
	local petGuid = UnitExists("pet") and UnitGUID("pet")
	return petGuid ~= nil and whoguid == petGuid
end

function DAN:FilterEvent(_, _, subevent, whoguid, whoname, whoflag, tguid, tname, tflag, spellid, spellname, spellschool, amount, overHeal_Kill, _, args16, _, _, dmgCrit)
	if not relevantEvents[subevent] then return end
	local db = E.db.DmgAtNameplates
	if not db or not db.enable then return end
	self.db = db
	if whoguid ~= pguid and tguid ~= pguid and band(whoflag or 0, AFFILIATION_MINE) == 0 then return end

	local isPlayerEvent = pguid == whoguid
	local isPetEvent = self:IsSourceMyPet(whoguid, whoflag)
	local damageText, healText
	if isPetEvent then
		if subevent == "SPELL_DISPEL" or csi[subevent] then return end
		damageText, healText = db.petToTargetDamageText, db.petToTargetHealText
	elseif isPlayerEvent and tguid ~= pguid then
		damageText, healText = db.playerToTargetDamageText, db.playerToTargetHealText
	elseif isPlayerEvent or tguid == pguid then
		damageText, healText = db.targetToPlayerDamageText, db.targetToPlayerHealText
	end
	if not (hse[subevent] and healText or not hse[subevent] and damageText) then return end

	local f = self:GetFrame(whoguid, whoname, whoflag, tguid, tname, tflag)
	if not f then return end
	targetUnitType = tguid ~= pguid and self:GetUnitTypeByFlag(tflag) or nil

	local swingDamage, swingMiss = subevent == "SWING_DAMAGE", subevent == "SWING_MISSED"
	if swingDamage or swingMiss then
		amount = spellid
		spellname = isPetEvent and AutoAttackPet or AutoAttack
		spellschool = 1
		spellid = isPetEvent and 315235 or 6603
		if swingDamage then dmgCrit = args16 end
	end

	if dse[subevent] or swingDamage then
		self:DamageEvent(f, spellname, amount, isPetEvent and "pet" or spellschool, dmgCrit, spellid, whoguid, whoname)
	elseif mse[subevent] or swingMiss then
		self:MissEvent(f, spellname, amount, spellid, isPetEvent)
	elseif hse[subevent] then
		self:HealEvent(f, spellname, amount, args16, spellid, overHeal_Kill)
	elseif subevent == "SPELL_DISPEL" then
		self:CategoryEvent(f, "dispel", overHeal_Kill, amount, spellname, false)
	else
		self:CategoryEvent(f, "interrupt", format(L["InterruptFormat"], overHeal_Kill), spellid, spellname, true)
	end
end

DAN.DmgTextFrame:SetScript("OnEvent", function(_, event, ...)
	DAN:FilterEvent(event, ...)
end)

function DAN:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	pguid = UnitGUID("player")
	E:CreateMover(self.ElvUI_ToPlayerFrame, "DmgAtNameplatesPlayerMover", L["PlayerDMGFrame"], nil, nil, nil, "ALL", nil, "DmgAtNameplates");
	E:CreateMover(self.ElvUI_ToTargetFrame, "DmgAtNameplatesTargetMover", L["TargetDMGFrame"], nil, nil, nil, "ALL", nil, "DmgAtNameplates");
end

function DAN:ClearTexts()
	for fontString in pairs(animating) do self:DeleteFontString(fontString) end
	self.DmgTextFrame:SetScript("OnUpdate", nil)
end

function DAN:OnDisable()
	self.DmgTextFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:ClearTexts()
end

function DAN:OnEnable()
	self.DmgTextFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local MOVER_RENAMES = {
	PlayerDMGFrame = "DmgAtNameplatesPlayerMover",
	TargetDMGFrame = "DmgAtNameplatesTargetMover",
}

function DAN:MigrateMovers()
	for _, profile in pairs(E.data.profiles) do
		local movers = profile.movers
		if movers then
			for old, new in pairs(MOVER_RENAMES) do
				if movers[old] and not movers[new] then movers[new] = movers[old] end
				movers[old] = nil
			end
		end
	end
end

function DAN:Initialize()
	self:MigrateMovers()
	self:InitializePlateIndex()
	EP:RegisterPlugin(DAN.AddOnName, self.DmgAtNameplatesOptions)
	self.db = E.db.DmgAtNameplates
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local function InitializeCallback()
	DAN:Initialize()
end

E:RegisterModule(DAN:GetName(), InitializeCallback)
