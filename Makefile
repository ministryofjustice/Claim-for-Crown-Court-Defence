bx=bundle exec

default: help

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"

rspec: #: run all or focused specs
	${bx} rspec
pspec: #: run all specs in parallel
	${bx} rake parallel:spec
cuke: #: run cucumber features tagged with @focus
	${bx} cucumber --tag @focus
jasmine: #: run jasmine specs
	${bx} npx jasmine-browser-runner runSpecs
rlint: #: run rubocop
	rubocop
jslint: #: lint javascript
	yarn run validate:js
scsslint: #: lint scss
	yarn run validate:scss
lint: rlint jslint scsslint #: run all linters
