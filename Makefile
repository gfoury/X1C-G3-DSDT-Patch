# makefile

# Patches/Builds DSDT patches for the Lenovo Thinkpad X1 Carbon Gen 3
#
# Originally based on https://github.com/RehabMan/HP-Envy-K-DSDT-Patch

# In Clover, press F4 to dump the ACPI tables.
# 
# Copy the contents of EFI/CLOVER/ACPI/origin to
# this directory's native_clover/origin.

# You need iasl and patchmatic on your PATH. If you don't have them,
# the download.sh script will download the zip files into
# downloads/tools/. Copy iasl and patchmatic into tools/.

export PATH:=tools:$(PATH)

LAPTOPGIT=./laptop-dsdt-patch
CLOVERCONFIG=./clover-laptop-config
#DEBUGGIT=../debug.git
BUILDDIR=./build
PATCHED=./patched
UNPATCHED=./unpatched
NATIVE=./native_clover
NATIVE_ORIGIN=./native_clover/origin

ifneq ($(wildcard $(NATIVE_ORIGIN)/DSDT*.aml),$(NATIVE_ORIGIN)/DSDT.aml)
$(error You need to dump the native DSDT/SSDT tables in Clover (press F4). Then copy the contents of EFI/CLOVER/ACPI/origin to this directory under $(NATIVE_ORIGIN))
endif

VERSION_ERA=$(shell ./print_version.sh)
ifeq "$(VERSION_ERA)" "10.10-"
	INSTDIR=/System/Library/Extensions
else
	INSTDIR=/Library/Extensions
endif
SLE=/System/Library/Extensions

# DSDT is easy to find...
DSDT=DSDT

# We want to rename GFX0 to IGPU. Besides the DSDT, there are two
# SSDTs which mention it.

# The place where _SB.PCI0.PEG0 is defined is the IGPU SSDT
#IGPU=$(shell grep -l Name.*_ADR.*0x00020000 $(UNPATCHED)/SSDT*.dsl)
BRIGHT=$(shell grep -l DefinitionBlock.*TP-SSDT2 $(UNPATCHED)/SSDT*.dsl)
BRIGHT:=$(subst $(UNPATCHED)/,,$(subst .dsl,,$(BRIGHT)))

# The big complicated thermal table that mentionds GFX0
SANV=$(shell grep -l OperationRegion.*SANV $(UNPATCHED)/SSDT*.dsl)
SANV:=$(subst $(UNPATCHED)/,,$(subst .dsl,,$(SANV)))

