//
//  SnapshotViewModel.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import Foundation
import Combine

@MainActor
final class SnapshotViewModel: ObservableObject {
    @Published private(set) var snapshot: SystemSnapshot?
    @Published private(set) var errorMessage: String?
    
    private let provider: any SystemInfoProviding
    
    init(provider: any SystemInfoProviding){
        self.provider = provider;
    }
    func loadIfNeeded(){
        guard snapshot == nil else { return }
        refreshSnapshot();
    }
    
    func refreshSnapshot() {
        do {
            let newSnapshot = try provider.captureSnapshot()
            snapshot = newSnapshot
            errorMessage = nil
        }
        catch {
            errorMessage = """
                Refresh failed. \(error.localizedDescription)
                """
        }
        
    }
    
}
