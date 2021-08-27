#
#  Copyright (c) 2021 true[X], Inc. All rights reserved.
#

MAKE_FILE := $(lastword $(MAKEFILE_LIST))
APPNAME = Truex_x_RokuExampleGame
IMPORTS =
ROKU_TEST_ID = 1
ROKU_TEST_WAIT_DURATION = 5
# Use globally set IP address and password as fallback
ROKU_DEV_TARGET := $(if $(ROKU_DEV_TARGET_OVERRIDE),$(ROKU_DEV_TARGET_OVERRIDE),$(if $(ROKU_DEV_TARGET),$(ROKU_DEV_TARGET),$(shell grep roku_ip_address ~/Library/Truex/Roku/target | sed 's/roku_ip_address=//')))
DEVPASSWORD := $(if $(DEVPASSWORD_OVERRIDE),$(DEVPASSWORD_OVERRIDE),$(if $(DEVPASSWORD),$(DEVPASSWORD),$(shell grep roku_dev_password ~/Library/Truex/Roku/target | sed 's/roku_dev_password=//')))
ZIP_EXCLUDE = -x test\* -x *.sh -x makefile -x dist\* -x channel_components\* -x channel_source\* -x channel_images\* -x *app.mk* -x *README* -x *rokuTarget* -x *.svn* -x *.git* -x *.DS_Store* -x out\* -x packages\* -x design\* -x node_modules/**\* -x node_modules -x .buildpath* -x .project* -x renderer\* -x backup\* -x *.code-workspace
# BRANCH_NAME is set by Jenkins. When on a release branch, the following will evaluate to `rc`, while on a develop branch, it will be left alone (`develop`).
RC_DEVELOP = $(shell echo $$BRANCH_NAME | sed "s/release.*/rc/")

APPSROOT = .
include $(APPSROOT)/app.mk

# The below `-hd` targets are normally used by CI to produce the HD / 720p version of Southback.
# This is done by updating the `ui_resolutions` value in the manifest to `hd`. The Southback layout
# honors this setting and dynamically adjusts the layout.
gen-hd:
	@echo " >> generating hd (720p) version of $(APPNAME)"
	@sed "s/ui_resolutions=.*/ui_resolutions=hd/g" manifest > manifestUpdated
	@mv manifestUpdated manifest

build-hd: gen-hd $(APPNAME)

install-hd: build-hd install
