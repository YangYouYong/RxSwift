//
//  SimpleTableViewExampleViewController.swift
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

class SimpleViewHeader: RxTableViewSectionProxy {
    
    public override class func heightForSection(withItem item: AnyObject, indexPath: IndexPath, sectionType: HeightType) -> CGFloat {
        
        if sectionType == .header {
            return 50
        } else if sectionType == .footer {
            return 0.01
        }else{
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

class SimpleTableViewExampleViewController : ViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        let items = Observable.just(
            (0..<20).map { "\($0)" }
        )

        items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by: disposeBag)
        
//        items.bind(to: tableView.rx.sectionViews(sectionIdentifier: "sectionIdentifier", SectionType: SimpleViewHeader.self)){
//            (row, element, view, viewType) in
//            view.contentView.backgroundColor = .yellow
//            view.textLabel?.text = "\(element) @ section \(row)"
//        }.disposed(by: disposeBag)

        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext:  { value in
                DefaultWireframe.presentAlert("Tapped `\(value)`")
            })
            .disposed(by: disposeBag)

        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(onNext: { indexPath in
                DefaultWireframe.presentAlert("Tapped Detail @ \(indexPath.section),\(indexPath.row)")
            })
            .disposed(by: disposeBag)

    }

}
