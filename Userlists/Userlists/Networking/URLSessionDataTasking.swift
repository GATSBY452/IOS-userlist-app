//
//  URLSessionDataTasking.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import Foundation

protocol URLSessionDataTasking {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionDataTasking {}
