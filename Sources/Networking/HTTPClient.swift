//
//  HTTPClient.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public protocol HTTPTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPTransport {}

public protocol HTTPClient: Sendable {
    func send<Request: HTTPRequest>(
        _ request: Request
    ) async throws(HTTPError) -> Request.Response
}

public struct URLSessionHTTPClient: HTTPClient {
    private let transport: any HTTPTransport
    private let builder: URLRequestBuilder

    public init(
        transport: any HTTPTransport = URLSession.shared,
        builder: URLRequestBuilder = URLRequestBuilder()
    ) {
        self.transport = transport
        self.builder = builder
    }

    public func send<Request: HTTPRequest>(
        _ request: Request
    ) async throws(HTTPError) -> Request.Response {
        let urlRequest = try builder.build(from: request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: urlRequest)
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw .timeout(nil)
        } catch let urlError as URLError {
            throw .transport(urlError)
        } catch {
            throw .transport(URLError(.unknown))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .transport(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try request.decode(data, response: httpResponse)
            } catch {
                throw .decoding(String(describing: error))
            }
        case 401: throw .unauthorized(data)
        case 403: throw .forbidden(data)
        case 404: throw .notFound(data)
        case 408: throw .timeout(data)
        default:  throw .http(statusCode: httpResponse.statusCode, data: data)
        }
    }
}
