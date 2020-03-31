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
    
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
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
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: Constants.serviceType, discoveryInfo: nil, session: self.mcSession!)
    }
    
    func setupNavigationBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.host, style: .plain, target: self, action: #selector(hostSession))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.join, style: .plain, target: self, action: #selector(joinSession))
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
        if mcSession!.connectedPeers.count > 0 {
            do {
                let data = Data(accelerometer.convertToString().utf8)
                try mcSession!.send(data, toPeers: mcSession!.connectedPeers, with: .reliable)
            } catch {
                print("Error connecting...")
            }
        }
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
            mcAdvertiserAssistant?.start()
        default:
            navigationItem.rightBarButtonItem?.title = UIConstants.host
            sessionState = .notconnected
            mcAdvertiserAssistant?.stop()
        }
    }

    @objc func joinSession() {
        guard let session = mcSession else { return }
        
        let mcBrowser = MCBrowserViewController(serviceType: Constants.serviceType, session: session)
        mcBrowser.delegate = self
        self.present(mcBrowser, animated: true, completion: nil)
    }
}

// MARK: - MCSessionDelegate

extension ViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            sessionState = .connected(peerID.displayName)
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        default:
            sessionState = .notconnected
            print("Not Connected")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        /// just for debug of sending data
        print(String(data: data, encoding: .utf8) ?? "error")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
}

// MARK: - MCBrowserViewControllerDelegate

extension ViewController: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
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
        
        static let host = "Host"
        static let stopHosting = "Stop"
        static let join = "Join"
        
        static let noOneIsAround = "No one is around"
        static let connecting = "Connecting..."
    }
}
