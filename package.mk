APP_NAME:=rfc4627_jsonrpc

UPSTREAM_GIT:=http://github.com/tonyg/erlang-rfc4627.git
UPSTREAM_APP_FILE=$(CLONE_DIR)/ebin/$(APP_NAME).app

## The path to httpd.hrl has changed in OTP R14A and newer. Detect the
## change, and supply a compile-time macro definition to allow
## rfc4627_jsonrpc_inets.erl to adapt to the new path.
ifeq ($(shell test R14A \> $$(erl -noshell -eval 'io:format(erlang:system_info(otp_release)), halt().') && echo yes),yes)
ERLC_OPTS:=
else
ERLC_OPTS:=-Dnew_inets
endif
