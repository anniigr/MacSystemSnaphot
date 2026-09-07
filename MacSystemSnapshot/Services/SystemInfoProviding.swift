//
//  SystemInfoProviding.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import Foundation

protocol SystemInfoProviding {
    func captureSnapshot() throws -> SystemSnapshot
}
