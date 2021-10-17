//
//  DFA.swift
//  DFA
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

import Foundation

/// A *deterministic state automata*, generic over its associated type `Element`
/// which must conform to `Hashable`.
///
/// *Deterministic state automata* —aka *dfa*— is a finite state machine built on a sequence of elements,
/// which then can be used for matching the pattern of those elements in another sequence.
/// You'd use this state machine by first obtaining a new instance via its initializer `init(_:)`,
/// passing as its parameter the sequence of elements representing the pattern to look for:
///
/// ```Swift
/// var dfa = DFA("seashells")
/// ```
///
/// You then update its state via the mutating method `updateState(for:)`
/// by passing to it sequentially elements from another sequence where to find such pattern;
/// you'd also check the state of the dfa after each of those updates.
/// When the dfa has reached its `finalState`, then  the pattern was found —at this point
/// you could eventually stop updating the dfa state and the iteration on the sequence being looked on:
///
/// ```Swift
/// let txt = "she sells seashells by the shoreline"
/// for char in txt {
///     dfa.updateState(for: char)
///     guard
///         !dfa.isAtFinalState
///     else {
///         print("Found match")
///         break
///     }
/// }
/// // Prints: "Found match"
/// ```
///
/// It's also good practice to reset the dfa to its initial state before starting a
/// new search on a different sequence:
///
/// ```Swift
/// var dfa = DFA("seashells")
/// let txt1 = "she ejoys sunsets by the sea"
/// for char in txt1 {
///     dfa.updateState(for: char)
///     guard
///         !dfa.isAtFinalState
///     else {
///         print("Found match")
///         break
///     }
/// }
///
/// // Didn't get to its final state:
/// print(dfa.state)
/// // Prints: "2"
///
/// let txt2 = "shells are explosives"
///
/// // If you were not to call `resetToInitialState()` method on this dfa
/// // and using it for looking up on txt2 you'd get the wrong result:
/// for char in txt2 {
///     dfa.updateState(for: char)
///     guard
///         !dfa.isAtFinalState
///     else {
///         print("Found match")
///         break
///     }
/// }
///
/// // Prints: "Found match"
/// ```
///
///  This is not correct because the dfa was still at state `2` after the lookup on `txt1`
///   ended: hence it matched "s" -> "e" -> "a" at the end of `txt1` and then
///   when looking up on `txt2` it matched "s" -> "h" -> "e" -> "l" -> "l" -> "s" getting to its final state.
/// The right approach in this case would have been to first reset the dfa to its initial state:
///
/// ```Swift
/// dfa.resetToInitialState()
///
/// print(dfa.state)
/// // Prints: "0"
///
/// for char in txt2 {
///     dfa.updateState(for: char)
///     guard
///         !dfa.isAtFinalState
///     else {
///         print("Found match")
///         break
///     }
/// }
///
/// // Didn't get to final state:
/// print(dfa.state)
/// // Prints: "1"
/// ```
///
public struct DFA<Element: Hashable> {
    typealias StateNode = Dictionary<Element, Int>
    
    /// The initial state for this dfa.
    public let initialState = 0
    
    let _states: Array<StateNode>
    
    /// The state this dfa is at.
    public fileprivate(set) var state = 0
    
    /// Creates a new dfa instance, initalized to contain state nodes for the specified sequence.
    ///
    /// - Parameter sequence:   A sequence of elements to use as state nodes
    ///                         for the new dfa created.
    ///
    /// - Complexity: O(*n*) where *n* is the length of the specified sequence of elements.
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self._states = sequence
            .withContiguousStorageIfAvailable({
                Self ._buildStates(from: $0)
            }) ?? Self._buildStates(from: sequence)
    }
    
}

// MARK: - Public computed properties
extension DFA {
    /// The elements of the pattern for this dfa.
    ///
    /// - Complexity: O(1).
    public var pattern: AnySequence<Element> {
        AnySequence { _Pattern(self) }
    }
    
    /// A boolean value, `true` when this dfa doesn't contain elements, `false` otherwise.
    ///
    /// - Note: An empty dfa always stays in its initial state and never reaches its final state.
    public var isEmpty: Bool {
        _states.first!.isEmpty
    }
    
    /// A boolean value: `true` when this dfa is at its initial state, `false` when not.
    @inlinable
    public var isAtInitialState: Bool { state == initialState }
    
    /// The final state for this dfa.
    public var finalState: Int { _states.endIndex }
    
    /// A boolean value: `true` when this dfa is at its final state, `false` when not.
    public var isAtFinalState: Bool { state == _states.endIndex }
    
}

// MARK: - public methods
extension DFA {
    /// Updates this dfa state for the the specified element.
    ///
    /// - Parameter element: The element to use for updating this dfa state.
    /// - Complexity: O(1).
    public mutating func updateState(for element: Element) {
        state = _states
            .withUnsafeBufferPointer {
                $0[state % _states.endIndex][element, default: 0]
            }
    }
    
    /// Resets this dfa to its initial state.
    ///
    /// - Complexity: O(1).
    public mutating func resetToInitialState() {
        state = 0
    }
    
}

// MARK: - Private
extension DFA {
    fileprivate struct _Pattern: IteratorProtocol {
        private let _states: Array<StateNode>
        
        private var _state: Int = 0
        
        fileprivate init(_ dfa: DFA) {
            self._states = dfa._states
        }
        
        mutating func next() -> Element? {
            guard
                _state < _states.endIndex
            else { return nil }
            
            defer { _state += 1 }
            
            return _states
                .withUnsafeBufferPointer { buffer in
                    guard
                        let keyIndex = buffer[_state].values
                            .firstIndex(of: _state + 1)
                    else { return nil }
                    
                    return buffer[_state].keys[keyIndex]
                }
        }
        
    }
    
}

extension DFA {
    fileprivate static func _buildStates<S: Sequence>(from sequence: S) -> Array<StateNode> where S.Iterator.Element == Element {
        var states: Array<StateNode> = [[:]]
        states.reserveCapacity(sequence.underestimatedCount)
        var iterator = sequence.makeIterator()
        if let firstElement = iterator.next() {
            states[0][firstElement] = 1
            var x = 0
            while let newElement = iterator.next() {
                var newStateNode = states
                    .withUnsafeBufferPointer { $0[x] }
                newStateNode[newElement] = states.endIndex + 1
                states.append(newStateNode)
                x = states
                    .withUnsafeBufferPointer { $0[x][newElement, default: 0] }
            }
        }
        
        return states
    }
    
}
