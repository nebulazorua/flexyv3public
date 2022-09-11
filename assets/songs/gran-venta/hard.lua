local function require(module)
    local file = debug.getinfo(1).source
    local directory = file:sub(2,#file-8)
    -- TODO: _FILEDIRECTORY
    print(directory .. module)
    return getfenv().require(directory .. module)
end

local utils = require("base")

-- aight put your shit here
utils.define("windowTipsy",0)
utils.define("windowDrunk",0)
utils.define("windowBop",0)
utils.define("windowX",0)
utils.define("windowY",0)
utils.define("aberration",0)
utils.define("hudAberration",0)

local windowX = (window.boundsWidth - window.width)/2;
local windowY = (window.boundsHeight - window.height)/2;

local counter = 0;

for shit = 1952, 1984, 4 do
    counter = counter + 1;
    modMgr:queueSet(shit, "squish", 75, 1)
    modMgr:queueEase(shit, shit+4, "squish", 0, "quartOut", 1)

    if(counter%3==0)then
        modMgr:queueEase(shit, shit+4, "invert", 0, "quintOut", 1)
        modMgr:queueEase(shit, shit+4, "flip", 100, "quintOut", 1)
    elseif(counter%3==1)then
        modMgr:queueEase(shit, shit+4, "flip", 0, "quintOut", 1)
        modMgr:queueEase(shit, shit+4, "invert", 100, "quintOut", 1)
    elseif(counter%3==2)then
        modMgr:queueEase(shit, shit+4, "invert", -75, "quintOut", 1)
        modMgr:queueEase(shit, shit+4, "flip", 25, "quintOut", 1)
    end
end

modMgr:queueEase(1984, 1988, "invert", 0, "quadOut", 1)
modMgr:queueEase(1984, 1988, "flip", 0, "quadOut", 1)
modMgr:queueEase(1984, 1988, "confusion0", 0, "quadOut", 1)
modMgr:queueEase(1984, 1988, "confusion1", 0, "quadOut", 1)
modMgr:queueEase(1984, 1988, "confusion2", 0, "quadOut", 1)
modMgr:queueEase(1984, 1988, "confusion3", 0, "quadOut", 1)

for step = 2428, 2496, .5 do
    modMgr:queueSet(step, 'reverse', -5)
    modMgr:queueEase(step, step+0.75, 'reverse', 0, 'linear')
end

modMgr:queueSet(2496, "drunk", 50)
modMgr:queueSet(2496, "tipsy", 50)

local shit = {
    2560,
    2576,
    2592,
    2600,
}

local shittier = {
    2608,
    2612,
    2614,
    2615,
    2616,
    2617,
    2618,
    2619,
    2620,
    2621,
    2622,
    2623,
}

local invDrunk = 1;
local invTipsy = 1;



for i = 1, #shit do
    local nowcanyoustfu = i%2;
    local modType = i%3;
    local percent = nowcanyoustfu*100
    local step = shit[i]
    modMgr:queueSet(step, 'hudAberration', (i/(#shit + #shittier)) * 100)
    modMgr:queueSet(step, 'aberration', (i/(#shit + #shittier)) * 100, 1)
    modMgr:queueSet(step, "squish", 125, 1)
    modMgr:queueEase(step, step+2, "squish", 0, "quartOut", 1)

    if(nowcanyoustfu==0)then
        modMgr:queueSet(step,'tipsy',200*invTipsy)
        modMgr:queueEase(step,step+2, 'tipsy', 100, 'cubeOut')
        invTipsy = invTipsy * -1
    else
        modMgr:queueSet(step,'drunk',200*invDrunk)
        modMgr:queueEase(step,step+2, 'drunk', 100, 'cubeOut')
        invDrunk = invDrunk * -1
    end

    if(modType==0)then
        modMgr:queueEase(step, step+2, "invert", 0, "quintOut", 1)
        modMgr:queueEase(step, step+2, "flip", 100, "quintOut", 1)

    elseif(modType==1)then
        modMgr:queueEase(step, step+2, "flip", 25, "quintOut", 1)
        modMgr:queueEase(step, step+2, "invert", 125, "quintOut", 1)

    elseif(modType==2)then
        modMgr:queueEase(step, step+2, "flip", 25, "quintOut", 1)
        modMgr:queueEase(step, step+2, "invert", -75, "quintOut", 1)

    end
end


for i = 1, #shittier do
    local nowcanyoustfu = i%2;
    local modType = i%3;
    local percent = nowcanyoustfu*100
    local step = shittier[i]
    modMgr:queueSet(step, 'hudAberration', ((#shit + i)/(#shit + #shittier)) * 100)
    modMgr:queueSet(step, 'aberration', ((#shit + i)/(#shit + #shittier)) * 100, 1)
    modMgr:queueSet(step, "squish", 125, 1)
    modMgr:queueEase(step, step+2, "squish", 0, "quartOut", 1)

    
    if(nowcanyoustfu==0)then
        modMgr:queueSet(step,'tipsy',200*invTipsy)
        modMgr:queueEase(step,step+2, 'tipsy', 0, 'cubeOut')
        invTipsy = invTipsy * -1
    else
        modMgr:queueSet(step,'drunk',200*invDrunk)
        modMgr:queueEase(step,step+2, 'drunk', 0, 'cubeOut')
        invDrunk = invDrunk * -1
    end

    if(modType==0)then
        modMgr:queueEase(step, step+2, "invert", 0, "quintOut", 1)
        modMgr:queueEase(step, step+2, "flip", 100, "quintOut", 1)
    elseif(modType==1)then
        modMgr:queueSet(step, "stretch", 100, 1)
        modMgr:queueEase(step, step+2, "stretch", 0, "quartOut", 1)
        modMgr:queueEase(step, step+2, "flip", 25, "quintOut", 1)
        modMgr:queueEase(step, step+2, "invert", 125, "quintOut", 1)
        modMgr:queueEase(step, step+2, "reverse", 100, "quintOut", 1)
    elseif(modType==2)then
        modMgr:queueSet(step, "stretch", 100, 1)
        modMgr:queueEase(step, step+2, "stretch", 0, "quartOut", 1)
        modMgr:queueEase(step, step+2, "flip", 0, "quintOut", 1)
        modMgr:queueEase(step, step+2, "reverse", 0, "quintOut", 1)

        modMgr:queueEase(step, step+2, "flip", 25, "quintOut", 1)
        modMgr:queueEase(step, step+2, "invert", -75, "quintOut", 1)

    end
end

local kickTemplate = {
    {2624, 0},
    {2632, 1},
    {2642, 0},
    {2644, 0},
    {2648, 1},

    {2656, 0},
    {2664, 1},
    {2670, 0},
    {2674, 0},
    {2676, 0},
    {2680, 1},

    {2688, 0},
    {2696, 1},
    {2706, 0},
    {2706, 0},
    {2708, 0},
    {2712, 1},
    
    {2720, 0},
    {2728, 1},
    {2734, 0},
    {2738, 0},
    {2740, 1},
    {2744, 0},
    {2746, 0},
    {2748, 1},
}

local kicks = {}
for i = 1,#kickTemplate do
    kickTemplate[i][1] = kickTemplate[i][1]-2624;
end

for sec = 164, 196, 8 do
    local step = sec * 16;
    for i = 1,#kickTemplate do
        local s = kickTemplate[i][1] + step
        if(s<2864 or sec>=180 and s<3136)then
            local newKick = {
                s,
                kickTemplate[i][2],
                sec<180 and 0 or 1
            }
            table.insert(kicks, newKick)
        end
    end
end

for _,v in next, {
    {2864,0,-1},
    {2866,0,-1},
    {2868,1,-1},
    {2872,0,-1},
    {2874,0,-1},
    {2876,1,-1},
    {2876.5,0,-1},
    {2877,1,-1},
    {2877.5,1,-1},
    {2878,0,-1},
    {2878.5,0,-1},
    {2879,0,-1},
    {2879.5,1,-1},
}do
    table.insert(kicks, v)
end

table.sort(kicks, function(a,b) return a[1]<b[1] end)

for i = 1,#kicks do
    local step, type, pn = unpack(kicks[i])
    if(type==0)then
        modMgr:queueSet(step,'drunkOffset',-75*invDrunk,pn)
        modMgr:queueSet(step,'drunk',250*invDrunk,pn)
        modMgr:queueSet(step,'windowDrunk',(pn==1 and 25 or 0)+(50*invDrunk)*(pn==0 and 1 or 0.25),0)
        modMgr:queueEase(step,step+4, 'drunk', 0, 'cubeOut', pn)
        modMgr:queueEase(step,step+4, 'windowDrunk', pn==1 and 25 or 0, 'cubeOut', 0)
        modMgr:queueEase(step,step+4, 'drunkOffset', 0, 'cubeOut', pn)
        invDrunk = invDrunk * -1
    elseif(type==1)then
        modMgr:queueSet(step,'tipsyOffset',-75*invTipsy,pn)
        modMgr:queueSet(step,'tipsy',250*invTipsy,pn)
        modMgr:queueSet(step,'windowTipsy',(pn==1 and 25 or 0)+(50*invTipsy)*(pn==0 and 1 or 0.25),0)
        if(step~=2879.5)then
            modMgr:queueEase(step,step+4, 'tipsy', 100, 'cubeOut', pn)
        end
        modMgr:queueEase(step,step+4, 'windowTipsy', pn==1 and 25 or 0, 'cubeOut', 0)
        modMgr:queueEase(step,step+4, 'tipsyOffset', 0, 'cubeOut', pn)
        invTipsy = invTipsy * -1
    end
end

modMgr:queueSet(2625, "squish", 125, 1)
modMgr:queueEase(2625, 2627, "squish", 0, "quartOut", 1)
modMgr:queueSet(2625, "stretch", 125, 1)
modMgr:queueEase(2625, 2627, "stretch", 0, "quartOut", 1)
modMgr:queueEase(2625, 2627, "flip", 0, "quintOut", 1)
modMgr:queueEase(2625, 2627, "invert", 0, "quintOut", 1)
modMgr:queueEase(2625, 2627, "reverse", 0, "quintOut", 1)

modMgr:queueEase(2496, 2500, "windowTipsy", 50, 'quadOut')


modMgr:queueEase(2624, 2628, "windowTipsy", 0, 'quadOut')
modMgr:queueEase(2624, 2628, "windowBop", 100, 'quadOut')

modMgr:queueSet(2688, "stretch", 150, 0)
modMgr:queueEase(2688,2692, "stretch", 0, 'quadOut', 0)
modMgr:queueEase(2688,2692, "reverse", 100, 'quintOut', 0)

modMgr:queueSet(2752, "stretch", 150, 0)
modMgr:queueEase(2752,2756, "stretch", 0, 'quadOut', 0)
modMgr:queueEase(2752,2756, "reverse", 0, 'quintOut', 0)

modMgr:queueEase(2816,2820, "alpha", 90, 'quadOut', 1)

modMgr:queueSet(2816, "miniX", -75)
modMgr:queueSet(2816, "miniY", 50)
modMgr:queueEase(2816,2820, "miniX", 0, 'quadOut')
modMgr:queueEase(2816,2820, "miniY", 0, 'quadOut')
modMgr:queueEase(2816,2820, "opponentSwap", 50, 'quintOut')

modMgr:queueEase(2880,2884, "alpha", 0, 'quadOut', 1)
modMgr:queueSet(2880, "miniX", -75)
modMgr:queueSet(2880, "miniY", 50)
modMgr:queueEase(2880,2884, "miniX", 0, 'quadOut')
modMgr:queueEase(2880,2884, "miniY", 0, 'quadOut')
modMgr:queueEase(2880,2884, "opponentSwap", 0, 'quintOut')

modMgr:queueEase(2864,2880, "windowBop", 35, 'quadOut')
modMgr:queueEase(2864,2880, "windowDrunk", 25, 'quadOut')
modMgr:queueEase(2864,2880, "windowTipsy", 25, 'quadOut')
modMgr:queueEase(2880,2884, "tipsy", 25, 'quadOut', 0)
modMgr:queueEase(2880,2884, "tipsySpeed", -35, 'quadOut')
local alt = 1;

modMgr:queueEase(2864, 2876, 'aberration', 125, 'cubeOut', 0)
modMgr:queueEase(2864, 2876, 'aberration', 50, 'cubeOut', 1)

modMgr:queueSet(2864, "squish", 75, 1)
modMgr:queueEase(2864,2870, "squish", 0, 'quartOut', 1)
modMgr:queueEase(2864,2870, "transformX", 0, 'quintOut', 1)

modMgr:queueSet(3024, "squish", 75, 1)
modMgr:queueEase(3024,3030, "squish", 0, 'quartOut', 1)
modMgr:queueEase(3024,3030, "transformX", 0, 'quintOut', 1)

modMgr:queueEase(3136,3168, "windowTipsy", 0, 'quadOut')
modMgr:queueEase(3136,3168, "windowDrunk", 0, 'quadOut')
modMgr:queueEase(3136,3168, "windowBop", 0, 'quartOut')
modMgr:queueEase(3136,3168, "alpha", 100, 'linear')
modMgr:queueEase(3136,3168, "tipsy", 0, 'linear')

modMgr:queueEase(3136,3168, "aberration", 0, 'linear')
modMgr:queueEase(3136,3168, "hudAberration", 0, 'linear')
local mult = 1;
local timer = 0;
function update(elapsed)
    timer = songPosition / 1000
    
    -- window mods
    do
        local offX = 0;
        local offY = 0;
        local windowTipsy = modMgr:get("windowTipsy",0)
        local windowDrunk = modMgr:get("windowDrunk",0)
        local windowMerchant = modMgr:get("windowBop",0)
        local windowOffX = ((modMgr:get("windowX", 0) * 100)) / (window.boundsWidth / 1920)
        local windowOffY = ((modMgr:get("windowY",0) * 100)) / (window.boundsHeight / 1080)
        offX = offX + windowOffX;
        offY = offY + windowOffY;
        if(windowDrunk  ~=0)then
            offX = offX + windowDrunk * (math.cos((timer)) * window.width*.3);
        end
        if(windowTipsy~=0)then
            offY = offY + windowTipsy * (math.sin((timer * 1.2)) * window.height*.2);
        end
        if(windowMerchant~=0)then
            offY = offY - windowMerchant * ((math.cos(timer*8)*72) * 1)
            offX = offX + windowMerchant * ((math.sin(timer*4)*48) * 1)
        end

        window.x = windowX + offX;
        window.y = windowY + offY;
    end

    --setDadAberration(modMgr:get("aberration",1)*15);
    --setBFAberration(modMgr:get("aberration",0)*5);
    --setHudAberration(modMgr:get("hudAberration",0)*25);
    utils.onUpdate(elapsed);
    
end