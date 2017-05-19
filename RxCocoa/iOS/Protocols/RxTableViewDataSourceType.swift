//
//  RxTableViewDataSourceType.swift
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

/// Marks data source as `UITableView` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxTableViewDataSourceType /*: UITableViewDataSource*/ {
    
    /// Type of elements that can be bound to table view.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter tableView: Bound table view.
    /// - parameter observedEvent: Event
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) -> Void
}

public protocol RxTableViewDelegateType /*: UITableViewDataSource*/ {
    
    /// Type of elements that can be bound to table view.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter tableView: Bound table view.
    /// - parameter observedEvent: Event
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) -> Void
}
   
// MARK: BaseClass
open class RxTableViewSectionProxy
: UITableViewHeaderFooterView {
    
    open class func heightForSection(withItem item: AnyObject, indexPath: IndexPath, sectionType: HeightType) -> CGFloat {
        return 0.01
    }
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init() {
        super.init(reuseIdentifier: "")
    }
}

#endif
