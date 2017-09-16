module("luci.controller.api.system", package.seeall)
function index()
    local page   = node("api","system")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 300
    page.sysauth = "root"
    page.sysauth_template = "sysauth_dweb"
    page.sysauth_authenticator = "htmlauth"
    page.index = true
    entry({"api", "system"}, firstchild(), (""), 301)
    entry({"api", "system", "firmware"}, call("firmware"), (""), 301)
    entry({"api", "system", "upgrade"}, call("upgrade"), (""), 302)
    entry({"api", "system", "backup"}, post("action_backup"), 303)
    entry({"api", "system", "login"}, call("login"), (""), 304)
    entry({"api", "system", "restart"}, call("restart"), (""), 305)
    entry({"api", "system", "time"}, call("time"), (""), 306)
    entry({"api", "system", "ping"}, call("diag_ping"), (""), 307)
    entry({"api", "system", "traceroute"}, call("diag_traceroute"), (""), 308)
    entry({"api", "system", "nslookup"}, call("diag_nslookup"), (""),309)
    entry({"api", "system", "restore"}, call("action_restore"), 310)
end

local ComFun = require "luci.handle.common.function"
local LuciHttp = require "luci.http"
local LuciUci = require "luci.model.uci"
local systemHandle = require "luci.handle.handle.system"

