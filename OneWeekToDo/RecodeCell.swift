//
//  RecodeCellClass.swift
//  OneWeekToDo
//
//  Created by 久保　直哉 on 2020/11/17.
//  Copyright © 2020 久保　直哉. All rights reserved.
//

import UIKit

class RecodeCell: UICollectionViewCell {
    @IBOutlet weak var RecodeDay: UILabel!
    @IBOutlet weak var RecodeAchievementRatio: UILabel!
    
    @IBOutlet weak var recodePercent: UILabel!
    let mainBoundSize: CGSize = UIScreen.main.bounds.size
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setup(){
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/89.6){
            RecodeDay.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/29.8){
            RecodeAchievementRatio.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/59.7){
            recodePercent.font=font
        }
        RecodeDay.textColor=UIColor.orange
        RecodeAchievementRatio.textColor=UIColor.orange
        recodePercent.textColor=UIColor.orange
    }
    

}

