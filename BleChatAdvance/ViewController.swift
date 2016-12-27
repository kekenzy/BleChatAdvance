//
//  ViewController.swift
//  BleChatAdvance
//
//  Created by ADK114019 on 2015/12/09.
//  Copyright © 2015年 Kenji Nagai. All rights reserved.
//

import UIKit
import BleFormatter

let SERVICE_UUID = "0BF806E9-F1FE-4326-AB21-CEAFDEAFE0E0"
let CHR_UUID_1 = "F5A6373E-B756-4B55-BE51-F8BD9A4A3193"
let CHR_UUID_2 = "DB76EB66-975B-412D-977F-4FC072E8C28F"
let CHR_UUID_3 = "D744D2FC-1989-45AD-B497-F5E5A22649A2"
let CHR_UUID_4 = "E7136B95-14E0-4975-8C69-9D7D830D4F87"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgText: UITextField!
    
    var talkList = [String]()
    var myTalkFlg = false
    var bleManager:BleManager!;
    var dataFormat:[BleDataFormat] = []
    
    // =========================================================================
    // MARK:private
    func onTap(_ recognize:UIPanGestureRecognizer) {
//        self.textField.resignFirstResponder()
        
    }
    
    // =========================================================================
    // MARK:UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .none
        self.tableView.allowsSelection = false
        
        self.bleManager = BleManager.sharedInstance;
        self.bleManager.setUUID(serviceUUID: SERVICE_UUID)
        self.dataFormat.append(BleDataFormat(uuid: CHR_UUID_1, dataType: .String))
        self.dataFormat.append(BleDataFormat(uuid: CHR_UUID_2, dataType: .Int))
        self.dataFormat.append(BleDataFormat(uuid: CHR_UUID_3, dataType: .Double))
        self.dataFormat.append(BleDataFormat(uuid: CHR_UUID_4, dataType: .Data))
        self.bleManager.setReadDataFormat(bleDataFormat: self.dataFormat)
        
        // observer登録
        self.bleManager.addObserver(self, withRead: #selector(ViewController.readNotification(_:)))
        self.bleManager.addObserver(self, withWrite: #selector(ViewController.writeNotification(_:)))
        
    }
    
    deinit  {
        let nc = NotificationCenter.default
        nc.removeObserver(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    // =========================================================================
    // MARK:UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkList.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        let cell:TalkCell = tableView.dequeueReusableCell(withIdentifier: "talkCell")! as! TalkCell
        let text = talkList[indexPath.row]
        cell.setCell(self.myTalkFlg, msg: text)
        
        self.myTalkFlg = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    
    func readNotification(_ notification: Notification) {
        // 変数宣言時にアンラップ & キャストする方法
//        let userInfo = [BleDataKey.NOTIFY_READ.description():dataFormatList[index].characteristicUUID.description,
//                        BleDataKey.VALUE.description():dataFormatList[index].value] as [String : Any]
        //                        let value = self.dataFormatList[index].getStringFromValue()
        var tmpValue:String?
        guard let userInfo = notification.userInfo else {
            return
        }
        let data = userInfo[BleDataKey.NOTIFY_READ.description()] as! BleDataFormat
        switch data.dataType {
        case .String:
            tmpValue = data.getStringFromValue() as String
        case .Int:
            let i = data.getIntFromValue() as Int
            print("read Int value = \(i)")
            tmpValue = data.getStringFromValue() as String
        case .Double:
            let i = data.getDoubleFromValue() as Double
            print("read Double value = \(i)")
            tmpValue = data.getStringFromValue() as String
        case .Data:
            let i = data.getDataFromValue() as Data
            print("read Data value = \(i)")
            tmpValue = data.getStringFromValue() as String
        }
        
        guard let value = tmpValue else {
            print("can not read Notification message!!")
            return
        }
        print("read Notification message  =  \(value)")
        
        let postName = data.getPostName() as String
        
        self.myTalkFlg = false
        talkList.insert(value + "," + postName, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func writeNotification(_ notification: Notification) {
        // 変数宣言時にアンラップ & キャストする方法
        
        self.msgText.text = ""
        return
    }
    

    // =========================================================================
    // MARK:IBAction
    
    @IBAction func tapScreen(_ sender: AnyObject) {
//        DLOG(LogKind.COM,message: "tapScreen")
//        self.view.endEditing(true)
    }
    
    @IBAction func onSendMsg(_ sender: AnyObject) {
        self.myTalkFlg = true
        talkList.insert(self.msgText.text!, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        
        // wirte処理
        bleManager.write(withString: self.msgText.text!, dataFormat: &self.dataFormat[0])
//        bleManager.write(withInt: 100, dataFormat: &self.dataFormat[1])
//        bleManager.write(withDouble: 0.00044, dataFormat: &self.dataFormat[2])
//        var str = "Hello"
//        let data = str.data(using: String.Encoding.utf8)
//        bleManager.write(withData: data!, dataFormat: &self.dataFormat[3])
    }
}

