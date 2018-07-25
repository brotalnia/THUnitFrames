
THTF_FADEIN_TIME = 0.125;
THTF_FADEOUT_TIME = 0.125;

-- THTF_TOT_UPDATE_TIME = 0.125;
THTF_TOT_UPDATE_TIME = 0;

THTF_IsShowing = false;
THTF_IsHiding = false;

THTF_HasMobHealth = false;
THTF_HasMyRolePlay = false;
THTF_MOBHEALTH_UPDATE_TIME = 0.50;

THTF_TAP_UPDATE_TIME = 0.25;

function THTF_OnLoad()
   if (type(MobHealth_GetTargetCurHP)=="function" and
       type(MobHealth_GetTargetMaxHP)=="function") then
      THTF_HasMobHealth = true;
      if (type(MobHealthText)=="table") then
         MobHealthText:Hide();
      end
   end
   if (type(mrpUser)=="function" and
       type(mrpFlagRSPUser)=="function") then
      THTF_HasMyRolePlay = true;
   end

   THTF_TargetFrame:SetAlpha(0);

   CombatFeedback_Initialize(THTF_TargetFrame_PlayerModel_PHI, 30);

   -- THTF_SetBackgroundGradient();
   THTF_DisplayUpdate();

   this:RegisterForClicks("LeftButtonUp", "RightButtonUp");

   TargetFrame:Hide();

   this:RegisterEvent("PLAYER_ENTERING_WORLD");
   -- this:RegisterEvent("PLAYER_TARGET_CHANGED");
   this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
   this:RegisterEvent("UNIT_DISPLAYPOWER");
   this:RegisterEvent("UNIT_PVP_UPDATE");
   this:RegisterEvent("UNIT_LEVEL");
   this:RegisterEvent("UNIT_NAME_UPDATE");
   this:RegisterEvent("UNIT_FACTION");
   this:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
   this:RegisterEvent("UNIT_AURA");
   this:RegisterEvent("PLAYER_FLAGS_CHANGED");
   this:RegisterEvent("PARTY_MEMBERS_CHANGED");
   this:RegisterEvent("PLAYER_COMBO_POINTS");

   this:RegisterEvent("UNIT_HEALTH");
   this:RegisterEvent("UNIT_MAXHEALTH");

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
   this:RegisterEvent("UNIT_COMBAT");
   this:RegisterEvent("RAID_TARGET_UPDATE");
end

function THTF_SetBackgroundGradient()
   if THPF_Vars["targetfadedirection"] == "up" then
      THTF_TargetFrame_GradientBG:SetGradientAlpha("VERTICAL",0,0,0,1,0,0,0,0);
   elseif THPF_Vars["targetfadedirection"] == "left" then
      THTF_TargetFrame_GradientBG:SetGradientAlpha("HORIZONTAL",0,0,0,0,0,0,0,1);
   elseif THPF_Vars["targetfadedirection"] == "right" then
      THTF_TargetFrame_GradientBG:SetGradientAlpha("HORIZONTAL",0,0,0,1,0,0,0,0);
   else
      THTF_TargetFrame_GradientBG:SetGradientAlpha("VERTICAL",0,0,0,0,0,0,0,1);
   end
   if THPF_Vars["totfadedirection"] == "up" then
      THTF_TargetFrame_ToT_BGTexture:SetGradientAlpha("VERTICAL",0,0,0,1,0,0,0,0);
   elseif THPF_Vars["totfadedirection"] == "left" then
      THTF_TargetFrame_ToT_BGTexture:SetGradientAlpha("HORIZONTAL",0,0,0,0,0,0,0,1);
   elseif THPF_Vars["totfadedirection"] == "right" then
      THTF_TargetFrame_ToT_BGTexture:SetGradientAlpha("HORIZONTAL",0,0,0,1,0,0,0,0);
   else
      THTF_TargetFrame_ToT_BGTexture:SetGradientAlpha("VERTICAL",0,0,0,0,0,0,0,1);
   end

   THTF_TargetFrame_HPBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
   THTF_TargetFrame_MPBar_BGTexture:SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
end

