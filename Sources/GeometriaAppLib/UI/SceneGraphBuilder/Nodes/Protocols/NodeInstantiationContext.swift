/// Provides concretized initial values for generating `SceneGraphNode`s with.
public protocol NodeInstantiationContext {
    /// Attempts to fetch a required input with a given label.
    ///
    /// Throws error if fetching fails and cannot produce a valid instance of `T`.
    func fetch<T>(label: String) throws -> T

    /// Attempts to fetch an optional input value with a given label.
    ///
    /// If no input value was provided, returns `nil`.
    ///
    /// May throw errors if any unexpected error was raised while attempting to
    /// instantiate a present value for `T`.
    func fetchOptional<T>(label: String) throws -> T?
}
