module ("luci.handle.util.wireless", package.seeall)

local ComFun = require("luci.handle.common.function")
local Config = require("luci.handle.common.config")
local LuciUci = require("luci.model.uci").cursor()
local LuciSys = require "luci.sys"

--[[
  AP CLIENT information 获取函数
  使用方式: 首先请求siteSurvey
      等待大概3~5秒之后再getSiteSUrvey
      即可获取scan到的wifi 信息
]]
function siteSurvey()
  ComFun.forkExec(Config.SITE_SURVEY)
end

function getSiteSurvey()
  local s = LuciSys.exec(Config.GET_SITE_SURVEY)
  local lines =  ComFun.Split(s,"\n")
  local rw={}
  local ch_index, _ = string.find(lines[2], "CH")
  ch_index = 0
  local ssid_index, _ = string.find(lines[2], "SSID")
  local bssid_index, _ = string.find(lines[2], "BSSID")
  local security_index, _ = string.find(lines[2], "Security")
  local signal_index, _ = string.find(lines[2], "Siganl")
  local mode_index, _ = string.find(lines[2], "W-Mode")
  mode_index = mode_index - 2
  local extch_index, _ = string.find(lines[2], "ExtCH")
  local nt_index, _ = string.find(lines[2], "NT")
  local wps_index, _ = string.find(lines[2], "WPS")
  local dpid_index, _ = string.find(lines[2], "DPID")
  table.remove(lines, 1)
  table.remove(lines, 1)
  table.remove(lines)
  table.remove(lines)
  for i, line in ipairs(lines) do
    rw[#rw+1] = {
      ch = string.sub(line, ch_index, ssid_index-1),
      ssid = string.sub(line, ssid_index, bssid_index-1),
      bssid = string.sub(line, bssid_index, security_index-1),
      security = string.sub(line, security_index, signal_index-1),
      signal = string.sub(line, signal_index, mode_index-1),
      mode = string.sub(line, mode_index, extch_index-1),
      extch = string.sub(line, extch_index, nt_index-1),
      nt = string.sub(line, nt_index, wps_index-1),
      wps = string.sub(line, wps_index, dpid_index-1)
    }
  end
  return rw
end

function getWifiInfo()
  local s = luci.util.execl(Config.GET_WIFI_INFO)
  local rw = {}
  rw.ssid = string.match(s[1], "ESSID: \"(%S+)\"")
  rw.bssid = string.match(s[2], "Access Point: (%S+)")
  rw.channel = string.match(s[3], "Channel: (%S+)")
  rw.bitrate = string.match(s[6], "Bit Rate: (%S+)")
  return rw
end

function getWifiPolicyInfo()
  local c = LuciUci.cursor()
  local rw = {}
  rw.macList = {}
  rw.policy = c:get("wireless", "default_mt7628", "AccessPolicy0")
  local AccessControlList0 = c:get("wireless", sectionName, "AccessControlList0")
  if AccessControlList0 then
    rw.macList = ComFun.Split(AccessControlList0, ";")
  end
  return rw
end


function startWpsPbc()
  local cmd = [[
    iwpriv ra0 set WscStop=1
    iwpriv ra0 set WscConfMode=7
    iwpriv ra0 set WscMode=2
    iwpriv ra0 set WscGetConf=1
  ]]
  ComFun.forkExec(cmd)
end

function startWpsPin(pinCode)
  local cmd_format = [[
    iwpriv ra0 set WscStop=1
    iwpriv ra0 set WscConfMode=7
    iwpriv ra0 set PinCode=%s
    iwpriv ra0 set WscMode=1
    iwpriv ra0 set WscGetConf=1
  ]]
  local cmd = string.format(cmd_formatm, pinCode)
  ComFun.forkExec(cmd)
end
