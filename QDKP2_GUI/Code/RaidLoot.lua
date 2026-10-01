local settings = {
    bidding = false,
    includeBIS = false,
    includeAlternative = false,
    includeOptional = false,
    bisOverMS = false,
    raidWarning = true,
    messageDelay = 0
}

QDKP2_RaidLootSettings = QDKP2_RaidLootSettings or {}
for key, value in pairs(settings) do
    if QDKP2_RaidLootSettings[key] == nil then
        QDKP2_RaidLootSettings[key] = value;
    end
end
settings = QDKP2_RaidLootSettings

local selectedItemID
local selectedItemLink
local activeRound
local queuedMessages = {}
local queueElapsed = 0
local MAX_MESSAGE_LENGTH = 230

local frame = CreateFrame("Frame", "QDKP2_RaidLootFrame", UIParent)
frame:SetWidth(390)
frame:SetHeight(445)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
        left = 11,
        right = 12,
        top = 12,
        bottom = 11
    }
})
frame:Hide()
tinsert(UISpecialFrames, "QDKP2_RaidLootFrame")

local function addText(parent, text, point, relative, relativePoint, x, y, width, height)
    local font = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    font:SetPoint(point, relative or parent, relativePoint or point, x or 0, y or 0)
    font:SetWidth(width or 340)
    font:SetHeight(height or 16)
    font:SetJustifyH("LEFT")
    font:SetText(text or "")
    return font
end

local title = addText(frame, "QDKP Loot Announcer", "TOP", frame, "TOP", 0, -17, 300, 20)
title:SetFontObject(GameFontNormal)

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
closeButton:SetScript("OnClick", function()
    frame:Hide()
end)

local itemButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
itemButton:SetWidth(342)
itemButton:SetHeight(42)
itemButton:SetPoint("TOP", title, "BOTTOM", 0, -12)
itemButton:SetText("Drag an item here")
itemButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
itemButton:SetScript("OnReceiveDrag", function()
    local cursorType, itemID, itemLink = GetCursorInfo()
    if cursorType == "item" then
        QDKP2_RaidLoot_SelectItem(itemID, itemLink);
        ClearCursor();
    end
end)
QDKP2_RaidLootItemButton = itemButton
itemButton:SetScript("OnClick", function(_, mouseButton)
    if mouseButton == "RightButton" then
        QDKP2_RaidLoot_SelectItem(nil, nil);
    end
end)
local itemIcon = frame:CreateTexture(nil, "ARTWORK")
itemIcon:SetWidth(34)
itemIcon:SetHeight(34)
itemIcon:SetPoint("LEFT", itemButton, "LEFT", 7, 0)
itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

local itemIDLabel = addText(frame, "Item ID", "TOPLEFT", frame, "TOPLEFT", 28, -96, 50, 20)
local itemIDBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
itemIDBox:SetWidth(120)
itemIDBox:SetHeight(22)
itemIDBox:SetPoint("LEFT", itemIDLabel, "RIGHT", 8, 0)
itemIDBox:SetAutoFocus(false)
itemIDBox:SetMaxLetters(12)
QDKP2_RaidLootItemIDBox = itemIDBox
itemIDBox:SetScript("OnEnterPressed", function(self)
    local value = string.gsub(self:GetText(), "^%s*(.-)%s*$", "%1")
    local itemID = tonumber(value)
    if itemID and itemID > 0 then
        QDKP2_RaidLoot_SelectItem(itemID)
    elseif value == "" then
        QDKP2_RaidLoot_SelectItem(nil, nil)
    end
    self:ClearFocus()
end)

local itemName = addText(frame, "No item selected", "LEFT", itemIDBox, "RIGHT", 15, 0, 140, 20)

local status = addText(frame, "Ready", "TOPLEFT", frame, "TOPLEFT", 25, -127, 340, 18)
status:SetTextColor(1, 0.82, 0.25)
QDKP2_RaidLootStatus = status

