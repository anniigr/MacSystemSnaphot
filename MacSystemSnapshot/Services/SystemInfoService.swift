//
//  SystemInfoService.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import Foundation
import Darwin

struct SystemInfoService: SystemInfoProviding {
    func captureSnapshot() throws -> SystemSnapshot {
        
        let processInfo = ProcessInfo.processInfo;
        
        let activeProccessorCount = processInfo.activeProcessorCount
        
        let deviceName : String
        let name = Host.current().localizedName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let name = name, name.isEmpty { deviceName = "Unknown Mac"}
        else { deviceName = name! }
        
        let macOSVersion = processInfo.operatingSystemVersion
        let macOSVersionString = "\(macOSVersion.majorVersion)." + "\(macOSVersion.minorVersion)." + "\(macOSVersion.patchVersion)"
        
        let processorArchitecture = try readProcessorArchitecture()
        let disk = try readDiskSpace();
        let physicalMemoryBytes = processInfo.physicalMemory
        
        
        
        
        
        return SystemSnapshot(
            id: UUID(),
            capturedAt: Date(),
            
            activeProccessorCount: activeProccessorCount,
            deviceName: deviceName,
            macOSVersion: macOSVersionString,
            processorArchitecture: processorArchitecture,
            
            physicalMemoryBytes: physicalMemoryBytes,
            totalDiskBytes: disk.total,
            availableDiskBytes: disk.available
        )
    }
    
    private func readProcessorArchitecture() throws -> String {
         var supportsARM64: Int32 = 0
         var size = MemoryLayout<Int32>.size

         let result = sysctlbyname(
             "hw.optional.arm64",
             &supportsARM64,
             &size,
             nil,
             0
         )

         if result == 0 {
             switch supportsARM64 {
             case 1:
                 return "arm64"
             case 0:
                 return "x86_64"
             default:
                 throw SystemInfoError.architectureUnavailable
             }
         }

         #if arch(x86_64)
         if errno == ENOENT {
             return "x86_64"
         }
         #endif

         throw SystemInfoError.architectureUnavailable
     }

     private func readDiskSpace() throws -> (
         total: UInt64,
         available: UInt64
     ) {
         let attributes: [FileAttributeKey: Any]

         do {
             attributes = try FileManager.default.attributesOfFileSystem(
                 forPath: NSHomeDirectory()
             )
         } catch {
             throw SystemInfoError.diskReadFailed(error)
         }

         guard
             let totalNumber = attributes[.systemSize] as? NSNumber,
             let availableNumber = attributes[.systemFreeSize] as? NSNumber,
             totalNumber.int64Value > 0,
             availableNumber.int64Value >= 0
         else {
             throw SystemInfoError.invalidDiskInformation
         }

         let total = totalNumber.uint64Value
         let available = availableNumber.uint64Value

         guard available <= total else {
             throw SystemInfoError.invalidDiskInformation
         }

         return (total: total, available: available)
     }
 }
enum SystemInfoError: LocalizedError {
    case architectureUnavailable
    case diskReadFailed(any Error)
    case invalidDiskInformation

    var errorDescription: String? {
        switch self {
        case .architectureUnavailable:
            return "The processor architecture could not be determined."

        case .diskReadFailed(let underlyingError):
            return """
            Disk information could not be read. \
            \(underlyingError.localizedDescription)
            """

        case .invalidDiskInformation:
            return "macOS returned missing or inconsistent disk information."
        }
    }
}



    
