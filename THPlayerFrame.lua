
local THPF_IsAFK = false;
local THPF_IsDND = false;

function THPF_OnLoad()
   SLASH_RUI1 = "/rui";
   SlashCmdList["RUI"] = function(msg)
      ReloadUI();
   end

   SLASH_THUF1 = "/thuf";
   SlashCmdList["THUF"] = function(msg)
      THPF_SlashCommandHandler(msg);
   end

   SLASH_MIX1 = "/mix";
   SlashCmdList["MIX"] = function(msg)
      THPF_MixItems(msg);
   end

   SLASH_MIXB1 = "/mix2";
   SlashCmdList["MIXB"] = function(msg)
      THPF_Mix2Items(msg);
   end

   CombatFeedback_Initialize(THPF_MainFrame_PlayerModel_PHI, 30);

   -- THPF_SetBackgroundGradient();
   THPF_PortraitUpdate();
   THPF_DisplayUpdate();

   this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
   -- THPF_MainFrame_Pet:RegisterForClicks("LeftButtonUp", "RightButtonUp");

   this:RegisterEvent("UNIT_NAME_UPDATE");
   this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
   this:RegisterEvent("UNIT_DISPLAYPOWER");
   this:RegisterEvent("UNIT_FACTION");
   this:RegisterEvent("UNIT_PVP_UPDATE");
   this:RegisterEvent("PLAYER_FLAGS_CHANGED");

   this:RegisterEvent("UNIT_LEVEL");
   this:RegisterEvent("UNIT_COMBAT");
   this:RegisterEvent("UNIT_PVP_UPDATE");
   this:RegisterEvent("UNIT_MAXMANA");
   this:RegisterEvent("PLAYER_ENTERING_WORLD");
   this:RegisterEvent("PLAYER_ENTER_COMBAT");
   this:RegisterEvent("PLAYER_LEAVE_COMBAT");
   this:RegisterEvent("PLAYER_REGEN_DISABLED");
   this:RegisterEvent("PLAYER_REGEN_ENABLED");
   this:RegisterEvent("PLAYER_UPDATE_RESTING");
   this:RegisterEvent("PARTY_MEMBERS_CHANGED");
   this:RegisterEvent("PARTY_LEADER_CHANGED");
   this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
   this:RegisterEvent("RAID_ROSTER_UPDATE");

   this:RegisterEvent("UNIT_HEALTH");
   this:RegisterEvent("UNIT_MAXHEALTH");

   this:RegisterEvent("UNIT_DISPLAYPOWER");
   this:RegisterEvent("UNIT_MANA");
   this:RegisterEvent("UNIT_RAGE");
   this:RegisterEvent("UNIT_FOCUS");
   this:RegisterEvent("UNIT_ENERGY");
   this:RegisterEvent("UNIT_HAPPINESS");
   this:RegisterEvent("UNIT_MAXMANA");
   this:RegisterEvent("UNIT_MAXRAGE");
   this:RegisterEvent("UNIT_MAXFOCUS");
   this:RegisterEvent("UNIT_MAXENERGY");
   this:RegisterEvent("UNIT_MAXHAPPINESS");

   this:RegisterEvent("UNIT_AURA");
   this:RegisterEvent("UNIT_PET");

   this:RegisterEvent("CHAT_MSG_SYSTEM");

   this:RegisterEvent("UPDATE_FACTION");
   this:RegisterEvent("PLAYER_XP_UPDATE");
   this:RegisterEvent("UPDATE_EXHAUSTION");
   this:RegisterEvent("PLAYER_LEVEL_UP");

   PlayerFrame:Hide();
end

function THPF_Mix2Items(msg)
   -- local matchstr = "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r";
   local matchstr = "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r%s+(.+)";
   if ( string.find(msg,matchstr) ) then
      local _, _, c1, l1, n1, oo = string.find(msg,matchstr);
      DEFAULT_CHAT_FRAME:AddMessage("Mixed = |c"..c1.."|Hitem:"..l1.."|h["..n1.." "..oo.."]|h|r");
   end
end

function THPF_MixItems(msg)
   -- local matchstr = "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r";
   local matchstr = "|c(%x+)|Hitem:(%d+:%d+):%d+:%d+|h%[(.-)%]|h|r.*|c(%x+)|Hitem:%d+:%d+(:%d+:%d+)|h%[.+( of .-)%]|h|r";
   if ( string.find(msg,matchstr) ) then
      local _, _, c1, l1, n1, c2, l2, n2 = string.find(msg,matchstr);
      if c1 then
      DEFAULT_CHAT_FRAME:AddMessage("c1 = "..c1); end
      if l1 then
      DEFAULT_CHAT_FRAME:AddMessage("l1 = "..l1); end
      if n1 then
      DEFAULT_CHAT_FRAME:AddMessage("n1 = "..n1); end
      if c2 then
      DEFAULT_CHAT_FRAME:AddMessage("c2 = "..c2); end
      if l2 then
      DEFAULT_CHAT_FRAME:AddMessage("l2 = "..l2); end
      if n2 then
      DEFAULT_CHAT_FRAME:AddMessage("n2 = "..n2); end
      DEFAULT_CHAT_FRAME:AddMessage("Mixed = |c"..c1.."|Hitem:"..l1..l2.."|h["..n1..n2.."]|h|r");
   else
      DEFAULT_CHAT_FRAME:AddMessage("not found");
      DEFAULT_CHAT_FRAME:AddMessage( string.gsub(msg, "|", "||") );
   end
