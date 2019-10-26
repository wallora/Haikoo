//
//  ContentView.swift
//  HaikooExample
//
//  Created by Paolo Ardia on 25/10/2019.
//  Copyright © 2019 Paolo Ardia. All rights reserved.
//

import SwiftUI
import Haikoo

class HaikooManager {
    let formatters: [LogFormatter] = [CompleteFormatter(symbols: "🐻🐻🐻")]
    
    let consoleMessenger: ConsoleMessenger
    var osLogMessenger: OSLogMessenger
    let fileMessenger: FileMessenger
    
    let consoleHaikoo: Haikoo
    let osLogHaikoo: Haikoo
    let fileHaikoo: Haikoo
    
    let colossalLog: String
    
    init(isAsync: Bool) {
        let colossalLogPath = Bundle.main.path(forResource: "colossal_log", ofType: "txt")!
        colossalLog = try! String(contentsOfFile: colossalLogPath)
        
        consoleMessenger = ConsoleMessenger(formatters: formatters, maxMessageLength: 200)
        fileMessenger = FileMessenger(maxFilesNumber: 2, fileMaxSize: 1024, formatters: formatters)
        
        let category = isAsync ? "async" : "sync"
        osLogMessenger = OSLogMessenger(subsystem: "com.haikoo.example", category: category, formatters: formatters, maxMessageLength: 200)
        
        let dispatchMethod: Haikoo.DispatchMethod = isAsync ? .asynchronous(queue: Haikoo.defaultQueue) : .synchronous(lock: NSRecursiveLock())
        
        consoleHaikoo = Haikoo(logLevels: .all, messengers: [consoleMessenger], dispatchMethod: dispatchMethod)
        osLogHaikoo = Haikoo(logLevels: .all, messengers: [osLogMessenger], dispatchMethod: dispatchMethod)
        fileHaikoo = Haikoo(logLevels: .all, messengers: [fileMessenger], dispatchMethod: dispatchMethod)
    }
}

struct ContentView: View {
    
    let syncManager = HaikooManager(isAsync: false)
    let asyncManager = HaikooManager(isAsync: true)
    var manager: HaikooManager {
        isAsync ? asyncManager : syncManager
    }
    @State var isAsync: Bool = false

    var body: some View {
        VStack {
            Text("Haikoo").bold()
            Toggle(isOn: $isAsync) {
                Text("Asynchronous logs")
            }.padding()
            Button(action: {
                self.manager.consoleHaikoo.verbose("Console verbose message")
            }) { Text("Console log") }
            Button(action: {
                self.manager.osLogHaikoo.verbose("OSLog verbose message")
            }) { Text("OS log") }
            Button(action: {
                self.manager.fileHaikoo.verbose("File verbose message")
            }) { Text("File log") }
            Spacer()
            Button(action: {
                self.manager.consoleHaikoo.verbose(self.manager.colossalLog)
            }) { Text("Console colossal log") }
            Button(action: {
                self.manager.osLogHaikoo.verbose(self.manager.colossalLog)
            }) { Text("OS colossal log") }
            Button(action: {
                self.manager.fileHaikoo.verbose(self.manager.colossalLog)
            }) { Text("File colossal log") }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
