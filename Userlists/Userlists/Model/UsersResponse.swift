//
//  UsersResponse.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Foundation

// MARK: - Root response

struct UsersResponse: Decodable {
    let users: [User]
}

// MARK: - Decoder factory

extension JSONEncoder {
    static var usersEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

}

extension JSONDecoder {
    static var usersDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}


