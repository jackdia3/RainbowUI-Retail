-- Please use the Localization App on CurseForge to Update this
-- https://legacy.curseforge.com/wow/addons/mythicpluspullreestimated/localization
local name, _ = ...

local L = LibStub("AceLocale-3.0"):NewLocale(name, "zhTW")
if not L then return end

-- MythicPlusPullReEstimated
L["A long way of writing 100%%."] = "一個長遠的路來寫入到100%%。"
L["Adds percentage info to the unit tooltip"] = "在浮動提示資訊顯示進度百分比"
L["Adds the % info to the enemy nameplates"] = "在敵方名條顯示進度百分比"
L["Allows addons and WAs that use MythicDungeonTools for % info to work with this addon instead."] = "允許使用 MythicDungeonTools 來取得 % 資訊的插件或 WA 改用本插件。"
L["Are you sure you want to reset the NPC data to the defaults?"] = "確定要重置 NPC 資料嗎？這會把進度分數重設為預設值。"
L["Are you sure you want to wipe all data?"] = "確定要清空所有資料嗎？"
L["Color of the text on the enemy nameplates"] = "敵方名條上的進度文字顏色"
L["CTRL-C to copy"] = "Ctrl+C 複製"
L["Current pull:"] = "當前進度："
L["Debug"] = "除錯"
--[[Translation missing --]]
L["Debug Criteria Events"] = "Debug Criteria Events"
L["Debug New NPC Scores"] = "除錯新 NPC 分數"
L["Developer Options"] = "開發者選項"
L["Disabled when MythicDungeonTools is loaded"] = "載入 MythicDungeonTools 時停用。"
L["Display a frame with current pull information"] = "在畫面上顯示一個計算當前拉怪進度的框架。"
L["Enable Current Pull frame"] = "啟用當前進度框架"
L["Enable MDT Emulation"] = "啟用 MDT 模擬"
L["Enable Nameplate Text"] = "啟用名條文字"
L["Enable Tooltip"] = "啟用浮動提示資訊"
L["Enable/Disable debug prints"] = "啟用/停用除錯資訊"
--[[Translation missing --]]
L["Enable/Disable debug prints for criteria events, ignores the Debug Print setting"] = "Enable/Disable debug prints for criteria events, ignores the Debug Print setting"
L["Enable/Disable debug prints for new NPC scores"] = "啟用/停用輸出新 NPC 分數的除錯資訊"
L["Enable/Disable Simulation Mode"] = "啟用/停用模擬模式"
L["Enable/Disable the addon"] = "啟用/停用插件"
L["Enabled"] = "啟用"
L["Experimental"] = "實驗性"
L["Export NPC data"] = "匯出 NPC 資料"
L["Export only data that is different from the default values"] = "只匯出和預設值不同的資料"
L["Export updated NPC data"] = "匯出已更新的 NPC 資料"
L["Horizontal offset ( <-> )"] = "水平偏移 ( <-> )"
L["Horizontal offset of the nameplate text"] = "名條文字的水平偏移"
L["Include Count"] = "包含分數"
L["Include the raw count value in the tooltip, as well as the percentage"] = "在浮動提示資訊中同時顯示原始進度分數和進度百分比"
L["Lock frame"] = "鎖定框架"
L["Lock the frame in place"] = "鎖定框架的位置"
L["M+Progress:"] = "小怪進度:"
L["Main Options"] = "主要選項"
L["MDT Emulation"] = "MDT 模擬"
L["MPP attempted to get missing setting:"] = "MPP 試圖獲取缺失的設定值："
L["MPP attempted to set missing setting:"] = "MPP 試圖設定缺失的設定值："
L["MPP String Uninitialized."] = "MPP 字串未初始化。"
L["Mythic Plus Progress"] = "M+ 小怪%"
L["Mythic Plus Progress tracker"] = "M+ 小怪% 追蹤"
L["Nameplate"] = "名條"
L["Nameplate Text Color"] = "名條文字顏色"
L["No Progress."] = "沒有進度。"
L["No record."] = "沒有記錄。"
L["No recorded mobs pulled or nameplates inactive."] = "沒有拉怪或沒有開啟名條。"
L["NPC data patch version: %s, build %d (ts %d)"] = "NPC 資料版本: %s, build %d (ts %d)"
L["Only in combat"] = "只在戰鬥中顯示"
L["Only show the frame when you are in combat"] = "只在戰鬥中顯示進度預估框架"
L["Opens a popup which allows copying the data"] = "打開彈出視窗以便複製資料"
L["Pull Estimate frame"] = "拉怪進度預估框架"
L["Reset NPC data"] = "重置 NPC 資料"
L["Reset position"] = "重置位置"
L["Reset position of Current Pull frame to the default"] = "將當前進度框架重置回預設位置"
L["Reset Settings to default"] = "重置設定成預設值"
L["Reset the NPC data to the default values"] = "將 NPC 資料恢復成預設值"
L["Running first time setup. This should only happen once. Enjoy! ;)"] = "正在執行第一次設定，這個動作只會執行一次，請好好享用此插件！ :)"
L["Simulated number of 'points' currently earned"] = "模擬目前獲得的「分數」"
L["Simulated number of 'points' required to complete the run"] = "模擬通關副本需要的「分數」"
L["Simulation Current Points"] = "模擬當前分數"
L["Simulation Mode"] = "模擬模式"
L["Simulation Required Points"] = "模擬所需分數"
L["Text Format"] = "文字格式"
L["The count of mobs pulled."] = "拉怪計數。"
L["The current count of mobs killed."] = "目前殺怪計數。"
L["The current percentage of mobs killed."] = "目前殺怪百分比。"
L["The estimated count after all pulled mobs are killed."] = "全部拉怪擊殺後的估計數。"
L["The estimated percentage after all pulled mobs are killed."] = "全部拉怪擊殺後的估計百分比。"
L["The following placeholders are available:"] = "以下佔位符可用："
L["The percentage of mobs pulled."] = "拉怪的百分比。"
--[[Translation missing --]]
L["The percentage the mob gives."] = "The percentage the mob gives."
--[[Translation missing --]]
L["The raw count the mob gives."] = "The raw count the mob gives."
L["The required count of mobs to reach 100%%."] = "所需的小怪數量達到100%%。"
--[[Translation missing --]]
L["The text format of the nameplate text. Use placeholders to display information."] = "The text format of the nameplate text. Use placeholders to display information."
L["The text format of the pull frame. Use placeholders to display information."] = "拉怪框架文字的格式。使用佔位符來顯示資訊。"
L["These options are experimental and may not work as intended."] = "下列選項是實驗性功能，可能無法按預期方式運作。"
L["Tooltip"] = "浮動提示資訊"
L["Version:"] = "版本："
L["Vertical Offset ( | )"] = "垂直偏移 ( | )"
L["Vertical offset of the nameplate text"] = "名條文字的垂直偏移"
L["Wipe all data"] = "清空所有資料"
L["Wipe All Data"] = "清空所有資料"

