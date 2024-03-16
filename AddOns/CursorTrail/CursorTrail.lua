--[[---------------------------------------------------------------------------
    Addon:  CursorTrail
    File:   CursorTrail.lua
    Desc:   This file contains the core implementation for this addon.
-----------------------------------------------------------------------------]]

local kAddonFolderName, private = ...

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Saved (Persistent) Variables                      ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CursorTrail_Config = CursorTrail_Config or {}
CursorTrail_PlayerConfig = CursorTrail_PlayerConfig or {}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Aliases to Globals                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local Globals = _G
local _  -- Prevent tainting global _ .
local abs = _G.math.abs
local assert = _G.assert
local CopyTable = _G.CopyTable
local CreateFrame = _G.CreateFrame
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local floor = _G.floor
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetCursorPosition = _G.GetCursorPosition
local GetCVar = _G.GetCVar
local GetTime = _G.GetTime
local geterrorhandler = _G.geterrorhandler
local ipairs = _G.ipairs
local IsMouseButtonDown = _G.IsMouseButtonDown
local IsMouselooking = _G.IsMouselooking
local math =_G.math
local max =_G.math.max
local min =_G.math.min
local next = _G.next
local pairs = _G.pairs
local print = _G.print
local random = _G.math.random
local select = _G.select
local string = _G.string
local table = _G.table
local tonumber = _G.tonumber
local UIParent = _G.UIParent
local UnitAffectingCombat = _G.UnitAffectingCombat
local xpcall = _G.xpcall

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Declare Namespace                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local CursorTrail = _G.CursorTrail or {}
if (not _G.CursorTrail) then _G.CursorTrail = CursorTrail end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Remap Global Environment                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Constants                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kAddonName = kAddonFolderName  -- (i.e.  "CursorTrail")
kAddonVersion = (GetAddOnMetadata(kAddonName, "Version") or "0.0.0.0"):match("^([%d.]+)")
kGameTocVersion = select(4, GetBuildInfo())
----print("CursorTrail kGameTocVersion:", kGameTocVersion)

-- Colors (Hex format = alpha, R, G, B.)
kTextColorDefault = "|cff7F7FFF"
BLUE        = "|cff0099DD"
BABYBLUE    = "|cff89CFF0"
GREEN       = "|cff00FF00"
GREEN2      = "|cff80FF00"  -- Bright Green
ORANGE      = "|cffEE5500"
RED         = "|cffFF0000"
RED2        = "|cffFF2020"  -- Bright Red
WHITE       = "|cffFFFFFF"
YELLOW      = "|cffFDDA0D"

-- Misc.
kShow = 1
kHide = -1

kMediaPath = "Interface\\Addons\\" .. kAddonName .. "\\Media\\"
kStr_None = "< 無 >"
kAddonErrorHeading = RED2.."[ERROR] "..kTextColorDefault.."["..kAddonName.."] "..WHITE
kAddonAlertHeading = ORANGE.."<"..YELLOW..kAddonName..ORANGE.."> "..kTextColorDefault

kFrameLevel = 32
kDefaultShadowSize = 72
kDefaultShapeSize = kDefaultShadowSize - 18

kScreenTopFourthMult = 1.015
kScreenBottomFourthMult = 1.077

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
kNewFeatures =  -- For flagging new features in the UI.
{
    -- Added in version 10.1.7.2 ...
    {anchor="BOTTOMLEFT", relativeTo="SparkleCheckbox", relativeAnchor="TOPRIGHT", x=-13, y=-5.3},
    {anchor="LEFT", relativeTo="DefaultsBtn11", relativeAnchor="RIGHT", x=0, y=0.7},

--~ Disabled this notification in 10.1.5.2 ...
--~     -- Added in version 10.1.0.1 ...
--~     "ShapeLabel",
--~     "HelpBtn",

    -- FOR TESTING ...
--~     {anchor="RIGHT", relativeTo="ShapeLabel", relativeAnchor="LEFT", x=-2, y=1},
--~     {anchor="LEFT", relativeTo="SparkleCheckbox.label", relativeAnchor="RIGHT", x=2, y=1.25},
--~     {anchor="RIGHT", relativeTo="OffsetLabel", relativeAnchor="LEFT", x=-2, y=1},
--~     {anchor="RIGHT", relativeTo="MouseLookCheckbox", relativeAnchor="LEFT", x=-2, y=2},
--~     {anchor="BOTTOM", relativeTo="HelpBtn", relativeAnchor="TOP", x=0, y=-1},
}

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
-- Default (Preset) Constants:
kDefaultModelID = 1417024 -- 彩虹
kDefaultConfig =
{
    ShapeFileName = nil,
    ModelID = kDefaultModelID,
    ShapeColorR = 1.0, ShapeColorG = 1.0, ShapeColorB = 1.0,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    UserShadowAlpha = 0.0,  -- (Solid = 1.0.  Transparent = 0.0)
    UserScale = 1.0,  -- (User model scale.  It is 1/100th the value shown in the UI.)
    UserAlpha = 1.00,  -- (Solid = 1.0.  Transparent = 0.0)
    Strata = "HIGH",
    UserOfsX = 0, UserOfsY = 0,  -- (User model offsets.  They are 1/10th the values shown in the UI.)
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    FadeOut = false,
    UserShowOnlyInCombat = false,
    UserShowMouseLook = false,
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--~     -- Preserve window location.
--~     OptionsSetPoint1 = nil,
--~     OptionsSetPoint2 = nil,
--~     OptionsSetPoint3 = nil,
--~     OptionsSetPoint4 = nil,
--~     OptionsSetPoint5 = nil,
}

kDefaultConfig2 = CopyTable(kDefaultConfig)
kDefaultConfig2.ModelID = 166498  -- "Electric, Blue & Long"
kDefaultConfig2.UserScale = 1.35
kDefaultConfig2.UserOfsX = 2.0
kDefaultConfig2.UserOfsY = -1.6
kDefaultConfig2.UserAlpha = 0.50

kDefaultConfig3 = CopyTable(kDefaultConfig)
kDefaultConfig3.ModelID = 166498  -- "Electric, Blue & Long"
kDefaultConfig3.UserScale = 0.50
kDefaultConfig3.UserOfsX = 2.0
kDefaultConfig3.UserOfsY = -2.1
kDefaultConfig3.UserAlpha = 1.0
--~ kDefaultConfig3.UserOfsX = 0.2
--~ kDefaultConfig3.UserOfsY = -0.1
--~ kDefaultConfig3.ModelID = 166492  -- "Electric, Blue"
--~ kDefaultConfig3.FadeOut = true

kDefaultConfig4 = CopyTable(kDefaultConfig)
kDefaultConfig4.ShapeFileName = kMediaPath.."Ring Soft 2.tga"
kDefaultConfig4.ModelID = 166926  -- "Soul Skull"
kDefaultConfig4.ShapeColorR = 0.984
kDefaultConfig4.ShapeColorG = 0.714
kDefaultConfig4.ShapeColorB = 0.82
kDefaultConfig4.UserScale = 0.7
kDefaultConfig4.UserAlpha = 1.0
kDefaultConfig4.UserShadowAlpha = 0.3
kDefaultConfig4.Strata = "FULLSCREEN"