end

function THPF_SlashCommandHandler(msg)
   if ( string.find(msg,"^scale (.*)$") ) then
      local _, _, scv = string.find(msg,"^scale (.*)$");
      THPF_SetFrameScale("player",scv);
      THPF_SetFrameScale("target",scv);
      THPF_SetFrameScale("tot",scv);
      THPF_SetFrameScale("pet",scv);
   else
      THUF_ShowConfigWindow();
   end
end

function THPF_SetBackgroundGradient()
   if (THPF_Vars["playerfadedirection"] == "up") then
      THPF_MainFrame_GradientBG:SetGradientAlpha("VERTICAL",0,0,0,1,0,0,0,0);
   elseif (THPF_Vars["playerfadedirection"] == "left") then
      THPF_MainFrame_GradientBG:SetGradientAlpha("HORIZONTAL",0,0,0,0,0,0,0,1);
   elseif (THPF_Vars["playerfadedirection"] == "right") then
      THPF_MainFrame_GradientBG:SetGradientAlpha("HORIZONTAL",0,0,0,1,0,0,0,0);
   else
      THPF_MainFrame_GradientBG:SetGradientAlpha("VERTICAL",0,0,0,0,0,0,0,1);
   end
   THPF_MainFrame_PlayerModel_PHIBG:SetVertexColor(0,0,0,1);
   THPF_MainFrame_HPBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
   THPF_MainFrame_MPBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
   THPF_MainFrame_ExpBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);

   if (THPF_Vars["petfadedirection"] == "up") then
      THPF_MainFrame_Pet_BGTexture:SetGradientAlpha("VERTICAL",0,0,0,1,0,0,0,0);
   elseif (THPF_Vars["petfadedirection"] == "left") then
      THPF_MainFrame_Pet_BGTexture:SetGradientAlpha("HORIZONTAL",0,0,0,0,0,0,0,1);
   elseif (THPF_Vars["petfadedirection"] == "right") then
      THPF_MainFrame_Pet_BGTexture:SetGradientAlpha("HORIZONTAL",0,0,0,1,0,0,0,0);
   else
      THPF_MainFrame_Pet_BGTexture:SetGradientAlpha("VERTICAL",0,0,0,0,0,0,0,1);
   end

   THPF_MainFrame_Pet_HPBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
   THPF_MainFrame_Pet_MPBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);

   THPF_MainFrame_ExpBar_SB:SetStatusBarColor( 0, 0.66, 0 );
end

function THPF_SetHPBarColor(hpbar, min, max, cur)
   local adj = (cur-min) / (max-min);
   local newcolor = { };
   if adj>0.5 then
      newcolor.r = ((1-adj) *2)
   else
      newcolor.r = 1;
   end
   if adj<0.5 then
      newcolor.g = (adj*2)
   else
      newcolor.g = 1;
   end
   newcolor.b = 0;

   if newcolor.r > 1 then
      newcolor.r = 1;
   elseif newcolor.r < 0 then
      newcolor.r = 0;
   end
   if newcolor.g > 1 then
      newcolor.g = 1;
   elseif newcolor.g < 0 then
      newcolor.g = 0;
   end
   if newcolor.b > 1 then
      newcolor.b = 1;
   elseif newcolor.b < 0 then
      newcolor.b = 0;
   end
                      
   hpbar:SetStatusBarColor( newcolor.r, newcolor.g, newcolor.b );
end

function THPF_DisplayUpdate()
   THPF_NameUpdate();
   THPF_LevelClassUpdate();
   THPF_PortraitUpdate();
   THPF_SetupDisplayPower();
   THPF_HPUpdate();
   THPF_MPUpdate();
   THPF_FactionUpdate();
   THPF_StatusUpdate();
   THPF_LeaderUpdate();
end

function THPF_NameUpdate()
   THPF_MainFrame_PlayerName:SetTextColor(200/255, 228/255, 255/255);
   local uname = UnitName("player");
   if ( THPF_IsAFK ) then
      uname = uname .. " |cffffff00<AFK>";
   elseif ( THPF_IsDND ) then
      uname = uname .. " |cffffff00<DND>";
   end
   THPF_MainFrame_PlayerName:SetText( uname );
end

function THPF_LevelUpdate()
   THPF_LevelClassUpdate();
end

function THPF_LevelClassUpdate()
   THPF_MainFrame_PlayerDesc:SetTextColor(255/255, 255/255, 255/255)
   THPF_MainFrame_PlayerDesc:SetText("Level "..UnitLevel("player").." "..UnitRace("player").." "..UnitClass("player"));
end

function THPF_PortraitUpdate()
   THPF_MainFrame_PlayerModel:SetRotation(0.61);
   THPF_MainFrame_PlayerModel:SetUnit("player");
   THPF_MainFrame_PlayerModel:SetCamera(0);
end

function THPF_SetupDisplayPower()
   local upt = UnitPowerType("player");
   THPF_MainFrame_MPBar_SB:SetStatusBarColor( ManaBarColor[upt].r, ManaBarColor[upt].g, ManaBarColor[upt].b );
end

local THPF_FADED_OUT_ALPHA = 0.25;
local THPF_HPFull = nil;
local THPF_MPFull = nil;
local THPF_IsFadingIn = nil;
local THPF_IsFadingOut = nil;
local THPF_AnimHandle = nil;

