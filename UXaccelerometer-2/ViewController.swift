//
//  ViewController.swift
//  UXaccelerometer-2
//
//  Created by cstore on 27/03/2020.
//  Copyright © 2020 dasharedd. All rights reserved.
//

import UIKit
import MultipeerConnectivity


enum SessionState {
    case notconnected
    case connected(String)
    case hosting
    case started(String)
}

class ViewController: UIViewController, DataTransfer {
    
    // MARK: - IBAOutlets
    
    @IBOutlet weak var sessionLabel: UILabel? {
        didSet {
            sessionLabel?.text = UIConstants.noOneIsAround
        }
    }
    
    @IBOutlet weak var sessionButton: UIButton? {
        didSet {
            sessionButton?.layer.cornerRadius = 10
            sessionButton?.setTitle(UIConstants.tapToStart, for: .normal)
        }
    }
    
    @IBOutlet weak var coordinatesStack: UIStackView?
    
    @IBOutlet weak var xLabel: UILabel?
    
    @IBOutlet weak var yLabel: UILabel?
    
    @IBOutlet weak var zLabel: UILabel?
    
    // MARK: - Properties
    
    var accelerometer = Accelerometer.shared
    
    var sessionState: SessionState = .notconnected {
        didSet {
            DispatchQueue.main.async {
                self.setupState()
            }
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupSession()
        setupNavigationBar()
        setupState()
        accelerometer.controller = self
    }
    
    // MARK: - Setup
    
    func setupSession() {
        
        SocketIOManager.shared.socket.on(clientEvent: .connect) { (data, ask) in
            self.sessionState = .connected(String(describing: data))
        }
        
        SocketIOManager.shared.socket.on(clientEvent: .disconnect) { (data, ask) in
            self.sessionState = .notconnected
        }
    }
    
    func setupNavigationBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.host, style: .plain, target: self, action: #selector(hostSession))
        
    }
    
    func setupState() {
        
        switch sessionState {
            
        case .notconnected:
            sessionLabel?.text = UIConstants.noOneIsAround
            sessionButton?.isHidden = true
            coordinatesStack?.isHidden = true
            accelerometer.stopAccelerometer()
        case .hosting:
            sessionLabel?.text = UIConstants.connecting
        case .connected(let name):
            sessionLabel?.text = "Connected to \(name)"
            sessionButton?.isHidden = false
            coordinatesStack?.isHidden = false
            sessionButton?.setTitle(UIConstants.tapToStart, for: .normal)
        case .started(_):
            sessionButton?.setTitle(UIConstants.tapToStop, for: .normal)
        }
    }
    
    func sendCoordinates() {
    
        SocketIOManager.shared.socket.emit("coordinates", [accelerometer.x, accelerometer.y, accelerometer.z])
       
        updateLabels()
    }
    
    func updateLabels() {
        xLabel?.text = "x = \(accelerometer.x)"
        yLabel?.text = "y = \(accelerometer.y)"
        zLabel?.text = "z = \(accelerometer.z)"
    }
    
    @IBAction func controlSession(_ sender: UIButton) {
        
        
        switch sessionState {
        case .started(let name):
            sessionState = .connected(name)
            accelerometer.stopAccelerometer()
        case .connected(let name):
            sessionState = .started(name)
            accelerometer.startAccelerometers()
        default:
            print("WTF")
        }
        
    }
    

    
    // MARK: - Join/host
    
    /// Switch button state
    @objc func hostSession() {
        
        switch sessionState {
            
        case .notconnected:
            navigationItem.rightBarButtonItem?.title = UIConstants.stopHosting
            sessionState = .hosting
            SocketIOManager.shared.establichConnection()
        default:
            navigationItem.rightBarButtonItem?.title = UIConstants.host
            sessionState = .notconnected
            SocketIOManager.shared.closeConnection()
        }
    }

}


// MARK: - Constants

extension ViewController {
    
    enum Constants {
        static let serviceType = "ba-td"
    }
    
    enum UIConstants {
        static let tapToStart = "Tap to start"
        static let tapToStop = "Tap to stop"
        
        static let host = "Connect"
        static let stopHosting = "Stop"
        
        static let noOneIsAround = "No one is around"
        static let connecting = "Connecting..."
    }
}
