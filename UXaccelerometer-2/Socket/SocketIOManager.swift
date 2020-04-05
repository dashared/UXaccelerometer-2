//
//  SocketIOManager.swift
//  UXaccelerometer-2
//
//  Created by cstore on 03/04/2020.
//  Copyright © 2020 dasharedd. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager {
    
    // MARK: - Porperties
    
    static let shared = SocketIOManager()

    private let manager = SocketManager(socketURL: URL(string: "http://cstore-a53b371c.localhost.run")!, config: [.log(true), .compress])
    
    var socket: SocketIOClient
    
    // MARK: - Init
    
    private init() {
        socket = manager.defaultSocket
    }
    
    // MARK: - Connection
    
    func establichConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}
