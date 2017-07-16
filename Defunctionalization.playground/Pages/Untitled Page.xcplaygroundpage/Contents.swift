//: Playground - noun: a place where people can play

import UIKit

indirect enum BT<A> {
    case leaf(A)
    case node(BT<A>, BT<A>)
}

extension Array {
    func appending(_ value: Element) -> [Element] {
        var copy = self
        copy.append(value)
        return copy
    }
}

// Flatten, eta-expanded
func flatten_ee<A>(_ t: BT<A>) -> [A] {
    func walk(_ t: BT<A>, _ accum: [A]) -> [A] {
        switch t {
        case .leaf(let x):
            return accum.appending(x)
        case .node(let t1, let t2):
            return walk(t1, walk(t2, accum))
        }
    }
    return walk(t, [])
}

func cons<A>(_ element: A) -> ([A]) -> [A] {
    return { rest in rest.appending(element) }
}

infix operator ∘
func ∘<A, B, C>(lhs: @escaping (B) -> C, rhs: @escaping (A) -> B) -> (A) -> C {
    return { lhs(rhs($0)) }
}

func flatten<A>(_ t: BT<A>) -> [A] {
    func walk(_ t: BT<A>) -> ([A]) -> [A] {
        switch t {
        case .leaf(let x): return cons(x)
        case let .node(t1, t2): return walk(t1) ∘ walk(t2)
        }
    }
    return walk(t)([])
}

flatten(.node(.leaf(1), .leaf(2)))

indirect enum Lam<A> {
    case leaf(A)
    case lam2(Lam<A>, Lam<A>)
}

func cons_def<A>(_ value: A) -> Lam<A> {
    return .leaf(value)
}

func o_def<A>(_ l1: Lam<A>, _ l2: Lam<A>) -> Lam<A> {
    return .lam2(l1, l2)
}

func apply<A>(_ l: Lam<A>, _ accum: [A]) -> [A] {
    switch l {
    case .lam1(let x): return accum.appending(x)
    case let .lam2(l1, l2): return apply(l1, apply(l2, accum))
    }
}

func flatten_def<A>(_ t: BT<A>) -> [A] {
    func walk(_ t: BT<A>) -> Lam<A> {
        switch t {
        case .leaf(let x): return cons_def(x)
        case let .node(t1, t2): return o_def(walk(t1), walk(t2))
        }
    }
    return apply(walk(t), [])
}
