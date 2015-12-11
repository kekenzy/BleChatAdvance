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
    var bleCentralManager:BleCentralManager!;
    var blePeripheralManager:BlePeripheralManager!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        bleCentralManager = BleCentralManager.sharedInstance;
        blePeripheralManager = BlePeripheralManager.sharedInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // セルの列数
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
        
        let text = talkList[indexPath.row]
        cell.textLabel!.text = text
        self.msgText.text = ""
        return cell
    }

    @IBAction func onSendMsg(sender: AnyObject) {
        talkList.insert(self.msgText.text!, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        bleCentralManager.writeMsg(self.msgText.text)
        // Send はペリフェラルから
    }
}

