//
//  SnapshotJSON.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 08/09/2026.
//

import Foundation

enum SnapshotJSON {
    static func encode<T: Encodable>(_ value: T)throws -> Data {
        let encoder = JSONEncoder();
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(value)
    }
    static func decode<T: Decodable>(_ type: T.Type, from data: Data)throws -> T {
        let decoder = JSONDecoder();
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode(type, from: data)
        
    }
}
