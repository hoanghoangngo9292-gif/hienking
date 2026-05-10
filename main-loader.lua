local STATUS_URL = "https://raw.githubusercontent.com/hoanghoangngo9292-gif/hienking/refs/heads/main/status.lua?t=" .. tostring(os.time())
local SCRIPT_URL = "https://xhider.xyz/raw/hienbin1712/hienbeo.lua"
local KEYWORD = "activefree"

local ok, content = pcall(function()
    return game:HttpGet(STATUS_URL)
end)

if not ok then return end

if string.find(content, KEYWORD) then
    loadstring(game:HttpGet(SCRIPT_URL))()
else
    print("het han su dung")
end
