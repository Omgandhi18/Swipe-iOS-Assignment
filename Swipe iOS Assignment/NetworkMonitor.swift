//
//  NetworkMonitor.swift
//  Swipe iOS Assignment
//
//  Created by Om Gandhi on 29/01/2025.
//


import Network
import SwiftUI

class NetworkManager: ObservableObject {
    static let shared = NetworkManager() // Singleton instance

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected: Bool = false
    
    var onStatusChange: ((Bool) -> Void)?  // Callback for network status changes

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let status = path.status == .satisfied
                if self?.isConnected != status {
                    self?.isConnected = status
                    self?.onStatusChange?(status) // Notify observers
                    print("Network status changed: \(status ? "Connected" : "Disconnected")")
                }
            }
        }
        monitor.start(queue: queue)
    }
}


extension Notification.Name {
    static let internetConnected = Notification.Name("internetConnected")
}
