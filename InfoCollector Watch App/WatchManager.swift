//
//  WactchManager.swift
//  Compete Watch App
//
//  Created by Gowtham Saravanan on 05/11/22.
//

import Foundation
import WatchConnectivity

class WatchManager: NSObject, ObservableObject {
    
    @Published var wcSessionFileTransfer: WCSessionFileTransfer? //this property is initially nil
    @Published var session: WCSession

  
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
   
    func sendFile(atURL url: URL ) {
        
        self.wcSessionFileTransfer = session.transferFile(url, metadata: nil)
    
        print("file transfer initiated")
        print(session.outstandingFileTransfers.count)
    }
}








extension WatchManager:  WCSessionDelegate{
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sendData(toWatch data: [String:Any]) {
        session.sendMessage(data, replyHandler: nil)
    }
    
}
