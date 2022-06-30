-- GryllsUnitFrames
-- Extension to the default unit frames
-- based on CT_UnitFrames (http://addons.us.to/addon/ct)
-- MobHealth3 support

_G = getfenv()
local GryllsUnitFrames = CreateFrame("Frame", nil, UIParent)
GryllsUnitFrames.MAX_TARGET_BUFFS = 16
GryllsUnitFrames.MAX_TARGET_DEBUFFS = 16

GryllsUnitFrames_Settings = {
    both = false,
    classportraits = false,
    colorbackground = true,
    colorhealth = true,
    colorhealthbar = true,
    colorname = true,
    colorpower = true,
    combatindicator = false,
    combattext = false,
    namefont = "frizqt__",
    namesize = 12,
    namesizeparty = 10,
    party = true,
    percent = false,
    resource = false,
    short = false,
    tick = true,
    tot = true,
    unit = true,
    value = true,
    valuefont = "frizqt__",
    valuesize = 12,
    valuesizeparty = 10,
}

local function GryllsUnitFrames_resetVariables()
    GryllsUnitFrames_Settings.both = false
    GryllsUnitFrames_Settings.classportraits = false
    GryllsUnitFrames_Settings.colorbackground = true
    GryllsUnitFrames_Settings.colorhealth = true
    GryllsUnitFrames_Settings.colorhealthbar = true
    GryllsUnitFrames_Settings.colorname = true
    GryllsUnitFrames_Settings.colorpower = true
    GryllsUnitFrames_Settings.combatindicator = false
    GryllsUnitFrames_Settings.combattext = false
    GryllsUnitFrames_Settings.namefont = "frizqt__"
    GryllsUnitFrames_Settings.namesize = 12
    GryllsUnitFrames_Settings.namesizeparty = 10
    GryllsUnitFrames_Settings.party = true
    GryllsUnitFrames_Settings.percent = false
    GryllsUnitFrames_Settings.resource = false
    GryllsUnitFrames_Settings.short = false
    GryllsUnitFrames_Settings.tick = true
    GryllsUnitFrames_Settings.tot = true
    GryllsUnitFrames_Settings.unit = true
    GryllsUnitFrames_Settings.value = true
    GryllsUnitFrames_Settings.valuefont = "frizqt__"
    GryllsUnitFrames_Settings.valuesize = 12
    GryllsUnitFrames_Settings.valuesizeparty = 10
end

local function GryllsUnitFrames_tick_update()
    -- code based on EnergyWatch v2
    local energy = UnitMana("player")
    local time = GetTime()
    local sparkPosition = 1
    local powerType = UnitPowerType("player")

    -- if powerType == 0 then -- mana
    --     if time < Grylls_Tick.lastMana + 5 then
    --         Grylls_Tick.tickRate = 5 -- tick once every 5 seconds
    --         -- DEFAULT_CHAT_FRAME:AddMessage("MANA - 5")
    --     else
    --         Grylls_Tick.tickRate = 2 -- tick once every 2 seconds
    --         -- DEFAULT_CHAT_FRAME:AddMessage("MANA - 2")
    --     end
    -- elseif powerType == 3 then -- energy
    --     Grylls_Tick.tickRate = 2 -- tick once every 2 seconds
    -- end

    Grylls_Tick.tickRate = 2 -- tick once every 2 seconds
    if ( energy > Grylls_Tick.energy or time >= Grylls_Tick.timerEnd ) then
        Grylls_Tick.energy = energy
        Grylls_Tick.timerStart = time
        Grylls_Tick.timerEnd = time + Grylls_Tick.tickRate
    else
        if( energy ~= Grylls_Tick.energy ) then
            energy = Grylls_Tick.energy
        end
        sparkPosition = ((time - Grylls_Tick.timerStart) / (Grylls_Tick.timerEnd - Grylls_Tick.timerStart)) * Grylls_Tick.sparkSize
    end

    Grylls_Tick.StatusBar:SetMinMaxValues(Grylls_Tick.timerStart, Grylls_Tick.timerEnd)
    Grylls_Tick.StatusBar:SetValue(time)

    if ( sparkPosition < 1 ) then
        sparkPosition = 1
    end

    Grylls_TickSpark.Spark:SetPoint("CENTER", Grylls_Tick.StatusBar, "LEFT", sparkPosition, 0)
end

local function GryllsUnitFrames_tick()
    if GryllsUnitFrames_Settings.tick then
        if not Grylls_Tick then
            Grylls_Tick = CreateFrame("Frame", "Grylls_Tick", PlayerFrame)
            Grylls_TickSpark = CreateFrame("Frame", "Grylls_TickSpark", PlayerFrame)

            local function powerColor()
                local r,g,b
                local powerType = UnitPowerType("player") -- 0 = mana, 1 = rage, 3 = energy
                -- color power text based on power type
                if powerType == 0 then -- mana
                    r,g,b = 0/255, 204/255, 255/255 -- Blizzard Blue
                elseif powerType == 1 then -- rage
                    r,g,b = 255/255, 107/255, 107/255 -- light Red
                elseif powerType == 2 then -- focus
                    r,g,b = 1, 0.5, 0.25
                elseif powerType == 3 then -- energy
                    r,g,b = 230/255, 204/255, 128/255 -- artifact gold
                end
                return r,g,b
            end

            Grylls_Tick:SetFrameStrata("BACKGROUND")
            Grylls_Tick:SetFrameLevel(PlayerFrameManaBar:GetFrameLevel()-1)

            Grylls_Tick.StatusBar = CreateFrame("StatusBar", "Grylls_TickStatusBar", PlayerFrame)
            Grylls_Tick.StatusBar:SetFrameLevel(PlayerFrameManaBar:GetFrameLevel()-1)
            Grylls_Tick.StatusBar:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            Grylls_Tick.StatusBar:SetAllPoints(PlayerFrameManaBar)
            Grylls_Tick.StatusBar:SetStatusBarColor(powerColor())
            Grylls_Tick.StatusBar:SetAlpha(0.5) -- set to 0 to hide

            Grylls_TickSpark.Spark = Grylls_TickSpark:CreateTexture(nil, "OVERLAY")
            Grylls_TickSpark.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            Grylls_TickSpark.Spark:SetHeight(32)
            Grylls_TickSpark.Spark:SetWidth(32)
            Grylls_TickSpark.Spark:SetBlendMode("ADD")
            Grylls_TickSpark.Spark:SetVertexColor(powerColor())

            Grylls_Tick.timerStart = 0
            Grylls_Tick.timerEnd = 0
            Grylls_Tick.sparkSize = 118
            Grylls_Tick.class = UnitClass("player")
            Grylls_Tick.energy = UnitMana("player")
            Grylls_Tick.lastMana = 0

            local powerType = UnitPowerType("player")
            if powerType == 0 then -- mana
                Grylls_Tick.enabled = true
            elseif powerType == 3 then -- energy
                Grylls_Tick.enabled = true
            else
                Grylls_Tick.enabled = false
            end

            if Grylls_Tick.enabled == true then
                Grylls_Tick:Show()
                Grylls_TickSpark:Show()
                Grylls_Tick:SetScript("OnUpdate", GryllsUnitFrames_tick_update)
            else
                Grylls_Tick:Hide()
                Grylls_Tick.StatusBar:Hide()
                Grylls_TickSpark:Hide()
                Grylls_Tick:SetScript("OnUpdate", nil)
            end
        end
    end
end

local function GryllsUnitFrames_combatText()
    if GryllsUnitFrames_Settings.combattext then
        PlayerFrame:RegisterEvent("UNIT_COMBAT")
        PetFrame:RegisterEvent("UNIT_COMBAT")
    else
        PlayerFrame:UnregisterEvent("UNIT_COMBAT")
        PetFrame:UnregisterEvent("UNIT_COMBAT")
    end
end

local function GryllsUnitFrames_setPartyVisibility()
    if GryllsUnitFrames_Settings.party then
        for i=1, 4 do
            _G["Grylls_PartyMemberFrame"..i]:Show()
        end
    else
        for i=1, 4 do
            _G["Grylls_PartyMemberFrame"..i]:Hide()
        end
    end
end

local function GryllsUnitFrames_setUnitVisibility()
    if GryllsUnitFrames_Settings.unit then
        Grylls_PlayerFrame:Show()
        Grylls_PetFrame:Show()
        Grylls_TargetFrame:Show()
    else
        Grylls_PlayerFrame:Hide()
        Grylls_PetFrame:Hide()
        Grylls_TargetFrame:Hide()
    end
end

local function GryllsUnitFrames_hideStatusBarText()
    local hideFrame = CreateFrame("Frame")
    PlayerFrameHealthBarText:SetParent(hideFrame)
    PlayerFrameManaBarText:SetParent(hideFrame)
    PetFrameHealthBarText:SetParent(hideFrame)
    PetFrameManaBarText:SetParent(hideFrame)
    TargetDeadText:SetParent(hideFrame)
    hideFrame:Hide()
end

local function GryllsUnitFrames_formatNum(num)
    local function GryllsUnitFrames_shortNum(num)
        -- short number eg 10100 = 10.1k
        if num <= 999 then
            return num
        elseif num >= 1000000 then
            return format("%.1f mil", floor(num/1000000))
        elseif num >= 1000 then
            return format("%.1fk", floor(num/1000))
        end
    end

    local function GryllsUnitFrames_defaultNum(num)
     -- default format with commas eg 10000 = 10,000
        -- http://lua-users.org/wiki/FormattingNumbers
        local formatted = num
            while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
        return formatted
    end

    if GryllsUnitFrames_Settings.short then
        return GryllsUnitFrames_shortNum(num)
    else
        return GryllsUnitFrames_defaultNum(num)
    end
end

local function GryllsUnitFrames_createColorBackground()
    if GryllsUnitFrames_Settings.colorbackground then
        -- credit to Shagu (https://shagu.org/ShaguTweaks/) for code below
        -- add name background to player frame
        PlayerFrameNameBackground = PlayerFrame:CreateTexture(nil, "BACKGROUND")
        PlayerFrameNameBackground:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
        PlayerFrameNameBackground:SetWidth(TargetFrameNameBackground:GetWidth())
        PlayerFrameNameBackground:SetHeight(TargetFrameNameBackground:GetHeight())
        PlayerFrameNameBackground:SetPoint("TOPLEFT", 106, -22)
        -- make sure to keep name background above frame shadow
        PlayerFrameNameBackground:SetDrawLayer("BORDER")
        TargetFrameNameBackground:SetDrawLayer("BORDER")
    end
end

local function GryllsUnitFrames_createFrames()

    local function setFrame(frame, healthbar, manabar)
        frame:SetFrameStrata("LOW")
        frame:SetFrameLevel(4)

        frame.health = frame:CreateFontString(nil, "LOW")
        frame.health:ClearAllPoints()

        frame.power = frame:CreateFontString(nil, "LOW")
        frame.power:ClearAllPoints()

        if (frame == Grylls_PlayerFrame) or (frame == Grylls_TargetFrame) then
            local y = 0.5
            frame.health:SetPoint("CENTER", healthbar, "CENTER", 0, y)
            frame.power:SetPoint("CENTER", manabar, "CENTER", 0, y)
        elseif (frame == Grylls_PetFrame) or (frame == Grylls_TargetofTargetFrame) then
            frame.health:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
            frame.power:SetPoint("CENTER", manabar, "CENTER", 0, -2)
        else
            local y = 0.5
            frame.health:SetPoint("CENTER", healthbar, "CENTER", 0, y)
            frame.power:SetPoint("CENTER", manabar, "CENTER", 0, y)
        end
    end

    Grylls_PlayerFrame = CreateFrame("Frame", "Grylls_PlayerFrame", PlayerFrame)
    setFrame(Grylls_PlayerFrame, PlayerFrameHealthBar, PlayerFrameManaBar)

    Grylls_PetFrame = CreateFrame("Frame", "Grylls_PetFrame", PetFrame)
    setFrame(Grylls_PetFrame, PetFrameHealthBar, PetFrameManaBar)

    Grylls_TargetFrame = CreateFrame("Frame", "Grylls_TargetFrame", TargetFrame)
    setFrame(Grylls_TargetFrame, TargetFrameHealthBar, TargetFrameManaBar)

    Grylls_TargetofTargetFrame = CreateFrame("Frame", "Grylls_TargetofTargetFrame", TargetofTargetFrame)
    setFrame(Grylls_TargetofTargetFrame, TargetofTargetHealthBar, TargetofTargetManaBar)

    Grylls_PartyMemberFrame1 = CreateFrame("Frame", "Grylls_PartyMemberFrame1", PartyMemberFrame1)
    setFrame(Grylls_PartyMemberFrame1, PartyMemberFrame1HealthBar, PartyMemberFrame1ManaBar)

    Grylls_PartyMemberFrame2 = CreateFrame("Frame", "Grylls_PartyMemberFrame2", PartyMemberFrame2)
    setFrame(Grylls_PartyMemberFrame2, PartyMemberFrame2HealthBar, PartyMemberFrame2ManaBar)

    Grylls_PartyMemberFrame3 = CreateFrame("Frame", "Grylls_PartyMemberFrame3", PartyMemberFrame3)
    setFrame(Grylls_PartyMemberFrame3, PartyMemberFrame3HealthBar, PartyMemberFrame3ManaBar)

    Grylls_PartyMemberFrame4 = CreateFrame("Frame", "Grylls_PartyMemberFrame4", PartyMemberFrame4)
    setFrame(Grylls_PartyMemberFrame4, PartyMemberFrame4HealthBar, PartyMemberFrame4ManaBar)
end

local function GryllsUnitFrames_createTargetCombatIndicator()
    if GryllsUnitFrames_Settings.combatindicator then
        local f = CreateFrame("Frame", "Grylls_TargetCombatIndicator", TargetFrame)

        f.indicator = f:CreateTexture(nil, "BORDER")
        --f.indicator:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
        f.indicator:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        f.indicator:SetTexCoord(0.50, 1.0, 0.0, 0.49)
        f.indicator:SetWidth(32)
        f.indicator:SetHeight(32)
        --f.indicator:SetPoint("Right", TargetFrame, 0, 5)
        f.indicator:SetPoint("CENTER", TargetFrame, 65, -13)
        f.indicator:Hide()

        f.glow = f:CreateTexture(nil, "BORDER")
        f.glow:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        f.glow:SetBlendMode("ADD")
        f.glow:SetTexCoord(0.50, 1.0, 0.50, 1.0)
        f.glow:SetVertexColor(1,0,0)
        f.glow:SetPoint("TOPLEFT", f.indicator, -1, 1)
        f.glow:SetPoint("BOTTOMRIGHT", f.indicator, 1, -1)
        f.glow:SetAlpha(0) -- for fade
        f.glow:Hide()

        --[[ f.statusTexture = f:CreateTexture(nil, "ARTWORK")
        f.statusTexture:SetTexture("Interface\\CharacterFrame\\UI-Player-Status")
        f.statusTexture:SetBlendMode("ADD")
        --f.statusTexture:SetTexCoord(0, 0.74609375, 0, 0.53125)
        f.statusTexture:SetTexCoord(1, 0, 0, 1) -- flip horizontally (https://www.wowinterface.com/forums/showthread.php?t=48367)
        f.statusTexture:SetVertexColor(1,0,0)
        f.statusTexture:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 0, 0)
        f.statusTexture:SetPoint("BOTTOMRIGHT", TargetFrame, "BOTTOMRIGHT", 0, 0)
        f.statusTexture:Hide() ]]
    end
end

local function GryllsUnitFrames_updateIndicator(unit, frame)
    if GryllsUnitFrames_Settings.combatindicator then
        if frame then
            if UnitExists(unit) then
                frame:SetScript("OnUpdate", function()
                    local inCombat = UnitAffectingCombat(unit)
                    if inCombat then
                        TargetLevelText:Hide()
                        frame.indicator:Show()
                        frame.glow:Show() -- comment out for blink
                        --frame.statusTexture:Show()

                        -- blinking glow
                        -- local time = GetTime()
                        -- if ( time >= frame.timerEnd ) then
                        --     frame.timerEnd = time + frame.tickRate

                        --     if frame.glow:IsVisible() then
                        --         frame.glow:Hide()
                        --     else
                        --         frame.glow:Show()
                        --     end
                        -- end

                        -- pulsing glow if we are attacking the mob otherwise static glow
                        if PlayerStatusGlow:IsVisible() then
                            local alpha = PlayerStatusGlow:GetAlpha()
                            frame.glow:SetAlpha(alpha)
                        else
                            frame.glow:SetAlpha(1)
                        end
                    else
                        TargetLevelText:Show()
                        frame.indicator:Hide()
                        frame.glow:Hide()
                        --frame.statusTexture:Hide()
                    end
                end)
            else
                frame:SetScript("OnUpdate", nil)
            end
        end
    end
end

local function GryllsUnitFrames_setup()
    TargetFrameNameBackground:SetAlpha(.5)
    TargetofTargetDeadText:SetText("")
end

local function GryllsUnitFrames_localizedClass(unit)
    local class = UnitClass(unit) -- get Localized name
    if (GetLocale() == "deDE") then
        if class == "Krieger" then
            return "WARRIOR"
        elseif class == "Paladin" then
            return "PALADIN"
        elseif class == "Jäger" then
            return "HUNTER"
        elseif class == "Schurke" then
            return "ROGUE"
        elseif class == "Priester" then
            return "PRIEST"
        elseif class == "Schamane" then
            return "SHAMAN"
        elseif class == "Magier" then
            return "MAGE"
        elseif class == "Hexenmeister" then
            return "WARLOCK"
        elseif class == "Druide" then
            return "DRUID"
        end
    elseif (GetLocale() == "frFR") then
        if class == "Guerrier" then
            return "WARRIOR"
        elseif class == "Paladin" then
            return "PALADIN"
        elseif class == "Chasseur" then
            return "HUNTER"
        elseif class == "Voleur" then
            return "ROGUE"
        elseif class == "Pretre" then
            return "PRIEST"
        elseif class == "Chaman" then
            return "SHAMAN"
        elseif class == "Mage" then
            return "Mage"
        elseif class == "Demoniste" then
            return "WARLOCK"
        elseif class == "Druide" then
            return "DRUID"
        end
    elseif (GetLocale() == "ruRU") then
        if class == "Воин" then
            return "WARRIOR"
        elseif class == "Паладин" then
            return "PALADIN"
        elseif class == "Охотник" then
            return "HUNTER"
        elseif class == "Разбойник" then
            return "ROGUE"
        elseif class == "Жрец" then
            return "PRIEST"
        elseif class == "Шаман" then
            return "SHAMAN"
        elseif class == "Маг" then
            return "MAGE"
        elseif class == "Чернокнижник" then
            return "WARLOCK"
        elseif class == "Друид" then
            return "DRUID"
        end
    elseif (GetLocale() == "koKR") then
        if class == "전사" then
            return "WARRIOR"
        elseif class == "성기사" then
            return "PALADIN"
        elseif class == "사냥꾼" then
            return "HUNTER"
        elseif class == "도적" then
            return "ROGUE"
        elseif class == "사제" then
            return "PRIEST"
        elseif class == "주술사" then
            return "SHAMAN"
        elseif class == "마법사" then
            return "MAGE"
        elseif class == "흑마법사" then
            return "WARLOCK"
        elseif class == "드루이드" then
            return "DRUID"
        end
    elseif (GetLocale() == "zhCN") then
        if class == "战士" then
            return "WARRIOR"
        elseif class == "圣骑士" then
            return "PALADIN"
        elseif class == "猎人" then
            return "HUNTER"
        elseif class == "盗贼" then
            return "ROGUE"
        elseif class == "牧师" then
            return "PRIEST"
        elseif class == "萨满" then
            return "SHAMAN"
        elseif class == "法师" then
            return "MAGE"
        elseif class == "术士" then
            return "WARLOCK"
        elseif class == "德鲁伊" then
            return "DRUID"
        end
    elseif (GetLocale() == "enUS") or (GetLocale() == "enGB") then
        if class == "Warrior" then
            return "WARRIOR"
        elseif class == "Paladin" then
            return "PALADIN"
        elseif class == "Hunter" then
            return "HUNTER"
        elseif class == "Rogue" then
            return "ROGUE"
        elseif class == "Priest" then
            return "PRIEST"
        elseif class == "Shaman" then
            return "SHAMAN"
        elseif class == "Mage" then
            return "MAGE"
        elseif class == "Warlock" then
            return "WARLOCK"
        elseif class == "Druid" then
            return "DRUID"
        end
    end
end

local function GryllsUnitFrames_colorName(unit)
    local frame
    if unit == "player" then
        frame = PlayerFrame
    elseif unit == "pet" then
        frame = PetFrame
    elseif unit == "target" then
        frame = TargetFrame
    elseif unit == "targettarget" then
        frame = TargetofTargetFrame
    elseif unit == "party1" then
        frame = PartyMemberFrame1
    elseif unit == "party2" then
        frame = PartyMemberFrame2
    elseif unit == "party3" then
        frame = PartyMemberFrame3
    elseif unit == "party4" then
        frame = PartyMemberFrame4
    else
        -- unit not found
        frame = null
    end

    if frame ~= null then
        if UnitExists(unit) then
            local r,g,b
            local thename -- implicit thename = nil
            -- set thename to the frame name
            if (unit == "targettarget") then
                thename = TargetofTargetName
            elseif (unit == "pet") then
                thename = PetName
            else
                thename = frame.name
            end

            local function color(unit)
                local r,g,b
                if UnitIsPlayer(unit) then
                    -- color by class
                    local colorClass = GryllsUnitFrames_localizedClass(unit)
                    if colorClass == "SHAMAN" then
                        r, g, b = 0/255, 112/255, 221/255 -- blue shamans
                    else
                        local color = RAID_CLASS_COLORS[colorClass]
                        r,g,b = color.r, color.g, color.b
                    end
                else
                    -- not a player
                    local creatureType = UnitCreatureType(unit)
                    local friend = UnitIsFriend("player", unit)
                    if friend then
                        if creatureType == "Demon" then -- friendly Warlock pet
                            r,g,b = 148/255, 130/255, 201/255
                        elseif creatureType == "Beast" then -- friendly Hunter pet
                            r,g,b = 171/255, 212/255, 115/255
                        else
                            r,g,b = 255/255, 210/255, 0/255  -- default color
                        end
                    else
                        -- enemy
                        -- color name by reaction
                        r,g,b = GameTooltip_UnitColor(unit)
                    end
                end
                return r,g,b
            end

            if GryllsUnitFrames_Settings.colorbackground then
                if unit == "player" then
                    if PlayerFrameNameBackground then
                        r,g,b = color(unit)
                        PlayerFrameNameBackground:SetVertexColor(r,g,b,1)
                    end
                elseif unit == "target" then
                    r,g,b = color(unit)
                    TargetFrameNameBackground:SetVertexColor(r,g,b,1)
                end
            end

            if GryllsUnitFrames_Settings.colorname then
                r,g,b = color(unit)
            else
                r,g,b = 255/255, 210/255, 0/255 -- default color
            end

            thename:SetTextColor(r,g,b)
        end
    end
end

local function GryllsUnitFrames_setValueFont(frame, size)
    if not size then
        size = GryllsUnitFrames_Settings.valuesize
    end

    font, outline = "Fonts\\"..GryllsUnitFrames_Settings.valuefont..".TTF", "OUTLINE"

    frame.health:SetFont(font, size, outline)
    frame.power:SetFont(font, size, outline)
end

local function GryllsUnitFrames_updateValueFont()
    GryllsUnitFrames_setValueFont(Grylls_PlayerFrame)
    GryllsUnitFrames_setValueFont(Grylls_PetFrame)
    GryllsUnitFrames_setValueFont(Grylls_TargetFrame)
    GryllsUnitFrames_setValueFont(Grylls_TargetofTargetFrame)
    if GryllsUnitFrames_Settings.party then
        for i=1, 4 do
            local size = GryllsUnitFrames_Settings.valuesizeparty
            local frame = _G["Grylls_PartyMemberFrame"..i]
            GryllsUnitFrames_setValueFont(frame, size)
        end
    end
end

local function GryllsUnitFrames_updateNameFont()
    local font, size, outline

    font, size, outline = "Fonts\\"..GryllsUnitFrames_Settings.namefont..".TTF", GryllsUnitFrames_Settings.namesize, "OUTLINE"

    PlayerFrame.name:SetFont(font, size, outline)
    TargetFrame.name:SetFont(font, size, outline)
    TargetofTargetName:SetFont(font, size, outline)
    PetName:SetFont(font, size, outline)
    -- Party
    size = GryllsUnitFrames_Settings.namesizeparty
    for i=1, 4 do
        local frame = _G["PartyMemberFrame"..i]
        frame.name:SetFont(font, size, outline)
    end
end

local function GryllsUnitFrames_updateHealth(unit)
    local frame
    if unit == "player" then
        frame = Grylls_PlayerFrame
    elseif unit == "pet" then
        frame = Grylls_PetFrame
    elseif unit == "target" then
        frame = Grylls_TargetFrame
    elseif unit == "targettarget" then
        frame = Grylls_TargetofTargetFrame
    elseif unit == "party1" then
        frame = Grylls_PartyMemberFrame1
    elseif unit == "party2" then
        frame = Grylls_PartyMemberFrame2
    elseif unit == "party3" then
        frame = Grylls_PartyMemberFrame3
    elseif unit == "party4" then
        frame = Grylls_PartyMemberFrame4
    else
        -- unit not found
        frame = null
    end

    if frame ~= null then
        if GryllsUnitFrames_Settings.resource == false then -- hide health when using resource mode
            if UnitExists(unit) then
                if UnitIsDead(unit) then
                    frame.health:SetTextColor(128/255, 128/255, 128/255) -- grey
                    frame.health:SetText("Dead")
                elseif UnitIsGhost(unit) then
                    frame.health:SetTextColor(1,1,1) -- white
                    frame.health:SetText("Ghost")
                else
                    local hp = UnitHealth(unit)
                    local hpmax = UnitHealthMax(unit)
                    local percent = hp / hpmax
                    local reaction = UnitReaction("player", unit); -- https://wowwiki-archive.fandom.com/wiki/API_UnitReaction

                    if GryllsUnitFrames_Settings.colorhealth then
                        -- color health text based on health
                        if percent <= 0.2 then
                            if reaction <= 4 then -- hostile or neutral
                                frame.health:SetTextColor(255/255, 128/255, 0/255) -- legendary orange
                            elseif reaction > 4 then -- friendly
                                frame.health:SetTextColor(0/255, 204/255, 255/255) -- Blizzard Blue
                            end
                        else
                            frame.health:SetTextColor(30/255, 255/255, 0/255) -- uncommon green
                        end
                    else
                        frame.health:SetTextColor(255/255, 255/255, 255/255) -- white
                    end

                    local percent = floor(percent*100)
                    -- format hp text
                    -- Limitations: we can only get friendly HP values if target is in our party and we can't get enemy HP values without mobhealth
                    if GryllsUnitFrames_Settings.value then
                        if (unit == "target") and MobHealth3 then
                            frame.health:SetText(GryllsUnitFrames_formatNum(MobHealth3:GetUnitHealth("target")))
                        else
                            frame.health:SetText(GryllsUnitFrames_formatNum(hp))
                        end
                    elseif GryllsUnitFrames_Settings.percent then
                            frame.health:SetText(percent)
                    elseif GryllsUnitFrames_Settings.both then
                        if unit == "target" then
                            if (unit == "target") and MobHealth3 then
                                frame.health:SetText(GryllsUnitFrames_formatNum(MobHealth3:GetUnitHealth("target")).." ("..percent..")")
                            else
                                frame.health:SetText(GryllsUnitFrames_formatNum(hp))
                            end
                        elseif unit == "party1" or "party2" or "party3" or "party4" then
                            frame.health:SetText(GryllsUnitFrames_formatNum(hp).." ("..percent..")")
                        end
                    end
                end
            end
        end
    end
end

local function GryllsUnitFrames_updateHealthBar(unit)
    if GryllsUnitFrames_Settings.colorhealthbar then
        local HealthBar
        -- color health bar based on health
        if unit == "player" then
            HealthBar = PlayerFrameHealthBar
        elseif unit == "pet" then
            HealthBar = PetFrameHealthBar
        elseif unit == "target" then
            HealthBar = TargetFrameHealthBar
        elseif unit == "targettarget" then
            HealthBar = TargetofTargetHealthBar
        elseif unit == "party1" then
            HealthBar = PartyMemberFrame1HealthBar
        elseif unit == "party2" then
            HealthBar = PartyMemberFrame2HealthBar
        elseif unit == "party3" then
            HealthBar = PartyMemberFrame3HealthBar
        elseif unit == "party4" then
            HealthBar = PartyMemberFrame4HealthBar
        elseif unit == "partypet1" then
            HealthBar = PartyMemberFrame1PetFrameHealthBar
        elseif unit == "partypet2" then
            HealthBar = PartyMemberFrame2PetFrameHealthBar
        elseif unit == "partypet3" then
            HealthBar = PartyMemberFrame3PetFrameHealthBar
        elseif unit == "partypet4" then
            HealthBar = PartyMemberFrame4PetFrameHealthBar
        else
            -- unit not found
            HealthBar = null
        end

        if HealthBar ~= null then
            if not (UnitIsDead(unit) or UnitIsGhost(unit)) then
                if unit == "pet" then
                    -- credit to KoOz (https://github.com/Ko0z/UnitFramesImproved_Vanilla) for code below
                    -- pet health bar happiness coloring
                    local _, class = UnitClass("player")
                    if class == 'HUNTER' then
                        local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
                        if (happiness == 3) then
                            HealthBar:SetStatusBarColor(0,1,0)
                        elseif (happiness == 2) then
                            HealthBar:SetStatusBarColor(1,1,0)
                        else
                            HealthBar:SetStatusBarColor(1,0,0)
                        end
                    end
                else
                    -- credit to Shagu (https://github.com/shagu/ShaguPlates) for code below
                    local function GetUnitType(red, green, blue)
                        if red > .9 and green < .2 and blue < .2 then
                        return "ENEMY_NPC"
                        elseif red > .9 and green > .9 and blue < .2 then
                        return "NEUTRAL_NPC"
                        elseif red < .2 and green < .2 and blue > 0.9 then
                        return "FRIENDLY_PLAYER"
                        elseif red < .2 and green > .9 and blue < .2 then
                        return "FRIENDLY_NPC"
                        end
                    end

                    local hp = UnitHealth(unit)
                    local hpmax = UnitHealthMax(unit)
                    local percent = hp / hpmax
                    local player = UnitIsPlayer(unit)

                    local red, green, blue = HealthBar:GetStatusBarColor()
                    local unittype = GetUnitType(red, green, blue) or "ENEMY_NPC"
                    if player and unittype == "ENEMY_NPC" then unittype = "ENEMY_PLAYER" end

                    if percent <= 0.2 then
                        if unittype == "ENEMY_NPC" or "ENEMY_PLAYER" or "NEUTRAL_NPC" then
                            HealthBar:SetStatusBarColor(255/255, 128/255, 0/255) -- legendary orange
                        elseif unittype == "FRIENDLY_NPC" or "FRIENDLY_PLAYER" then
                            HealthBar:SetStatusBarColor(0/255, 204/255, 255/255) -- Blizzard Blue
                        end
                    else
                        HealthBar:SetStatusBarColor(red, green, blue)
                    end
                end
            end
        end
    end
end

local function GryllsUnitFrames_updatePower(unit)
    local frame
    if unit == "player" then
        frame = Grylls_PlayerFrame
    elseif unit == "pet" then
        frame = Grylls_PetFrame
    elseif unit == "target" then
        frame = Grylls_TargetFrame
    elseif unit == "targettarget" then
        frame = Grylls_TargetofTargetFrame
    elseif unit == "party1" then
        frame = Grylls_PartyMemberFrame1
    elseif unit == "party2" then
        frame = Grylls_PartyMemberFrame2
    elseif unit == "party3" then
        frame = Grylls_PartyMemberFrame3
    elseif unit == "party4" then
        frame = Grylls_PartyMemberFrame4
    else
        -- unit not found
        frame = null
    end

    if frame ~= null then
        local function updatePower(unit, frame)
            if UnitExists(unit) then
                if UnitIsDeadOrGhost(unit) then
                    frame.power:SetText("")
                else
                    local mana = UnitMana(unit) -- returns values for mana/energy/rage
                    local max_mana = UnitManaMax(unit)
                    local percent = mana / max_mana
                    local percent = floor(percent*100)
                    if not (percent >= 0) then
                        percent = 0
                    end

                    if GryllsUnitFrames_Settings.colorpower then
                        local powerType = UnitPowerType(unit) -- 0 = mana, 1 = rage, 3 = energy
                        -- color power text based on power type
                        if powerType == 0 then -- mana
                            frame.power:SetTextColor(0/255, 204/255, 255/255) -- Blizzard Blue
                        elseif powerType == 1 then -- rage
                            frame.power:SetTextColor(255/255, 107/255, 107/255) -- light Red
                        elseif powerType == 2 then -- focus
                            frame.power:SetTextColor(1, 0.5, 0.25)
                        elseif powerType == 3 then -- energy
                            frame.power:SetTextColor(230/255, 204/255, 128/255) -- artifact gold
                        end
                    else
                        frame.power:SetTextColor(255/255, 255/255, 255/255) -- white
                    end

                    local powerType = UnitPowerType(unit) -- 0 = mana, 1 = rage, 3 = energy

                    -- format power text
                    if mana == 0 or ((powerType == 1 or powerType == 3) and percent == 100) then -- hide if 0 power or full rage/energy
                        frame.power:SetText("")
                    elseif GryllsUnitFrames_Settings.value then
                        frame.power:SetText(GryllsUnitFrames_formatNum(mana))
                    elseif GryllsUnitFrames_Settings.percent then
                        frame.power:SetText(percent)
                    elseif GryllsUnitFrames_Settings.both then
                        frame.power:SetText(GryllsUnitFrames_formatNum(mana).." ("..percent..")")
                    end
                end
            end
        end

        local powerType = UnitPowerType(unit) -- 0 = mana, 1 = rage, 3 = energy
        if GryllsUnitFrames_Settings.resource == true and powerType == 0 then -- hide mana when using resource mode
            frame.power:SetText("")
        else
            updatePower(unit, frame)
        end
    end
end

-- credit to Shagu (https://shagu.org/ShaguTweaks/) for code below
local function updatePortraits(frame, unit)
    if GryllsUnitFrames_Settings.classportraits then
        local CLASS_ICON_TCOORDS = {
            ["WARRIOR"] = { 0, 0.25, 0, 0.25 },
            ["MAGE"] = { 0.25, 0.49609375, 0, 0.25 },
            ["ROGUE"] = { 0.49609375, 0.7421875, 0, 0.25 },
            ["DRUID"] = { 0.7421875, 0.98828125, 0, 0.25 },
            ["HUNTER"] = { 0, 0.25, 0.25, 0.5 },
            ["SHAMAN"] = { 0.25, 0.49609375, 0.25, 0.5 },
            ["PRIEST"] = { 0.49609375, 0.7421875, 0.25, 0.5 },
            ["WARLOCK"] = { 0.7421875, 0.98828125, 0.25, 0.5 },
            ["PALADIN"] = { 0, 0.25, 0.5, 0.75 },
        }

        local portrait = nil
        local class = GryllsUnitFrames_localizedClass(unit)

        if frame == TargetTargetFrame then
            portrait = TargetofTargetPortrait
        else
            portrait = frame.portrait
        end

        -- detect unit class or remove for non-player units
        class = UnitIsPlayer(unit) and class or nil

        -- update class icon if possible
        if class then
            local iconCoords = CLASS_ICON_TCOORDS[class]
            portrait:SetTexture("Interface\\Addons\\GryllsUnitFrames\\UI-Classes-Circles")
            portrait:SetTexCoord(unpack(iconCoords))
        elseif not class then
            portrait:SetTexCoord(0, 1, 0, 1)
        end
    end
end

local function GryllsUnitFrames_classPortraits()
	if GryllsUnitFrames_Settings.classportraits then

        local tot = CreateFrame("Frame")
        local events = CreateFrame("Frame")
        events:RegisterEvent("PLAYER_ENTERING_WORLD")
        events:RegisterEvent("PLAYER_TARGET_CHANGED")
        events:RegisterEvent("PARTY_MEMBERS_CHANGED")
        events:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        -- events:RegisterEvent("UNIT_NAME_UPDATE")
        events:RegisterEvent("UNIT_HEALTH")
        events:RegisterEvent("PLAYER_REGEN_DISABLED") -- in combat
        events:SetScript("OnEvent", function()
            if (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_PORTRAIT_UPDATE") then
                updatePortraits(PlayerFrame, "player")
                updatePortraits(TargetFrame, "target")
                updatePortraits(TargetTargetFrame, "targettarget")
                updatePortraits(PartyMemberFrame, "party1")
                updatePortraits(PartyMemberFrame2, "party2")
                updatePortraits(PartyMemberFrame3, "party3")
                updatePortraits(PartyMemberFrame4, "party4")
            elseif (event == "PARTY_MEMBERS_CHANGED") then
                updatePortraits(PartyMemberFrame, "party1")
                updatePortraits(PartyMemberFrame2, "party2")
                updatePortraits(PartyMemberFrame3, "party3")
                updatePortraits(PartyMemberFrame4, "party4")
            elseif (event == "PLAYER_TARGET_CHANGED") then --or (event == "UNIT_NAME_UPDATE" and arg1 == "target") then
                updatePortraits(TargetFrame, "target")
            end
        end)
    end
end

local function GryllsUnitFrames_tot()
    if GryllsUnitFrames_Settings.tot then
        local function updateHealth()
            GryllsUnitFrames_updateHealth("targettarget")

            if GryllsUnitFrames_Settings.colorname then
                if totName ~= UnitName("targettarget") then -- does not run multiple times for the same target
                    totName = UnitName("targettarget")
                    GryllsUnitFrames_colorName("targettarget")
                end
            end
        end

        local function updatePower()
            GryllsUnitFrames_updatePower("targettarget")
        end

        local totName = nil
        TargetofTargetHealthBar:SetScript("OnValueChanged", function()
            updateHealth()
            updatePortraits(TargetTargetFrame, "targettarget")
        end)

        TargetofTargetManaBar:SetScript("OnValueChanged", updatePower)
    end
    GryllsUnitFrames_updateHealthBar("targettarget")
end

local function GryllsUnitFrames_updatePartyFrames()
    if GryllsUnitFrames_Settings.party then
        for i=1, GetNumPartyMembers() do
            local arg = "party"..i
            GryllsUnitFrames_updateHealth(arg)
            GryllsUnitFrames_updateHealthBar(arg)
            GryllsUnitFrames_updatePower(arg)
            GryllsUnitFrames_colorName(arg)
        end
    end
end

local function GryllsUnitFrames_updateUnitFrames()
    GryllsUnitFrames_updateHealth("player")
    GryllsUnitFrames_updateHealthBar("player")
    GryllsUnitFrames_updatePower("player")

    GryllsUnitFrames_updateHealth("pet")
    GryllsUnitFrames_updateHealthBar("pet")
    GryllsUnitFrames_updatePower("pet")

    GryllsUnitFrames_updateHealth("target")
    GryllsUnitFrames_updateHealthBar("target")
    GryllsUnitFrames_updatePower("target")

    GryllsUnitFrames_colorName("player")
    GryllsUnitFrames_colorName("pet")
    GryllsUnitFrames_colorName("target")

    GryllsUnitFrames_updatePartyFrames()
end

local function GryllsUnitFrames_commands(msg, editbox)
    local yellow = "FFFFFF00"
    local orange = "FFFF9900"

    local function fontnum(msg)
        local startPos = string.find(msg, "%d")
        local numstr = string.sub(msg, startPos)
        if tonumber(numstr) then
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: font size set to |c"..yellow..numstr.."|r")
            return numstr
        else
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: unable to set font size to |c"..yellow..numstr.."|r as it is not a number, please try again")
        end
    end

    if msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rUnitFrames options:")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf classportraits|r - toggles display of class portraits")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf party|r - toggles display of party values")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf unit|r - toggles display of player/target/pet values")
        --DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf tick|r - toggles display of energy tick")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf tot|r - toggles display of target of target values")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf value|r - shows options for displaying health/power values")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color|r - shows options for coloring name/health/power values")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf font|r - shows options for changing the font")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf combat text|r - toggles hiding the combat text shown on the portrait")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf combat indicator|r - toggles the target combat indicator")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf tick|r - toggles the tick indicator")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf reset|r - resets all options to default")
    elseif msg == "reset" then
        GryllsUnitFrames_resetVariables()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: options reset to default (please reload ui)")
        GryllsUnitFrames_updateNameFont()
        GryllsUnitFrames_updateValueFont()
        GryllsUnitFrames_updateUnitFrames()
    elseif msg == "classportraits" then
        if GryllsUnitFrames_Settings.classportraits then
            GryllsUnitFrames_Settings.classportraits = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: classportraits off (requires reload)")
        else
            GryllsUnitFrames_Settings.classportraits = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: classportraits on (requires reload)")
        end
        GryllsUnitFrames_classPortraits()
    elseif msg == "combat text" then
        if GryllsUnitFrames_Settings.combattext then
            GryllsUnitFrames_Settings.combattext = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: combat text hidden")
        else
            GryllsUnitFrames_Settings.combattext = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: combat text shown")
        end
        GryllsUnitFrames_combatText()
    elseif msg == "combat indicator" then
        if GryllsUnitFrames_Settings.combatindicator then
            GryllsUnitFrames_Settings.combatindicator = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: combat indicator off")
            GryllsUnitFrames_updateIndicator("target", Grylls_TargetCombatIndicator)
        else
            GryllsUnitFrames_Settings.combatindicator = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: combat indicator on")
            GryllsUnitFrames_createTargetCombatIndicator()
            GryllsUnitFrames_updateIndicator("target", Grylls_TargetCombatIndicator)
        end
    elseif msg == "party" then
        if GryllsUnitFrames_Settings.party then
            GryllsUnitFrames_Settings.party = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: party values hidden")
        else
            GryllsUnitFrames_Settings.party = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: party values shown")
        end
        GryllsUnitFrames_setPartyVisibility()
    elseif msg == "unit" then
        if GryllsUnitFrames_Settings.unit then
            GryllsUnitFrames_Settings.unit = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: unit values hidden")
        else
            GryllsUnitFrames_Settings.unit = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: unit values shown")
        end
        GryllsUnitFrames_setUnitVisibility()
    elseif msg == "tot" then
        if GryllsUnitFrames_Settings.tot then
            GryllsUnitFrames_Settings.tot = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: tot values hidden (please reload)")
        else
            GryllsUnitFrames_Settings.tot = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: tot values shown")
        end
        GryllsUnitFrames_tot()
    -- tick options
    elseif msg == "tick" then
        if GryllsUnitFrames_Settings.tick then
            GryllsUnitFrames_Settings.tick = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: tick hidden (please reload)")
        else
            GryllsUnitFrames_Settings.tick = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: tick shown")
            GryllsUnitFrames_tick()
        end
    elseif msg == "value" then
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."GryllsUnitFrames value options:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf value value|r - shows health/mana as a value (requires MobHealth for enemy values)")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf value percent|r - shows health/mana as a percentage")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf value both|r - shows health/mana as value and percentage")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf value short|r - toggles short values e.g. 10.1k instead of 10,100")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf value resource|r - toggles resource (rage,energy,focus) values only")
    elseif msg == "value value" then
        GryllsUnitFrames_Settings.value = true
        GryllsUnitFrames_Settings.percent = false
        GryllsUnitFrames_Settings.both = false
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: values shown")
        GryllsUnitFrames_updateUnitFrames()
    elseif msg == "value percent" then
        GryllsUnitFrames_Settings.value = false
        GryllsUnitFrames_Settings.percent = true
        GryllsUnitFrames_Settings.both = false
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: percent shown")
        GryllsUnitFrames_updateUnitFrames()
    elseif msg == "value both" then
        GryllsUnitFrames_Settings.value = false
        GryllsUnitFrames_Settings.percent = false
        GryllsUnitFrames_Settings.both = true
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: values and percent shown")
        GryllsUnitFrames_updateUnitFrames()
    elseif msg == "value short" then
        if GryllsUnitFrames_Settings.short then
            GryllsUnitFrames_Settings.short = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: short values off")
            GryllsUnitFrames_updateUnitFrames()
        else
            GryllsUnitFrames_Settings.short = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: short values on")
            GryllsUnitFrames_updateUnitFrames()
        end
    elseif msg == "value resource" then
        if GryllsUnitFrames_Settings.resource then
            GryllsUnitFrames_Settings.resource = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: resource mode off")
            GryllsUnitFrames_updateUnitFrames()
        else
            GryllsUnitFrames_Settings.resource = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: resource mode on (requires reload)")
            GryllsUnitFrames_updateUnitFrames()
        end
    elseif msg == "color" then
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."GryllsUnitFrames color options:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color name|r - toggles player/target/pet/tot class/reaction color names")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color nameparty|r - toggles party class color names")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color background|r - toggles player/target background class/reaction color names")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color health|r - toggles health coloring")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color healthbar|r - toggles healthbar coloring when under 20% health")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf color power|r - toggles power coloring")
        DEFAULT_CHAT_FRAME:AddMessage("power coloring will show the relevant colors for mana, rage, energy and focus")
    elseif msg == "color name" then
        if GryllsUnitFrames_Settings.colorname then
            GryllsUnitFrames_Settings.colorname = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: name coloring off")
            GryllsUnitFrames_updateUnitFrames()
            GryllsUnitFrames_tot()
        else
            GryllsUnitFrames_Settings.colorname = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: name coloring on")
            GryllsUnitFrames_updateUnitFrames()
            GryllsUnitFrames_tot()
        end
    elseif msg == "color background" then
        if GryllsUnitFrames_Settings.colorbackground then
            GryllsUnitFrames_Settings.colorbackground = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: background coloring off (requires reload)")
            GryllsUnitFrames_createColorBackground()
            GryllsUnitFrames_updateUnitFrames()
        else
            GryllsUnitFrames_Settings.colorbackground = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: background coloring on")
            GryllsUnitFrames_createColorBackground()
            GryllsUnitFrames_updateUnitFrames()
        end
    elseif msg == "color health" then
        if GryllsUnitFrames_Settings.colorhealth then
            GryllsUnitFrames_Settings.colorhealth = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: health coloring off")
            GryllsUnitFrames_updateUnitFrames()
        else
            GryllsUnitFrames_Settings.colorhealth = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: health coloring on")
            GryllsUnitFrames_updateUnitFrames()
        end
    elseif msg == "color healthbar" then
        if GryllsUnitFrames_Settings.colorhealthbar then
            GryllsUnitFrames_Settings.colorhealthbar = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: healthbar coloring off (requires reload)")
            GryllsUnitFrames_updateUnitFrames()
        else
            GryllsUnitFrames_Settings.colorhealthbar = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: healthbar coloring on (requires reload)")
            GryllsUnitFrames_updateUnitFrames()
        end
    elseif msg == "color power" then
        if GryllsUnitFrames_Settings.colorpower then
            GryllsUnitFrames_Settings.colorpower = false
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: power coloring off")
            GryllsUnitFrames_updateUnitFrames()
        else
            GryllsUnitFrames_Settings.colorpower = true
            DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: power coloring on")
            GryllsUnitFrames_updateUnitFrames()
        end
    elseif msg == "font" then
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."GryllsUnitFrames font options:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."name/value|r = choose name or value")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."number|r = choose a number")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf font|r |c"..orange.."name/nameparty/value/valueparty |c"..yellow.."size |c"..orange.."number|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf font|r |c"..orange.."name/value |c"..yellow.."arialn|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf font|r |c"..orange.."name/value |c"..yellow.."frizqt|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf font|r |c"..orange.."name/value |c"..yellow.."morpheus|r")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/guf font|r |c"..orange.."name/value |c"..yellow.."skurri|r")
    elseif msg == "font value arialn" then
        GryllsUnitFrames_Settings.valuefont = "arialn"
        GryllsUnitFrames_updateValueFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: value using arialn font")
    elseif msg == "font value frizqt" then
        GryllsUnitFrames_Settings.valuefont = "frizqt__"
        GryllsUnitFrames_updateValueFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: value using frizqt font")
    elseif msg == "font value morpheus" then
        GryllsUnitFrames_Settings.valuefont = "morpheus"
        GryllsUnitFrames_updateValueFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: value using morpheus font")
    elseif msg == "font value skurri" then
        GryllsUnitFrames_Settings.valuefont = "skurri"
        GryllsUnitFrames_updateValueFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: value using skurri font")
    elseif string.find(msg, "font value size %d") then
        GryllsUnitFrames_Settings.valuesize = fontnum(msg)
        GryllsUnitFrames_updateValueFont()
    elseif string.find(msg, "font valueparty size %d") then
        GryllsUnitFrames_Settings.valuesizeparty = fontnum(msg)
        GryllsUnitFrames_updateValueFont()
        GryllsUnitFrames_updateNameFont()
    elseif msg == "font name arialn" then
        GryllsUnitFrames_Settings.namefont = "arialn"
        GryllsUnitFrames_updateNameFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: name using arialn font")
    elseif msg == "font name frizqt" then
        GryllsUnitFrames_Settings.namefont = "frizqt__"
        GryllsUnitFrames_updateNameFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: name using frizqt font")
    elseif msg == "font name morpheus" then
        GryllsUnitFrames_Settings.namefont = "morpheus"
        GryllsUnitFrames_updateNameFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: name using morpheus font")
    elseif msg == "font name skurri" then
        GryllsUnitFrames_Settings.namefont = "skurri"
        GryllsUnitFrames_updateNameFont()
        DEFAULT_CHAT_FRAME:AddMessage("GryllsUnitFrames: name using skurri font")
    elseif string.find(msg, "font name size %d") then
        GryllsUnitFrames_Settings.namesize = fontnum(msg)
        GryllsUnitFrames_updateNameFont()
    elseif string.find(msg, "font nameparty size %d") then
        GryllsUnitFrames_Settings.namesizeparty = fontnum(msg)
        GryllsUnitFrames_updateNameFont()
    end
