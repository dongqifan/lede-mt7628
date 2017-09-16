module ("luci.handle.util.interface", package.seeall)

local ComFun = require("luci.handle.common.function")
local Config = require("luci.handle.common.config")
local LuciUci = require("luci.model.uci").cursor()



function getLanIp()
    local uci = require("luci.model.uci").cursor()
    local lanIp = uci:get("network", "lan", "ipaddr")
    return lanIp
end

function reload()
    os.execute("/etc/init.d/dnsmasq restart")
end

function ubusLanStatus()
  local ubus = require("ubus").connect()
  local lan = ubus:call("network.interface.lan", "status", {})
  local result = {}
  if lan["ipv4-address"] and #lan["ipv4-address"] > 0 then
      result["ipv4"] = lan["ipv4-address"][1]
  else
      result["ipv4"] = {
          ["mask"] = 0,
          ["address"] = ""
      }
  end
  result["dns"] = lan["dns-server"] or {}
  result["proto"] = string.lower(lan.proto or "dhcp")
  result["up"] = lan.up
  result["uptime"] = lan.uptime or 0
  result["pending"] = lan.pending
  result["autostart"] = lan.autostart
  return result
end

function ubusWanStatus()
    local ubus = require("ubus").connect()
    local wan = ubus:call("network.interface.wan", "status", {})
    local result = {}
    if wan["ipv4-address"] and #wan["ipv4-address"] > 0 then
        result["ipv4"] = wan["ipv4-address"][1]
    else
        result["ipv4"] = {
            ["mask"] = 0,
            ["address"] = ""
        }
    end
    result["dns"] = wan["dns-server"] or {}
    result["proto"] = string.lower(wan.proto or "dhcp")
    result["up"] = wan.up
    result["device"] = wan.device
    result["uptime"] = wan.uptime or 0
    result["pending"] = wan.pending
    result["autostart"] = wan.autostart
    return result
end



function getMac(interface)
    local LuciUtil = require("luci.util")
    local ifconfig = LuciUtil.exec("ifconfig " .. interface)
    if not ComFun.isStrNil(ifconfig) then
        return ifconfig:match('HWaddr (%S+)') or ""
    else
        return nil
    end
end



function getIPv6Addrs()
    local LuciIp = require("luci.ip")
    local LuciUtil = require("luci.util")
    local cmd = "ifconfig|grep inet6"
    local ipv6List = LuciUtil.execi(cmd)
    local result = {}
    for line in ipv6List do
        line = luci.util.trim(line)
        local ipv6,mask,ipType = line:match('inet6 addr: ([^%s]+)/([^%s]+)%s+Scope:([^%s]+)')
        if ipv6 then
            ipv6 = LuciIp.IPv6(ipv6,"ffff:ffff:ffff:ffff::")
            ipv6 = ipv6:host():string()
            result[ipv6] = {}
            result[ipv6]['ip'] = ipv6
            result[ipv6]['mask'] = mask
            result[ipv6]['type'] = ipType
        end
    end
    return result
end

function getLanDHCPService()
    local LuciUci = require "luci.model.uci"
    local lanDhcpStatus = {}
    local uciCursor  = LuciUci.cursor()
    local ignore = uciCursor:get("dhcp", "lan", "ignore")
    local leasetime = uciCursor:get("dhcp", "lan", "leasetime")
    if ignore ~= "1" then
        ignore = "0"
    end
    local leasetimeNum,leasetimeUnit = leasetime:match("^(%d+)([^%d]+)")
    lanDhcpStatus["lanIp"] = getLanWanIp("lan")
    lanDhcpStatus["start"] = uciCursor:get("dhcp", "lan", "start")
    lanDhcpStatus["limit"] = uciCursor:get("dhcp", "lan", "limit")
    lanDhcpStatus["leasetime"] = leasetime
    lanDhcpStatus["leasetimeNum"] = leasetimeNum
    lanDhcpStatus["leasetimeUnit"] = leasetimeUnit
    lanDhcpStatus["ignore"] = ignore
    return lanDhcpStatus
end


function wanDown()
    local LuciUtil = require("luci.util")
    LuciUtil.exec("env -i /sbin/ifdown wan")
end

function wanRestart()
    local LuciUtil = require("luci.util")
    LuciUtil.exec("env -i /sbin/ifup wan")
    --XQFunction.forkExec("/etc/init.d/filetunnel restart") Ivan
end

function dnsmsqRestart()
    local LuciUtil = require("luci.util")
    LuciUtil.exec("ubus call network reload; sleep 1; /etc/init.d/dnsmasq restart > /dev/null")
end

