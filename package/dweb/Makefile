include $(TOPDIR)/rules.mk

LUCI_TITLE:=dweb
#LUCI_DEPENDS:=+luci-base
PKG_NAME:=dweb
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_CONFIG_DEPENDS:=
include $(INCLUDE_DIR)/package.mk
define Package/$(PKG_NAME)
  SECTION:=dweb
  CATEGORY:=Web Page
  SUBMENU:=Base
  TITLE:=web page by dongqifanivan@gmail.com
  DEPENDS:=+luci-base +uhttpd +uhttpd-mod-ubus
endef

HTDOCS = /www
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci


define Build/Prepare
	for d in luasrc htdocs root src; do \
	  if [ -d ./$$$$d ]; then \
	    mkdir -p $(PKG_BUILD_DIR)/$$$$d; \
		$(CP) ./$$$$d/* $(PKG_BUILD_DIR)/$$$$d/; \
	  fi; \
	done
	$(call Build/Prepare/Default)
endef

define Package/$(PKG_NAME)/description
  When you want the package work, you must do somethings
  1. install luci(./script/feeds/update; ./script/feeds/install -a)
  2. ./feeds/luci/collections/luci/Makefile
  (LUCI_DEPENDS:= +uhttpd +uhttpd-mod-ubus). Now you dont compire luci-mod-full and the other package you dont want
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	if [ -d $(PKG_BUILD_DIR)/luasrc ]; then \
	  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
	  cp -pR $(PKG_BUILD_DIR)/luasrc/* $(1)$(LUCI_LIBRARYDIR)/; \
	  $(FIND) $(1)$(LUCI_LIBRARYDIR)/ -type f -name '*.luadoc' | $(XARGS) rm; \
	else true; fi
	if [ -d $(PKG_BUILD_DIR)/htdocs ]; then \
	  $(INSTALL_DIR) $(1)$(HTDOCS); \
	  cp -pR $(PKG_BUILD_DIR)/htdocs/* $(1)$(HTDOCS)/; \
	else true; fi
	if [ -d $(PKG_BUILD_DIR)/root ]; then \
	  $(INSTALL_DIR) $(1)/; \
	  cp -pR $(PKG_BUILD_DIR)/root/* $(1)/; \
	else true; fi
	if [ -d $(PKG_BUILD_DIR)/src ]; then \
	  $(call Build/Install/Default) \
	  $(CP) $(PKG_INSTALL_DIR)/* $(1)/; \
	else true; fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
# call BuildPackage - OpenWrt buildroot signature