function THTF_SetDummyValues()
   -- Dummy name and display
   THTF_TargetFrame_PlayerName:SetTextColor(200/255, 228/255, 255/255);
   THTF_TargetFrame_PlayerName:SetText( "Target" );
   THTF_TargetFrame_PlayerDesc:SetTextColor(255/255, 255/255, 255/255)
   THTF_TargetFrame_PlayerDesc:SetText( "You have nothing targetted" );
   -- Tap Color
   THTF_TargetFrame_PlayerModel_PHIBG:SetGradient("VERTICAL", 1, 1, 1, 0, 0, 0);
   -- Portrait
   THTF_TargetFrame_PlayerModel:Show();
   THTF_TargetFrame_PlayerModel:SetRotation(0.61);
   THTF_TargetFrame_PlayerModel:SetUnit("player");
   THTF_TargetFrame_PlayerModel:SetCamera(0);
   -- HP
   THTF_TargetFrame_HPBar_SB:SetValue(0);
   THTF_TargetFrame_HPBar_SB_SBX:SetText( "" );
   THTF_TargetFrame_HPBar_SB_SBP:SetText( "" );
   -- MP
   THTF_TargetFrame_MPBar_SB:SetValue(0);
   THTF_TargetFrame_MPBar_SB_SBX:SetText( "" );
   THTF_TargetFrame_MPBar_SB_SBP:SetText( "" );
   --- Auras
   THTF_AuraUpdate();
--[[
   for i=1, 16 do
      getglobal("THTF_TargetFrame_Buff"..i):Hide();
   end
   for i=1, 16 do
      getglobal("THTF_TargetFrame_Debuff"..i):Hide();
   end
--]]
   -- Faction    
   THTF_SetNoFaction();
   -- Party Leader
   THTF_TargetFrame_LeaderIcon:Hide();
   -- Combo Points
   THTF_TargetFrame_ComboText:Hide();
end

function THTF_DisplayUpdate()
   -- ChatFrame1:AddMessage("here displayupdate");
   if ( UnitExists("target") and UnitName("target") ) then
      THTF_NameUpdate();
      THTF_LevelClassUpdate();
      THTF_TapColorUpdate();
      THTF_PortraitUpdate();
      THTF_SetupDisplayPower();
      THTF_HPUpdate();
      THTF_MPUpdate();
      THTF_AuraUpdate();
      THTF_FactionUpdate();
      THTF_PartyLeaderUpdate();
      THTF_ComboPointUpdate();
      THTF_RaidTargetIconUpdate();
      THTF_RoleplayUpdate();

      THTF_IsShowing = true;
      THTF_IsHiding = false;
   else
      THTF_IsShowing = false;
      THTF_IsHiding = true;
   end
end

function THTF_RoleplayUpdate()
   if THTF_HasMyRolePlay and (mrpUser(UnitName("target")) or mrpFlagRSPUser(UnitName("target"))) then
      THTF_TargetFrame_RoleplayIcon:Show();
   else
      THTF_TargetFrame_RoleplayIcon:Hide();
   end
end

function THTF_RoleplayIconClicked()
   if THTF_HasMyRolePlay then
      mrpViewTargetCharacterSheet();
   end
end

function THTF_RaidTargetIconUpdate()
   if (UnitExists("target")) then
   local index = GetRaidTargetIndex("target");
   if (index) then
      SetRaidTargetIconTexture(THTF_TargetFrame_RaidTargetIcon_Texture, index);
      THTF_TargetFrame_RaidTargetIcon:Show();
   else
      THTF_TargetFrame_RaidTargetIcon:Hide();
   end
   end
end

function THTF_GetUnitModel(unit)
   return "Character\\Human\\Female\\HumanFemale.mdx";
end

function THTF_PortraitUpdate()
   THTF_TargetFrame_PlayerModel:Show();
   THTF_TargetFrame_PlayerModel:SetRotation(0.61);
   if UnitIsVisible("target") then
      THTF_TargetFrame_PlayerModel:SetUnit("target");
   else
      THTF_TargetFrame_PlayerModel:SetModel( THTF_GetUnitModel("target") );
   end
   THTF_TargetFrame_PlayerModel:SetCamera(0);
end

function THUF_UnitDisplayName(unit)
   local uName = UnitName(unit);
   if not THTF_HasMyRolePlay then
      return uName;
   end
   local mrpPlayerIndex = nil;
   local mrpFlagRSPPlayerIndex = nil;
   for i = 1, table.getn(mrpPlayerList) do
      if (mrpPlayerList[i].CharacterName == uName) then
         mrpPlayerIndex = i;
         break;
      end
   end
   for i = 1, table.getn(mrpFlagRSPPlayerList) do
      if (mrpFlagRSPPlayerList[i].CharacterName == uName) then
         mrpFlagRSPPlayerIndex = i;
         break;
      end
   end

   if (mrpPlayerIndex ~= nil and mrpPlayerList[mrpPlayerIndex].Surname ~= "") then
      return uName.." ".. mrpPlayerList[mrpPlayerIndex].Surname;
   elseif (mrpFlagRSPPlayerIndex ~= nil and mrpFlagRSPPlayerList[mrpFlagRSPPlayerIndex].Surname ~= "") then
      return uName.." ".. mrpFlagRSPPlayerList[mrpFlagRSPPlayerIndex].Surname;
   else
      return uName;
   end
