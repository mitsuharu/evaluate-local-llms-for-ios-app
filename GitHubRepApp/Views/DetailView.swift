import SwiftUI
import SafariServices

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel

    init(repository: Repository) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(repository: repository))
    }

    @State private var showBrowser = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                statsSection
                infoSection
            }
            .padding()
        }
        .navigationTitle(viewModel.repository.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showBrowser = true
                } label: {
                    Image(systemName: "safari")
                }
            }
        }
        .sheet(isPresented: $showBrowser) {
            SafariViewer(url: viewModel.repository.htmlUrl)
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: viewModel.repository.owner.avatarUrl) { phase in
                switch phase {
                case .empty, .failure:
                    placeholderImage
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .empty:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.repository.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("@\(viewModel.repository.owner.login)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var placeholderImage: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 64, height: 64)
            .overlay(
                Image(systemName: "person.crop.square")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            )
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(title: "Star", value: viewModel.formattedStarCount, icon: "star.fill", color: .yellow)
            StatItem(title: "Watcher", value: viewModel.formattedWatcherCount, icon: "eye.fill", color: .blue)
            StatItem(title: "Fork", value: viewModel.formattedForkCount, icon: "arrow.left.arrow.right", color: .mint)
            StatItem(title: "Issue", value: viewModel.formattedIssueCount, icon: "exclamationmark.circle.fill", color: .orange)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let language = viewModel.repository.language {
                InfoRow(title: "言語", value: language)
            }

            if let description = viewModel.repository.description {
                InfoRow(title: "説明", value: description, isMultiline: true)
            }

            InfoRow(title: "オーナー", value: "@\(viewModel.repository.owner.login)")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Components

private struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .lineLimit(isMultiline ? 5 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Safari Viewer

private struct SafariViewer: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_: SFSafariViewController, context: Context) {}
}
