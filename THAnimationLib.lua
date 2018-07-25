
--[[

  Tempora Heroica Animation Library
  Version 1

  YOU SHOULD NOT MODIFY THIS FILE!  Modifications to this file may not be honored if
  a user has other addons that include this library!

  You can include this .lua file in your addon, and simply reference it in your .toc file.
  If multiple addons do this, the addon that has the latest version of this library will
  provide the implementation.

  You may also add "THAnimation" as an OptionalDep for your addon, which provides advanced
  controls, such as the ability to disable animations.  The full addon is -not- required.

  API:

  * THAnim.AnimateFrame(frame, afunc, from, to, length, oncomp)
      Starts a frame animation. The frame specified in 'frame' will be animated over the
      next 'length' seconds, adjusting the property specified via 'afunc' from the value
      specified in 'from', to the value specified in 'to'.  The 'oncomp' handler will be
      called at the end of the animation, if specified.  Examples:

      'afunc' may be a method reference, or a string containing the name of the method
      on 'frame' to call.  For example:

        THAnim.AnimateFrame(MyAddon_MainFrame, "SetAlpha", 1, 0, 0.5, nil);

--]]



local THANIM_VERSION = 1;

if not THAnim or
   THAnim.version < THANIM_VERSION then

    local needInit = true;
    local headEvent = nil;
    -- headEvent is a double-linked list of animations queued/in-progress, sorted by animStart.
    -- Format:
    --   headEvent.animStart -- GetTime() to start animation
    --   headEvent.animFinish -- GetTime() to finish animation
    --   headEvent.previousEvent -- previous event in double-linked list (nil if first)
    --   headEvent.nextEvent -- next event in double-linked list (nil if last)
    --   headEvent.fromValue -- starting value of animation
    --   headEvent.toValue -- ending value of animation
    --   headEvent.adapter -- function to modify frame value
    --   headEvent.targetFrame -- frame being modified (passed as param 1 to adapter)
    --   headEvent.onComplete -- function called when animation finishes (optional)

    THAnim = {
        Version = THANIM_VERSION;

        AnimateFrame = function(frame, afunc, from, to, length, oncomp)
            THAnim.Initialize();

            local now = GetTime();
            local nev = {
                animStart = now;
                animFinish = now + length;
                previousEvent = nil;
                nextEvent = nil;
                fromValue = from;
                toValue = to;
                adapter = afunc;
                targetFrame = frame;
                onComplete = oncomp;
            };
            THAnim.AddEvent(nev);
            return nev;
        end;

  -- INTERNAL FUNCTIONS -- DO NOT CALL THESE DIRECTLY --

        Initialize = function()
            if not needInit then
                return;
            end
            local f = CreateFrame("Frame", "THAnim_EventFrame", UIParent);
            f:SetScript("OnUpdate", THAnim.OnUpdate);
        end;

        OnUpdate = function(interval)
            if not headEvent or headEvent.animStart > GetTime() then
                return;
            end
            local now = GetTime();
            local thisEvent = headEvent;
            while thisEvent and thisEvent.animStart <= now do
                THAnim.ProcessAnimationStep(now, interval, thisEvent);
                thisEvent = thisEvent.nextEvent;
            end
        end;

        ProcessAnimationStep = function(now, interval, event)
            if event.animFinish <= now then
                if type(event.adapter)=="string" then
                    event.targetFrame[event.adapter](event.targetFrame, event.toValue);
                else
                    event.adapter(event.targetFrame, event.toValue);
                end
                THAnim.RemoveEvent(event);
                if event.onComplete then
                    event.onComplete();
                end
                return;
            end
            local timedelta = (event.animFinish - event.animStart);
            local persec = (event.toValue - event.fromValue) / timedelta;
            local curval = ((timedelta - (event.animFinish - now)) * persec) + event.fromValue;
            if type(event.adapter)=="string" then
                event.targetFrame[event.adapter](event.targetFrame, curval);
            else
                event.adapter(event.targetFrame, curval);
            end
        end;

        AddEvent = function(event)
            if not headEvent or headEvent.animStart >= event.animStart then
                event.nextEvent = headEvent;
                event.previousEvent = nil;
                if headEvent then
                    headEvent.previousEvent = event;
                end
                headEvent = event;
                return;
            end
            local levent = headEvent.nextEvent;
            local pevent = headEvent;
            while levent do
                if levent.animStart >= event.animStart then
                    event.nextEvent = levent;
                    event.previousEvent = levent.previousEvent;
                    levent.previousEvent.nextEvent = event;
                    levent.previousEvent = event;
                    return;
                end
                pevent = levent;
                levent = levent.nextEvent;
            end
            event.previousEvent = pevent;
            event.nextEvent = nil;
            pevent.nextEvent = event;
            return;
        end;

        RemoveEvent = function(event)
            if event.nextEvent then
                event.nextEvent.previousEvent = event.previousEvent;
            end
            if event.previousEvent then
                event.previousEvent.nextEvent = event.nextEvent;
            elseif headEvent == event then
                headEvent = event.nextEvent;
            end
            event.nextEvent = nil;
            event.previousEvent = nil;
        end;
    };

end
