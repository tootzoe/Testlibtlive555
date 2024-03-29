//
//  ContentView.swift
//  Testlibtlive555
//
//  Created by thor on 14/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI
 
struct ContentView: View {
    
    @State private var mediaFolderPath = ""
    
    @State private var testStr = ""
    
    @State private var currLDat = Data()
    
    var body: some View {
        VStack {
            
            Text("mediaFolder: \(mediaFolderPath)")
        
            Button("Select MediaFolder"){
                #if os(macOS)
                 let op = NSOpenPanel()
                op.directoryURL = URL.documentsDirectory
                
                op.canChooseDirectories = true
                op.canChooseFiles = false
                op.title = "Select a folder contains medial files...."
                op.begin { rsl in
                    if rsl.rawValue == NSApplication.ModalResponse.OK.rawValue {
                        mediaFolderPath = op.url?.path() ?? mediaFolderPath
                    }
                }
                #else
                mediaFolderPath = URL.documentsDirectory.path()
                print(mediaFolderPath)
                let b = FileManager.default.isReadableFile(atPath: "\(mediaFolderPath)xs.mp3")
                print(b)
                #endif
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Divider()
            
            
            Button("Start Media Server"){
                startLive555Svr(mediaFolderPath)
            }
            .buttonStyle(.borderedProminent)
            
            Divider()  
            Button("Stop Media Server"){
                stopLive555Server()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            Divider()
            
            
            
            
              Button("Write txt to document"){
                  var p = URL.documentsDirectory
                  p.appendPathComponent("testtxt.txt", conformingTo: .text)
                  try?  "startLive555Svr(\")".write(toFile: p.path(), atomically: true, encoding: .utf8) 
            }
            .buttonStyle(.borderedProminent)
            
              Button("get network"){
                  
                  getLocalNetworkAccessState { granted in
                      print(granted ? "granted" : "denied")
                  }
                  
                 
            }
            .buttonStyle(.borderedProminent) 
            
              Button("Invoke network"){
                  
                  DispatchQueue.global().async {
                      getData()
                  }
            }
            .buttonStyle(.borderedProminent)
            
        Divider()
            
            
        }
        .padding()
    }
    
    
    
    
    private func startLive555Svr(_ folderPath :String) {
        
        print("applicationDirectory0: " ,URL.currentDirectory())
        #if os(iOS)
        FileManager.default.changeCurrentDirectoryPath(URL.documentsDirectory.path())
        
        print("applicationDirectory1: " ,URL.currentDirectory())
        print("applicationDirectory2: " ,FileManager.default.currentDirectoryPath)
        #endif
        
        DispatchQueue.global().async {
            startMediaSrv(folderPath)
        }
         
    }
    
    func getData() {
 
           guard let url = URL(string: "https://www.google.com") else {
               fatalError("Invalid URL")
           }
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
 
           URLSession.shared.dataTask(with: request) { data, response, error in
               guard let data = data else{ return }
 
                   print(data)
 
           }.resume()
       }
    
}





class getLocalNetworkAccessState : NSObject {
    var service: NetService
    var denied: DispatchWorkItem?
    var completion: ((Bool) -> Void)
    
    @discardableResult
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        
        service = NetService(domain: "local.", type:"_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        
        super.init()
        
        denied = DispatchWorkItem {
            self.completion(false)
            self.service.stop()
            self.denied = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: denied!)
        
        service.delegate = self
        self.service.publish()
    }
}

extension getLocalNetworkAccessState : NetServiceDelegate {
    
    func netServiceDidPublish(_ sender: NetService) {
        denied?.cancel()
        denied = nil

        completion(true)
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("Error: \(errorDict)")
    }
}


public extension String {
    var hexStr : String {
        Data(self.utf8).hexDescription
    }
}

public extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

#Preview {
    ContentView()
}









