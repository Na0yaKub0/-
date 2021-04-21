//
//  MyToDoClass.swift
//  OneWeekToDo
//
//  Created by 久保　直哉 on 2020/11/11.
//  Copyright © 2020 久保　直哉. All rights reserved.
//

import Foundation

class MyTodo: NSObject,NSSecureCoding{
        static var supportsSecureCoding: Bool{
            return true
        }
        var todoTitle: String?
        var Do:Bool=false
    
        override init() {
        }
    
        func encode(with aCoder: NSCoder) {
            aCoder.encode(todoTitle, forKey: "todoTitle")
            aCoder.encode(Do, forKey: "Do")
        }
    
        required init?(coder aDecoder: NSCoder){
            todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
            Do = aDecoder.decodeBool(forKey: "Do")
        }
}