function THPF_HPUpdate()
   local curValue = UnitHealth("player");
   local maxValue = UnitHealthMax("player");
   THPF_MainFrame_HPBar_SB:SetMinMaxValues(0, maxValue);
   THPF_MainFrame_HPBar_SB:SetValue(curValue);
   THPF_SetHPBarColor(THPF_MainFrame_HPBar_SB, 0, maxValue, curValue);
   THPF_MainFrame_HPBar_SB_SBX:SetText( curValue .. "/" .. maxValue );
   THPF_MainFrame_HPBar_SB_SBP:SetText( math.floor((curValue/maxValue)*100).."%" );
   if (curValue==maxValue) then
      THPF_HPFull = 1;
   else
      THPF_HPFull = nil;
   end
   THPF_MaybeStartFade();
end

function THPF_MPUpdate()
   local curValue = UnitMana("player");
   local maxValue = UnitManaMax("player");
   THPF_MainFrame_MPBar_SB:SetMinMaxValues(0, maxValue);
   THPF_MainFrame_MPBar_SB:SetValue(curValue);
   THPF_MainFrame_MPBar_SB_SBX:SetText( curValue .. "/" .. maxValue );
   THPF_MainFrame_MPBar_SB_SBP:SetText( math.floor((curValue/maxValue)*100).."%" );
   if (curValue==maxValue) then
      THPF_MPFull = 1;
   else
      THPF_MPFull = nil;
   end
   THPF_MaybeStartFade();
end

function THPF_MaybeStartFade()
   if THPF_HPFull and THPF_MPFull then
      if not THPF_IsFadingOut and THPF_MainFrame:GetAlpha()==1 and THPF_Vars and THPF_Vars["fadeplayerframe"] then
         --ChatFrame1:AddMessage("fading out");
         THAnim.AnimateFrame(THPF_MainFrame, "SetAlpha", 1, THPF_FADED_OUT_ALPHA, 1, function() THPF_IsFadingOut = nil; end);
         THPF_IsFadingOut = 1;
      end
   else
      if not THPF_IsFadingIn and THPF_MainFrame:GetAlpha() < (THPF_FADED_OUT_ALPHA+0.01) then
         --ChatFrame1:AddMessage("fading in");
         THAnim.AnimateFrame(THPF_MainFrame, "SetAlpha", THPF_FADED_OUT_ALPHA, 1, 0.33, function() THPF_IsFadingIn = nil; end);
         THPF_IsFadingIn = 1;
      end
   end
end

function THPF_FactionUpdate()
   local factionGroup = UnitFactionGroup("player");
   if ( UnitIsPVPFreeForAll("player") ) then
      THPF_MainFrame_Faction_PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
      THPF_MainFrame_Faction:Show();
      -- THPF_MainFrame_PlayerDesc:SetPoint("BOTTOMRIGHT", "THPF_MainFrame", "BOTTOMRIGHT", -28, 0);
      THPF_MainFrame_PlayerName:SetPoint("TOPRIGHT", "THPF_MainFrame", "TOPRIGHT", -28, -2);
   elseif ( factionGroup and UnitIsPVP("player") ) then
      THPF_MainFrame_Faction_PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
      THPF_MainFrame_Faction:Show();
      -- THPF_MainFrame_PlayerDesc:SetPoint("BOTTOMRIGHT", "THPF_MainFrame", "BOTTOMRIGHT", -28, 0);
      THPF_MainFrame_PlayerName:SetPoint("TOPRIGHT", "THPF_MainFrame", "TOPRIGHT", -28, -2);
   else
      THPF_MainFrame_Faction:Hide();
      -- THPF_MainFrame_PlayerDesc:SetPoint("BOTTOMRIGHT", "THPF_MainFrame", "BOTTOMRIGHT", -8, 0);
      THPF_MainFrame_PlayerName:SetPoint("TOPRIGHT", "THPF_MainFrame", "TOPRIGHT", -8, -2);
   end
end

THPF_InCombat = 0;

function THPF_StatusUpdate()
   if ( IsResting() ) then
      THPF_MainFrame_State_StateIcon:SetTexCoord(0, 0.5, 0, 0.5);
      THPF_MainFrame_State_StateIcon:Show();
      THPF_MainFrame_State:Show();
   --elseif ( THPF_InCombat > 0 ) then
   elseif ( UnitAffectingCombat("player") ) then
      THPF_MainFrame_State_StateIcon:SetTexCoord(0.5, 1, 0, 0.5);
      THPF_MainFrame_State_StateIcon:Show();
      THPF_MainFrame_State:Show();
   else
      THPF_MainFrame_State_StateIcon:Hide();
      THPF_MainFrame_State:Hide();
   end
end

function THPF_LeaderUpdate()
   if ( UnitIsPartyLeader("player") ) then
      THPF_MainFrame_LeaderIcon:Show();
   else
      THPF_MainFrame_LeaderIcon:Hide();
   end
end

