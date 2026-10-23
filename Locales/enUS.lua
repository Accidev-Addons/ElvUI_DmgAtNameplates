local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI_DmgAtNameplates", "enUS", true, true)
if not L then return end

-------------- text desc
L["Reflected"] = "Reflected"
L["Resisted"] = "Resisted"

L["Absorb"] = "Absorb"
L["Block"] = "Block"
L["Deflect"] = "Deflect"
L["Dodge"] = "Dodge"
L["Evade"] = "Evade"
L["Immune"] = "Immune"
L["Miss"] = "Miss"
L["Parry"] = "Parry"
L["OverhealFormat"] = "Overhealed: %s"
L["PetMissFormat"] = "Pet %s"
L["InterruptFormat"] = "Interrupted {%s}"

------------- options desc
L["PluginName"] = "Floating Combat Text"
L["PlayerDMGFrame"] = "Damage to player"
L["TargetDMGFrame"] = "Damage to target"
L["common"] = "General"
L["commondesc"] = "General settings"
L["onorof"] = "Enable"
L["onorofdesc"] = "Turns the addon on or off"
L["font"] = "Font"
L["fontSize"] = "Font size"
L["fontColor"] = "Text color"
L["Font Outline"] = "Font Outline"
L["NONE"] = "None"
L["Duration of all animations"] = "Duration of all animations"
L["animation"] = "Animation"
L["sicon"] = "Show icon"
L["offtarget"] = "Separate size for non-target units"
L["otfSize"] = "Size"
L["fontAlpha"] = "Opacity"
L["showFromAnotherPlayer"] = "Show source name for non-player text"

L["textformat"] = "Text format"
L["kkk"] = "1.2k  <-- shorten to thousands"
L["csep"] = "1,200  <-- with separators"
L["none"] = "1200  <-- plain number"

------------- small hits
L["SmallHits"] = "Small hits"
L["SmallHitsdesc"] = "Scale down small hits such as DoT ticks"
L["SmallHitsScale"] = "Small hits scale"
L["SmallHitsHide"] = "Hide small hits"
L["SmallHitsHidedesc"] = "Do not show small hits"
-------------------- animations Dmg
L["AnimationDmg"] = "Damage animations"
L["autoAttackPlusCritAnimation"] = "Auto attack + crit"
L["autoAttack"] = "Auto attack"
L["crit"] = "Crit"
L["commonDMGAnimation"] = "Normal damage"
------------------- animating heal
L["noHealCrit"] = "Normal heal"
L["AnimationHeal"] = "Heal animations"
L["healColor"] = "Heal text color"
L["showOverHeal"] = "Show overheal"
L["shwrhlldesc"] = "Show heals that were fully overhealed"

L["Vertical Up"] = "Vertical up"
L["Vertical Down"] = "Vertical down"
L["Fountain"] = "Fountain"
L["Rainfall"] = "Rainfall"
L["Disabled"] = "Disabled"
----------------dmg
L["damageText"] = "Damage"
----------------heal
L["healText"] = "Healing"
----------------player to target dmg
L["playerToTargetDamageText"] = "Damage FROM player"
L["pttdtdesc"] = "Damage FROM player"
----------------player to target heal
L["playerToTargetHealText"] = "Healing FROM player"
L["ptthtdesc"] = "Healing FROM player"
----------------target to player dmg
L["targetToPlayerDamageText"] = "Damage TO player"
L["ttpdtdesc"] = "Damage TO player"
L["showDmgToFriend"] = "Show damage to friendly units"
L["showDmgToEnemy"] = "Show damage to hostile units"
----------------target to player heal
L["targetToPlayerHealText"] = "Healing TO player"
L["ttphtdesc"] = "Healing TO player"
-----------------pet text
L["petToTargetDamageText"] = "Damage FROM pet"
L["petttdtdesc"] = "Damage FROM pet"
L["petToTargetHealText"] = "Healing FROM pet"
L["pettthtdesc"] = "Healing FROM pet"
L["DispelTab"] = "Dispels"
L["MissTab"] = "Misses"
L["InterruptTab"] = "Interrupts"
