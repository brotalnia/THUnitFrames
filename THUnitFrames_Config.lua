
local THUF_Config_Opening = false;

function THUF_ShowConfigWindow()
   THUF_Config_Opening = true;

   THUF_ConfigFrame_LockCategory_ForceVisible:SetChecked( THPF_Vars["forcevisible"] );

   if THPF_Vars["unlock_player"] then
      THUF_ConfigFrame_LockCategory_PlayerLock:SetChecked( nil );
   else
      THUF_ConfigFrame_LockCategory_PlayerLock:SetChecked( 1 );
   end

   if THPF_Vars["unlock_target"] then
      THUF_ConfigFrame_LockCategory_TargetLock:SetChecked( nil );
   else
      THUF_ConfigFrame_LockCategory_TargetLock:SetChecked( 1 );
   end

   if THPF_Vars["unlock_tot"] then
      THUF_ConfigFrame_LockCategory_TotLock:SetChecked( nil );
   else
      THUF_ConfigFrame_LockCategory_TotLock:SetChecked( 1 );
   end

   if THPF_Vars["unlock_pet"] then
      THUF_ConfigFrame_LockCategory_PetLock:SetChecked( nil );
   else
      THUF_ConfigFrame_LockCategory_PetLock:SetChecked( 1 );
   end

   local x;
   for x=0, 4 do
      local lf = getglobal("THUF_ConfigFrame_LockCategory_Party"..x.."Lock");
      if THPF_Vars["unlock_party"..x] then
         lf:SetChecked( nil );
      else
         lf:SetChecked( 1 );
      end
   end

   THUF_ConfigFrame_LockCategory_PlayerLock_ScaleSlider:SetValue( THPF_MainFrame:GetScale() );
   THUF_SetSliderLabel( "player",
      THUF_ConfigFrame_LockCategory_PlayerLock_ScaleSlider_Title,
      THPF_MainFrame:GetScale() );

   THUF_ConfigFrame_LockCategory_TargetLock_ScaleSlider:SetValue( THTF_TargetFrame:GetScale() );
   THUF_SetSliderLabel( "target",
      THUF_ConfigFrame_LockCategory_TargetLock_ScaleSlider_Title,
      THTF_TargetFrame:GetScale() );

   THUF_ConfigFrame_LockCategory_TotLock_ScaleSlider:SetValue( THTF_TargetFrame_ToT:GetScale() );
   THUF_SetSliderLabel( "tot",
      THUF_ConfigFrame_LockCategory_TotLock_ScaleSlider_Title,
      THTF_TargetFrame_ToT:GetScale() );

   THUF_ConfigFrame_LockCategory_PetLock_ScaleSlider:SetValue( THPF_MainFrame_Pet:GetScale() );
   THUF_SetSliderLabel( "pet",
      THUF_ConfigFrame_LockCategory_PetLock_ScaleSlider_Title,
      THPF_MainFrame_Pet:GetScale() );

   for x=0, 4 do
      local pmf = getglobal("THGF_PartyMember"..x);
      local lockname = "THUF_ConfigFrame_LockCategory_Party"..x.."Lock";
      getglobal(lockname.."_ScaleSlider"):SetValue( pmf:GetScale() );
      THUF_SetSliderLabel( "party"..x,
         getglobal(lockname.."_ScaleSlider_Title"),
         pmf:GetScale() );
   end

--[[
   THUF_ConfigFrame_MiscCategory_ShowPartyFrameInRaid:SetChecked( THPF_Vars["showpartyframeinraid"] );
   THUF_ConfigFrame_MiscCategory_ShowSelfInParty:SetChecked( THPF_Vars["showselfinparty"] );
   THUF_ConfigFrame_MiscCategory_FilterBuffs:SetChecked( THPF_Vars["filterbuffs"] );
   THUF_ConfigFrame_MiscCategory_FilterDebuffs:SetChecked( THPF_Vars["filterdebuffs"] );
   THUF_ConfigFrame_MiscCategory_HighlightPartyTarget:SetChecked( THPF_Vars["highlightpartytarget"] );
--]]

   local initcb = function(framename, varkey)
      getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBUp"):SetChecked(nil);
      getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBDown"):SetChecked(nil);
      getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBLeft"):SetChecked(nil);
      getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBRight"):SetChecked(nil);
      if THPF_Vars[varkey] == "up" then
         getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBUp"):SetChecked(1);
      elseif THPF_Vars[varkey] == "down" then
         getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBDown"):SetChecked(1);
      elseif THPF_Vars[varkey] == "left" then
         getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBLeft"):SetChecked(1);
      elseif THPF_Vars[varkey] == "right" then
         getglobal("THUF_ConfigFrame_MiscCategory_"..framename.."_CBRight"):SetChecked(1);
      end
   end;

   initcb("PartyFadeDirection", "partyfadedirection");
   initcb("PlayerFadeDirection", "playerfadedirection");
   initcb("TargetFadeDirection", "targetfadedirection");
   initcb("TotFadeDirection", "totfadedirection");
   initcb("PetFadeDirection", "petfadedirection");

