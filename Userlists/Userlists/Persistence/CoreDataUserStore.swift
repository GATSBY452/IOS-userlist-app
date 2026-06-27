//
//  CoreDataUserStore.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import CoreData
import Foundation

/// Abstraction the view model talks to, mirroring `UserServicing` from the
/// networking layer. Keeps `CoreData` import out of anything above this
/// layer, and gives tests a seam to inject an in-memory store instead of
/// stubbing Core Data directly at every call site.
protocol UserStoring {
    /// Inserts new users and updates existing ones, matched by `id`.
    /// Deliberately does **not** delete local users missing from `users` —
    /// the brief doesn't ask for sync-deletes, so a partial/failed refresh
    /// can't silently wipe out previously saved data.
    func upsert(_ users: [User]) async throws
    func fetchAll() async throws -> [User]
    func search(_ query: String) async throws -> [User]
}

final class CoreDataUserStore: UserStoring {
    private let persistence: PersistenceController

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    func upsert(_ users: [User]) async throws {
        guard !users.isEmpty else { return }
        let context = persistence.newBackgroundContext()

        try await context.perform {
            // One fetch for every existing match, not one fetch per
            // incoming user — 192 records is small either way, but this
            // keeps the cost flat as that number grows.
            let ids = users.map(\.id)
            let request = ManagedUser.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids)
            let existing = try context.fetch(request)
            var existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

            for user in users {
                if let managed = existingByID[user.id] {
                    try managed.update(from: user)
                } else {
                    let managed = ManagedUser(context: context)
                    try managed.update(from: user)
                    existingByID[user.id] = managed
                }
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    func fetchAll() async throws -> [User] {
        let context = persistence.viewContext
        return try await context.perform {
            let request = ManagedUser.fetchRequest()
            request.sortDescriptors = Self.defaultSort
            return try context.fetch(request).compactMap(\.asDomainUser)
        }
    }

    func search(_ query: String) async throws -> [User] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return try await fetchAll() }

        let context = persistence.viewContext
        return try await context.perform {
            let request = ManagedUser.fetchRequest()
            // [cd] = case- and diacritic-insensitive, so "jose" matches
            // "José" and "JOSE" alike.
            request.predicate = NSPredicate(
                format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@ OR username CONTAINS[cd] %@ OR email CONTAINS[cd] %@",
                trimmed, trimmed, trimmed, trimmed
            )
            request.sortDescriptors = Self.defaultSort
            return try context.fetch(request).compactMap(\.asDomainUser)
        }
    }

    private static let defaultSort = [
        NSSortDescriptor(key: "lastName", ascending: true),
        NSSortDescriptor(key: "firstName", ascending: true)
    ]
}
