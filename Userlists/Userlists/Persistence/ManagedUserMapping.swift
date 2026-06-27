//
//  ManagedUserMapping.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Foundation

extension ManagedUser {
    /// Copies every field from a decoded `User` into this managed object.
    ///
    /// Only the fields needed for sorting, display, and search are promoted
    /// to first-class Core Data attributes (name fields, email, city,
    /// country, a few scalars). Everything else — full address, preferences,
    /// metadata, scores, tags — gets re-encoded wholesale into `payload`
    /// rather than modeled as separate Core Data entities/relationships.
    ///
    /// That's a deliberate simplification: nothing in the brief requires
    /// querying *inside* those nested structures (e.g. "find everyone with
    /// push notifications off"), only the list + search requirement, which
    /// only touches name/username/email. If that changes, this is the file
    /// to revisit — promote whatever new field needs to be queryable.
    func update(from user: User, encoder: JSONEncoder = .usersEncoder) throws {
        id = user.id
        firstName = user.firstName
        lastName = user.lastName
        username = user.username
        email = user.email
        phone = user.phone
        avatarURL = user.avatarURL.absoluteString
        age = Int32(user.age)
        balance = user.balance
        currency = user.currency
        premium = user.premium
        verified = user.verified
        city = user.address.city
        country = user.address.country
        createdAt = user.createdAt
        updatedAt = user.updatedAt
        payload = try encoder.encode(user)
    }

    /// Reconstructs the full `User`, including everything not exposed as
    /// its own attribute. Returns `nil` rather than throwing because a
    /// failed decode here means stored data is corrupt, not that the
    /// caller passed something wrong — callers filter with `compactMap`.
    var asDomainUser: User? {
        try? JSONDecoder.usersDecoder.decode(User.self, from: payload)
    }
}
