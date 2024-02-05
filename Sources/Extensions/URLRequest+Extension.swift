//
//  URLRequest+Extension.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public extension URLRequest {
    mutating func setHTTPBody(from parameter: [String: Any]?) {
        guard
            let parameter = parameter,
            let httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: [])
        else {
            return
        }
        self.httpBody = httpBody
    }
}
