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
    
    func setCell(myMsgFlg: Bool, msg: String) {
        let msgs:[String]? = msg.componentsSeparatedByString(" from")
        if (myMsgFlg || msgs!.count <= 1) {
            self.myTalkLabel.hidden = false
            self.myTalkLabel.text = msgs?[0]
            self.myTalkLabel.textColor = .blueColor()
            self.myTalkLabel.textAlignment = .Right
            self.otherTalkLabel.text = ""
            self.otherTalkLabel.hidden = true
            self.otherNameLabel.text = ""
            self.otherNameLabel.hidden = true
            
        } else {
            self.otherTalkLabel.hidden = false
//            self.otherTalkLabel.text = msg
            self.otherTalkLabel.text = msgs?[0]
            self.otherTalkLabel.textColor = .blackColor()
            self.otherTalkLabel.textAlignment = .Left
            self.otherNameLabel.text = msgs?[1]
            self.otherNameLabel.hidden = false
            self.otherNameLabel.textAlignment = .Left
            self.myTalkLabel.text = ""
            self.myTalkLabel.hidden = true
        }
    }
}
