PRODUCT_BRAND ?= candy5

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/candy5/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/candy5/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/candy5/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

ifdef candy5_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=candy5nightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=candy5
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false \
    dalvik.vm.image-dex2oat-filter=everything \
    dalvik.vm.dex2oat-filter=everything

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/candy5/CHANGELOG.mkdn:system/etc/CHANGELOG-CM.txt

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/candy5/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/candy5/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/candy5/prebuilt/common/bin/50-candy5.sh:system/addon.d/50-candy5.sh \
    vendor/candy5/prebuilt/common/bin/blacklist:system/addon.d/blacklist \
    vendor/candy5/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/candy5/prebuilt/common/etc/backup.conf:system/etc/backup.conf


# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/candy5/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/candy5/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/candy5/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/candy5/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/candy5/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/candy5/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/candy5/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/candy5/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# T-Mobile theme engine
include vendor/candy5/config/themes_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt \
    Profiles

# Optional CM packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji

# Custom CM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    AudioFX \
    Eleven \
    CandyOTA \
    LockClock   

# CM Platform Library
PRODUCT_PACKAGES += \
    org.cyanogenmod.platform-res \
    org.cyanogenmod.platform \
    org.cyanogenmod.platform.xml

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
    
# OmniSwitch 
PRODUCT_PACKAGES += \
    OmniSwitch

# HFM Files
PRODUCT_COPY_FILES += \
	vendor/candy5/prebuilt/etc/hosts.alt:system/etc/hosts.alt \
	vendor/candy5/prebuilt/etc/hosts.og:system/etc/hosts.og


PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# Chromium prebuilt
ifeq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)
-include prebuilts/chromium/$(TARGET_DEVICE)/chromium_prebuilt.mk
endif

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

PRODUCT_PACKAGE_OVERLAYS += vendor/candy5/overlay/common

PRODUCT_VERSION_MAJOR = release
PRODUCT_VERSION_MINOR = v2.5.4
PRODUCT_VERSION_MAINTENANCE = v2.5.4

# Set CM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef candy5_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "CM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^candy5_||g')
        candy5_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL OFFICIAL,$(candy5_BUILDTYPE)),)
    candy5_BUILDTYPE := OFFICIAL
endif

ifdef candy5_BUILDTYPE
    ifneq ($(candy5_BUILDTYPE), SNAPSHOT)
        ifdef candy5_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            candy5_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from CM_EXTRAVERSION
            candy5_EXTRAVERSION := $(shell echo $(candy5_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CM_EXTRAVERSION
            candy5_EXTRAVERSION := -$(candy5_EXTRAVERSION)
        endif
    else
        ifndef candy5_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            candy5_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from CM_EXTRAVERSION
            candy5_EXTRAVERSION := $(shell echo $(candy5_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CM_EXTRAVERSION
            candy5_EXTRAVERSION := -$(candy5_EXTRAVERSION)
        endif
    endif
else
    # If CM_BUILDTYPE is not defined, set to UNOFFICIAL
    candy5_BUILDTYPE := UNOFFICIAL
    candy5_EXTRAVERSION :=
endif

ifeq ($(candy5_BUILDTYPE), OFFICIAL)
    ifneq ($(TARGET_OFFICIAL_BUILD_ID),)
        candy5_EXTRAVERSION := OFFICIAL
    endif
endif

ifeq ($(candy5_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        candy5_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(candy5_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        candy5_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(candy5_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            candy5_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(candy5_BUILD)
        else
            candy5_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(candy5_BUILD)
        endif
    endif
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        candy5_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(candy5_BUILDTYPE)$(candy5_EXTRAVERSION)-$(candy5_BUILD)
    else
        candy5_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(candy5_BUILDTYPE)$(candy5_EXTRAVERSION)-$(candy5_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.candy5.version=$(candy5_VERSION) \
  ro.candy5.releasetype=$(candy5_BUILDTYPE) \
  ro.modversion=$(candy5_VERSION) \
  ro.cmlegal.url=https://cyngn.com/legal/privacy-policy

-include vendor/candy5-priv/keys/keys.mk

candy5_DISPLAY_VERSION := $(candy5_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(candy5_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(candy5_EXTRAVERSION),)
        # Remove leading dash from CM_EXTRAVERSION
        candy5_EXTRAVERSION := $(shell echo $(candy5_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(candy5_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    candy5_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

ifndef CM_PLATFORM_SDK_VERSION
  # This is the canonical definition of the SDK version, which defines
  # the set of APIs and functionality available in the platform.  It
  # is a single integer that increases monotonically as updates to
  # the SDK are released.  It should only be incremented when the APIs for
  # the new release are frozen (so that developers don't write apps against
  # intermediate builds).
  CM_PLATFORM_SDK_VERSION := 1
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.candy5.display.version=$(candy5_DISPLAY_VERSION)


# CyanogenMod Platform SDK Version
PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.build.version.plat.sdk=$(CM_PLATFORM_SDK_VERSION)

# OTA Updater
CANDY_BASE_URL    := https://basketbuild.com/dl/devs?dl=CandyRoms
CANDY_DEVICE_URL  := $(CANDY_BASE_URL)/$(candy5_BUILD)
CANDY_OTA_VERSION := $(shell date +%Y%m%d)
CANDY_ROM_NAME    := CandyRoms

# Lib For Webview
PRODUCT_COPY_FILES += \
vendor/candy5/prebuilt/lib/armeabi-v7a/libbypass.so:system/lib/libbypass.so


PRODUCT_PROPERTY_OVERRIDES += \
    ro.ota.candyroms=$(CANDY_ROM_NAME) \
    ro.candyroms.version=$(CANDY_OTA_VERSION) \
    ro.ota.manifest=$(CANDY_DEVICE_URL)/ota.xml \
 
export CANDY_OTA_ROM=$(CANDY_ROM_NAME)
export CANDY_OTA_VERNAME=$(candy5_DISPLAY_VERSION)
export CANDY_OTA_VER=$(CANDY_OTA_VERSION)
export CANDY_OTA_URL=$(CANDY_DEVICE_URL)/candy5-$(candy5_DISPLAY_VERSION).zip

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
