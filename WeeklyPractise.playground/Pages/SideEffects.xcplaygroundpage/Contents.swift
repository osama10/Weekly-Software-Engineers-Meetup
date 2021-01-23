
import Foundation
// https://www.pointfree.co/episodes/ep2-side-effects

// hidden things that are not visible by functions signature

func compute(_ x: Int) -> Int {
    return x * x + 1
}

compute(2) // 5
compute(2) // 5
compute(2) // 5
compute(2) == 5
compute(2) != 4

// lets add side effect
func computeWithEffect(_ x: Int) -> Int {
  let computation = x * x + 1
  print("Computed \(computation)")
  return computation
}

// Can not test it
computeWithEffect(2) == 5

compute >>> compute

// different behavior

[2, 10].map(compute).map(compute) // [26, 10202]
[2, 10].map(compute >>> compute)  // [26, 10202]

[2, 10].map(computeWithEffect).map(computeWithEffect) // [26, 10202]
print(" ---- ")
[2, 10].map(computeWithEffect >>> computeWithEffect)  // [26, 10202]

/// Hidden outputs

func computeAndPrint(_ x: Int) -> (Int, [String]) {
  let computation = x * x + 1
  return (computation, ["Computed \(computation)"])
}

/// but this break one thing can anyone guess :D


func compose<A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> (A) -> (C, [String]) {

  return { a in
    let (b, logs) = f(a)
    let (c, moreLogs) = g(b)
    return (c, logs + moreLogs)
  }
}

computeAndPrint >=> computeAndPrint

/// Hidden inputs
func greetWithEffect(_ name: String) -> String {
  let seconds = Int(Date().timeIntervalSince1970) % 60
  return "Hello \(name)! It's \(seconds) seconds past the minute."
}

greetWithEffect("osama")
greetWithEffect("osama")



/// can test

func greet(at date: Date = Date(), name: String) -> String {
  let s = Int(date.timeIntervalSince1970) % 60
  return "Hello \(name)! It's \(s) seconds past the minute."
}

// this way we can test it . But this again breaks our composition

func uppercased(_ string: String) -> String {
  return string.uppercased()
}


"Osama" |> greetWithEffect >>> uppercased


// "Osama" |> greet >>> uppercased ... error

// We can fix it by providing only date and return a function from (String) -> String

func greet(at date: Date) -> (String) -> String {
  return { name in
    let s = Int(date.timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(s) seconds past the minute."
  }
}

// so now

greet(at: Date()) // (String) -> String

uppercased >>> greet(at: Date()) // (String) -> String
greet(at: Date()) >>> uppercased // (String) -> String


"Blob" |> uppercased >>> greet(at: Date())

// "Hello BLOB! It's 37 seconds past the minute."
"Blob" |> greet(at: Date()) >>> uppercased
// "HELLO BLOB! IT'S 37 SECONDS PAST THE MINUTE."


"Hello Blob! It's 37 seconds past the minute." == ("Blob" |> greet(at: Date(timeIntervalSince1970: 37)))
