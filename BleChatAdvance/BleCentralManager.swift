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
    
    let SERVICE_UUID = "0BF806E9-F1FE-4326-AB21-CEAFDEAFE0E0"
    let CHR_UUID = "0001"
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
    
    func debugPrint(msg:String) {
        print("[CE] \(msg)")
    }
    
    // =========================================================================
    // MARK: Public
    
    func startScan() {
        debugPrint("スキャン開始")
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
        self.msgText = msg
        self.startScan()
    }
    // =========================================================================
    // MARK: CBCentralManagerDelegate
    
    // セントラルマネージャの状態が変化すると呼ばれる
    // CBCentralManagerの状態変化を取得
    func centralManagerDidUpdateState(central: CBCentralManager) {
        debugPrint("state: \(central.state.rawValue)")
        
        switch(central.state){
        case CBCentralManagerState.PoweredOn:
            self.startScan()
            break
            
        case CBCentralManagerState.PoweredOff:
            debugPrint("電源が入っていないようです。")
            break
            
        case CBCentralManagerState.Unknown:
            debugPrint("unknown")
            break
            
        case CBCentralManagerState.Unauthorized:
            debugPrint("Unauthorized")
            break
            
        case CBCentralManagerState.Unsupported:
            debugPrint("Unsupported")
            break
            
        default:
            break
        }
    }
    
    
    // ペリフェラルを発見すると呼ばれる
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        debugPrint("発見したBLEデバイス: \(peripheral)")
        
        if !self.peripheralList.contains(peripheral) {
            self.peripheralList.insert(peripheral, atIndex: 0)
            
            if peripheral.state == CBPeripheralState.Disconnected {
                self.centralManager.connectPeripheral(peripheral, options: nil)
            }
        }
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        debugPrint("接続成功！")
        
        // サービス探索結果を受け取るためにデリゲートをセット
        peripheral.delegate = self
        
        let serviceUUID = [CBUUID(string:SERVICE_UUID)]
        // サービス探索開始
        peripheral.discoverServices(serviceUUID)
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("接続失敗・・・")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("切断完了")
        // TODO 暫定
        self.peripheralList.removeAll()
    }
    
    
    // =========================================================================
    // MARK:CBPeripheralDelegate
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if (error != nil) {
            debugPrint("エラー: \(error)")
            return
        }
        
        if !(peripheral.services?.count > 0) {
            debugPrint("no services")
            return
        }
        
        let services = peripheral.services!
        debugPrint("\(services.count) 個のサービスを発見！ \(services)")
        
        for service in services {
            // キャラクタリスティック探索開始
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (error != nil) {
            debugPrint("エラー: \(error)")
            return
        }
        
        if !(service.characteristics?.count > 0) {
            debugPrint("no characteristics")
            return
        }
        
        let characteristics = service.characteristics!
        debugPrint("\(characteristics.count) 個のキャラクタリスティックを発見！ \(characteristics)")
        
        for characteristic in characteristics {
            
            if characteristic.UUID.isEqual(CBUUID(string:CHR_UUID)) {
                
                
                characteristic.properties
                if characteristic.properties.contains(CBCharacteristicProperties.Notify) {
                    debugPrint("Notify On ")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
                if characteristic.properties.contains(CBCharacteristicProperties.Read) {
                    debugPrint("Read On ")
                    peripheral.readValueForCharacteristic(characteristic)
                }
                if characteristic.properties.contains(CBCharacteristicProperties.Write) {
                    debugPrint("Write On ")
                    let data = self.msgText?.dataUsingEncoding(NSUTF8StringEncoding)
                    peripheral.writeValue(data!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
                }
                if characteristic.properties.contains(CBCharacteristicProperties.WriteWithoutResponse) {
                    debugPrint("WriteWithResopnse On ")
                    let data = self.msgText?.dataUsingEncoding(NSUTF8StringEncoding)
                    peripheral.writeValue(data!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                }
                
            }
        }
    }
    
    // データ読み込みが完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            debugPrint("読み込み失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        var value:NSString? = nil
        if characteristic.value != nil {
            value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        debugPrint("読み込み成功！service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID), value: \(value)")
    }
    
    // Notify受付が完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            debugPrint("Notify受付失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        var value:NSString? = nil
        if characteristic.value != nil {
            value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        debugPrint("Notify受付成功！service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID), value: \(value)")
        
    }
    
    
    // データ書き込みが完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            debugPrint("書き込み失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        var value:NSString? = nil
        if characteristic.value != nil {
            value = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            
        }
        debugPrint("書き込み成功！service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID), value: \(value)")
    }
    
    
    
}
