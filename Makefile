all: osx chrome

osx.watch:
	$(MAKE) -C ./front -B osx.watch
osx:
	$(MAKE) -C ./front -B osx
	$(MAKE) -C ./widget -B release

chrome:
	$(MAKE) -C ./front -B chrome
	crx pack ./chrome_extension -o dist/GithubPulse.crx -p ./resources/GithubPulse.pem

.PHONY: osx chrome all osx.watch
