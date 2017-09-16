替换package/ralink/applications/uci2data

增加uci中字段到ralink配置字段的解析（AP-CLIENT模式配置）

在/etc/config/wireless里对应的字段为
ApCliEnable   1
ApCliSsid     'hiwifi'
ApCliAuthMode  'WPA2PSK'
ApCliEncrypType  'AES'
ApCliWPAPSK    /*密码*/


  			option ApCliEnable '1'
        option ApCliSsid 'HiWiFi_0DE45A'
        option ApCliAuthMode 'WPA2PSK'
        option ApCliEncrypType 'AES'
        option ApCliWPAPSK 's00all1234'
