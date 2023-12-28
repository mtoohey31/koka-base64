module base64

// External support

inline fip extern (<<.) : (int8, int8) -> int8
  c  inline "((int8_t)((uint8_t)#1 << #2))"
  js inline "(#1 << #2)"

inline fip extern (>>.) : (int8, int8) -> int8
  c inline "((int8_t)((uint8_t)#1 >> #2))"
  js inline "(#1 >> #2)"

inline fip extern (&) : (int8, int8) -> int8
  inline "(#1 & #2)"

inline fip extern (|.) : (int8, int8) -> int8
  inline "(#1 | #2)"

// Encoding

val chars = vector([
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
  't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', '+', '/'
])

fun encode-int6(x : int8) : exn char
  chars[int(x)]

pub fun encode(b : list<int8>, padding : bool = True) : string
  // unsafe-no-exn is safe because the bitwise operations ensure that the values
  // passed to encode-int6 are within range.
  match b
    Cons(a, Cons(b, Cons(c, xx))) ->
      val x1 = a >>. 2.int8
      val x2 = ((a & 3.int8) <<. 4.int8) |. (b >>. 4.int8)
      val x3 = ((b & 15.int8) <<. 2.int8) |. (c >>. 6.int8)
      val x4 = c & 63.int8
      val chars = unsafe-no-exn
        [x1, x2, x3, x4].map(encode-int6)
      string(chars) ++ encode(xx, padding)

    Cons(a, Cons(b, Nil)) ->
      val x1 = a >>. 2.int8
      val x2 = ((a & 3.int8) <<. 4.int8) |. (b >>. 4.int8)
      val x3 = (b & 15.int8) <<. 2.int8
      val chars = unsafe-no-exn
        [x1, x2, x3].map(encode-int6)
      string(chars) ++ (if padding then "=" else "")

    Cons(a, Nil) ->
      val x1 = a >>. 2.int8
      val x2 = (a & 3.int8) <<. 4.int8
      val chars = unsafe-no-exn
        [x1, x2].map(encode-int6)
      string(chars) ++ (if padding then "==" else "")

    Nil -> ""

pub fun encode(b : vector<int8>, padding : bool = True) : string
  // PERF: Avoid list allocation.
  encode(list(b), padding)

// Decoding

val values = {
  fun range(a : int8, b : int8) : div list<int8>
    if a <= b then
      return Cons(a, range(a + 1.int8, b))
    else
      return Nil

  unsafe-total
    concat([
      replicate(-1.int8, int('+')),
      [62.int8],
      replicate(-1.int8, int('/') - int('+') - 1),
      [63.int8],
      replicate(-1.int8, int('0') - int('/') - 1),
      range(52.int8, 61.int8),
      replicate(-1.int8, int('A') - int('9') - 1),
      range(0.int8, 25.int8),
      replicate(-1.int8, int('a') - int('Z') - 1),
      range(26.int8, 51.int8)
    ])
}

val invalid-char-exn = Exception("base64/decode: invalid character", ExnRange)

fun decode-char(c : char) : exn int8
  // TODO: Remove manual bounds checking once C and JS backend bounds checking
  // is fixed upstream.
  val i = int(c)
  if 0 > i || i >= values.length then
    throw-exn(invalid-char-exn)
  match values[int(c)]
    Just(x) -> if x != -1.int8 then x else throw-exn(invalid-char-exn)
    Nothing -> throw-exn(invalid-char-exn)

fun assemble(x1 : int8, x2 : int8) : list<int8>
  [(x1 <<. 2.int8) |. (x2 >>. 4.int8)]

fun assemble(x1 : int8, x2 : int8, x3 : int8) : list<int8>
  assemble(x1, x2) ++ [((x2 & 15.int8) <<. 4.int8) |. (x3 >>. 2.int8)]

fun assemble(x1 : int8, x2 : int8, x3 : int8, x4 : int8) : list<int8>
  assemble(x1, x2, x3) ++ [((x3 & 3.int8) <<. 6.int8) |. x4]

pub fun decode(s : string, padding : bool = True) : <div, exn> list<int8>
  decode(slice(s), padding)

pub fun decode(s : sslice, padding : bool = True) : <div, exn> list<int8>
  decode-rec(s, padding)

fun decode-rec(s : sslice, padding : bool) : <div, exn> list<int8>
  match next(s)
    Nothing -> Nil
    Just((a, s')) ->
      val x1 = decode-char(a)
      match next(s')
        Nothing -> throw("base64/decode: invalid length")
        Just((b, s'')) ->
          val x2 = decode-char(b)
          if padding && s''.count == 2 && s''.string == "==" then
            return assemble(x1, x2)
          match next(s'')
            Nothing -> assemble(x1, x2)
            Just((c, s''')) ->
              val x3 = decode-char(c)
              if padding && s'''.count == 1 && s'''.string == "=" then
                return assemble(x1, x2, x3)
              match next(s''')
                Nothing -> assemble(x1, x2, x3)
                Just((d, s'''')) ->
                  val x4 = decode-char(d)
                  assemble(x1, x2, x3, x4) ++ decode-rec(s'''', padding)

pub fun decode'(s : string, padding : bool = True) : <div, exn> vector<int8>
  // PERF: Avoid list allocation.
  vector(decode(s, padding))
