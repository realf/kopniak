//
//  AboutView.swift
//  Kopniak
//
//  Created by alf on 04.11.2025.
//

import ComposableArchitecture
import SwiftUI

struct AboutView: View {
    let store: StoreOf<AboutFeature>

    var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .leading) {
                Header()
                Divider()
                LibrariesHeader()

                // Libraries List
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(store.libraries, id: \.name) { library in
                            Library(library: library)
                        }
                    }
                }
            }

            Spacer()
        }
    }
}

private struct Header: View {
    var mailtoLink: some View {
        let emailBody = "Please describe your issue below:"
        let mailto =
            "mailto:dunets.devel@gmail.com?subject=Kopniak \(version)&body=\(emailBody)"
        return Link(
            "Contact Me",
            destination: URL(string: mailto)!
        )
        .buttonStyle(.bordered)
    }

    let shortVersion =
        Bundle.main.infoDictionary?[
            "CFBundleShortVersionString"
        ] as? String ?? "1.0"

    let buildVersion =
        Bundle.main.infoDictionary?["CFBundleVersion"]
        as? String ?? "1"

    var version: String {
        "Version \(shortVersion) (\(buildVersion))"
    }

    var body: some View {
        // Header: Icon, Name, Version, Copyright
        HStack(alignment: .top, spacing: 20) {
            Image("Icon")
                .interpolation(.high)
                .resizable()
                .frame(width: 100, height: 100)
                .scaledToFit()
                .cornerRadius(20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Kopniak")
                    .font(.largeTitle)
                Text("This app is made by an independent developer.")
                Text(
                    "Learn more at https://realf.github.io/kopniak/."
                )
                Text(
                    "If you like the app, please rate it on [AppStore](https://apps.apple.com/us/app/kopniak/id6754943310)."
                )
                Text("Thanks to Olena for her valuable contributions.")
                Text("Thank you to my family for their continuous support.")
                Text("Special thanks to \(NSFullUserName()) ❤️")

                mailtoLink

                Text(version)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("© 2025 Serhii Dunets")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Libraries Section Title and Description
private struct LibrariesHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Third Party Licenses")
                .font(.title2)

            Text(
                "These are the licenses of open source projects shipped with Kopniak. Thank you to all the contributors."
            )
            .foregroundColor(.secondary)
        }
    }
}

private struct Library: View {
    var library: LibraryInfo

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Link(
                    library.name,
                    destination: library.repositoryURL
                )
                .font(.title3)
                .foregroundColor(.primary)

                Text(library.version)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Link(
                library.licenseType,
                destination: library.licenseURL
            )
            .font(.body)
            .foregroundColor(.blue)
        }
    }
}

#Preview {
    AboutView(
        store: Store(
            initialState: AboutFeature.State(),
            reducer: { AboutFeature() }
        )
    )
}

#Preview("Header") {
    Header()
}

#Preview("LibrariesHeader") {
    LibrariesHeader()
}

#Preview("Library") {
    Library(
        library: LibraryInfo(
            name: "The Composable Library",
            version: "1.2.3",
            licenseType: "MIT",
            repositoryURL: URL(string: "http://example.com")!,
            licenseURL: URL(string: "http://example.com")!
        )
    )
}
