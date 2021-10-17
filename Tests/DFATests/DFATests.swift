//
//  DFATests.swift
//  DFATests
//
//  Created by Valeriano Della Longa on 2021/10/08.
//  Copyright © 2021 Valeriano Della Longa. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest
@testable import DFA

final class DFATests: XCTestCase {
    var sut: DFA<Character>!
    
    // MARK: - Given
    var givenNonEmptyRandomSequence: String {
        var pattern = ""
        for _ in 0..<Int.random(in: 10...100) {
            pattern.append(randomChars.randomElement()!)
        }
        
        return pattern
    }
    
    // MARK: - When
    func whenIsEmpty() {
        sut = DFA("")
    }
    
    func whenIsNotEmpty() {
        sut = DFA(givenNonEmptyRandomSequence)
    }
    
    func whenPatternIsBookExample() {
        sut = DFA(bookExampleSubstring)
    }
    
    // MARK: - Tests
    func testInit_whenSequenceIsEmpty_thenCreatesEmptyDFA() {
        sut = DFA(TestSequence(""))
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.state, sut.initialState)
        XCTAssertTrue(sut.isAtInitialState)
        XCTAssertFalse(sut.isAtFinalState)
        XCTAssertEqual(sut._states.first?.isEmpty, true)
        XCTAssertEqual(sut._states.count, 1)
        