function THPF_OnEvent(event)
   if (event=="UNIT_HEALTH" or event=="UNIT_MAXHEALTH") then
      if (arg1=="player") then
         THPF_HPUpdate();
      elseif (arg1=="pet") then
         THPF_PetUpdate();
      end
   elseif (event=="UNIT_MANA" or
           event=="UNIT_RAGE" or
           event=="UNIT_FOCUS" or
           event=="UNIT_ENERGY" or
           event=="UNIT_HAPPINESS" or
           event=="UNIT_MAXMANA" or
           event=="UNIT_MAXRAGE" or
           event=="UNIT_MAXFOCUS" or
           event=="UNIT_MAXENERGY" or
           event=="UNIT_MAXHAPPINESS") then
      if (arg1 == "player") then
         THPF_MPUpdate();
      elseif (arg1 == "pet") then
         THPF_PetUpdate();
      end
   elseif (event=="UNIT_NAME_UPDATE") then
      if (arg1 == "player") then
         THPF_NameUpdate();
      elseif (arg1 == "pet") then
         THPF_PetUpdate();
      end
   elseif (event=="UNIT_PORTRAIT_UPDATE") then
      if (arg1 == "player") then
         THPF_PortraitUpdate();
      elseif (arg1 == "pet") then
         THPF_PetPortraitUpdate();
      end
   elseif (event=="UNIT_DISPLAYPOWER") then
      if (arg1 == "player") then
         THPF_SetupDisplayPower();
      elseif (arg1 == "pet") then
         THPF_PetUpdate();
      end
   elseif (event=="UNIT_LEVEL") then
      if (arg1 == "player") then
         THPF_LevelUpdate();
      elseif (arg1 == "pet") then
         THPF_PetUpdate();
      end
   elseif (event=="UNIT_COMBAT") then
      if (arg1 == "player") then
         CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5);
      end
   elseif (event=="UNIT_FACTION" or event=="UNIT_PVP_UPDATE") then
      if (arg1 == "player") then
         THPF_FactionUpdate();
      end
   elseif (event=="PLAYER_FLAGS_CHANGED") then
      if (arg1 == "player") then
         THPF_LeaderUpdate();
      end
   elseif (event=="PARTY_LEADER_CHANGED" or event=="RAID_ROSTER_UPDATE") then
      THPF_LeaderUpdate();
   elseif (event=="PLAYER_ENTER_COMBAT" or event=="PLAYER_REGEN_DISABLED") then
      THPF_InCombat = THPF_InCombat + 1;
      THPF_StatusUpdate();
   elseif (event=="PLAYER_LEAVE_COMBAT" or event=="PLAYER_REGEN_ENABLED") then
      THPF_InCombat = THPF_InCombat - 1;
      if THPF_InCombat < 0 then
         THPF_InCombat = 0;
      end
      THPF_StatusUpdate();
   elseif (event=="PLAYER_UPDATE_RESTING") then
      THPF_StatusUpdate();
   elseif (event=="UNIT_AURA") then
      if (arg1=="pet") then
         THPF_PetAuraUpdate();
      end
   elseif (event=="UNIT_PET") then
      THPF_PetUpdate();
   elseif (event=="CHAT_MSG_SYSTEM") then
      if ( string.find(arg1, "You are now AFK") ) then
         THPF_IsAFK = true;
         THPF_IsDND = false;
         THPF_NameUpdate();
      elseif ( string.find(arg1, "You are no longer AFK") ) then
         THPF_IsAFK = false;
         THPF_NameUpdate();
      elseif ( string.find(arg1, "You are now DND") ) then
         THPF_IsAFK = false;
         THPF_IsDND = true;
         THPF_NameUpdate();
      elseif ( string.find(arg1, "You are no longer marked DND") ) then
         THPF_IsDND = false;
         THPF_NameUpdate();
      end
   elseif (event=="UPDATE_FACTION") then
      THPF_ExpBarUpdate();
   elseif (event=="PLAYER_XP_UPDATE" or event=="UPDATE_EXHAUSTION" or event=="PLAYER_LEVEL_UP") then
      THPF_ExpBarUpdate();
   elseif (event=="PLAYER_ENTERING_WORLD") then
      THPF_InitializeSavedVars();
      THPF_SetBackgroundGradient();
      THPF_MainFrame_Pet:RegisterForClicks("LeftButtonUp", "RightButtonUp");
      THPF_DisplayUpdate();
      THPF_PetUpdate();
      THPF_ExpBarUpdate();

      THPF_CheckAFKDNDStatus();
   end
end

function THPF_CheckAFKDNDStatus()
   THPF_IsAFK = false;
   THPF_IsDND = false;
   THPF_NameUpdate();
end

