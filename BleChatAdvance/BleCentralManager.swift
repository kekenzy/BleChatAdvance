//
//  BleCentralManager.swift
//  BleChatAdvance
//
//  Created by ADK114019 on 2015/12/10.
//  Copyright © 2015年 Kenji Nagai. All rights reserved.
//

import Foundation
import CoreBluetooth


class BleCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static let sharedInstance: BleCentralManager = BleCentralManager()
    var centralManager: CBCentralManager!
    var peripheralList:[CBPeripheral]!
    var msgText:String?
    
    // =========================================================================
    // MARK: Private
    override private init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralList = [CBPeripheral]()
    }
    
    
    // =========================================================================
    // MARK: Public
    

    func startScan() {
        DLOG(LogKind.CE,message:"スキャン開始")
        // peripherarl側でCBAdvertisementDataServiceUUIDsKeyをアドバタイズしないと検出できない
        let serviceUUID = [CBUUID(string:SERVICE_UUID)]
        
        // アドバダタイズを１回にまとめるかかどうか、NOはまとめる(iOSのみ有効)
        let OPTION:Dictionary = [CBCentralManagerScanOptionAllowDuplicatesKey:false]
        self.centralManager!.scanForPeripheralsWithServices(serviceUUID, options:OPTION)
        
//        self.centralManager!.scanForPeripheralsWithServices(serviceUUID, options:nil)
//        self.centralManager!.scanForPeripheralsWithServices(nil, options:OPTION)
    }
    
    func stopScan() {
        self.centralManager.stopScan()
        self.peripheralList.removeAll()
    }
    
    func writeMsg(msg:String?) {
//        if centralManager.isScanning {
//            DLOG(LogKind.CE,message:"スキャン中....")
//            return
//        }
        
        self.msgText = msg
        self.startScan()
    }
    // =========================================================================
    // MARK: CBCentralManagerDelegate
    
    // セントラルマネージャの状態が変化すると呼ばれる
    // CBCentralManagerの状態変化を取得
    func centralManagerDidUpdateState(central: CBCentralManager) {
        DLOG(LogKind.CE,message:"state: \(central.state.rawValue)")
        
        switch(central.state){
        case CBCentralManagerState.PoweredOn:
//            self.startScan()
            break
            
        case CBCentralManagerState.PoweredOff:
            DLOG(LogKind.CE,message:"電源が入っていないようです。")
            break
            
        case CBCentralManagerState.Unknown:
            DLOG(LogKind.CE,message:"unknown")
            break
            
        case CBCentralManagerState.Unauthorized:
            DLOG(LogKind.CE,message:"Unauthorized")
            break
            
        case CBCentralManagerState.Unsupported:
            DLOG(LogKind.CE,message:"Unsupported")
            break
            
        default:
            break
        }
    }
    
    
    // ペリフェラルを発見すると呼ばれる
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        DLOG(LogKind.CE,message:"発見したBLEデバイス: \(peripheral)")
        
        if !self.peripheralList.contains(peripheral) {
            self.peripheralList.insert(peripheral, atIndex: 0)
            
            if peripheral.state == CBPeripheralState.Disconnected {
                self.centralManager.connectPeripheral(peripheral, options: nil)
            }
        }
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        DLOG(LogKind.CE,message:"接続成功！")
        
        // サービス探索結果を受け取るためにデリゲートをセット
        peripheral.delegate = self
        
        let serviceUUID = [CBUUID(string:SERVICE_UUID)]
        // サービス探索開始
        peripheral.discoverServices(serviceUUID)
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        DLOG(LogKind.CE,message:"接続失敗・・・")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        DLOG(LogKind.CE,message:"切断完了")
        // TODO 暫定
        self.peripheralList.removeAll()
    }
    
    
    // =========================================================================
    // MARK:CBPeripheralDelegate
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if (error != nil) {
            DLOG(LogKind.CE,message:"エラー: \(error)")
            return
        }
        
        if !(peripheral.services?.count > 0) {
            DLOG(LogKind.CE,message:"no services")
            return
        }
        
        let services = peripheral.services!
        DLOG(LogKind.CE,message:"\(services.count) 個のサービスを発見！ \(services)")
        
        for service in services {
            // キャラクタリスティック探索開始
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (error != nil) {
            DLOG(LogKind.CE,message:"エラー: \(error)")
            return
        }
        
        if !(service.characteristics?.count > 0) {
            DLOG(LogKind.CE,message:"no characteristics")
            return
        }
        
        let characteristics = service.characteristics!
        DLOG(LogKind.CE,message:"\(characteristics.count) 個のキャラクタリスティックを発見！ \(characteristics)")
        
        for characteristic in characteristics {
            
            if characteristic.UUID.isEqual(CBUUID(string:CHR_UUID)) {
                
                
                characteristic.properties
                if characteristic.properties.contains(CBCharacteristicProperties.Notify) {
                    DLOG(LogKind.CE,message:"Notify On ")
//                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
                if characteristic.properties.contains(CBCharacteristicProperties.Read) {
                    DLOG(LogKind.CE,message:"Read On ")
//                    peripheral.readValueForCharacteristic(characteristic)
                }
                if characteristic.properties.contains(CBCharacteristicProperties.Write) {
                    let data = self.msgText?.dataUsingEncoding(NSUTF8StringEncoding)
//                    let msg = "Hello!!!!!!!"
//                    let data = msg.dataUsingEncoding(NSUTF8StringEncoding)
                    DLOG(LogKind.CE,message:"Write On :\(self.msgText!)")
                    peripheral.writeValue(data!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
                }
                if characteristic.properties.contains(CBCharacteristicProperties.WriteWithoutResponse) {
                    DLOG(LogKind.CE,message:"WriteWithResopnse On ")
//                    let data = self.msgText?.dataUsingEncoding(NSUTF8StringEncoding)
//                    peripheral.writeValue(data!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                }
                
            }
        }
    }
    
    // データ読み込みが完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            DLOG(LogKind.CE,message:"読み込み失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        var value:NSString? = nil
        if characteristic.value != nil {
            value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        DLOG(LogKind.CE,message:"読み込み成功！value: \(value) service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID)")
    }
    
    // Notify受付が完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            DLOG(LogKind.CE,message:"Notify受付失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        var value:NSString? = nil
        if characteristic.value != nil {
            value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        DLOG(LogKind.CE,message:"Notify受付成功！value: \(value) service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID)")
        
    }
    
    
    // データ書き込みが完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            DLOG(LogKind.CE,message:"書き込み失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        var value:NSString? = nil
        if characteristic.value != nil {
            value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        DLOG(LogKind.CE,message:"書き込み成功！value: \(value) service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID)")
        
//        self.centralManager.cancelPeripheralConnection(peripheral)
//        self.stopScan()
        self.peripheralList.removeAll()
    }
    
    
    
}
