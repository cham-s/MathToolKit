//
//  MathToolKit.swift
//  MathToolKit
//
//  Created by chams on 05/11/2019.
//

import Foundation

// MARK: - Tuple
public struct Tuple<T: Numeric>: MutableCollection {
    public typealias Index = Array<T>.Index
    public typealias Element = Array<T>.Element
    
    var values: [T]

    public var startIndex: Index { values.startIndex }
    public var endIndex: Index { values.endIndex }
    
    public subscript(position: Index) -> T {
        get {
            return values[position]
        }
        
        set {
            values[position] = newValue
        }
    }
    
    public func index(after i: Index) -> Index {
        return values.index(after: i)
    }
    
    mutating func append(_ newElement: T) {
        self.values.append(newElement)
    }
}

// MARK: - Tuple operations
extension Tuple {
    public static func *(left: Tuple, right: Tuple) -> T {
        assert(isValidOperation(left: right, right: left), "Unbalanced tuples")
        var result: T = 0
        for i in 0..<right.count {
            result += right[i] * left[i]
        }
        return result
    }
    
    public static func +(left: Tuple, right: Tuple) -> Tuple {
        assert(isValidOperation(left: right, right: left), "Unbalanced tuples")
        var result: Tuple = []
        for i in 0..<right.count {
            result.append(left[i] + right[i])
        }
        
        return result
    }
    
    public static func -(left: Tuple, right: Tuple) -> Tuple {
        assert(isValidOperation(left: right, right: left), "Unbalanced tuples")
        var result: Tuple = []
        for i in 0..<right.count {
            result.append(left[i] - right[i])
        }
        
        return result
    }
    
    public static func *(left: T, right: Tuple) -> Tuple {
        return Tuple(values: right.map { left * $0 })
    }
    
    private static func isValidOperation(left: Tuple, right: Tuple) -> Bool {
        return left.count == right.count
    }
}


// MARK: - Tuple: Description
extension Tuple: CustomStringConvertible where Element: LosslessStringConvertible {
    public var description: String {
        var output = "( "
        let replaced = values.map { String($0) }.joined(separator: ", ")
        output += "\(replaced) )"
        
        return output
    }
}

// MARK: - Tuple: Array Literal Format
extension Tuple: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.values = elements
    }
}


// MARK: - Matrix
public struct Matrix {
    public var rowsSize: Int
    public var columnsSize: Int
    public var rows: [[Double]] {
        var result: [[Double]] = []
        for currentStart in stride(from: 0, to: columnsSize * rowsSize, by: rowsSize) {
            result.append(Array(grid[currentStart..<rowsSize + currentStart]))
        }
        return result
    }
    
    public var columns: [[Double]] {
        var result: [[Double]] = []
        for i in 0..<columnsSize {
            var column: [Double] = []
            for row in rows {
                column.append(row[i])
            }
            result.append(column)
        }
        return result
    }
        
    private var grid: [Double]
    public init(rows: Int, columns: Int) {
        self.rowsSize = rows
        self.columnsSize = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    
    public init?(_ values: [[Double]]) {
        guard let firstCount = values.first?.count else {
            return nil
        }
        if let _ = values.first(where: { $0.count != firstCount })
        {
            return nil
        }
        self.rowsSize = values.count
        self.columnsSize = firstCount
        self.grid = values.flatMap { $0 }
    }
    
    private func indexIsValid(row: Int, column: Int) -> Bool {
        return column >= 0 && column < columnsSize && row >= 0 && row <= rowsSize
    }
    
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(columnsSize * row) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(columnsSize * row) + column] = newValue
        }
    }
}

// MARK: - Matrix: Description
extension Matrix: CustomStringConvertible {
    public var description: String {
        var output = ""
        for row in rows {
            let description = row.map { String($0) }
                .joined(separator: " ")
            output += "[ \(description) ]\n"
        }
        return output
    }
}



// MARK: - Matrix: Operations
extension Matrix {
    public static func +(left: Matrix, right: Matrix) -> Matrix {
        assert(isValidAddition(left: left, right: right))
        var result = Matrix(rows: right.rowsSize, columns: right.columnsSize)
        for i in 0..<right.rowsSize {
            for j in 0..<right.columnsSize {
                result[i, j] = left[i, j] + right[i, j]
            }
        }
        return result
    }
    
