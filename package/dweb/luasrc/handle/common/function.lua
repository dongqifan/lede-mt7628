module ("luci.handle.common.function", package.seeall)

local LuciUci = require("luci.model.uci").cursor()


function getSectionName(config, sectiontype)
  rw={}
  LuciUci:foreach(config, sectiontype,
    function(x)
      rw[#rw+1] = x['.name']
    end
  )
  return rw
end




function Split(szFullString, szSeparator)
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while true do
    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
    if not nFindLastIndex then
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
      break
    end
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
    nFindStartIndex = nFindLastIndex + string.len(szSeparator)
    nSplitIndex = nSplitIndex + 1
  end
  return nSplitArray
end


--[[
@param mac: mac address
@return XX:XX:XX:XX:XX:XX
]]--
function macFormat(mac)
    if mac then
        return string.upper(string.gsub(mac,"-",":"))
    else
        return ""
    end
end

function isStrNil(str)
    return (str == nil or str == "")
end

function checkChineseChar(str)
    local res = false
    if str and type(str) == "string" then
        for i=1, #str do
            if string.byte(str, i) > 127 then
                res = true
                break
            end
        end
    end
    return res
end

function isDomain(url)
    if not url then
        return false
    end
    if url:match("^%w[%w%-%.]+%w$") then
        return true
    end
    return false
end

function forkExec(command)
    local Nixio = require("nixio")
    local pid = Nixio.fork()
    if pid > 0 then
        return
    elseif pid == 0 then
        Nixio.chdir("/")
        local null = Nixio.open("/dev/null", "w+")
        if null then
            Nixio.dup(null, Nixio.stderr)
            Nixio.dup(null, Nixio.stdout)
            Nixio.dup(null, Nixio.stdin)
            if null:fileno() > 2 then
                null:close()
            end
        end
        Nixio.exec("/bin/sh", "-c", command)
    end
end

function doPrint(content)
    if type(content) == "table" then
        for k,v in pairs(content) do
            if type(v) == "table" then
                print("<"..k..": ")
                doPrint(v)
                print(">")
            else
                print("["..k.." : "..tostring(v).."]")
            end
        end
    else
        print(content)
    end
end
