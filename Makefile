PWD = $(shell pwd)
BR2_EXTERNAL = ${PWD}/base_external
BR2_DL_DIR ?= ${PWD}/../br_dl_dir
AESD_DEFCONFIG = ${PWD}/base_external/configs/aesd_qemu_defconfig
QEMU_DEFCONFIG = configs/qemu_aarch64_virt_defconfig
DEFAULT_DEFCONFIG = ${QEMU_DEFCONFIG}

BR2 = $(MAKE) -C buildroot BR2_DL_DIR=${BR2_DL_DIR} BR2_EXTERNAL=${BR2_EXTERNAL}


all: config build

submodule:
	@git submodule init
	@git submodule sync
	@git submodule update

config: submodule
	@test -e buildroot/.config || $(BR2) defconfig BR2_DEFCONFIG=${DEFAULT_DEFCONFIG}
	@$(BR2) menuconfig
	@$(BR2) savedefconfig BR2_DEFCONFIG=${AESD_DEFCONFIG}
	@if \
		test -e buildroot/output/build/linux-*/.config \
		&& grep "BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE" buildroot/.config > /dev/null \
	; then \
		$(BR2) linux-update-defconfig \
	; fi

build: submodule
	@$(BR2)

clean:
	@$(BR2) distclean

reconfigure:
	$(BR2) aesd-assignments-reconfigure
