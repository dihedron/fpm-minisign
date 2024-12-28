VERSION=$(shell curl -sI https://github.com/jedisct1/minisign/releases/latest | grep -i Location | cut -d" " -f2 | grep -Eo '[0-9]+\.[0-9]+')
PACKAGE_DOWNLOAD_URL=https://github.com/jedisct1/minisign/releases/download/$(VERSION)/minisign-$(VERSION)-linux.tar.gz
SIGNATURE_DOWNLOAD_URL=https://github.com/jedisct1/minisign/releases/download/$(VERSION)/minisign-$(VERSION)-linux.tar.gz.minisig
SIGNATURE=RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3



minisign-$(VERSION)-linux.tar.gz:
	@wget $(PACKAGE_DOWNLOAD_URL)
	@wget $(SIGNATURE_DOWNLOAD_URL)

.phony: latest
latest:
	@echo "Latest minisign version is $(VERSION)"

.phony: verify
verify:
ifeq ($(shell which minisign),)
	@echo "Please install minisign to perform signature verification"
else
	@minisign -Vm minisign-$(VERSION)-linux.tar.gz -P $(SIGNATURE)
endif

.phony: setup-tools
setup-tools:
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

.phony: deb
deb: minisign-$(VERSION)-linux.tar.gz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf minisign-linux/
	@tar xvf minisign-$(VERSION)-linux.tar.gz 2>&1 > /dev/null
	@echo -n "Create minisign $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager deb --target .
	@rm -rf minisign-linux/

.phony: rpm
rpm: minisign-$(VERSION)-linux.tar.gz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf minisign-linux/
	@tar xvf minisign-$(VERSION)-linux.tar.gz 2>&1 > /dev/null
	@echo -n "Create minisign $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager rpm --target .
	@rm -rf minisign-linux/


# TODO: run a cleanup task removing go/ only once:
# see https://gist.github.com/APTy/9a9eb218f68bc0b4beb133b89c9def14

.phony: apk
apk: minisign-$(VERSION)-linux.tar.gz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf minisign-linux/
	@tar xvf minisign-$(VERSION)-linux.tar.gz 2>&1 > /dev/null
	@echo -n "Create minisign $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager apk --target .
	@rm -rf minisign-linux/

.phony: clean
clean:
	@rm -rf *.deb *.rpm *.apk *.tar.gz* minisign-linux/ *.minisig
