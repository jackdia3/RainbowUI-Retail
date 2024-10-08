
local addonName, addon = ...

local L = {}
L["All bugs"] = "All bugs"
L["All stored bugs have been exterminated painfully."] = "All stored bugs have been exterminated painfully."
L["altWipeDesc"] = "Allows an alt-click on the minimap icon to wipe all stored bugs."
L["autoDesc"] = "Makes the BugSack open automatically when an error is encountered, but not while you are in combat."
L["Auto popup"] = "Auto popup"
L.minimapHint = "|cffeda55fClick|r to open BugSack with the last bug. |cffeda55fShift-Click|r to reload the user interface. |cffeda55fRight-Click|r to open options."
L["|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"] = "|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"
L["chatFrameDesc"] = "Prints a reminder to the chat frame when an error is encountered. Doesn't print the whole error, just a reminder!"
L["Chatframe output"] = "Chatframe output"
L["Current session"] = "Current session"
L["%d bugs have been sent to %s. He must have BugSack to be able to examine them."] = "%d bugs have been sent to %s. He must have BugSack to be able to examine them."
L["Failure to deserialize incoming data from %s."] = "Failure to deserialize incoming data from %s."
L["Filter"] = "Filter"
L["Filter addon mistakes"] = "Filter addon mistakes"
L["filterDesc"] = "Whether BugSack should treat ADDON_ACTION_BLOCKED and ADDON_ACTION_FORBIDDEN events as bugs or not. If that doesn't make sense, just ignore this option."
L["Font size"] = "Font size"
L["Large"] = "Large"
L["Limit"] = "Limit"
L["Local (%s)"] = "Local (%s)"
L["Medium"] = "Medium"
L["minimapDesc"] = "Shows the BugSack icon around your minimap."
L["Minimap icon"] = "Minimap icon"
L["Minimap icon alt-click wipe"] = "Minimap icon alt-click wipe"
L["Mute"] = "Mute"
L["muteDesc"] = "Prevents BugSack from playing the any sound when a bug is detected, no matter what you select in the dropdown below."
L["Next >"] = "Next >"
L["Player needs to be a valid name."] = "Player needs to be a valid name."
L["< Previous"] = "< Previous"
L["Previous session"] = "Previous session"
L["saveDesc"] = "Saves the bugs in the database. If this is off, bugs will not persist in the sack from session to session."
L["Save errors"] = "Save errors"
L["Send"] = "Send"
L["Send all bugs from the currently viewed session (%d) in the sack to the player specified below."] = "Send all bugs from the currently viewed session (%d) in the sack to the player specified below."
L["Send bugs"] = "Send bugs"
L["Sent by %s (%s)"] = "Sent by %s (%s)"
L["Small"] = "Small"
L["Sound"] = "Sound"
L["There's a bug in your soup!"] = "There's a bug in your soup!"
L["Throttle at excessive amount"] = "Throttle at excessive amount"
L["throttleDesc"] = "Sometimes addons can generate hundreds of bugs per second, which can lock up the game. Enabling this option will throttle bug grabbing, preventing lockup when this happens."
L["Today"] = "Today"
L["Toggle the minimap icon."] = "Toggle the minimap icon."
L["Quick tips"] = "Quick tips"
L["quickTipsDesc"] = "|cff44ff44Double-click|r to filter bug reports. After you are done with the search results, return to the full sack by selecting a tab at the bottom. |cff44ff44Left-click|r and drag to move the window. |cff44ff44Right-click|r to close the sack and open the interface options for BugSack."
L["wipeDesc"] = "Exterminates all stored bugs from the database."
L["Wipe saved bugs"] = "Wipe saved bugs"
L["X-Large"] = "X-Large"
L["You have no bugs, yay!"] = "You have no bugs, yay!"
L["You've received %d bugs from %s."] = "You've received %d bugs from %s."
L.useMaster = "Use 'Master' sound channel"
L.useMasterDesc = "Play the chosen error sound over the 'Master' sound channel instead of the default one."
L.addonCompartment = "Addon compartment icon"
L.addonCompartment_desc = "Creates a menu entry in the 'Addon Compartment' for BugSack."