--[[
   THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBUp:SetChecked(nil);
   THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBDown:SetChecked(nil);
   THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBLeft:SetChecked(nil);
   THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBRight:SetChecked(nil);
   if THPF_Vars["partyfadedirection"] == "up" then
      THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBUp:SetChecked(1);
   elseif THPF_Vars["partyfadedirection"] == "down" then
      THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBDown:SetChecked(1);
   elseif THPF_Vars["partyfadedirection"] == "left" then
      THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBLeft:SetChecked(1);
   elseif THPF_Vars["partyfadedirection"] == "right" then
      THUF_ConfigFrame_MiscCategory_PartyFadeDirection_CBRight:SetChecked(1);
   end
--]]

   THUF_ConfigFrame:SetAlpha(0);
   THUF_ConfigFrame:SetScale(0.75);
   THUF_ConfigFrame:Show();
   THAnim.AnimateFrame(THUF_ConfigFrame, "SetAlpha", 0, 1, 0.1, nil);
   THAnim.AnimateFrame(THUF_ConfigFrame, "SetScale", 0.8, 1, 0.1, nil);

   THUF_Config_Opening = false;
end

function THUF_HideConfigWindow()
   THAnim.AnimateFrame(THUF_ConfigFrame, "SetAlpha", 1, 0, 0.25, nil);
   THAnim.AnimateFrame(THUF_ConfigFrame, "SetScale", 1, 1.25, 0.25, 
      function()
         THUF_ConfigFrame:Hide();
      end);
end

function THUF_LockChange(which,value)
   if THUF_Config_Opening then
      return;
   end

   if value then
      THPF_Vars[which] = nil;
   else
      THPF_Vars[which] = 1;
   end
end

function THUF_ResetFrame(which)
   if which=="player" then
      THPF_MainFrame:ClearAllPoints();
      THPF_MainFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 5, 1);
   elseif which=="target" then
      THTF_TargetFrame:ClearAllPoints();
      THTF_TargetFrame:SetPoint("TOPLEFT", "THPF_MainFrame", "TOPRIGHT", 5, 0);

      THPF_Vars["detached_target"] = nil;
      THUF_ConfigFrame_LockCategory_TargetLock_ScaleSlider:SetValue(
         THPF_MainFrame:GetScale() );
   elseif which=="tot" then
      THTF_TargetFrame_ToT:ClearAllPoints();
      THTF_TargetFrame_ToT:SetPoint("TOPLEFT", "THTF_TargetFrame_HPBar", "TOPRIGHT", 8, 0);
      THTF_TargetFrame_ToT:SetPoint("BOTTOMLEFT", "THTF_TargetFrame_MPBar", "BOTTOMRIGHT", 8, 0);

      THPF_Vars["detached_tot"] = nil;
      THUF_ConfigFrame_LockCategory_TotLock_ScaleSlider:SetValue(
         THTF_TargetFrame:GetScale() );
   elseif which=="pet" then
      THPF_MainFrame_Pet:ClearAllPoints();
      THPF_MainFrame_Pet:SetPoint("TOPLEFT", "THPF_MainFrame_MPBar", "BOTTOMLEFT");
      THPF_MainFrame_Pet:SetPoint("TOPRIGHT", "THPF_MainFrame_MPBar", "BOTTOMRIGHT");

      THPF_Vars["detached_pet"] = nil;
      THUF_ConfigFrame_LockCategory_PetLock_ScaleSlider:SetValue(
         THPF_MainFrame:GetScale() );
   elseif which=="party0" then
      THGF_PartyMember0:ClearAllPoints();
      THGF_PartyMember0:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -200);
      THPF_Vars["detached_party0"] = nil;
      THUF_ConfigFrame_LockCategory_Party0Lock_ScaleSlider:SetValue(
         THPF_MainFrame:GetScale() );
   elseif which=="party1" then
      THGF_PartyMember1:ClearAllPoints();
      THGF_PartyMember1:SetPoint("TOPLEFT", "THGF_PartyMember0", "BOTTOMLEFT", 0, -10);
      THPF_Vars["detached_party1"] = nil;
      THUF_ConfigFrame_LockCategory_Party1Lock_ScaleSlider:SetValue(
         THGF_PartyMember0:GetScale() );
   elseif which=="party2" then
      THGF_PartyMember2:ClearAllPoints();
      THGF_PartyMember2:SetPoint("TOPLEFT", "THGF_PartyMember1", "BOTTOMLEFT", 0, -10);
      THPF_Vars["detached_party2"] = nil;
      THUF_ConfigFrame_LockCategory_Party2Lock_ScaleSlider:SetValue(
         THGF_PartyMember1:GetScale() );
   elseif which=="party3" then
      THGF_PartyMember3:ClearAllPoints();
      THGF_PartyMember3:SetPoint("TOPLEFT", "THGF_PartyMember2", "BOTTOMLEFT", 0, -10);
      THPF_Vars["detached_party3"] = nil;
      THUF_ConfigFrame_LockCategory_Party3Lock_ScaleSlider:SetValue(
         THGF_PartyMember2:GetScale() );
   elseif which=="party4" then
      THGF_PartyMember4:ClearAllPoints();
      THGF_PartyMember4:SetPoint("TOPLEFT", "THGF_PartyMember3", "BOTTOMLEFT", 0, -10);
      THPF_Vars["detached_party4"] = nil;
      THUF_ConfigFrame_LockCategory_Party4Lock_ScaleSlider:SetValue(
         THGF_PartyMember3:GetScale() );
