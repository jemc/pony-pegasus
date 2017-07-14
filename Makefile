all: test
.PHONY: all test clean lldb lldb-test ci ci-setup

PKG=pegasus

bin/test: $(shell find ${PKG}/*.pony ${PKG}/**/*.pony)
	mkdir -p bin
	ponyc --debug -o bin ${PKG}/test

test: bin/test
	$^

clean:
	rm -rf bin lib/libpony-${PKG}.so

lldb:
	lldb -o run -- $(shell which ponyc) --debug -o /tmp ${PKG}/test

lldb-test: bin/test
	lldb -o run -- bin/test

ci: test

ci-setup:
