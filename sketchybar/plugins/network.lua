#!/usr/bin/env lua

local function exec(cmd)
	local h = io.popen(cmd)
	if not h then
		return ""
	end
	local o = h:read("*a") or ""
	h:close()
	return o
end

local function link_bytes(iface)
	local out = exec("netstat -ibn -I " .. iface .. " 2>/dev/null")
	for line in out:gmatch("[^\n]+") do
		if line:find("<Link#", 1, true) then
			local t = {}
			for tok in line:gmatch("%S+") do
				t[#t + 1] = tok
			end
			return tonumber(t[#t - 4]), tonumber(t[#t - 1])
		end
	end
	return nil, nil
end

local function human(bps)
	local k = bps / 1024
	if k < 9.95 then
		return string.format("%.1fK", k)
	elseif k < 999.5 then
		return string.format("%.0fK", k)
	end
	local m = k / 1024
	if m < 9.95 then
		return string.format("%.1fM", m)
	elseif m < 999.5 then
		return string.format("%.0fM", m)
	end
	return string.format("%.1fG", m / 1024)
end

local iface = exec("route -n get default 2>/dev/null"):match("interface:%s+(%S+)") or "en0"
local rx1, tx1 = link_bytes(iface)
os.execute("sleep 1")
local rx2, tx2 = link_bytes(iface)

local down = (rx1 and rx2 and rx2 > rx1) and (rx2 - rx1) or 0
local up = (tx1 and tx2 and tx2 > tx1) and (tx2 - tx1) or 0

os.execute(string.format(
	"sketchybar --set net.down label='%s' --set net.up label='%s'",
	human(down),
	human(up)
))
