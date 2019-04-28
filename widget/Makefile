release: archive export zip clean
	mv GithubPulse.zip ../dist

clean:
	rm -rf GithubPulse.app GithubPulse.xcarchive

zip:
	zip -r GithubPulse.zip GithubPulse.app

archive:
	xcodebuild archive -workspace GithubPulse.xcworkspace -scheme GithubPulse -archivePath GithubPulse

export:
	xcodebuild -exportArchive -archivePath GithubPulse.xcarchive -exportPath GithubPulse.app -exportOptionsPlist exportOptions.plist
