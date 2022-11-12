//
//  MotionCollectorView.swift
//  Compete Watch App
//
//  Created by Gowtham Saravanan on 05/11/22.
//

import SwiftUI

struct MotionCollectorView: View {
    
    @StateObject var manager = MotionCollectionManager()
    @State var isTimerRiunning = false
    @State var timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text((manager.isSessionRunning) ? "Recording Data..." : "")
                .foregroundColor(manager.isSessionRunning ? .red : .white)
            HStack {
                Button("Start") {
                    //start recording motion data and print it on the screen
                    manager.startSession()
                    startTimer()
                    isTimerRiunning.toggle()
                }
                
                Button("Stop") {
                    //pause the session.
                    manager.PauseSession()
                    stopTimer()
                    isTimerRiunning.toggle()
                }
            }
            Text("Total Count: \(manager.totaCount)")
                .padding(10)
            Button("End") {
                //end the session
                manager.endSession()
            }
            // isTransfering and progress properties are present in the wcFileTransfer object which itself is present in the WatchManager class
            //both of these values keep  on changing based on condition whether there are files to be sent to iPhone or not
            //Since I cannot publish those values using @Published property wrapper as they are in a predefines class, I need to way to listen to changes made to those two values update the UI accordingly
            if manager.wcManager.wcSessionFileTransfer?.isTransferring == true {
                // if yes then showing the value using a progress view
                ProgressView("Transfering...", value: manager.wcManager.wcSessionFileTransfer?.progress.fractionCompleted, total: 100)
                    .progressViewStyle(.linear)
                    .padding(10)
                    //as the value of manager.wcManager.wcSessionFileTransfer?.progress.fractionCompleted changes the progress view should update automatically but it is not as the values are not pulished.
            }
        }
        .onAppear() {
            stopTimer()
        }
        .onReceive(timer, perform: {input in
            WKInterfaceDevice.current().play(.directionUp)
        })
        
    }
    
}

struct MotionCollectorView_Previews: PreviewProvider {
    static var previews: some View {
        MotionCollectorView()
    }
}


extension MotionCollectorView {
    func stopTimer() {
           self.timer.upstream.connect().cancel()
       }
       
       func startTimer() {
           self.timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
       }
}
