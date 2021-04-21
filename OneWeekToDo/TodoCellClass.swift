
//
//  TodoCell.swift
//  OneWeekToDo
//
//  Created by 久保　直哉 on 2020/11/10.
//  Copyright © 2020 久保　直哉. All rights reserved.
//

import UIKit
protocol customdelegate {
    func deletecell(index:Int)
    func updateTableView(index:Int)
}

class TodoCell: UITableViewCell {
    

    @IBOutlet weak var ToDoTitle: UIButton!
    @IBOutlet weak var toDoCheck: UILabel!
    @IBOutlet weak var toDoLine: UILabel!
    @IBOutlet weak var toDoDelete: UIButton!
    
    var delegate:customdelegate!
    var cellindex:Int?
    let mainBoundSize: CGSize = UIScreen.main.bounds.size
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setup(){
        toDoCheck.font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/23.0)!
        toDoLine.font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/35.8)!
        toDoDelete.titleLabel?.font=UIFont.init(name: "Futura-CondensedExtraBold", size:mainBoundSize.height/15.0)!
    }
    
    @IBAction func TitleTouch(_ sender: Any) {
        delegate.updateTableView(index: cellindex!)
    }
    
    
    @IBAction func DeleteTouch(_ sender: Any) {
        delegate.deletecell(index: cellindex!)
    }
    
}
