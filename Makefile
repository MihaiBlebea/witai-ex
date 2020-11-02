release: test build publish 

test:
	mix test

build:
	mix build

publish:
	mix hex.publish