function THPF_ExpBarUpdate()
   local numFactions = GetNumFactions();
   local i;
   for i = 1, numFactions do
      local name, desc, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(i);
      if (isWatched) then
         barMax = barMax - barMin;
         barValue = barValue - barMin;
         barMin = 0;
         if not MouseIsOver(THPF_MainFrame_ExpBar) then
            THPF_MainFrame_ExpBar_SB_SBX:SetText( barValue .. "/" .. barMax );
            THPF_MainFrame_ExpBar_SB_SBP:SetText( math.floor((barValue/barMax)*100).."%" );
         else
            THPF_MainFrame_ExpBar_SB_SBX:SetText( name );
            THPF_MainFrame_ExpBar_SB_SBP:SetText( "" );
         end
         THPF_MainFrame_ExpBar_SB:SetMinMaxValues(0, barMax);
         THPF_MainFrame_ExpBar_SB:SetValue(barValue);
         local color = FACTION_BAR_COLORS[standingID];
         THPF_MainFrame_ExpBar_SB:SetStatusBarColor(color.r, color.g, color.b);

         THPF_MainFrame_ExpBar_SBUnder:Hide();

         THPF_MainFrame_ExpBar:Show();
         THPF_FixPetAnchor();
         return;
      end
   end

   if (UnitLevel("player") < 60) or THPF_Vars["forcevisible"] then
      local curXP = UnitXP("player");
      local maxXP = UnitXPMax("player");
      local exhThreshold = GetXPExhaustion();
      local exhStateID, exhStateName, exhStateMul = GetRestState();

      THPF_MainFrame_ExpBar_SB:SetStatusBarColor(0, 0.75, 0.75);
      THPF_MainFrame_ExpBar_SB:SetMinMaxValues(0, maxXP);
      THPF_MainFrame_ExpBar_SB:SetValue(curXP);
      if not MouseIsOver(THPF_MainFrame_ExpBar) then
         THPF_MainFrame_ExpBar_SB_SBX:SetText( curXP .. "/" .. maxXP );
         THPF_MainFrame_ExpBar_SB_SBP:SetText( math.floor((curXP/maxXP)*100).."%" );
      else
         THPF_MainFrame_ExpBar_SB_SBX:SetText( "Exp to Level "..(UnitLevel("player")+1) );
         THPF_MainFrame_ExpBar_SB_SBP:SetText( "" );
      end

      if (not exhThreshold) then
         THPF_MainFrame_ExpBar_SBUnder:Hide();
      else
         local exhCurXP = curXP + exhThreshold;
         if (exhCurXP > maxXP) then
            exhCurXP = maxXP;
         end
         THPF_MainFrame_ExpBar_SBUnder:SetStatusBarColor(0, 0, 0.75);
         THPF_MainFrame_ExpBar_SBUnder:SetMinMaxValues(0, maxXP);
         THPF_MainFrame_ExpBar_SBUnder:SetValue(exhCurXP);
         THPF_MainFrame_ExpBar_SBUnder:Show();
      end

      THPF_MainFrame_ExpBar:Show();
      THPF_FixPetAnchor();
      return;
   end

   THPF_MainFrame_ExpBar:Hide();
   THPF_FixPetAnchor();
end

function THPF_FixPetAnchor()
   if not THPF_Vars == nil then
      if not THPF_Vars["detached_pet"] then
         if THPF_MainFrame_ExpBar:IsVisible() then
            THPF_MainFrame_Pet:ClearAllPoints();
            THPF_MainFrame_Pet:SetPoint("TOPLEFT", "THPF_MainFrame_ExpBar", "BOTTOMLEFT", 0, 0);
            THPF_MainFrame_Pet:SetPoint("TOPRIGHT", "THPF_MainFrame_ExpBar", "BOTTOMRIGHT", 0, 0);
         else
            THPF_MainFrame_Pet:ClearAllPoints();
            THPF_MainFrame_Pet:SetPoint("TOPLEFT", "THPF_MainFrame_MPBar", "BOTTOMLEFT", 0, 0);
            THPF_MainFrame_Pet:SetPoint("TOPRIGHT", "THPF_MainFrame_MPBar", "BOTTOMRIGHT", 0, 0);
         end
      end
   end
end

--[[
local THPF_OldSetWatchedFactionIndex = SetWatchedFactionIndex;

function THPF_SetWatchedFactionIndex(idx)
   THPF_OldSetWatchedFactionIndex(idx);
   THPF_ExpBarUpdate();
end

SetWatchedFactionIndex = THPF_SetWatchedFactionIndex;
--]]

function THPF_PetAuraUpdate()
   local forceshow = THPF_Vars["forcevisible"];
   local i, debuff, buff, button, countel, thisDebuffCount;
   local buffCount = 0;
   local debuffCount = 0;

   for i=1,24 do
      buff = UnitBuff("pet", i);
      button = getglobal("THPF_MainFrame_Pet_Buff"..i);
      if (not buff) and forceshow then
         buff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
      end
      if (buff) then
         getglobal("THPF_MainFrame_Pet_Buff"..i.."_Icon"):SetTexture(buff);
         button:SetWidth(20.5);
         button:SetHeight(20.5);
         button:Show();
         button.id = i;
         buffCount = buffCount + 1;
      else
         button:Hide();
      end
   end
   for i=1,16 do
      debuff, thisDebuffCount = UnitDebuff("pet", i);
      button = getglobal("THPF_MainFrame_Pet_Debuff"..i);
      if (not debuff) and forceshow then
         debuff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
         thisDebuffCount = 1;
      end
      if (debuff) then
         getglobal("THPF_MainFrame_Pet_Debuff"..i.."_Icon"):SetTexture(debuff);
         countel = getglobal("THPF_MainFrame_Pet_Debuff"..i.."_Count");
         if (thisDebuffCount > 1) then
            countel:SetText(debuffCount);
            countel:Show();
         else
            countel:Hide();
         end
         button:Show();
         button.id = i;
         debuffCount = debuffCount + 1;
      else
         button:Hide();
      end
   end

   if (buffCount > 0) then
      THPF_MainFrame_Pet_Buff1:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet_MPBar", "BOTTOMRIGHT", 0, -3);
      if (buffCount > 8) then
         THPF_MainFrame_Pet_Debuff1:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet_Buff9", "BOTTOMRIGHT", 0, -2);
      else
         THPF_MainFrame_Pet_Debuff1:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet_Buff1", "BOTTOMRIGHT", 0, -2);
      end
   else
      THPF_MainFrame_Pet_Debuff1:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet_MPBar", "BOTTOMRIGHT", 0, -3);
   end
   local debuffSize = 20.5;
   if (debuffCount <= 5) then
      debuffSize = 25;
   end
   for i=1,16 do
      button = getglobal("THPF_MainFrame_Pet_Debuff"..i);
      button:SetWidth(debuffSize);
      button:SetHeight(debuffSize);
   end