--~ kDefaultConfig4 = CopyTable(kDefaultConfig)
--~ kDefaultConfig4.UserScale = 0.10
--~ kDefaultConfig4.UserAlpha = 1.0

kDefaultConfig5 = CopyTable(kDefaultConfig)
kDefaultConfig5.UserScale = 1.8
kDefaultConfig5.UserAlpha = 0.65
kDefaultConfig5.UserShadowAlpha = 0.30

kDefaultConfig6 = CopyTable(kDefaultConfig)
kDefaultConfig6.ModelID = 166923  -- "Burning Cloud, Purple"
kDefaultConfig6.UserScale = 2.0

kDefaultConfig7 = CopyTable(kDefaultConfig)
kDefaultConfig7.ModelID = 166923  -- "Burning Cloud, Purple"
kDefaultConfig7.UserScale = 2.5
kDefaultConfig7.FadeOut = true
kDefaultConfig7.Strata = "FULLSCREEN"

kDefaultConfig8 = CopyTable(kDefaultConfig)
kDefaultConfig8.ModelID = 166926  -- "Soul Skull"
kDefaultConfig8.UserScale = 1.5
kDefaultConfig8.Strata = "FULLSCREEN"

kDefaultConfig9 = CopyTable(kDefaultConfig)
kDefaultConfig9.ModelID = 166991  -- "Cloud, Dark Blue",
kDefaultConfig9.UserScale = 2.4
kDefaultConfig9.FadeOut = true
kDefaultConfig9.Strata = "FULLSCREEN"

kDefaultConfig10 = CopyTable(kDefaultConfig)
kDefaultConfig10.ModelID = 166923  -- "Burning Cloud, Purple"
kDefaultConfig10.UserScale = 1.5
kDefaultConfig10.UserOfsY = 0.1
kDefaultConfig10.UserAlpha = 0.80
kDefaultConfig10.UserShadowAlpha = 0.50
kDefaultConfig10.FadeOut = true

kDefaultConfig11 = CopyTable(kDefaultConfig)
kDefaultConfig11.ShapeFileName = kMediaPath.."Ring 3.tga"
kDefaultConfig11.ModelID = 0
kDefaultConfig11.ShapeColorR = 1.0
kDefaultConfig11.ShapeColorG = 1.0
kDefaultConfig11.ShapeColorB = 1.0
kDefaultConfig11.ShapeSparkle = true
kDefaultConfig11.UserScale = 0.65
kDefaultConfig11.UserAlpha = 1.0
kDefaultConfig11.UserShadowAlpha = 0.65
kDefaultConfig11.Strata = "FULLSCREEN"
kDefaultConfig11.FadeOut = false

--~ -- NOTE: The next config only works for Retail WoW.
--~ kDefaultConfig12 = CopyTable(kDefaultConfig)
--~ kDefaultConfig12.ShapeFileName = kMediaPath.."Ring 3.tga"
--~ kDefaultConfig12.ModelID = 1417024  -- "Sparkling, Rainbow"
--~ kDefaultConfig12.ShapeColorR = 1.0
--~ kDefaultConfig12.ShapeColorG = 0.882
--~ kDefaultConfig12.ShapeColorB = 0.882
--~ kDefaultConfig12.UserScale = 0.6
--~ kDefaultConfig12.UserAlpha = 1.0
--~ kDefaultConfig12.UserShadowAlpha = 0.99
--~ kDefaultConfig12.Strata = "HIGH"
--~ kDefaultConfig12.FadeOut = false

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Switches                                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kEditBaseValues = false -- Set to true so arrow keys change base offsets and step size while UI is up.  (Developers only!)
                        -- Arrow keys (no modifier key) change BaseOfsX and BaseOfsY.
                        -- Alt causes arrow keys to change BaseStepX and BaseStepY.
                        -- Shift decrease the amount of change each arrow key press.
                        -- Ctrl increase the amount of change each arrow key press.
                        -- When done, type "/ct model" to dump all values (BEFORE CLOSING THE UI).
kAlwaysUseDefaults = false  -- Set to true to prevent using saved settings.
kShadowStrataMatchesMain = false  -- Set to true if you want shadow at same level as the trail effect.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Variables                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

gLButtonDownCount = 0
gMotionIntensity = 0  -- Ranges 0.0 to 1.0, increases the longer the mouse is moving.  Decrease when mouse is idle.
gShowOrHide = nil  -- Can be kShow, kHide, or nil (no change).
gPreviousX = nil
gPreviousY = nil

-- Sparkling shape color arrays:
gShapeSparkleIndex = 1
gShapeSparkleMax = 60
gShapeSparkleR = {}
gShapeSparkleG = {}
gShapeSparkleB = {}
for i = 1, gShapeSparkleMax do
    gShapeSparkleR[i] = random(3,9) * 0.1
    gShapeSparkleG[i] = random(3,9) * 0.1
    gShapeSparkleB[i] = random(3,9) * 0.1
end

-- Timer variables:
gTimer1 = 0
kTimer1Interval = 0.250 -- seconds

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Helper Functions                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
kGameFrame = UIParent
function getScreenScaledSize()
    local uiScale = kGameFrame:GetEffectiveScale()  -- i.e. getScreenScale()
    ----print("uiScale:", round(uiScale,4), "  GetCVar(uiScale):", round(GetCVar("uiScale"),4))
    local w, h = kGameFrame:GetSize()  -- i.e. getScreenSize()
    w = w * uiScale
    h = h * uiScale
    local midX = w / 2
    local midY = h / 2
    local hypotenuse = (w^2 + h^2) ^ 0.5
    return w, h, midX, midY, uiScale, hypotenuse
end

