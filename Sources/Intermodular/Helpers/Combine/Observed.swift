//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow

@propertyWrapper
public struct Observed<Value: ObservableObject> {
    @MutableValueBox
    public var wrappedValue: Value
    
    private var subscription: AnyCancellable?
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init<P: PropertyWrapper>(wrappedValue: P) where P.WrappedValue == Value {
        self._wrappedValue = .init(AnyMutablePropertyWrapper(unsafelyAdapting: wrappedValue))
    }

    public init<P: MutablePropertyWrapper>(wrappedValue: P) where P.WrappedValue == Value {
        self._wrappedValue = .init(wrappedValue)
    }
        
    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value where EnclosingSelf.ObjectWillChangePublisher: _opaque_VoidSender {
        get {
            if object[keyPath: storageKeyPath].subscription == nil {
                object[keyPath: storageKeyPath].subscribe(_enclosingInstance: object)
            }
            
            return object[keyPath: storageKeyPath].wrappedValue
        } set {
            object[keyPath: storageKeyPath].wrappedValue = newValue
            object[keyPath: storageKeyPath].subscribe(_enclosingInstance: object)
        }
    }
    
    mutating func subscribe<EnclosingSelf: ObservableObject>(
        _enclosingInstance: EnclosingSelf
    ) where EnclosingSelf.ObjectWillChangePublisher: _opaque_VoidSender {
        subscription = wrappedValue
            .objectWillChange
            .publish(to: _enclosingInstance.objectWillChange)
            .sink()
    }
}
