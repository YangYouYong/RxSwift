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
        return 55.0
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
    , RxTableViewDelegateType {
    typealias Element = S
    
    override init(_ viewFactory: ViewFactory? = nil , heightFactory: @escaping HeightFactory) {
        super.init(viewFactory, heightFactory: heightFactory)
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { tableViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            tableViewDataSource.tableView(tableView, observedElements: sections)
            }.on(observedEvent)
    }
}

class RxTableViewReactiveArrayDelegate<Element>
    : _RxTableViewReactiveArrayDelegate
    , SectionedViewDataSourceType {
    
    
    typealias HeightFactory = (UITableView, IndexPath, Element, HeightType) -> CGFloat
    typealias ViewFactory = (UITableView, IndexPath, Element, HeightType) -> RxTableViewSectionProxy
    
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
    let viewFactory: ViewFactory?
    
    init( _ viewFactory: ViewFactory? = nil , heightFactory: @escaping HeightFactory) {
        self.heightFactory = heightFactory
        self.viewFactory = viewFactory
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let model = itemModels?[indexPath.row] {
            return heightFactory(tableView, indexPath, model, .row)
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        if let model = itemModels?[section] {
            return heightFactory(tableView, headerFooterIndexPath, model, .header)
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        if let model = itemModels?[section] {
            return heightFactory(tableView, headerFooterIndexPath, model, .footer)
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        guard let factory = viewFactory , let model = itemModels?[section] else {
            return nil
        }
        
        if heightFactory(tableView, headerFooterIndexPath, model, .header) <= 0.01 {
            return nil
        }
        return factory(tableView, headerFooterIndexPath, model, .header)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerFooterIndexPath = IndexPath(row: 0, section: section)
        guard let factory = viewFactory , let model = itemModels?[section] else {
            return nil
        }
        if heightFactory(tableView, headerFooterIndexPath, model, .footer) <= 0.01 {
            return nil
        }
        return factory(tableView, headerFooterIndexPath, model, .footer)
    }
    
    // reactive
    
    func tableView(_ tableView: UITableView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        tableView.reloadData()
    }
}


#endif