end

function GryllsUnitFrames_TargetDebuffButton_Update()
    -- FrameXML/TargetFrame.lua
    local buff, buffButton;
	local button;
	local numBuffs = 0;

	for i=1, GryllsUnitFrames.MAX_TARGET_DEBUFFS do
		buff = UnitBuff("target", i);
		button = getglobal("TargetFrameBuff"..i);
		if ( buff ) then
			getglobal("TargetFrameBuff"..i.."Icon"):SetTexture(buff);
			button:Show();
			button.id = i;
			numBuffs = numBuffs + 1;
		else
			button:Hide();
		end
	end

	local debuff, debuffButton, debuffStack, debuffType, color;
	local debuffCount;
	local numDebuffs = 0;
	for i=1, GryllsUnitFrames.MAX_TARGET_DEBUFFS do

		local debuffBorder = getglobal("TargetFrameDebuff"..i.."Border");
		debuff, debuffStack, debuffType = UnitDebuff("target", i);
		button = getglobal("TargetFrameDebuff"..i);
		if ( debuff ) then
			getglobal("TargetFrameDebuff"..i.."Icon"):SetTexture(debuff);
			debuffCount = getglobal("TargetFrameDebuff"..i.."Count");
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			if ( debuffStack > 1 ) then
				debuffCount:SetText(debuffStack);
				debuffCount:Show();
			else
				debuffCount:Hide();
			end
			debuffBorder:SetVertexColor(color.r, color.g, color.b);
			button:Show();
			numDebuffs = numDebuffs + 1;
		else
			button:Hide();
		end
		button.id = i;
	end

	local debuffFrame, debuffWrap, debuffSize, debuffFrameSize;
	local targetofTarget = TargetofTargetFrame:IsShown();

	if ( UnitIsFriend("player", "target") ) then
		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrameBuff1", "BOTTOMLEFT", 0, -2);
	else
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
		if ( targetofTarget ) then
			if ( numDebuffs < 5 ) then
				TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 0, -2);
			elseif ( numDebuffs >= 5 and numDebuffs < 10  ) then
				TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 0, -2);
			elseif (  numDebuffs >= 10 ) then
				TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff11", "BOTTOMLEFT", 0, -2);
			end
		else
			TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff7", "BOTTOMLEFT", 0, -2);
		end
	end

	-- set the wrap point for the rows of de/buffs.
	if ( targetofTarget ) then
		debuffWrap = 5;
	else
		debuffWrap = 6;
	end

	-- and shrinks the debuffs if they begin to overlap the TargetFrame
	if ( ( targetofTarget and ( numBuffs >= 5 ) ) or ( numDebuffs >= debuffWrap ) ) then
		debuffSize = 17;
		debuffFrameSize = 19;
	else
		debuffSize = 21;
		debuffFrameSize = 23;
	end

	-- resize Buffs
	for i=1, GryllsUnitFrames.MAX_TARGET_DEBUFFS do
		button = getglobal("TargetFrameBuff"..i);
		if ( button ) then
			button:SetWidth(debuffSize);
			button:SetHeight(debuffSize);
		end
	end

	-- resize Debuffs
	for i=1, GryllsUnitFrames.MAX_TARGET_DEBUFFS do
		button = getglobal("TargetFrameDebuff"..i);
		debuffFrame = getglobal("TargetFrameDebuff"..i.."Border");
		if ( debuffFrame ) then
			debuffFrame:SetWidth(debuffFrameSize);
			debuffFrame:SetHeight(debuffFrameSize);
		end
		button:SetWidth(debuffSize);
		button:SetHeight(debuffSize);
	end

	-- Reset anchors for debuff wrapping
	getglobal("TargetFrameDebuff"..debuffWrap):ClearAllPoints();
	getglobal("TargetFrameDebuff"..debuffWrap):SetPoint("LEFT", getglobal("TargetFrameDebuff"..(debuffWrap - 1)), "RIGHT", 3, 0);
	getglobal("TargetFrameDebuff"..(debuffWrap + 1)):ClearAllPoints();
	getglobal("TargetFrameDebuff"..(debuffWrap + 1)):SetPoint("TOPLEFT", "TargetFrameDebuff1", "BOTTOMLEFT", 0, -2);
	getglobal("TargetFrameDebuff"..(debuffWrap + 2)):ClearAllPoints();
	getglobal("TargetFrameDebuff"..(debuffWrap + 2)):SetPoint("LEFT", getglobal("TargetFrameDebuff"..(debuffWrap + 1)), "RIGHT", 3, 0);

	-- Set anchor for the last row if debuffWrap is 5
	if ( debuffWrap == 5 ) then
		TargetFrameDebuff11:ClearAllPoints();
		TargetFrameDebuff11:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 0, -2);
	else
		TargetFrameDebuff11:ClearAllPoints();
		TargetFrameDebuff11:SetPoint("LEFT", "TargetFrameDebuff10", "RIGHT", 3, 0);
	end
