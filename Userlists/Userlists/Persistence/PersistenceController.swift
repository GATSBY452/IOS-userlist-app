//
//  PersistenceController.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import CoreData

/// Owns the Core Data stack for `UsersApp.xcdatamodeld`. One instance,
/// handed out via dependency injection rather than reached for as a global
/// singleton everywhere, so tests can spin up an isolated in-memory store.
final class PersistenceController {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "UserApp")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                // A failed store load means the app has no way to persist
                // or read data at all — there's nothing sensible to do but
                // stop. Crashing loudly here in development is preferable
                // to limping along and silently losing every write later;
                // replace with real error surfacing (e.g. an alert + retry,
                // or a "reset local data" escape hatch) before shipping.
                fatalError("Core Data store failed to load: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    /// A background context for write-heavy work — used by the bulk
    /// upsert after a 192-user network fetch so the main/view context
    /// (and anything reading from it for the list UI) isn't blocked.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
