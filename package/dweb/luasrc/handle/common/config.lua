module ("luci.handle.common.config", package.seeall)

AP_CLIENT_INTERFACE = "apcli0" --MT7628 wifi driver用于连接上级wifi的interface


-- mt7628搜索无线信号， 获取搜索到的无线信号方式
--[[
  iwpriv apcli0 set SiteSurvey=0
  sleep 3 -- 3～5秒
  iwpriv apcli0 get_site_survey
]]
SITE_SURVEY_FORMAT = "iwpriv %s set SiteSurvey=0 >/dev/null 2>/dev/null"
GET_SITE_SURVEY_FORMAT = "iwpriv %s get_site_survey"
SITE_SURVEY = string.format(SITE_SURVEY_FORMAT, AP_CLIENT_INTERFACE)
GET_SITE_SURVEY = string.format(GET_SITE_SURVEY_FORMAT, AP_CLIENT_INTERFACE)

DHCP_LEASE_FILEPATH = "/var/dhcp.leases"

GET_DEFAULT_MACADDRESS = "getmac"

GET_WIFI_ASSOCLIST = "iwinfo ra0 assoclist"
GET_WIFI_INFO = "iwinfo ra0 info"

INTERFACE_STATISTICS_FILE = "cat /proc/net/dev"
