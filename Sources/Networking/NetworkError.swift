//
//  NetworkError.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public enum HTTPError: Error, Sendable {
    case invalidURL
    case transport(URLError)
    case unauthorized(Data)
    case forbidden(Data)
    case notFound(Data)
    case timeout(Data?)
    case http(statusCode: Int, data: Data)
    case decoding(String)
    case encoding(String)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:                 "Invalid URL."
        case .transport(let e):           "Transport error: \(e.localizedDescription)"
        case .unauthorized:               "Unauthorized (401)."
        case .forbidden:                  "Forbidden (403)."
        case .notFound:                   "Not found (404)."
        case .timeout:                    "Request timed out."
        case .http(let code, _):          "HTTP \(code)."
        case .decoding(let description):  "Decoding failed: \(description)"
        case .encoding(let description):  "Encoding failed: \(description)"
        }
    }
}
