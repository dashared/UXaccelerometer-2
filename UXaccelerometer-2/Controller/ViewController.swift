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

class ViewController: UIViewController {
    
    // MARK: - IBAOutlets
    
    @IBOutlet weak var sessionLabel: UILabel? {
        didSet {
            sessionLabel?.text = UIConstants.noOneIsAround
        }
    }
    
    @IBOutlet weak var sessionButton: UIButton? {
        didSet {
            sessionButton?.titleLabel?.text = UIConstants.tapToStart
        }
    }
    
    // MARK: - Properties
    
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    var sessionState: SessionState = .notconnected {
        didSet {
            setupState()
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupSession()
        setupNavigationBar()
        setupState()
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
        case .hosting:
            sessionLabel?.text = UIConstants.connecting
        case .connected(let name):
            sessionLabel?.text = "Connected to \(name)"
            sessionButton?.isHidden = false
            sessionButton?.titleLabel?.text = UIConstants.tapToStart
        case .started(_):
            sessionButton?.titleLabel?.text = UIConstants.tapToStop
        }
    }
    
    /// TODO: - Add logic
    @IBAction func controlSession(_ sender: UIButton) {
        
        
        switch sessionState {
        case .started(let name):
            sessionState = .connected(name)
            // add
        case .connected(let name):
            sessionState = .started(name)
            // add
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
