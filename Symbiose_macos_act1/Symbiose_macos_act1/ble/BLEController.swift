//
//  BLEController.swift
//  BLEPeripheralApp
//
import AppKit
import CoreBluetooth

class BLEController: NSWindowController, CBPeripheralManagerDelegate, ObservableObject {
    
    @Published var messageLabel: String = ""
    @Published var readValueLabel: String = ""
    @Published var writeValueLabel: String = ""
    
    @Published var bleStatus: Bool = false
    
    let authCBUUID = CBUUID(string: "42381107-FF7F-40D8-AA2A-115A76449099")
    let writeCBUUID = CBUUID(string: "4797327B-7044-4AD7-A01E-9F3AEA2FAF17")
    let readCBUUID = CBUUID(string: "19C73BE7-7CE7-4A80-B135-AE0EA643E646")
    
    private var service: CBUUID!
    private let value = "BD34E"
    private var peripheralManager : CBPeripheralManager!

    func load() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            self.bleStatus = true
            self.addServices()
        @unknown default:
            fatalError()
        }
    }

    func addServices() {
        let valueData = value.data(using: .utf8)
        // 1. Create instance of CBMutableCharcateristic
        let myCharacteristic1 = CBMutableCharacteristic(type: writeCBUUID, properties: [.notify, .write, .read], value: nil, permissions: [.readable, .writeable])
        let myCharacteristic2 = CBMutableCharacteristic(type: readCBUUID, properties: [.read], value: valueData, permissions: [.readable])
       
        // 2. Create instance of CBMutableService
        service = authCBUUID
        let myService = CBMutableService(type: service, primary: true)
        
        // 3. Add characteristics to the service
        myService.characteristics = [myCharacteristic1, myCharacteristic2]
        
        // 4. Add service to peripheralManager
        peripheralManager.add(myService)
        
        // 5. Start advertising
        startAdvertising()
       
    }
    
    
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey : "symbioseact"])
        print("Started Advertising")
        
    }
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        
    }

    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print(peripheral)
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        readValueLabel = value
        print(value)
      
        // Perform your additional operations here
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        if let value = requests.first?.value {
           writeValueLabel = value.hexEncodedString2()
            //Perform here your additional operations on the data you get
            if let string = String(bytes: value, encoding: .utf8) {
                print(string)
                self.messageLabel = string
            }
        }
    }
}


extension Data {
    struct HexEncodingOptions2: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions2(rawValue: 1 << 0)
    }
    
    func hexEncodedString2(options: HexEncodingOptions2 = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
