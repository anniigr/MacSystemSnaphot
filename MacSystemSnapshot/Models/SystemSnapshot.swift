//
//  SystemSnapshot.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import Foundation

struct SystemSnapshot: Codable, Identifiable,Equatable {
    let id: UUID
    let capturedAt: Date
    
    let activeProccessorCount: Int
    let deviceName: String
    let macOSVersion: String
    let processorArchitecture: String
    
    let physicalMemoryBytes: UInt64
    let totalDiskBytes: UInt64
    let availableDiskBytes: UInt64
}


