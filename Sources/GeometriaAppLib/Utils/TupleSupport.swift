// TODO: Workaround for https://github.com/apple/swift/issues/66917 and lack of
// pack iteration (https://github.com/apple/swift-evolution/blob/main/proposals/0408-pack-iteration.md)
// in Swift 5.9
@usableFromInline
internal struct _TupleIterationStop: Error {
    @usableFromInline
    init() {
    }
}
