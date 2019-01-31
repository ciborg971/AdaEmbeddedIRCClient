all:
	gprbuild --target=arm-eabi -d -p AdaEmbeddedIRCClient.gpr -XLCH=led -XRTS_Profile=ravenscar-sfp -XLOADER=ROM -XADL_BUILD_CHECKS=Disabled -XADL_BUILD=Debug src/main.adb -largs -W
	arm-eabi-objcopy -O binary obj/main obj/main.bin
clean:
	rm -rf obj/
