//
//  URLRequestBuilder.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public struct URLRequestBuilder: Sendable {
    public init() {}

    public func build<Request: HTTPRequest>(
        from request: Request
    ) throws(HTTPError) -> URLRequest {
        let url = request.baseURL.appendingPathComponent(request.path)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw .invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }

        guard let finalURL = components.url else {
            throw .invalidURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers

        if let body = request.body {
            do {
                urlRequest.httpBody = try request.encoder.encode(body)
            } catch {
                throw .encoding(String(describing: error))
            }
        }

        return urlRequest
    }
}