local checks = {}
local function addCheckbox(key, label, x, y)
    local check = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
    check:SetChecked(settings[key])
    local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", check, "RIGHT", 0, 0)
    text:SetText(label)
    check:SetScript("OnClick", function(self)
        settings[key] = self:GetChecked() and true or false
        if key == "bidding" then
            QDKP2_RaidLoot_Refresh();
        end
    end)
    checks[key] = check
    _G["QDKP2_RaidLootCheck_" .. key] = check
    return check
end

addCheckbox("includeBIS", "Include BIS list", 18, -153)
addCheckbox("includeAlternative", "Include alternatives", 190, -153)
addCheckbox("includeOptional", "Include optional", 18, -180)
addCheckbox("bidding", "Bidding mode", 190, -180)
addCheckbox("bisOverMS", "BIS before MS", 18, -207)
addCheckbox("raidWarning", "Raid Warning", 190, -207)

frame:SetScript("OnUpdate", function()
    if not IsMouseButtonDown("LeftButton") and not IsMouseButtonDown("RightButton") and not IsMouseButtonDown("MiddleButton") then
        return
    end
    local mouseFocus = GetMouseFocus()
    if itemIDBox:HasFocus() and mouseFocus ~= itemIDBox then
        itemIDBox:ClearFocus()
    end
end)

local function createButton(name, label, x, y, width, callback)
    local button = CreateFrame("Button", name, frame, "UIPanelButtonTemplate")
    button:SetWidth(width or 104)
    button:SetHeight(24)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
    button:SetText(label)
    button:SetScript("OnClick", callback)
    return button
end

local phaseButtons = {}
phaseButtons.MS = createButton("QDKP2_RaidLootMS", "Roll MS", 20, -275, 105, function()
    QDKP2_RaidLoot_StartRound("MS")
end)
phaseButtons.OS = createButton("QDKP2_RaidLootOS", "Roll OS", 142, -275, 105, function()
    QDKP2_RaidLoot_StartRound("OS")
end)
phaseButtons.DE = createButton("QDKP2_RaidLootDE", "DE / Transmog", 264, -275, 105, function()
    QDKP2_RaidLoot_StartRound("DE")
end)

local announceButtons = {}
announceButtons.BIS = createButton("QDKP2_RaidLootBIS", "BIS", 20, -308, 105, function()
    QDKP2_RaidLoot_AnnounceList("bis")
end)
announceButtons.ALTERNATIVE = createButton("QDKP2_RaidLootAlternative", "Alternative", 142, -308, 105, function()
    QDKP2_RaidLoot_AnnounceList("alternative")
end)
announceButtons.OPTIONAL = createButton("QDKP2_RaidLootOptional", "Optional", 264, -308, 105, function()
    QDKP2_RaidLoot_AnnounceList("optional")
end)

local closeRoundButton = createButton("QDKP2_RaidLootCloseRound", "Close Round", 20, -344, 105, function()
    QDKP2_RaidLoot_CloseRound()
end)
local winnerButton = createButton("QDKP2_RaidLootWinner", "Set Selected Winner", 132, -344, 132, function()
    QDKP2_RaidLoot_SetSelectedWinner()
end)
local reopenButton = createButton("QDKP2_RaidLootReopen", "Undo / Reopen", 274, -344, 105, function()
    QDKP2_RaidLoot_UndoAndReopen()
end)

local function formatItemLink()
    if not selectedItemID then
        return nil;
    end
    if selectedItemLink then
        return selectedItemLink;
    end
    local name = GetItemInfo(selectedItemID)
    return "|cffffffff|Hitem:" .. selectedItemID .. "|h[" .. (name or ("item:" .. selectedItemID)) .. "]|h|r"
end