end

function THTF_NameUpdate()
   if THTF_HasMyRolePlay and (mrpUser(UnitName("target")) or mrpFlagRSPUser(UnitName("target"))) then
      THTF_TargetFrame_PlayerName:SetTextColor(128/255, 255/255, 128/255);
   else
      THTF_TargetFrame_PlayerName:SetTextColor(200/255, 228/255, 255/255);
   end
   THTF_TargetFrame_PlayerName:SetText( THUF_UnitDisplayName("target") );
end

function THTF_NibbleToHex(n)
   if (n>=0 and n<=9) then
      return ""..n;
   elseif (n==10) then
      return "a";
   elseif (n==11) then
      return "b";
   elseif (n==12) then
      return "c";
   elseif (n==13) then
      return "d";
   elseif (n==14) then
      return "e";
   elseif (n==15) then
      return "f";
   else
      return "f";
   end
end

function THTF_NumToHex(n)
   local ln = math.mod(n, 16);
   local r = THTF_NibbleToHex(ln);
   ln = math.floor((n - ln)/16);
   r = THTF_NibbleToHex(ln) .. r;
   return r;
end

function THTF_LevelClassUpdate()
   if (not UnitExists("target")) then
      return;
   end
   local xfc = UnitClassification("target");
   local level = UnitLevel("target");
   local race = UnitRace("target");
   local class = UnitClass("target");
   local ctype = UnitCreatureType("target");
   local msg = "";
   if (not UnitIsPlayer("target")) then
      if (ctype) then
         if (ctype == "Not Specified") then
            msg = "Mob";
         else
            msg = ctype;
         end
      end
   else
      if (class) then
         msg = race.." "..class;
      end
   end
   if (level>0) then
      local color = GetDifficultyColor(level);
      local xr = math.floor( (color.r * 255)+0.5 );
      local xg = math.floor( (color.g * 255)+0.5 );
      local xb = math.floor( (color.b * 255)+0.5 );
      local colstr = "|cff" .. THTF_NumToHex(xr) ..
         THTF_NumToHex(xg) ..
         THTF_NumToHex(xb);
      msg = "Level "..colstr..level.."|r "..msg;
   end
   -- if (UnitIsPlusMob("target")) then
   --    msg = "Elite "..msg;
   -- end
   if (xfc=="rare") then
      msg = "Rare "..msg;
   elseif (xfc=="elite") then
      msg = "Elite "..msg;
   elseif (xfc=="rareelite") then
      msg = "Rare Elite "..msg;
   elseif (xfc=="worldboss") then
      msg = msg .. " Boss";
   end
   if (UnitIsDeadOrGhost("target")) then
      msg = "Dead "..msg;
   end
   THTF_TargetFrame_PlayerDesc:SetTextColor(255/255, 255/255, 255/255)
   THTF_TargetFrame_PlayerDesc:SetText(msg);
end

function THTF_TapColorUpdate()
   local r = 0.5;
   local g = 0.5;
   local b = 0.5;
   if (UnitIsDeadOrGhost("target")) then
      r = 0.2; g = 0.2; b = 0.2;
--[[
   elseif (UnitIsFriend("player", "target")) then
      r = 0; g = 0.6; b = 0;
   elseif (UnitIsTapped("target")) then
      r = 0.5; g = 0.5; b = 0.5;
   elseif (UnitIsEnemy("player", "target")) then
      r = 0.6; g = 0; b = 0;
   else
      r = 0.6; g = 0.6; b = 0;
   end
]]--
   elseif (UnitPlayerControlled("target")) then
      if (UnitCanAttack("target","player")) then
         if (not UnitCanAttack("player", "target")) then
            r = 0.0; g = 0.0; b = 0.6;
         else
            r = 0.6; g = 0.0; b = 0.0;
         end
      elseif (UnitCanAttack("player","target")) then
         r = 0.6; g = 0.6; b = 0.0;
      elseif (UnitIsPVP("target")) then
         r = 0.0; g = 0.6; b = 0.0;
      else
         r = 0.0; g = 0.0; b = 0.6;
      end
   elseif (UnitIsTapped("target") and not UnitIsTappedByPlayer("target")) then
      r = 0.5; g = 0.5; b = 0.5;
   else
      local reaction = UnitReaction("target","player");
      if (reaction) then
         r = UnitReactionColor[reaction].r;
         g = UnitReactionColor[reaction].g;
         b = UnitReactionColor[reaction].b;
      else
         r = 0.0; g = 0.0; b = 0.6;
      end
   end

   local rbot = r * 0.6;
   local gbot = g * 0.6;
   local bbot = b * 0.6;

   local rtop = r * 1.2;
   local gtop = g * 1.2;
   local btop = b * 1.2;
   if (rtop>1) then
      rtop = 1
   end
   if (gtop>1) then
      gtop = 1
   end
   if (btop>1) then
      btop = 1
   end
   -- ChatFrame1:AddMessage("r="..r..", g="..g..", b="..b);
   -- THTF_TargetFrame_PlayerModel_PHIBG:SetGradient("VERTICAL", 1, 1, 1, 0, 0, 0);
   THTF_TargetFrame_PlayerModel_PHIBG:SetGradient("VERTICAL", rtop, gtop, btop, rbot, gbot, bbot);
   -- THTF_TargetFrame_PlayerModel_PHIBG:SetVertexColor(r, g, b, 1);
