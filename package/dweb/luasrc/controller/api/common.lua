module("luci.controller.api.common", package.seeall)
function index()
    local page   = node("api","common")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "root"
    page.sysauth_template = "sysauth_dweb"
    page.sysauth_authenticator = "htmlauth"
    page.index = true
    entry({"api", "common"}, firstchild(), (""), 101)
    entry({"api", "common", "common"}, call("common"), 102)
end

local ComFun =  require "luci.handle.common.function"
local LuciHttp = require "luci.http"
local LuciUci = require("luci.model.uci").cursor()
local Log = require("luci.handle.util.log")
local networkHandle = require("luci.handle.handle.network")
local wirelessHandle = require("luci.handle.handle.wireless")
--[[
  api{
    apiType: model, commit, command, function, advanced, page
    model: model.config.name.option
    command:command
  }
]]
function apiParse()
  local form = LuciHttp.formvalue()
  Log.print_r(form)
  local model = {}
  local api = {}
  for k, v in pairs(form) do
    api = ComFun.Split(k, ",")
    if api[1] == "model" then
      model[#model+1] = {
        config = api[2],
        name = api[3],
        option = api[4],
        value = v
      }
    end
  end
  --Log.print_r(model)
  return model
end

function common()
  local model = apiParse()
  for i, v in ipairs(model) do
    Log.print_r(v)
    LuciUci:set(v.config, v.name, v.option, v.value)
  end
  -- custome
  custom()
  local commit = LuciHttp.formvalue("commit")
  if commit ~= nil then
    local config = ComFun.Split(commit, ",")
    Log.print_r(config)
    for i, v in ipairs(config) do
      LuciUci:commit(v)
    end
  end

  local command = LuciHttp.formvalue("command")
  if command ~= nil then
    ComFun.forkExec(command)
  end
  LuciHttp.redirect(luci.dispatcher.build_url("web", "countDown"))
end

function custom()
  local page = LuciHttp.formvalue("page")
  if page == "bridge" or page == "router" or page == "repeater" or page == "wisp" or page == "client" or page == "client_wisp" then
    networkHandle.setOpMode()
  end
  if page == "bridge" or page == "router" or page == "repeater" or page == "wisp" or page == "wireless_security" then
    wirelessHandle.setApSecurity()
  end
  if page == "router" or page == "wisp" or page == "client_wisp" then
    networkHandle.setStaticDNS()
  end

  if page == "dhcp" then
    networkHandle.setLanDHCP()
  end
end