-------------------------------------------------------------------------------
function updateScaleVars()
    ScreenW, ScreenH, ScreenMidX, ScreenMidY, ScreenScale, ScreenHypotenuse = getScreenScaledSize()
    ScreenFourthH = ScreenH * 0.25  -- 1/4th screen height.
    ----print("ScreenScale:", round(ScreenScale,4), " GetCVar(uiScale):", GetCVar("uiScale"), " ScreenW:", round(ScreenW,1), " ScreenH:", round(ScreenH,1))
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                    Register for Slash Commands                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
function printUsageMsg()
    printMsg(kAddonName.." "..kAddonVersion.." 指令:")
    printMsg("(注意: 輸入 "..BLUE.."/ct|r".." or "..BLUE.."/"..kAddonName.."|r 都可以使用這些指令。)")
    printMsg(BLUE.."  /ct"..GREEN2.." - 顯示/隱藏選項視窗。")
    printMsg(BLUE.."  /ct combat"..GREEN2.." - 切換 '只在戰鬥中顯示' 的設定。")
    printMsg(BLUE.."  /ct fade"..GREEN2.." - 切換 '滑鼠不動時隱藏' 的設定。")
    printMsg(BLUE.."  /ct help"..GREEN2.." - 顯示這段說明內容。")
    printMsg(BLUE.."  /ct mouselook"..GREEN2.." - 切換 '用滑鼠控制視角時要顯示' 的設定。")
    printMsg(BLUE.."  /ct off"..GREEN2.." - 暫時停用滑鼠特效已改善遊戲效能。"
        .."  (下次重新載入介面，或是輸入 "..BLUE.."/ct on"..GREEN2.." 來重新啟用。)")
    printMsg(BLUE.."  /ct reload"..GREEN2.." - 載入當前的滑鼠游標設定。")
    printMsg(BLUE.."  /ct reset"..GREEN2.." - 重置為原本的設定。")
    printMsg(BLUE..'  /ct sparkle'..GREEN2..' - 將圖形顏色在普通或 "閃閃發光" 之間切換。')
    printMsg(GREEN2.."設定檔指令:")
    printMsg(BLUE.."    /ct delete <設定檔名稱>")
    printMsg(BLUE.."    /ct list")
    printMsg(BLUE.."    /ct load <設定檔名稱>")
    printMsg(BLUE.."    /ct save <設定檔名稱>")

    ----printMsg(BLUE.."  /ct screen"..GREEN2.." - Print screen info in chat window.")
    ----printMsg(BLUE.."  /ct camera"..GREEN2.." - Print camera info in chat window.")
    ----printMsg(BLUE.."  /ct config"..GREEN2.." - Print configuration info in chat window.")
    ----printMsg(BLUE.."  /ct model"..GREEN2.." - Print model info in chat window.")
    ----printMsg(BLUE.."  /ct cal"..GREEN2.." - Calibrate cursor effect to your mouse.")
    ----printMsg(" \n")
end
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
Globals["SLASH_"..kAddonName.."1"] = "/"..kAddonName
Globals["SLASH_"..kAddonName.."2"] = "/ct"
Globals.SlashCmdList[kAddonName] = function (params)
    if (params == nil or params == "") then
        if OptionsFrame:IsShown() then
            OptionsFrame:Hide()
        else
            OptionsFrame:Show()
            if isCursorTrailOff() then CursorTrail_ON(true) end
        end
        ----printUsageMsg()
        return
    end

    params = string.lower(params)
    ----local paramAsNum = tonumber(params)

    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    if (params == "help" or params == "?") then
        printUsageMsg()
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "reset") then
        ----if Calibrating then Calibrating_DoNextStep("abort") end
        if (OptionsFrame and OptionsFrame:IsShown()) then OptionsFrame:Hide() end
        PlayerConfig_SetDefaults()
        CursorTrail_Load()
        CursorTrail_ON()
        printMsg("鼠之軌跡".." 重置為原本的設定。")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "reload") then
        if (OptionsFrame and OptionsFrame:IsShown()) then OptionsFrame:Hide() end
        updateScaleVars()
        CursorTrail_Load()
        CursorTrail_ON()
        ----if (OptionsFrame and OptionsFrame:IsShown()) then OptionsFrame_UpdateUI(PlayerConfig) end
        printMsg("鼠之軌跡".." 設定已載入。")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "resetnewfeatures") then  -- For development use.
        if (OptionsFrame and OptionsFrame:IsShown()) then OptionsFrame:Hide() end
        Globals.CursorTrail_Config.NewFeaturesSeen = {}
        printMsg("鼠之軌跡".." 重置新功能通知。")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "combat") then
        PlayerConfig.UserShowOnlyInCombat = not PlayerConfig.UserShowOnlyInCombat
        PlayerConfig_Save()
        CursorTrail_Load(PlayerConfig)
        if OptionsFrame:IsShown() then OptionsFrame_Value("combat", PlayerConfig.UserShowOnlyInCombat) end
        printMsg("鼠之軌跡"..GREEN2.." '只在戰鬥中顯示' |r= "
            ..ORANGE..(PlayerConfig.UserShowOnlyInCombat==true and "開啟" or "關閉"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "mouselook") then
        PlayerConfig.UserShowMouseLook = not PlayerConfig.UserShowMouseLook
        PlayerConfig_Save()
        CursorTrail_Load(PlayerConfig)
        if OptionsFrame:IsShown() then OptionsFrame_Value("mouselook", PlayerConfig.UserShowMouseLook) end
        printMsg("鼠之軌跡"..GREEN2.." '用滑鼠控制視角時要顯示' |r= "
            ..ORANGE..(PlayerConfig.UserShowMouseLook==true and "開啟" or "關閉"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "fade") then
        PlayerConfig.FadeOut = not PlayerConfig.FadeOut
        PlayerConfig_Save()
        CursorTrail_Load(PlayerConfig)
        if OptionsFrame:IsShown() then OptionsFrame_Value("fade", PlayerConfig.FadeOut) end
        if (PlayerConfig.FadeOut == true) then gMotionIntensity = 0.5 end
        printMsg("鼠之軌跡"..GREEN2.." '滑鼠不動時隱藏' |r= "
            ..ORANGE..(PlayerConfig.FadeOut==true and "開啟" or "關閉"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "sparkle") then
        if (OptionsFrame and OptionsFrame:IsShown()) then OptionsFrame:Hide() end
        CursorTrail_SetShapeSparkle( not PlayerConfig.ShapeSparkle )
        PlayerConfig_Save()
        printMsg("鼠之軌跡"..GREEN2.." '圖形閃閃發光' |r= "
            ..ORANGE..(PlayerConfig.ShapeSparkle==true and "開啟" or "關閉"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params:sub(1,4) == "list") then
        Profiles_List()
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params:sub(1,4) == "load") then
        Profiles_Load( params:sub(6) )
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params:sub(1,4) == "save") then
        Profiles_Save( params:sub(6) )
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params:sub(1,6) == "delete") then
        Profiles_Delete( params:sub(8) )
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "on") then
        -- Show model if in combat or ShowOnlyInCombat is false.
        if (PlayerConfig.UserShowOnlyInCombat ~= true or UnitAffectingCombat("player") == true) then
            CursorTrail_Show()
        end
        CursorTrail_ON(true)
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif (params == "off") then
        CursorTrail_OFF()
        CursorTrail_Hide()
        printMsg("鼠之軌跡"..": "..ORANGE.."關閉|r  (下次重新載入時會再次開啟，或是從選項視窗開啟。)")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
--~     elseif (params == "test") then
--~         ----print("UIParent:GetEffectiveScale():", UIParent:GetEffectiveScale())
--~         ----UIParent:SetScale(0.7)
--~         ----updateScaleVars()
--~         msgBox("CursorTrail message box test message.")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif not HandleToolSwitches(params) then
        printMsg("鼠之軌跡"..": 無效的指令 ("..params..")。")
        ----DebugText(kAddonName..": Invalid slash command ("..params..").")
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Event Handlers                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

EventFrame = CreateFrame("Frame")

