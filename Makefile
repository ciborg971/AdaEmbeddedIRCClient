all: obj/main
.PHONY: all

obj/main: src/main.adb src/irc.ads src/irc.adb
	gprbuild --target=arm-eabi -d -p AdaEmbeddedIRCClient.gpr -XLCH=led -XRTS_Profile=ravenscar-sfp -XLOADER=ROM -XADL_BUILD_CHECKS=Disabled -XADL_BUILD=Debug src/main.adb -largs -W
	arm-eabi-objcopy -O binary obj/main obj/main.bin

%.bin: %
	arm-none-eabi-objcopy -O binary -S $< $@

flash: obj/main.bin
	st-flash write $< 0x08000000
.PHONY: flash

clean:
	rm -rf obj/
.PHONY: clean
