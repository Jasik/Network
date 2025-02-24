//
//  NetworkError.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public enum HTTPError: Error {
    case invalidRequest
    case failedConnect
    case networkError(Error)
    
    case unauthorized(response: HTTPURLResponse, data: Data?)
    case forbidden(response: HTTPURLResponse, data: Data?)
    case timeout(response: HTTPURLResponse?, data: Data?)
    case badHTTPStatus(response: HTTPURLResponse, data: Data?)
    
    case parseError(Error)
    case serializationError(Error)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request."
        case .failedConnect:
            return "Failed to connect to the server."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized(let response, _):
            return "Unauthorized (HTTP \(response.statusCode))."
        case .forbidden(let response, _):
            return "Forbidden (HTTP \(response.statusCode))."
        case .timeout(let response, _):
            if let response = response {
                return "Request timed out (HTTP \(response.statusCode))."
            }
            return "Request timed out."
        case .badHTTPStatus(let response, _):
            return "Bad HTTP status code: \(response.statusCode)."
        case .parseError(let error):
            return "Parse error: \(error.localizedDescription)"
        case .serializationError(let error):
            return "Serialization error: \(error.localizedDescription)"
        }
    }
}
