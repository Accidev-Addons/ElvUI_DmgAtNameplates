
local E = unpack(ElvUI)
local L = E.Libs.ACL:GetLocale("ElvUI_DmgAtNameplates", E:GetLocale())
local DAN = E:GetModule("DmgAtNameplates")

local animationValues = {
	["verticalUp"] = L["Vertical Up"],
	["verticalDown"] = L["Vertical Down"],
	["fountain"] = L["Fountain"],
	["rainfall"] = L["Rainfall"],
	["disabled"] = L["Disabled"]
}

local fontOutlineValues = {
	["NONE"] = L["NONE"],
	["OUTLINE"] = "OUTLINE",
	["MONOCHROMEOUTLINE"] = "MONOCHROMEOUTLINE",
	["THICKOUTLINE"] = "THICKOUTLINE"
}

local function tableForAllEvents(key)
	return {
		font = {
			order = 1,
			type = "select",
			name = L["font"],
			dialogControl = "LSM30_Font",
			values = AceGUIWidgetLSMlists.font,
		},
		fontSize = {
			order = 2,
			type = "range",
			name = L["fontSize"],
			min = 5, max = 72, step = 1,
		},
		fontAlpha = {
			order = 3,
			type = "range",
			name = L["fontAlpha"],
			min = 0.1,
			max = 1,
			step = .01,
		},
		fontOutline = {
			order = 4,
			type = "select",
			name = L["Font Outline"],
			values = fontOutlineValues
		},
		fontColor = {
			order = 5,
			type = "color",
			name = L["fontColor"],
			hasAlpha = false,
			get = function() return DAN:hexToRGB(E.db.DmgAtNameplates[key].fontColor) end,
			set = function(_, r, g, b) E.db.DmgAtNameplates[key].fontColor = DAN:rgbToHex(r, g, b) end,
		},
		animation = {
			order = 6,
			type = "select",
			name = L["animation"],
			desc = L["animation"],
			values = animationValues,
		},
	}
end