end

function THPF_SetPetDummyValues()
   -- Name
   THPF_MainFrame_Pet_Name:SetTextColor(200/255, 228/255, 255/255);
   THPF_MainFrame_Pet_Name:SetText( "Pet" );
   -- Level
   THPF_MainFrame_Pet_Name:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet_Level", "TOPLEFT", 0, 0);
   THPF_MainFrame_Pet_Level:SetText(" Lv");
   -- HP
   THPF_MainFrame_Pet_HPBar_SB:SetMinMaxValues(0,1);
   THPF_MainFrame_Pet_HPBar_SB:SetValue(1);
   THPF_MainFrame_Pet_HPBar_SB:SetStatusBarColor( 1, 0, 0 );
   THPF_MainFrame_Pet_HPBar_SB_Text:SetText( "" );
   -- MP
   THPF_MainFrame_Pet_MPBar_SB:SetMinMaxValues(0,1);
   THPF_MainFrame_Pet_MPBar_SB:SetValue(1);
   THPF_MainFrame_Pet_MPBar_SB:SetStatusBarColor( 0, 0, 1 );
   THPF_MainFrame_Pet_MPBar_SB_Text:SetText( "" );
   -- Happiness
   THPF_MainFrame_Pet_Happiness_Texture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
   THPF_MainFrame_Pet_Happiness:Show();
   THPF_MainFrame_Pet_Happiness.tooltip = nil;
   THPF_MainFrame_Pet_Happiness.tooltipDamage = nil;
   -- Portrait
   THPF_MainFrame_Pet_PlayerModel:SetRotation(0.61);
   THPF_MainFrame_Pet_PlayerModel:SetUnit("player");
   THPF_MainFrame_Pet_PlayerModel:SetCamera(0);
   -- Auras
   THPF_PetAuraUpdate();
end

function THPF_PetUpdate()
   local petname = UnitName("pet");
   if (not petname) then
      if THPF_Vars["forcevisible"] then
         THPF_SetPetDummyValues();
         THPF_MainFrame_Pet:Show();
      else
         THPF_MainFrame_Pet:Hide();
      end
      return;
   end

   local petmana = UnitMana("pet");
   local petmanamax = UnitManaMax("pet");
   local pethealth = UnitHealth("pet");
   local pethealthmax = UnitHealthMax("pet");
   local petlevel = UnitLevel("pet");
   local petpower = UnitPowerType("pet");
   local petxp, petxpmax = GetPetExperience();
  
   if (not THPF_MainFrame_Pet:IsVisible()) then
      THPF_PetPortraitUpdate();
      THPF_PetAuraUpdate();
   end 
   THPF_MainFrame_Pet:Show();
   THPF_MainFrame_Pet_Name:SetTextColor(200/255, 228/255, 255/255);
   THPF_MainFrame_Pet_Name:SetText(petname);
   if (petlevel>=1 and petlevel<=59) then
      THPF_MainFrame_Pet_Name:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet_Level", "TOPLEFT", 0, 0);
      THPF_MainFrame_Pet_Level:SetText(" "..petlevel);
   else
      THPF_MainFrame_Pet_Name:SetPoint("TOPRIGHT", "THPF_MainFrame_Pet", "TOPRIGHT", -5, -5);
      THPF_MainFrame_Pet_Level:SetText("");
   end

   THPF_MainFrame_Pet_MPBar_SB:SetStatusBarColor( ManaBarColor[petpower].r, ManaBarColor[petpower].g, ManaBarColor[petpower].b );
   THPF_MainFrame_Pet_HPBar_SB:SetMinMaxValues(0, pethealthmax);
   THPF_MainFrame_Pet_MPBar_SB:SetMinMaxValues(0, petmanamax);
   THPF_SetHPBarColor(THPF_MainFrame_Pet_HPBar_SB, 0, pethealthmax, pethealth);
   THPF_MainFrame_Pet_HPBar_SB:SetValue(pethealth);
   THPF_MainFrame_Pet_MPBar_SB:SetValue(petmana);

   if ( UnitIsDeadOrGhost("pet") ) then
      THPF_MainFrame_Pet_HPBar_SB_Text:SetText( "Dead" );
      THPF_MainFrame_Pet_MPBar_SB_Text:SetText( "" );
   else
      THPF_MainFrame_Pet_HPBar_SB_Text:SetText( pethealth .. "/" .. pethealthmax );
      THPF_MainFrame_Pet_MPBar_SB_Text:SetText( petmana .. "/" .. petmanamax );
   end

   local happiness, damagePercentage, loyaltyRate = GetPetHappiness();
   if ( happiness == 1 ) then
      THPF_MainFrame_Pet_Happiness_Texture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
      THPF_MainFrame_Pet_Happiness:Show();
   elseif ( happiness == 2 ) then
      THPF_MainFrame_Pet_Happiness_Texture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
      THPF_MainFrame_Pet_Happiness:Show();
   elseif ( happiness == 3 ) then
      THPF_MainFrame_Pet_Happiness_Texture:SetTexCoord(0, 0.1875, 0, 0.359375);
      THPF_MainFrame_Pet_Happiness:Hide();
   else
      THPF_MainFrame_Pet_Happiness:Hide();
   end
   if (happiness ~= nil) then
      THPF_MainFrame_Pet_Happiness.tooltip = getglobal("PET_HAPPINESS"..happiness);
      THPF_MainFrame_Pet_Happiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
      if (loyaltyRate < 0) then
         THPF_MainFrame_Pet_Happiness.tooltipLoyalty = getglobal("LOSING_LOYALTY");
      elseif (loyaltyRate > 0) then
         THPF_MainFrame_Pet_Happiness.tooltipLoyalty = getglobal("GAINING_LOYALTY");
      else
         THPF_MainFrame_Pet_Happiness.tooltipLoyalty = nil;
      end
   end
