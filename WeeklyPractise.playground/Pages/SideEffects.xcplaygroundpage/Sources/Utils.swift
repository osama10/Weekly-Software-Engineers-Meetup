import Foundation


public func incr(_ x: Int) -> Int { x + 1 }
public func sqr(_ x: Int) -> Int { x * x }


precedencegroup ForwardApplication {
    associativity: left
}

infix operator |> : ForwardApplication

public func |> <A,B>(a: A, f: (A) -> B) -> B { f(a) }


/// Introducing >>>
precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication, EffectfulComposition
}

infix operator >>>: ForwardComposition

public func >>> <A,B,C> (f: @escaping(A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    { a in g(f(a)) }
}

precedencegroup EffectfulComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator >=>: EffectfulComposition
public func >=> <A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> (A) -> (C, [String]) {

  return { a in
    let (b, logs) = f(a)
    let (c, moreLogs) = g(b)
    return (c, logs + moreLogs)
  }
}
