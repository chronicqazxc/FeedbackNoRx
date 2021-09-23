//
//  System.swift
//  Feedback
//
//  Created by YuHan Hsiao on 2021/09/20.
//

import Foundation

public struct Feedback<State, Event> {
    var run: (_ state: State, _ callback: @escaping (Event)->Void) -> Void
    
    public init(run: @escaping (State, @escaping (Event) -> Void) -> Void) {
        self.run = run
    }
}

public final class System<State, Event> {
    public private(set) var state: Dynamic<State>
    public private(set) var event: Dynamic<Event>
    
    public convenience init(initial: (state: State, event: Event),
         reduce: @escaping (State, Event) -> State,
         feedbacks: ((Event) -> Feedback<State, Event>)...) {
        self.init(initial: initial, reduce: reduce, feedbacks: feedbacks)
    }
    
    public init(initial: (state: State, event: Event),
         reduce: @escaping (State, Event) -> State,
         feedbacks: [((Event) -> Feedback<State, Event>)]) {
        
        self.state = Dynamic<State>(initial.state)
        self.event = Dynamic<Event>(initial.event)
        
        self.event.bindAndFire { event in
            for feedback in feedbacks {
                feedback(event).run(self.state.value) { newEvent in
                    let newState = reduce(self.state.value, newEvent)
                    self.state.value = newState
                }
            }
        }
    }
}
