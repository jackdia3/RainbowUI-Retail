BountifulDelvesHelper = BountifulDelvesHelper or {}

SLASH_DELVES1 = "/delves"

FONT_SMALL = GameFontHighlightLarge:GetFont()
FONT_MEDIUM = GameFontHighlightLarge:GetFont()
FONT_LARGE = GameFontHighlightLarge:GetFont()

areaIDs = {
    [2248] = "多恩島",
    [2215] = "聖落之地",
    [2214] = "鳴響深淵",
    [2255] = "阿茲-卡罕特",
}

if not BountifulDelvesHelperDB then
    BountifulDelvesHelperDB = {
        highestDelveTier = nil,
    }
end

if not BountifulDelvesHelperIconDB then
    BountifulDelvesHelperIconDB = {
        minimapPos = 140,
        hide = false,
    }
end

waypoints = {
    -- "Earthcrawl Mines"
    [7787] = { ["zone"] = 2248, ["x"] = 38.6, ["y"] = 74.0 },
    -- "The Dread Pit"
    [7788] = { ["zone"] = 2214, ["x"] = 74.2, ["y"] = 37.3 },
    -- "The Sinkhole"
    [7783] = { ["zone"] = 2215, ["x"] = 50.6, ["y"] = 53.3 },
    -- "The Spiral Weave"
    [7790] = { ["zone"] = 2255, ["x"] = 45.0, ["y"] = 19.0 },
    -- "Fungal Folly"
    [7779] = { ["zone"] = 2248, ["x"] = 52.03, ["y"] = 65.77 },
    -- "Kriegval's Rest"
    [7781] = { ["zone"] = 2248, ["x"] = 62.19, ["y"] = 42.70 },
    --["The Waterworks"]
    [7782] = { ["zone"] = 2214, ["x"] = 46.42, ["y"] = 48.71 },
    -- "Nightfall Sanctum"
    [7785] = { ["zone"] = 2215, ["x"] = 34.32, ["y"] = 47.43 },
    -- "Mycomancer Cavern"
    [7780] = { ["zone"] = 2215, ["x"] = 71.3, ["y"] = 31.2 },
    -- "Skittering Breach"
    [7789] = { ["zone"] = 2215, ["x"] = 65.48, ["y"] = 61.74 },
    -- "The Underkeep"
    [7786] = { ["zone"] = 2255, ["x"] = 51.85, ["y"] = 88.30 },
    -- "Tak-Rethan Abyss"
    [7784] = { ["zone"] = 2255, ["x"] = 55.0, ["y"] = 73.92 },
    -- "Zekvir's Lair"
    -- [7875] = { ["zone"] = 2255, ["x"] = 32.74, ["y"] = 76.87 },
}

worldQuestsIDs = {
    ["82158"] = "特殊任務: 解救山貓",
    ["82414"] = "特殊任務: 一磅的治療",
    ["82355"] = "特殊任務: 激增的燼蜂",
    ["82531"] = "特殊任務: 從背面轟炸",
    ["83229"] = "特殊任務: 當深處攪拌時",
    ["82787"] = "特殊任務: 巨人的興起",
    ["81691"] = "特殊任務: 地底暗影",
    ["81649"] = "特殊任務: 泰坦復甦"
}

delveTiers = {
    { ["bountifulLootIlvl"] = 561, ["recommendedIlvl"] = 515 },
    { ["bountifulLootIlvl"] = 564, ["recommendedIlvl"] = 532 },
    { ["bountifulLootIlvl"] = 571, ["recommendedIlvl"] = 545 },
    { ["bountifulLootIlvl"] = 577, ["recommendedIlvl"] = 548 },
    { ["bountifulLootIlvl"] = 584, ["recommendedIlvl"] = 567 },
    { ["bountifulLootIlvl"] = 590, ["recommendedIlvl"] = 574 },
    { ["bountifulLootIlvl"] = 597, ["recommendedIlvl"] = 587 },
    { ["bountifulLootIlvl"] = 603, ["recommendedIlvl"] = 600 },
    { ["bountifulLootIlvl"] = 603, ["recommendedIlvl"] = 610 },
    { ["bountifulLootIlvl"] = 603, ["recommendedIlvl"] = 610 },
    { ["bountifulLootIlvl"] = 603, ["recommendedIlvl"] = 610 }
}

