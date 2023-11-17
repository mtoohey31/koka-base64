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

inline extern inject-console : forall<e, a> (action : () -> e a) -> <console|e> a
  inline "#1"

inline extern inject-div : forall<e, a> (action : () -> e a) -> <div|e> a
  inline "#1"

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

fun assert-eq(expected : string, actual : string) : <console, div> ()
  assert(expected == actual, "expected: " ++ expected ++ ", got: " ++ actual)

fun assert-eq(expected : list<int8>, actual : list<int8>) : <console, div> ()
  assert(expected == actual, "expected: " ++ show(expected) ++ ", got: " ++ show(actual))

fun assert-throws(expected : string, f : () -> <div, exn> a) : <console, div> ()
  with final ctl throw-exn(actual-exn) assert-eq(expected, actual-exn.message)
  f()
  assert(False, "expected exception: " ++ expected ++ ", none thrown")

// Test main

fun main()
  assert-eq("", encode(Nil))
  assert-eq("AxVV", encode([3.int8, 21.int8, 85.int8]))
  assert-eq("MR8HPw==", encode([49.int8, 31.int8, 7.int8, 63.int8]))
  assert-eq("QH9/f38=", encode([64.int8, 188.int8, 201.int8, 144.int8, 213.int8]))
  assert-eq("MR8HPw", encode([49.int8, 31.int8, 7.int8, 63.int8], padding=False))
  assert-eq("QH9/f38", encode([64.int8, 188.int8, 201.int8, 144.int8, 213.int8], padding=False))

  assert-eq(Nil, decode(""))
  assert-eq([3.int8, 21.int8, 85.int8], decode("AxVV"))
  assert-eq([49.int8, 31.int8, 7.int8, 63.int8], decode("MR8HPw", padding=False))
  assert-eq([49.int8, 31.int8, 7.int8, 63.int8], decode("MR8HPw=="))

  assert-eq("asdf", encode(decode("asdf")))
  assert-eq("ASDF", encode(decode("ASDF")))
  assert-eq("", encode(decode("")))
  assert-eq([3.int8, 21.int8, 85.int8], decode(encode([3.int8, 21.int8, 85.int8])))
  assert-eq(Nil, decode(encode(Nil)))

  assert-throws("decode: invalid character", fn() { decode("MR8HPw==", padding=False) })
  assert-throws("decode: invalid character", fn() { decode("%") })
  assert-throws("decode: invalid length", fn() { decode("A") })
  assert-throws("decode: invalid character", fn() { decode("MR8HPw==", padding=False) })