function diag_command(cmd, addr)
  result = {
    code = 0,
    inputName = "",
    message = ""
  }
  local infomation = {}
  if addr and addr:match("^[a-zA-Z0-9%-%.:_]+$") then
    luci.http.prepare_content("text/plain")

    local util = io.popen(cmd % addr)
    if util then
      while true do
        local ln = util:read("*l")
        if not ln then break end
        infomation[#infomation+1] = ln
      end
      result.message = table.concat( infomation, "\n")
      util:close()
      LuciHttp.prepare_content("application/json")
      LuciHttp.write_json(result)
    end

    return
  end

  luci.http.status(500, "Bad address")
end

function diag_ping()
  local addr = LuciHttp.formvalue("host")
  diag_command("ping -c 5 -W 1 %q 2>&1", addr)
end

function diag_traceroute()
  local addr = LuciHttp.formvalue("host")
  diag_command("traceroute -q 1 -w 1 -n %q 2>&1", addr)
end

function diag_nslookup()
  local addr = LuciHttp.formvalue("host")
  diag_command("nslookup %q 2>&1", addr)
end

function diag_ping6()
  local addr = LuciHttp.formvalue("host")
  diag_command("ping6 -c 5 %q 2>&1", addr)
end

function diag_traceroute6()
  local addr = LuciHttp.formvalue("host")
  diag_command("traceroute6 -q 1 -w 2 -n %q 2>&1", addr)
end



function time()
  result = {code = 0}

  systemHandle.setTime()
  local cmd
  if enabled == "0" then
    cmd = "/etc/init.d/sysntpd start"
  elseif enabled == "1" then
    cmd = "/etc/init.d/sysntpd stop"
  end
  ComFun.forkExec(cmd)
  LuciHttp.prepare_content("application/json")
  LuciHttp.write_json(result)
end

function restart()
  local restart = LuciHttp.formvalue("restart")
  local reset = LuciHttp.formvalue("reset")
  if LuciHttp.formvalue("restart") then
    cmd = [[
      sleep 3
      reboot
    ]]
  elseif LuciHttp.formvalue("reset") then
    cmd = "sleep 1; killall dropbear uhttpd; sleep 1; jffs2reset -y && reboot"
  end
  luci.template.render("setting/reboot", {sec=60})
  ComFun.forkExec(cmd)
end

function login()
  local password = LuciHttp.formvalue("password")
  local confirm = LuciHttp.formvalue("confirm")
  systemHandle.setLogin(password)
  luci.dispatcher.build_url("web", "countDown")
end

function firmware()
  local sys = require "luci.sys"
  local fs    = require "nixio.fs"
  local image_tmp   = "/tmp/firmware.img"



  local function image_supported()
    -- XXX: yay...
    return ( 0 == os.execute(
      ". /lib/functions.sh; " ..
      "include /lib/upgrade; " ..
      "platform_check_image %q >/dev/null"
        % image_tmp
    ) )
  end

  local function image_checksum()
    return (luci.sys.exec("md5sum %q" % image_tmp):match("^([^%s]+)"))
  end

  local function storage_size()
    local size = 0
    if nixio.fs.access("/proc/mtd") then
      for l in io.lines("/proc/mtd") do
        local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
        if n == "linux" or n == "firmware" then
          size = tonumber(s, 16)
          break
        end
      end
    elseif nixio.fs.access("/proc/partitions") then
      for l in io.lines("/proc/partitions") do
        local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
        if b and n and not n:match('[0-9]') then
          size = tonumber(b) * 1024
          break
        end
      end
    end
    return size
  end
  local fp
  luci.http.setfilehandler(
    function(meta, chunk, eof)
      if not fp then
        if meta and meta.name == "image" then
          fp = io.open(image_tmp, "w")
        end
      end
      if chunk then
        fp:write(chunk)
      end
      if eof then
        fp:close()
      end
    end
  )
  if luci.http.formvalue("image") then
    if image_supported() then
      luci.template.render("setting/upgrade", {
           checksum = image_checksum(),
           storage  = storage_size(),
           size     = nixio.fs.stat(image_tmp).size
         })
    else
     luci.template.render("setting/error_firmware")
   end
  end
end

function upgrade()
  local image_tmp   = "/tmp/firmware.img"
  local keep = (luci.http.formvalue("keep") == "1") and "" or "-n"
  local cmd_format=[[
    sleep 3
    /sbin/sysupgrade %s %q
  ]]
  local cmd = string.format(cmd_format, keep, image_tmp)
  ComFun.forkExec(cmd)
  luci.template.render("setting/reboot", {sec=130})
end

function ltn12_popen(command)

  local fdi, fdo = nixio.pipe()
  local pid = nixio.fork()

  if pid > 0 then
    fdo:close()
    local close
    return function()
      local buffer = fdi:read(2048)
      local wpid, stat = nixio.waitpid(pid, "nohang")
      if not close and wpid and stat == "exited" then
        close = true
      end

      if buffer and #buffer > 0 then
        return buffer
      elseif close then
        fdi:close()
        return nil
      end
    end
  elseif pid == 0 then
    nixio.dup(fdo, nixio.stdout)
    fdi:close()
    fdo:close()
    nixio.exec("/bin/sh", "-c", command)
  end
end

function action_backup()
	local reader = ltn12_popen("sysupgrade --create-backup - 2>/dev/null")

	luci.http.header(
		'Content-Disposition', 'attachment; filename="backup-%s-%s.tar.gz"' %{
			luci.sys.hostname(),
			os.date("%Y-%m-%d")
		})

	luci.http.prepare_content("application/x-targz")
	luci.ltn12.pump.all(reader, luci.http.write)
end

function action_restore()
	local fs = require "nixio.fs"
	local http = require "luci.http"
	local archive_tmp = "/tmp/restore.tar.gz"

	local fp
	http.setfilehandler(
		function(meta, chunk, eof)
			if not fp and meta and meta.name == "archive" then
				fp = io.open(archive_tmp, "w")
			end
			if fp and chunk then
				fp:write(chunk)
			end
			if fp and eof then
				fp:close()
			end
		end
	)
		os.execute("tar -C / -xzf %q >/dev/null 2>&1" % archive_tmp)
    cmd = [[
      sleep 3
      reboot
    ]]
    ComFun.forkExec(cmd)
    luci.template.render("setting/reboot", {sec=60})
end
function action_restore()
	local fs = require "nixio.fs"
	local http = require "luci.http"
	local archive_tmp = "/tmp/restore.tar.gz"

	local fp
	http.setfilehandler(
		function(meta, chunk, eof)
			if not fp and meta and meta.name == "archive" then
				fp = io.open(archive_tmp, "w")
			end
			if fp and chunk then
				fp:write(chunk)
			end
			if fp and eof then
				fp:close()
			end
		end
	)

	if not luci.dispatcher.test_post_security() then
		fs.unlink(archive_tmp)
		return
	end

	local upload = http.formvalue("archive")
	if upload and #upload > 0 then
		os.execute("tar -C / -xzf %q >/dev/null 2>&1" % archive_tmp)
    cmd = [[
      sleep 3
      reboot
    ]]
    ComFun.forkExec(cmd)
    luci.template.render("setting/reboot", {sec=60})
	end
end
