//
//  MathToolKit.swift
//  MathToolKit
//
//  Created by chams on 05/11/2019.
//

import Foundation

struct Tuple<T: Numeric>: MutableCollection {
    typealias Index = Array<T>.Index
    typealias Element = Array<T>.Element
    
    var values: [T]

    var startIndex: Index { values.startIndex }
    var endIndex: Index { values.endIndex }
    
    subscript(position: Index) -> T {
        get {
            return values[position]
        }
        
        set {
            values[position] = newValue
        }
    }
    
    func index(after i: Index) -> Index {
        return values.index(after: i)
    }
    
    mutating func append(_ newElement: T) {
        self.values.append(newElement)
    }
}

// Dot product
extension Tuple {
    static func *(left: Tuple, right: Tuple) -> T {
        assert(isValidOperation(left: right, right: left), "Unbalanced tuples")
        var result: T = 0
        for i in 0..<right.count {
            result += right[i] * left[i]
        }
        return result
    }
    
    static func +(left: Tuple, right: Tuple) -> Tuple {
        assert(isValidOperation(left: right, right: left), "Unbalanced tuples")
        var result: Tuple = []
        for i in 0..<right.count {
            result.append(left[i] + right[i])
        }
        
        return result
    }
    
    static func -(left: Tuple, right: Tuple) -> Tuple {
        assert(isValidOperation(left: right, right: left), "Unbalanced tuples")
        var result: Tuple = []
        for i in 0..<right.count {
            result.append(left[i] - right[i])
        }
        
        return result
    }
    
    static func *(left: T, right: Tuple) -> Tuple {
        return Tuple(values: right.map { left * $0 })
    }
    
    private static func isValidOperation(left: Tuple, right: Tuple) -> Bool {
        return left.count == right.count
    }
}


// Pretty Print
extension Tuple: CustomStringConvertible where Element: LosslessStringConvertible {
    var description: String {
        var output = "( "
        let replaced = values.map { String($0) }.joined(separator: ", ")
        output += "\(replaced) )"
        
        return output
    }
}

extension Tuple: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self.values = elements
    }
}


struct Matrix {
    var rowsSize: Int
    var columnsSize: Int
    var rows: [[Double]] {
        var result: [[Double]] = []
        for currentStart in stride(from: 0, to: columnsSize * rowsSize, by: rowsSize) {
            result.append(Array(grid[currentStart..<rowsSize + currentStart]))
        }
        return result
    }
    
    var columns: [[Double]] {
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
    init(rows: Int, columns: Int) {
        self.rowsSize = rows
        self.columnsSize = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    
    init?(_ values: [[Double]]) {
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
    
    subscript(row: Int, column: Int) -> Double {
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

extension Matrix: CustomStringConvertible {
    var description: String {
        var output = ""
        for row in rows {
            let description = row.map { String($0) }
                .joined(separator: " ")
            output += "[ \(description) ]\n"
        }
        return output
    }
}


extension Matrix {
    static func +(left: Matrix, right: Matrix) -> Matrix {
        assert(isValidAddition(left: left, right: right))
        var result = Matrix(rows: right.rowsSize, columns: right.columnsSize)
        for i in 0..<right.rowsSize {
            for j in 0..<right.columnsSize {
                result[i, j] = left[i, j] + right[i, j]
            }
        }
        return result
    }
    
    static func -(left: Matrix, right: Matrix) -> Matrix {
        assert(isValidAddition(left: left, right: right))
        var result = Matrix(rows: right.rowsSize, columns: right.columnsSize)
        for i in 0..<right.rowsSize {
            for j in 0..<right.columnsSize {
                result[i, j] = left[i, j] - right[i, j]
            }
        }
        return result
    }
    
    static func *(left: Matrix, right: Matrix) -> Matrix {
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
    
    static func *(left: Double, right: Matrix) -> Matrix {
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

enum Quadrant {
    case first
    case second
    case third
    case fourth
    case origin

    init(x: Double, y: Double) {
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

extension Quadrant: CustomStringConvertible {
    var description: String {
        let quadrant = self == .origin ? "\(self)" : "\(self) quadrant"
        return "The point is located at the \(quadrant)."
    }
}


/*
 Mark: Angle
 */
struct Angle {
    var degrees: Double
    var radians: Double
    
    init(radians: Double) {
        self.radians = radians
        self.degrees = (radians * 180.0) / Double.pi
    }
    
    init(degrees: Double) {
        self.degrees = degrees
        self.radians = (degrees * Double.pi) / 180.0
    }
}

extension Angle: CustomStringConvertible {
    var description: String { "\(degrees) degrees, \(radians) radians." }
}

struct Vector2D {
    var x = 0.0, y = 0.0
    var magnitude: Double { sqrt(pow(x, 2) + pow(y, 2)) }
    var direction: Double? {
        guard x != 0 else {
            return nil
        }
        
        let angle = Angle(radians: atan(y / x))
        let quadrant = Quadrant(x: x, y: y)
        
        switch quadrant {
        case .first:
            return angle.degrees
        case .second:
            return angle.degrees + 180.0
        case .third:
            return angle.degrees + 180.0
        default:
            return angle.degrees + 360.0
        }
    }
    var notation: VectorNotation
    
    init(x: Double, y: Double, notation: VectorNotation = .component) {
        self.x = x
        self.y = y
        self.notation = notation
    }
    
    enum VectorNotation {
        case column, component, unit
    }
}

extension Vector2D {

    static func *(left: Double, right: Vector2D) -> Vector2D {
        return Vector2D(x: left * right.x, y: left * right.y)
    }
    
    static func -(left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func +(left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }
}

extension Vector2D: CustomStringConvertible {
    
    var description: String {
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