end

function THTF_SetupDisplayPower()
   local upt = UnitPowerType("target");
   THTF_TargetFrame_MPBar_SB:SetStatusBarColor( ManaBarColor[upt].r, ManaBarColor[upt].g, ManaBarColor[upt].b );
end

function THTF_ShortenNumber(num)
   local res = num;
   if (num > 1000000) then
      res = string.format("%0.2fM", num/1000000);
   elseif (num > 100000) then
      res = string.format("%dK", math.floor(num/1000 + 0.5));
   end
   return res;
end

function THTF_UpdateMobHealth()
   local maxValue = UnitHealthMax("target");

   if (maxValue==100) then
      local bigText = "";
      if (UnitExists("target")) then
         local chp = MobHealth_GetTargetCurHP();
         local mhp = MobHealth_GetTargetMaxHP();
         if (not chp or chp==0) then
            chp = "???";
         else
            chp = THTF_ShortenNumber(chp);
         end
         if (not mhp or mhp==0) then
            mhp = "???";
         else
            mhp = THTF_ShortenNumber(mhp);
         end
         if (chp=="???" and mhp=="???") then
            bigText = "";
         else
            bigText = chp .. "/" .. mhp;
         end
      end
      THTF_TargetFrame_HPBar_SB_SBX:SetText( bigText );
   end
end

function THTF_HPUpdate()
   local curValue = UnitHealth("target");
   local maxValue = UnitHealthMax("target");
   local useMobHealth = false;

   local bigText = THTF_ShortenNumber(curValue) .. "/" .. THTF_ShortenNumber(maxValue);
   local smallText = math.floor((curValue/maxValue)*100).."%";
   if (maxValue==100) then
      bigText = smallText;
      smallText = "";
      if ( THTF_HasMobHealth ) then
         smallText = bigText;
         bigText = "";
         useMobHealth = true;
      end
   end

   THTF_TargetFrame_HPBar_SB:SetMinMaxValues(0, maxValue);
   THTF_TargetFrame_HPBar_SB:SetValue(curValue);
   THPF_SetHPBarColor(THTF_TargetFrame_HPBar_SB, 0, maxValue, curValue);
   THTF_TargetFrame_HPBar_SB_SBP:SetText( smallText );
   if (useMobHealth) then
      THTF_UpdateMobHealth();
   else
      THTF_TargetFrame_HPBar_SB_SBX:SetText( bigText );
   end
end

function THTF_MPUpdate()
   local curValue = UnitMana("target");
   local maxValue = UnitManaMax("target");

   local bigText = THTF_ShortenNumber(curValue) .. "/" .. THTF_ShortenNumber(maxValue);
   local smallText = math.floor((curValue/maxValue)*100);
   if not (UnitPowerType("target")==1 or UnitPowerType("target")==3) then
      smallText = smallText .. "%";
   end
   if (maxValue==100 or UnitPowerType("target")==3) then
      bigText = smallText;
      smallText = "";
   elseif (maxValue==0) then
      bigText = "";
      smallText = "";
   end

   THTF_TargetFrame_MPBar_SB:SetMinMaxValues(0, maxValue);
   THTF_TargetFrame_MPBar_SB:SetValue(curValue);
   THTF_TargetFrame_MPBar_SB_SBX:SetText( bigText );
   THTF_TargetFrame_MPBar_SB_SBP:SetText( smallText );
end

