
local THGF_BUFF_FILTER_OVERRIDES = {};

local THGF_DEBUFF_FILTER_OVERRIDES = {};
THGF_DEBUFF_FILTER_OVERRIDES["Priest"] = {};
THGF_DEBUFF_FILTER_OVERRIDES["Priest"]["Weakened Soul"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Priest"]["type:Magic"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Priest"]["type:Disease"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Paladin"] = {};
THGF_DEBUFF_FILTER_OVERRIDES["Paladin"]["Forbearance"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Paladin"]["type:Magic"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Paladin"]["type:Poison"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Paladin"]["type:Disease"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Druid"] = {};
THGF_DEBUFF_FILTER_OVERRIDES["Druid"]["type:Curse"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Druid"]["type:Poison"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Mage"] = {};
THGF_DEBUFF_FILTER_OVERRIDES["Mage"]["type:Curse"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Shaman"] = {};
THGF_DEBUFF_FILTER_OVERRIDES["Shaman"]["type:Poison"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["Shaman"]["type:Disease"] = true;
THGF_DEBUFF_FILTER_OVERRIDES["all"] = {};
THGF_DEBUFF_FILTER_OVERRIDES["all"]["Recently Bandaged"] = true;

local THGF_DEBUFF_SPELLS = {};
THGF_DEBUFF_SPELLS["Priest"] = {};
THGF_DEBUFF_SPELLS["Priest"]["Magic"] = "Dispel Magic";
THGF_DEBUFF_SPELLS["Priest"]["Disease"] = "Abolish Disease";
THGF_DEBUFF_SPELLS["Paladin"] = {};
THGF_DEBUFF_SPELLS["Paladin"]["Magic"] = "Cleanse";
THGF_DEBUFF_SPELLS["Paladin"]["Poison"] = "Cleanse";
THGF_DEBUFF_SPELLS["Paladin"]["Disease"] = "Cleanse";
THGF_DEBUFF_SPELLS["Druid"] = {};
THGF_DEBUFF_SPELLS["Druid"]["Curse"] = "Remove Curse";
THGF_DEBUFF_SPELLS["Druid"]["Poison"] = "Abolish Poison";
THGF_DEBUFF_SPELLS["Mage"] = {};
THGF_DEBUFF_SPELLS["Mage"]["Curse"] = "Remove Lesser Curse";
THGF_DEBUFF_SPELLS["Shaman"] = {};
THGF_DEBUFF_SPELLS["Shaman"]["Poison"] = "Cure Poison";
THGF_DEBUFF_SPELLS["Shaman"]["Disease"] = "Cure Disease";

local THGF_UnitDebuffTypeCounts = {};

local THGF_PartyFrameEnabled = true;
--local THGF_FadeDirection = "right";

local THGF_NeedChange = nil;
local THGF_CHANGE_INTERVAL = 0.25;

local THGF_FADE_IN_TIME = 0.125;
local THGF_FADE_OUT_TIME = 0.125;

local THGF_AnyFade = false;
local THGF_Fades = {};

local THGF_EXISTCHECK_INTERVAL = 5;
local THGF_NextExistCheck = 0;
local THGF_NeedExistCheck = {};

local THGF_FilteredBuffs = {};

function THGF_OnLoad()
   if not THGF_PartyFrameEnabled then
      return;
   end

   this:RegisterEvent("PARTY_MEMBERS_CHANGED");
   this:RegisterEvent("PARTY_LEADER_CHANGED");
   this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
   this:RegisterEvent("RAID_ROSTER_UPDATE");

   this:RegisterEvent("PLAYER_ENTERING_WORLD");

   this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
   this:RegisterEvent("UNIT_NAME_UPDATE");
   this:RegisterEvent("UNIT_LEVEL");

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

   this:RegisterEvent("UNIT_DISPLAYPOWER");

   this:RegisterEvent("UNIT_AURA");

   this:RegisterEvent("UNIT_FACTION");
   this:RegisterEvent("UNIT_PVP_UPDATE");

   this:RegisterEvent("SPELLS_CHANGED");
   this:RegisterEvent("PLAYER_LOGIN");

   this:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function THGF_OnUpdate(elapsed)
   if not THGF_PartyFrameEnabled then
      return;
   end

   HidePartyFrame();

   if (THGF_NeedChange and THGF_NeedChange <= GetTime()) then
      THGF_NeedChange = nil;
      THGF_PartyChange();
   end
   if (THGF_AnyFade) then
      THGF_FadeStep(elapsed);
   end

   if GetTime() > THGF_NextExistCheck then
      THGF_NextExistCheck = GetTime() + THGF_EXISTCHECK_INTERVAL;
      local k,v;
      for k,v in pairs(THGF_NeedExistCheck) do
         if v then
            if UnitIsVisible(k) then
               THGF_UpdateAll();
               THGF_NeedExistCheck[k] = nil;
            elseif not UnitExists(k) then
               THGF_NeedExistCheck[k] = nil;
            end
         end
      end
   end
end

function THGF_MouseUpHandler(gid)
   local f = getglobal("THGF_PartyMember"..gid);
   if (f.isMoving) then
      f:StopMovingOrSizing();
      f.isMoving = false;
   end
end

function THGF_MouseDownHandler(gid)
   if THPF_Vars["unlock_party"..gid] then
      if (arg1=="LeftButton") then
         THPF_Vars["detached_party"..gid] = 1;
         local f = getglobal("THGF_PartyMember"..gid);
         f:StartMoving();
         f.isMoving = true;
      end
   end
end

function THGF_HideHandler(gid)
   THGF_MouseUpHandler(gid);
end

function THGF_ShowMember(num)
   THGF_Fades[num] = 1;
   THGF_AnyFade = true;
end

function THGF_HideMember(num)
   if THPF_Vars["forcevisible"] then
      THGF_ShowMember(num);
      return;
   end
   THGF_Fades[num] = -1;
   THGF_AnyFade = true;
end

function THGF_GetNumPartyMembers()
   if UnitInRaid("player") and not THPF_Vars["showpartyframeinraid"] then
      return 0;
   else
      return GetNumPartyMembers();
   end
end

function THGF_PartyChange()
   local nm = THGF_GetNumPartyMembers();
   if nm == 0 then
      nm = -1;
   end
   for i=0,4 do
      if (nm >= i) and (i>0 or (i==0 and THPF_Vars["showselfinparty"])) then
         THGF_ShowMember(i);
      else
         THGF_HideMember(i);
      end
   end

   THGF_UpdateAllGroupMembers(THPF_Vars["forcevisible"]);
end

function THGF_FadeStep(elapsed)
   local newaf = false;
   for i=0, 4 do
      if THGF_Fades[i] then
         local tpf = getglobal("THGF_PartyMember"..i);
         local curVis = tpf:IsVisible();
         local curAlpha = tpf:GetAlpha();
         if THGF_Fades[i]>0 then
            -- fading in
            local fadeStep = elapsed / THGF_FADE_IN_TIME;
            if (fadeStep > 1) then
               fadeStep = 1;
            elseif (fadeStep < 0) then
               fadeStep = 0;
            end

            if (not curVis) then
               curAlpha = 0;
               tpf:Show();
            end
            curAlpha = curAlpha + fadeStep;
            if (curAlpha >= 1) then
               curAlpha = 1;
               THGF_Fades[i] = nil;
            end

            tpf:SetAlpha(curAlpha);
         else
            -- fading out
            local fadeStep = elapsed / THGF_FADE_OUT_TIME;
            if (fadeStep > 1) then
               fadeStep = 1;
            elseif (fadeStep < 0) then
               fadeStep = 0;
            end

            if (not curVis) then
               curAlpha = 0;
            end
            curAlpha = curAlpha - fadeStep;
            if (curAlpha <= 0) then
               curAlpha = 0;
               THGF_Fades[i] = nil;
               tpf:Hide();
            else
               tpf:SetAlpha(curAlpha);
            end
         end

         -- Need to continue fading...
         if THGF_Fades[i] then
            newaf = true;
         end
      end
   end
   THGF_AnyFade = newaf;
end

function THGF_UpdateAllGroupMembers(debug)
   local max = THGF_GetNumPartyMembers();
   if debug then
      max = 4;
   end
   for i = 0, max do
      THGF_UpdateGroupMember(i,debug);
   end
end

function THGF_UpdateGroupMember(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   THGF_UpdatePortrait(num,debug);
   THGF_UpdateNameLevel(num,debug);
   THGF_UpdateLeader(num,debug);
   THGF_UpdateDisplayPower(num,debug);
   THGF_UpdateHP(num,debug);
   THGF_UpdateMP(num,debug);
   THGF_UpdateAura(num,debug);
   THGF_UpdatePvp(num,debug);
end

function THGF_GetUnitName(num,debug)
   if num == 0 then
      return "player";
   end
   local unitName = "party"..num;
   if debug and not UnitExists(unitName) then
      unitName = "player";
   end
   return unitName;
end

function THGF_UpdatePortrait(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   getglobal("THGF_PartyMember"..num.."_PlayerModel"):SetRotation(0.61);
   if UnitIsVisible(unitName) then
      getglobal("THGF_PartyMember"..num.."_PlayerModel"):SetUnit(unitName);
      THGF_NeedExistCheck[unitName] = nil;
   else
      getglobal("THGF_PartyMember"..num.."_PlayerModel"):SetModel( THTF_GetUnitModel(unitName) );
      THGF_NeedExistCheck[unitName] = 1;
   end
   getglobal("THGF_PartyMember"..num.."_PlayerModel"):SetCamera(0);
end

function THGF_UpdateNameLevel(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   local charName = UnitName(unitName);
   if not charName then
      charName = "Unknown Entity";
   end
   local charLevel = UnitLevel(unitName);
   if not charLevel then
      charLevel = "0";
   end
   local charClass = UnitClass(unitName);
   if not charClass then
      charClass = "??";
   end

   getglobal("THGF_PartyMember"..num.."_Data_Name"):SetText("|cffc8e4ff"..charName.."|cffffffff, "..charLevel.." "..charClass);
end

function THGF_UpdateLeader(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   local isLeader = UnitIsPartyLeader(unitName);
   if (isLeader) then
      -- TODO: show leader icon
   else
      -- TODO: hide leader icon
   end
end

function THGF_UpdateDisplayPower(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   -- TODO
   local upt = UnitPowerType(unitName);
   getglobal("THGF_PartyMember"..num.."_Data_MP_SB"):SetStatusBarColor(
      ManaBarColor[upt].r, ManaBarColor[upt].g, ManaBarColor[upt].b
   );
end

function THGF_UpdateHP(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   -- TODO
   local curHP = UnitHealth(unitName);
   local maxHP = UnitHealthMax(unitName);
   THPF_SetHPBarColor( getglobal("THGF_PartyMember"..num.."_Data_HP_SB"), 0, maxHP, curHP );
   getglobal("THGF_PartyMember"..num.."_Data_HP_SB"):SetMinMaxValues(0, maxHP);
   getglobal("THGF_PartyMember"..num.."_Data_HP_SB"):SetValue(curHP);

   getglobal("THGF_PartyMember"..num.."_Data_HP_SB_Text"):SetText(curHP .. "/" .. maxHP);
end

function THGF_UpdateMP(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   -- TODO
   local curMP = UnitMana(unitName);
   local maxMP = UnitManaMax(unitName);
   getglobal("THGF_PartyMember"..num.."_Data_MP_SB"):SetMinMaxValues(0, maxMP);
   getglobal("THGF_PartyMember"..num.."_Data_MP_SB"):SetValue(curMP);

   getglobal("THGF_PartyMember"..num.."_Data_MP_SB_Text"):SetText(curMP .. "/" .. maxMP);
end

function THGF_BuffFilterCheckInt(overrides, buffname, bufftype)
   if overrides[buffname] then
      return 1;
   end
   if bufftype and overrides["type:"..bufftype] then
      return 1;
   end
   return nil;
end

function THGF_BuffFilterCheck(overrides, incmine)
   local buffname = THUF_ScanTooltipTextLeft1:GetText();
   local bufftype = THUF_ScanTooltipTextRight1:GetText();
   if not bufftype then
      bufftype = "None";
   end
   local myclass = UnitClass("player");
   if overrides[myclass] then
      if THGF_BuffFilterCheckInt(overrides[myclass], buffname, bufftype) then
         return 1;
      end
   end
   if overrides["all"] then
      if THGF_BuffFilterCheckInt(overrides["all"], buffname, bufftype) then
         return 1;
      end
   end
   if incmine then
      if THGF_BuffFilterCheckInt(THGF_FilteredBuffs, buffname, bufftype) then
         return 1;
      end
   end
   return nil;
end

function THGF_DebuffClicked(unit, id, debuffType)
   if (not unit) or (not id) or (not debuffType) then
      return;
   end
   local myClass = UnitClass("player");
   if not THGF_DEBUFF_SPELLS[myClass] then
      return;
   end
   if THGF_DEBUFF_SPELLS[myClass][debuffType] then
      local spell = THGF_DEBUFF_SPELLS[myClass][debuffType];
      --ChatFrame1:AddMessage("debuffing with "..spell);
      --ChatFrame1:AddMessage("count: "..THGF_UnitDebuffTypeCounts[unit][debuffType]);
      if THGF_UnitDebuffTypeCounts[unit] and
            THGF_UnitDebuffTypeCounts[unit][debuffType] and
            THGF_UnitDebuffTypeCounts[unit][debuffType] == 1 and
            THGF_DEBUFF_SPELLS[myClass]["1:"..debuffType] then
         spell = THGF_DEBUFF_SPELLS[myClass]["1:"..debuffType];
      end

      TargetUnit(unit);
      CastSpellByName( spell );
      TargetLastTarget();
   end
end

function THGF_SetTooltip(id)
   local unit = THGF_GetUnitName(id);
   if not UnitName(unit) then
      return;
   end

   THGF_Tooltip:SetOwner(getglobal("THGF_PartyMember"..id), "ANCHOR_CURSOR");
   THGF_Tooltip:SetScale( UIParent:GetScale() );
   THGF_Tooltip:ClearLines();
--[[
   THGF_Tooltip:AddDoubleLine( UnitName(unit), UnitLevel(unit), 1, 1, 1, 1, 1, 1 );
   THGF_Tooltip:AddLine( UnitRace(unit).." "..UnitClass(unit), 0.75, 0.75, 0.75, nil);
   if UnitExists(unit.."target") then
      THGF_Tooltip:AddLine( "Target: ".. UnitName(unit.."target") );
   end
   if UnitIsPartyLeader(unit) then
      THGF_Tooltip:AddLine( "Party Leader", 0, 1.0, 0, nil );
   end
--]]
   THGF_Tooltip:SetUnit(unit);
   --GameTooltip:SetUnit(unit);
   --GameTooltip:Show();
   THGF_Tooltip:Show();
end

function THGF_UpdateAura(num,debug)
   --ChatFrame1:AddMessage("THGF_UpdateAura("..num..","..debug..")");
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local forceshow = THPF_Vars["forcevisible"];
   local unitName = THGF_GetUnitName(num,debug);
   local i, debuff, buff, button, countel, thisDebuffCount;
   local buffCount = 0;
   local debuffCount = 0;

   THGF_UnitDebuffTypeCounts[unitName] = {};
   THGF_UnitDebuffTypeCounts[unitName]["Magic"] = 0;
   THGF_UnitDebuffTypeCounts[unitName]["Disease"] = 0;
   THGF_UnitDebuffTypeCounts[unitName]["Curse"] = 0;
   THGF_UnitDebuffTypeCounts[unitName]["Poison"] = 0;

   local bnum = 1;
   local dnum = 1;
   for i=1,24 do
      buff = UnitBuff(unitName, i);
      button = getglobal("THGF_PartyMember"..num.."_Buff"..bnum);
      if buff and THPF_Vars["filterbuffs"] and (not forceshow) then
         THUF_ScanTooltip:ClearLines();
         THUF_ScanTooltip:SetUnitBuff(unitName, i);
         if not THGF_BuffFilterCheck(THGF_BUFF_FILTER_OVERRIDES, 1) then
            buff = nil;
         end
      end
      if (not buff) and forceshow then
         buff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
      end
      if (buff) then
         getglobal("THGF_PartyMember"..num.."_Buff"..bnum.."_Icon"):SetTexture(buff);
         button:SetWidth(20.5);
         button:SetHeight(20.5);
         button:Show();
         button.unit = unitName;
         button.id = i;
         buffCount = buffCount + 1;
         bnum = bnum + 1;
      else
         button:Hide();
      end

      if i <= 16 then
      debuff, thisDebuffCount = UnitDebuff(unitName, i);
      button = getglobal("THGF_PartyMember"..num.."_Debuff"..dnum);
      THUF_ScanTooltip:ClearLines();
      THUF_ScanTooltipTextLeft1:SetText("");
      THUF_ScanTooltipTextRight1:SetText("");
      THUF_ScanTooltip:SetUnitDebuff(unitName, i);
      local debuffType = THUF_ScanTooltipTextRight1:GetText();
      if debuff and THPF_Vars["filterdebuffs"] and (not forceshow) then
         --ChatFrame1:AddMessage("fname="..THUF_ScanTooltipTextLeft1:GetText().." ftype="..debuffType);
         if not THGF_BuffFilterCheck(THGF_DEBUFF_FILTER_OVERRIDES, nil) then
            debuff = nil;
            debuffType = nil;
         end
      end
      if (not debuff) and forceshow then
         debuff = "Interface\\Icons\\INV_Qiraj_JewelBlessed";
         debuffType = nil;
         thisDebuffCount = 1;
      end
      if (debuff) then
         getglobal("THGF_PartyMember"..num.."_Debuff"..dnum.."_Icon"):SetTexture(debuff);
         countel = getglobal("THGF_PartyMember"..num.."_Debuff"..dnum.."_Count");
         if (thisDebuffCount > 1) then
            countel:SetText(debuffCount);
            countel:Show();
         else
            countel:Hide();
         end
         button:Show();
         button.unit = unitName;
         button.id = i;
         button.debuffType = debuffType;
         debuffCount = debuffCount + 1;
         dnum = dnum + 1;

         if debuffType then
            if thisDebuffCount == 0 then
               thisDebuffCount = 1;
            end
            THGF_UnitDebuffTypeCounts[unitName][debuffType] = 
                  THGF_UnitDebuffTypeCounts[unitName][debuffType] + thisDebuffCount;
         end
      else
         button.debuffType = nil;
         button:Hide();
      end
      end -- if i <= 16
   end
   while bnum <= 24 do
      getglobal("THGF_PartyMember"..num.."_Buff"..bnum):Hide();
      bnum = bnum + 1;
   end
   while dnum <= 16 do
      getglobal("THGF_PartyMember"..num.."_Debuff"..dnum):Hide();
      dnum = dnum + 1;
   end
end

function THGF_UpdatePvp(num,debug)
   if num > THGF_GetNumPartyMembers() and not debug then return end

   local unitName = THGF_GetUnitName(num,debug);

   -- TODO
   if UnitIsPartyLeader(unitName) then
      getglobal("THGF_PartyMember"..num.."_Data_LeaderIcon"):Show();
   else
      getglobal("THGF_PartyMember"..num.."_Data_LeaderIcon"):Hide();
   end
end

function THGF_SetBackgroundGradients()
   THGF_UpdateTargetHighlight();

   local i;
   for i=0,4 do
      getglobal("THGF_PartyMember"..i.."_Data_HP_GradientBG"):SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
      getglobal("THGF_PartyMember"..i.."_Data_MP_GradientBG"):SetGradientAlpha("VERTICAL",0.25,0.25,0.25,1,0.75,0.75,0.75,1);
   end
end

function THGF_Test()
   THGF_PartyMember1_PlayerModel:SetRotation(0.61);
   THGF_PartyMember1_PlayerModel:SetUnit("player");
   THGF_PartyMember1_PlayerModel:SetCamera(0);
end

function THGF_ConditionalCall(func, unit)
   if unit=="party1" then func(1);
   elseif unit=="party2" then func(2);
   elseif unit=="party3" then func(3);
   elseif unit=="party4" then func(4);
   elseif unit=="player" then func(0);
   end
end

function THGF_OnClick(button)
   local unitName = THGF_GetUnitName(this:GetID());
   --ChatFrame1:AddMessage("button == "..button);
   --local unitName = "party" .. this:GetID();
   if ( SpellIsTargeting() and button == "RightButton" ) then
      SpellStopTargeting();
      return;
   end
   if ( button == "LeftButton" ) then
      if ( SpellIsTargeting() ) then
         SpellTargetUnit(unitName);
      -- TODO: add item drop
      else
         if type(CastParty_OnClickByUnit)=="function" then
            CastParty_OnClickByUnit(button, unitName);
         else
            TargetUnit(unitName);
         end
      end
   else
      if type(CastParty_OnClickByUnit)=="function" then
         CastParty_OnClickByUnit(button, unitName);
      end
   end
   -- TODO: add dropdown menu
end

function THGF_UpdateAll(immediate)
   if not immediate then
      THGF_NeedChange = GetTime() + THGF_CHANGE_INTERVAL;
   else
      THGF_NeedChange = GetTime();
   end
end

function THGF_UpdateBuffFilter()
   THGF_FilteredBuffs = {};
   local i = 1;
   while true do
      local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL);
      if not spellName then
         break;
      end

      THGF_FilteredBuffs[spellName] = true;
      -- ChatFrame1:AddMessage("adding buff ->"..spellName.."<-");

      i = i + 1;
   end
   while true do
      local spellName, spellRank = GetSpellName(i, BOOKTYPE_PET);
      if not spellName then
         break;
      end

      THGF_FilteredBuffs[spellName] = true;

      i = i + 1;
   end
end

function THGF_UpdateTargetHighlight()
   local x;
   for x=0, 4 do
      local unitName = THGF_GetUnitName(x);

      local r = 0;
      local g = 0;
      local b = 0;
      if THPF_Vars["highlightpartytarget"] and UnitIsUnit(unitName, "target") then
         r = 0.75;
         g = 0.75;
         b = 0;
      end

      getglobal("THGF_PartyMember"..x.."_Data_GradientBG"):SetTexture(r,g,b,1);
      getglobal("THGF_PartyMember"..x.."_PMBG_BGTexture"):SetTexture(r,g,b,1);

      if THPF_Vars["partyfadedirection"] == "left" then
         getglobal("THGF_PartyMember"..x.."_Data_GradientBG"):SetGradientAlpha("HORIZONTAL",r,g,b,0,r,g,b,1);
         getglobal("THGF_PartyMember"..x.."_PMBG_BGTexture"):SetGradientAlpha("HORIZONTAL",r,g,b,0,r,g,b,0);
      elseif THPF_Vars["partyfadedirection"] == "down" then
         getglobal("THGF_PartyMember"..x.."_Data_GradientBG"):SetGradientAlpha("VERTICAL",r,g,b,0,r,g,b,1);
         getglobal("THGF_PartyMember"..x.."_PMBG_BGTexture"):SetGradientAlpha("VERTICAL",r,g,b,0,r,g,b,1);
      elseif THPF_Vars["partyfadedirection"] == "up" then
         getglobal("THGF_PartyMember"..x.."_Data_GradientBG"):SetGradientAlpha("VERTICAL",r,g,b,1,r,g,b,0);
         getglobal("THGF_PartyMember"..x.."_PMBG_BGTexture"):SetGradientAlpha("VERTICAL",r,g,b,1,r,g,b,0);
      else
         getglobal("THGF_PartyMember"..x.."_Data_GradientBG"):SetGradientAlpha("HORIZONTAL",r,g,b,1,r,g,b,0);
         getglobal("THGF_PartyMember"..x.."_PMBG_BGTexture"):SetGradientAlpha("HORIZONTAL",r,g,b,1,r,g,b,1);
      end
   end
end

function THGF_UnhookDefaultPartyFrame()
   ShowPartyFrame = function() end;
   HidePartyFrame();
end

function THGF_OnEvent(event)
   if (event=="PARTY_MEMBERS_CHANGED" or event=="PARTY_LEADER_CHANGED" or
       event=="PARTY_LOOT_METHOD_CHANGED" or event=="RAID_ROSTER_UPDATE") then
      THGF_UpdateAll();
      if THPF_Vars["highlightpartytarget"] then
         THGF_UpdateTargetHighlight();
      end
   elseif (event=="PLAYER_LOGIN") then
      local i;
      for i = 0,4 do
         --ChatFrame1:AddMessage("THGF_PartyMember"..i);
         getglobal("THGF_PartyMember"..i):RegisterForClicks("LeftButtonUp", "RightButtonUp");
      end
   elseif (event=="PLAYER_TARGET_CHANGED") then
      if THPF_Vars["highlightpartytarget"] then
         THGF_UpdateTargetHighlight();
      end
   elseif (event=="PLAYER_ENTERING_WORLD") then
      THGF_UnhookDefaultPartyFrame();
      THGF_SetBackgroundGradients();
      THGF_UpdateAll();
      THGF_UpdateBuffFilter();
   elseif (event=="SPELLS_CHANGED") then
      THGF_UpdateBuffFilter();
   elseif (event=="UNIT_PORTRAIT_UPDATE") then
      THGF_ConditionalCall(THGF_UpdatePortrait, arg1);
   elseif (event=="UNIT_NAME_UPDATE" or event=="UNIT_LEVEL") then
      THGF_ConditionalCall(THGF_UpdateNameLevel, arg1);
   elseif (event=="UNIT_HEALTH" or event=="UNIT_MAXHEALTH") then
      THGF_ConditionalCall(THGF_UpdateHP, arg1);
   elseif (event=="UNIT_MANA" or event=="UNIT_MAXMANA" or
           event=="UNIT_RAGE" or event=="UNIT_MAXRAGE" or
           event=="UNIT_FOCUS" or event=="UNIT_MAXFOCUS" or
           event=="UNIT_ENERGY" or event=="UNIT_MAXENERGY" or
           event=="UNIT_HAPPINESS" or event=="UNIT_MAXHAPPINESS") then
      THGF_ConditionalCall(THGF_UpdateMP, arg1);
   elseif (event=="UNIT_DISPLAYPOWER") then
      THGF_ConditionalCall(THGF_UpdateDisplayPower, arg1);
   elseif (event=="UNIT_AURA") then
      THGF_ConditionalCall(THGF_UpdateAura, arg1);
   elseif (event=="UNIT_FACTION" or event=="UNIT_PVP_UPDATE") then
      THGF_ConditionalCall(THGF_UpdatePvp, arg1);
   end
end

