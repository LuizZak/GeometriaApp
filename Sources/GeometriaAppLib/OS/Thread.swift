public enum Thread {
    /// Conenience for ``System/sleep``, with a less confusing name that doesn't
    /// imply that the whole system will wait.
    static func sleep(milliseconds: Int64) {
        System.sleep(milliseconds: milliseconds)
    }
}
