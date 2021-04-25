//
//  RecodeViewController.swift
//  OneWeekToDo
//
//  Created by 久保　直哉 on 2020/11/10.
//  Copyright © 2020 久保　直哉. All rights reserved.
//

import UIKit
import Charts

class RecodeViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, IAxisValueFormatter,IValueFormatter{
//変数
    var RecodeList=[Recode]()
    var days: [String] = []
    var barChartPage:Int=1
    var PageCount:Int=0
    let bgColor = UIColor(red: 255/255, green: 190/255, blue: 145/255, alpha: 1)
    weak var axisFormatDelegate: IAxisValueFormatter?
    weak var valueFormatDelegate:IValueFormatter?
    let mainBoundSize: CGSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var pagePluss: UIButton!
    @IBOutlet weak var pageMinus: UIButton!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var collectionView: UICollectionView!
    
//関数

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return days[Int(value)]
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let a = RecodeList[Int(entry.x)].RecodeDays{
 
        return a == "" ? "" : String(Int(entry.y))+"%"
        }
        return ""
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecodeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecodeCell", for: indexPath)as! RecodeCell
        cell.layer.cornerRadius = 7
        cell.clipsToBounds = true
        
        let recodelist = RecodeList[indexPath.row]
        cell.RecodeDay.text=recodelist.RecodeDays
        cell.RecodeAchievementRatio.text=recodelist.RecodeAchievementRatio!
        cell.backgroundColor=UIColor.white
        if RecodeList[indexPath.row].RecodeDays==""{
            cell.RecodeAchievementRatio.text=""
            cell.recodePercent.text=""
            cell.backgroundColor=collectionView.backgroundColor
        }

        return cell
    }

    func setChart() {

        PageCount=(RecodeList.count/6)
        let Remainder=RecodeList.count%6

        if  RecodeList.count == 0{
            let appendValue = Recode()
            appendValue.RecodeDays=""
            appendValue.RecodeAchievementRatio="0"
            PageCount=PageCount+1
            for _ in 0..<6{
                RecodeList.append(appendValue)
            }
        }
        
        if  Remainder != 0{
            let appendValue = Recode()
            appendValue.RecodeDays=""
            appendValue.RecodeAchievementRatio="0"
            PageCount=PageCount+1
            for _ in 0..<(6-Remainder){
                RecodeList.append(appendValue)
            }
        }
        var dataEntries:[BarChartDataEntry] = []

        for i in ((barChartPage-1)*6)..<(6*barChartPage){
            let value:Double=Double(RecodeList[i].RecodeAchievementRatio!)!
            let Entries = BarChartDataEntry(x: Double(i), y: value)
            dataEntries.append(Entries)
        }
         for i in 0..<RecodeList.count{
            days.append(RecodeList[i].RecodeDays!)
         }
   
        barChartView.setVisibleXRangeMaximum(6)
        let chartDataSet = BarChartDataSet(entries: dataEntries)
         let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        
        chartDataSet.colors = [.orange]
        chartDataSet.valueTextColor=UIColor.orange
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/68.9){
            chartDataSet.valueFont=font
        }
        
         let xAxisValue = barChartView.xAxis
         xAxisValue.valueFormatter = axisFormatDelegate
        chartDataSet.valueFormatter = valueFormatDelegate
        
        barChartView.rightAxis.axisMinimum = 0.0
        barChartView.leftAxis.axisMinimum = 0.0
        barChartView.rightAxis.axisMaximum=130
        barChartView.leftAxis.axisMaximum=130
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.axisLineColor=bgColor
        barChartView.xAxis.labelTextColor=UIColor.orange
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/68.9){
            barChartView.xAxis.labelFont=font
        }
        barChartView.xAxis.labelCount = 30
        barChartView.xAxis.granularity = 1
        barChartView.leftAxis.granularity = 1.0
        barChartView.leftAxis.labelCount = 5
        barChartView.highlighter = nil
        barChartView.doubleTapToZoomEnabled = false
        barChartView.chartDescription?.text = ""
        barChartView.rightAxis.enabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.dragEnabled = false
        barChartView.legend.enabled = false
        barChartView.leftAxis.enabled=false
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled=false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuart)

     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setup()
        axisFormatDelegate = self
        valueFormatDelegate = self
        setChart()
    }
    
    func setup(){
        resultLabel.text="達成回数:"+String(RecodeList.filter{$0.RecodeAchievementRatio == "100"}.count)+"回"
        
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/29.8){
            resultLabel.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/35.8){
            pagePluss.titleLabel?.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/35.8){
            pageMinus.titleLabel?.font=font
        }
        if let font=UIFont.init(name: "Hiragino Maru Gothic ProN", size:mainBoundSize.height/44.8){
            returnButton.titleLabel?.font=font
        }
    }
    
    func setupCollectionView(){
        collectionView.register(UINib(nibName: "RecodeCellClass", bundle: nil),forCellWithReuseIdentifier:"RecodeCell")
        
        let cellSize:CGFloat = ((self.view.bounds.width-8)/6)-3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 7, left: 4, bottom: 4, right: 4)
        layout.minimumLineSpacing=3
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize(width:cellSize, height:cellSize)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor=bgColor
    }

    @IBAction func MoveOn(_ sender: Any) {
        if barChartPage != PageCount{
        barChartPage=barChartPage+1
        setChart()
        }
    }
    
    @IBAction func Return(_ sender: Any) {
        if barChartPage != 1{
        barChartPage=barChartPage-1
        setChart()
        }
    }
    
}

