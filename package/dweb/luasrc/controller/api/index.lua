module("luci.controller.api.index", package.seeall)
function index()
    local page   = node("api")
    page.target  = firstchild()
    page.title   = _("")
    page.order   = 10
    page.sysauth = "root"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
end