--[[
Get wan details, static ip/pppoe/dhcp/mobile
@return {proto="dhcp",ifname=ifname,dns=dns,peerdns=peerdns}
@return {proto="static",ifname=ifname,ipaddr=ipaddr,netmask=netmask,gateway=gateway,dns=dns}
@return {proto="pppoe",ifname=ifname,username=pppoename,password=pppoepasswd,dns=dns,peerdns=peerdns}
]]--
function getWanDetails()
    local LuciNetwork = require("luci.model.network").init()
    local wanNetwork = LuciNetwork:get_network("wan")
    local wanDetails = {}
    if wanNetwork then
        local wanType = wanNetwork:proto()
        if wanType == "mobile" or wanType == "3g" then
            wanType = "mobile"
        elseif wanType == "static" then
            wanDetails["ipaddr"] = wanNetwork:get_option_value("ipaddr")
            wanDetails["netmask"] = wanNetwork:get_option_value("netmask")
            wanDetails["gateway"] = wanNetwork:get_option_value("gateway")
        elseif wanType == "pppoe" then
            wanDetails["username"] = wanNetwork:get_option_value("username")
            wanDetails["password"] = wanNetwork:get_option_value("password")
            wanDetails["peerdns"] = wanNetwork:get_option_value("peerdns")
            wanDetails["service"] = wanNetwork:get_option_value("service")
        elseif wanType == "dhcp" then
            wanDetails["peerdns"] = wanNetwork:get_option_value("peerdns")
        end
        if not MtkFunction.isStrNil(wanNetwork:get_option_value("dns")) then
            wanDetails["dns"] = luci.util.split(wanNetwork:get_option_value("dns")," ")
        end
        wanDetails["wanType"] = wanType
        wanDetails["ifname"] = wanNetwork:get_option_value("ifname")
        return wanDetails
    else
        return nil
    end
end

function generateDns(dns1, dns2, peerdns)
    local dns
    if not MtkFunction.isStrNil(dns1) and not MtkFunction.isStrNil(dns2) then
        dns = {dns1,dns2}
    elseif not MtkFunction.isStrNil(dns1) then
        dns = dns1
    elseif not MtkFunction.isStrNil(dns2) then
        dns = dns2
    end
    return dns
end

function checkMTU(value)
    local mtu = tonumber(value)
    if mtu and mtu >= 576 and mtu <= 1492 then
        return true
    else
        return false
    end
end
function checkWanIp(ip)
    local LuciIp = require("luci.ip")
    local ipNl = LuciIp.iptonl(ip)
    if (ipNl >= LuciIp.iptonl("1.0.0.0") and ipNl <= LuciIp.iptonl("126.255.255.255"))
        or (ipNl >= LuciIp.iptonl("128.0.0.0") and ipNl <= LuciIp.iptonl("223.255.255.255")) then
        return 0
    else
        return 1533
    end
end

function setWanMac(mac)
    local LuciNetwork = require("luci.model.network").init()
    local LuciDatatypes = require("luci.cbi.datatypes")
    local network = LuciNetwork:get_network("wan")
    local oldMac = network:get_option_value("macaddr")
    local succeed = false
    if oldMac ~= mac then
        if MtkFunction.isStrNil(mac) then
            local defaultMac = getDefaultMacAddress() or ""
            network:set("macaddr",defaultMac)
            succeed = true
        elseif LuciDatatypes.macaddr(mac) and mac ~= "ff:ff:ff:ff:ff:ff" and mac ~= "00:00:00:00:00:00" then
            network:set("macaddr",mac)
            succeed = true
        end
    else
        succeed = true
    end
    if succeed then
        LuciNetwork:save("network")
        LuciNetwork:commit("network")
        wanRestart()
    end
    return succeed
end

function _checkIP(ip)
    if MtkFunction.isStrNil(ip) then
        return false
    end
    local LuciIp = require("luci.ip")
    local ipNl = LuciIp.iptonl(ip)
    if (ipNl >= LuciIp.iptonl("1.0.0.0") and ipNl <= LuciIp.iptonl("126.0.0.0"))
        or (ipNl >= LuciIp.iptonl("128.0.0.0") and ipNl <= LuciIp.iptonl("223.255.255.255")) then
        return true
    else
        return false
    end
end

function _checkMac(mac)
    if MtkFunction.isStrNil(mac) then
        return false
    end
    local LuciDatatypes = require("luci.cbi.datatypes")
    if LuciDatatypes.macaddr(mac) and mac ~= "ff:ff:ff:ff:ff:ff" and mac ~= "00:00:00:00:00:00" then
        return true
    else
        return false
    end
end

function _parseMac(mac)
    if mac then
        return string.lower(string.gsub(mac,"[:-]",""))
    else
        return nil
    end
end

function _parseDhcpLeases()
    local NixioFs = require("nixio.fs")
    local uci =  require("luci.model.uci").cursor()
    local result = {}
    local leasefile = MtkConfig.DHCP_LEASE_FILEPATH
    uci:foreach("dhcp", "dnsmasq",
    function(s)
        if s.leasefile and NixioFs.access(s.leasefile) then
            leasefile = s.leasefile
            return false
        end
    end)
    local dhcp = io.open(leasefile, "r")
    if dhcp then
        for line in dhcp:lines() do
            if line then
                local ts, mac, ip, name = line:match("^(%d+) (%S+) (%S+) (%S+)")
                if name == "*" then
                    name = ""
                end
                if ts and mac and ip and name then
                    result[ip] = {
                        mac  = string.lower(MtkFunction.macFormat(mac)),
                        ip   = ip,
                        name = name
                    }
                end
            end
        end
        dhcp:close()
    end
    return result
end
