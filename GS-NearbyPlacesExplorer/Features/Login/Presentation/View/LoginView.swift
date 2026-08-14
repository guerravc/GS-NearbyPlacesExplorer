// 
//  LoginView.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import SwiftUI

/// Root SwiftUI view for the Login module.
///
/// This view owns the lifecycle of the view model using a `@State` property.
/// It renders different states (loading, error, empty, content) based on the
/// view model's `ViewState`.
struct LoginView: View {

    // MARK: - State

    /// View model driving the presentation logic for this module.
    ///
    /// The view owns the view model instance by storing it in `@State`.
    /// You can inject a custom instance for previews or testing.
    @State private var viewModel: LoginViewModel

    // MARK: - Initializers

    /// Creates a new instance of the view.
    ///
    /// - Parameter viewModel: Optional custom view model instance,
    ///   useful for previews or dependency injection in tests.
    init(viewModel: LoginViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - View

    /// Main view hierarchy for the module.
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    loadingView
                case .loaded(let items) where items.isEmpty:
                    emptyView
                case .loaded(let items):
                    contentView(items: items)
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle(viewModel.title)
        }
        .task {
            await viewModel.onAppear()
        }
    }

    // MARK: - Subviews

    /// View displayed while the data is being loaded.
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// View displayed when an error occurs.
    ///
    /// - Parameter message: Error description to show to the user.
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: {
                Task {
                    await viewModel.reload()
                }
            }) {
                Text("Retry")
                    .font(.body.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.primary)
    }

    /// View displayed when there is no data to show.
    private var emptyView: some View {
        VStack(spacing: 8) {
            Text("No data available")
                .font(.body)
            Text("Try again later or pull to refresh.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Main content view when there is data available.
    private func contentView(items: [LoginModel]) -> some View {
        List(items) { item in
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.reload()
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: LoginViewModel())
}