L["BugSack"] = "BugSack"
local locale = GetLocale()
if locale == "zhCN" then
	L["%d bugs have been sent to %s. He must have BugSack to be able to examine them."] = "%d个错误已经发送给%s。他必须安装 BugSack 插件才能查看错误信息。"
	L.minimapHint = "|cffeda55f点击|r打开 BugSack 及最后一错误信息。|cffeda55fShift-点击|r重新加载用户界面。|cffeda55f右击|r 打开选项。"
	L["|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"] = "|cffff4411BugSack 需要 |r|cff44ff44!BugGrabber|r|cffff4411 插件, 你可以从相同地方下载 BugSack。猎虫愉快！|r"
	L["< Previous"] = "<前一个"
	L["All bugs"] = "全部错误"
	L["All stored bugs have been exterminated painfully."] = "所有已保存的错误已经被清除。"
	L["altWipeDesc"] = "允许 ALT-点击小地图按钮清除所有存储的错误。"
	L["Auto popup"] = "自动弹出"
	L["autoDesc"] = "遇到错误是否自动弹出 BugSack 窗口。"
	L["Chatframe output"] = "聊天栏输出"
	L["chatFrameDesc"] = "当发生错误的时，在聊天栏中显示。不是整个错误，只是一个提醒！"
	L["Current session"] = "目前会话"
	L["Failure to deserialize incoming data from %s."] = "反序列化失败输入数据来自 %s。"
	L["Filter"] = "过滤"
	L["Filter addon mistakes"] = "过滤插件错误"
	L["filterDesc"] = "不论 BugSack 可能对 ADDON_ACTION_BLOCKED 和 ADDON_ACTION_FORBIDDEN 事件认为错误与否。如果这样做没有意义，忽略这个选项。"
	L["Font size"] = "字体尺寸"
	L["Large"] = "大"
	L["Limit"] = "限制"
	L["Local (%s)"] = "本地（%s）"
	L["Medium"] = "中"
	L["Minimap icon"] = "小地图按钮"
	L["Minimap icon alt-click wipe"] = "小地图按钮 ALT-点击清除"
	L["minimapDesc"] = "在小地图周围显示 BugSack 图标。"
	L["Mute"] = "静音"
	L["muteDesc"] = "当一个错误被检测到时，阻止 BugSack 播放任何音效，无视下面的下拉列表中的选择。"
	L["Next >"] = "下一个>"
	L["Player needs to be a valid name."] = "玩家需要有一个有效的名字。"
	L["Previous session"] = "上一次登录会话"
	L["Save errors"] = "保存错误"
	L["saveDesc"] = "将错误保存在数据库中。如果关闭此选项，错误将不会在不同会话期间持续存在于数据库中。"
	L["Send"] = "发送"
	L["Send all bugs from the currently viewed session (%d) in the sack to the player specified below."] = "发送当前查看会话（%d）所有错误给下列玩家。"
	L["Send bugs"] = "发送错误"
	L["Sent by %s (%s)"] = "%s发送（%s）"
	L["Small"] = "小"
	L["Sound"] = "音效"
	L["There's a bug in your soup!"] = "这里有一个恶心的错误！"
	L["Throttle at excessive amount"] = "过度错误数量过滤"
	L["throttleDesc"] = "一些插件可能每秒生成成百个错误，从而影响了正常游戏。启用此选项，将会截流错误，防止发生影响正常游戏。"
	L["Today"] = "今日"
	L["Toggle the minimap icon."] = "切换小地图按钮。"
	L["Quick tips"] = "快速提示"
	L["quickTipsDesc"] = "|cff44ff44双击|r 过滤错误报告。完成搜索结果后，通过选择底部的选项卡返回完整汇总。|cff44ff44点击|r 并拖动窗口。|cff44ff44右击|r 关闭汇总并打开 BugSack 界面选项。"
	L["Wipe saved bugs"] = "清除已保存错误"
	L["wipeDesc"] = "清除数据库中所有已保存错误。"
	L["X-Large"] = "超大"
	L["You have no bugs, yay!"] = "没有发生错误。\\^o^/"
	L["You've received %d bugs from %s."] = "你已从%s接收到%d个错误。"
	L.useMaster = "使用“主”声道"
	L.useMasterDesc = "通过“主”声道而不是默认声道播放所选的错误音效。"
	L.addonCompartment = "插件抽屉图标"
	L.addonCompartment_desc = "在“插件抽屉”中为 BugSack 创建一个菜单。"
