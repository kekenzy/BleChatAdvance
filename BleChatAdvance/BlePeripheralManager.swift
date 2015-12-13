//
//  BlePeripheralManager.swift
//  BleChatAdvance
//
//  Created by ADK114019 on 2015/12/10.
//  Copyright © 2015年 Kenji Nagai. All rights reserved.
//

import Foundation
import CoreBluetooth


class BlePeripheralManager: NSObject,CBPeripheralManagerDelegate {
    
    static let sharedInstance: BlePeripheralManager = BlePeripheralManager()
    var peripheralManager: CBPeripheralManager!
    var serviceUUID: CBUUID!
    var characteristic: CBMutableCharacteristic!
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // ペリフェラルマネージャ初期化
//        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    
    // =========================================================================
    // MARK: Private
    override private init() {
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    
    func publishservice () {
        
        // サービスを作成
        self.serviceUUID = CBUUID(string:SERVICE_UUID)
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // キャラクタリスティックを作成
        let characteristicUUID = CBUUID(string:CHR_UUID)
        
        let properties: CBCharacteristicProperties =
        [CBCharacteristicProperties.Notify, CBCharacteristicProperties.Read, CBCharacteristicProperties.Write]
        
        let permissions: CBAttributePermissions =
        [CBAttributePermissions.Readable, CBAttributePermissions.Writeable]
        
        self.characteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: properties,
            value: nil,
            permissions: permissions)
        
        // キャラクタリスティックをサービスにセット
        service.characteristics = [self.characteristic]
        
        // サービスを Peripheral Manager にセット
        self.peripheralManager.addService(service)
        
        // 値をセット
        let value = UInt8(arc4random() & 0xFF)
        let data = NSData(bytes: [value], length: 1)
        self.characteristic.value = data;
    }
    
    // =========================================================================
    // MARK: Public
    func startAdvertise() {
        
        if self.peripheralManager.isAdvertising {
            return
        }
        
        // アドバタイズメントデータを作成する
        let advertisementData = [
            CBAdvertisementDataLocalNameKey: "Test Device",
            CBAdvertisementDataServiceUUIDsKey: [self.serviceUUID]
        ]
        
        // アドバタイズ開始
        self.peripheralManager.startAdvertising(advertisementData)
        
    }
    
    func stopAdvertise () {
        // アドバタイズ停止
        self.peripheralManager.stopAdvertising()
        
    }
    
    
    // =========================================================================
    // MARK: CBPeripheralManagerDelegate
    
    // ペリフェラルマネージャの状態が変化すると呼ばれる
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        DLOG(LogKind.PE,message: "state: \(peripheral.state)")
        
        switch peripheral.state {
            
        case CBPeripheralManagerState.PoweredOn:
            // サービス登録開始
            self.publishservice()
            break
            
        default:
            break
        }
    }
    
    // サービス追加処理が完了すると呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        if (error != nil) {
            DLOG(LogKind.PE,message:"サービス追加失敗！ error: \(error)")
            return
        }
        
        DLOG(LogKind.PE,message:"サービス追加成功！")
        
        // アドバタイズ開始
        self.startAdvertise()
    }
    
    // アドバタイズ開始処理が完了すると呼ばれる
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        
        if (error != nil) {
            DLOG(LogKind.PE,message:"アドバタイズ開始失敗！ error: \(error)")
            return
        }
        
        DLOG(LogKind.PE,message:"アドバタイズ開始成功！")
    }
    
    // Readリクエスト受信時に呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        
        var value:NSString? = nil
        if request.characteristic.value != nil {
            value = NSString(data: request.characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        DLOG(LogKind.PE,message:"Readリクエスト受信！ requested service uuid:\(request.characteristic.service.UUID) characteristic uuid:\(request.characteristic.UUID) value:\(value)")
        
        // プロパティで保持しているキャラクタリスティックへのReadリクエストかどうかを判定
        if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
            
            // CBMutableCharacteristicのvalueをCBATTRequestのvalueにセット
            request.value = self.characteristic.value;
            
            // リクエストに応答
            self.peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
        }
    }
    
    // Writeリクエスト受信時に呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {

        DLOG(LogKind.PE,message:"\(requests.count) 件のWriteリクエストを受信！")

        for request in requests {
            
            var value:NSString? = nil
            if request.characteristic.value != nil {
                value = NSString(data: request.characteristic.value!, encoding: NSUTF8StringEncoding)
                
            }
            DLOG(LogKind.PE,message:"Requested value:\(value) service uuid:\(request.characteristic.service.UUID) characteristic uuid:\(request.characteristic.UUID)")
            
            if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
                
                // CBMutableCharacteristicのvalueに、CBATTRequestのvalueをセット
                self.characteristic.value = request.value;
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName(NC_MSG, object: nil, userInfo: ["message" : value!.description])
                
            }
        }

        // リクエストに応答
        self.peripheralManager.respondToRequest(requests[0] , withResult: CBATTError.Success)
    }
    
    
    // Notify開始要求
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        DLOG(LogKind.PE,message:"Notify開始要求受信！")
    }
    
    // Notify開始要求
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        DLOG(LogKind.PE,message:"Notify停止要求受信！")
    }
    
}