-------------------------------------------------------------------------------
EventFrame:SetScript("OnEvent", function(self, event, ...)
	-- This calls a method named after the event, passing in all the relevant args.
    -- Example:  MyAddon.frame:RegisterEvent("XYZ") calls function MyAddon.frame:XYZ()
    --           with any arguments passed in the "..." part.
	self[event](self, ...)
end)

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("ADDON_LOADED")
function       EventFrame:ADDON_LOADED(addonName)
    if (addonName == kAddonName) then
        ----dbg("ADDON_LOADED")
        ----print("|c7f7f7fff".. kAddonName .." "..kAddonVersion.." loaded.  For options, type \n"..
        ----    Globals["SLASH_"..kAddonName.."2"] .." or ".. Globals["SLASH_"..kAddonName.."1"] ..".|r") -- Color format = xRGB.
        self:UnregisterEvent("ADDON_LOADED")
    end
end

-------------------------------------------------------------------------------
--~ EventFrame:RegisterEvent("CVAR_UPDATE")
--~ function       EventFrame:CVAR_UPDATE(varName, varValue)
--~     ----dbg("CVAR_UPDATE("..(varName or "nil")..", "..(varValue or "nil")..")")
--~     if (varName and varName == "uiScale") then
--~         ----dbg("*** Calling updateScaleVars() ***")
--~         updateScaleVars()
--~     end
--~ end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") --VARIABLES_LOADED
function       EventFrame:PLAYER_ENTERING_WORLD()
    ----dbg("PLAYER_ENTERING_WORLD")
    ----dbg("CursorModel: "..(CursorModel and "EXISTS" or "NIL"))
    Addon_Initialize()
    if not StandardPanel then StandardPanel_Create("/"..kAddonName) end
    if not OptionsFrame then OptionsFrame_Create() end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("UI_SCALE_CHANGED")
function       EventFrame:UI_SCALE_CHANGED()
    ----dbg("UI_SCALE_CHANGED")
    updateScaleVars()
    if CursorModel then
        -- Reload the cursor model to apply the new UI scale.
        CursorTrail_Load()
    end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
function       EventFrame:LOADING_SCREEN_DISABLED()
    updateScaleVars()
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_LOGOUT")
function       EventFrame:PLAYER_LOGOUT()
    PlayerConfig_Save()
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("CINEMATIC_START")
function       EventFrame:CINEMATIC_START()
    ----gShowOrHide = kHide
    gShowOrHide = nil
    CursorTrail_Hide()
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("CINEMATIC_STOP")
function       EventFrame:CINEMATIC_STOP()
    ----gShowOrHide = kShow
    gShowOrHide = nil
    if (PlayerConfig.UserShowOnlyInCombat == true) then
        CursorTrail_Hide()
    else
        CursorTrail_Show()
    end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
function       EventFrame:PLAYER_REGEN_DISABLED()  -- Combat started.
    ----dbg("PLAYER_REGEN_DISABLED")
    if (PlayerConfig.UserShowOnlyInCombat == true) then gShowOrHide = kShow end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
function       EventFrame:PLAYER_REGEN_ENABLED()  -- Combat ended.
    ----dbg("PLAYER_REGEN_ENABLED")
    if (PlayerConfig.UserShowOnlyInCombat == true) then gShowOrHide = kHide end
end

-------------------------------------------------------------------------------
----EventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")  <-- Registered in OptionsFrame_OnShow().
function EventFrame:GLOBAL_MOUSE_DOWN(button)
    ----dbg("GLOBAL_MOUSE_DOWN")
    private.Controls.handleGlobalMouseClick(button)
end

--~ -------------------------------------------------------------------------------
--~ EventFrame:RegisterEvent("UNIT_PET")
--~ function       EventFrame:UNIT_PET()
--~     ----dbg("UNIT_PET")
--~     -- Eat this event so it doesn't mysteriously cause an
--~     -- "addon tried to call protected function" error
--~     -- in Blizzard's CompactuUnitFrame.lua file.
--~ end

--~ -------------------------------------------------------------------------------
--~ EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
--~ function       EventFrame:GROUP_ROSTER_UPDATE()
--~     ----dbg("GROUP_ROSTER_UPDATE")
--~     -- Eat this event so it doesn't mysteriously cause an
--~     -- "addon tried to call protected function" error
--~     -- in Blizzard's CompactRaidFrameContainer.lua file.
--~ end

