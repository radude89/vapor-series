import Fluent

extension Model {
    func setValue<Value>(
        _ value: Value?,
        to keyPath: ReferenceWritableKeyPath<Self, Value>
    ) {
        if let value {
            self[keyPath: keyPath] = value
        }
    }
}
