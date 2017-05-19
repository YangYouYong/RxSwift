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
    : ViewController {
    @IBOutlet weak var tableView: UITableView!

    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()

    let delegate = RxTableViewSectionedReloadDelegate<SectionModel<String, Double>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource
        let delegate = self.delegate
        
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
        
        delegate.configureSection = { (_, tv, indexPath, element, type) in
            var identifier = "section"
            var sectionClass: AnyClass = FirstViewHeader.self
            if indexPath.section == 0 {
                tv.register(sectionClass, forHeaderFooterViewReuseIdentifier: identifier)
            }else if indexPath.section == 1 {
                identifier = "FirstSection"
                sectionClass = SecondViewHeader.self
                tv.register(sectionClass, forHeaderFooterViewReuseIdentifier: identifier)
            }else{
                identifier = "SecondSection"
                sectionClass = ThirdViewHeader.self
                tv.register(sectionClass, forHeaderFooterViewReuseIdentifier: identifier)
            }

            var v: RxTableViewSectionProxy
            if let view = tv.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? RxTableViewSectionProxy {
                v = view
            }else {
                v = RxTableViewSectionProxy(reuseIdentifier: identifier)
            }
            v.textLabel?.text = "\(element)"
            v.contentView.backgroundColor = .randomColor
            print("react____\(v)")
            return v
        }
        
        delegate.sectionAndCellHeight = { (_, tv, indexPath, element, type) in
            var sectionClass: SimpleViewHeader.Type = FirstViewHeader.self
            if indexPath.section == 0 {
            }else if indexPath.section == 1 {
                sectionClass = SecondViewHeader.self
            }else{
                sectionClass = ThirdViewHeader.self
            }
            
            return sectionClass.heightForSection(withItem: element as AnyObject, indexPath: indexPath, sectionType: type)
        }
        delegate.cellHeight = { (_, tv, indexPath, element, type) in
            var sectionClass: SimpleViewHeader.Type = FirstViewHeader.self
            if indexPath.section == 0 {
            }else if indexPath.section == 1 {
                sectionClass = SecondViewHeader.self
            }else{
                sectionClass = ThirdViewHeader.self
            }
            
            return sectionClass.heightForSection(withItem: element as AnyObject, indexPath: indexPath, sectionType: type)
        }
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        items.bind(to: tableView.rx.sectionViews(delegate: delegate))
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
    }
}

public extension UIColor {
    public class var randomColor: UIColor {
        let randomNum = CGFloat(arc4random()%256)
        return UIColor(red: randomNum/255.0, green: randomNum/255.0, blue: randomNum/255.0, alpha: 1.0)
    }
}
