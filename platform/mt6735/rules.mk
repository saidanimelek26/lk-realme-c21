LOCAL_DIR := $(GET_LOCAL_DIR)

ARCH    := arm
ARM_CPU := cortex-a53
CPU     := generic

MMC_SLOT         := 1

PLATFORM_SECURITY_VERSION:=11
DEFINES += PLATFORM_SECURITY_VERSION=$(PLATFORM_SECURITY_VERSION)
MTK_AVB20_SUPPORT:=yes
AVB_SHA256_CRYPTO_HW_SUPPORT:=no
SYSTEM_AS_ROOT = no

# mtk gpt version
GPT_VER := 1
DEFINES += GPT_VER=$(GPT_VER)

# choose one of following value ->  2: permissive /3: enforcing
SELINUX_STATUS := 3

# overwrite SELINUX_STATUS value with PRJ_SELINUX_STATUS, if defined. it's by project variable.
ifdef PRJ_SELINUX_STATUS
	SELINUX_STATUS := $(PRJ_SELINUX_STATUS)
endif

DEFINES += MTK_DTBO_FEATURE

ifeq (yes,$(strip $(MTK_BUILD_ROOT)))
SELINUX_STATUS := 2
DEFINES += MTK_BUILD_ROOT
endif
CFG_MTK_WDT_COMMON := no
DEFINES += PLATFORM=\"$(PLATFORM)\"

DEFINES += SELINUX_STATUS=$(SELINUX_STATUS)

DEFINES += PERIPH_BLK_BLSP=1
DEFINES += WITH_CPU_EARLY_INIT=0 WITH_CPU_WARM_BOOT=0 \
	   MMC_SLOT=$(MMC_SLOT)

CFG_DTB_EARLY_LOADER_SUPPORT := yes
ifeq ($(CFG_DTB_EARLY_LOADER_SUPPORT), yes)
	DEFINES += CFG_DTB_EARLY_LOADER_SUPPORT=1
endif

MTK_SECURITY_SW_SUPPORT ?= yes
ifeq ($(MTK_SECURITY_SW_SUPPORT), yes)
	DEFINES += MTK_SECURITY_SW_SUPPORT
endif

ifneq ($(wildcard ../../../../../../vendor/mediatek/internal/testmode_enable),)
ifeq ($(MTK_EFUSE_DOWNGRADE), yes)
	DEFINES += MTK_EFUSE_DOWNGRADE
endif
endif

ifeq ($(MTK_SEC_FASTBOOT_UNLOCK_SUPPORT), yes)
	DEFINES += MTK_SEC_FASTBOOT_UNLOCK_SUPPORT
ifeq ($(MTK_SEC_FASTBOOT_UNLOCK_KEY_SUPPORT), yes)
	DEFINES += MTK_SEC_FASTBOOT_UNLOCK_KEY_SUPPORT
endif
endif

ifeq ($(CFG_MEMORY_RESERVED_SMALL_GRANULARITY),yes)
	DEFINES += CFG_MEMORY_RESERVED_SMALL_GRANULARITY=1
endif

ifeq ($(MTK_KERNEL_POWER_OFF_CHARGING),yes)
#Fastboot support off-mode-charge 0/1
#1: charging mode, 0:skip charging mode
DEFINES += MTK_OFF_MODE_CHARGE_SUPPORT
endif

KEDUMP_MINI := yes

ARCH_HAVE_MT_RAMDUMP := no

DEFINES += $(shell echo $(BOOT_LOGO) | tr a-z A-Z)

MTK_EMMC_POWER_ON_WP := no
ifeq ($(MTK_EMMC_SUPPORT),yes)
ifeq ($(MTK_EMMC_POWER_ON_WP),yes)
	DEFINES += MTK_EMMC_POWER_ON_WP
endif
endif

ifdef MTK_CARRIEREXPRESS_PACK
ifneq ($(strip $(MTK_CARRIEREXPRESS_PACK)), no)
    DEFINES += MTK_CARRIEREXPRESS_PACK
ifeq ($(filter OP01, $(subst _, $(space), $(MTK_REGIONAL_OP_PACK))), OP01)
    DEFINES += MTK_CARRIEREXPRESS_PACK_OP01
endif

ifeq ($(filter OP02, $(subst _, $(space), $(MTK_REGIONAL_OP_PACK))), OP02)
    DEFINES += MTK_CARRIEREXPRESS_PACK_OP02
endif

ifeq ($(filter OP09, $(subst _, $(space), $(MTK_REGIONAL_OP_PACK))), OP09)
    DEFINES += MTK_CARRIEREXPRESS_PACK_OP09
endif

ifneq ($(filter NONE, $(subst _, $(space), $(OPTR_SPEC_SEG_DEF))), NONE)
ifeq ($(filter OP01, $(subst _, $(space), $(OPTR_SPEC_SEG_DEF))), OP01)
    GLOBAL_DEVICE_DEFAULT_OPTR := 1
    DEFINES += GLOBAL_DEVICE_DEFAULT_OPTR=$(GLOBAL_DEVICE_DEFAULT_OPTR)
