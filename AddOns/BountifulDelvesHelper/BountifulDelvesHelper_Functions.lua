function getColorText(color, text)
    return "\124cff" .. color .. text .. "\124r"
end

function getGearColorText(ilvl, text)
    local color = "1eff00"

    if ilvl >= 571 and ilvl < 584 then
        color = "0070dd"
    elseif ilvl >= 584 then
        color = "a335ee"
    end

    return "\124cff" .. color .. text .. "\124r"
end

function setWaypoint(mapPoiID)
    local waypoint = waypoints[mapPoiID]
    local point = UiMapPoint.CreateFromCoordinates(waypoint["zone"], waypoint["x"] / 100, waypoint["y"] / 100)
    C_Map.SetUserWaypoint(point)
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
end

function guiCreateNewline(container, count)
    local count = count or 1
    for index = 1, count do
        local newline = AceGUI:Create("Label")
        newline:SetFullWidth(true)
        container:AddChild(newline)
    end
end

function guiCreateLabel(container, fontSize, text, width)
    local label = AceGUI:Create("Label")
    label:SetText(text)
    label:SetFont(fontSize)
    label:SetWidth(width)
    container:AddChild(label)
end
