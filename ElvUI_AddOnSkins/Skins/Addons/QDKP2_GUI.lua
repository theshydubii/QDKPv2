local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")
local AS = E:GetModule("AddOnSkins")

if not AS:IsAddonLODorEnabled("QDKP2_GUI") then return end

-- Quick DKP V2 - GUI v 2.6.7 and v 2.7.5

S:AddCallbackForAddon("QDKP2_GUI", "QDKP2_GUI", function()
	if not E.private.addOnSkins.QDKP2_GUI then return end
	local qdkpPopups = {
		QDKP2_InputBox, QDKP2_NotifyBox, QDKP2_QuestionBox, QDKP2_CopyWindow,
	}
	for _, popup in ipairs(qdkpPopups) do
		if popup then
			popup:StripTextures()
			popup:CreateBackdrop("Transparent")
			local closeButton = _G[popup:GetName() .. "_ButtonClose"]
			if closeButton then S:HandleCloseButton(closeButton, popup) end
		end
	end
	local qdkpPopupEdits = {
		QDKP2_InputBox_Data, QDKP2_CopyWindow_Data,
	}
	for _, editBox in ipairs(qdkpPopupEdits) do
		if editBox then S:HandleEditBox(editBox) end
	end
	local qdkpPopupButtons = {
		QDKP2_InputBox_Cancel, QDKP2_InputBox_OK,
		QDKP2_NotifyBox_OK, QDKP2_QuestionBox_Cancel, QDKP2_QuestionBox_OK,
	}
	for _, button in ipairs(qdkpPopupButtons) do
		if button then S:HandleButton(button) end
	end
	local qdkpCopyChecks = {
		QDKP2_CopyWindow_Format1, QDKP2_CopyWindow_Format2,
		QDKP2_CopyWindow_Format3, QDKP2_CopyWindow_Format4,
	}
	for _, check in ipairs(qdkpCopyChecks) do
		if check then S:HandleCheckBox(check) end
	end
	if QDKP2_RaidLootFrame then
		QDKP2_RaidLootFrame:StripTextures()
		QDKP2_RaidLootFrame:CreateBackdrop("Transparent")
		if QDKP2_RaidLootItemButton then S:HandleButton(QDKP2_RaidLootItemButton) end
		if QDKP2_RaidLootCloseButton then S:HandleCloseButton(QDKP2_RaidLootCloseButton, QDKP2_RaidLootFrame) end
		if QDKP2_RaidLootItemIDBox then
			S:HandleEditBox(QDKP2_RaidLootItemIDBox)
			QDKP2_RaidLootItemIDBox:StripTextures()
			QDKP2_RaidLootItemIDBox:CreateBackdrop("Transparent")
		end
		if QDKP2_RaidLootStatus then QDKP2_RaidLootStatus:SetTextColor(0.85, 0.85, 0.85) end
		local raidLootButtons = {
			QDKP2_RaidLootMS, QDKP2_RaidLootOS, QDKP2_RaidLootDE,
			QDKP2_RaidLootBIS, QDKP2_RaidLootAlternative, QDKP2_RaidLootOptional,
			QDKP2_RaidLootCloseRound, QDKP2_RaidLootWinner, QDKP2_RaidLootReopen,
			QDKP2_RaidLootItemClear,
		}
		for _, button in ipairs(raidLootButtons) do
			if button then
				S:HandleButton(button)
				-- Enable()/Disable() reset Blizzard's button textures, so re-skin whenever that happens
				button:HookScript("OnEnable", function() S:HandleButton(button) end)
				button:HookScript("OnDisable", function() S:HandleButton(button) end)
			end
		end
		local raidLootChecks = {
			QDKP2_RaidLootCheck_includeBIS,
			QDKP2_RaidLootCheck_includeAlternative,
			QDKP2_RaidLootCheck_includeOptional,
			QDKP2_RaidLootCheck_bidding,
			QDKP2_RaidLootCheck_bisOverMS,
			QDKP2_RaidLootCheck_raidWarning,
			QDKP2_RaidLootCheck_autoClose,
		}
		for _, check in ipairs(raidLootChecks) do
			if check then S:HandleCheckBox(check) end
		end
	end
	--Roster Frame
	QDKP2_Frame2:StripTextures()
	QDKP2_Frame2:CreateBackdrop("Transparent")
	QDKP2_Frame2:Size(780, 400)
	QDKP2_frame2_title:Size(725, 14)
	QDKP2_frame2_scrollbar:StripTextures()
	QDKP2_frame2_scrollbar:Point("TOPLEFT", 15, - 55)
	QDKP2_frame2_scrollbar:Point("BOTTOMRIGHT", - 30, 41)
	QDKP2_frame2_title_name:Size(105, 14)
	QDKP2_frame2_title_class:Size(80, 14)
	QDKP2_frame2_title_net:Size(60, 14)
	QDKP2_frame2_title_total:Size(60, 14)
	QDKP2_frame2_title_spent:Size(60, 14)

	for i = 10, 29 do
		local child = select(i, QDKP2_Frame2:GetChildren())
		if child:IsObjectType("Button") then
			child:StripTextures()
			child:SetHighlightTexture("Interface\\AddOns\\ElvUI\\Media\\Textures\\Highlight.tga", "Add")
			S:HandleButtonHighlight(child, 1, 0.8, 0.1)
		end
	end

	for i = 1, 20 do
		_G["QDKP2_frame2_entry" .. i]:Size(725, 14)
		_G["QDKP2_frame2_entry" .. i .. "_name"]:Size(105, 14)
		_G["QDKP2_frame2_entry" .. i .. "_class"]:Size(80, 14)
		_G["QDKP2_frame2_entry" .. i .. "_net"]:Size(60, 14)
		_G["QDKP2_frame2_entry" .. i .. "_total"]:Size(60, 14)
		_G["QDKP2_frame2_entry" .. i .. "_spent"]:Size(60, 14)

		local highlight = _G["QDKP2_frame2_entry" .. i .. "_Highlight"]
		highlight:SetAllPoints(true)
		highlight:SetTexture(E.Media.Textures.Highlight)
		local valueColor = E.media and E.media.rgbvaluecolor or { 0.8, 0.6, 0.2 }
		highlight:SetVertexColor(valueColor[1], valueColor[2], valueColor[3], 0.5)
	end

	S:HandleScrollBar(QDKP2_frame2_scrollbarScrollBar)
	S:HandleButton(QDKP2_Frame2_SortBtn_name)
	S:HandleButton(QDKP2_Frame2_SortBtn_rank)
	S:HandleButton(QDKP2_Frame2_SortBtn_class)
	S:HandleButton(QDKP2_Frame2_SortBtn_net)
	S:HandleButton(QDKP2_Frame2_SortBtn_total)
	S:HandleButton(QDKP2_Frame2_SortBtn_spent)
	S:HandleButton(QDKP2_Frame2_SortBtn_hours)
	S:HandleButton(QDKP2_Frame2_SortBtn_deltatotal)
	S:HandleButton(QDKP2_Frame2_SortBtn_deltaspent)
	S:HandleButton(QDKP2_frame2_showRaid)
	S:HandleButton(QDKP2_Frame2_SortBtn_roll)
	S:HandleButton(QDKP2_Frame2_SortBtn_bid)
	S:HandleButton(QDKP2_Frame2_SortBtn_value)
	S:HandleCheckBox(QDKP2frame2_selectList_guild)
	if QDKP2frame2_selectList_guildOnline then
		S:HandleCheckBox(QDKP2frame2_selectList_guildOnline)
	elseif QDKP2frame2_selectList_Custom then
		S:HandleCheckBox(QDKP2frame2_selectList_Custom)
	end
	S:HandleCheckBox(QDKP2frame2_selectList_Raid)
	S:HandleCheckBox(QDKP2frame2_selectList_Bid)
	S:HandleCloseButton(QDKP2_Frame2_Button1, QDKP2_Frame2)

	--RaidLog Frame
	QDKP2_Frame5:StripTextures()
	QDKP2_Frame5:CreateBackdrop("Transparent")
	QDKP2_frame5_scrollbar:StripTextures()
	S:HandleCloseButton(QDKP2_Frame5_Button1, QDKP2_Frame5)
	S:HandleScrollBar(QDKP2_frame5_scrollbarScrollBar)
	QDKP2_frame5_intest_net:Size(40, 14)
	QDKP2_frame5_intest_mod:Size(40, 14)
	for i = 1, 25 do
		_G["QDKP2_frame5_entry" .. i .. "_net"]:Size(40, 14)
		_G["QDKP2_frame5_entry" .. i .. "_mod"]:Size(40, 14)
	end
	for i = 4, 28 do
		local child = select(i, QDKP2_Frame5:GetChildren())
		if child:IsObjectType("Button") then
			child:StripTextures()
			child:SetHighlightTexture("Interface\\AddOns\\ElvUI\\Media\\Textures\\Highlight.tga", "Add")
			S:HandleButtonHighlight(child, 1, 0.8, 0.1)
		end
	end

	--Frame 1
	QDKP2_Frame1:StripTextures()
	QDKP2_Frame1:CreateBackdrop("Transparent")
	S:HandleCloseButton(QDKP2_Frame1_Button1, QDKP2_Frame1)
	S:HandleButton(QDKP2frame1_newSession)
	S:HandleButton(QDKP2frame1_closeSession)
	S:HandleButton(QDKP2frame1_upload)
	S:HandleButton(QDKP2frame1_revert)
	S:HandleButton(QDKP2frame1_backup)
	S:HandleButton(QDKP2frame1_restore)
	S:HandleButton(QDKP2frame1_exportTXT)
	S:HandleButton(QDKP2frame1_list)
	S:HandleButton(QDKP2frame1_log)
	S:HandleButton(QDKP2frame1_award)
	S:HandleButton(QDKP2frame1_dkpBox_perhr)
	S:HandleButton(QDKP2frame1_dkpBox_IM)
	S:HandleButton(QDKP2frame1_ironman)
	S:HandleButton(QDKP2frame1_onOff)
	S:HandleButton(QDKP2frame1_dkpBox)
	S:HandleNextPrevButton(QDKP2frame1_upbutton, "up")
	S:HandleNextPrevButton(QDKP2frame1_downbutton, "down")
	S:HandleNextPrevButton(QDKP2frame1_hourlybonus_upbutton, "up")
	S:HandleNextPrevButton(QDKP2frame1_hourlybonus_downbutton, "down")
	S:HandleNextPrevButton(QDKP2frame1_IMbonus_upbutton, "up")
	S:HandleNextPrevButton(QDKP2frame1_IMbonus_downbutton, "down")
	S:HandleCheckBox(QDKP2frame1_UseBossMod)
	S:HandleCheckBox(QDKP2frame1_DetectBids)
	S:HandleCheckBox(QDKP2frame1_FixedPrice)
	QDKP2_frame1_BackupDate:Point("CENTER", 0, - 3)
	QDKP2_Frame1_raidDKP_text:Point("LEFT", 4, 0)
	QDKP2_Frame1_timerDKP_text:Point("LEFT", 4, 0)
	QDKP2_Frame1_IMDKP_text:Point("LEFT", 4, 0)
	QDKP2frame1_exportTXT:Size(60, 20)
	QDKP2frame1_exportTXT:Point("Left", QDKP2frame1_upload, "RIGHT", 5, - 22)
	QDKP2frame1_log:Point("CENTER", QDKP2_Frame1, "TOP", - 25, - 55)
	QDKP2frame1_newSession:Point("RIGHT", QDKP2_Frame1, "TOP", - 2, - 103)
	QDKP2frame1_backup:Point("RIGHT", QDKP2_frame1_BackupDate_Parent, "TOP", - 36, 5)
	QDKP2frame1_restore:Point("LEFT", QDKP2_frame1_BackupDate_Parent, "TOP", - 35, 5)
	QDKP2frame1_backup:Size(89, 20)
	QDKP2frame1_restore:Size(89, 20)

	--Frame 3
	QDKP2_Frame3:StripTextures()
	QDKP2_Frame3:CreateBackdrop("Transparent")
	QDKP2frame3_dkpBox:Size(45, 20)
	QDKP2frame3_reasonBox:Size(137, 20)
	QDKP2frame3_reasonBox:Point("LEFT", QDKP2frame3_For, "RIGHT", 4, - 2)
	QDKP2frame3_changePlayerInfo:Point("CENTER", QDKP2_Frame3, "BOTTOM", 0, 23)
	S:HandleCloseButton(QDKP2_Frame3_Button1)
	S:HandleEditBox(QDKP2frame3_dkpBox)
	S:HandleEditBox(QDKP2frame3_reasonBox)
	S:HandleButton(QDKP2frame3_award)
	S:HandleButton(QDKP2frame3_spend)
	S:HandleButton(QDKP2frame3_zsBtn)
	S:HandleButton(QDKP2frame3_PopupLog)
	S:HandleButton(QDKP2frame3_changePlayerInfo)

	--Frame 4
	QDKP2_Frame4:StripTextures()
	QDKP2_Frame4:CreateBackdrop("Transparent")
	S:HandleCloseButton(QDKP2_Frame4_Button1)
	QDKP2frame4_NetBox:Size(100, 15)
	QDKP2frame4_TotalBox:Size(100, 15)
	QDKP2frame4_HoursBox:Size(70, 15)
	QDKP2frame4_NetBox:Point("TopLeft", QDKP2_Frame4, "TopLeft", 70, - 31)
	QDKP2frame4_TotalBox:Point("TopLeft", QDKP2_Frame4, "TopLeft", 70, - 51)
	QDKP2frame4_HoursBox:Point("TopLeft", QDKP2_Frame4, "TopLeft", 70, - 71)
	S:HandleEditBox(QDKP2frame4_NetBox)
	S:HandleEditBox(QDKP2frame4_TotalBox)
	S:HandleEditBox(QDKP2frame4_HoursBox)
	S:HandleButton(QDKP2Frame4_Set)

	--QDKP2_modify_log_entry
	QDKP2_modify_log_entry:StripTextures()
	QDKP2_modify_log_entry:CreateBackdrop("Transparent")
	S:HandleCloseButton(QDKP2_modify_log_entry_ButtonClose)
	QDKP2_modify_log_entry:Size(230, 160)
	QDKP2frame6_GainedBox:Size(50, 20)
	QDKP2frame6_SpentBox:Size(50, 20)
	QDKP2frame6_ReasonBox:Size(160, 20)
	QDKP2frame6_ReasonBox:Point("TOP", 19, - 70)
	QDKP2_modify_log_entry_for:Point("TOPLEFT", 5, - 74)
	S:HandleEditBox(QDKP2frame6_GainedBox)
	S:HandleEditBox(QDKP2frame6_SpentBox)
	S:HandleEditBox(QDKP2frame6_ReasonBox)
	S:HandleButton(QDKP2_modify_log_entry_Apply)
	S:HandleButton(QDKP2_modify_log_entry_Cancel)
end)
