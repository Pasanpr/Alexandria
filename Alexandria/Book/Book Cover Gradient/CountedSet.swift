//
//  CountedSet.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 10/13/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

public struct CountedSet<Element: Hashable> {
    private var contents: Set<Element>
    private var elementCounter: [Element: Int]
    
    /// The number of elements in the CountedSet
    public var count: Int { return contents.count }
    
    /// Returns `true` is the CountedSet is empty
    public var isEmpty: Bool { return contents.isEmpty }
    
    /// The elements of the CountedSet as an array
    public var elements: [Element] { return Array(self.contents) }
    
    public init() {
        contents = []
        elementCounter = [:]
    }
    
    init(minimumCapacity: Int) {
        self.init()
        contents.reserveCapacity(minimumCapacity)
        elementCounter.reserveCapacity(minimumCapacity)
    }
    
    /// Returns `true` if the CountedSet contains `element`
    public func contains(element: Element) -> Bool {
        return contents.contains(element)
    }
    
    /// Returns the element with the highest count value
    public var first: Element? {
        typealias ElementCount = (element: Element, count: Int)
        let elementsWithCounts: [ElementCount] = elementCounter.map({$0}).sorted(by: { first, second in first.count > second.count})
        guard let first = elementsWithCounts.first else { return nil }
        return first.element
    }
    
    /// Returns the elements of the CountedSet as an array sorted by the element counts
    public var sortedElements: [Element] {
        return elements.sorted(by: { count(for: $0) > count(for: $1) })
    }
    
    /// Add `element` to CountedSet. If CountedSet already contains `element` the
    /// element count is incremented
    public mutating func add(_ element: Element) {
        contents.insert(element)
        let count = elementCounter[element] ?? 0
        elementCounter[element] = count + 1
    }
    
    /// Add `elements` to CountedSet. If CountedSet already contains an element
    /// the element count is incremented
    ///
    /// - Parameter elements: new elements
    public mutating func add(_ elements: Element...) {
        let _ = elements.map { add($0) }
    }
    
    /// Removes the specified element from the CountedSet. Sets `element` count to 0.
    @discardableResult public mutating func remove(_ element: Element) -> Element? {
        guard var count = elementCounter[element], count > 0 else { return nil }
        count -= 1
        elementCounter[element] = Swift.max(count, 0)
        if count <= 0 {
            return contents.remove(element)
        }
        
        return element
    }
    
    
    /// Removes all members from the set. Counts are invalidated
    ///
    /// - Parameter keepingCapacity: If true, the counted set's buffer capacity is preserved; if false, the underlying buffer is released. The default is false.
    public mutating func removeAll(keepingCapacity: Bool = false) {
        contents.removeAll(keepingCapacity: keepingCapacity)
        elementCounter.removeAll(keepingCapacity: keepingCapacity)
    }
    
    /// Returns count for specified `element`. If the CountedSet does not contain
    /// `element`, 0 is returned.
    public func count(for element: Element) -> Int {
        return elementCounter[element] ?? 0
    }
    
    /// Sets the count of `element` to specified value. If value is 0, the element
    /// is removed from the CountedSet. If the CountedSet does not contain `element`,
    /// it is added and the count is set to specified value.
    @discardableResult public mutating func setCount(_ count: Int, for element: Element) -> Bool {
        precondition(count >= 0, "Count must be zero or a positive integer")
        
        if count > 0 && !contains(element: element) {
            add(element)
        }
        
        elementCounter[element] = count
        
        if count <= 0 {
            remove(element)
        }
        
        return true
    }
    
    /// Returns a new counted set containing the elements of the set that satisfy the given predicate.
    ///
    /// - Parameter includeElement: A closure that takes an element as its argument and returns a Boolean value indicating whether the element should be included in the returned set.
    /// - Returns: A counted set of the elements that isIncluded allows. Element counts are maintained.
    public func filter(includeElement: (Element) throws -> Bool) rethrows -> CountedSet<Element> {
        let newContents = try contents.filter(includeElement)
        var newCountedSet = CountedSet()
        
        for element in newContents {
            newCountedSet.add(element)
            let count = elementCounter[element] ?? 0
            newCountedSet.setCount(count, for: element)
        }
        
        return newCountedSet
    }
    
    /*
     init(array: [Any])
     init(set: Set<AnyHashable>)
     init(minimumCapacity: Int)
     removeFirst()
     
     filter(using: NSPredicate)
     addObjects(from: [Any])
     
     minus(Set<AnyHashable>
     intersect(Set<AnyHashable>)
     setSet(Set<AnyHashable>)
     */
}


// MARK: SetAlgebra

extension CountedSet: SetAlgebra {
    public func union(_ other: CountedSet<Element>) -> CountedSet<Element> {
        var currentSet = self
        
        for element in other {
            currentSet.add(element)
        }
        
        return currentSet
    }
    
    public func intersection(_ other: CountedSet<Element>) -> CountedSet<Element> {
        return filter { other.contains(element: $0) }
    }
    
    public func symmetricDifference(_ other: CountedSet<Element>) -> CountedSet<Element> {
        let common = intersection(other)
        let uniqueSelf = self.filter { !common.contains(element: $0) }
        let uniqueOther = other.filter { !common.contains(element: $0) }
        return uniqueSelf.union(uniqueOther)
    }
    
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        add(newMember)
        return (true, newMember)
    }
    
    public mutating func update(with newMember: Element) -> Element? {
        add(newMember)
        return newMember
    }
    
    public mutating func formUnion(_ other: CountedSet<Element>) {
        for element in other {
            add(element)
        }
    }
    
    public mutating func formIntersection(_ other: CountedSet<Element>) {
        self = filter { other.contains(element: $0) }
    }
    
    public mutating func formSymmetricDifference(_ other: CountedSet<Element>) {
        let common = intersection(other)
        let uniqueSelf = self.filter { !common.contains(element: $0) }
        let uniqueOther = other.filter { !common.contains(element: $0) }
        self = uniqueSelf.union(uniqueOther)
    }
    
    
}

// MARK: Collection

extension CountedSet: Collection {
    public subscript(position: Set<Element>.Index) -> Element {
        return contents[position]
    }
    
    public var startIndex: SetIndex<Element> {
        return contents.startIndex
    }
    
    public var endIndex: Set<Element>.Index {
        return contents.endIndex
    }
    
    public func index(after i: Set<Element>.Index) -> Set<Element>.Index {
        return contents.index(after: i)
    }
    
    public func makeIterator() -> SetIterator<Element> {
        return contents.makeIterator()
    }
}

// MARK: ExpressibleByArrayLiteral

extension CountedSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CountedSet.Element...) {
        self.init()
        for element in elements {
            add(element)
        }
    }
}

// MARK: Equatable
extension CountedSet: Equatable {
    public static func ==(lhs: CountedSet<Element>, rhs: CountedSet<Element>) -> Bool {
        return lhs.contents == rhs.contents && lhs.elementCounter == rhs.elementCounter
    }
}

// MARK: Hashable

extension CountedSet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(contents)
    }
}


// MARK: CustomStringConvertible

extension CountedSet: CustomStringConvertible {
    public var description: String {
        return contents.reduce("CountedSet:\n", { (sum, element) in
            sum + "\t- \(element): \(count(for: element))\n"
        })
    }
}






