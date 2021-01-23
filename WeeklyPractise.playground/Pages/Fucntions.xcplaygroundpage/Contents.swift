import Foundation

// https://www.pointfree.co/episodes/ep1-functions

// Functional Programming is all about creating small, independent, reusable functions and create complex structure using there composition.

// Lets define a function that increment a value and a fucntion that squares the value

func incr(_ x: Int) -> Int { x + 1 }
func sqr(_ x: Int) -> Int { x * x }

// lets do something with these functions

incr(2)
sqr(3)
incr(incr(sqr(2)))

// or I can do composition here


// Problem here is complexity. It's a small composition . But if we imaging having more and more methods to compose together to get the result, we wont have the clarity

// This is how we do it in method world

extension Int {
    func incr() -> Int { self + 1 }
    func sqr() -> Int { self * self }
}


2.sqr().incr().incr()

// Above syntax is nice and much more readable. It can also be read left to right and we can also see proper flow here. In functional composition, this thing have to be read from the most inside fuction and then we have to unpack it all over. This makes it hard to read and that's one of the reason why people avoid free functions. So lets solve this thing


/// Introducing  |>

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

func |> <A,B>(a: A, f: (A) -> B) -> B { f(a) }

// So above is a generic function that takes a value and a function, apply that function over the value and gives another functions. So Now It can be use like this.

2 |> incr
2 |> sqr

2.sqr()
    .incr()
    .incr()

2 |> sqr
    |> incr
    |> incr

// let's use inc and sqr together

2 |> incr |> sqr


// So now we got the readability. Our functions are much more nicer and readable and can be used to do compositions. But we solve this thing with not so famous way .i.e using customs operators. So why operators are not so famous.

// Overaloading operator that's alrady in the language
// creating a very own operator that doesnt exist in programming domain
// Overloading operator for very domain specific thing

// So our above operator follows all the things . it's not in the swift , it presents in ELM, Elixr and F# and since it's over generics it's not solving a domain specific problem.

// So far what ever we have done, can also be done in method world. So that's doenst persuade many to move to functional, but theres one thing that can be done in functional world which is not possible in method world and that is function composition.


//(A) -> B
//(B) -> C
//(A) -> C

// Time for another operator :D

/// Introducing >>>

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>> <A,B,C> ( f: @escaping(A) -> B, g: @escaping (B) -> C) -> (A) -> C {

    { a in g(f(a)) }
}

// So now

let incrementAndSquare = incr >>> sqr // we have a whole new fucntion (Int) -> Int that increments and squares a number :D and vice versa

/// let use it with our pipe operator

2 |> incr >>> sqr

// Let's look what method composition looks like

extension Int {
    func incrAndSquare() -> Int {
        self.incr().sqr()
    }
}

2.incrAndSquare() // but not so good way. We have to do a lot of work to acheive a simple composition much better way is

2.incr()
    .sqr() // alot of work has to be done to acheive this moreover it's not very reuse. Consider the following statements

2 |> incr >>> sqr
2 |> incr
2 |>  sqr

incr >>> sqr

func anyOp(incrSquare: (Int) -> Int) -> Int { incrementAndSquare(2) }

anyOp(incrSquare: incr >>> sqr)

// but with method composition we cant
2.incr().sqr()

/// Some Free functions in swift

/// Initializer are gloabal functions and we use them all the time. They can be use easily with our compositions .

incr >>> sqr >>> String.init // here we have a function that increments a number , square it and convert it into string in much simple and nice way


2 |>
    incr
    >>> sqr
    >>> String.init

// in methoods we have to do this

String(2.incr().sqr()) // less readable

/// There are many functions that takes free functions. One of them is map


print( [1, 2, 3].map { ($0 + 1) * ($0 + 1) }) // can be written as this


print([1, 2, 3].map(incr)
    .map(sqr))


print([1, 2, 3].map( incr >>> sqr ))


/// using functions we can reuse them easily than method as they are not bound to specific types or classes



