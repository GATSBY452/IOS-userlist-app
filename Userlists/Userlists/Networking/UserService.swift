//
//  UserService.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Foundation

/// Abstraction the view model talks to. The persistence step will likely
/// want a second implementation that reads from Core Data first and only
/// hits the network as a refresh — this protocol is the seam for that.
protocol UserServicing {
    func fetchUsers() async throws -> [User]
}

final class RemoteUserService: UserServicing {
    private let url: URL
    private let session: URLSessionDataTasking
    private let decoder: JSONDecoder

    init(
        url: URL = APIEndpoint.usersFeed,
        session: URLSessionDataTasking = URLSession.shared,
        decoder: JSONDecoder = .usersDecoder
    ) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }

    func fetchUsers() async throws -> [User] {
        let (data, response) = try await fetchData()
        try Self.validate(response)

        do {
            return try decoder.decode(UsersResponse.self, from: data).users
        } catch {
            throw NetworkError.decodingFailed(message: error.localizedDescription)
        }
    }

    private func fetchData() async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch {
            throw NetworkError.transportError(message: error.localizedDescription)
        }
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }
    }
}
