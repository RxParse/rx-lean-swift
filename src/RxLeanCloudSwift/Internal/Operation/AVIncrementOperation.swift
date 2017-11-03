//
//  AVIncrementOperation.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 03/11/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVIncrementOperation: IAVFieldOperation {

    func add(lhs: inout Any, rhs: Any) -> Any {
        switch (lhs, rhs) {
        case let (i as Int, j as Int):
            lhs = i + j
        case let (d as Double, e as Double):
            lhs = d + e
        case let (i as Int, d as Double):
            lhs = Double(i) + d
        case let (d as Double, i as Int):
            lhs = Double(i) + d
        default:
            lhs = 0
        }
        return lhs
    }

    var _amount: Any
    public var amount: Any {
        get {
            return self._amount
        }
    }
    init(_amount: Any) {
        self._amount = _amount
    }
    public func encode() -> Any {
        return ["__op": "Increment", "amount": self.amount];
    }

    public func mergeWithPrevious(previous: IAVFieldOperation?) -> IAVFieldOperation {
        if previous == nil {
            return self
        } else if previous is AVDeleteOperation {
            return AVSetOperation(value: self.amount)
        } else if previous is AVSetOperation {
            var otherAmount = (previous as! AVSetOperation).value
            if self.validNumeric(obj: otherAmount) {
                let myAmount = self.amount
                let afterAdded = self.add(lhs: &otherAmount, rhs: myAmount)
                return AVSetOperation(value: afterAdded)
            }
        }
        if previous is AVIncrementOperation {
            var otherAmount = (previous as! AVIncrementOperation).amount
            let myAmount = self.amount
            let afterAdded = self.add(lhs: &otherAmount, rhs: myAmount)
            return AVIncrementOperation(_amount: afterAdded)
        }
        return self
    }

    func validNumeric(obj: Any) -> Bool {
        return obj is Int
            || obj is Int8
            || obj is Int16
            || obj is Int32
            || obj is Int64
            || obj is Character
            || obj is Float
            || obj is Double
    }

    public func apply(oldValue: Any?, key: String) -> Any {
        var otherAmount = oldValue == nil ? 0 : oldValue!
        let myAmount = self.amount
        return self.add(lhs: &otherAmount, rhs: myAmount)
    }
}

