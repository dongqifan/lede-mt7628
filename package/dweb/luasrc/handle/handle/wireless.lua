module ("luci.handle.handle.wireless", package.seeall)

local LuciHttp = require "luci.http"
local LuciUci = require("luci.model.uci").cursor()
local ComFun = require("luci.handle.common.function")
local LuciSys = require "luci.sys"
local Log = require("luci.handle.util.log")
function setApSecurity()
  Log.print("setApSecurity")
  local c = LuciUci.cursor()
  local sid = "default_mt7628"
  local encryption = LuciHttp.formvalue("encryption")
  local key_slot = LuciHttp.formvalue("key_slot")
  local key1 = LuciHttp.formvalue("key1")
  local key2 = LuciHttp.formvalue("key2")
  local key3 = LuciHttp.formvalue("key3")
  local key4 = LuciHttp.formvalue("key4")
  local cipher = LuciHttp.formvalue("cipher")
  local key = LuciHttp.formvalue("key")
  if encryption == "wep-open" or encryption == "wep-shared" then
    -- start to config wireless by use command
    -- command end
    c:set("wireless", sid, "encryption", encryption)
    c:set("wireless", sid, "key", key_slot)
    if #key1 == 5 or #key1 == 13 then
      key1 = "s:" .. key1
    end
    c:set("wireless", sid, "key1", key1)
    if #key2 == 5 or #key2 == 13 then
      key2 = "s:" .. key2
    end
    c:set("wireless", sid, "key2", key2)
    if #key3 == 5 or #key3 == 13 then
      key3 = "s:" .. key3
    end
    c:set("wireless", sid, "key3", key3)
    if #key4 == 5 or #key4 == 13 then
      key4 = "s:" .. key4
    end
    c:set("wireless", sid, "key4", key4)
  elseif encryption == "psk" or encryption == "psk2" or encryption == "psk-mixed" then
    c:set("wireless", sid, "encryption", encryption .. "+" .. cipher)
    c:set("wireless", sid, "key", key)
  elseif encryption == "none" then
    c:set("wireless", sid, "encryption", encryption)
  end
  c:commit("wireless")
end
