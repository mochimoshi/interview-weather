//
//  URLSession+Request.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/14/23.
//

import Foundation

extension URLSession {
    
    func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
