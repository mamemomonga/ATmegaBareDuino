ARDUINO_IDE=/Applications/Arduino.app
ARDUINO_HARDWARE=/Applications/Arduino.app/Contents/Java/hardware

DESTDIR=hardware/ATmega/avr

export PATH := $(ARDUINO_HARDWARE)/tools/avr/bin:$(PATH)

.PHONY: hardware get_optiboot all

all: hardware build_optiboot copy_from_arduino

hardware:
	mkdir -p $(DESTDIR)/bootloaders/atmega

copy_from_arduino:
	cp $(ARDUINO_HARDWARE)/arduino/avr/platform.txt $(DESTDIR)/
	cp -r $(ARDUINO_HARDWARE)/arduino/avr/cores     $(DESTDIR)/
	cp -r $(ARDUINO_HARDWARE)/arduino/avr/libraries $(DESTDIR)/
	cp -r $(ARDUINO_HARDWARE)/arduino/avr/variants  $(DESTDIR)/

build_optiboot: optiboot
	cp optiboot/optiboot/bootloaders/optiboot/*.c        $(DESTDIR)/bootloaders/atmega/
	cp optiboot/optiboot/bootloaders/optiboot/*.h        $(DESTDIR)/bootloaders/atmega/
	cp optiboot/optiboot/bootloaders/optiboot/Makefile   $(DESTDIR)/bootloaders/atmega/
	cp optiboot/optiboot/bootloaders/optiboot/Makefile.* $(DESTDIR)/bootloaders/atmega/

	./configure.pl generate_optiboot_custom

	cd hardware/ATmega/avr/bootloaders/atmega; make build_custom

optiboot:
	git clone https://github.com/Optiboot/optiboot.git

clean:
	rm -rf hardware

