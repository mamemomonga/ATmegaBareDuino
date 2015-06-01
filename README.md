#素のATmega 168P / ATmega 368PをArduinoにする

## 実行環境

* OSX Yosemite
* Arduino 1.6.4
* Xcode Command Line Tools (make, perl, git他)

## 実行

	$ ./configure.pl
	$ make

hardwares ディレクトリを 書類/ArduinoにコピーしてArduino IDEを再起動します。

## ビルドせず手作業でセットアップ

hardwares ディレクトリにはすでにビルドした状態のものがはいっていますので、以下の作業をすることでビルドせず利用することが出来ます。

1.hardwares ディレクトリを 書類/Arduinoにコピー

2.ATmega/avrにArduino IDEから以下のディレクトリ・ファイルをコピーします。

コピー元 /Applications/Arduino.app/Contents/Java/hardware/arduino/avr

	platform.txt
	cores/
	libraries/
	variants/

3.Arduino IDEを再起動します。

## 結線

この図がわかりやすいです。

[How made a DIY Board](http://www.pighixxx.com/test/portfolio-items/diy-board/)

* 100nFは0.1uF
* RTSは#DTR
* 5V電源とUSBのVccは同時に入力しないこと

ATmega168P/328Pのピン配列とArduinoとの対照表はこちらが参考になります。

[ATMEGA328 PINOUT](http://www.pighixxx.com/test/portfolio-items/atmega328/?portfolioID=337)


## このプログラムは以下のページからのコードを含んでいます。

[https://github.com/Optiboot/optiboot](https://github.com/Optiboot/optiboot)