function THTF_AuraUpdate()
   local forceshow = THPF_Vars["forcevisible"];
   local i, debuff, debuffCount, buff, button, countel;
   local numBuffs = 0;
   for i=1, 24 do
      buff = UnitBuff("target", i);
      button = getglobal("THTF_TargetFrame_Buff"..i);
      if (not buff) and forceshow then
         buff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
      end
      if (buff) then
         getglobal("THTF_TargetFrame_Buff"..i.."_Icon"):SetTexture(buff);
         button:Show();
         button.id = i;
         numBuffs = numBuffs + 1;
      else
         button:Hide();
      end
   end

   local numDebuffs = 0;
   for i=1, 16 do
      debuff, debuffCount = UnitDebuff("target", i);
      button = getglobal("THTF_TargetFrame_Debuff"..i);
      if (not debuff) and forceshow then
         debuff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
         debuffCount = 1;
      end
      if (debuff) then
         getglobal("THTF_TargetFrame_Debuff"..i.."_Icon"):SetTexture(debuff);
         countel = getglobal("THTF_TargetFrame_Debuff"..i.."_Count");
         if (debuffCount > 1) then
            countel:SetText(debuffCount);
            countel:Show();
         else
            countel:Hide();
         end
         button:Show();
         button.id = i;
         numDebuffs = numDebuffs + 1;
      else
         button:Hide();
      end
   end

   -- Position buffs depending on whether the targeted unit is friendly or not
   if ( UnitIsFriend("player", "target") ) then
      if (numBuffs > 0) then
         THTF_TargetFrame_Buff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_MPBar", "BOTTOMRIGHT", 0, -3);
         if (numBuffs > 16) then
            THTF_TargetFrame_Debuff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_Buff17", "BOTTOMRIGHT", 0, -2);
         elseif (numBuffs > 8) then
            THTF_TargetFrame_Debuff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_Buff9", "BOTTOMRIGHT", 0, -2);
         else
            THTF_TargetFrame_Debuff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_Buff1", "BOTTOMRIGHT", 0, -2);
         end
      else
         THTF_TargetFrame_Debuff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_MPBar", "BOTTOMRIGHT", 0, -3);
      end
   else
      THTF_TargetFrame_Debuff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_MPBar", "BOTTOMRIGHT", 0, -3);
      if (numDebuffs >= 8) then
         THTF_TargetFrame_Buff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_Debuff9", "BOTTOMRIGHT", 0, -2);
      else
         THTF_TargetFrame_Buff1:SetPoint("TOPRIGHT", "THTF_TargetFrame_Debuff1", "BOTTOMRIGHT", 0, -2);
      end
   end

   -- Make the debuffs larger if less than 5
   local debuffSize = 22;
   if (numDebuffs <= 5) then
      debuffSize = 28;
   end
   for i=1,5 do
      button = getglobal("THTF_TargetFrame_Debuff"..i);
      button:SetWidth(debuffSize);
      button:SetHeight(debuffSize);
   end
end

function THTF_FactionUpdate()
   local factionGroup = UnitFactionGroup("target");
   if ( UnitIsPVPFreeForAll("target") ) then
      THTF_TargetFrame_Faction_PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
      THTF_TargetFrame_Faction:Show();
      -- THTF_TargetFrame_PlayerDesc:SetPoint("BOTTOMRIGHT", "THTF_TargetFrame", "BOTTOMRIGHT", -28, 0);
      THTF_TargetFrame_PlayerName:SetPoint("TOPRIGHT", "THTF_TargetFrame", "TOPRIGHT", -28, -2);
   elseif ( factionGroup and UnitIsPVP("target") ) then
      THTF_TargetFrame_Faction_PVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
      THTF_TargetFrame_Faction:Show();
      -- THTF_TargetFrame_PlayerDesc:SetPoint("BOTTOMRIGHT", "THTF_TargetFrame", "BOTTOMRIGHT", -28, 0);
      THTF_TargetFrame_PlayerName:SetPoint("TOPRIGHT", "THTF_TargetFrame", "TOPRIGHT", -28, -2);
   else
      THTF_SetNoFaction();
   end
   THTF_TapColorUpdate();
end

function THTF_SetNoFaction()
   THTF_TargetFrame_Faction:Hide();
   -- THTF_TargetFrame_PlayerDesc:SetPoint("BOTTOMRIGHT", "THTF_TargetFrame", "BOTTOMRIGHT", -8, 0);
   THTF_TargetFrame_PlayerName:SetPoint("TOPRIGHT", "THTF_TargetFrame", "TOPRIGHT", -8, -2);
end

function THTF_PartyLeaderUpdate()
   if (UnitExists("target") and UnitIsPartyLeader("target")) then
      THTF_TargetFrame_LeaderIcon:Show();
   else
      THTF_TargetFrame_LeaderIcon:Hide();
   end
end

function THTF_ComboPointUpdate()
   local cp = GetComboPoints();
   if ( cp > 0 ) then
      THTF_TargetFrame_ComboText:SetText("Combo: " .. cp);
      THTF_TargetFrame_ComboText:Show();
   else
      THTF_TargetFrame_ComboText:Hide();
   end
   ComboFrame:Hide();