    public static func -(left: Matrix, right: Matrix) -> Matrix {
        assert(isValidAddition(left: left, right: right))
        var result = Matrix(rows: right.rowsSize, columns: right.columnsSize)
        for i in 0..<right.rowsSize {
            for j in 0..<right.columnsSize {
                result[i, j] = left[i, j] - right[i, j]
            }
        }
        return result
    }
    
    public static func *(left: Matrix, right: Matrix) -> Matrix {
        var result = Matrix(rows: left.rowsSize, columns: right.columnsSize)
        for i in 0..<right.rowsSize {
            for j in 0..<left.columnsSize {
                let leftRow = Tuple(values: left.rows[i])
                let rightColumn = Tuple(values: right.columns[j])
                result[i, j] = leftRow * rightColumn
            }
        }
        
        return result
    }
    
    public static func *(left: Double, right: Matrix) -> Matrix {
        var result = Matrix(rows: right.rowsSize, columns: right.columnsSize)
        for i in 0..<right.rowsSize {
            for j in 0..<right.columnsSize {
                result[i, j] = right[i, j] * left
            }
        }
        return result
    }
    
    static private func isValidAddition(left: Matrix, right: Matrix) -> Bool {
        return left.columnsSize == right .columnsSize &&
            left.rowsSize == right.rowsSize
    }
    
    static private func isValiProduct(left: Matrix, right: Matrix) -> Bool {
        return left.columnsSize == right.rowsSize
    }
}

// MARK: - Quadrant
public enum Quadrant {
    case first
    case second
    case third
    case fourth
    case origin

    public init(x: Double, y: Double) {
        switch (x, y) {
        case (0.0, 0.0):
            self = .origin
        case (1.0..., 1.0...):
            self = .first
        case (...1.0, 1.0...):
            self = .second
        case (...1.0, ...1.0):
            self = .third
        default:
            self = .fourth
        }
    }
}

// MARK: - Quadrant: Description
extension Quadrant: CustomStringConvertible {
    public var description: String {
        let quadrant = self == .origin ? "\(self)" : "\(self) quadrant"
        return "The point is located at the \(quadrant)."
    }
}


// MARK: - Angle
public struct Angle {
    var degrees: Double
    var radians: Double
    
    public init(radians: Double) {
        self.radians = radians
        self.degrees = (radians * 180.0) / Double.pi
    }
    
    public init(degrees: Double) {
        self.degrees = degrees
        self.radians = (degrees * Double.pi) / 180.0
    }
}

// MARK: - Angle: Description
extension Angle: CustomStringConvertible {
    public var description: String { "\(degrees) degrees, \(radians) radians." }
}

// MARK: - Vector Notation
public enum VectorNotation {
    case column, component, unit
}


// MARK: - Vector2D
public struct Vector2D {
    public var x = 0.0, y = 0.0
    public var magnitude: Double { sqrt(pow(x, 2) + pow(y, 2)) }
    public var notation: VectorNotation
    public var quadrant: Quadrant {
        get {
            Quadrant(x: x, y: y)
        }
    }
    public var direction: Double? {
        guard x != 0 else {
            return nil
        }
        
        let angle = Angle(radians: atan(y / x))
        
        switch quadrant {
        case .first:
            return angle.degrees
        case .second, .third:
            return angle.degrees + 180.0
        default:
            return angle.degrees + 360.0
        }
    }
    
    
    public init(x: Double, y: Double, notation: VectorNotation = .component) {
        self.x = x
        self.y = y
        self.notation = notation
    }
}


// MARK: - Vector2D: Operations
extension Vector2D {

    public static func *(left: Double, right: Vector2D) -> Vector2D {
        return Vector2D(x: left * right.x, y: left * right.y)
    }
    
    public static func -(left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x - right.x, y: left.y - right.y)
    }
    
    public static func +(left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }
}

// MARK: - Vector2D: Description
extension Vector2D: CustomStringConvertible {
    
    public var description: String {
        var output = ""
        switch notation {
        case .column:
            output += "[ \(x) ]\n[ \(y) ]\n"
        case .unit:
            output += "\(x)i + \(y)j\n"
        case.component:
            output += "(x: \(self.x), y: \(self.y))\n"
        }
        
        output += "magnitude: \(magnitude)"
        return output
    }
}