function QDKP2_RaidLoot_SelectItem(itemID, link)
    if type(itemID) == "string" then
        itemID = tonumber(itemID) or tonumber(string.match(itemID, "item:(%d+)"))
    end
    selectedItemID = tonumber(itemID)
    if selectedItemID and selectedItemID < 1 then
        selectedItemID = nil;
    end
    selectedItemLink = link
    itemIDBox:SetText(selectedItemID and tostring(selectedItemID) or "")
    local name = selectedItemID and (GetItemInfo(selectedItemID) or ("item:" .. selectedItemID)) or nil
    itemName:SetText(name or "No item selected")
    itemButton:SetText(link or name or "Drag an item here")
    if selectedItemID then
        local _, linkFromCache, _, _, _, _, _, _, _, texture = GetItemInfo(selectedItemID)
        itemIcon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        selectedItemLink = selectedItemLink or linkFromCache
    else
        itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    QDKP2_RaidLoot_Refresh()
end

local function getMatches(itemID)
    local output = {
        bis = {},
        alternative = {},
        optional = {}
    }
    local item = QDKP2_RaidLootData[itemID]
    if type(item) ~= "table" then
        return output;
    end
    local stars = {
        [5] = "bis",
        [4] = "alternative",
        [3] = "optional"
    }
    local classNames = {
        WarriorTanking = {"Warrior", "Protection"},
        WarriorDPS = {"Warrior", "Arms", "Fury"},
        Rogue = {"Rogue"},
        Hunter = {"Hunter"},
        DruidFeral = {"Druid", "Feral"},
        DruidHealing = {"Druid", "Restoration"},
        Mage = {"Mage"},
        Priest = {"Priest"},
        Warlock = {"Warlock"},
        PaladinDPS = {"Paladin", "Retribution"},
        PaladinHealing = {"Paladin", "Holy"},
        ShamanDPS = {"Shaman", "Elemental", "Enhancement"},
        ShamanHealing = {"Shaman", "Restoration"},
        WarriorProt = {"Warrior", "Protection"},
        WarriorArms = {"Warrior", "Arms"},
        WarriorFury = {"Warrior", "Fury"},
        PaladinHoly = {"Paladin", "Holy"},
        PaladinProt = {"Paladin", "Protection"},
        PaladinRet = {"Paladin", "Retribution"},
        ShamanElemental = {"Shaman", "Elemental"},
        ShamanEnhance = {"Shaman", "Enhancement"},
        ShamanResto = {"Shaman", "Restoration"},
        DruidBalance = {"Druid", "Balance"},
        DruidResto = {"Druid", "Restoration"},
        PriestDPS = {"Priest", "Shadow"},
        PriestHeal = {"Priest", "Holy"},
        DeathknightTank = {"Death Knight", "Blood"},
        DeathknightDPS = {"Death Knight", "Frost", "Unholy"}
    }
    for key, value in pairs(item) do
        if output[key] and type(value) == "table" then
            for className, specs in pairs(value) do
                for _, spec in ipairs(specs) do
                    table.insert(output[key], className .. " - " .. spec)
                end
            end
        elseif type(value) == "number" and stars[value] then
            local info = classNames[key]
            if info then
                local category = stars[value]
                if #info == 1 then
                    table.insert(output[category], info[1])
                else
                    for index = 2, #info do
                        table.insert(output[category], info[1] .. " - " .. info[index]);
                    end
                end
            end
        end
    end
    for _, lines in pairs(output) do
        table.sort(lines);
    end
    return output
end

local function queueMessage(text)
    while string.len(text) > 230 do
        local splitAt = string.find(string.sub(text, 1, 230), ";[^;]*$") or 230
        table.insert(queuedMessages, string.sub(text, 1, splitAt - 1))
        text = string.gsub(string.sub(text, splitAt + 1), "^%s*;?%s*", "")
    end
    if text ~= "" then
        table.insert(queuedMessages, text);
    end
    queueFrame:Show()
end

