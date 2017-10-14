module("luci.controller.web.index", package.seeall)

function index()
    local root = node()
    if not root.target then
        root.target = alias("web")
        root.index = true
    end
    local page   = node("web")
    page.target  = firstchild()
    page.title   = _("")
    page.order   = 10
    page.sysauth = "root"
    page.sysauth_template = "sysauth_dweb"
    page.sysauth_authenticator = "htmlauth"
  	page.ucidata = true
    page.index = true

    local LuciUtil = require "luci.util"


    entry({"web"}, alias("web", "quick_start"), _("Home"), 10)
    entry({"web", "logout"}, call("action_logout"), 11)


    entry({"web", "quick_start"}, alias("web", "quick_start", "index"), _("Quick Start Index"), 12)
    entry({"web", "quick_start", "index"}, template("include/operation_to"), _("Quick Start Index"), 13)
    entry({"web", "quick_start", "gateway"}, template("setting/router"), _("Router"), 14).leaf = true
    entry({"web", "quick_start", "bridge"}, template("setting/bridge"), _("Bridge"), 15).leaf = true
    entry({"web", "quick_start", "repeater"}, template("setting/repeater"), _("Repeater"), 16).leaf = true
    entry({"web", "quick_start", "wisp"}, template("setting/wisp"), _("WISP"), 17).leaf = true
    entry({"web", "quick_start", "client"}, template("setting/client"), _("Client"), 18).leaf = true
    entry({"web", "quick_start", "client_wisp"}, template("setting/client_wisp"), _("Client_WISP"), 19).leaf = true

    entry({"web", "status"}, alias("web", "status", "status_info"), (""), 29)
    entry({"web", "status", "status_info"}, alias("web", "status", "status_info", "device_info"), (""), 30)
    entry({"web", 'status', "status_info", "device_info"}, template("setting/device_info"), _("Device Info"), 31)
    entry({"web", 'status', "status_info", "wireless_info"}, template("setting/wireless_info"), _("Wireless Info"), 32)

    entry({"web", "status", "statistics"}, alias("web", "status", "statistics", "statistic"), (""), 33)
    entry({"web", 'status', "statistics", "statistic"}, template("setting/statistic"), _("statistic"), 34)

    entry({"web", "network"}, alias("web", "network", "wan"), _(""), 40)
    entry({"web", "network", "wan"}, alias("web", "network", "wan", "wan"), _(""), 41)
    entry({"web", "network", "wan", "wan"}, template("setting/wan"), _("Wan"), 42)
    entry({"web", "network", "wan", "3g"}, template("setting/3g"), _("3G"), 42)

    entry({"web", "network", "lan"}, alias("web", "network", "lan", "lan"), _(""), 43)
    entry({"web", "network", "lan", "lan"}, template("setting/lan"), _("Lan"), 44)
    entry({"web", "network", "lan", "dhcp"}, template("setting/dhcp"), _("DHCP"), 45)

    entry({"web", "network", "wireless"}, alias("web", "network", "wireless", "wireless_setting"), _(""), 46)
    entry({"web", "network", "wireless", "wireless_setting"}, template("setting/wireless_setting"), _("Wireless Settiing"), 47)
    entry({"web", "network", "wireless", "wireless_security"}, template("setting/wireless_security"), _("Wireless Security"), 48)
    entry({"web", "network", "wireless", "wireless_advanced"}, template("setting/wireless_advanced"), _("Wireless Advanced"), 49)
    entry({"web", "network", "wireless", "access_policy"}, template("setting/access_policy"), _("MAC Filtering"), 50)
    entry({"web", "network", "wireless", "wps"}, template("setting/wps"), _("WPS"), 51)
    entry({"web", "network", "advanced"}, alias("web", "network", "advanced", "ipv6"), _(""), 52)
    entry({"web", "network", "advanced", "ipv6"}, template("setting/ipv6"), _("IPV6"), 53)

    entry({"web", "advanced"}, alias("web", "advanced", "firewall"), _(""), 59)
    entry({"web", "advanced", "security"}, alias("web", "advanced", "security", "ip_filtering"), _(""), 60)
    entry({"web", "advanced", "security", "ip_filtering"}, template("setting/ip_filtering"), _("Ip Filtering"), 61)
    entry({"web", "advanced", "security", "port_filtering"}, template("setting/port_filtering"), _("Port Filtering"), 62)
    entry({"web", "advanced", "security", "mac_filtering"}, template("setting/mac_filtering"), _("Mac Filtering"), 63)
    entry({"web", "advanced", "security", "url_filtering"}, template("setting/url_filtering"), _("URL Filtering"), 64)

    entry({"web", "advanced", "firewall"}, alias("web", "advanced", "firewall", "port_forwarding"), _(""), 65)
    entry({"web", "advanced", "firewall", "port_forwarding"}, template("setting/port_forwarding"), _("Port Forwarding"), 66)
    entry({"web", "advanced", "firewall", "dmz"}, template("setting/dmz"), _("DMZ"), 67)
    entry({"web", "advanced", "firewall", "upnp"}, template("setting/upnp"), _("UPNP"), 67)

    entry({"web", "maintenace"}, alias("web", "maintenace", "update"), _(""), 68)
    entry({"web", "maintenace", "update"}, alias("web", "maintenace", "update", "firmware"), _(""), 70)
    entry({"web", "maintenace", "update", "firmware"}, template("setting/firmware"), _("Firmware"), 71)
    entry({"web", "maintenace", "update", "backup"}, template("setting/backup"), _("Backup/Restore"), 72)

    entry({"web", "maintenace", "admin"}, alias("web", "maintenace", "admin", "login"), _(""), 73)
    entry({"web", "maintenace", "admin", "login"}, template("setting/login"), _("Login"), 74)
    entry({"web", "maintenace", "admin", "restart"}, template("setting/restart"), _("Restart"), 75)
    entry({"web", "maintenace", "admin", "time"}, template("setting/time"), _("Time"), 76)
    entry({"web", "maintenace", "admin", "system_log"}, template("setting/system_log"), _("System Log"), 77)
    entry({"web", "maintenace", "admin", "diagnostic_tools"}, template("setting/diagnostic_tools"), _("Diagnostic Tools"), 78)
    entry({"web", "countDown"}, template("setting/count_down"), _("countDown"), 79)
end
