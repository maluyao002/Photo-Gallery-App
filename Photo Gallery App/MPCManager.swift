//
//  MPCManager.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/26/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(_ fromPeer: String)
    
    func connectedWithPeer(_ peerID: MCPeerID)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc")
        advertiser.delegate = self
    }
    
    
    // MARK: MCNearbyServiceBrowserDelegate method implementation
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated(){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        
        delegate?.lostPeer()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    
    // MARK: MCNearbyServiceAdvertiserDelegate method implementation
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: (@escaping (Bool, MCSession) -> Void)) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    
    // MARK: MCSessionDelegate method implementation
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID)
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "receivedMPCDataNotification"), object: dictionary)
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    
    
    // MARK: Custom method implementation
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = NSArray(object: targetPeer)
        var error: NSError?
        
        do {
            try session.send(dataToSend, toPeers: peersArray as [AnyObject] as [AnyObject] as! [MCPeerID], with: MCSessionSendDataMode.reliable)
        } catch var error1 as NSError {
            error = error1
            print(error?.localizedDescription)
            return false
        }
        
        return true
    }
    
    func sendImage(dictionaryWithData dictionary: Dictionary<String, Data>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = NSArray(object: targetPeer)
        var error: NSError?
        
        do {
            try session.send(dataToSend, toPeers: peersArray as [AnyObject] as [AnyObject] as! [MCPeerID], with: MCSessionSendDataMode.reliable)
        } catch var error1 as NSError {
            error = error1
            print(error?.localizedDescription)
            return false
        }
        
        return true
    }
    
    

}