local function queueLines(header, lines)
    if #lines == 0 then
        queueMessage(header .. " No entries found.");
        return;
    end
    local current = header .. " "
    for _, line in ipairs(lines) do
        local addition = (current == header .. " " and "" or "; ") .. line
        if string.len(current .. addition) > 230 then
            queueMessage(current)
            current = line
        else
            current = current .. addition
        end
    end
    queueMessage(current)
end

local function sendMessage(text)
    local channel = "SAY"
    if GetNumRaidMembers() > 0 then
        if settings.raidWarning and ((IsRaidLeader and IsRaidLeader()) or (IsRaidOfficer and IsRaidOfficer())) then
            channel = "RAID_WARNING"
        else
            channel = "RAID"
        end
    elseif GetNumPartyMembers() > 0 then
        channel = "PARTY"
    end
    SendChatMessage(text, channel)
end

queueFrame = CreateFrame("Frame")
queueFrame:Hide()
queueFrame:SetScript("OnUpdate", function(_, elapsed)
    if #queuedMessages == 0 then
        queueElapsed = 0;
        queueFrame:Hide();
        return;
    end
    queueElapsed = queueElapsed + elapsed
    if queueElapsed >= (tonumber(settings.messageDelay) or 0) then
        queueElapsed = 0
        sendMessage(table.remove(queuedMessages, 1))
    end
end)

function QDKP2_RaidLoot_AnnounceList(category)
    if not selectedItemID then
        status:SetText("Drag an item into the item area first.");
        return;
    end
    local lines = getMatches(selectedItemID)[category]
    local header = category == "bis" and "BIS for " or category == "alternative" and "Alternatives for " or
                       "Optional for "
    queueLines(header .. (formatItemLink() or "item") .. ":", lines)
end

function QDKP2_RaidLoot_StartRound(phase)
    if not QDKP2_OfficerMode() then
        QDKP2_Msg(QDKP2_LOC_NoRights, "ERROR");
        return;
    end
    if not selectedItemID then
        status:SetText("Drag an item into the item area first.");
        return;
    end
    local item = formatItemLink()
    local mode = settings.bidding and "bid" or "roll"
    local started
    if mode == "bid" then
        started = QDKP2_BidM_StartBid(item, phase, true, true)
    else
        started = QDKP2_BidM_StartRoll(phase, item, true)
    end
    if not started then
        return;
    end
    activeRound = {
        mode = mode,
        phase = phase,
        item = item
    }
    if settings.bisOverMS and phase == "MS" then
        queueMessage("BIS priority for " .. item .. ": BIS first, then MS.");
    end
    local category = phase == "MS" and "Main Spec" or phase == "OS" and "Off Spec" or "DE / Transmog"
    if mode == "bid" then
        queueMessage("Bidding is open for " .. item .. " (" .. category .. ").")
    else
        queueMessage("Roll 1-100 for " .. category .. ": " .. item)
    end
    local matches = getMatches(selectedItemID)
    if settings.includeBIS and phase ~= "MS" and #matches.bis > 0 then
        queueLines("BIS for:", matches.bis);
    end
    if settings.includeAlternative and #matches.alternative > 0 then
        queueLines("Alternatives for:", matches.alternative);
    end
    if settings.includeOptional and #matches.optional > 0 then
        queueLines("Optional for:", matches.optional);
    end
    status:SetText((mode == "bid" and "Bidding" or "Roll") .. " open: " .. category)
    QDKP2_RaidLoot_Refresh()
end

local function findBestBid()
    local bestName, bestValue, tied
    for name, bid in pairs(QDKP2_BidM.LIST or {}) do
        if bid.eligible ~= false then
            local value = tonumber(bid.value or bid.dkp)
            if value and (not bestValue or value > bestValue) then
                bestName, bestValue, tied = name, value, false
            elseif value and value == bestValue then
                tied = true
            end
        end
    end
    return bestName, bestValue, tied
