# DFA

A *deterministic state automata*, generic over its associated type `Element` which must conform to `Hashable`.

*Deterministic state automata* —aka *dfa*— is a finite state machine built on a sequence of elements, which then can be used for matching the pattern of those elements in another sequence.
You'd use this state machine by first obtaining a new instance via its initializer `init(_:)`, passing as its parameter the sequence of elements representing the pattern to look for:

 ```Swift
 var dfa = DFA("seashells")
 ```

 You then update its state via the mutating method `updateState(for:)`
 by sequentially calling it specifying the elements from another sequence where to find such pattern.
 You'd also check the state of the dfa after each of those updates.
 When the dfa has reached its `finalState`, then  the pattern was found —at this point
 you could eventually stop updating the dfa state and the iteration on the sequence being looked on:

 ```Swift
 let txt = "she sells seashells by the shoreline"
 for char in txt {
     dfa.updateState(for: char)
     guard
         !dfa.isAtFinalState
     else {
         print("Found match")
         break
     }
 }
 // Prints: "Found match"
 ```

 It's also good practice to reset the dfa to its initial state before starting a
 new search on a different sequence:

 ```Swift
 var dfa = DFA("seashells")
 let txt1 = "she ejoys sunsets by the sea"
 for char in txt1 {
     dfa.updateState(for: char)
     guard
         !dfa.isAtFinalState
     else {
         print("Found match")
         break
     }
 }

 // Didn't get to its final state:
 print(dfa.state)
 // Prints: "2"

 let txt2 = "shells are explosives"

 // If you were not to call `resetToInitialState()` method on this dfa
 // and using it for looking up on `txt2` you'd get the wrong result:
 for char in txt2 {
     dfa.updateState(for: char)
     guard
         !dfa.isAtFinalState
     else {
         print("Found match")
         break
     }
 }

 // Prints: "Found match"
```

This is not correct because the dfa was still at state `2` after the lookup on `txt1` ended: hence it matched "s" -> "e" -> "a" at the end of `txt1` and then when looking up on `txt2` it matched "s" -> "h" -> "e" -> "l" -> "l" -> "s" getting to its final state. 
The right approach in this case would have been to first reset the dfa to its
 initial state:
 
```Swift
 dfa.resetToInitialState()

 print(dfa.state)
 // Prints: "0"

 for char in txt2 {
     dfa.updateState(for: char)
     guard
         !dfa.isAtFinalState
     else {
         print("Found match")
         break
     }
 }

 // Didn't get to final state:
 print(dfa.state)
 // Prints: "1"
 ```

