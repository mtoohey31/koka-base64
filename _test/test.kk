module test

import base64

// External support

inline extern exit : (int32) -> div ()
  c  inline "exit(#1)"
  js inline "process.exit(#1)"
  cs inline "Environment.Exit(#1)"

inline fip extern (==) : (int8, int8) -> bool
  inline "(#1 == #2)"
  js inline "(#1 === #2)"

// Show implementations for assertions

fun show(i : int8) : string
  show(int(i))

fun show(xs : list<int8>) : string
  show-list(xs, show)

// Comparison for assertions

fun (==)(xs : list<int8>, ys : list<int8>) : div bool
  match (xs, ys)
    (Cons(x, xs), Cons(y, ys)) | x == y -> xs == ys
    (Nil, Nil) -> True
    _ -> False

// Assertions

fun assert(condition : bool, message : string) : <console, div> ()
  if !condition then
    println(message)
    exit(1.int32)

fun assert_eq(expected : string, actual : string) : <console, div> ()
  assert(expected == actual, "expected: " ++ expected ++ ", got: " ++ actual)

fun assert_eq(expected : list<int8>, actual : list<int8>) : <console, div> ()
  assert(expected == actual, "expected: " ++ show(expected) ++ ", got: " ++ show(actual))

// Test main

fun main()
  assert_eq("", encode(Nil))
  assert_eq("AxVV", encode([3.int8, 21.int8, 85.int8]))
  assert_eq("MR8HPw==", encode([49.int8, 31.int8, 7.int8, 63.int8]))
  assert_eq("QH9/f38=", encode([64.int8, 188.int8, 201.int8, 144.int8, 213.int8]))
  assert_eq("MR8HPw", encode([49.int8, 31.int8, 7.int8, 63.int8], padding=False))
  assert_eq("QH9/f38", encode([64.int8, 188.int8, 201.int8, 144.int8, 213.int8], padding=False))

  assert_eq(Nil, decode(""))
  assert_eq([3.int8, 21.int8, 85.int8], decode("AxVV"))
  assert_eq([49.int8, 31.int8, 7.int8, 63.int8], decode("MR8HPw", padding=False))
  assert_eq([49.int8, 31.int8, 7.int8, 63.int8], decode("MR8HPw=="))

  assert_eq("asdf", encode(decode("asdf")))
  assert_eq("ASDF", encode(decode("ASDF")))
  assert_eq("", encode(decode("")))
  assert_eq([3.int8, 21.int8, 85.int8], decode(encode([3.int8, 21.int8, 85.int8])))
  assert_eq(Nil, decode(encode(Nil)))

  // TODO: Test exceptions.
