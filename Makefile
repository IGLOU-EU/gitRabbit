APPNAME := gitrabbit
WHOAMI  := $(shell whoami)
OS      := $(shell uname 2>/dev/null || echo Unknown)

UADD  ?= useradd -s /sbin/nologin
UDEL  ?= userdel
MKDIR ?= mkdir -p
CHOWN ?= chown
RM    ?= rm -rf
CP    ?= cp

BIN ?= /usr/local/bin/
ETC ?= /etc/$(APPNAME)

ifeq ($(OS),Linux)
	VAR         ?= /var/lib/gitrabbit
	DMN         := /usr/lib/systemd/system/
	DMN_FILE    := gitrabbit.service
	DMN_STOP    := systemctl stop
	DMN_START   := systemctl start
	DMN_ENABLE  := systemctl enable
	DMN_DISABLE := systemctl disable
endif
ifeq ($(OS),OpenBSD)
	VAR         ?= /var/gitrabbit
	DMN         := /etc/rc.d/
	DMN_FILE    := gitrabbitd
	DMN_STOP    := rcctl stop
	DMN_START   := rcctl start
	DMN_ENABLE  := rcctl enable
	DMN_DISABLE := rcctl disable
endif

.PHONY: help
help:
	@echo "Make Routines:"
	@echo " - \"\"                print Make routines list"
	@echo " - install           install the binary and config files"
	@echo " - upgrade           update installed binary"
	@echo " - remove            remove binary"
	@echo " - removeall         remove binary, config and datas files"

.PHONY: need
need:
ifndef DMN
	@echo "OS not supported '$(OS)'"
	(exit 1)
endif
ifneq ($(WHOAMI),root)
	@echo "You need to be root !"
	(exit 1)
endif

.PHONY: install
install: need
	@echo "Installing $(APPNAME)"

	$(UADD) $(APPNAME)
	$(MKDIR) $(ETC)
	$(MKDIR) $(VAR)
	$(CHOWN) $(APPNAME) $(VAR)

	$(CP) etc/gitRabbit/lapereaux.conf.sample $(ETC)/lapereaux.conf
	$(CP) bin/$(APPNAME) $(BIN)/$(APPNAME)
	$(CP) service/$(DMN_FILE) $(DMN)$(DMN_FILE)

	$(DMN_START) $(DMN_FILE)
	$(DMN_ENABLE) $(DMN_FILE)

.PHONY: remove
remove: need
	@echo "Uninstalling $(APPNAME)"

	$(UDEL) $(APPNAME)
	$(DMN_STOP) $(DMN_FILE)
	$(DMN_DISABLE) $(DMN_FILE)

	$(RM) $(BIN)$(APPNAME)
	$(RM) $(DMN)$(DMN_FILE)

.PHONY: removeall
removeall: need remove
	@echo "Remove config and data files"
	$(RM) $(ETC)
	$(RM) $(VAR)

.PHONY: upgrade
upgrade: need
	git pull
	$(CP) bin/$(APPNAME) $(BIN)/$(APPNAME)