local function eventGroup(order, name, key)
	return {
		order = order,
		type = "group",
		name = name,
		get = function(info) return E.db.DmgAtNameplates[key][info[#info]] end,
		set = function(info, value) E.db.DmgAtNameplates[key][info[#info]] = value end,
		args = tableForAllEvents(key),
	}
end

local function get(info) return E.db.DmgAtNameplates[info[#info]] end
local function set(info, value) E.db.DmgAtNameplates[info[#info]] = value end

function DAN:DmgAtNameplatesOptions()
	E.Options.args.DmgAtNameplates = {
		order = 55,
		type = "group",
		childGroups = "tab",
		name = string.format("|cff00FF00%s|r", L["PluginName"]),
		args = {
			common = {
				order = 1,
				type = "group",
				name = L["common"],
				get = get,
				set = set,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["commondesc"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["onorof"],
						desc = L["onorofdesc"],
						set = function(info, value)
							E.db.DmgAtNameplates.enable = value
							if not value then DAN:ClearTexts() end
						end
					},
					showIcon = {
						order = 3,
						type = "toggle",
						name = L["sicon"],
						desc = L["sicon"],
					},
					showFromAnotherPlayer = {
						order = 4,
						type = "toggle",
						name = L["showFromAnotherPlayer"],
						desc = L["showFromAnotherPlayer"],
					},
					duration = {
						order = 5,
						type = "range",
						name = L["Duration of all animations"],
						min = 0.1, max = 10, step = 0.1,
					},
					spacer2 = {
						order = 6,
						type = "description",
						name = " "
					},
					font = {
						order = 7,
						type = "select",
						name = L["font"],
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
					},
					fontSize = {
						order = 8,
						type = "range",
						name = L["fontSize"],
						min = 5, max = 72, step = 1,
					},
					fontAlpha = {
						order = 9,
						type = "range",
						name = L["fontAlpha"],
						min = 0.1,
						max = 1,
						step = .01,
					},
					fontOutline = {
						order = 10,
						type = "select",
						name = L["Font Outline"],
						values = fontOutlineValues
					},
					header2 = {
						order = 11,
						type = "header",
						name = L["offtarget"]
					},
					showOffTargetText = {
						order = 12,
						type = "toggle",
						name = L["offtarget"],
						desc = "",
					},
					showOffTargetTextSize = {
						order = 13,
						type = "range",
						name = L["otfSize"],
						desc = "",
						min = 5,
						max = 72,
						step = 1,
						disabled = function() return not E.db.DmgAtNameplates.showOffTargetText end,
					},
					showOffTargetTextAlpha = {
						order = 14,
						type = "range",
						name = L["fontAlpha"],
						desc = "",
						min = 0.1,
						max = 1,
						step = .01,
						disabled = function() return not E.db.DmgAtNameplates.showOffTargetText end,
					},
					header3 = {
						order = 15,
						type = "header",
						name = L["SmallHits"]
					},
					smallHits = {
						type = "toggle",
						order = 16,
						name = L["SmallHits"],
						desc = L["SmallHitsdesc"],
						disabled = function()
							return not E.db.DmgAtNameplates.enable or E.db.DmgAtNameplates.smallHitsHide
						end,
					},
					smallHitsScale = {
						order = 17,
						type = "range",
						name = L["SmallHitsScale"],
						desc = "",
						disabled = function()
							return not E.db.DmgAtNameplates.enable or not E.db.DmgAtNameplates.smallHits or E.db.DmgAtNameplates.smallHitsHide
						end,
						min = 0.33,
						max = 1,
						step = .01,
						width = "double"
					},
					smallHitsHide = {
						order = 18,
						type = "toggle",
						name = L["SmallHitsHide"],
						desc = L["SmallHitsHidedesc"],
					},
					textFormat = {
						order = 19,
						type = "select",
						name = L["textformat"],
						values = {
							["none"] = L["none"],
							["csep"] = L["csep"],
							["kkk"] = L["kkk"],
						},
					},
				},
			},
			playerToTargetDamageTextTab = {
				order = 2,
				type = "group",
				name = L["damageText"],
				get = get,
				set = set,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["playerToTargetDamageText"]
					},
					playerToTargetDamageText = {
						order = 2,
						type = "toggle",
						name = L["playerToTargetDamageText"],
						desc = L["pttdtdesc"],
					},
					petToTargetDamageText = {
						order = 3,
						type = "toggle",
						name = L["petToTargetDamageText"],
						desc = L["petttdtdesc"],
					},
					targetToPlayerDamageText = {
						order = 4,
						type = "toggle",
						name = L["targetToPlayerDamageText"],
						desc = L["ttpdtdesc"],
					},
					showDmgToFriend = {
						order = 5,
						type = "toggle",
						name = L["showDmgToFriend"],
						desc = L["showDmgToFriend"],
					},
					showDmgToEnemy = {
						order = 6,
						type = "toggle",
						name = L["showDmgToEnemy"],
						desc = L["showDmgToEnemy"],
					},
					header2 = {
						order = 7,
						type = "header",
						name = L["AnimationDmg"]
					},
					autoAttackPlusCritAnimation = {
						order = 8,
						type = "select",
						name = L["autoAttackPlusCritAnimation"],
						desc = L["autoAttackPlusCritAnimation"],
						values = animationValues,
					},
					autoAttack = {
						order = 9,
						type = "select",
						name = L["autoAttack"],
						desc = L["autoAttack"],
						values = animationValues,
					},
					critAnimation = {
						order = 10,
						type = "select",
						name = L["crit"],
						desc = L["crit"],
						values = animationValues,
					},
					commonDMGAnimation = {
						order = 11,
						type = "select",
						name = L["commonDMGAnimation"],
						desc = L["commonDMGAnimation"],
						values = animationValues,
					},
				},
			},
			playerToTargetHealTextTab = {
				order = 3,
				type = "group",
				name = L["healText"],
				get = get,
				set = set,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["playerToTargetHealText"]
					},
					playerToTargetHealText = {
						order = 2,
						type = "toggle",
						name = L["playerToTargetHealText"],
						desc = L["ptthtdesc"],
					},
					targetToPlayerHealText = {
						order = 3,
						type = "toggle",
						name = L["targetToPlayerHealText"],
						desc = L["ttphtdesc"],
					},
					petToTargetHealText = {
						order = 4,
						type = "toggle",
						name = L["petToTargetHealText"],
						desc = L["pettthtdesc"],
					},
					showOverHeal = {
						order = 5,
						type = "toggle",
						name = L["showOverHeal"],
						desc = L["shwrhlldesc"],
					},
					header2 = {
						order = 6,
						type = "header",
						name = L["AnimationHeal"]
					},
					healCrit = {
						order = 7,
						type = "select",
						name = L["crit"],
						desc = L["crit"],
						values = animationValues,
					},
					noHealCrit = {
						order = 8,
						type = "select",
						name = L["noHealCrit"],
						desc = L["noHealCrit"],
						values = animationValues,
					},
					healColor = {
						order = 9,
						type = "color",
						name = L["healColor"],
						desc = "",
						hasAlpha = false,
						set = function(_, r, g, b)
							E.db.DmgAtNameplates.healColor = DAN:rgbToHex(r, g, b)
						end,
						get = function()
							return DAN:hexToRGB(E.db.DmgAtNameplates.healColor)
						end,
					},
				},
			},
			DispelTab = eventGroup(4, L["DispelTab"], "dispel"),
			MissTab = eventGroup(5, L["MissTab"], "miss"),
			InterruptTab = eventGroup(6, L["InterruptTab"], "interrupt"),
		}
	}
end