endif

ifeq ($(filter OP02, $(subst _, $(space), $(OPTR_SPEC_SEG_DEF))), OP02)
    GLOBAL_DEVICE_DEFAULT_OPTR := 2
    DEFINES += GLOBAL_DEVICE_DEFAULT_OPTR=$(GLOBAL_DEVICE_DEFAULT_OPTR)
endif

ifeq ($(filter OP09, $(subst _, $(space), $(OPTR_SPEC_SEG_DEF))), OP09)
    GLOBAL_DEVICE_DEFAULT_OPTR := 9
    DEFINES += GLOBAL_DEVICE_DEFAULT_OPTR=$(GLOBAL_DEVICE_DEFAULT_OPTR)
endif
endif

endif
endif

MTK_PARTITION_COMMON := yes
ifeq ($(MTK_PARTITION_COMMON), yes)
DEFINES += MTK_PARTITION_COMMON
endif

MTK_MUSB := yes
ifeq ($(MTK_MUSB), yes)
INCLUDES += -I$(LK_TOP_DIR)/platform/common/mt_musb
MODULE_SRCS += \
	$(LOCAL_DIR)/mt_musb/mt_musbphy.c
endif

ifeq ($(CFG_MTK_WDT_COMMON), yes)
INCLUDES += -I$(LK_TOP_DIR)/platform/common/wdt
DEFINES += CFG_MTK_WDT_COMMON
endif

$(info libshowlogo new path ------- $(LOCAL_DIR)/../../lib/libshowlogo)
INCLUDES += -I$(LOCAL_DIR)/include \
            -I$(LOCAL_DIR)/include/platform \
            -I$(LOCAL_DIR)/../../lib/libshowlogo \
            -I$(LK_TOP_DIR)/app/mt_boot/ \
            -Icustom/$(FULL_PROJECT)/lk/include/target \
            -Icustom/$(FULL_PROJECT)/lk/lcm/inc \
            -Icustom/$(FULL_PROJECT)/lk/inc \
            -Icustom/$(FULL_PROJECT)/common \
            -Icustom/$(FULL_PROJECT)/kernel/dct/ \
            -I$(BUILDDIR)/include/dfo \
            -I$(LOCAL_DIR)/../../dev/lcm/inc

INCLUDES += -I$(DRVGEN_OUT)/inc

# Convert all OBJS to MODULE_SRCS with source file extensions
MODULE_SRCS += \
	$(LOCAL_DIR)/bitops.c \
	$(LOCAL_DIR)/mt_gpio.c \
	$(LOCAL_DIR)/mt_disp_drv.c \
	$(LOCAL_DIR)/mt_gpio_init.c \
	$(LOCAL_DIR)/mt_i2c.c \
	$(LOCAL_DIR)/platform.c \
	$(LOCAL_DIR)/uart.c \
	$(LOCAL_DIR)/interrupts.c \
	$(LOCAL_DIR)/timer.c \
	$(LOCAL_DIR)/debug.c \
	$(LOCAL_DIR)/boot_mode.c \
	$(LOCAL_DIR)/load_image.c \
	$(LOCAL_DIR)/atags.c \
	$(LOCAL_DIR)/partition_setting.c \
	$(LOCAL_DIR)/mt_get_dl_info.c \
	$(LOCAL_DIR)/addr_trans.c \
	$(LOCAL_DIR)/factory.c \
	$(LOCAL_DIR)/mtk_key.c \
	$(LOCAL_DIR)/mt_logo.c \
	$(LOCAL_DIR)/mt_pmic_wrap_init.c \
	$(LOCAL_DIR)/mmc_common_inter.c \
	$(LOCAL_DIR)/mmc_core.c \
	$(LOCAL_DIR)/mmc_test.c \
	$(LOCAL_DIR)/msdc.c \
	$(LOCAL_DIR)/msdc_dma.c \
	$(LOCAL_DIR)/msdc_utils.c \
	$(LOCAL_DIR)/msdc_irq.c \
	$(LOCAL_DIR)/upmu_common.c \
	$(LOCAL_DIR)/mt_pmic.c \
	$(LOCAL_DIR)/mt6311.c \
	$(LOCAL_DIR)/mt_rtc.c \
	$(LOCAL_DIR)/ddp_manager.c \
	$(LOCAL_DIR)/ddp_path.c \
	$(LOCAL_DIR)/ddp_ovl.c \
	$(LOCAL_DIR)/ddp_rdma.c \
	$(LOCAL_DIR)/ddp_misc.c \
	$(LOCAL_DIR)/ddp_info.c \
	$(LOCAL_DIR)/ddp_dither.c \
	$(LOCAL_DIR)/ddp_dump.c \
	$(LOCAL_DIR)/ddp_dsi.c \
	$(LOCAL_DIR)/primary_display.c \
	$(LOCAL_DIR)/disp_lcm.c \
	$(LOCAL_DIR)/ddp_pwm.c \
	$(LOCAL_DIR)/pwm.c \
	$(LOCAL_DIR)/mtk_auxadc.c \
	$(LOCAL_DIR)/mt_dummy_read.c \
	$(LOCAL_DIR)/mt_efuse.c

