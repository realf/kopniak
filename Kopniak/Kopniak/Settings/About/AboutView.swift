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
                .frame(minHeight: 150)
            }

            Spacer()
        }
    }
}

private struct Header: View {
    var body: some View {
        // Header: Icon, Name, Version, Copyright
        HStack(alignment: .top, spacing: 40) {
            Image("Kopniak1")
                .interpolation(.high)
                .resizable()
                .frame(width: 100, height: 100)
                .scaledToFit()
                .cornerRadius(20)
                .shadow(color: .brown, radius: 10)

            VStack(alignment: .leading, spacing: 8) {
                Text("Kopniak")
                    .font(.largeTitle)
                Text(
                    """
                    Kopniak is an app being made by an indie developer [realf](https://github.com/realf/).
                    If you have any suggestions or issues, feel free to contact me on [GitHub](https://github.com/realf/kopniak/issues).
                    If you like Kopniak, please rate it on [AppStore](https://apps.apple.com/us/app/kopniak/id6754943310) - it helps other users to find it.
                    """
                )
                Text(
                    "Thanks to Olena for her valuable contributions, and to my family for their continuous support."
                )
                Text("Special thanks to \(NSFullUserName()) ❤️")

                let shortVersion =
                    Bundle.main.infoDictionary?[
                        "CFBundleShortVersionString"
                    ] as? String ?? "1.0"
                let buildVersion =
                    Bundle.main.infoDictionary?["CFBundleVersion"]
                    as? String ?? "1"
                Text("Version \(shortVersion) (\(buildVersion))")
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("© 2025 Serhii Dunets")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 200)
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
        .frame(height: 80)
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