end

function QDKP2_RaidLoot_CloseRound()
    if not activeRound then
        status:SetText("No active roll or bidding round.");
        return;
    end
    if activeRound.mode == "roll" then
        local winner = QDKP2_BidM_CloseRoll(true)
        if not winner then
            status:SetText("Roll closed. Select a winner in the Bid Manager list.");
            return;
        end
        status:SetText("Roll winner: " .. winner)
    else
        QDKP2_BidM_CloseBid()
        local winner, value, tied = findBestBid()
        if not winner then
            status:SetText("Bidding closed with no valid bids.")
        elseif tied then
            status:SetText("Top bid is tied. Select the winner in the Bid Manager list.")
        else
            QDKP2_BidM_Winner(winner, true, true)
            status:SetText("Winner selected: " .. winner .. " (" .. tostring(value) .. ")")
        end
    end
    QDKP2_RaidLoot_Refresh()
end

function QDKP2_RaidLoot_SetSelectedWinner()
    local selected = QDKP2GUI_Roster.SelectedPlayers and QDKP2GUI_Roster.SelectedPlayers[1]
    if not selected or not QDKP2_BidM.LIST or not QDKP2_BidM.LIST[selected] then
        status:SetText("Select a bidder in the Bid Manager roster first.")
        return
    end
    local bid = QDKP2_BidM.LIST[selected]
    QDKP2_BidM_Winner(selected, not bid.rollPhase, true)
    status:SetText("Winner selected: " .. selected)
    QDKP2_RaidLoot_Refresh()
end

function QDKP2_RaidLoot_UndoAndReopen()
    local round = QDKP2_BidM_UndoLastSettlementAndReopen()
    if not round then
        return;
    end
    activeRound = {
        mode = round.mode,
        phase = round.phase,
        item = round.item
    }
    status:SetText("Settlement reverted. Round reopened.")
    QDKP2_RaidLoot_Refresh()
end

function QDKP2_RaidLoot_Refresh()
    local inProgress = QDKP2_RollPhase or QDKP2_BidM_isBidding()
    local phase = QDKP2_RollPhase or QDKP2_BidM.Phase
    for _, button in pairs(phaseButtons) do
        if inProgress then
            button:Disable()
        else
            button:Enable();
        end
    end
    if activeRound or inProgress then
        closeRoundButton:Enable()
    else
        closeRoundButton:Disable();
    end
    local selected = QDKP2GUI_Roster and QDKP2GUI_Roster.SelectedPlayers and QDKP2GUI_Roster.SelectedPlayers[1]
    if selected and QDKP2_BidM.LIST and QDKP2_BidM.LIST[selected] then
        winnerButton:Enable()
    else
        winnerButton:Disable()
    end
    if QDKP2_BidM.LastSettlement then
        reopenButton:Enable()
    else
        reopenButton:Disable();
    end
    if announceButtons.BIS then
        local hasData = selectedItemID and getMatches(selectedItemID) or nil
        for category, button in pairs(announceButtons) do
            local key = string.lower(category)
            if hasData and #hasData[key] > 0 then
                button:Enable()
            else
                button:Disable();
            end
        end
    end
    if not activeRound and inProgress then
        activeRound = {
            mode = QDKP2_RollPhase and "roll" or "bid",
            phase = phase,
            item = QDKP2_BidM.ITEM
        }
    elseif activeRound and not inProgress and not QDKP2_BidM.LastSettlement and
        not (QDKP2_BidM.LIST and next(QDKP2_BidM.LIST)) then
        activeRound = nil
    end
end

function QDKP2GUI_RaidLoot_Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show();
        QDKP2_RaidLoot_Refresh();
    end
end

SLASH_QDKP2_RRA1 = "/rra"
SLASH_QDKP2_RRA2 = "/announce"
SlashCmdList.QDKP2_RRA = QDKP2GUI_RaidLoot_Toggle
