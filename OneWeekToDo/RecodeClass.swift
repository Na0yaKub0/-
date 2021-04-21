//
//  RecodeCell.swift
//  OneWeekToDo
//
//  Created by 久保　直哉 on 2020/11/16.
//  Copyright © 2020 久保　直哉. All rights reserved.
//

import Foundation
class Recode: NSObject,NSSecureCoding{
        static var supportsSecureCoding: Bool{
            return true
        }
        var RecodeAchievementRatio:String?
        var RecodeDays: String?
    
        override init() {
        }
    
        func encode(with aCoder: NSCoder) {
            aCoder.encode(RecodeAchievementRatio, forKey: "RecodeAchievementRatio")
            aCoder.encode(RecodeDays, forKey: "RecodeDays")
        }
    
        required init?(coder aDecoder: NSCoder){
            RecodeAchievementRatio = aDecoder.decodeObject(forKey: "RecodeAchievementRatio") as? String
            RecodeDays = aDecoder.decodeObject(forKey: "RecodeDays") as? String
        }
}

