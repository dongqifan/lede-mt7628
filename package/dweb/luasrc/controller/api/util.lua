module("luci.controller.api.util", package.seeall)
function index()
    local page   = node("api","common")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 500
    page.sysauth = "root"
    page.sysauth_template = "sysauth_dweb"
    page.sysauth_authenticator = "htmlauth"
    page.index = true
    entry({"api", "util"}, firstchild(), (""), 501)
    entry({"api", "util", "get_site_survey"}, call("get_site_survey"), (""), 502)
    entry({"api", "util", "site_survey"}, call("site_survey"), (""), 503)
    entry({"api", "util", "setStaticDhcp"}, call("setStaticDhcp"), (""), 504)
    entry({"api", "util", "detectStaticDhcp"}, call("detectStaticDhcp"), (""), 505)
    entry({"api", "util", "delectAllStaticDhcp"}, call("delectAllStaticDhcp"), (""), 506)
    entry({"api", "util", "macPolicyDelect"}, call("macPolicyDelect"), (""), 507)
    entry({"api", "util", "macPolicyDelectAll"}, call("macPolicyDelectAll"), (""), 508)
    entry({"api", "util", "setMacPolicy"}, call("setMacPolicy"), (""), 509)
    entry({"api", "util", "startWps"}, call("startWps"), (""), 510)
    entry({"api", "util", "port_forwarding"}, call("port_forwarding"), (""), 511)
    entry({"api", "util", "dmz"}, call("dmz"), (""), 512)

    entry({"api", "util", "detectPortForwarding"}, call("detectPortForwarding"), 513)
    entry({"api", "util", "detectPortForwardingAll"}, call("detectPortForwardingAll"), 514)
    entry({"api", "util", "command"}, call("command"), 515)
end
local wirelessUtil = require("luci.handle.util.wireless")
local LuciHttp = require "luci.http"
local networkHandle = require "luci.handle.handle.network"
local Interface = require "luci.handle.util.interface"
local ComFun = require "luci.handle.common.function"
local LuciUci = require "luci.model.uci"
local wirelessHandle = require "luci.handle.util.wireless"
function site_survey()
  result = {
    code = 0
  }
  wirelessHandle.siteSurvey()
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end

function get_site_survey()
  local rw = wirelessHandle.getSiteSurvey()
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(rw)
end

function setStaticDhcp()
  local name = LuciHttp.formvalue("name")
  local mac = LuciHttp.formvalue("mac")
  local ip = LuciHttp.formvalue("ip")
  networkHandle.setLanStaticDHCP(name,mac,ip)
  Interface.reload()
  LuciHttp.redirect(luci.dispatcher.build_url("web/network/lan/dhcp"))
end

function detectStaticDhcp()
  result = {
    code = 0
  }
  local sId = LuciHttp.formvalue("select")
  networkHandle.delectStaticDHCP(sId)
  Interface.reload()
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end


function delectAllStaticDhcp()
  result = {
    code = 0
  }
  networkHandle.delectAllStaticDHCP()
  Interface.reload()
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end


function setMacPolicy()
  result = {
    code = 0
  }
  local c = LuciUci.cursor()
  local sid = "default_mt7628"
  local mac = LuciHttp.formvalue("mac")
  local policy = LuciHttp.formvalue("AccessPolicy0")
  local Model = require "luci.handle.util.model"
  local iface = Model.getConfigByName("wireless", "default_mt7628")
  local prefix = ""
  if not iface.options.AccessControlList0 then
    prefix = ""
  else
    prefix = iface.options.AccessControlList0 .. ";"
  end
  iface.options.AccessControlList0 = prefix ..  mac
  c:set("wireless", sid, "AccessControlList0", iface.options.AccessControlList0)
  c:set("wireless", sid, "AccessPolicy0", policy)
  c:commit("wireless")
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end
function macPolicyDelect()
  result = {
    code = 0
  }
  local c = LuciUci.cursor()
  local sid = "default_mt7628"
  local i = LuciHttp.formvalue("select")
  local Model = require "luci.handle.util.model"
  local wifi = Model.getConfigByName("wireless", "default_mt7628")
  local macList = ComFun.Split(wifi.options.AccessControlList0, ";")
  table.remove(macList, i)
  local macString = table.concat(macList, ";")
  c:set("wireless", sid, "AccessControlList0", macString)
  c:commit("wireless")
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end

function macPolicyDelectAll()
  result = {
    code = 0
  }
  local c = LuciUci.cursor()
  local sid = "default_mt7628"
  c:set("wireless", sid, "AccessControlList0", "")
  c:commit("wireless")
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end

function startWps()
  result = {code = 0}
  local pinCode = LuciHttp.formvalue("pinCode")
  local wpsMethod = LuciHttp.formvalue("wpsMethod")
  if wpsMethod == "pin" then
    wirelessHandle.startWpsPin(pinCode)
  elseif wpsMethod == "pbc" then
    wirelessHandle.startWpsPbc()
  end
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end



function port_forwarding()
    result = {code = 0}
    local src_dport = LuciHttp.formvalue("src_dport")
    local proto = LuciHttp.formvalue("proto")
    local dest_ip = LuciHttp.formvalue("dest_ip")
    local dest_port = LuciHttp.formvalue('dest_port')
    local c = LuciUci.cursor()
  	local sId = c:add("firewall", "redirect")
  	c:set("firewall", sId, "src", "wan")
  	c:set("firewall", sId, "src_dport", src_dport)
  	c:set("firewall", sId, "proto", proto)
  	c:set("firewall", sId, "dest", "lan")
  	c:set("firewall", sId, "dest_ip", dest_ip)
  	c:set("firewall", sId, "dest_port", dest_port)
  	c:set("firewall", sId, "comment", "port_forwarding")
  	c:commit("firewall")
    local cmd = "/etc/init.d/firewall restart"
    ComFun.forkExec("cmd")
    LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end


function detectPortForwarding()
    result = {code = 0}
    local sId = LuciHttp.formvalue("select")
    local c = LuciUci.cursor()
    c:delete("firewall", sId)
    c:commit("firewall")
    local cmd = "/etc/init.d/firewall restart"
    ComFun.forkExec("cmd")
    LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end

function detectPortForwardingAll()
    result = {code = 0}
    local rw = MtkFirewallUtil.getPortForwardingInfo()
    local Model = require "luci.handle.util.model"
    local redirect = Model.getConfigByType("firewall", "redirect")
    local c = LuciUci.cursor()
    for i, v in ipairs(redirect) do
        if v.options.comment == "port_forwarding" then
          c:delete("firewall", v.name)
        end
    end
    c:commit("firewall")
    local cmd = "/etc/init.d/firewall restart"
    ComFun.forkExec("cmd")
    LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end

function dmz()
    result = {code = 0}
    local dest_ip = LuciHttp.formvalue("dest_ip")
    local c = LuciUci.cursor()
  	if dest_ip == "" then
  		c:set("firewall", "dmz", "dest_ip", "")
  		c:set("firewall", "dmz", "enabled", "0")
  	else
  		c:set('firewall', "dmz", "dest_ip", dest_ip)
  		c:set("firewall", "dmz", "enabled", "1")
  	end
  	c:commit("firewall")
    local cmd = "/etc/init.d/firewall restart"
    ComFun.forkExec("cmd")
    LuciHttp.prepare_content("application/json")
    LuciHttp.write_json(result)
end

function command()
  local command =  LuciHttp.formvalue("command")
  ComFun.forkExec(command)
  luci.dispatcher.build_url("web", "countDown")
end
