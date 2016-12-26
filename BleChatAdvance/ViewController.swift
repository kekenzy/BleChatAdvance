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
let CHR_UUID = "F5A6373E-B756-4B55-BE51-F8BD9A4A3193"
let NC_MSG = "NC_MSG"
let STATUS_DID_WRITE = "STATUS_DID_WRITE"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgText: UITextField!
    
    var talkList = [String]()
    var myTalkFlg = false
    var bleManager:BleManager!;
    
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
        self.bleManager.setUUID(serviceUUID: SERVICE_UUID, charUUID: CHR_UUID, ncMsg: NC_MSG)

//        let tap = UITapGestureRecognizer(target: self, action: "onTap")
//        view.addGestureRecognizer(tap)
        
        // 登録
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(ViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: NC_MSG), object: nil)

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
    
    
    
    func handleNotification(_ notification: Notification) {
        // 変数宣言時にアンラップ & キャストする方法
        var value:String! = ""
        if let userInfo = notification.userInfo {
            value = userInfo["message"] as! String
        }
        
        if (value == STATUS_DID_WRITE) {
            self.msgText.text = ""
            return
        }
        

        self.myTalkFlg = false
        talkList.insert(value, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
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
        bleManager.write(msg: self.msgText.text, statusDidWrite: STATUS_DID_WRITE)
        // Send はペリフェラルから
    }
}