end

function THPF_PetPortraitUpdate()
   THPF_MainFrame_Pet_PlayerModel:SetRotation(0.61);
   THPF_MainFrame_Pet_PlayerModel:SetUnit("pet");
   THPF_MainFrame_Pet_PlayerModel:SetCamera(0);
end

function THPF_InitializeSavedVars()
   if not THPF_Vars then
      THPF_Vars = {};
   end
   if THPF_Vars["scale"] and (THPF_Vars["scale"]+0) > 0 then
      -- Import previous scale
      THPF_Vars["scale_player"] = THPF_Vars["scale"];
      THPF_Vars["scale_target"] = THPF_Vars["scale"];
      THPF_Vars["scale_tot"] = THPF_Vars["scale"];
      THPF_Vars["scale_pet"] = THPF_Vars["scale"];
      THPF_Vars["scale_party0"] = THPF_Vars["scale"];
      THPF_Vars["scale_party1"] = THPF_Vars["scale"];
      THPF_Vars["scale_party2"] = THPF_Vars["scale"];
      THPF_Vars["scale_party3"] = THPF_Vars["scale"];
      THPF_Vars["scale_party4"] = THPF_Vars["scale"];
      THPF_Vars["scale"] = nil;
   end
   if THPF_Vars["scale_player"] then
      THPF_SetFrameScale( "player", THPF_Vars["scale_player"] );
      -- Initialize new settings...
      if not THPF_Vars["scale_party"] then
         THPF_Vars["scale_party0"] = THPF_Vars["scale_player"];
         THPF_Vars["scale_party1"] = THPF_Vars["scale_player"];
         THPF_Vars["scale_party2"] = THPF_Vars["scale_player"];
         THPF_Vars["scale_party3"] = THPF_Vars["scale_player"];
         THPF_Vars["scale_party4"] = THPF_Vars["scale_player"];
      end
   end
   if THPF_Vars["scale_target"] then
      THPF_SetFrameScale( "target", THPF_Vars["scale_target"] );
   end
   if THPF_Vars["scale_tot"] then
      THPF_SetFrameScale( "tot", THPF_Vars["scale_tot"] );
   end
   if THPF_Vars["scale_pet"] then
      THPF_SetFrameScale( "pet", THPF_Vars["scale_pet"] );
   end
   if THPF_Vars["scale_party0"] then
      THPF_SetFrameScale( "party0", THPF_Vars["scale_party0"] );
   end
   if THPF_Vars["scale_party1"] then
      THPF_SetFrameScale( "party1", THPF_Vars["scale_party1"] );
   end
   if THPF_Vars["scale_party2"] then
      THPF_SetFrameScale( "party2", THPF_Vars["scale_party2"] );
   end
   if THPF_Vars["scale_party3"] then
      THPF_SetFrameScale( "party3", THPF_Vars["scale_party3"] );
   end
   if THPF_Vars["scale_party4"] then
      THPF_SetFrameScale( "party4", THPF_Vars["scale_party4"] );
   end
   if not THPF_Vars["isset_showpartyframeinraid"] then
      THPF_Vars["showpartyframeinraid"] = nil;
      THPF_Vars["isset_showpartyframeinraid"] = 1;
   end
   if not THPF_Vars["isset_filterbuffs"] then
      THPF_Vars["filterbuffs"] = 1;
      THPF_Vars["isset_filterbuffs"] = 1;
   end
   if not THPF_Vars["isset_filterdebuffs"] then
      THPF_Vars["filterdebuffs"] = 1;
      THPF_Vars["isset_filterdebuffs"] = 1;
   end
   if not THPF_Vars["isset_showselfinparty"] then
      THPF_Vars["showselfinparty"] = 1;
      THPF_Vars["isset_showselfinparty"] = 1;
   end
   if not THPF_Vars["isset_highlightpartytarget"] then
      THPF_Vars["highlightpartytarget"] = 1;
      THPF_Vars["isset_highlightpartytarget"] = 1;
   end
   if not THPF_Vars["isset_partyfadedirection"] then
      THPF_Vars["partyfadedirection"] = "right";
      THPF_Vars["isset_partyfadedirection"] = 1;
   end
   if not THPF_Vars["isset_playerfadedirection"] then
      THPF_Vars["playerfadedirection"] = "down";
      THPF_Vars["isset_playerfadedirection"] = 1;
   end
   if not THPF_Vars["isset_targetfadedirection"] then
      THPF_Vars["targetfadedirection"] = "down";
      THPF_Vars["isset_targetfadedirection"] = 1;
   end
   if not THPF_Vars["isset_totfadedirection"] then
      THPF_Vars["totfadedirection"] = "down";
      THPF_Vars["isset_totfadedirection"] = 1;
   end
   if not THPF_Vars["isset_petfadedirection"] then
      THPF_Vars["petfadedirection"] = "down";
      THPF_Vars["isset_petfadedirection"] = 1;
   end
