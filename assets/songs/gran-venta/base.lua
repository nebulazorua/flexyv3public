-- by Nebula the Zorua / @Nebula_Zorua

-- DO NOT TOUCH --
local queuedFuncs = {}

function queueFunc(startStep, endStep, callback)
    table.insert(queuedFuncs, {startStep, endStep, callback})
end

function queueEveryBeat(startStep, endStep, callback)
    for step = startStep, endStep do
        if(step%4==0)then
            local beat = step/4;
            callback(step,beat)
        end
    end
end

function onUpdate(elapsed)
    for i = #queuedFuncs, 1, -1 do
        local d = queuedFuncs[i];
        if(curDecStep>=d[1] and curDecStep<=d[2])then
            d[3](curDecStep, curDecBeat)
        elseif(curDecStep>d[2])then
            table.remove(queuedFuncs,i)
        end
    end
end

function define(name, defaultVal)
    modMgr:define(name)
    modMgr:set(name, defaultVal)
end

return {
    queueSet = function(...)return modMgr:queueSet(...)end;
    queueEase = function(...)return modMgr:queueEase(...)end;
    queueFunc = queueFunc;

    queueSetB = function(step,...)return modMgr:queueSet(step*4,...)end;
    queueEaseB = function(startstep,endstep,...)return modMgr:queueEase(startstep*4,endstep*4,...)end;
    queueFuncB = function(startstep,endstep,...)return modMgr:queueFunc(startstep*4,endstep*4,...)end;

    define = define;
    
    queueEveryBeat = queueEveryBeat;

    onUpdate = onUpdate;
}