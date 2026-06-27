//
//  UserResponse.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Foundation

// MARK: - User

struct User: Codable, Identifiable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let phone: String
    let age: Int
    let gender: Gender
    let birthDate: String       // "yyyy-MM-dd" — see `birthDateValue`
    let avatarURL: URL
    let bio: String
    let balance: Double
    let currency: String
    let premium: Bool
    let verified: Bool
    let tags: [String]
    let address: Address
    let preferences: Preferences
    let metadata: UserMetadata
    let scores: Scores
    let createdAt: Date
    let updatedAt: Date?
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case email
        case phone
        case age
        case gender
        case birthDate = "birth_date"
        case avatarURL = "avatar_url"
        case bio
        case balance
        case currency
        case premium
        case verified
        case tags
        case address
        case preferences
        case metadata
        case scores
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

    var fullName: String { "\(firstName) \(lastName)" }

    
    var birthDateValue: Date? {
        User.birthDateFormatter.date(from: birthDate)
    }

    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}

// MARK: - Gender

enum Gender: Hashable, Codable {
    case male
    case female
    case other(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw.lowercased() {
        case "male": self = .male
        case "female": self = .female
        default: self = .other(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .male: try container.encode("male")
        case .female: try container.encode("female")
        case .other(let raw): try container.encode(raw)
        }
    }
}

// MARK: - Address

struct Address: Codable, Hashable {
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    let coordinates: Coordinates

    enum CodingKeys: String, CodingKey {
        case street, city, state, country, coordinates
        case postalCode = "postal_code"
    }
}

struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Preferences

struct Preferences: Codable, Hashable {
    let language: String
    let theme: Theme
    let timezone: String
    let notifications: NotificationSettings
    let privacy: PrivacySettings
}

enum Theme: Hashable, Codable {
    case light, dark, auto
    case other(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw.lowercased() {
        case "light": self = .light
        case "dark": self = .dark
        case "auto": self = .auto
        default: self = .other(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .light: try container.encode("light")
        case .dark: try container.encode("dark")
        case .auto: try container.encode("auto")
        case .other(let raw): try container.encode(raw)
        }
    }
}

struct NotificationSettings: Codable, Hashable {
    let email: Bool
    let push: Bool
    let sms: Bool
    let inApp: Bool

    enum CodingKeys: String, CodingKey {
        case email, push, sms
        case inApp = "in_app"
    }
}

struct PrivacySettings: Codable, Hashable {
    let profileVisible: Bool
    let showEmail: Bool
    let showPhone: Bool
    let allowIndexing: Bool

    enum CodingKeys: String, CodingKey {
        case profileVisible = "profile_visible"
        case showEmail = "show_email"
        case showPhone = "show_phone"
        case allowIndexing = "allow_indexing"
    }
}

// MARK: - Metadata

struct UserMetadata: Codable, Hashable {
    let lastLogin: Date?
    let loginCount: Int
    let failedAttempts: Int
    let referralCode: String
    let referredBy: UUID?
    let subscriptionTier: SubscriptionTier
    let featuresEnabled: [String]

    enum CodingKeys: String, CodingKey {
        case lastLogin = "last_login"
        case loginCount = "login_count"
        case failedAttempts = "failed_attempts"
        case referralCode = "referral_code"
        case referredBy = "referred_by"
        case subscriptionTier = "subscription_tier"
        case featuresEnabled = "features_enabled"
    }
}

enum SubscriptionTier: Hashable, Codable {
    case free, basic, pro, enterprise
    case other(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw.lowercased() {
        case "free": self = .free
        case "basic": self = .basic
        case "pro": self = .pro
        case "enterprise": self = .enterprise
        default: self = .other(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .free: try container.encode("free")
        case .basic: try container.encode("basic")
        case .pro: try container.encode("pro")
        case .enterprise: try container.encode("enterprise")
        case .other(let raw): try container.encode(raw)
        }
    }
}

// MARK: - Scores

struct Scores: Codable, Hashable {
    let activity: Double
    let engagement: Double
    let reliability: Double
    let trust: Double
}