end

function THTF_OnEvent(event)
   -- ChatFrame1:AddMessage("here onevent");
   if (event == "PLAYER_TARGET_CHANGED") then
      THTF_DisplayUpdate();
      THTF_RaidTargetIconUpdate();
      THTF_PartyLeaderUpdate();
   elseif (event == "RAID_TARGET_UPDATE") then
      THTF_RaidTargetIconUpdate();
   elseif (event == "UNIT_PORTRAIT_UPDATE") then
      if (arg1 == "target") then
         THTF_PortraitUpdate();
      end
   elseif (event == "UNIT_DISPLAYPOWER") then
      if (arg1 == "target") then
         THTF_SetupDisplayPower();
      end
   elseif (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
      if (arg1 == "target") then
         THTF_HPUpdate();
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
      if (arg1 == "target") then
         THTF_MPUpdate();
      end
   elseif (event=="UNIT_AURA") then
      if (arg1 == "target") then
         THTF_AuraUpdate();
      end
   elseif (event=="UNIT_COMBAT") then
      if (arg1 == "target") then
         CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5);
      end
   elseif (event=="UNIT_FACTION" or event=="UNIT_PVP_UPDATE") then
      if (arg1 == "target") then
         THTF_FactionUpdate();
      end
   elseif (event=="UNIT_NAME_UPDATE") then
      if (arg1 == "target") then
         THTF_NameUpdate();
      end
   elseif (event=="UNIT_LEVEL" or event=="UNIT_CLASSIFICATION_CHANGED") then
      if (arg1 == "target") then
         THTF_LevelClassUpdate();
      end
   elseif (event=="PLAYER_FLAGS_CHANGED") then
      if (arg1 == "target") then
         THTF_PartyLeaderUpdate();
      end
   elseif (event=="PARTY_MEMBERS_CHANGED") then
      THTF_DisplayUpdate();
   elseif (event=="PLAYER_COMBO_POINTS") then
      THTF_ComboPointUpdate();
   elseif (event=="PLAYER_ENTERING_WORLD") then
      THTF_SetBackgroundGradient();
   end
end

local THTF_NextToTUpdate = 0;
local THTF_NextTapUpdate = 0;
local THTF_NextMobHealthUpdate = 0;

function THTF_OnUpdate(elapsed)
   TargetFrame:Hide();

   if ( THPF_Vars["forcevisible"] ) then
      THTF_TargetFrame:SetAlpha(1);
      THTF_TargetFrame:Show();
      if (THTF_IsHiding) then
         THTF_SetDummyValues();
      end
      THTF_IsHiding = false;
      THTF_IsShowing = false;
   else
      local newa = THTF_TargetFrame:GetAlpha();

      if ( THTF_IsHiding ) then
         adjust = elapsed / THTF_FADEOUT_TIME;
         newa = newa - adjust;
         if ( newa < 0 ) then
            THTF_TargetFrame:SetAlpha(0);
            THTF_TargetFrame:Hide();
            THTF_IsHiding = false;
         else
            -- ChatFrame1:AddMessage("elapsed: "..elapsed);
            THTF_TargetFrame:SetAlpha(newa);
         end
      elseif ( THTF_IsShowing ) then
         adjust = elapsed / THTF_FADEIN_TIME;
         newa = newa + adjust;
         if ( newa > 1 ) then
            THTF_TargetFrame:SetAlpha(1);
            THTF_TargetFrame:Show();
            THTF_IsShowing = false;
         else
            if ( not THTF_TargetFrame:IsVisible() ) then
               THTF_TargetFrame:Show();
               THTF_PortraitUpdate();
            end
            -- ChatFrame1:AddMessage("showing "..newa);
            THTF_TargetFrame:SetAlpha(newa);
         end
      end
   end

   if GetTime() >= THTF_NextToTUpdate then
      THTF_NextToTUpdate = GetTime() + THTF_TOT_UPDATE_TIME;
      THTF_UpdateTargetOfTarget();
   end
   if GetTime() >= THTF_NextTapUpdate and UnitExists("target") then
      THTF_NextTapUpdate = GetTime() + THTF_TAP_UPDATE_TIME;
      THTF_TapColorUpdate();
   end
   if (useMobHealth) then
      if GetTime() >= THTF_NextMobHealthUpdate then
         THTF_NextMobHealthUpdate = GetTime() + THTF_MOBHEALTH_UPDATE_TIME;
         THTF_UpdateMobHealth();
      end
   end

   this = THTF_TargetFrame;
   CombatFeedback_OnUpdate(elapsed);
end

