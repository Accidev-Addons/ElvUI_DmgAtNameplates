local E, L, V, P, G = unpack(ElvUI)

local function ReturnFontTable()
    return {
        font = "PT Sans Narrow",
        fontSize = 20,
        fontAlpha = 1,
        fontOutline = "OUTLINE",
        fontColor = "ffff00",
        animation = "verticalUp",
    }
end


P.DmgAtNameplates = {
    enable = true,
    showIcon = true,
    duration = 1,
    font = "PT Sans Narrow",
    fontSize = 20,
    fontAlpha = 1,
    fontOutline = "OUTLINE",
    showOffTargetText = true,
    showOffTargetTextSize = 20,
    showOffTargetTextAlpha = 1,
    smallHits = true,
    smallHitsScale = 1,
    smallHitsHide = false,
    textFormat = "none",
    playerToTargetDamageText = true,
    targetToPlayerDamageText = true,
    petToTargetDamageText = true,

    showDmgToFriend = true,
    showDmgToEnemy = true,

    autoAttackPlusCritAnimation = "verticalUp",
    autoAttack = "verticalUp",
    critAnimation = "verticalUp",
    commonDMGAnimation = "verticalUp",
    playerToTargetHealText = true,
    targetToPlayerHealText = true,
    petToTargetHealText = true,
    showOverHeal = true,
    healCrit = "verticalUp",
    noHealCrit = "verticalUp",
    healColor = "0fff00",

    showFromAnotherPlayer = true,
    dispel = ReturnFontTable(),
    miss = ReturnFontTable(),
    interrupt = ReturnFontTable(),
}
