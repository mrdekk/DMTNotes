//
//  InvalidatableComputedValue.swift
//  NotesV1
//
//  Created by Dmitry Galimzyanov on 10.11.16.
//  Copyright © 2016 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class InvalidatableComputedValue<TValue> {
    private var val: TValue?
    private var selector: () -> (TValue)

    var value: TValue {
        get {
            if val == nil {
                val = selector()
            }
            return val!
        }
    }

    func invalidate() {
        val = nil
    }

    init(_ valueFactory: @escaping () -> (TValue)) {
        val = nil
        selector = valueFactory
    }
}
