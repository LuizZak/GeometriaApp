#if canImport(Geometria)
import Geometria
#endif

extension MatrixType {
    /// Returns an array of the rows of this matrix.
    public func rows() -> [[Scalar]] {
        var values: [[Scalar]] = .init(repeating: [], count: rowCount)

        for row in 0..<rowCount {
            for column in 0..<columnCount {
                values[row].append(self[column, row])
            }
        }

        return values
    }
    
    /// Returns an array of the columns of this matrix.
    public func columns() -> [[Scalar]] {
        var values: [[Scalar]] = .init(repeating: [], count: columnCount)

        for column in 0..<columnCount {
            for row in 0..<rowCount {
                values[column].append(self[column, row])
            }
        }

        return values
    }
}
