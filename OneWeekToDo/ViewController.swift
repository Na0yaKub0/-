
//
//  ViewController.swift
//  OneWeekToDo
//
//  Created by 久保　直哉 on 2020/11/08.
//  Copyright © 2020 久保　直哉. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseCrashlytics
import SwiftDate

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,customdelegate{

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var RemainingTime: UILabel!
    @IBOutlet weak var AchievementRatioValueLabel: UILabel!
    @IBOutlet weak var DeadlineDaysButton: UIButton!
    @IBOutlet weak var recodeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
//変数20210425aaaaaaaaaa
    var todoList=[MyTodo]()
    var recodeList=[Recode]()
    var DeadlineDayWeek:String="日曜日"
    var DeadlineYear:String=""
    var DeadlineMonth:String=""
    var DeadlineDay:String=""
    var AchievementRatioValue:Int=0
    let bgColor = UIColor(red: 255/255, green: 190/255, blue: 145/255, alpha: 1)
    let userDefaults = UserDefaults.standard
    let mainBoundSize: CGSize = UIScreen.main.bounds.size

    //関数20210425aaaaaaaaaaa
    func deletecell(index: Int) {
        view.isUserInteractionEnabled = false
        todoList.remove(at:index)
        tableView.deleteRows(at: [IndexPath(row:index,section:0)], with: UITableView.RowAnimation.left)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
        do{
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }catch{
        }
        AchievementRatioCalculation()
        SetupPieChartView()
        view.isUserInteractionEnabled = true
    }
    
    func updateTableView(index: Int) {
        todoList[index].Do = !todoList[index].Do
        tableView.reloadData()
        AchievementRatioCalculation()
        SetupPieChartView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat((Int(mainBoundSize.height)))/11
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! TodoCell
        cell.delegate=self
        tableView.backgroundColor=bgColor
        tableView.tableFooterView = UIView()
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = bgColor.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 25
        cell.clipsToBounds = true
        cell.cellindex=indexPath.row

        let myTodo = todoList[indexPath.row]
        if let myTodoTitle = myTodo.todoTitle{
            cell.toDoLine.text=myTodoTitle
        }
        if let celltoDoLineRext=cell.toDoLine.text{
            let atr =  NSMutableAttributedString(string: celltoDoLineRext)
            if myTodo.Do {
                atr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 9, range: NSMakeRange(0, atr.length))
                cell.toDoLine.attributedText = atr
                cell.toDoCheck.textColor=UIColor.orange
            }else{
                atr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, atr.length))
                cell.toDoLine.attributedText = atr
                cell.toDoCheck.textColor=UIColor.white
            }
            do{
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            }catch{
            }
        }
        return cell
    }
    
    func AchievementRatioCalculation(){
        if todoList.count == 0{
            AchievementRatioValue = 0
            return
        }
        var NotAchievedCount:Int = 0
        for index in 0...(todoList.count-1){
            if todoList[index].Do{
                NotAchievedCount+=1
            }
        }
        AchievementRatioValue=NotAchievedCount*100/todoList.count
        userDefaults.set(AchievementRatioValue, forKey: "AchievementRatioValue")
        userDefaults.synchronize()
    }
    
    func SetupPieChartView() {
        if todoList.count == 0{
            AchievementRatioValue=0
            }
        let NoAchievementRatioValue=100-AchievementRatioValue
        
        pieChartView.highlightPerTapEnabled = false
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.rotationEnabled = false
        pieChartView.holeRadiusPercent = 0.6
        AchievementRatioValueLabel.text=String(AchievementRatioValue)+"%"
        AchievementRatioValueLabel.font=UIFont.init(name: "DBLCDTempBlack", size: mainBoundSize.height/12.8)!
        let dataEntries = [
            PieChartDataEntry(value: Double(AchievementRatioValue), label: "A"),
            PieChartDataEntry(value: Double(NoAchievementRatioValue), label: "B"),
        ]
        let dataSet = PieChartDataSet(entries: dataEntries)
        dataSet.setColors(UIColor.orange, bgColor)
        dataSet.drawValuesEnabled = false
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        self.pieChartView.usePercentValuesEnabled = true
        view.addSubview(self.pieChartView)
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }

    func saveRecode(){
        let save=Recode()
        var NotAchievedCount:Int = 0
        save.RecodeDays=DeadlineMonth+"月"+DeadlineDay+"日"
        save.RecodeAchievementRatio=String(AchievementRatioValue)
        recodeList.insert(save, at: 0)
        
        for index in 0...6{
            if let modifiedDate = Calendar.current.date(byAdding: .day, value: index, to: Date()){
                let nextday=String(modifiedDate.weekdayName(.default))
                if DeadlineDayWeek==nextday{
                    DeadlineYear=String(modifiedDate.year)
                    DeadlineMonth=String(modifiedDate.month)
                    DeadlineDay=String(modifiedDate.day)
                }
            }
        }
        
        
        if todoList.count != 0{
        for i in 0..<todoList.count{
            todoList[i].Do=false
        }
        let _ = todoList.map{$0.Do = false}
        tableView.reloadData()
        NotAchievedCount = todoList.filter{$0.Do == true}.count
        for index in 0...(todoList.count-1){
            if todoList[index].Do{
                NotAchievedCount+=1
            }
        }
            AchievementRatioValue=NotAchievedCount*100/todoList.count
        }else{
            AchievementRatioValue=0
        }
        SetupPieChartView()
        do{
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: recodeList, requiringSecureCoding: true)
            userDefaults.set(data, forKey: "recodeList")
            userDefaults.synchronize()
        }catch{
            print("保存してない")
        }
        do{
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }catch{
        }
        userDefaults.set(AchievementRatioValue, forKey: "AchievementRatioValue")
        userDefaults.set(DeadlineYear, forKey: "DeadlineYear")
        userDefaults.set(DeadlineMonth, forKey: "DeadlineMonth")
        userDefaults.set(DeadlineDay, forKey: "DeadlineDay")
        userDefaults.synchronize()
        
    }

    @objc func TimeProces(){
        var count:Int=0
        let date = Date()
        for index in 0...6{
            if let modifiedDate = Calendar.current.date(byAdding: .day, value: index, to: date){
                let nextday=String(modifiedDate.weekdayName(.default))
                if DeadlineDayWeek==nextday{
                    count=(index+1)
                }
                if count==1{
                    var hhh:Int=23-date.hour
                    var mmm:Int=60-date.minute
                    if mmm==60{
                        mmm=0
                        hhh=hhh+1
                    }
                    RemainingTime.text="あと、"+String(hhh)+"時間"+String(mmm)+"分"
                }else{
                    RemainingTime.text=("あと、"+String(count)+"日")
                }
            }
        }
        
        if Int(DeadlineYear)!<date.year{
            saveRecode()
        }else if Int(DeadlineMonth)!<date.month && Int(DeadlineYear)!<=date.year{
            saveRecode()
  
        }else if Int(DeadlineDay)!<date.day && Int(DeadlineMonth)!<=date.month && Int(DeadlineYear)!<=date.year{
            saveRecode()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "TodoCellClass", bundle: nil),forCellReuseIdentifier:"TodoCell")
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector (TimeProces), userInfo: nil, repeats: true)
        let japan = Region(calendar: Calendars.gregorian, zone: Zones.asiaTokyo, locale: Locales.japanese)
        SwiftDate.defaultRegion = japan
        
        if let font = UIFont.init(name: "Hiragino Maru Gothic ProN", size: mainBoundSize.height/35.8){
            RemainingTime.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size: mainBoundSize.height/44.8){
            DeadlineDaysButton.titleLabel?.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size: mainBoundSize.height/44.8){
            recodeButton.titleLabel?.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size: mainBoundSize.height/44.8){
            addButton.titleLabel?.font=font
        }
        tableView.backgroundColor=bgColor
        tableView.tableFooterView = UIView()
        if let value = userDefaults.string(forKey: "DeadlineDayWeek"){
            DeadlineDayWeek = value
        }
        if let value = userDefaults.string(forKey: "DeadlineYear"){
            DeadlineYear = value
        }
        if let value = userDefaults.string(forKey: "DeadlineMonth"){
            DeadlineMonth = value
        }
        if let value = userDefaults.string(forKey: "DeadlineDay"){
            DeadlineDay = value
        }
        let achievementRatioValue = userDefaults.integer(forKey: "AchievementRatioValue")
            AchievementRatioValue = achievementRatioValue
            do{
                    if let storedTodoList=userDefaults.object(forKey: "todoList") as? Data {
                            if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject (ofClasses:[NSArray.self,MyTodo.self], from: storedTodoList) as? [MyTodo] {
                            todoList.append(contentsOf: unarchiveTodoList)
                                }
                          }
                       } catch {
                       }
        do{
                if let storedTodoList=userDefaults.object(forKey: "recodeList") as? Data {
                        if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject (ofClasses:[NSArray.self,Recode.self], from: storedTodoList) as? [Recode] {
                        recodeList.append(contentsOf: unarchiveTodoList)
                            }
                      }
                   } catch {
                   }
        DeadlineDaysButton.setTitle("期限("+DeadlineDayWeek+")", for: .normal)
        SetupPieChartView()
        if DeadlineMonth==""{
            var nextday:String=""
            
            for index in 0...6{
                if let modifiedDate = Calendar.current.date(byAdding: .day, value: index, to: Date()){
                    nextday=String(modifiedDate.weekdayName(.default))
                    if DeadlineDayWeek==nextday{
                        DeadlineYear=String(modifiedDate.year)
                        DeadlineMonth=String(modifiedDate.month)
                        DeadlineDay=String(modifiedDate.day)
                    }
                }
            }
            
            userDefaults.set(DeadlineYear, forKey: "DeadlineYear")
            userDefaults.set(DeadlineMonth, forKey: "DeadlineMonth")
            userDefaults.set(DeadlineDay, forKey: "DeadlineDay")
            userDefaults.synchronize()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let recode = segue.destination as! RecodeViewController
        recode.RecodeList=recodeList
    }
    
