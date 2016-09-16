//
//  PeerViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/26/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeerViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {
    
    
    @IBOutlet weak var tblPeers: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isAdvertising: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblPeers.delegate = self
        tblPeers.dataSource = self
        
        appDelegate.mpcManager.delegate = self
        
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        
        isAdvertising = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStopAdvertising(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "", message: "Change Visibility", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        var actionTitle: String
        if isAdvertising == true {
            actionTitle = "Make me invisible to others"
        }
        else{
            actionTitle = "Make me visible to others"
        }
        
        let visibilityAction: UIAlertAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default) { (alertAction) -> Void in
            if self.isAdvertising == true {
                self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
            }
            else{
                self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
            }
            
            self.isAdvertising = !self.isAdvertising
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(visibilityAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "idCellPeer")! as UITableViewCell
        
        cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[(indexPath as NSIndexPath).row] as MCPeerID
        
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, to: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    
    // MARK: MPCManagerDelegate method implementation
    
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    
    func lostPeer() {
        tblPeers.reloadData()
    }
    
    func invitationWasReceived(_ fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler(false, nil)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func connectedWithPeer(_ peerID: MCPeerID) {
        OperationQueue.main.addOperation { () -> Void in
            self.performSegue(withIdentifier: "idSegueChat", sender: self)
        }
    }

}
