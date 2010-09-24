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

$(CHECKOUT_DIR):
	git clone $(UPSTREAM_GIT) $@

$(CHECKOUT_DIR).stamp: | $(CHECKOUT_DIR)
	touch $@

$(EBIN_DIR):
	mkdir -p $@

$(EBIN_DIR)/$(APP_NAME).app: | $(EBIN_DIR)
	cp $(CHECKOUT_DIR)/ebin/$(@F) $@

$(PACKAGE_DIR)/clean::
	rm -rf $(CHECKOUT_DIR) $(CHECKOUT_DIR).stamp

include $(CHECKOUT_DIR).stamp
endif

include ../include.mk