function THTF_UpdateToTAuras()
   local forceshow = THPF_Vars["forcevisible"];
   local i, debuff, buff, button, thisDebuffCount;
   local buffCount = 0;
   local debuffCount = 0;

   for i=1,16 do
      buff = UnitBuff("targettarget", i);
      button = getglobal("THTF_TargetFrame_ToT_Buff"..i);
      if (not buff) and forceshow then
         buff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
      end
      if (buff) then
         getglobal("THTF_TargetFrame_ToT_Buff"..i.."_Icon"):SetTexture(buff);
         button:SetWidth(11);
         button:SetHeight(11);
         button:Show();
         button.unit = "targettarget";
         button.id = i;
         buffCount = buffCount + 1;
      else
         button:Hide();
      end

      debuff, thisDebuffCount = UnitDebuff("targettarget", i);
      button = getglobal("THTF_TargetFrame_ToT_Debuff"..i);
      if (not debuff) and forceshow then
         debuff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
         thisDebuffCount = 1;
      end
      if debuff then
         getglobal("THTF_TargetFrame_ToT_Debuff"..i.."_Icon"):SetTexture(debuff);
         local countel = getglobal("THTF_TargetFrame_ToT_Debuff"..i.."_Count");
         if (thisDebuffCount > 1) then
            countel:SetText(debuffCount);
            countel:Show();
         else
            countel:Hide();
         end
         button:SetWidth(11);
         button:SetHeight(11);
         button:Show();
         button.unit = "targettarget";
         button.id = i;
         debuffCount = debuffCount + 1;
      else
         button:Hide();
      end
   end

   if ( UnitIsFriend("player", "targettarget") ) then
      THTF_TargetFrame_ToT_Buff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_MPBar", "BOTTOMLEFT", 0, -2);
      if buffCount == 0 then
         THTF_TargetFrame_ToT_Debuff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_MPBar", "BOTTOMLEFT", 0, -2);
      elseif buffCount <= 8 then
         THTF_TargetFrame_ToT_Debuff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_Buff1", "BOTTOMLEFT", 0, -2);
      elseif buffCount > 8 then
         THTF_TargetFrame_ToT_Debuff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_Buff9", "BOTTOMLEFT", 0, -2);
      end
   else
      THTF_TargetFrame_ToT_Debuff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_MPBar", "BOTTOMLEFT", 0, -2);
      if debuffCount == 0 then
         THTF_TargetFrame_ToT_Buff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_MPBar", "BOTTOMLEFT", 0, -2);
      elseif debuffCount <= 8 then
         THTF_TargetFrame_ToT_Buff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_Debuff1", "BOTTOMLEFT", 0, -2);
      elseif debuffCount > 8 then
         THTF_TargetFrame_ToT_Buff1:SetPoint("TOPLEFT", "THTF_TargetFrame_ToT_Debuff9", "BOTTOMLEFT", 0, -2);
      end
   end
 
   if buffCount <= 5 then
      for i=1,5 do
         button = getglobal("THTF_TargetFrame_ToT_Buff"..i);
         button:SetWidth(16);
         button:SetHeight(16);
      end
   else
      for i=1,buffCount do
         button = getglobal("THTF_TargetFrame_ToT_Buff"..i);
         button:SetWidth(11.8);
         button:SetHeight(11.8);
      end
   end

   if debuffCount <= 5 then
      for i=1,5 do
         button = getglobal("THTF_TargetFrame_ToT_Debuff"..i);
         button:SetWidth(16);
         button:SetHeight(16);
      end
   else
      for i=1,debuffCount do
         button = getglobal("THTF_TargetFrame_ToT_Debuff"..i);
         button:SetWidth(11.8);
         button:SetHeight(11.8);
      end
   end
end

