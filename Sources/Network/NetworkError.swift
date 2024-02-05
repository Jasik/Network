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
    case parseError(Error)
    case networkError(Error)
    case badHTTPStatus(Int)
}
