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
        VStack(alignment: .leading, spacing: 16) {
            // Header: Icon, Name, Version, Copyright
            HStack(alignment: .top, spacing: 60) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .cornerRadius(12)
                    .shadow(color: .brown, radius: 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Kopniak")
                        .font(.largeTitle)

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

                Spacer()
            }
            .padding()

            Divider()

            // Libraries Section Title and Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Third Party Licenses")
                    .font(.title2)

                Text(
                    "These are the licenses of open source projects shipped with Kopniak."
                )
                .font(.body)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Libraries List
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(store.libraries, id: \.name) { library in
                        HStack {
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
            }
        }
        .padding(20)
        .frame(width: 500, height: 500)
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
