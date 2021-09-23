//
//  Dynamic.swift
//  Feedback
//
//  Created by YuHan Hsiao on 2021/09/20.
//

import Foundation

public final class Dynamic<T> {
    public typealias Listener = (T) -> Void
    var listener: Listener?
    
    public func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    public func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    public var value: T {
        didSet {
            listener?(value)
        }
    }
    
    public init(_ v: T) {
        value = v
    }
}
