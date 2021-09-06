//
//  ViewModelObject.swift
//  Healthcare
//
//  Created by T T on 2021/06/09.
//

import Foundation
import SwiftUI
import Combine

protocol ViewModelObject: ObservableObject {
    associatedtype Input: InputObject
    associatedtype Binding: BindingObject
    associatedtype Output: OutputObject
    var input: Input { get }
    var binding: Binding { get }
    var output: Output { get }
}
extension ViewModelObject where Binding.ObjectWillChangePublisher == ObservableObjectPublisher, Output.ObjectWillChangePublisher == ObservableObjectPublisher {
    var objectWillChange: AnyPublisher<Void, Never> {
        return Publishers.Merge(binding.objectWillChange, output.objectWillChange).eraseToAnyPublisher()
    }
}

protocol InputObject: AnyObject { }
protocol OutputObject: ObservableObject {}
protocol BindingObject: ObservableObject {}
@propertyWrapper struct BindableObject<T: BindingObject> {
    @dynamicMemberLookup struct Wrapper {
        fileprivate let binding: T
        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<T, Value>) -> Binding<Value> {
            return .init(
                get: { self.binding[keyPath: keyPath] },
                set: { self.binding[keyPath: keyPath] = $0 }
            )
        }
    }
    var wrappedValue: T
    var projectedValue: Wrapper {
        return Wrapper(binding: wrappedValue)
    }
}
