include $(TOPDIR)/rules.mk

PKG_NAME:=mtk-basefiles
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Used to config the chip of mtk
  SUBMENU:=Applications
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/board.d
	$(INSTALL_BIN) ./files/etc/board.d/10_mtkwifi $(1)/etc/board.d/10_mtkwifi
	$(INSTALL_DIR) $(1)/lib/wifi
	$(INSTALL_BIN) ./files/lib/wifi/ralink_common.sh $(1)/lib/wifi/ralink_common.sh
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/smp.sh $(1)/usr/sbin/smp.sh 
endef


$(eval $(call BuildPackage,$(PKG_NAME)))