ifneq ($(CFG_MTK_WDT_COMMON),yes)
MODULE_SRCS += $(LOCAL_DIR)/mtk_wdt.c
endif

ifeq ($(MTK_SECURITY_SW_SUPPORT),yes)
	MODULE_SRCS += $(LOCAL_DIR)/img_auth_stor.c
endif
ifneq ($(MACH_FPGA_LED_SUPPORT), yes)
	MODULE_SRCS += $(LOCAL_DIR)/mt_leds.c
endif
# SETTING of USBPHY type
#MODULE_SRCS += $(LOCAL_DIR)/mt_usbphy_d60802.c
#MODULE_SRCS += $(LOCAL_DIR)/mt_usbphy_e60802.c

MODULE_SRCS += $(LOCAL_DIR)/mt_battery.c

ifneq ($(MTK_EMMC_SUPPORT),yes)
#	MODULE_SRCS += $(LOCAL_DIR)/mtk_nand.c
#	MODULE_SRCS += $(LOCAL_DIR)/bmt.c
endif

ifeq ($(MTK_USB2JTAG_SUPPORT),yes)
MODULE_SRCS += $(LOCAL_DIR)/mt_usb2jtag.c
DEFINES += MTK_USB2JTAG_SUPPORT
endif

ifeq ($(MTK_MT8193_SUPPORT),yes)
MODULE_SRCS += $(LOCAL_DIR)/mt8193_init.c
MODULE_SRCS += $(LOCAL_DIR)/mt8193_ckgen.c
MODULE_SRCS += $(LOCAL_DIR)/mt8193_i2c.c
endif

ifeq ($(MTK_KERNEL_POWER_OFF_CHARGING),yes)
MODULE_SRCS += $(LOCAL_DIR)/mt_kernel_power_off_charging.c
DEFINES += MTK_KERNEL_POWER_OFF_CHARGING
endif

ifeq ($(MTK_PUMP_EXPRESS_SUPPORT),yes)
DEFINES += MTK_PUMP_EXPRESS_SUPPORT
endif

ifeq ($(MTK_BQ24261_SUPPORT),yes)
MODULE_SRCS += $(LOCAL_DIR)/bq24261.c
else
    ifeq ($(MTK_BQ24296_SUPPORT),yes)
        MODULE_SRCS += $(LOCAL_DIR)/bq24296.c
    else
        ifeq ($(MTK_NCP1854_SUPPORT),yes)
            MODULE_SRCS += $(LOCAL_DIR)/ncp1854.c
        endif
    endif
endif

ifeq ($(DUMMY_AP),yes)
MODULE_SRCS += $(LOCAL_DIR)/dummy_ap.c
#MODULE_SRCS += $(LOCAL_DIR)/spm_md_mtcmos.c
endif

ifeq ($(MTK_EFUSE_WRITER_SUPPORT), yes)
    DEFINES += MTK_EFUSE_WRITER_SUPPORT
endif

ifeq ($(MTK_GOOGLE_TRUSTY_SUPPORT),yes)
DEFINES += MTK_GOOGLE_TRUSTY_SUPPORT
endif

MTK_LOADER_BACKUP ?= yes
ifeq ($(MTK_LOADER_BACKUP),yes)
DEFINES += MTK_LOADER_BACKUP
endif

ifeq ($(MTK_USERIMAGES_USE_F2FS), yes)
DEFINES += MTK_USERIMAGES_USE_F2FS
endif

ifeq ($(MTK_DM_VERITY_OFF),yes)
DEFINES += MTK_DM_VERITY_OFF
endif

MODULE_SRCS += $(LOCAL_DIR)/dm_verity_status.c

MTK_RC_TO_VENDOR ?= yes

ifeq ($(CUSTOM_SEC_AUTH_SUPPORT), yes)
LIBSEC := -L$(LOCAL_DIR)/lib -lsec
else
LIBSEC := -L$(LOCAL_DIR)/lib -lsec -lcrypto
endif
LIBSEC_PLAT := -lsecplat -ldevinfo

MBLOCK_LIB_SUPPORT := yes
ifeq ($(MBLOCK_LIB_SUPPORT), yes)
    DEFINES += MBLOCK_LIB_SUPPORT=2
    MBLOCK_LIB_SUPPORT := 2
    MODULES += lib/mblock
    INCLUDES += -I$(LOCAL_DIR)/../../lib/mblock
endif

# kernel mblock limitation
DEFINES += KERNEL_MBLOCK_LIMIT=0x80000000

LINKER_SCRIPT += $(BUILDDIR)/system-onesegment.ld
