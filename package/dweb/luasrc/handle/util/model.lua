module ("luci.handle.util.model", package.seeall)

local ComFun = require("luci.handle.common.function")
local LuciUci = require("luci.model.uci").cursor()
local Log = require("luci.handle.util.log")
local Config = require("luci.handle.common.config")

function getConfigByName(config, name)
  local rw = {}
  rw.config = config
  rw.name = name
  rw.options = LuciUci:get_all(config, name) or {}
  --Log.print_r(rw)
  return rw
end

function getConfigByType(config, type)
  local rw = {}
  local tmp = {}
  local name = ComFun.getSectionName(config, type)
  Log.print_r(name)
  for i, v in ipairs(name) do
    tmp = {}
    tmp.config = config
    tmp.name = v
    tmp.options = LuciUci:get_all(config, v) or {}
    rw[#rw+1] = tmp
    Log.print_r(rw)
  end

  return rw
end

function getTimeInfo()
	local c = LuciUci.cursor()
	local rw = {}
	local systemId = ComFun.getSectionName("system", 'system')[1]
	rw.timezone = c:get("system", systemId, "timezone")
	rw.server = c:get("system", "ntp", 'server')
	rw.enabled = c:get('system', "ntp", "enabled")
	rw.enable_server = c:get('system', "ntp", "enable_server")
	return rw
end

function getInterfaceStatistics()
	local s = luci.util.execl(Config.INTERFACE_STATISTICS_FILE)

	local rw = {}
	for i, v in ipairs(s) do
		local tmp = {}
		tmp.interface, tmp.rx_bytes, tmp.rx_packets, tmp.rx_errs, tmp.rx_drop, tmp.rx_fifo, tmp.rx_frame, tmp.rx_compressed, tmp.rx_multicast, tmp.tx_bytes, tmp.tx_packets, tmp.tx_errs, tmp.tx_drop, tmp.tx_fifo, tmp.tx_colls, tmp.tx_carrier, tmp.tx_compressed = string.match(v, "(%S+):%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
		if tmp.interface == "ra0" or tmp.interface == "apcli0" or tmp.interface == "eth0.2" or tmp.interface == "br-lan" then
			rw[#rw+1] = tmp
		end
	end
	--MtkLog.print_r(rw)
	return  rw
end

function getStaticDHCPInfo()
	local LuciUci = require "luci.model.uci"
	local c = LuciUci.cursor()
	local rw = {}
	c:foreach("dhcp", "host",
		function(s)
			local item = {
				sId = s['.name'],
				ip = s.ip,
				name = s.name,
				mac = s.mac
			}
			rw[#rw+1] = item
		end)
	return rw
end
