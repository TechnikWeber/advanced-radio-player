ID      := com.technikweber.advancedradio
VERSION := $(shell python3 -c 'import json;print(json.load(open("package/metadata.json"))["KPlugin"]["Version"])')

.PHONY: check dist install uninstall clean

check:
	python3 -c 'import json;d=json.load(open("package/metadata.json"))["KPlugin"];assert d["Id"]=="$(ID)",d["Id"]'
	grep -q "device: mediaDevices.defaultAudioOutput" package/contents/ui/main.qml
	grep -q "device: testPlayDevices.defaultAudioOutput" package/contents/ui/config/configSearch.qml

dist: check
	rm -rf dist && mkdir -p dist
	cd package && zip -qr ../dist/$(ID).plasmoid . -x '*.orig' '*.bak'
	@echo "dist/$(ID).plasmoid ($(VERSION))"

install:
	kpackagetool6 -t Plasma/Applet -u package 2>/dev/null || kpackagetool6 -t Plasma/Applet -i package

uninstall:
	kpackagetool6 -t Plasma/Applet -r $(ID)

clean:
	rm -rf dist
