// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "BoligScrapper",
    targets: [
		Target(
			name: "BoligScrapper",
			dependencies: ["BoligScrapperCore"]
		),
		Target(name: "BoligScrapperCore")
	],
    dependencies: [
		.Package(url: "https://github.com/kylef/Commander.git", "0.6.0"),
	]
)
