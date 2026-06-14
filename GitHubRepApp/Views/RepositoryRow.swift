import SwiftUI

struct RepositoryRow: View {
    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(repository.fullName)
                .font(.headline)
                .lineLimit(1)

            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 16) {
                if let language = repository.language {
                    Label(language, systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Label("\(formattedCount(repository.stargazersCount))", systemImage: "star")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label("\(formattedCount(repository.forksCount))", systemImage: "arrow.left.arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedCount(_ count: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal)
    }
}