        // same test with sequence not having contiguous buffer:
        sut = DFA(TestSequence("", hasContiguousBuffer: false))
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.state, sut.initialState)
        XCTAssertTrue(sut.isAtInitialState)
        XCTAssertFalse(sut.isAtFinalState)
        XCTAssertEqual(sut._states.first?.isEmpty, true)
        XCTAssertEqual(sut._states.count, 1)
    }
    
    func testInit_whenSequenceIsNotEmpty_thenCreatesDFAWithSameNumberOfStatesOfSequenceCount() {
        sut = DFA(TestSequence(bookExampleSubstring))
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut._states.count, bookExampleSubstring.count)
        XCTAssertEqual(sut.state, sut.initialState)
        XCTAssertTrue(sut.isAtInitialState)
        XCTAssertFalse(sut.isAtFinalState)
        XCTAssertTrue(sut._states.allSatisfy({ !$0.isEmpty }))
        
        // same test with sequence not having contiguous buffer:
        sut = DFA(TestSequence(bookExampleSubstring, hasContiguousBuffer: false))
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut._states.count, bookExampleSubstring.count)
        XCTAssertEqual(sut.state, sut.initialState)
        XCTAssertTrue(sut.isAtInitialState)
        XCTAssertFalse(sut.isAtFinalState)
        XCTAssertTrue(sut._states.allSatisfy({ !$0.isEmpty }))
    }
    
    func testInitialState() {
        whenIsEmpty()
        XCTAssertEqual(sut.initialState, 0)
        
        whenIsNotEmpty()
        XCTAssertEqual(sut.initialState, 0)
    }
    
    func testStates() {
        // We adopt the same example from the book
        // Algorithms 4th edition by Robert Sedgewick, to test that states
        // is built correctly:
        whenPatternIsBookExample()
        
        // Initial state node:
        XCTAssertEqual(sut._states[0]["A".first!], 1)
        XCTAssertEqual(sut._states[0]["B".first!, default: 0], 0)
        XCTAssertEqual(sut._states[0]["C".first!, default: 0], 0)
        
        // next states nodes
        XCTAssertEqual(sut._states[1]["B".first!], 2)
        XCTAssertEqual(sut._states[1]["A".first!], 1)
        XCTAssertEqual(sut._states[1]["C".first!, default: 0], 0)
        
        XCTAssertEqual(sut._states[2]["A".first!], 3)
        XCTAssertEqual(sut._states[2]["B".first!, default: 0], 0)
        XCTAssertEqual(sut._states[2]["C".first!, default: 0], 0)
        
        XCTAssertEqual(sut._states[3]["B".first!], 4)
        XCTAssertEqual(sut._states[3]["A".first!], 1)
        XCTAssertEqual(sut._states[3]["C".first!, default: 0], 0)
        
        XCTAssertEqual(sut._states[4]["A".first!], 5)
        XCTAssertEqual(sut._states[4]["B".first!, default: 0], 0)
        XCTAssertEqual(sut._states[4]["C".first!, default: 0], 0)
        
        XCTAssertEqual(sut._states[5]["C".first!], 6)
        XCTAssertEqual(sut._states[5]["A".first!], 1)
        XCTAssertEqual(sut._states[5]["B".first!], 4)
    }
    
    // MARK: - Computed properties tests
    func testPattern() {
        whenIsEmpty()
        XCTAssertTrue(sut.pattern.elementsEqual([]))
        
        // when is not empty:
        let sequence = givenNonEmptyRandomSequence
        sut = DFA(sequence)
        XCTAssertTrue(sut.pattern.elementsEqual(sequence))
    }
    
    func testIsEmpty() {
        whenIsEmpty()
        XCTAssertTrue(sut.isEmpty)
        
        whenIsNotEmpty()
        XCTAssertFalse(sut.isEmpty)
    }
    
    func testIsAtInitialState() throws {
        // This test relies on updateState(for:) to move from initial state to
        // different ones
        whenPatternIsBookExample()
        try XCTSkipIf(!sut.isAtInitialState, "Must be at initial state upon initialization")
        XCTAssertTrue(sut.isAtInitialState)
        XCTAssertEqual(sut.isAtInitialState, sut.state == sut.initialState)
        
        // Let's also check it is consistent by updating the state:
        for c in bookExampleSubstring {
            sut.updateState(for: c)
            try XCTSkipIf(sut.isAtInitialState, "Must be at state different from intialState upon updating using elements of pattern to update its state")
            XCTAssertFalse(sut.isAtInitialState)
            XCTAssertEqual(sut.isAtInitialState, sut.state == sut.initialState)
        }
    }
    
    func testFinalState_whenIsEmpty_thenIsEqualTo1() {
        whenIsEmpty()
        XCTAssertEqual(sut.finalState, 1)
    }
    
    func testFinalState_whenIsNotEmpty_thenIsEqualToStatesCount() {
        whenIsNotEmpty()
        XCTAssertEqual(sut.finalState, sut._states.count)
    }
    
    func testIsAtFinalState() throws {
        // This test relies on updateState(for:) to move from initial state to
        // different ones:
        whenPatternIsBookExample()
        try XCTSkipIf(!sut.isAtInitialState, "Must be at initial state upon initialization")
        
        for c in bookExampleSubstring {
            sut.updateState(for: c)
            try XCTSkipIf(sut.isAtInitialState, "Must be at state different from intialState upon updating using elements of pattern to update its state")
            XCTAssertEqual(sut.isAtFinalState, sut.state == sut._states.endIndex)
        }
    }
    
    func testUpdateState_whenIsEmpty_thenStateAlwaysStaysAtInitialState() {
        whenIsEmpty()
        for char in givenNonEmptyRandomSequence {
            sut.updateState(for: char)
            XCTAssertTrue(sut.isAtInitialState)
            XCTAssertFalse(sut.isAtFinalState)
        }
    }
    
    func testUpdateState_whenIsNotEmptyAndAtInitialState_thenUpdatingWithElementsFromPatternInSameOrderLeadsToFinalState() throws {
        whenIsNotEmpty()
        try XCTSkipIf(!sut.isAtInitialState, "Must be at initial state after initialization")
        for c in sut.pattern {
            let prevState = sut.state
            sut.updateState(for: c)
            XCTAssertEqual(sut.state, prevState + 1)
        }
        XCTAssertTrue(sut.isAtFinalState)
    }
    
    func testUpdateState_whenIsNotEmptyAndGivenElementIsNotInActualStateNode_thenResetStateToInitialState() {
        whenIsNotEmpty()
        var soFar = ""
        for c in sut.pattern {
            for charAt in soFar {
                sut.updateState(for: charAt)
            }
            soFar.append(c)
            let actualStateNode = sut._states[sut.state]
            let charNotInActualStateNode = randomChars.shuffled().first(where: { actualStateNode[$0] == nil })!
            
            sut.updateState(for: charNotInActualStateNode)
            XCTAssertTrue(sut.isAtInitialState)
        }
        XCTAssertTrue(sut.isAtInitialState)
    }
    
    func testUpdateState_whenIsNotEmptyAndGivenElementIsInActualStateNode_thenUpdatesStateToValueInNodeForSuchChar() {
        whenIsNotEmpty()
        var soFar = ""
        for c in sut.pattern {
            for charAt in soFar {
                sut.updateState(for: charAt)
            }
            soFar.append(c)
            let actualStateNode = sut._states[sut.state]
            let charInActualStateNode = sut.pattern.shuffled().first(where: { actualStateNode[$0] != nil })!
            let expectedState = actualStateNode[charInActualStateNode]
            
            sut.updateState(for: charInActualStateNode)
            XCTAssertEqual(sut.state, expectedState)
        }
    }
    
    func testResetToInitalSate_whenIsAtInitialState_thenStaysAtInitialState() throws {
        whenIsEmpty()
        try XCTSkipIf(!sut.isAtInitialState, "Must be at initialState for this test")
        
        sut.resetToInitialState()
        XCTAssertTrue(sut.isAtInitialState)
        
        whenIsNotEmpty()
        try XCTSkipIf(!sut.isAtInitialState, "Must be at initialState for this test")
        
        sut.resetToInitialState()
        XCTAssertTrue(sut.isAtInitialState)
    }
    
    func testResetToInitialState_whenIsNotAtInitialState_thenResetsStateToInitialState() throws {
        whenIsNotEmpty()
        var soFar = ""
        for c in sut.pattern {
            soFar.append(c)
            for charAt in soFar {
                sut.updateState(for: charAt)
            }
            try XCTSkipIf(sut.isAtInitialState, "Must not be at initialState for this test")
            let prevState = sut.state
            
            sut.resetToInitialState()
            XCTAssertNotEqual(sut.state, prevState)
            XCTAssertTrue(sut.isAtInitialState)
        }
    }
    
}

