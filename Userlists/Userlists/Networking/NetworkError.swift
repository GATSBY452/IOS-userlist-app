//
//  NetworkError.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(message: String)
    case transportError(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned a response we couldn't understand."
        case .httpError(let statusCode):
            return "The server returned an error (HTTP \(statusCode))."
        case .decodingFailed(let message):
            return "The data couldn't be read: \(message)"
        case .transportError(let message):
            return "Couldn't reach the server: \(message)"
        }
    }

    // Equatable conformance for unit tests — compares case + associated
    // values, ignoring the wrapped Error's own (non-Equatable) identity.
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse):
            return true
        case (.httpError(let a), .httpError(let b)):
            return a == b
        case (.decodingFailed(let a), .decodingFailed(let b)):
            return a == b
        case (.transportError(let a), .transportError(let b)):
            return a == b
        default:
            return false
        }
    }
}
