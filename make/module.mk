# test for old style rules.mk
ifneq ($(flavor MODULE_OBJS),undefined)
ifneq ($(MODULE_OBJS),)
$(warning MODULE_OBJS = $(MODULE_OBJS))
$(warning MODULE $(MODULE) is setting MODULE_OBJS - this is deprecated, use MODULE_SRCS)
# Store for backward compatibility
MODULE_OLD_OBJS := $(MODULE_OBJS)
endif
endif
ifneq ($(flavor OBJS),undefined)
ifneq ($(OBJS),)
$(warning OBJS = $(OBJS))
$(warning MODULE $(MODULE) is using OBJS - this is deprecated, please use MODULE_SRCS)
# Store for backward compatibility
MODULE_OLD_OBJS := $(MODULE_OLD_OBJS) $(OBJS)
endif
endif

ifneq ($(filter $(MODULE),$(DENY_MODULES)),)
$(error MODULE $(MODULE) is not allowed by PROJECT $(PROJECT)'s DENY_MODULES list)
endif

MODULE_SRCDIR := $(MODULE)
MODULE_BUILDDIR := $(call TOBUILDDIR,$(MODULE_SRCDIR))

# add a local include dir to the global include path if it is present
ifneq ($(wildcard $(MODULE_SRCDIR)/include),)
GLOBAL_INCLUDES += $(MODULE_SRCDIR)/include
endif

# add the listed module deps to the global list
MODULES += $(MODULE_DEPS)

# parse options
MODULE_OPTIONS_COPY := $(sort $(MODULE_OPTIONS))
ifneq (,$(findstring float,$(MODULE_OPTIONS)))
# floating point option just forces all files in the module to be
# compiled with floating point compiler flags.
#$(info MODULE $(MODULE) has float option)
MODULE_FLOAT_SRCS := $(sort $(MODULE_FLOAT_SRCS) $(MODULE_SRCS))
MODULE_SRCS :=
MODULE_OPTIONS_COPY := $(filter-out float,$(MODULE_OPTIONS_COPY))
endif
ifneq (,$(findstring extra_warnings,$(MODULE_OPTIONS)))
# add some extra warnings to the various module compiler switches.
# add these extra switches first so it's possible for the rules.mk file
# that invoked us to override with a -Wno-...
MODULE_COMPILEFLAGS := $(EXTRA_MODULE_COMPILEFLAGS) $(MODULE_COMPILEFLAGS)
MODULE_CFLAGS := $(EXTRA_MODULE_CFLAGS) $(MODULE_CFLAGS)
MODULE_CPPFLAGS := $(EXTRA_MODULE_CPPFLAGS) $(MODULE_CPPFLAGS)
MODULE_ASMFLAGS := $(EXTRA_MODULE_ASMFLAGS) $(MODULE_ASMFLAGS)
MODULE_OPTIONS_COPY := $(filter-out extra_warnings,$(MODULE_OPTIONS_COPY))
endif
ifneq (,$(findstring test,$(MODULE_OPTIONS)))
# if this module has the test option, add a submodule for the tests
# that will be added if WITH_TESTS is true
ifeq (true, $(call TOBOOL,$(WITH_TESTS)))
MODULES += $(MODULE)/test
endif
MODULE_OPTIONS_COPY := $(filter-out test,$(MODULE_OPTIONS_COPY))
endif

ifneq ($(MODULE_OPTIONS_COPY),)
$(error MODULE $(MODULE) has unrecognized option(s) $(MODULE_OPTIONS_COPY))
endif

# if MODULE_SRCS and MODULE_FLOAT_SRCS are both empty, skip the rest of this
# file as there is nothing to build for this module.
ifneq ($(MODULE_SRCS)$(MODULE_FLOAT_SRCS)$(MODULE_ARM_OVERRIDE_SRCS),)

#$(info module $(MODULE))
#$(info MODULE_COMPILEFLAGS = $(MODULE_COMPILEFLAGS))
#$(info MODULE_SRCDIR $(MODULE_SRCDIR))
#$(info MODULE_BUILDDIR $(MODULE_BUILDDIR))
#$(info MODULE_DEPS $(MODULE_DEPS))
#$(info MODULE_SRCS $(MODULE_SRCS))
#$(info MODULE_FLOAT_SRCS $(MODULE_FLOAT_SRCS))
#$(info MODULE_ARM_OVERRIDE_SRCS $(MODULE_ARM_OVERRIDE_SRCS))
#$(info MODULE_OPTIONS $(MODULE_OPTIONS))

MODULE_DEFINES += MODULE_NAME=\"$(subst $(SPACE),_,$(MODULE))\"
MODULE_DEFINES += MODULE_OPTIONS=\"$(subst $(SPACE),_,$(MODULE_OPTIONS))\"
MODULE_DEFINES += MODULE_COMPILEFLAGS=\"$(subst $(SPACE),_,$(MODULE_COMPILEFLAGS))\"
MODULE_DEFINES += MODULE_CFLAGS=\"$(subst $(SPACE),_,$(MODULE_CFLAGS))\"
MODULE_DEFINES += MODULE_CPPFLAGS=\"$(subst $(SPACE),_,$(MODULE_CPPFLAGS))\"
MODULE_DEFINES += MODULE_ASMFLAGS=\"$(subst $(SPACE),_,$(MODULE_ASMFLAGS))\"
MODULE_DEFINES += MODULE_OPTFLAGS=\"$(subst $(SPACE),_,$(MODULE_OPTFLAGS))\"
MODULE_DEFINES += MODULE_INCLUDES=\"$(subst $(SPACE),_,$(MODULE_INCLUDES))\"
MODULE_DEFINES += MODULE_SRCDEPS=\"$(subst $(SPACE),_,$(MODULE_SRCDEPS))\"
MODULE_DEFINES += MODULE_DEPS=\"$(subst $(SPACE),_,$(MODULE_DEPS))\"
MODULE_DEFINES += MODULE_SRCS=\"$(subst $(SPACE),_,$(MODULE_SRCS))\"
MODULE_DEFINES += MODULE_FLOAT_SRCS=\"$(subst $(SPACE),_,$(MODULE_FLOAT_SRCS))\"
MODULE_DEFINES += MODULE_ARM_OVERRIDE_SRCS=\"$(subst $(SPACE),_,$(MODULE_ARM_OVERRIDE_SRCS))\"

# generate a per-module config.h file
MODULE_CONFIG := $(MODULE_BUILDDIR)/module_config.h

$(MODULE_CONFIG): MODULE_DEFINES:=$(MODULE_DEFINES)
$(MODULE_CONFIG): configheader
	@$(call MAKECONFIGHEADER,$@,MODULE_DEFINES)

GENERATED += $(MODULE_CONFIG)

MODULE_COMPILEFLAGS += -include $(MODULE_CONFIG)

MODULE_SRCDEPS += $(MODULE_CONFIG)

MODULE_INCLUDES := $(addprefix -I,$(MODULE_INCLUDES))

# include the rules to compile the module's object files
include make/compile.mk

# MODULE_OBJS is passed back from compile.mk
#$(info MODULE_OBJS = $(MODULE_OBJS))

# For backward compatibility - add any OBJS that were set directly
ifneq ($(MODULE_OLD_OBJS),)
MODULE_OBJS += $(MODULE_OLD_OBJS)
endif

# build a ld -r style combined object
MODULE_OBJECT := $(call TOBUILDDIR,$(MODULE_SRCDIR).mod.o)
$(MODULE_OBJECT): $(MODULE_OBJS) $(MODULE_EXTRA_OBJS)
	@$(MKDIR)
	$(info linking $@)
	$(NOECHO)$(LD) $(GLOBAL_MODULE_LDFLAGS) -r $^ -o $@

# track all of the source files compiled
ALLSRCS += $(MODULE_SRCS)

# track all the objects built
ALLOBJS += $(MODULE_OBJS)

# track the module object for make clean
GENERATED += $(MODULE_OBJECT)

# make the rest of the build depend on our output
ALLMODULE_OBJS := $(ALLMODULE_OBJS) $(MODULE_OBJECT)

else # ifneq ($(MODULE_ALL_SRCS),)
#$(info MODULE $(MODULE) has no source files, skipping)
endif

# empty out any vars set here
MODULE :=
MODULE_SRCDIR :=
MODULE_BUILDDIR :=
MODULE_DEPS :=
MODULE_SRCS :=
MODULE_FLOAT_SRCS :=
MODULE_OBJS :=
MODULE_OLD_OBJS :=
MODULE_DEFINES :=
MODULE_OPTFLAGS :=
MODULE_COMPILEFLAGS :=
MODULE_CFLAGS :=
MODULE_CPPFLAGS :=
MODULE_ASMFLAGS :=
MODULE_SRCDEPS :=
MODULE_INCLUDES :=
MODULE_EXTRA_OBJS :=
MODULE_CONFIG :=
MODULE_OBJECT :=
MODULE_ARM_OVERRIDE_SRCS :=
MODULE_OPTIONS :=
