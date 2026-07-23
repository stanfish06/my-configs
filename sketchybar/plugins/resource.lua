#!/usr/bin/env lua
-- Resource monitor — pure Lua, no Python
-- CPU gold, RAM foam, SWAP iris — compact labels to avoid cutoff

local function exec(cmd)
	local h = io.popen(cmd)
	if not h then
		return ""
	end
	local o = h:read("*a") or ""
	h:close()
	return o
end

local function cpu_percent()
	local out = exec("top -l 2 -n 0 2>/dev/null")
	local lu, ls
	for u, s in out:gmatch("CPU usage:%s+([%d%.]+)%% user,%s+([%d%.]+)%% sys") do
		lu = tonumber(u)
		ls = tonumber(s)
	end
	return lu and (lu + ls) or 0
end

local function ram_usage()
	local vm = exec("vm_stat 2>/dev/null")
	local ps = tonumber(vm:match("page size of (%d+) bytes")) or 16384
	local function pg(l)
		return tonumber(vm:match(l .. ":%s+(%d+)%.")) or 0
	end
	local used = (pg("Pages active") + pg("Pages inactive") + pg("Pages wired down")) * ps
	local total = tonumber(exec("sysctl -n hw.memsize 2>/dev/null")) or 0
	return used, total
end

local function swap_usage()
	local out = exec("sysctl -n vm.swapusage 2>/dev/null")
	local um = tonumber(out:match("used = ([%d%.]+)M")) or 0
	local tm = tonumber(out:match("total = ([%d%.]+)M")) or 0
	return um * 1024 * 1024, tm * 1024 * 1024
end

local function gb(b)
	return b / (1024 ^ 3)
end

local cpu = cpu_percent()
local ru, rt = ram_usage()
local su, st = swap_usage()

local cpu_l = string.format("%.0f%%", cpu)
local ram_l = string.format("%.1f/%.0fG", gb(ru), gb(rt))
local swap_l = string.format("%.1f/%.0fG", gb(su), gb(st))
local swap_draw = (gb(st) > 0.5 and gb(su) > 0.5) and "on" or "off"

local cmd = string.format(
	"sketchybar --set resource.cpu label='%s' --set resource.ram label='%s' --set resource.swap label='%s' drawing=%s",
	cpu_l,
	ram_l,
	swap_l,
	swap_draw
)
os.execute(cmd)
