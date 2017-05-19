//
//  SimpleTableViewExampleSectionedViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class FirstViewHeader: SimpleViewHeader {
    
    public override class func heightForSection(withItem item: AnyObject, indexPath: IndexPath, sectionType: HeightType) -> CGFloat {
        
        if sectionType == .header {
            if indexPath.section == 0 {
                return 65
            }
            return 50
        } else if sectionType == .footer {
            return 0.01
        }else{
            if indexPath.section > 0 {
                return 50
            }
            return 70
        }
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        // add subViews
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class SecondViewHeader: SimpleViewHeader {
    
    public override class func heightForSection(withItem item: AnyObject, indexPath: IndexPath, sectionType: HeightType) -> CGFloat {
        
        if sectionType == .header {
            if indexPath.section == 1 {
                return 55
            }
            return 50
        } else if sectionType == .footer {
            return 0.01
        }else{
            if indexPath.section > 0 {
                return 50
            }
            return 70
        }
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        // add subViews
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class ThirdViewHeader: SimpleViewHeader {
    
    public override class func heightForSection(withItem item: AnyObject, indexPath: IndexPath, sectionType: HeightType) -> CGFloat {
        
        if sectionType == .header {
            if indexPath.section == 2 {
                return 35
            }
            return 50
        } else if sectionType == .footer {
            return 0.01
        }else{
            if indexPath.section > 0 {
                return 50
            }
            return 70
        }
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        // add subViews
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class SimpleTableViewExampleSectionedViewController
    : ViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

//    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        let dataSource = self.dataSource
//
//        let items = Observable.just([
//            SectionModel(model: "First section", items: [
//                    1.0,
//                    2.0,
//                    3.0
//                ]),
//            SectionModel(model: "Second section", items: [
//                    1.0,
//                    2.0,
//                    3.0
//                ]),
//            SectionModel(model: "Third section", items: [
//                    1.0,
//                    2.0,
//                    3.0
//                ])
//            ])
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let dataSource = self.dataSource
            
            let items = Observable.just([
                SectionModel(model: "First section", items: [
                    1.0,
                    2.0,
                    3.0
                    ]),
                SectionModel(model: "Second section", items: [
                    1.0,
                    2.0,
                    3.0
                    ]),
                SectionModel(model: "Third section", items: [
                    1.0,
                    2.0,
                    3.0
                    ])
                ])
            
            dataSource.configureCell = { (_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
                return cell
            }
            
            dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            }
            
            items
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            
            tableView.rx
                .itemSelected
                .map { indexPath in
                    return (indexPath, dataSource[indexPath])
                }
                .subscribe(onNext: { indexPath, model in
                    DefaultWireframe.presentAlert("Tapped `\(model)` @ \(indexPath)")
                })
                .disposed(by: disposeBag)
            
            tableView.rx
                .setDelegate(self)
                .disposed(by: disposeBag)
        
//        let registerSections:[(String,RxTableViewSectionProxy.Type, Int, HeightType)]
//            
//            = [("sectionIdentifier", FirstViewHeader.self, 0, .header),
//               ("sectionIdentifier1", FirstViewHeader.self, 0, .footer),
//               ("sectionIdentifier2", SecondViewHeader.self, 1, .header),
//               ("sectionIdentifier3", SecondViewHeader.self, 1, .footer),
//               ("sectionIdentifier4", ThirdViewHeader.self, 2, .footer),
//               ("sectionIdentifier5", ThirdViewHeader.self, 2, .footer),
//               ("sectionIdentifier", FirstViewHeader.self, 0, .row)]
//        
//        items.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)){ (row, element, cell) in
//            cell.textLabel?.text = "\(element) @ row \(row)"
//            print("cell inited \(row)")
//            }
//            .disposed(by: disposeBag)
//        
//        items.bind(to: tableView.rx.sectionViews(registerSections)){
//            (row, element, view, viewType) in
//            
//            if row.section == 0 {
//                let v = view as! FirstViewHeader
//                v.contentView.backgroundColor = .yellow
//                v.textLabel?.text = "\(element) @ section \(row)"
//            }
//            
//            if row.section == 1 {
//                let v = view as! SecondViewHeader
//                v.contentView.backgroundColor = .cyan
//                v.textLabel?.text = "\(element) @ section \(row)"
//            }
//            
//            if row.section == 2 {
//                let v = view as! SecondViewHeader
//                v.contentView.backgroundColor = .magenta
//                v.textLabel?.text = "\(element) @ section \(row)"
//            }
//            }.disposed(by: disposeBag)
    }

    // to prevent swipe to delete behavior
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