// MARK: - utilities
// Test environment stuff with example from Algorithms 4th Edition by Robert Sedgewick
fileprivate let bookExampleSubstring = "ABABAC"

fileprivate let bookExampleSourceString = "AABACAABABACAA"

fileprivate let rangeOfBookExample = bookExampleSourceString.range(of: bookExampleSubstring)!

fileprivate let randomChars: [Character] = {
    let charFromUInt32: (UInt32) -> Character? = {
        guard let scalar = UnicodeScalar($0) else { return nil }
        
        return Character(scalar)
    }
    
    let lettersAndNumbers = [
        UnicodeScalar("a").value...UnicodeScalar("z").value,
        UnicodeScalar("A").value...UnicodeScalar("Z").value,
        UnicodeScalar("0").value...UnicodeScalar("9").value
    ]
        .joined()
        .compactMap(charFromUInt32)
    
    
    let emojis = (0x1F601...0x1F64F as ClosedRange<UInt32>)
        .compactMap(charFromUInt32)
    
    return lettersAndNumbers + emojis
}()

fileprivate struct TestSequence<T: Hashable>: Sequence {
    typealias Element = T
    
    private var _elements: Array<Element>
    
    private let _hasContiguousBuffer: Bool
    
    init<S: Sequence>(_ sequence: S, hasContiguousBuffer: Bool = true) where S.Element == T {
        self._elements = Array(sequence)
        self._hasContiguousBuffer = hasContiguousBuffer
    }
    
    var underestimatedCount: Int { _elements.count }
    
    func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        guard _hasContiguousBuffer else { return nil }
        
        return try _elements.withUnsafeBufferPointer(body)
    }
    
    func makeIterator() -> AnyIterator<Element> {
        AnyIterator(_elements.makeIterator())
    }
    
}
