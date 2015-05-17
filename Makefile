
# Arduino IDE 1.6.4

ARDUINO_IDE=/Applications/Arduino.app
ARDUINO_HARDWARE=$(ARDUINO_IDE)/Contents/Java/hardware/arduino/avr

DESTDIR=hardware/ATmega/avr

export PATH := $(ARDUINO_IDE)/Contents/Java/hardware/tools/avr/bin:$(PATH)

.PHONY: hardware get_optiboot all

all: hardware build_optiboot copy_from_arduino

hardware:
	mkdir -p $(DESTDIR)/bootloaders/atmega

copy_from_arduino:
	cp $(ARDUINO_HARDWARE)/platform.txt $(DESTDIR)/
	cp -r $(ARDUINO_HARDWARE)/cores     $(DESTDIR)/
	cp -r $(ARDUINO_HARDWARE)/libraries $(DESTDIR)/
	cp -r $(ARDUINO_HARDWARE)/variants  $(DESTDIR)/

build_optiboot:
	cp src/optiboot/optiboot/bootloaders/optiboot/*.c        $(DESTDIR)/bootloaders/atmega/
	cp src/optiboot/optiboot/bootloaders/optiboot/*.h        $(DESTDIR)/bootloaders/atmega/
	cp src/optiboot/optiboot/bootloaders/optiboot/Makefile   $(DESTDIR)/bootloaders/atmega/
	cp src/optiboot/optiboot/bootloaders/optiboot/Makefile.* $(DESTDIR)/bootloaders/atmega/
	./builder.pl
	cd hardware/ATmega/avr/bootloaders/atmega; make build_custom

get_optiboot:
	mkdir src
	cd src; git clone https://github.com/Optiboot/optiboot.git

clean:
	rm -rf hardware