isFrameVisible = false
AceGUI = LibStub("AceGUI-3.0")
frame = {}

function showUI()
    Delves = {}

    for delvePoiID, delveConfig in pairs(waypoints) do
        local delve = C_AreaPoiInfo.GetAreaPOIInfo(delveConfig["zone"], delvePoiID)

        if delve ~= nil and delve["atlasName"] == "delves-bountiful" then
            local areaName = areaIDs[delveConfig["zone"]]
            Delves[delvePoiID] = { ["name"] = delve["name"], ["zone"] = areaName }
        end
    end

    local function openStartGroupFrame()
        if not PVEFrame:IsShown() then
            PVEFrame_ToggleFrame()
        end

        GroupFinderFrameGroupButton3:Click()
        LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 121, 0)
        LFGListFrame.CategorySelection.StartGroupButton:Click()

        LFGListFrame.EntryCreation.GroupDropdown:OpenMenu()

        --value = LFGListFrame.EntryCreation.ActivityDropdown
        --DevTools_Dump(value)

        --LFGListFrame.EntryCreation.Name.Instructions:SetText(delveName)
        --LFGListFrame.EntryCreation.Name.Instructions2.text = delveName
    end

    local function openFindGroupFrame()
        if not PVEFrame:IsShown() then
            PVEFrame_ToggleFrame()
        end

        GroupFinderFrameGroupButton3:Click()
        LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 121, 0)
        LFGListFrame.CategorySelection.FindGroupButton:Click()
    end

    local function DrawDelvesGroup(container)
        local count = 0
        for _ in pairs(Delves) do
            count = count + 1
        end
        if count == 0 then
            guiCreateNewline(container, 3)

            if UnitLevel("player") < 68 then
                local label = AceGUI:Create("Label")
                label:SetText(getColorText("FF7E40", "  探究在等級68時解鎖"))
                label:SetFont(GameFontHighlightLarge:GetFont())
                label:SetFullWidth(true)
                container:AddChild(label)
            else
                local label = AceGUI:Create("Label")
                label:SetText(getColorText("FF7E40", "  目前沒有可用的豐碩探究"))
                label:SetFont(GameFontHighlightLarge:GetFont())
                label:SetFullWidth(true)
                container:AddChild(label)
            end

        else
            guiCreateNewline(container, 2)

            local label = AceGUI:Create("Label")
            if BountifulDelvesHelperDB["highestDelveTier"] ~= nil then
                label:SetText("最高探究: " .. getColorText("40BC40", "Tier " .. BountifulDelvesHelperDB["highestDelveTier"]))
            end
            label:SetFont(GameFontHighlightMedium:GetFont())
            label:SetWidth(370)
            container:AddChild(label)

            local spacing = AceGUI:Create("Label")
            spacing:SetWidth(50)
            container:AddChild(spacing)

            --local eyeIcon = GetItemIcon(142454)
            --local label = AceGUI:Create("InteractiveLabel")
            --label:SetImage(eyeIcon)
            --label:SetText("")
            --label:SetImageSize(20,20)
            --container:AddChild(label)

            --local spacing = AceGUI:Create("Label")
            --spacing:SetWidth(1)
            --container:AddChild(spacing)

            local button = AceGUI:Create("Button")
            button:SetText("編組隊伍")
            button:SetWidth(105)
            button:SetCallback("OnClick", function()
                openStartGroupFrame()
            end)
            container:AddChild(button)

            local spacing = AceGUI:Create("Label")
            spacing:SetWidth(5)
            container:AddChild(spacing)

            if IsInGroup() and not UnitIsGroupLeader("player") then
                button:SetDisabled(true)
            end

            local button = AceGUI:Create("Button")
            button:SetText("搜尋預組")
            button:SetWidth(105)
            button:SetCallback("OnClick", function()
                openFindGroupFrame()
            end)
            container:AddChild(button)

            guiCreateNewline(container, 4)

            local label = AceGUI:Create("Label")
            label:SetText("探究")
            label:SetFont(GameFontHighlightSmall:GetFont())
            label:SetWidth(220)
            container:AddChild(label)

            local label = AceGUI:Create("Label")
            label:SetText("區域")
            label:SetFont(GameFontHighlightSmall:GetFont())
            label:SetWidth(120)
            container:AddChild(label)

            local label = AceGUI:Create("Label")
            label:SetText("")
            label:SetFont(GameFontHighlightSmall:GetFont())
            label:SetWidth(150)
            container:AddChild(label)

            local label = AceGUI:Create("Label")
            label:SetFullWidth(true)
            container:AddChild(label)

            for mapPoiID, delve in pairs(Delves) do
                cofferKeyIcon = GetItemIcon(224172)
                local label = AceGUI:Create("InteractiveLabel")
                label:SetImage(cofferKeyIcon)
                label:SetImageSize(18, 18)
                label:SetText("\124cffA335EE" .. delve["name"] .. "\124r")
                label:SetFont(GameFontHighlightMedium:GetFont())
                label:SetWidth(220)
                container:AddChild(label)

                local label = AceGUI:Create("Label")
                label:SetText(delve["zone"])
                label:SetFont(GameFontHighlightMedium:GetFont())
                label:SetWidth(120)
                container:AddChild(label)

                local button = AceGUI:Create("Button")
                button:SetText("地圖標記")
                button:SetWidth(150)
                button:SetCallback("OnClick", function()
                    setWaypoint(mapPoiID)
                end)
                container:AddChild(button)

                guiCreateNewline(container, 1)
            end
        end
    end

    local function DrawKeysGroup(container)
        guiCreateNewline(container, 2)

        currency = C_CurrencyInfo.GetCurrencyInfo(3028)
        cofferKeyIcon = GetItemIcon(224172)

        local text = AceGUI:Create("InteractiveLabel")
        text:SetImage(cofferKeyIcon)
        text:SetImageSize(25, 25)
        text:SetText("\124cffA335EE復原的寶庫鑰匙\124r: " .. currency.quantity)
        text:SetFullWidth(true)
        text:SetFont(GameFontHighlightLarge:GetFont())
        container:AddChild(text)

        cofferKeyShardsCount = C_Item.GetItemCount("寶庫鑰匙裂片")
        keysToCreateCount = math.floor(cofferKeyShardsCount / 100)

        local text = AceGUI:Create("Label")
        text:SetText("       +" ..
                keysToCreateCount .. " 鑰匙來自 " .. cofferKeyShardsCount .. " \124cff0070FF寶庫鑰匙裂片\124r")
        text:SetFullWidth(true)
        text:SetFont(GameFontHighlightMedium:GetFont())
        container:AddChild(text)

        guiCreateNewline(container, 5)

        radiantEchoCount = C_Item.GetItemCount(220520)
        radiantEchoIcon = GetItemIcon(220520)

        local text = AceGUI:Create("InteractiveLabel")
        text:SetImage(radiantEchoIcon)
        text:SetImageSize(25, 25)
        text:SetText("\124cffA335EE璀璨回音\124r: " .. radiantEchoCount)
        text:SetFullWidth(true)
        text:SetFont(GameFontHighlightLarge:GetFont())
        container:AddChild(text)

        guiCreateNewline(container, 2)

        --completedCount = 0
        --for questID, _ in pairs(worldQuestsIDs) do
        --    isCompleted = C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID)
        --    if isCompleted then
        --        completedCount = completedCount + 1
        --    end
        --end
        --
        --local text = AceGUI:Create("Label")
        --text:SetText("Special assignments: " .. completedCount .. "/4")
        --text:SetFullWidth(true)
        --text:SetFont(GameFontHighlightMedium:GetFont())
        --container:AddChild(text)
    end

    function DrawTiersOverviewGroup(container)
        guiCreateNewline(container, 3)
        --guiCreateLabel(container, FONT_MEDIUM, "Tier", 120)

        local label = AceGUI:Create("Label")
        if BountifulDelvesHelperDB["highestDelveTier"] ~= nil then
            label:SetText("最高探究: " .. getColorText("40BC40", "層級 " .. BountifulDelvesHelperDB["highestDelveTier"]))
        end
        label:SetFont(GameFontHighlightMedium:GetFont())
        label:SetWidth(370)
        container:AddChild(label)

        guiCreateNewline(container, 5)

        local label = AceGUI:Create("Label")
        label:SetText("層級")
        label:SetFont(GameFontHighlightMedium:GetFont())
        label:SetWidth(150)
        container:AddChild(label)

        for index = 1, 11 do
            local label = AceGUI:Create("Label")

            if index < 10 then
                label:SetText("  " .. index)
            else
                label:SetText(" " .. index)
            end

            label:SetFont(GameFontHighlightMedium:GetFont())
            label:SetWidth(40)
            container:AddChild(label)
        end

        guiCreateNewline(container)

        local label = AceGUI:Create("Label")
        label:SetText("建議裝等")
        label:SetFont(GameFontHighlightMedium:GetFont())
        label:SetWidth(150)
        container:AddChild(label)

        for _, tierDetails in pairs(delveTiers) do
            local label = AceGUI:Create("Label")
            label:SetText(tierDetails["recommendedIlvl"])
            label:SetFont(GameFontHighlightMedium:GetFont())
            label:SetWidth(40)
            container:AddChild(label)
        end

        guiCreateNewline(container)

        local label = AceGUI:Create("Label")
        label:SetText("豐碩拾取")
        label:SetFont(GameFontHighlightMedium:GetFont())
        label:SetWidth(150)
        container:AddChild(label)

        for _, tierDetails in pairs(delveTiers) do
            local label = AceGUI:Create("Label")
            local bountifulLoot = tierDetails["bountifulLootIlvl"]

            label:SetText(getGearColorText(bountifulLoot, bountifulLoot))

            label:SetFont(GameFontHighlightMedium:GetFont())
            label:SetWidth(40)
            container:AddChild(label)
        end

        guiCreateNewline(container)
    end

    local function SelectGroup(container, event, group)
        container:ReleaseChildren()
        if group == "tab1" then
            DrawDelvesGroup(container)
        elseif group == "tab2" then
            DrawKeysGroup(container)
        elseif group == "tab3" then
            DrawTiersOverviewGroup(container)
        end
    end

    local frame = AceGUI:Create("Frame")
    frame:EnableResize(false)
    frame:SetTitle("豐碩探究幫手")
    frame:SetStatusText("豐碩探究幫手 - v1.1.3")
    frame:SetCallback("OnClose", function(widget)
        isFrameVisible = false
    end)
    frame:SetHeight(400)
    frame:SetLayout("Fill")

    local tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    tab:SetTabs({ { text = "豐碩探究", value = "tab1" }, { text = "寶庫鑰匙", value = "tab2" }, { text = "層級總覽", value = "tab3" } })
    tab:SetCallback("OnGroupSelected", SelectGroup)
    tab:SelectTab("tab1")

    frame:AddChild(tab)

    _G["BountifulDelvesHelperGlobalFrame"] = frame.frame
    tinsert(UISpecialFrames, "BountifulDelvesHelperGlobalFrame")
