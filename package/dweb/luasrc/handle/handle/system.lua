module ("luci.handle.handle.system", package.seeall)

local LuciHttp = require "luci.http"
local LuciUci = require("luci.model.uci").cursor()
local ComFun = require("luci.handle.common.function")
local LuciSys = require "luci.sys"
local Log = require("luci.handle.util.log")

function setLogin(password)
	luci.sys.user.setpasswd(luci.dispatcher.context.authuser, password)
end
function setTime()
	local c = LuciUci.cursor()
  local timezone = LuciHttp.formvalue("timezone")
  local enabled = LuciHttp.formvalue("enabled")
  local server1 = LuciHttp.formvalue("server1")
  local server2 = LuciHttp.formvalue("server2")
  local server3 = LuciHttp.formvalue("server3")
  local server4 = LuciHttp.formvalue("server4")
	local systemId = MtkFunction.getSectionName("system", 'system')[1]
	c:set("system", systemId, "timezone", timezone)
	c:set("system", "ntp", "enabled", enabled)
	c:delete("system", "ntp", "server")
	c:set_list("system", "ntp", "server", {server1, server2, server3, server4})
	c:commit("system")
end