function THTF_UpdateTargetOfTarget()
   local unit = "targettarget";
   if UnitIsUnit("target","player") then
      unit = "target";
   end
   if UnitExists(unit) then
      THTF_TargetFrame_ToT_Name:SetText( UnitName(unit) );

      local hmax = UnitHealthMax(unit);
      local h = UnitHealth(unit);
      THTF_TargetFrame_ToT_HPBar:SetMinMaxValues(0, hmax);
      THTF_TargetFrame_ToT_HPBar:SetValue(h);
      THPF_SetHPBarColor(THTF_TargetFrame_ToT_HPBar, 0, hmax, h);
      if (hmax==0) then
         THTF_TargetFrame_ToT_HPBar_Text:SetText( "" );
      else
         THTF_TargetFrame_ToT_HPBar_Text:SetText( math.floor((h/hmax)*100) .. "%" );
      end

      local upt = UnitPowerType(unit);
      local mmax = UnitManaMax(unit);
      local m = UnitMana(unit);
      THTF_TargetFrame_ToT_MPBar:SetStatusBarColor( ManaBarColor[upt].r, ManaBarColor[upt].g, ManaBarColor[upt].b );
      THTF_TargetFrame_ToT_MPBar:SetMinMaxValues(0, mmax);
      THTF_TargetFrame_ToT_MPBar:SetValue(m);
      if (mmax==0 or upt==1 or upt==3) then
         THTF_TargetFrame_ToT_MPBar_Text:SetText( "" );
      else
         THTF_TargetFrame_ToT_MPBar_Text:SetText( math.floor((m/mmax)*100) .. "%" );
      end

      THTF_UpdateToTAuras();

      THTF_TargetFrame_ToT:Show();
   elseif THPF_Vars["forcevisible"] then
      THTF_TargetFrame_ToT_Name:SetText( "Target of Target" );
      THTF_TargetFrame_ToT_HPBar_Text:SetText( "" );
      THTF_TargetFrame_ToT_MPBar_Text:SetText( "" );
      THTF_TargetFrame_ToT_HPBar:SetMinMaxValues(0,1);
      THTF_TargetFrame_ToT_HPBar:SetValue(1);
      THTF_TargetFrame_ToT_MPBar:SetStatusBarColor( 0, 0, 1 );
      THTF_TargetFrame_ToT_MPBar:SetMinMaxValues(0,1);
      THTF_TargetFrame_ToT_MPBar:SetValue(1);
      THTF_TargetFrame_ToT:Show();
   else
      THTF_TargetFrame_ToT:Hide();
   end
end

function THTF_ToT_MouseUpHandler()
   if (THTF_TargetFrame_ToT.isMoving) then
      THTF_TargetFrame_ToT:StopMovingOrSizing();
      THTF_TargetFrame_ToT.isMoving = false;
   end
end

function THTF_ToT_MouseDownHandler()
   if THPF_Vars["unlock_tot"] then
      if (arg1=="LeftButton") then
         THPF_Vars["detached_tot"] = 1;
         THTF_TargetFrame_ToT:StartMoving();
         THTF_TargetFrame_ToT.isMoving = true;
      end
   end
end

function THTF_ToT_OnClick(button)
   if (SpellIsTargeting() and button == "RightButton") then
      SpellStopTargeting();
      return;
   end
   if (button == "LeftButton") then
      if (SpellIsTargeting()) then
         SpellTargetUnit("targettarget");
      elseif (CursorHasItem()) then
         DropItemOnUnit("targettarget");
      else
         TargetUnit("targettarget");
      end
   else
      -- ToggleDropDownMenu(1, nil, THTF_DropDown, "cursor");
   end
end

function THTF_MouseUpHandler()
   if (THTF_TargetFrame.isMoving) then
      THTF_TargetFrame:StopMovingOrSizing();
      THTF_TargetFrame.isMoving = false;
   end
end

function THTF_MouseDownHandler()
   if THPF_Vars["unlock_target"] then
      if (arg1=="LeftButton") then
         THPF_Vars["detached_target"] = 1;
         THTF_TargetFrame:StartMoving();
         THTF_TargetFrame.isMoving = true;
      end
   end
end

function THTF_OnClick(button)
   -- ChatFrame1:AddMessage("here");
   if (SpellIsTargeting() and button == "RightButton") then
      SpellStopTargeting();
      return;
   end
   if (button == "LeftButton") then
      if (SpellIsTargeting()) then
         SpellTargetUnit("target");
      elseif (CursorHasItem()) then
         DropItemOnUnit("target");
      end
   else
      ToggleDropDownMenu(1, nil, THTF_DropDown, "cursor");
   end
end

function THTF_DropDown_OnLoad()
   UIDropDownMenu_Initialize(this, THTF_DropDown_Initialize, "MENU");
end

function THTF_DropDown_Initialize()
   local menu = nil;
   local name = nil;
   if ( UnitExists("target") and UnitReaction("player", "target") and 
         (((UnitReaction("player", "target") >= 4 and not UnitIsPlayer("target")) and
         not UnitIsUnit("player", "target")) or (UnitReaction("player", "target") < 4  and not UnitIsPlayer("target"))) ) then
      menu = "RAID_TARGET_ICON";
      name = RAID_TARGET_ICON;
   end
   if (UnitIsUnit("target","player")) then
      menu = "SELF";
   elseif (UnitIsUnit("target","pet")) then
      menu = "PET";
   elseif (UnitIsPlayer("target")) then
      if (UnitInParty("target")) then
         menu = "PARTY";
      else
         menu = "PLAYER";
      end
   end

   if (menu) then
      UnitPopup_ShowMenu(THTF_DropDown, menu, "target", name);
   end
end

