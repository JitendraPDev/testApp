//
//  GenericTypeResponseModel.swift
//  YellowInbox
//
//  Created by Jitendra Patidar on 05/01/22.
//

import Foundation

// Reference: https://gist.github.com/mbuchetics/c9bc6c22033014aa0c550d3b4324411a
// TODO: Unit test this enum
enum JSON: Decodable {
    case bool(Bool)
    case double(Double)
    case string(String)
    indirect case array([JSON])
    indirect case dictionary([String: JSON])

    var dictionary: [String: JSON]? {
        if case  JSON.dictionary(let dict) = self {
            return dict
        }
        return nil
    }
    
    var array: [Any]? {
        if case  JSON.array(let arr) = self {
            return arr
        }
        return nil
    }

    subscript(key: String) -> Any? {
        if case JSON.dictionary(let dict) = self {
            return dict[key]
        }
        return nil
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            self = JSON(from: container)
        } else if let container = try? decoder.unkeyedContainer() {
            self = JSON(from: container)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
    }

    private init(from container: KeyedDecodingContainer<JSONCodingKeys>) {
        let container = container
        var dict: [String: JSON] = [:]
        for key in container.allKeys {
            if let value = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = .bool(value)
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = .double(value)
            } else if let value = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = .string(value)
            } else if let value = try? container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key) {
                dict[key.stringValue] = JSON(from: value)
            } else if let value = try? container.nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = JSON(from: value)
            }
        }
        self = .dictionary(dict)
    }

    private init(from container: UnkeyedDecodingContainer) {
        var container = container
        var arr: [JSON] = []
        while !container.isAtEnd {
            if let value = try? container.decode(Bool.self) {
                arr.append(.bool(value))
            } else if let value = try? container.decode(Double.self) {
                arr.append(.double(value))
            } else if let value = try? container.decode(String.self) {
                arr.append(.string(value))
            } else if let value = try? container.nestedContainer(keyedBy: JSONCodingKeys.self) {
                arr.append(JSON(from: value))
            } else if let value = try? container.nestedUnkeyedContainer() {
                arr.append(JSON(from: value))
            }
        }
        self = .array(arr)
    }
}

private struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
