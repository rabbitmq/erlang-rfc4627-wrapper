ifdef PACKAGE_DIR
UPSTREAM_GIT:=http://github.com/tonyg/erlang-rfc4627.git

EBIN_DIR:=$(PACKAGE_DIR)/ebin
CHECKOUT_DIR:=$(PACKAGE_DIR)/erlang-rfc4627-git
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/include
APP_NAME:=rfc4627_jsonrpc

## The path to httpd.hrl has changed in OTP R14A and newer. Detect the
## change, and supply a compile-time macro definition to allow
## rfc4627_jsonrpc_inets.erl to adapt to the new path.
ifeq ($(shell test R14A \> $$(erl -noshell -eval 'io:format(erlang:system_info(otp_release)), halt().') && echo yes),yes)
ERLC_OPTS =
else
ERLC_OPTS +=-Dnew_inets
endif

$(CHECKOUT_DIR)_UPSTREAM_GIT:=$(UPSTREAM_GIT)
$(CHECKOUT_DIR):
	git clone $($@_UPSTREAM_GIT) $@

$(CHECKOUT_DIR)/stamp: | $(CHECKOUT_DIR)
	rm -f $@
	cd $(@D) && echo COMMIT_SHORT_HASH:=$$(git log -n 1 --format=format:"%h" HEAD) >> $@

.PHONY: $(EBIN_DIR)/$(APP_NAME).app
$(EBIN_DIR)/$(APP_NAME).app: $(CHECKOUT_DIR)/ebin/$(APP_NAME).app | $(EBIN_DIR)
	sed -e 's/{vsn, *\"[^\"]\+\"/{vsn,\"$($@_VERSION)\"/' < $< > $@

$(PACKAGE_DIR)/clean_RM:=$(CHECKOUT_DIR) $(CHECKOUT_DIR)/stamp $(EBIN_DIR)/$(APP_NAME).app
$(PACKAGE_DIR)/clean::
	rm -rf $($@_RM)

ifneq "$(strip $(patsubst clean%,,$(patsubst %clean,,$(TESTABLEGOALS))))" ""
include $(CHECKOUT_DIR)/stamp

VERSION:=rmq$(GLOBAL_VERSION)-git$(COMMIT_SHORT_HASH)
$(EBIN_DIR)/$(APP_NAME).app_VERSION:=$(VERSION)
endif
endif

include ../include.mk