-------------------------------------------------------------------------------
function CursorTrail_OnUpdate(self, elapsedSeconds)
    ----DebugText("CPU: "..round(elapsedSeconds,3), 76)
    ----local t0 = GetTime()
    local bIsMouseLooking = IsMouselooking()

    if (PlayerConfig.UserShowMouseLook == true) then
        gTimer1 = 0  -- Prevents hiding during "mouse look".
        if (bIsMouseLooking == true and PlayerConfig.FadeOut == true) then
            gMotionIntensity = 1.0  -- Force show during mouse look.
        end
    else
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        -- Hide cursor effect during "mouse look".
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        gTimer1 = gTimer1 + elapsedSeconds
        if (gTimer1 >= kTimer1Interval) then
            gTimer1 = 0
            if (OptionsFrame and OptionsFrame:IsShown() ~= true) then
                if (bIsMouseLooking == true) then
                    gLButtonDownCount = 1
                    if ( CursorModel.IsHidden ~= true
                        or (ShadowTexture and ShadowTexture:GetAlpha() > 0)
                        or (ShapeTexture and ShapeTexture:GetAlpha() > 0) )
                      then
                        gShowOrHide = kHide;
                    end
                elseif IsMouseButtonDown("LeftButton") then
                    gLButtonDownCount = gLButtonDownCount + 1
                    if (gLButtonDownCount > 1) then
                        if ( CursorModel.IsHidden ~= true
                            or (ShadowTexture and ShadowTexture:GetAlpha() > 0)
                            or (ShapeTexture and ShapeTexture:GetAlpha() > 0) )
                          then
                            gShowOrHide = kHide
                        end
                    end
                elseif (gLButtonDownCount > 0) then
                    gLButtonDownCount = 0
                    gShowOrHide = kShow
                    if (PlayerConfig.UserShowOnlyInCombat == true
                        and UnitAffectingCombat("player") ~= true
                        ) then
                        -- Player not in combat, so don't show the cursor.
                        gShowOrHide = kHide
                    end
                end
            end
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - --
    -- Show/hide cursor model (or leave it as-is).
    -- - - - - - - - - - - - - - - - - - - - - - - - --
    if (gShowOrHide == kShow) then
        CursorTrail_Show()  -- Note: Resets gShowOrHide to nil.
        ----xpcall(CursorTrail_Show, errHandler)
    elseif (gShowOrHide == kHide) then
        CursorTrail_Hide()  -- Note: Resets gShowOrHide to nil.
        ----xpcall(CursorTrail_Hide, errHandler)
        return  -- No need to continue when its hidden.
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - --
    -- Update shape color if sparkle mode is on.
    -- - - - - - - - - - - - - - - - - - - - - - - - --
    if (ShapeTexture and PlayerConfig.ShapeSparkle) then
        ShapeTexture:SetVertexColor(gShapeSparkleR[gShapeSparkleIndex]
                                  , gShapeSparkleG[gShapeSparkleIndex]
                                  , gShapeSparkleB[gShapeSparkleIndex])
        gShapeSparkleIndex = gShapeSparkleIndex + 1
        if gShapeSparkleIndex > gShapeSparkleMax then gShapeSparkleIndex = 1 end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - --
    -- Follow mouse cursor.
    -- - - - - - - - - - - - - - - - - - - - - - - - --
    local cursorX, cursorY = GetCursorPosition()
    ----DebugText("x: "..cursorX..",  y: "..cursorY)
    if (cursorX ~= gPreviousX or cursorY ~= gPreviousY) then
        -- Cursor position changed.  Keep model position in sync with it.

        ----local dx, dy = cursorX-(gPreviousX or 0), cursorY-(gPreviousY or 0)
        gPreviousX, gPreviousY = cursorX, cursorY

        local tX, tY   -- (x, y) position of texture objects.
        if (ShadowTexture or ShapeTexture) then
            tX = ((cursorX - ScreenMidX) / ScreenScale)
            tY = ((cursorY - ScreenMidY) / ScreenScale)
        end

        -- Update position of shadow.
        if ShadowTexture then
            ShadowTexture:SetPoint("CENTER", kGameFrame, "CENTER", tX+3, tY-2)
            ----ShadowTexture:SetPoint("CENTER", kGameFrame, "CENTER", tX+(3*PlayerConfig.UserScale), tY-(2*PlayerConfig.UserScale))
        end

        -- Update position of model.
        if CursorModel then
            if (CursorModel.Constants.IsSkewed == true) then
                cursorX, cursorY = unskew(cursorX, cursorY,
                                        CursorModel.Constants.HorizontalSlope,
                                        CursorModel.Constants.SkewTopMult,
                                        CursorModel.Constants.SkewBottomMult)
            end

            local modelX = ((cursorX - ScreenMidX) / CursorModel.StepX) + CursorModel.OfsX
            local modelY = ((cursorY - ScreenMidY) / CursorModel.StepY) + CursorModel.OfsY
            CursorModel:SetPosition(0, modelX, modelY)
        end

        -- Update position of shape.
        if ShapeTexture then
            ShapeTexture:SetPoint("CENTER", kGameFrame, "CENTER", tX+0.5, tY-0.5)
        end

        -- - - - - - - - - - - - - - - - - - - - - - - - --
        -- Fade in, if necessary.
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        if (PlayerConfig.FadeOut == true) then
            -- Calculate motion intensity.
            if (gMotionIntensity <= 0) then
                gMotionIntensity = 0.04  -- Starting intensity for fading in.
            elseif (gMotionIntensity < 1) then
                gMotionIntensity = min(1.0, gMotionIntensity*1.23)  -- Increase intensity while cursor moves (up to 1.0).
            end
            ----print("gMotionIntensity fi:", round(gMotionIntensity,2))

            -- Apply motion intensity to user's chosen alpha levels.
            if (CursorModel and CursorModel.IsHidden ~= true) then
                CursorModel:SetAlpha( PlayerConfig.UserAlpha * gMotionIntensity )
            end
            if (ShadowTexture and PlayerConfig.UserShadowAlpha > 0) then  -- Has user set shadow opacity?
                ShadowTexture:SetAlpha( PlayerConfig.UserShadowAlpha * gMotionIntensity )
            end
            if (ShapeTexture and PlayerConfig.UserAlpha > 0) then  -- TODO: Add a userShapeAlpha parameter set by user?
                ShapeTexture:SetAlpha( PlayerConfig.UserAlpha * gMotionIntensity )
            end
        end
    elseif (gMotionIntensity > 0) then
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        -- Fade out when mouse is not moving.
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        local kFadeoutSecs = 0.5  -- (Reduce from max to min intensity over this many seconds.)
        local delta, alpha

        -- Decrease intensity.
        ----if (gMotionIntensity >= 1.0) then print("-------------") end
        delta = elapsedSeconds / kFadeoutSecs
        gMotionIntensity = gMotionIntensity - delta
        if (gMotionIntensity < 0) then gMotionIntensity = 0 end
        ----print("elapsed: "..round(elapsedSeconds,2)..", delta: "..round(delta,2))
        ----dbg("gMotionIntensity fo: "..round(gMotionIntensity,2))

        -- Fade out model.
        if CursorModel then
            if (CursorModel:GetAlpha() > 0) then
                alpha = PlayerConfig.UserAlpha * gMotionIntensity
                CursorModel:SetAlpha(alpha)
                ----print("model alpha:", round(alpha,2))
            end
        end

        -- Fade out shadow.
        if ShadowTexture then
            if (ShadowTexture:GetAlpha() > 0) then
                alpha = PlayerConfig.UserShadowAlpha * gMotionIntensity
                ShadowTexture:SetAlpha(alpha)
                ----print("shadow alpha:", round(alpha,2))
            end
        end

        -- Fade out shape.
        if ShapeTexture then
            if (ShapeTexture:GetAlpha() > 0) then
                alpha = PlayerConfig.UserAlpha * gMotionIntensity
                ShapeTexture:SetAlpha(alpha)
                ----print("shape alpha:", round(alpha,2))
            end
        end
    end

    ----DebugText("dt: "..GetTime()-t0, 200)
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Hooks                                        ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
-- Hide during movies.
Globals.MovieFrame:HookScript("OnShow", function() gShowOrHide = kHide end)
Globals.MovieFrame:HookScript("OnHide", function() gShowOrHide = kShow end)

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Functions                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
function Addon_Initialize()
    -------------------
    -- Global Settings
    -------------------
    Globals.CursorTrail_Config.Profiles = Globals.CursorTrail_Config.Profiles or {}

    ------ Changelog stuff.
    ---->>> NOT IMPLEMENTED YET.
    ----Globals.CursorTrail_Config.LastChangelogVersion = Globals.CursorTrail_Config.LastChangelogVersion or ""
    ----
    ------ Show change log?
    ----if (compareVersions(Globals.CursorTrail_Config.LastChangelogVersion, kAddonVersion) == 2) then  -- Is addon version newer?
    ----    CursorTrail_ShowChangelog()
    ----    Globals.CursorTrail_Config.LastChangelogVersion = kAddonVersion
    ----end

    -- New features notification.
    Globals.CursorTrail_Config.NewFeaturesSeen = Globals.CursorTrail_Config.NewFeaturesSeen or {}
    local newFeaturesCount = 0
    for _, pt in pairs(kNewFeatures) do
        local newFeatureName = pt.relativeTo
        ----print("Addon_Initialize(), newFeatureName:", newFeatureName)
        if not Globals.CursorTrail_Config.NewFeaturesSeen[newFeatureName] then
            newFeaturesCount = newFeaturesCount + 1
        end
    end
    if (newFeaturesCount > 0) then printNewFeaturesMsg(true) end

    -------------------
    -- Player Settings
    -------------------
    if (kAlwaysUseDefaults == true) then
        PlayerConfig_SetDefaults()
    elseif (not PlayerConfig) then
        PlayerConfig_Load()
    end

    -- Initialize addon.
    CursorTrail_Load()
    CursorTrail_ON()
