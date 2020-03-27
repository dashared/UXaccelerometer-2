//
//  ViewController.swift
//  UXaccelerometer-2
//
//  Created by cstore on 27/03/2020.
//  Copyright © 2020 dasharedd. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupSession()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    func setupSession() {
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: Constants.serviceType, discoveryInfo: nil, session: self.mcSession!)
    }
    
    func setupNavigationBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Host", style: .plain, target: self, action: #selector(hostSession))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(joinSession))
    }

    
    // MARK: - Join/host
    
    @objc func hostSession() {
        self.mcAdvertiserAssistant?.start()
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
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        default:
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
}
