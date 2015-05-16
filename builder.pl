#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT,':utf8');
binmode(STDIN, ':utf8');
binmode(STDERR,':utf8');

use File::Path;

my %configs=(
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


sub generate_board_txt {

	my $buf=<< "EOS";
menu.f_cpu=CPU Frequency

EOS
	foreach my $cpu_name (keys %configs) {
		my $cpu=$configs{$cpu_name};
		$buf.=<< "EOS";
$cpu->{key}.name=$cpu_name
$cpu->{key}.upload.tool=avrdude
$cpu->{key}.upload.protocol=arduino
$cpu->{key}.bootloader.tool=avrdude
$cpu->{key}.bootloader.unlock_bits=$cpu->{unlock_bits}
$cpu->{key}.bootloader.lock_bits=$cpu->{lock_bits}
$cpu->{key}.build.mcu=$cpu->{mcu}

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
	open(my $fh,'>:utf8','hardware/ATmega/avr/boards.txt') || die $!;
	print $fh $buf;
}

sub generate_optiboot_custom {
	my $buf="";
	my @targets=();

	foreach my $cpu_name (keys %configs) {
		my $cpu=$configs{$cpu_name};
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

	open(my $fh,'>:utf8','hardware/ATmega/avr/bootloaders/atmega/Makefile.custom') || die $!;
	print $fh $buf;
}

generate_board_txt();
generate_optiboot_custom();

1;
