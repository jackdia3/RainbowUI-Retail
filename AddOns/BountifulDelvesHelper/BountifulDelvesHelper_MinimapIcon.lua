local addon = LibStub("AceAddon-3.0"):NewAddon("BountifulDelvesHelper")
BountifulDelvesHelperMinimapButton = LibStub("LibDBIcon-1.0", true)

local BountifulDelvesHelperLDB = LibStub("LibDataBroker-1.1"):NewDataObject("BountifulDelvesHelper", {
	type = "launcher",
	text = "豐碩探究幫手",
	icon = "Interface\\AddOns\\BountifulDelvesHelper\\minimap.tga",
	OnClick = function(self, btn)
        if btn == "LeftButton" or btn == "RightButton" then
		    BountifulDelvesHelper:ToggleMainFrame()
        end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end

		tooltip:AddLine("豐碩探究幫手", nil, nil, nil, nil)
	end,
})

local BountifulDelvesHelperIcon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("BountifulDelvesHelperLDB", {
		profile = {
			minimap = {
				hide = BountifulDelvesHelperIconDB["hide"],
			},
		},
	})

	BountifulDelvesHelperIcon:Register("BountifulDelvesHelper", BountifulDelvesHelperLDB, BountifulDelvesHelperIconDB)
end

BountifulDelvesHelperMinimapButton:Show("BountifulDelvesHelper")