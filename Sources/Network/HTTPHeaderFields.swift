//
//  HTTPHeaderFields.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public struct HTTPHeaderField {
    let name: String
    let value: String?
}

public struct HTTPHeaderFields {
    private var fields: [HTTPHeaderField]
    
    public init(fields: [HTTPHeaderField] = []) {
        self.fields = fields
    }
    
    public func toDictionary() -> [String: String] {
        var dictionary = [String: String]()
        fields.forEach { field in
            if let value = field.value {
                dictionary[field.name] = value
            }
        }
        return dictionary
    }
    
    public static func defaultHeaders() -> HTTPHeaderFields {
        return HTTPHeaderFields(fields: [HTTPHeaderField(name: "Content-Type", value: HTTPContentType.applicationJSON.rawValue)])
    }
}
