module ("luci.handle.handle.network", package.seeall)

local LuciHttp = require "luci.http"
local LuciUci = require("luci.model.uci").cursor()
local Config = require("luci.handle.common.config")
local ComFun = require("luci.handle.common.function")
local Log = require("luci.handle.util.log")
function set3g()
  LuciUci:set("network", "wan2", "enabled", '1')
end

function setStaticDNS()
  local dns1 = LuciHttp.formvalue("dns1")
  local dns2 = LuciHttp.formvalue('dns2')
  LuciUci:set_list("network", "wan", "dns", {dns1, dns2})
end



function setOpMode()
  Log.print("setOpMode")
  local wifi2gSid = "default_mt7628"
  local opmode = LuciHttp.formvalue("model,network,op,mode")
  local c = LuciUci.cursor()
  if opmode == "gateway" then
    c:set("network", "lan", "ifname", "eth0.1")
    c:set("network", "wan", "ifname", 'eth0.2')
    c:set("network", "wan", "proto", "dhcp")
    c:set("dhcp", "lan", "ignore", "0")
    c:set("wireless", wifi2gSid, "ApCliEnable", "0")
    c:set("wireless", wifi2gSid, "hidden", "0")
    ComFun.forkExec("echo 0 > /sys/class/leds/mt7628\:blue\:wifi/brightness");
  elseif opmode == "bridge" then
    c:set("network", "lan", "ifname", "eth0.1 eth0.2")
    c:set("network", "wan", "ifname", "")
    c:set("dhcp", "lan", "ignore", "1")
    c:set("wireless", wifi2gSid, "ApCliEnable", "0")
    c:set("wireless", wifi2gSid, "hidden", "0")
    ComFun.forkExec("echo 0 > /sys/class/leds/mt7628\:blue\:wifi/brightness");
  elseif opmode == "repeater" then
    c:set("network", "lan", "ifname", "eth0.1 eth0.2 apcli0")
    c:set("network", "wan", "ifname", "")
    c:set("dhcp", "lan", "ignore", "1")
    c:set("wireless", wifi2gSid, "ApCliEnable", "1")
    c:set("wireless", wifi2gSid, "hidden", "0")
    ComFun.forkExec("echo 0 > /sys/class/leds/mt7628\:blue\:wifi/brightness");
  elseif opmode == "wisp" then
    c:set("network", "lan", "ifname", "eth0.1 eth0.2")
    c:set("network", "wan", "ifname", "apcli0")
    c:set("dhcp", "lan", "ignore", "0")
    c:set("wireless", wifi2gSid, "ApCliEnable", "1")
    c:set("wireless", wifi2gSid, "hidden", "0")
    ComFun.forkExec("echo 0 > /sys/class/leds/mt7628\:blue\:wifi/brightness");
  elseif opmode == "client" then
    c:set("network", "lan", "ifname", "eth0.1 eth0.2 apcli0")
    c:set("network", "wan", "ifname", "")
    c:set("dhcp", "lan", "ignore", "1")
    c:set("wireless", wifi2gSid, "ApCliEnable", "1")
    c:set("wireless", wifi2gSid, "hidden", "1")
    ComFun.forkExec("echo 1 > /sys/class/leds/mt7628\:blue\:wifi/brightness");
  elseif opmode == "client_wisp" then
    c:set("network", "lan", "ifname", "eth0.1 eth0.2")
    c:set("network", "wan", "ifname", "apcli0")
    c:set("dhcp", "lan", "ignore", "0")
    c:set("wireless", wifi2gSid, "ApCliEnable", "1")
    c:set("wireless", wifi2gSid, "hidden", "1")
    ComFun.forkExec("echo 1 > /sys/class/leds/mt7628\:blue\:wifi/brightness");
  end
  c:commit("wireless")
  c:commit("network")
  c:commit("dhcp")
end


function setLanStaticDHCP(name,mac,ip)
	local LuciUci = require("luci.model.uci")
	local c  = LuciUci.cursor()
	local cId = c:add("dhcp", "host")
	c:set("dhcp", cId, "name", name)
	c:set("dhcp", cId, "mac", mac)
	c:set("dhcp", cId, "ip", ip)
	c:commit("dhcp")
end

function delectStaticDHCP(sId)
	local LuciUci = require "luci.model.uci"
	local c = LuciUci.cursor()
	c:delete("dhcp", sId)
	c:commit("dhcp")
end


function delectAllStaticDHCP()
	local LuciUci = require "luci.model.uci"
	local c = LuciUci.cursor()
	c:delete_all("dhcp", "host")
	c:commit("dhcp")
end


function setLanDHCP()
    local startReq = LuciHttp.formvalue("startReq")
    local endReq = LuciHttp.formvalue("endReq")
    local leasetimeMinute = LuciHttp.formvalue("leasetimeMinute")
    local LuciUci = require("luci.model.uci")
    local uciCursor  = LuciUci.cursor()
    local leasetime = leasetimeMinute .. "h"
    local limit = tonumber(endReq) - tonumber(startReq) + 1
    uciCursor:set("dhcp", "lan", "start", tonumber(startReq))
    uciCursor:set("dhcp", "lan", "limit", tonumber(limit))
    uciCursor:set("dhcp", "lan", "leasetime", leasetime)
end
