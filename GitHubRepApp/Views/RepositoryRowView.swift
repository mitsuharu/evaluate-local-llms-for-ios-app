//
//  RepositoryRowView.swift
//  GitHubRepApp
//

import SwiftUI

/// 検索結果一覧の各行。
struct RepositoryRowView: View {
    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(repository.fullName)
                .font(.headline)
                .lineLimit(2)

            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                if let language = repository.language {
                    Label(language, systemImage: "chevron.left.forwardslash.chevron.right")
                        .labelStyle(.titleAndIcon)
                }
                Label("\(repository.stargazersCount)", systemImage: "star.fill")
                Label("\(repository.forksCount)", systemImage: "tuningfork")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityDescription))
    }

    private var accessibilityDescription: String {
        var parts: [String] = [repository.fullName]
        if let language = repository.language {
            parts.append("言語 \(language)")
        }
        parts.append("Star \(repository.stargazersCount)")
        parts.append("Fork \(repository.forksCount)")
        return parts.joined(separator: ", ")
    }
}