end

-------------------------------------------------------------------------------
function isCursorTrailOff()
    if (EventFrame:GetScript("OnUpdate") == nil) then return true end
    return false
end

-------------------------------------------------------------------------------
function CursorTrail_ON(bPrintMsg)
    if isCursorTrailOff() then  -- Prevents chaining multiple calls to our handler.
        ----print(kAddonName..": Setting EventFrame's OnUpdate script.")
        EventFrame:SetScript("OnUpdate", CursorTrail_OnUpdate)
    end
    if bPrintMsg then printMsg("鼠之軌跡"..": "..ORANGE.."開啟") end
end

-------------------------------------------------------------------------------
function CursorTrail_OFF()
    if OptionsFrame:IsShown() then OptionsFrame:Hide() end
    EventFrame:SetScript("OnUpdate", nil)
end

-------------------------------------------------------------------------------
function printNewFeaturesMsg(bIncludeInstructions)
    local msg = kAddonAlertHeading..GREEN.."NEW FEATURES available!"..kTextColorDefault
    if bIncludeInstructions then
        msg = msg.."  (Type either "..WHITE.."/ct|r or "..WHITE.."/"..kAddonName.."|r to see them.)"
    end
    printMsg(msg)
end

-------------------------------------------------------------------------------
function PlayerConfig_SetDefaults()
    PlayerConfig = {}  -- Must clear all existing fields first!
    PlayerConfig = CopyTable(kDefaultConfig)
    PlayerConfig_Save()
end

-------------------------------------------------------------------------------
function PlayerConfig_Save()
    assert(PlayerConfig)
    Globals.CursorTrail_PlayerConfig = PlayerConfig
end

-------------------------------------------------------------------------------
function PlayerConfig_Load()
    PlayerConfig = Globals.CursorTrail_PlayerConfig
    if isEmpty(PlayerConfig) then PlayerConfig_SetDefaults() end
    PlayerConfig_Validate()
end

-------------------------------------------------------------------------------
function PlayerConfig_Validate()
    -- Update stored model path (string) to a numeric ID.
    if ( not PlayerConfig.ModelID or not tonumber(PlayerConfig.ModelID) ) then
        PlayerConfig.ModelID = kDefaultModelID
    end

    -- Clear obsolete fields.
    if (PlayerConfig.BaseScale ~= nil) then
        PlayerConfig.BaseScale = nil
        PlayerConfig.BaseOfsX = nil
        PlayerConfig.BaseOfsY = nil
        PlayerConfig.BaseStepX = nil
        PlayerConfig.BaseStepY = nil
    end
    PlayerConfig.Version = nil

    -- Validate fields.
    PlayerConfig.UserScale = PlayerConfig.UserScale or 1.0
    PlayerConfig.UserAlpha = PlayerConfig.UserAlpha or 1.0
    PlayerConfig.UserShadowAlpha = PlayerConfig.UserShadowAlpha or 0.0
    PlayerConfig.Strata = PlayerConfig.Strata or "HIGH"
    ----PlayerConfig.FadeOut = PlayerConfig.FadeOut or false
    PlayerConfig.ShapeColorR = PlayerConfig.ShapeColorR or 1.0
    PlayerConfig.ShapeColorG = PlayerConfig.ShapeColorG or 1.0
    PlayerConfig.ShapeColorB = PlayerConfig.ShapeColorB or 1.0
end

