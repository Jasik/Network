//
//  URLRequest+Extension.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public extension URLRequest {
    mutating func setHTTPBody<Body: Encodable>(from body: Body?) {
        guard let body = body else { return }
        self.httpBody = try? JSONEncoder().encode(body)
    }
}
