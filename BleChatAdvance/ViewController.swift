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
    // MARK:private
    func onTap(recognize:UIPanGestureRecognizer) {
//        self.textField.resignFirstResponder()
        
    }
    
    // =========================================================================
    // MARK:UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .None
        self.tableView.allowsSelection = false
        self.bleCentralManager = BleCentralManager.sharedInstance;
        self.blePeripheralManager = BlePeripheralManager.sharedInstance

//        let tap = UITapGestureRecognizer(target: self, action: "onTap")
//        view.addGestureRecognizer(tap)
        
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
//        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        let cell:TalkCell = tableView.dequeueReusableCellWithIdentifier("talkCell")! as! TalkCell
        let text = talkList[indexPath.row]
        cell.setCell(self.myTalkFlg, msg: text)
        
        self.myTalkFlg = false
        return cell
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    
    func handleNotification(notification: NSNotification) {
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
        talkList.insert(value, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // =========================================================================
    // MARK:IBAction
    
    @IBAction func tapScreen(sender: AnyObject) {
        DLOG(LogKind.COM,message: "tapScreen")
//        self.view.endEditing(true)
    }
    
    @IBAction func onSendMsg(sender: AnyObject) {
        self.myTalkFlg = true
        talkList.insert(self.msgText.text!, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        bleCentralManager.writeMsg(self.msgText.text)
        // Send はペリフェラルから
    }
}

