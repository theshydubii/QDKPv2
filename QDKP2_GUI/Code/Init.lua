------------------------------------- INIT ----------------------------------
function QDKP2GUI_Init()
    QDKP2_Events:RegisterCallback("TIMERBASE_UPDATED", function(...)
        QDKP2GUI_Main:TimerCountdownRefresh(...);
    end)
    QDKP2_Events:RegisterCallback("DATA_UPDATED", QDKP2GUI_UpdateManager)
    QDKP2_Events:RegisterCallback("TIMER_START", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("TIMER_STOP", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("TIMER_PAUSED", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("IRONMAN_START", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("IRONMAN_STOP", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("BOSSBONUS_ON", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("BOSSBONUS_OFF", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("DETECTBID_ON", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("DETECTBID_OFF", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("FIXEDPRICES_ON", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("FIXEDPRICES_OFF", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("BACKUP_SAVED", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("BACKUP_RESTORED", function(...)
        QDKP2GUI_Main:Refresh();
    end)
    QDKP2_Events:RegisterCallback("SESSION_END", function(...)
        QDKP2GUI_RaidLoot_Refresh();
    end)
    QDKP2_Events:RegisterCallback("LOAD", QDKP2GUI_OnLoad)
end

------------------------------------- ON LOAD ----------------------------------------
function QDKP2GUI_OnLoad()
    QDKP2_Debug(2, "GUI", "Doing OnLoad...")
    -- QDKP2_RefreshAll()
    QDKP2GUI_MiniBtn_Refresh()
    QDKP2_Frame2_Header:SetText("Roster")
    QDKP2_Frame4_Header:SetText("Set Player Amounts")
end

-------------------------------- QDKP2 EVENTS MANAGER --------------------------------
function QDKP2GUI_UpdateManager(event, what)
    if what == "all" then
        QDKP2_RefreshAll()
    elseif what == "log" then
        QDKP2GUI_Log:Refresh()
    elseif what == "roster" then
        QDKP2GUI_Roster:Refresh(true) -- forces a restory
    end
    if QDKP2GUI_RaidLoot_Refresh then
        QDKP2GUI_RaidLoot_Refresh();
    end
end
