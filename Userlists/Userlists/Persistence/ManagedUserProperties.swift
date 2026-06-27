//
//  ManagedUserProperties.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import CoreData
import Foundation

extension ManagedUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedUser> {
        NSFetchRequest<ManagedUser>(entityName: "ManagedUser")
    }

    @NSManaged public var id: UUID
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var username: String
    @NSManaged public var email: String
    @NSManaged public var phone: String
    @NSManaged public var avatarURL: String
    @NSManaged public var age: Int32
    @NSManaged public var balance: Double
    @NSManaged public var currency: String
    @NSManaged public var premium: Bool
    @NSManaged public var verified: Bool
    @NSManaged public var city: String
    @NSManaged public var country: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date?
    /// Full `User` re-encoded via `JSONEncoder.usersEncoder` — see
    /// `ManagedUser+Mapping.swift`. Everything not promoted to its own
    /// attribute above (address detail, preferences, metadata, scores,
    /// tags) lives only in here.
    @NSManaged public var payload: Data
}

extension ManagedUser: Identifiable {}
