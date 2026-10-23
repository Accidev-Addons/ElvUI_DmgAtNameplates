local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI_DmgAtNameplates", "ruRU")
if not L then return end

-------------- text desc
L["Reflected"] = "Отражено"
L["Resisted"] = "Резист"

L["Absorb"] = "Поглощено"
L["Block"] = "Блок"
L["Deflect"] = "Отражение"
L["Dodge"] = "Уворот"
L["Evade"] = "Избегание"
L["Immune"] = "Иммунитет"
L["Miss"] = "Промах"
L["Parry"] = "Парирование"
L["OverhealFormat"] = "Перелечено: %s"
L["PetMissFormat"] = "Питомец %s"
L["InterruptFormat"] = "Прервано {%s}"

------------- options desc
L["PluginName"] = "Всплывающий урон"
L["PlayerDMGFrame"] = "Урон по персонажу"
L["TargetDMGFrame"] = "Урон по цели"
L["common"] = "Общие"
L["commondesc"] = "Общие настройки"
L["onorof"] = "Включить?"
L["onorofdesc"] = "Включает или выключает аддон"
L["font"] = "Шрифт"
L["fontSize"] = "Размер шрифта"
L["fontColor"] = "Цвет текста"
L["Font Outline"] = "Обводка"
L["NONE"] = "Нет"
L["Duration of all animations"] = "Длительность всех анимаций"
L["animation"] = "Анимация"
L["sicon"] = "Показывать иконку"
L["offtarget"] = "Разный размер для офф таргетов"
L["otfSize"] = "Размер"
L["fontAlpha"] = "Прозрачность"
L["showFromAnotherPlayer"] = "Показывать текст не игрока"

L["textformat"] = "Формат текста"
L["kkk"] = "1,2k  <-- сокращать на тысячи"
L["csep"] = "1,200  <-- с запятой"
L["none"] = "1200  <-- просто текст"

------------- small hits
L["SmallHits"] = "Промежуточный урон"
L["SmallHitsdesc"] = "Показывает промежуточный урон дот"
L["SmallHitsScale"] = "Скалирование промежуточного урона"
L["SmallHitsHide"] = "Прятать промежуточный урон"
L["SmallHitsHidedesc"] = "Не показывать промежуточный урон"
-------------------- animations Dmg
L["AnimationDmg"] = "Анимации урона"
L["autoAttackPlusCritAnimation"] = "АА + крит"
L["autoAttack"] = "АА"
L["crit"] = "Крит"
L["commonDMGAnimation"] = "Обычный урон"
------------------- animating heal
L["noHealCrit"] = "Обычное исцеление"
L["AnimationHeal"] = "Анимация исцеления"
L["healColor"] = "Цвет текста исцеления"
L["showOverHeal"] ="Показывать оверхил"
L["shwrhlldesc"] ="Показывать оверхил?"

L["Vertical Up"] = "Поднятие вверх"
L["Vertical Down"] = "Опускается вниз"
L["Fountain"] = "Фонтан"
L["Rainfall"] = "Капельки дождя"
L["Disabled"] = "Отключено"
----------------dmg
L["damageText"] = "Урон персонажа"
----------------heal
L["healText"] = "Исцеление персонажа"
----------------player to target dmg
L["playerToTargetDamageText"] = "Урон ОТ персонажа"
L["pttdtdesc"] = "Урон ОТ персонажа"
----------------player to target heal
L["playerToTargetHealText"] = "Исцеление ОТ персонажа"
L["ptthtdesc"] = "Исцеление ОТ персонажа"
----------------target to player dmg
L["targetToPlayerDamageText"] = "Урон В персонажа"
L["ttpdtdesc"] = "Урон В персонажа"
L["showDmgToFriend"] = "Показывать урон в Дружественные юниты"
L["showDmgToEnemy"] = "Показывать урон во Враждебные юниты"
----------------target to player heal
L["targetToPlayerHealText"] = "Исцеление В персонажа"
L["ttphtdesc"] = "Исцеление В персонажа"
-----------------pet text
L["petToTargetDamageText"] = "Урон ОТ пета"
L["petttdtdesc"] = "Урон ОТ пета"
L["petToTargetHealText"] = "Хил от пета"
L["pettthtdesc"] = "Хил от пета"
L["DispelTab"] = "Рассеивание"
L["MissTab"] = "Промахи"
L["InterruptTab"] = "Прерывания"