end

function triggerFrame()
    if not isFrameVisible then
        showUI()
        isFrameVisible = true
    end
end

function BountifulDelvesHelper:ToggleMainFrame()
    triggerFrame()
end

SlashCmdList["DELVES"] = function(arg1)
    if arg1 == "hide" and BountifulDelvesHelperIconDB["hide"] == false or BountifulDelvesHelperIconDB["hide"] == nil then
        BountifulDelvesHelperIconDB["hide"] = true
        print("[Bountiful Delves Helper] 小地圖按鈕隱藏，使用 /reload 來套用效果。")
    elseif arg1 == "show" and BountifulDelvesHelperIconDB["hide"] == true then
        BountifulDelvesHelperIconDB["hide"] = false
        print("[Bountiful Delves Helper] 小地圖按鈕顯示，使用 /reload 來套用效果。")
    elseif arg1 == "" then
        showUI()
        isFrameVisible = true
    end
end

local eventListenerFrame = CreateFrame("Frame", "BountifulDelvesHelperListenerFrame")
local function eventHandler(self, event, arg1)
    if event == "GOSSIP_SHOW" and arg1 == "delves-difficulty-picker" then
        local highestTier = 1
        for index, data in pairs(DelvesDifficultyPickerFrame:GetOptions()) do
            if data["status"] == 0 then
                highestTier = index
            end
        end
    end
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("GOSSIP_SHOW")