end

GryllsUnitFrames:RegisterEvent("ADDON_LOADED")
GryllsUnitFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
GryllsUnitFrames:RegisterEvent("UNIT_MANA")
GryllsUnitFrames:RegisterEvent("UNIT_MAXMANA")
GryllsUnitFrames:RegisterEvent("UNIT_HEALTH")
GryllsUnitFrames:RegisterEvent("UNIT_RAGE")
GryllsUnitFrames:RegisterEvent("UNIT_MAXRAGE")
GryllsUnitFrames:RegisterEvent("UNIT_FOCUS")
GryllsUnitFrames:RegisterEvent("UNIT_MAXFOCUS")
GryllsUnitFrames:RegisterEvent("UNIT_ENERGY")
GryllsUnitFrames:RegisterEvent("UNIT_MAXENERGY")
GryllsUnitFrames:RegisterEvent("UNIT_DISPLAYPOWER")
GryllsUnitFrames:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
GryllsUnitFrames:RegisterEvent("PARTY_MEMBERS_CHANGED")
GryllsUnitFrames:RegisterEvent("PLAYER_TARGET_CHANGED")
GryllsUnitFrames:RegisterEvent("UNIT_PET")

GryllsUnitFrames:SetScript("OnEvent", function()
    if (event == "ADDON_LOADED") then
        if not GryllsUnitFrames.loaded then
            SLASH_GRYLLSUNITFRAMES1 = "/gryllsunitframes"
            SLASH_GRYLLSUNITFRAMES2 = "/guf"
            SlashCmdList["GRYLLSUNITFRAMES"] = GryllsUnitFrames_commands

            GryllsUnitFrames_createFrames()
            GryllsUnitFrames_createColorBackground()
            GryllsUnitFrames_tot()
            GryllsUnitFrames_setup()
            GryllsUnitFrames_createTargetCombatIndicator()
            GryllsUnitFrames_classPortraits()

            -- hook TargetDebuffButton_Update
            TargetDebuffButton_Update = GryllsUnitFrames_TargetDebuffButton_Update

            DEFAULT_CHAT_FRAME:AddMessage("|cffff8000Grylls|rUnitFrames loaded! /guf")
            GryllsUnitFrames.loaded = true
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        GryllsUnitFrames_updateNameFont()
        GryllsUnitFrames_updateValueFont()
        GryllsUnitFrames_setPartyVisibility()
        GryllsUnitFrames_setUnitVisibility()
        GryllsUnitFrames_combatText()
        GryllsUnitFrames_tick()
        GryllsUnitFrames_colorName("player")
        GryllsUnitFrames_updateHealth("player")
        GryllsUnitFrames_updateHealthBar("player")
        GryllsUnitFrames_updatePower("player")
        GryllsUnitFrames_updatePartyFrames()
        GryllsUnitFrames_hideStatusBarText()
    elseif (event == "PLAYER_TARGET_CHANGED") then
        GryllsUnitFrames_colorName("target")
        GryllsUnitFrames_updateHealth("target")
        GryllsUnitFrames_updateHealthBar("target")
        GryllsUnitFrames_updatePower("target")
        GryllsUnitFrames_updateIndicator("target", Grylls_TargetCombatIndicator)
    elseif (event == "PARTY_MEMBERS_CHANGED") then
        GryllsUnitFrames_updatePartyFrames()
    elseif (event == "UNIT_PET") then
        if (arg1 == "player") then -- runs for player pet only
            GryllsUnitFrames_colorName("pet")
            GryllsUnitFrames_updateHealth("pet")
            GryllsUnitFrames_updateHealthBar("pet")
            GryllsUnitFrames_updatePower("pet")
        end
    elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
        GryllsUnitFrames_updateHealth(arg1)
        GryllsUnitFrames_updateHealthBar(arg1)
    elseif (event == "UNIT_MANA" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_RAGE" or event == "UNIT_FOCUS" or event == "UNIT_ENERGY" or event == "UPDATE_SHAPESHIFT_FORMS" or event == "UNIT_MAXMANA" or event == "UNIT_MAXRAGE" or event == "UNIT_MAXENERGY" or event == "UNIT_MAXFOCUS") then
        GryllsUnitFrames_updatePower(arg1)
    end
end)