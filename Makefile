swiftArgs = -Xswiftc -target -Xswiftc x86_64-apple-macosx11

build:
	swift build $(swiftArgs)

run: build
	swift run $(swiftArgs)

build-rel:
	swift build -c=release $(swiftArgs)

run-rel: build-rel
	swift run -c=release $(swiftArgs)
