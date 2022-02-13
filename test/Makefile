# Simple makefile to wrap the compilation and execution of tests. Don't worry
# about being smart with Make rules and prerequisites - Meson will handle that
# itself during compilation.

.DEFAULT_RULE: tests
.PHONY: tests clean-tests

SHELL = /bin/sh
BUILD_DIR = ./build
TEST_EXECUTABLE = $(BUILD_DIR)/com.github.avojak.replay-tests

$(BUILD_DIR):
	meson build --prefix=/usr

tests: | $(BUILD_DIR)
	sudo ninja -C build install

run-tests: tests
	$(TEST_EXECUTABLE)

clean-tests:
	sudo rm -rf $(BUILD_DIR)