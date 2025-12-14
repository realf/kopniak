//
//  Isolated.swift
//  Kopniak
//
//  Created by alf on 13.12.2025.
//

import Foundation

/// Actor wrapper for isolation of non-sendable types
actor Isolated<Value> {
    private let value: Value

    init(_ value: Value) {
        self.value = value
    }

    func withValue(_ body: (Value) throws -> Void) rethrows {
        try body(value)
    }
}
