APP_NAME:=rfc4627_jsonrpc

UPSTREAM_GIT:=http://github.com/tonyg/erlang-rfc4627.git

CHECKOUT_DIR:=$(PACKAGE_DIR)/erlang-rfc4627-git
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/include

## The path to httpd.hrl has changed in OTP R14A and newer. Detect the
## change, and supply a compile-time macro definition to allow
## rfc4627_jsonrpc_inets.erl to adapt to the new path.
ifeq ($(shell test R14A \> $$(erl -noshell -eval 'io:format(erlang:system_info(otp_release)), halt().') && echo yes),yes)
ERLC_OPTS:=
else
ERLC_OPTS:=-Dnew_inets
endif

$(eval $(call safe_include,$(PACKAGE_DIR)/version.mk))

VERSION:=rmq$(GLOBAL_VERSION)-git$(COMMIT_SHORT_HASH)

define package_targets

$(CHECKOUT_DIR)/.done:
	rm -rf $(CHECKOUT_DIR)
	git clone $(UPSTREAM_GIT) $(CHECKOUT_DIR)
	touch $$@

$(PACKAGE_DIR)/version.mk: $(CHECKOUT_DIR)/.done
	echo COMMIT_SHORT_HASH:=`git --git-dir=$(CHECKOUT_DIR)/.git log -n 1 --format=format:"%h" HEAD` >$$@

$(EBIN_DIR)/$(APP_NAME).app: $(CHECKOUT_DIR)/ebin/$(APP_NAME).app $(PACKAGE_DIR)/version.mk
	@mkdir -p $$(@D)
	sed -e 's|{vsn, *\"[^\"]*\"|{vsn,\"$(VERSION)\"|' <$$< >$$@

$(PACKAGE_DIR)+clean::
	rm -rf $(CHECKOUT_DIR) $(EBIN_DIR)/$(APP_NAME).app $(PACKAGE_DIR)/version.mk

endef