# Most of the AML files we aren't going to touch, only copy.
UNTOUCHED=$(shell echo $(UNPATCHED)/*.dsl)
UNTOUCHED:=$(subst $(UNPATCHED)/,,$(subst .dsl,,$(UNTOUCHED)))
UNTOUCHED:=$(filter-out $(DSDT) $(BRIGHT) $(SANV),$(UNTOUCHED))

UNTOUCHED_AML=$(addsuffix .aml,$(UNTOUCHED))

# testy:
# 	@echo $(UNTOUCHED_AML)
# 	@echo SSDT-0.aml SSDT-10.aml SSDT-12.aml SSDT-13.aml SSDT-14.aml SSDT-2.aml SSDT-3.aml SSDT-4.aml SSDT-5.aml SSDT-6.aml

# Here is the list of AML files we don't expect to touch, as a sanity check.
#ifneq ($(UNTOUCHED_AML),SSDT-0.aml SSDT-10.aml SSDT-12.aml SSDT-13.aml SSDT-14.aml SSDT-2.aml SSDT-3.aml SSDT-4.aml SSDT-5.aml SSDT-6.aml)
#$(error The list of SSDTs I am planning to just copy unchanged is different than I expected. Perhaps SSDTs are missing or have been renamed. This script is expecting to only modify SSDT-1 and SSDT-11.)
#endif

UNTOUCHED_IN_NATIVE=$(addprefix $(NATIVE_ORIGIN)/, $(UNTOUCHED_AML))
UNTOUCHED_IN_BUILDDIR=$(addprefix $(BUILDDIR)/, $(UNTOUCHED_AML))

# Determine build products
AML_PRODUCTS:=$(BUILDDIR)/$(DSDT).aml $(BUILDDIR)/$(BRIGHT).aml $(BUILDDIR)/$(SANV).aml $(UNTOUCHED_IN_BUILDDIR)

PRODUCTS=$(AML_PRODUCTS) 

#ALL_PATCHED=$(PATCHED)/$(DSDT).dsl $(PATCHED)/$(IGPU).dsl $(PATCHED)/$(DPTF).dsl
ALL_PATCHED=$(PATCHED)/$(DSDT).dsl $(PATCHED)/$(BRIGHT).dsl $(PATCHED)/$(SANV).dsl

IASLFLAGS=-ve
IASL=iasl

.PHONY: all
all: $(PRODUCTS)
	@echo
	@echo ---------------
	@echo Now copy $(BUILDDIR)/\*.aml to EFI/CLOVER/ACPI/patched
	@echo ...and remember to set DropOem to true in CLOVER/config.plist

$(BUILDDIR)/DSDT.aml: $(PATCHED)/$(DSDT).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/$(BRIGHT).aml: $(PATCHED)/$(BRIGHT).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/$(SANV).aml: $(PATCHED)/$(SANV).dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

.PHONY: clean
clean:
	rm -f $(PATCHED)/*.dsl
	rm -f $(BUILDDIR)/*.dsl $(BUILDDIR)/*.aml $(BUILDDIR)/*.plist

.PHONY: cleanall
cleanall:
	make clean
	rm -f $(UNPATCHED)/*.dsl

.PHONY: cleanallex
cleanallex:
	make cleanall
	rm -f native_patchmatic/*.aml

# Clover Install
.PHONY: install
install: $(PRODUCTS)
	$(error You do not want to run this)
	$(eval EFIDIR:=$(shell sudo ./mount_efi.sh /))
	cp $(BUILDDIR)/$(DSDT).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched
	cp $(BUILDDIR)/$(PPC).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-2.aml
	cp $(BUILDDIR)/$(DYN).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-3.aml
	cp $(BUILDDIR)/$(IGPU).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-4.aml
ifneq "$(PEGP)" ""
	cp $(BUILDDIR)/$(PEGP).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-5.aml
endif
ifneq "$(IAOE)" ""
	cp $(BUILDDIR)/$(IAOE).aml $(EFIDIR)/EFI/CLOVER/ACPI/patched/SSDT-7.aml
endif

.PHONY: update_kernelcache
update_kernelcache:
	sudo touch $(SLE)
	sudo kextcache -update-volume /

# .PHONY: install_hda
# install_hda:
# 	sudo rm -Rf $(INSTDIR)/$(HDAINJECT)
# 	sudo cp -R ./$(HDAINJECT) $(INSTDIR)
# 	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(HDAINJECT); fi
# 	make update_kernelcache

# .PHONY: install_usb
# install_usb:
# 	sudo rm -Rf $(INSTDIR)/$(USBINJECT)
# 	sudo cp -R ./$(USBINJECT) $(INSTDIR)
# 	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(USBINJECT); fi
# 	make update_kernelcache

# .PHONY: install_backlight
# install_backlight:
# 	sudo rm -Rf $(INSTDIR)/$(BACKLIGHTINJECT)
# 	sudo cp -R ./$(BACKLIGHTINJECT) $(INSTDIR)
# 	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(BACKLIGHTINJECT); fi
# 	make update_kernelcache

# Patch with 'patchmatic'

.PHONY: patch
patch: $(ALL_PATCHED)

$(PATCHED)/$(DSDT).dsl: $(UNPATCHED)/$(DSDT).dsl
	cp $(UNPATCHED)/$(DSDT).dsl $(PATCHED)
	patchmatic $@ $(LAPTOPGIT)/syntax/remove_DSM.txt
	patchmatic $@ $(LAPTOPGIT)/system/system_SMBUS.txt
	# not doing audio layout 12
	patchmatic $@ $(LAPTOPGIT)/system/system_WAK2.txt
	patchmatic $@ $(LAPTOPGIT)/system/system_HPET.txt
	patchmatic $@ $(LAPTOPGIT)/system/system_IRQ.txt
	patchmatic $@ $(LAPTOPGIT)/system/system_RTC.txt
	patchmatic $@ $(LAPTOPGIT)/system/system_OSYS_win8.txt
	#patchmatic $@ $(LAPTOPGIT)/system/system_PNOT.txt
	patchmatic $@ $(LAPTOPGIT)/system/system_IMEI.txt
	patchmatic $@ $(LAPTOPGIT)/battery/battery_Lenovo-X220.txt
	# already fixed ADGB
	patchmatic $@ $(LAPTOPGIT)/graphics/graphics_PNLF_haswell.txt 
	patchmatic $@ $(LAPTOPGIT)/graphics/graphics_Rename-PCI0_VID.txt
	patchmatic $@ patches/brightbutton.txt

# This would use the 0x6d USB patch


$(PATCHED)/$(BRIGHT).dsl: $(UNPATCHED)/$(BRIGHT).dsl 
	cp $(UNPATCHED)/$(BRIGHT).dsl $(PATCHED)
	patchmatic $@ $(LAPTOPGIT)/graphics/graphics_Rename-PCI0_VID.txt

$(PATCHED)/$(SANV).dsl: $(UNPATCHED)/$(SANV).dsl 
	cp $(UNPATCHED)/$(SANV).dsl $(PATCHED)
	patchmatic $@ $(LAPTOPGIT)/graphics/graphics_Rename-PCI0_VID.txt

$(UNTOUCHED_IN_BUILDDIR): $(BUILDDIR)/%: $(NATIVE_ORIGIN)/%
	cp $< $@

#$(BUILDDIR)/config.plist: config.patch $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist
#	patch -o $(BUILDDIR)/config.plist $(CLOVERCONFIG)/config_HD5300_5500_5600_6000.plist config.patch
