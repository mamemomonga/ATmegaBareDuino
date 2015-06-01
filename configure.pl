#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use feature 'say';
binmode(STDOUT,':utf8');
binmode(STDIN, ':utf8');
binmode(STDERR,':utf8');

# 単体のATmega328P/168PをArduinoで使えるようにするための
# 設定をはき出します。

use File::Path;
use File::Basename;

my %configs=(
	# 以下はOSX版の設定

	# Arduino IDE(1.6.4)のパス
	arduino_ide_path =>
		'/Applications/Arduino.app',

	# hardware情報のあるパス
	arduino_ide_hardware_path =>
		'/Applications/Arduino.app/Contents/Java/hardware'
);

my %mcu=(
	# ATmega168Pの設定
	'ATmega168P' => {
		unlock_bits       => '0x3F',
		lock_bits         => '0x0F',
		maximum_size      => 15872,
		maximum_data_size => 1024,
		key               => 'atmega168p',
		mcu               => 'atmega168p',
		menu => {
			'External 16MHz' => {
				key            => '16MHz',
				f_cpu          => '16000000L',
				low_fuses      => '0xFF',
				high_fuses     => '0xDD',
				extended_fuses => '0x04'
			},
			'External 20MHz' => {
				key            => '20MHz',
				f_cpu          => '20000000L',
				low_fuses      => '0xFF',
				high_fuses     => '0xDD',
				extended_fuses => '0x04'
			},
			'Internal 8MHz' => {
				key            => '8MHz',
				f_cpu          => '8000000L',
				low_fuses      => '0xE2',
				high_fuses     => '0xDD',
				extended_fuses => '0x04'
			},
		},
	},
	# ATmega328Pの設定
	'ATmega328P' => {
		unlock_bits       => '0x3F',
		lock_bits         => '0x0F',
		maximum_size      => 32256,
		maximum_data_size => 2048,
		key               => 'atmega328p',
		mcu               => 'atmega328p',
		menu => {
			'External 16MHz' => {
				key            => '16MHz',
				f_cpu          => '16000000L',
				low_fuses      => '0xFF',
				high_fuses     => '0xDE',
				extended_fuses => '0x05'
			},
			'External 20MHz' => {
				key            => '20MHz',
				f_cpu          => '20000000L',
				low_fuses      => '0xFF',
				high_fuses     => '0xDE',
				extended_fuses => '0x05'
			},
			'Internal 8MHz' => {
				key            => '8MHz',
				f_cpu          => '8000000L',
				low_fuses      => '0xE2',
				high_fuses     => '0xDD',
				extended_fuses => '0x04'
			},
		}
	}
);

sub write_file {
	my($filename,$buf)=@_;
	my $dirname=dirname($filename);

	if(!-d $dirname) {
		mkpath($dirname);
		say "create: $dirname";
	}

	open(my $fh,'>:utf8',$filename) || die $!;
	print $fh $buf;
	say "write: $filename";
}


sub generate_board_txt {

	my $buf=<< "EOS";
menu.f_cpu=CPU Frequency

EOS
	foreach my $cpu_name (keys %mcu) {
		my $cpu=$mcu{$cpu_name};
		$buf.=<< "EOS";
$cpu->{key}.name=$cpu_name
$cpu->{key}.upload.tool=avrdude
$cpu->{key}.upload.protocol=arduino
$cpu->{key}.bootloader.tool=avrdude
$cpu->{key}.bootloader.unlock_bits=$cpu->{unlock_bits}
$cpu->{key}.bootloader.lock_bits=$cpu->{lock_bits}
$cpu->{key}.build.mcu=$cpu->{mcu}
$cpu->{key}.build.core=arduino
$cpu->{key}.upload.maximum_size=$cpu->{maximum_size}
$cpu->{key}.upload.maximum_data_size=$cpu->{maximum_data_size}
$cpu->{key}.upload.speed=115200

EOS

		foreach my $menu_name (keys %{$cpu->{menu}}) {
			my $menu=$cpu->{menu}->{$menu_name};
			$buf.=<<"EOS";
$cpu->{key}.menu.f_cpu.$menu->{key}=$menu_name
$cpu->{key}.menu.f_cpu.$menu->{key}.build.f_cpu=$menu->{f_cpu}
$cpu->{key}.menu.f_cpu.$menu->{key}.bootloader.low_fuses=$menu->{low_fuses}
$cpu->{key}.menu.f_cpu.$menu->{key}.bootloader.high_fuses=$menu->{high_fuses}
$cpu->{key}.menu.f_cpu.$menu->{key}.bootloader.extended_fuses=$menu->{extended_fuses}
$cpu->{key}.menu.f_cpu.$menu->{key}.build.variant=standard
$cpu->{key}.menu.f_cpu.$menu->{key}.bootloader.file=atmega/optiboot_$cpu->{mcu}\_$menu->{key}.hex

EOS
		}

	}
	write_file('hardware/ATmega/avr/boards.txt',$buf);
}

sub generate_optiboot_custom {
	my $buf="";
	my @targets=();

	foreach my $cpu_name (keys %mcu) {
		my $cpu=$mcu{$cpu_name};
		foreach my $menu_name (keys %{$cpu->{menu}}) {
			my $menu=$cpu->{menu}->{$menu_name};

			my $target_name="$cpu->{mcu}_$menu->{key}";
			my $file_name="optiboot_$target_name";
			push @targets,$target_name;

			$buf.=<< "EOS";
$target_name: TARGET = $target_name
$target_name: MCU_TARGET = $cpu->{mcu}
$target_name: CFLAGS += \$(COMMON_OPTIONS)
$target_name: CHIP = atmega168p
$target_name: $file_name.hex
$target_name: $file_name.lst
$target_name: AVR_FREQ=$menu->{f_cpu}

EOS
		}
	}

	$buf.="build_custom: ".join(' ',@targets)."\n";
	write_file('hardware/ATmega/avr/bootloaders/atmega/Makefile.custom',$buf);
}

sub generate_makefile {

	my $buf=<<'__EOS__';
ARDUINO_IDE=###arduino_ide_path###
ARDUINO_HARDWARE=###arduino_ide_hardware_path###

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

__EOS__

	foreach(qw( arduino_ide_path arduino_ide_hardware_path )) {
		$buf=~s/\Q###$_###\E/$configs{$_}/g;
	}
	write_file('Makefile',$buf);
}

if($ARGV[0] && ( $ARGV[0] eq 'generate_optiboot_custom')) {
	generate_optiboot_custom();
} else {
	generate_board_txt();
	generate_makefile();
}

1;
