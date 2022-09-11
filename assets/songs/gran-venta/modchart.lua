local function require(module)
    local file = debug.getinfo(1).source
    local directory = file:sub(2,#file-12)
    -- TODO: _FILEDIRECTORY
    print(directory .. module)
    return getfenv().require(directory .. module)
end

if(storyDifficulty==2)then
    require("hard")
elseif(storyDifficulty==3)then
    require("erect")
end