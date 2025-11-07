//
//  AboutFeature.swift
//  Kopniak
//
//  Created by alf on 04.11.2025.
//

import ComposableArchitecture
import Foundation

struct LibraryInfo {
    let name: String
    let version: String
    let licenseType: String
    let repositoryURL: URL
    let licenseURL: URL
}

@Reducer
struct AboutFeature {
    @ObservableState
    struct State {
        let libraries: [LibraryInfo] = [
            .init(
                name: "combine-schedulers",
                version: "1.0.3",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/combine-schedulers"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/combine-schedulers/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-case-paths",
                version: "1.7.2",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-case-paths"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-case-paths/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-clocks",
                version: "1.0.6",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-clocks"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-clocks/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-collections",
                version: "1.3.0",
                licenseType: "Apache 2.0",
                repositoryURL: URL(
                    string: "https://github.com/apple/swift-collections"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/apple/swift-collections/main/LICENSE.txt"
                )!
            ),
            .init(
                name: "swift-composable-architecture",
                version: "1.23.0",
                licenseType: "MIT",
                repositoryURL: URL(
                    string:
                        "https://github.com/pointfreeco/swift-composable-architecture"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-composable-architecture/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-concurrency-extras",
                version: "1.3.2",
                licenseType: "MIT",
                repositoryURL: URL(
                    string:
                        "https://github.com/pointfreeco/swift-concurrency-extras"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-concurrency-extras/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-custom-dump",
                version: "1.3.3",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-custom-dump"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-custom-dump/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-dependencies",
                version: "1.10.0",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-dependencies"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-dependencies/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-identified-collections",
                version: "1.1.1",
                licenseType: "MIT",
                repositoryURL: URL(
                    string:
                        "https://github.com/pointfreeco/swift-identified-collections"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-identified-collections/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-navigation",
                version: "2.6.0",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-navigation"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-navigation/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-perception",
                version: "2.0.9",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-perception"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-perception/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-sharing",
                version: "2.7.4",
                licenseType: "MIT",
                repositoryURL: URL(
                    string: "https://github.com/pointfreeco/swift-sharing"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/swift-sharing/main/LICENSE"
                )!
            ),
            .init(
                name: "swift-syntax",
                version: "602.0.0",
                licenseType: "Apache 2.0",
                repositoryURL: URL(
                    string: "https://github.com/swiftlang/swift-syntax"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/swiftlang/swift-syntax/main/LICENSE.txt"
                )!
            ),
            .init(
                name: "xctest-dynamic-overlay",
                version: "1.7.0",
                licenseType: "MIT",
                repositoryURL: URL(
                    string:
                        "https://github.com/pointfreeco/xctest-dynamic-overlay"
                )!,
                licenseURL: URL(
                    string:
                        "https://raw.githubusercontent.com/pointfreeco/xctest-dynamic-overlay/main/LICENSE"
                )!
            ),
        ]
    }
}
