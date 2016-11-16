build:
	gem build active_couch.gemspec

install: build
	gem install *.gem