//実行処理
    @IBAction func Return(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func AddTodo(_ sender: Any) {
        let alertController = UIAlertController(title:"ルーティンを追加",
            message:"ルーティンを入力してください",preferredStyle:
            UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: nil)
        if let subview = alertController.view.subviews.first?.subviews.first?.subviews.first {
            subview.backgroundColor = bgColor
        }
        alertController.view.tintColor = UIColor.black
        let okAction = UIAlertAction(title:"追加",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            if let textField=alertController.textFields?.first {
                if textField.text==""{return}
                let myTodo = MyTodo()
                let last=todoList.count
                myTodo.todoTitle=textField.text
                self.todoList.append(myTodo)
                self.tableView.insertRows(at: [IndexPath(row:last,section:0)],with:UITableView.RowAnimation.right)
                //達成率処理
                var NotAchievedCount:Int = 0
                for index in 0...(todoList.count-1){
                    if todoList[index].Do == true{
                        NotAchievedCount+=1
                    }
                }
                
                AchievementRatioValue=NotAchievedCount*100/todoList.count
                let NoAchievementRatioValue=100-AchievementRatioValue
                userDefaults.set(AchievementRatioValue, forKey: "AchievementRatioValue")
                pieChartView.highlightPerTapEnabled = false
                pieChartView.holeRadiusPercent = 0.6
                pieChartView.chartDescription?.enabled = false
                pieChartView.drawEntryLabelsEnabled = false
                pieChartView.legend.enabled = false
                pieChartView.rotationEnabled = false
                
                AchievementRatioValueLabel.text=String(AchievementRatioValue)+"%"
                if let font=UIFont.init(name: "DBLCDTempBlack", size: mainBoundSize.height/12.8){
                    AchievementRatioValueLabel.font=font
                }
                let dataEntries = [
                    PieChartDataEntry(value: Double(AchievementRatioValue), label: "A"),
                    PieChartDataEntry(value: Double(NoAchievementRatioValue), label: "B"),
                ]
                let dataSet = PieChartDataSet(entries: dataEntries)
                dataSet.setColors(UIColor.orange,bgColor)
                dataSet.drawValuesEnabled = false
                self.pieChartView.data = PieChartData(dataSet: dataSet)
                self.pieChartView.usePercentValuesEnabled = true
                view.addSubview(self.pieChartView)
                pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
            }
        }
        alertController.addAction(okAction)
        alertController.preferredAction=okAction
        let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelButton)
        present(alertController, animated:true, completion:nil)
        tableView.reloadData()
        
    }
    
    @IBAction func DeadlineDaysProces(_ sender: Any) {
        func saveDay(){
            var nextday:String=""
            self.DeadlineDaysButton.setTitle("期限("+DeadlineDayWeek+")", for: .normal)
            for index in 0...6{
                if let modifiedDate = Calendar.current.date(byAdding: .day, value: index, to: Date()){
                    nextday=String(modifiedDate.weekdayName(.default))
                    if DeadlineDayWeek==nextday{
                        DeadlineYear=String(modifiedDate.year)
                        DeadlineMonth=String(modifiedDate.month)
                        DeadlineDay=String(modifiedDate.day)
                    }
                }                
            }
            userDefaults.set(DeadlineDayWeek, forKey: "DeadlineDayWeek")
            userDefaults.set(DeadlineYear, forKey: "DeadlineYear")
            userDefaults.set(DeadlineMonth, forKey: "DeadlineMonth")
            userDefaults.set(DeadlineDay, forKey: "DeadlineDay")
            userDefaults.synchronize()
        }
        
        let alertController = UIAlertController(title:"期限日設定",
            message:"期限日(曜日)を選択してください",preferredStyle:
            UIAlertController.Style.alert)
        if let subview = alertController.view.subviews.first?.subviews.first?.subviews.first {
            subview.backgroundColor = bgColor
        }
        alertController.view.tintColor = UIColor.black
        let Sunday = UIAlertAction(title:"日曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="日曜日"
            saveDay()
        }
        let Monday = UIAlertAction(title:"月曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="月曜日"
            saveDay()
        }
        let Tuesday = UIAlertAction(title:"火曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="火曜日"
            saveDay()
        }
        let Wednesday  = UIAlertAction(title:"水曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="水曜日"
            saveDay()
        }
        let Thursday = UIAlertAction(title:"木曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="木曜日"
            saveDay()
        }
        let Friday  = UIAlertAction(title:"金曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="金曜日"
            saveDay()
        }
        let Saturday = UIAlertAction(title:"土曜日",
                                     style:UIAlertAction.Style.default) { [self](action: UIAlertAction)in
            DeadlineDayWeek="土曜日"
            saveDay()
        }
        alertController.addAction(Sunday)
        alertController.addAction(Monday)
        alertController.addAction(Tuesday)
        alertController.addAction(Wednesday)
        alertController.addAction(Thursday)
        alertController.addAction(Friday)
        alertController.addAction(Saturday)
        present(alertController, animated:true, completion:nil)
    }
}
