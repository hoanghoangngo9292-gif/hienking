-- HIEN VIP LOADER
local req = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)

local function fetch(url)
    local ok, res = pcall(function()
        return req({ Url = url, Method = "GET" })
    end)
    return ok and res and res.Body or nil
end

-- Check status
local status = fetch("https://raw.githubusercontent.com/hoanghoangngo9292-gif/hienking/refs/heads/main/status.lua")

if status and status:find("activefree") then
    -- Load main script
    local main = fetch("https://raw.githubusercontent.com/hoanghoangngo9292-gif/hienking/refs/heads/main/.lua")
    if main then
        local fn, err = loadstring(main)
        if fn then fn()
        else warn("Loi: " .. tostring(err)) end
    else
        warn("Khong tai duoc script!")
    end
else
    warn("Script da tat!")
end