end

function THPF_SetVar(varname, varvalue)
   --if varvalue then
   --   ChatFrame1:AddMessage("setting "..varname.." to: ".. varvalue);
   --else
   --   ChatFrame1:AddMessage("setting "..varname.." to nil");
   --end
   THPF_Vars[varname] = varvalue;
   if varname == "showpartyframeinraid" or 
        varname == "filterbuffs" or 
        varname == "filterdebuffs" or 
        varname == "showselfinparty" then
      THGF_UpdateAll(1);
   end
   if varname == "highlightpartytarget" or varname == "partyfadedirection" then
      THGF_UpdateTargetHighlight();
   end
   if varname == "playerfadedirection" or varname == "petfadedirection" then
      THPF_SetBackgroundGradient();
   end
   if varname == "targetfadedirection" or varname == "totfadedirection" then
      THTF_SetBackgroundGradient();
   end
end

function THPF_SetFrameScale(what, scale)
   THPF_Vars["scale_"..what] = scale;
   if what=="player" then
      THPF_MainFrame:SetScale(scale);
   elseif what=="target" then
      THTF_TargetFrame:SetScale(scale);
   elseif what=="tot" then
      THTF_TargetFrame_ToT:SetScale(scale);
   elseif what=="pet" then
      THPF_MainFrame_Pet:SetScale(scale);
   elseif what=="party0" then
      THGF_PartyMember0:SetScale(scale);
   elseif what=="party1" then
      THGF_PartyMember1:SetScale(scale);
   elseif what=="party2" then
      THGF_PartyMember2:SetScale(scale);
   elseif what=="party3" then
      THGF_PartyMember3:SetScale(scale);
   elseif what=="party4" then
      THGF_PartyMember4:SetScale(scale);
   end
end

function THPF_OnUpdate(elapsed)
   CombatFeedback_OnUpdate(elapsed);
end

function THPF_MouseUpHandler()
   if (THPF_MainFrame.isMoving) then
      THPF_MainFrame:StopMovingOrSizing();
      THPF_MainFrame.isMoving = false;
   end
end

function THPF_MouseDownHandler()
   if THPF_Vars["unlock_player"] then
      if (arg1=="LeftButton") then
         THPF_MainFrame:StartMoving();
         THPF_MainFrame.isMoving = true;
      end
   end
end

function THPF_OnClick(button)
   if ( SpellIsTargeting() and button == "RightButton" ) then
      SpellStopTargeting();
      return;
   end
   if ( button == "LeftButton" ) then
      if ( SpellIsTargeting() ) then
         SpellTargetUnit("player");
      elseif ( CursorHasItem() ) then
         AutoEquipCursorItem();
      else
         TargetUnit("player");
      end
   else
      -- ChatFrame1:AddMessage("here");
      -- ToggleDropDownMenu(1, nil, THPF_DropDown, "THPF_MainFrame", 40, 0);
      -- ToggleDropDownMenu(1, nil, THPF_DropDown, "cursor");
      ToggleDropDownMenu(1, nil, THPF_DropDown, "cursor");
      return;
   end
end

function THPF_Pet_MouseUpHandler()
   if (THPF_MainFrame_Pet.isMoving) then
      THPF_MainFrame_Pet:StopMovingOrSizing();
      THPF_MainFrame_Pet.isMoving = false;
   end
end

function THPF_Pet_MouseDownHandler()
   if THPF_Vars["unlock_pet"] then
      if (arg1=="LeftButton") then
         THPF_Vars["detached_pet"] = 1;
         THPF_MainFrame_Pet:StartMoving();
         THPF_MainFrame_Pet.isMoving = true;
      end
   end
end

function THPF_Pet_OnClick(button)
   if ( SpellIsTargeting() and button == "RightButton" ) then
      SpellStopTargeting();
      return;
   end
   if ( button == "LeftButton" ) then
      if ( SpellIsTargeting() ) then
         SpellTargetUnit("pet");
      elseif ( CursorHasItem() ) then
         DropItemOnUnit("pet");
      else
         TargetUnit("pet");
      end
   else
      ToggleDropDownMenu(1, nil, THPF_Pet_DropDown, "cursor");
      return;
   end
end

function THPF_DropDown_OnLoad()
   UIDropDownMenu_Initialize(this, THPF_DropDown_Initialize, "MENU");
end

function THPF_DropDown_Initialize()
    UnitPopup_ShowMenu(THPF_DropDown, "SELF", "player");
end

function THPF_Pet_DropDown_OnLoad()
   UIDropDownMenu_Initialize(this, THPF_Pet_DropDown_Initialize, "MENU");
end

function THPF_Pet_DropDown_Initialize()
    UnitPopup_ShowMenu(THPF_Pet_DropDown, "PET", "pet");
end
