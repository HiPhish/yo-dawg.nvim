# SPDX-FileCopyrightText: © 2024 Alejandro "HiPhish" Sanchez
# SPDX-License-Identifier: Unlicense

.PHONY: check integration-test clean

check: integration-test

integration-test:
	@./test/bin/busted --run integration

clean:
	@rm -rf test/xdg/local/state/nvim/*