elseif locale == "zhTW" then
	L["%d bugs have been sent to %s. He must have BugSack to be able to examine them."] = "%d 個錯誤已經傳送給 %s。他必須使用 BugSack 插件查看錯誤訊息。"
	L.minimapHint = "|cffeda55f左鍵:|r 顯示最新的錯誤訊息。\n|cffeda55fShift+左鍵:|r 重新載入介面。\n|cffeda55f右鍵:|r 設定選項。"
	L["|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"] = "|cffff4411錯誤訊息袋需要|r|cff44ff44 !BugGrabber |r|cffff4411插件，可以從下載 BugSack 相同的地方來下載。獵蟲愉快!|r"
	L["< Previous"] = "< 上一個"
	L["All bugs"] = "所有錯誤"
	L["All stored bugs have been exterminated painfully."] = "所有保留的錯誤都已清除。"
	L["altWipeDesc"] = "使用 Alt+左鍵 點一下小地圖按鈕來清空所有保留的錯誤訊息。"
	L["Auto popup"] = "自動彈出"
	L["autoDesc"] = "發生錯誤時自動打開錯誤訊息袋，但是在戰鬥中不要打開。"
	L["Chatframe output"] = "聊天視窗顯示訊息"
	L["chatFrameDesc"] = "當發生錯誤時輸出提醒到聊天框架。不是輸出所有錯誤訊息，只是一個提醒!"
	L["Current session"] = "這次"
	L["Failure to deserialize incoming data from %s."] = "從%s傳來的資料反序列化失敗。"
	L["Filter"] = "過濾"
	L["Filter addon mistakes"] = "過濾插件錯誤"
	L["filterDesc"] = "不論錯誤訊息袋可能對 ADDON_ACTION_BLOCKED 和 ADDON_ACTION_FORBIDDEN 事件認為是錯誤與否。如果這樣做沒有意義，只要忽略這個設定。"
	L["Font size"] = "字型大小"
	L["Large"] = "大"
	L["Limit"] = "限制"
	L["Local (%s)"] = "本地 (%s)"
	L["Medium"] = "中"
	L["Minimap icon"] = "小地圖按鈕"
	L["Minimap icon alt-click wipe"] = "Alt+左鍵點一下小地圖按鈕來清空"
	L["minimapDesc"] = "在小地圖四周顯示錯誤訊息袋的圖示。"
	L["Mute"] = "靜音"
	L["muteDesc"] = "預防錯誤訊息袋發現有錯誤時播放任何聲音，不管你在下列選項選了什麼。"
	L["Next >"] = "下一個 >"
	L["Player needs to be a valid name."] = "玩家需要有一個有效的名字。"
	L["Previous session"] = "上一次"
	L["Save errors"] = "保留錯誤"
	L["saveDesc"] = "將錯誤保留在資料庫。如果關閉此設定，將不會保留每一次的錯誤。"
	L["Send"] = "傳送"
	L["Send all bugs from the currently viewed session (%d) in the sack to the player specified below."] = "傳送這次(%d)所有錯誤給以下玩家。"
	L["Send bugs"] = "傳送錯誤"
	L["Sent by %s (%s)"] = "由%s傳送(%s)"
	L["Small"] = "小"
	L["Sound"] = "音效"
	L["There's a bug in your soup!"] = "有東西發生錯誤，請查看錯誤訊息袋!"
	L["Throttle at excessive amount"] = "調節錯誤數量"
	L["throttleDesc"] = "有時插件可能每秒產生上百個錯誤，進而影響遊戲。啟用此設定，將會扼殺錯誤，防止發生影響遊戲。"
	L["Today"] = "今天"
	L["Toggle the minimap icon."] = "切換顯示小地圖按鈕。"
	L["Quick tips"] = "快速提示"
	L["quickTipsDesc"] = "|cff44ff44點兩下|r來過濾錯誤報告。使用完搜尋結果後，選擇底部的標籤頁返回全部的錯誤訊息。|cff44ff44左鍵|r拖曳來移動視窗。|cff44ff44右鍵|r關閉錯誤訊息視窗，並且打開設定選項。"
	L["Wipe saved bugs"] = "清空保留的錯誤"
	L["wipeDesc"] = "清除資料庫中所有保留的錯誤。"
	L["X-Large"] = "超大"
	L["You have no bugs, yay!"] = "你沒有發生錯誤。\\^o^//"
	L["You've received %d bugs from %s."] = "從%s收到%d個錯誤。"
	L.useMaster = "使用 '主音量' 聲音頻道"
	L.useMasterDesc = "透過 '主音量' 聲音頻道播放選擇的錯誤音效，而不是預設的聲音頻道。"
	L.addonCompartment = "插件選單圖示"
	L.addonCompartment_desc = "在 '插件選單' 建立錯誤訊息袋 BugSack 的選單項目。"
	
	L["BugSack"] = "錯誤訊息"
end

addon.L = L
