//
//  CommonLog.swift
//  BleChatAdvance
//
//  Created by USER on 2015/12/11.
//  Copyright © 2015年 Kenji Nagai. All rights reserved.
//

import Foundation

enum LogKind:String {
    case COM, CE, PE
    func logText()-> String {
        switch(self){
        case .COM:
            return "[COM]"
        case .CE:
            return "[CE]"
        case .PE:
            return "[PE]"
        }
    }
}

func DLOG(id:LogKind, message: String) {
    LOG(id.logText() + message)
}

func LOG(message: String,
    file: String = __FILE__,
    line: Int = __LINE__) {
        
        #if DEBUG
//            print("\(message) (File: \(file), Line: \(line))")
            print("\(message)")
//            let nc = NSNotificationCenter.defaultCenter()
//            nc.postNotificationName(NC_MSG, object: nil, userInfo: ["message" : message])
        #endif
}
