//
//  RxTableViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

// objc monkey business
class _RxTableViewReactiveArrayDataSource
    : NSObject
    , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func _tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }

    fileprivate func _tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rxAbstractMethod()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAt: indexPath)
    }
}


class RxTableViewReactiveArrayDataSourceSequenceWrapper<S: Sequence>
    : RxTableViewReactiveArrayDataSource<S.Iterator.Element>
    , RxTableViewDataSourceType {
    typealias Element = S

    override init(cellFactory: @escaping CellFactory) {
        super.init(cellFactory: cellFactory)
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { tableViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            tableViewDataSource.tableView(tableView, observedElements: sections)
        }.on(observedEvent)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxTableViewReactiveArrayDataSource<Element>
    : _RxTableViewReactiveArrayDataSource
    , SectionedViewDataSourceType {
    typealias CellFactory = (UITableView, Int, Element) -> UITableViewCell
    
    var itemModels: [Element]? = nil
    
    func modelAtIndex(_ index: Int) -> Element? {
        return itemModels?[index]
    }

    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }

    let cellFactory: CellFactory
    
    init(cellFactory: @escaping CellFactory) {
        self.cellFactory = cellFactory
    }
    
    override func _tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    override func _tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory(tableView, indexPath.item, itemModels![indexPath.row])
    }
    
    // reactive
    
    func tableView(_ tableView: UITableView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        tableView.reloadData()
    }
}

// MARK: - Delegate
    
class _RxTableViewReactiveArrayDelegate
    : NSObject
    , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // didselected
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
    
class RxTableViewReactiveArrayDelegateSequenceWrapper<S: Sequence>
    : RxTableViewReactiveArrayDelegate<S.Iterator.Element>
    , RxTableViewDataSourceType {
    typealias Element = S
    
    override init(heightFactory: @escaping HeightFactory, viewFactory: @escaping ViewFactory) {
        super.init(heightFactory: heightFactory, viewFactory: viewFactory)
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { tableViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            tableViewDataSource.tableView(tableView, observedElements: sections)
            }.on(observedEvent)
    }
}
    
// Please take a look at `DelegateProxyType.swift`
class RxTableViewReactiveArrayDelegate<Element>
    : _RxTableViewReactiveArrayDelegate
    , SectionedViewDataSourceType {
    
    
    typealias HeightFactory = (UITableView, IndexPath, Element, HeightType) -> CGFloat
    typealias ViewFactory = (UITableView, IndexPath, Element, HeightType) -> UIView?
    
    var itemModels: [Element]? = nil
    
    func modelAtIndex(_ index: Int) -> Element? {
        return itemModels?[index]
    }
    
    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }
    
    let heightFactory: HeightFactory
    let viewFactory: ViewFactory
    
    init(heightFactory: @escaping HeightFactory, viewFactory: @escaping ViewFactory) {
        self.heightFactory = heightFactory
        self.viewFactory = viewFactory
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightFactory(tableView, indexPath, itemModels![indexPath.row], .row)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        return heightFactory(tableView, headerFooterIndexPath , itemModels![section], .header)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        return heightFactory(tableView, headerFooterIndexPath , itemModels![section], .footer)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        return viewFactory(tableView, headerFooterIndexPath, itemModels![section], .header)
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        return viewFactory(tableView, headerFooterIndexPath, itemModels![section], .footer)
    }
    
    // reactive
    
    func tableView(_ tableView: UITableView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        tableView.reloadData()
    }
}


#endif
