//
//  HTTPRequest.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public protocol HTTPRequest: Sendable {
    associatedtype Response: Decodable & Sendable
    associatedtype Body: Encodable & Sendable = Never

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: Body? { get }

    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }

    func decode(_ data: Data, response: HTTPURLResponse) throws -> Response
}

public extension HTTPRequest {
    var method: HTTPMethod { .get }

    var headers: [String: String] {
        [HTTPHeader.contentType.rawValue: HTTPContentType.json.rawValue]
    }

    var queryItems: [URLQueryItem] { [] }

    var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }

    var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }

    func decode(_ data: Data, response: HTTPURLResponse) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}

// Body == Never означает "у запроса нет тела" — без EmptyParameters-костыля.
public extension HTTPRequest where Body == Never {
    var body: Never? { nil }
}
