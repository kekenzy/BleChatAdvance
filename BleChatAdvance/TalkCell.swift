//
//  TalkCell.swift
//  BleChatAdvance
//
//  Created by ADK114019 on 2015/12/17.
//  Copyright © 2015年 Kenji Nagai. All rights reserved.
//

import UIKit

class TalkCell:UITableViewCell {
    
    @IBOutlet weak var myTalkLabel: UILabel!
    @IBOutlet weak var otherTalkLabel: UILabel!
    @IBOutlet weak var otherNameLabel: UILabel!
    
    func setCell(_ myMsgFlg: Bool, msg: String) {
        let msgs:[String]? = msg.components(separatedBy: " from")
        if (myMsgFlg || msgs!.count <= 1) {
            self.myTalkLabel.isHidden = false
            self.myTalkLabel.text = msgs?[0]
            self.myTalkLabel.textColor = .blue
            self.myTalkLabel.textAlignment = .right
            self.otherTalkLabel.text = ""
            self.otherTalkLabel.isHidden = true
            self.otherNameLabel.text = ""
            self.otherNameLabel.isHidden = true
            
        } else {
            self.otherTalkLabel.isHidden = false
//            self.otherTalkLabel.text = msg
            self.otherTalkLabel.text = msgs?[0]
            self.otherTalkLabel.textColor = .black
            self.otherTalkLabel.textAlignment = .left
            self.otherNameLabel.text = msgs?[1]
            self.otherNameLabel.isHidden = false
            self.otherNameLabel.textAlignment = .left
            self.myTalkLabel.text = ""
            self.myTalkLabel.isHidden = true
        }
    }
}