--[[
   elseif which=="party" then
      THGF_PartyMember1:ClearAllPoints();
      THGF_PartyMember2:ClearAllPoints();
      THGF_PartyMember3:ClearAllPoints();
      THGF_PartyMember4:ClearAllPoints();
      THGF_PartyMember1:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -200);
      THGF_PartyMember2:SetPoint("TOPLEFT", "THGF_PartyMember1", "BOTTOMLEFT", 0, -10);
      THGF_PartyMember3:SetPoint("TOPLEFT", "THGF_PartyMember2", "BOTTOMLEFT", 0, -10);
      THGF_PartyMember4:SetPoint("TOPLEFT", "THGF_PartyMember3", "BOTTOMLEFT", 0, -10);

      THPF_Vars["detached_party"] = nil;
      THUF_ConfigFrame_LockCategory_PartyLock_ScaleSlider:SetValue(
         THPF_MainFrame:GetScale() );
--]]
   end
end

function THUF_SetSliderLabel(what, el, value)
   value = string.format("%0.2f", value);
   el:SetText( value );

   if THUF_Config_Opening then
      return;
   end

   THPF_Vars["scale_"..what] = value;

   if what=="player" then
      if not THPF_Vars["detached_pet"] then
         THUF_ConfigFrame_LockCategory_PetLock_ScaleSlider:SetValue(value);
      end
      if not THPF_Vars["detached_target"] then
         THUF_ConfigFrame_LockCategory_TargetLock_ScaleSlider:SetValue(value);
      end
      local x;
      if not THPF_Vars["detached_party0"] then
         THUF_ConfigFrame_LockCategory_Party0Lock_ScaleSlider:SetValue(value);
      end
   elseif what=="target" then
      if not THPF_Vars["detached_tot"] then
         THUF_ConfigFrame_LockCategory_TotLock_ScaleSlider:SetValue(value);
      end
   elseif what=="party0" then
      if not THPF_Vars["detached_party1"] then
         THUF_ConfigFrame_LockCategory_Party1Lock_ScaleSlider:SetValue(value);
      end
   elseif what=="party1" then
      if not THPF_Vars["detached_party2"] then
         THUF_ConfigFrame_LockCategory_Party2Lock_ScaleSlider:SetValue(value);
      end
   elseif what=="party2" then
      if not THPF_Vars["detached_party3"] then
         THUF_ConfigFrame_LockCategory_Party3Lock_ScaleSlider:SetValue(value);
      end
   elseif what=="party3" then
      if not THPF_Vars["detached_party4"] then
         THUF_ConfigFrame_LockCategory_Party4Lock_ScaleSlider:SetValue(value);
      end
   end
end

