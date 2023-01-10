//
//  BLEObservableAct1.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 27/12/2022.
//

import Foundation
import CoreBluetooth

class BLEObservableIos:ObservableObject{
    
    enum ConnectionState {
        case disconnected,connecting,discovering,ready
    }
    
    @Published var periphList:[Periph] = []
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
    
    @Published var isActivated: Bool = false
    
    init(){
        _ = BLEManagerIos.instance
    }
    
    func startScann(){
        BLEManagerIos.instance.scan { p,s in
            let periph = Periph(blePeriph: p,name: s)
            if periph.name == "BLEPeripheralApp"{
                self.connectTo(p: periph)
                self.stopScann()
                
            }
            
        }
    }
    
    func stopScann(){
        BLEManagerIos.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        BLEManagerIos.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            BLEManagerIos.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
            }
        }
        BLEManagerIos.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManagerIos.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
    
    func sendString(str:String){
        
        let dataFromString = str.data(using: .utf8)!
        
        BLEManagerIos.instance.sendData(data: dataFromString) { c in
            
        }
    }
    
    func sendData(){
        let d = [UInt8]([0x00,0x01,0x02])
        let data = Data(d)
        let dataFromString = String("Toto").data(using: .utf8)
        
        BLEManagerIos.instance.sendData(data: data) { c in
            
        }
    }
    
    func readData(){
        BLEManagerIos.instance.readData()
    }
    
    func listen(c:((String)->())){
        
        BLEManagerIos.instance.listenForMessages { data in
            
            if let d = data{
                if let str = String(data: d, encoding: .utf8) {
                    if (str == "esp1On" && !self.isActivated) {
                        print(str)
                        self.isActivated = true
                    }
                }
            }
        }
        
    }
    
}
