//
//  ViewController.swift
//  BleChatAdvance
//
//  Created by ADK114019 on 2015/12/09.
//  Copyright © 2015年 Kenji Nagai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgText: UITextField!
    
    var talkList = [String]()
    var myTalkFlg = false
    var bleCentralManager:BleCentralManager!;
    var blePeripheralManager:BlePeripheralManager!;
    
    // =========================================================================
    // MARK:UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        bleCentralManager = BleCentralManager.sharedInstance;
        blePeripheralManager = BlePeripheralManager.sharedInstance
        
        // 登録
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "handleNotification:", name: NC_MSG, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // =========================================================================
    // MARK:UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkList.count
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
//        if self.myTalkFlg {
            cell.textLabel?.textAlignment = .Center
//        } else {
//            cell.textLabel?.textAlignment = NSTextAlignment.Left
//        }
        let text = talkList[indexPath.row]
        cell.textLabel!.text = text
//        self.msgText.text = ""
        return cell
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボードを閉じる
//        textField.resignFirstResponder()
        return true
    }
    
    func handleNotification(notification: NSNotification) {
        // 変数宣言時にアンラップ & キャストする方法
        var value:String! = ""
        if let userInfo = notification.userInfo {
            value = userInfo["message"] as! String
        }

        self.myTalkFlg = false
        talkList.insert(value, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    @IBAction func tapScreen(sender: AnyObject) {
        DLOG(LogKind.COM,message: "tapScreen")
//        self.view.endEditing(true)
    }
    
    @IBAction func onSendMsg(sender: AnyObject) {
        talkList.insert(self.msgText.text!, atIndex: 0)
        self.myTalkFlg = true
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        bleCentralManager.writeMsg(self.msgText.text)
        // Send はペリフェラルから
    }
}