function THUF_ScaleSliderChanged(which)
   if THUF_Config_Opening then
      return;
   end

   if which=="player" then
      local value = THUF_ConfigFrame_LockCategory_PlayerLock_ScaleSlider:GetValue();
      THPF_MainFrame:SetScale(value);
      THUF_SetSliderLabel( "player",
         THUF_ConfigFrame_LockCategory_PlayerLock_ScaleSlider_Title,
         value);
   elseif which=="target" then
      local value = THUF_ConfigFrame_LockCategory_TargetLock_ScaleSlider:GetValue();
      THTF_TargetFrame:SetScale(value);
      THUF_SetSliderLabel( "target",
         THUF_ConfigFrame_LockCategory_TargetLock_ScaleSlider_Title,
         value);
   elseif which=="tot" then
      local value = THUF_ConfigFrame_LockCategory_TotLock_ScaleSlider:GetValue();
      THTF_TargetFrame_ToT:SetScale(value);
      THUF_SetSliderLabel( "tot",
         THUF_ConfigFrame_LockCategory_TotLock_ScaleSlider_Title,
         value);
   elseif which=="pet" then
      local value = THUF_ConfigFrame_LockCategory_PetLock_ScaleSlider:GetValue();
      THPF_MainFrame_Pet:SetScale(value);
      THUF_SetSliderLabel( "pet",
         THUF_ConfigFrame_LockCategory_PetLock_ScaleSlider_Title,
         value);
   elseif which=="party0" then
      local value = THUF_ConfigFrame_LockCategory_Party0Lock_ScaleSlider:GetValue();
      THGF_PartyMember0:SetScale(value);
      THUF_SetSliderLabel( "party0",
         THUF_ConfigFrame_LockCategory_Party0Lock_ScaleSlider_Title,
         value);
   elseif which=="party1" then
      local value = THUF_ConfigFrame_LockCategory_Party1Lock_ScaleSlider:GetValue();
      THGF_PartyMember1:SetScale(value);
      THUF_SetSliderLabel( "party1",
         THUF_ConfigFrame_LockCategory_Party1Lock_ScaleSlider_Title,
         value);
   elseif which=="party2" then
      local value = THUF_ConfigFrame_LockCategory_Party2Lock_ScaleSlider:GetValue();
      THGF_PartyMember2:SetScale(value);
      THUF_SetSliderLabel( "party2",
         THUF_ConfigFrame_LockCategory_Party2Lock_ScaleSlider_Title,
         value);
   elseif which=="party3" then
      local value = THUF_ConfigFrame_LockCategory_Party3Lock_ScaleSlider:GetValue();
      THGF_PartyMember3:SetScale(value);
      THUF_SetSliderLabel( "party3",
         THUF_ConfigFrame_LockCategory_Party3Lock_ScaleSlider_Title,
         value);
   elseif which=="party4" then
      local value = THUF_ConfigFrame_LockCategory_Party4Lock_ScaleSlider:GetValue();
      THGF_PartyMember4:SetScale(value);
      THUF_SetSliderLabel( "party4",
         THUF_ConfigFrame_LockCategory_Party4Lock_ScaleSlider_Title,
         value);
--[[
   elseif which=="party" then
      local value = THUF_ConfigFrame_LockCategory_PartyLock_ScaleSlider:GetValue();
      THGF_PartyMember1:SetScale(value);
      THGF_PartyMember2:SetScale(value);
      THGF_PartyMember3:SetScale(value);
      THGF_PartyMember4:SetScale(value);
      THUF_SetSliderLabel( "party",
         THUF_ConfigFrame_LockCategory_PartyLock_ScaleSlider_Title,
         value);
--]]
   end
end

function THUF_ForceVisibleChange(value)
   if THUF_Config_Opening then
      return;
   end

   THPF_Vars["forcevisible"] = value; 
   if value then
      if not UnitExists("target") then
         THTF_SetDummyValues();
      end
      THTF_UpdateTargetOfTarget();
      THPF_ExpBarUpdate();
      THPF_PetUpdate();
      THGF_UpdateAll(true);
   else
      if not UnitExists("target") then
         THTF_IsHiding = true;
      else
         THTF_AuraUpdate();
      end
      THTF_UpdateTargetOfTarget();
      THPF_ExpBarUpdate();
      THPF_PetUpdate();
      THGF_UpdateAll(true);
   end
end

function THUF_ResetAll()
   THUF_ResetFrame("party4");
   THUF_ResetFrame("party3");
   THUF_ResetFrame("party2");
   THUF_ResetFrame("party1");
   THUF_ResetFrame("party0");
   THUF_ResetFrame("pet");
   THUF_ResetFrame("tot");
   THUF_ResetFrame("target");
   THUF_ResetFrame("player");
   THUF_ConfigFrame_LockCategory_PlayerLock_ScaleSlider:SetValue( UIParent:GetScale() );
end