-------------------------------------------------------------------------------
function CursorTrail_Load(config)
    -- Handle nil parameter.
    if (not config) then
        if (not PlayerConfig) then PlayerConfig_Load() end
        config = PlayerConfig
    end
    config.UserScale = config.UserScale or 1

    -----------------
    -- LOAD SHADOW --
    -----------------
    if not ShadowTexture then
        Shadow_Create()
    end
    if (kShadowStrataMatchesMain == true) then
        ShadowFrame:SetFrameStrata(config.Strata)
    end
    ShadowTexture:SetAlpha(config.UserShadowAlpha)

    ----------------
    -- LOAD SHAPE --
    ----------------
    if not ShapeTexture then
        Shape_Create()
    end
    ShapeFrame:SetFrameStrata(config.Strata)
    Shape_SetTexture(config.ShapeFileName)
    ----Shape_SetColor()  -- Set texture's original color(s).
    Shape_SetColor(config.ShapeColorR, config.ShapeColorG, config.ShapeColorB)

    ----------------
    -- LOAD MODEL --
    ----------------
    if not CursorModel then
        ----assert(UnitAffectingCombat("player") ~= true)
        CursorModel = CreateFrame("PlayerModel", nil, kGameFrame)
        CursorModel:SetAllPoints()

        -- After the parent frame (UIParent) is unhidden, we must reload the cursor model to see it again.
        CursorModel:SetScript("OnHide", function(self)
                if (kGameFrame:IsShown() ~= true)  then
                    CursorModel.bReloadOnShow = true
                end
            end)
        CursorModel:SetScript("OnShow", function(self)
                if (CursorModel.bReloadOnShow == true) then
                    CursorTrail_Load()
                    CursorModel.bReloadOnShow = nil
                end
            end)
    end

    CursorModel_Init()
    CursorModel_SetModel(config.ModelID)
    CursorModel:SetCustomCamera(1) -- Very important! (Note: CursorModel:SetCamera(1) doesn't work here.)
    CursorTrail_ApplyModelSettings(config.UserScale,
                                   config.UserOfsX,
                                   config.UserOfsY,
                                   config.UserAlpha)
    CursorTrail_SetFadeOut(config.FadeOut)
    CursorModel:SetFrameStrata(config.Strata)
    CursorModel:SetFrameLevel(kFrameLevel+1)  -- +1 so model is drawn in front of the shadow texture.

    if (CursorModel.Constants.BaseFacing ~= nil) then
        CursorModel:SetFacing(CursorModel.Constants.BaseFacing)
    end

    ------------
    -- FINISH --
    ------------
    gShowOrHide = kShow
    if (PlayerConfig.UserShowOnlyInCombat == true
        and UnitAffectingCombat("player") ~= true
        ) then
        -- Player not in combat, so don't show the cursor.
        gShowOrHide = kHide
    end
end

-------------------------------------------------------------------------------
function CursorTrail_ApplyModelSettings(userScale, userOfsX, userOfsY, userAlpha)
-- This function is for changing values that do not require recreating the model object.
-- It also forces the displayed model to refresh immediately.
-- It does not update PlayerConfig.
-- (Note: This single function was written instead of multiple separate functions for fastest performance.)

    ----print("userScale="..(userScale or "NIL")..", userOfs=("..(userOfsX or "NIL")..", "..(userOfsY or "NIL")..")")
    assert(CursorModel.Constants)

    -- Validate parameters.
    if (userScale == nil or userScale <= 0) then
        userScale = PlayerConfig.UserScale
    end
    userOfsX = userOfsX or PlayerConfig.UserOfsX
    userOfsY = userOfsY or PlayerConfig.UserOfsY
    if (userAlpha == nil or userAlpha <= 0) then
        userAlpha = PlayerConfig.UserAlpha or 1.0
    end

    -- Compute scale factor.
    local mult = kBaseMult * ScreenHypotenuse
    local baseScale = CursorModel.Constants.BaseScale
    local finalScale = userScale * baseScale
    ---->>> DIDN'T HELP.  CHANGING UI SCALE ALSO CHANGES THE ScaleMin VALUE.  WAS UNABLE TO DETERMINE CORRECT VALUE.
    ----if (CursorModel.Constants.ScaleMin and finalScale < CursorModel.Constants.ScaleMin) then
    ----    finalScale = CursorModel.Constants.ScaleMin
    ----end

    -- UPDATE MODEL --
    CursorModel:SetScale(finalScale)
    CursorModel:SetAlpha(userAlpha)
    ----print("CursorModel:GetEffectiveScale():", CursorModel:GetEffectiveScale()) -- i.e. finalScale * kGameFrame:GetEffectiveScale()
    ----if (CursorModel:GetEffectiveScale() < 0.0113) then printMsg("鼠之軌跡".." WARNING - Model scaled too small.  ") end

    -- Compute model step size and offset.
    CursorModel.StepX = CursorModel.Constants.BaseStepX * mult * finalScale
    CursorModel.StepY = CursorModel.Constants.BaseStepY * mult * finalScale
    CursorModel.OfsX = ((CursorModel.Constants.BaseOfsX * mult / baseScale) + userOfsX) / userScale
    CursorModel.OfsY = ((CursorModel.Constants.BaseOfsY * mult / baseScale) + userOfsY) / userScale

    -- UPDATE SHADOW --
    if ShadowTexture then
        -- Update shadow size based on current user scale.
        local shadowSize = kDefaultShadowSize * userScale
        ShadowTexture:SetSize(shadowSize, shadowSize)

        ----ShadowTexture.OfsX = (CursorModel.StepX * userOfsX)
        ----ShadowTexture.OfsY = (CursorModel.StepY * userOfsY)
    end

    -- UPDATE SHAPE --
    if ShapeTexture then
        ShapeTexture:SetAlpha(userAlpha)

        -- Update shape size based on current user scale.
        local shapeSize = kDefaultShapeSize * userScale
        ShapeTexture:SetSize(shapeSize, shapeSize)
    end

    gPreviousX = nil  -- Forces cursor FX to refresh during the next OnUpdate().
end

-------------------------------------------------------------------------------
function CursorTrail_Show()
    CursorModel_Show()
    if ShadowTexture then
        ShadowTexture:Show()
    end
    if ShapeTexture then
        ShapeTexture:Show()
    end

    gShowOrHide = nil  -- Reset.
end

-------------------------------------------------------------------------------
function CursorTrail_Hide()
    CursorModel_Hide()
    if ShadowTexture then
        ShadowTexture:Hide()
    end
    if ShapeTexture then
        ShapeTexture:Hide()
    end
    gShowOrHide = nil  -- Reset.
end

-------------------------------------------------------------------------------
function CursorTrail_SetFadeOut(bFadeOut)
    gMotionIntensity = 0
    PlayerConfig.FadeOut = bFadeOut or false
    if (PlayerConfig.FadeOut == true) then
        CursorModel:SetAlpha(0)
        if ShadowTexture then
            ShadowTexture:SetAlpha(0)
        end
        if ShapeTexture then
            ShapeTexture:SetAlpha(0)
        end
    else
        CursorModel:SetAlpha(PlayerConfig.UserAlpha)
        if ShadowTexture then
            ShadowTexture:SetAlpha(PlayerConfig.UserShadowAlpha)
        end
        if ShapeTexture then
            ShapeTexture:SetAlpha(PlayerConfig.UserAlpha)
        end
    end
end

-------------------------------------------------------------------------------
function CursorTrail_SetShapeSparkle(bSparkle)
    PlayerConfig.ShapeSparkle = bSparkle or false
    if not PlayerConfig.ShapeSparkle then
        Shape_SetColor(PlayerConfig.ShapeColorR, PlayerConfig.ShapeColorG, PlayerConfig.ShapeColorB)
    end
end

-------------------------------------------------------------------------------
function CursorModel_Init()
    if CursorModel then
        CursorModel:ClearModel()
        CursorModel:SetScale(1)  -- Very important!
        CursorModel:SetModelScale(1)
        CursorModel:SetPosition(0, 0, 0)  -- Very Important!
        CursorModel:SetAlpha(1.0)
        CursorModel:SetFacing(0)

        CursorModel.Constants = nil
        CursorModel.OfsX = nil
        CursorModel.OfsY = nil
        CursorModel.StepX = nil
        CursorModel.StepY = nil
        CursorModel.IsHidden = nil
    end
end

-------------------------------------------------------------------------------
function CursorModel_SetModel(modelID)
    modelID = modelID or kDefaultModelID
    CursorModel.Constants = CopyTable( kModelConstants[modelID] or kModelConstants[kDefaultModelID] )
    CursorModel.Constants.sortedID = modelID
    if (modelID > 0) then
        CursorModel:SetModel(modelID)
    end
    ----dbg("CursorModel:GetModelFileID() --> "..(CursorModel:GetModelFileID() or "nil"))
end

-------------------------------------------------------------------------------
function CursorModel_Show()
    -- Note: The normal Show() and Hide() don't work right (reason unknown).
    if not CursorModel then return end
    if (CursorModel.Constants.sortedID == 0) then -- Is model set to "None"?
        CursorModel_Hide()
    elseif (CursorModel.IsHidden ~= false) then -- Is model hidden?
        -- Unhide it.
        local alpha = PlayerConfig.UserAlpha or 1.0
        if (PlayerConfig.FadeOut == true) then alpha = alpha * gMotionIntensity end
        CursorModel:SetAlpha(alpha)
        CursorModel.IsHidden = false
    end
end

-------------------------------------------------------------------------------
function CursorModel_Hide()
    -- Note: The normal Show() and Hide() don't work right (reason unknown).
    if (CursorModel and CursorModel.IsHidden ~= true) then  -- Is model shown?
        -- Hide it.
        CursorModel:SetAlpha(0)
        CursorModel.IsHidden = true
        ----gMotionIntensity = 0
    end
end

-------------------------------------------------------------------------------
function Shadow_Create()
    if not ShadowFrame then
        ShadowFrame = CreateFrame("Frame", nil, kGameFrame)
        ShadowFrame:SetFrameStrata("BACKGROUND")
        ShadowFrame:SetFrameLevel(kFrameLevel)
        ShadowTexture = ShadowFrame:CreateTexture()
        ShadowTexture:SetBlendMode("ALPHAKEY")
        ShadowTexture:SetTexture([[Interface\GLUES\Models\UI_Alliance\gradient5Circle]])
        ----ShadowTexture:SetTexture([[Interface\GLUES\Models\UI_Draenei\GenericGlow64]])
        ----ShadowTexture:SetColorTexture(1,1,1,1)  DIDN'T WORK!
        ----ShadowTexture:SetVertexColor(1,1,1,1)  DIDN'T WORK!  (Only works for non-black textures.)
    end
end

-------------------------------------------------------------------------------
function Shape_Create()
    if not ShapeFrame then
        ShapeFrame = CreateFrame("Frame", nil, kGameFrame)
        ShapeFrame:SetFrameStrata("HIGH")
        ShapeFrame:SetFrameLevel(kFrameLevel+2)  -- +2 so shape is drawn in front of the model and shadow.
        ShapeTexture = ShapeFrame:CreateTexture()
        ----ShapeTexture:SetBlendMode("ALPHAKEY")
    end
end

-------------------------------------------------------------------------------
function Shape_SetTexture(shapeFileName)
    if ShapeTexture then
        if (shapeFileName == kStr_None) then
            ShapeTexture:SetTexture(nil)  -- Clear current texture.
        else
            ShapeTexture:SetTexture(shapeFileName)
        end
    end
end

-------------------------------------------------------------------------------
function Shape_SetColor(r, g, b, a)  -- Pass in nothing to use the texture's original color(s).
    if (not r and not g and not b and not a) then a = 1 end
    ShapeTexture:SetVertexColor(r or 1, g or 1, b or 1, a)  -- RGBa
end

-------------------------------------------------------------------------------
function unskew(inX, inY, inHorizontalSlope, topMult, bottomMult) -- Compensates for perimeter skewing built into some models.
    local x, y = inX, inY
    local dx = inX - ScreenMidX  -- Horizontal delta from center of screen.
    local dy = inY - ScreenMidY  -- Vertical delta from center of screen.

    -- Initialize skew factors for sides of screen depending on if cursor is above or below middle of screen.
    topMult = topMult or 0.985
    bottomMult = bottomMult or 1.105

    -- Multiply X coord by a variable factor based on the Y coord.
    local vertRange = topMult - bottomMult
    local multX = bottomMult + (vertRange*inY/ScreenH)
    x = ScreenMidX + (dx * multX)

    -- Multiply Y coord by a variable factor based on whether the Y coord is in the top or bottom half of the screen.
    if (dy < 0) then
        -- Bottom half of screen.
        y = ScreenMidY + (dy * 1.11)
        ----if (dy > -ScreenFourthH) then DebugText("Bottom 1") else DebugText("Bottom 2") end
        if (dy > -ScreenFourthH) then
            y = ScreenMidY + (dy * kScreenBottomFourthMult)
        else
            ----y = ScreenMidY + ((-ScreenFourthH * kScreenBottomFourthMult) + ((dy+ScreenFourthH) * 1.138))
            ----y = ScreenMidY + ((-ScreenFourthH * kScreenBottomFourthMult) + ((dy+ScreenFourthH) * kScreenBottomFourthMult * 1.0566))
            ----y = ScreenMidY + ((-ScreenFourthH + ((dy+ScreenFourthH) * 1.0566)) * kScreenBottomFourthMult)
            y = ScreenMidY + ((((dy+ScreenFourthH) * 1.0566) - ScreenFourthH) * kScreenBottomFourthMult)
        end
    else
        -- Top half of screen.
        y = ScreenMidY + (dy * 0.99)
        ----if (dy < ScreenFourthH) then DebugText("Top 1") else DebugText("Top 2") end
        if (dy < ScreenFourthH) then
            y = ScreenMidY + (dy * kScreenTopFourthMult)
        else
            ----y = ScreenMidY + ((ScreenFourthH * kScreenTopFourthMult) + ((dy-ScreenFourthH) * 0.966))
            ----y = ScreenMidY + ((ScreenFourthH * kScreenTopFourthMult) + ((dy-ScreenFourthH) * kScreenTopFourthMult * 0.9517))
            ----y = ScreenMidY + ((ScreenFourthH + ((dy-ScreenFourthH) * 0.9517)) * kScreenTopFourthMult)
            y = ScreenMidY + ((((dy-ScreenFourthH) * 0.9517) + ScreenFourthH) * kScreenTopFourthMult)
        end
    end

    -- Adjust the Y coord by a dynamic offset based on the X coord.
    y = y - (inHorizontalSlope * dx / ScreenMidX)
    ----x = x - (inVerticalSlope * dy / ScreenMidY)

    return x, y
end

-------------------------------------------------------------------------------
function Profiles_List(profileName)
    local names = {}
    local index
    for profileName, _ in pairs(Globals.CursorTrail_Config.Profiles) do
        local index = #names + 1
        names[index] = profileName
    end
    table.sort(names)

    printMsg("鼠之軌跡".." 設定檔:")
    if (#names == 0) then
        printMsg("    (無)")
    else
        for _, profileName in pairs(names) do
            printMsg(ORANGE.."    "..profileName)
        end
    end
end

-------------------------------------------------------------------------------
function Profiles_Load(profileName)
    if (profileName == nil or profileName == "") then
        printMsg("鼠之軌跡"..": 錯誤 - 沒有指定設定檔名稱。")
    elseif isEmpty(Globals.CursorTrail_Config.Profiles[profileName]) then
        printMsg("鼠之軌跡"..": 錯誤 - '"..ORANGE..profileName.."|r' 不存在。")
    else
        if (OptionsFrame and OptionsFrame:IsShown()) then OptionsFrame:Hide() end
        PlayerConfig = CopyTable( Globals.CursorTrail_Config.Profiles[profileName] )
        PlayerConfig_Validate()
        CursorTrail_Load()
        CursorTrail_ON()
        printMsg("鼠之軌跡"..": 已載入 '"..ORANGE..profileName.."|r'。")
    end
end

-------------------------------------------------------------------------------
function Profiles_Save(profileName)
    if (profileName == nil or profileName == "") then
        printMsg("鼠之軌跡"..": 錯誤 - 沒有指定設定檔名稱。")
    else
        PlayerConfig_Validate()
        Globals.CursorTrail_Config.Profiles[profileName] = CopyTable(PlayerConfig)
        printMsg("鼠之軌跡"..": 已儲存 '"..ORANGE..profileName.."|r'。")
    end
end

-------------------------------------------------------------------------------
function Profiles_Delete(profileName)
    if (profileName == nil or profileName == "") then
        printMsg("鼠之軌跡"..": 錯誤 - 沒有指定設定檔名稱。")
    elseif isEmpty(Globals.CursorTrail_Config.Profiles[profileName]) then
        printMsg("鼠之軌跡"..": 錯誤 - '"..ORANGE..profileName.."|r' 不存在。")
    else
        Globals.CursorTrail_Config.Profiles[profileName] = nil
        printMsg("鼠之軌跡"..": 已刪除 '"..ORANGE..profileName.."|r'。")
    end
end

--- End of File ---