LINT_FILE ?= $(wildcard *.sv)


.PHONY: lint 
lint:
	verilator --lint-only -Wall $(LINT_FILE)
