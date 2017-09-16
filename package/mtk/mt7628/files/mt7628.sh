#!/bin/sh
append DRIVERS "mt7628"

. /lib/wifi/ralink_common.sh

prepare_mt7628() {
	prepare_ralink_wifi mt7628
}

scan_mt7628() {
	scan_ralink_wifi mt7628 mt7628
}


disable_mt7628() {
	disable_ralink_wifi mt7628
}

enable_mt7628() {
	enable_ralink_wifi mt7628 mt7628
}

detect_mt7628() {
#	detect_ralink_wifi mt7628 mt7628
	ssid=mt7628-`ifconfig eth0 | grep HWaddr | cut -c 51- | sed 's/://g'`
	cd /sys/module/
	[ -d $module ] || return
	
	config_load wireless
	
	config_get type mt7628 type
	[ -z "$type" ] || break
	
	uci -q batch <<-EOF
		set wireless.mt7628=wifi-device
		set wireless.mt7628.type=mt7628
		set wireless.mt7628.vendor=ralink
		set wireless.mt7628.band=2.4G
		set wireless.mt7628.channel=0
		set wireless.mt7628.bw=1
		
		set wireless.default_mt7628=wifi-iface
		set wireless.default_mt7628.device=mt7628
		set wireless.default_mt7628.ifname=ra0
		set wireless.default_mt7628.mode=ap
		set wireless.default_mt7628.ssid=$ssid
		set wireless.default_mt7628.encryption=psk2
		set wireless.default_mt7628.key=12345678
EOF
	uci -q commit wireless
}


