//
//  UsersListViewModel.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Combine
import Foundation

@MainActor
final class UsersListViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    /// `private(set)` so only this view model mutates state — the
    /// `$users`/`$state` publishers (Combine synthesizes these regardless
    /// of the setter's access level) are still externally subscribable,
    /// which is exactly what the view controller needs.
    @Published private(set) var users: [User] = []
    @Published private(set) var state: State = .idle

    private let userService: UserServicing
    private let userStore: UserStoring
    private var searchTask: Task<Void, Never>?

    init(userService: UserServicing, userStore: UserStoring) {
        self.userService = userService
        self.userStore = userStore
    }

    /// Call once when the screen appears. Shows whatever's cached
    /// immediately (instant list on a cold launch with no network), then
    /// refreshes from the network and re-renders once that lands.
    func start() async {
        await loadFromCache()
        await refresh()
    }

    /// Re-fetches from the network and upserts into the store. Safe to
    /// call again later for a pull-to-refresh without needing separate
    /// wiring.
    func refresh() async {
        if users.isEmpty { state = .loading }
        do {
            let fetched = try await userService.fetchUsers()
            try await userStore.upsert(fetched)
            users = try await userStore.fetchAll()
            state = .loaded
        } catch {
            // If we already have something on screen (from cache or a
            // previous successful fetch), a failed refresh shouldn't blank
            // the list — just leave it and only surface the error when
            // there's truly nothing to show.
            if users.isEmpty {
                state = .error(Self.message(for: error))
            }
        }
    }

    /// Debounced so fast typing doesn't fire a Core Data fetch per
    /// keystroke. Cancels any in-flight search before starting a new one.
    func updateSearch(_ query: String) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled, let self else { return }
            await self.performSearch(query)
        }
    }

    private func loadFromCache() async {
        // A cache-read failure isn't fatal — it just means we fall through
        // to whatever `refresh()` does next, the same as a cold launch.
        if let cached = try? await userStore.fetchAll(), !cached.isEmpty {
            users = cached
            state = .loaded
        }
    }

    private func performSearch(_ query: String) async {
        // Leave the list as-is on a search failure rather than blanking it.
        if let results = try? await userStore.search(query) {
            users = results
        }
    }

    private static func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}
