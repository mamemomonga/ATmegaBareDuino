#素のATmega 168P / ATmega 368PをArduinoにする

## 実行環境

* OSX Yosemite
* Arduino 1.6.4
* Xcode Command Line Tools (make, perl)

## ビルド

	$ make get_optiboot
	$ make

hardwares ディレクトリを 書類/ArduinoにコピーしてArduino IDEを再起動します。

## ビルドせず手作業でセットアップ

hardwares ディレクトリにはすでにビルドした状態のものがはいっていますので、以下の作業をすることでビルドせず利用することが出来ます。

1. hardwares ディレクトリを 書類/Arduinoにコピー
2. ATmega/avrにArduino IDEから以下のディレクトリ・ファイルをコピーします。

	/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/platform.txt
	/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/cores
	/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/libraries
	/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/variants

3. Arduino IDEを再起動します。

## このプログラムは以下のページからのコードを含んでいます。

[https://github.com/Optiboot/optiboot](https://github.com/Optiboot/optiboot)
