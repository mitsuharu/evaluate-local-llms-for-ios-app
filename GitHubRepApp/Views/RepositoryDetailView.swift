//
//  RepositoryDetailView.swift
//  GitHubRepApp
//

import SwiftUI

/// 選択されたリポジトリの詳細画面。
struct RepositoryDetailView: View {
    let repository: Repository

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ownerHeader

                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                statsGrid

                if let url = repository.htmlURL {
                    Link(destination: url) {
                        Label("GitHub で開く", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle(repository.fullName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var ownerHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: repository.owner.avatarURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .accessibilityLabel(Text("\(repository.owner.login) のアイコン"))

            Text(repository.fullName)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("@\(repository.owner.login)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            statCell(title: "主要言語", value: repository.language ?? "—", icon: "chevron.left.forwardslash.chevron.right")
            statCell(title: "Star", value: "\(repository.stargazersCount)", icon: "star.fill")
            statCell(title: "Watcher", value: "\(repository.watchersCount)", icon: "eye.fill")
            statCell(title: "Fork", value: "\(repository.forksCount)", icon: "tuningfork")
            statCell(title: "Issue", value: "\(repository.openIssuesCount)", icon: "exclamationmark.circle.fill")
        }
    }

    private func statCell(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title) \(value)"))
    }
}
