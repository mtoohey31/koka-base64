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

fun encode-int6(i : int8) : exn char
  match int(i)
    0 -> 'A'
    1 -> 'B'
    2 -> 'C'
    3 -> 'D'
    4 -> 'E'
    5 -> 'F'
    6 -> 'G'
    7 -> 'H'
    8 -> 'I'
    9 -> 'J'
    10 -> 'K'
    11 -> 'L'
    12 -> 'M'
    13 -> 'N'
    14 -> 'O'
    15 -> 'P'
    16 -> 'Q'
    17 -> 'R'
    18 -> 'S'
    19 -> 'T'
    20 -> 'U'
    21 -> 'V'
    22 -> 'W'
    23 -> 'X'
    24 -> 'Y'
    25 -> 'Z'
    26 -> 'a'
    27 -> 'b'
    28 -> 'c'
    29 -> 'd'
    30 -> 'e'
    31 -> 'f'
    32 -> 'g'
    33 -> 'h'
    34 -> 'i'
    35 -> 'j'
    36 -> 'k'
    37 -> 'l'
    38 -> 'm'
    39 -> 'n'
    40 -> 'o'
    41 -> 'p'
    42 -> 'q'
    43 -> 'r'
    44 -> 's'
    45 -> 't'
    46 -> 'u'
    47 -> 'v'
    48 -> 'w'
    49 -> 'x'
    50 -> 'y'
    51 -> 'z'
    52 -> '0'
    53 -> '1'
    54 -> '2'
    55 -> '3'
    56 -> '4'
    57 -> '5'
    58 -> '6'
    59 -> '7'
    60 -> '8'
    61 -> '9'
    62 -> '+'
    63 -> '/'

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

fun decode-char(c : char) : exn int8
  match c
    'A' -> 0.int8
    'B' -> 1.int8
    'C' -> 2.int8
    'D' -> 3.int8
    'E' -> 4.int8
    'F' -> 5.int8
    'G' -> 6.int8
    'H' -> 7.int8
    'I' -> 8.int8
    'J' -> 9.int8
    'K' -> 10.int8
    'L' -> 11.int8
    'M' -> 12.int8
    'N' -> 13.int8
    'O' -> 14.int8
    'P' -> 15.int8
    'Q' -> 16.int8
    'R' -> 17.int8
    'S' -> 18.int8
    'T' -> 19.int8
    'U' -> 20.int8
    'V' -> 21.int8
    'W' -> 22.int8
    'X' -> 23.int8
    'Y' -> 24.int8
    'Z' -> 25.int8
    'a' -> 26.int8
    'b' -> 27.int8
    'c' -> 28.int8
    'd' -> 29.int8
    'e' -> 30.int8
    'f' -> 31.int8
    'g' -> 32.int8
    'h' -> 33.int8
    'i' -> 34.int8
    'j' -> 35.int8
    'k' -> 36.int8
    'l' -> 37.int8
    'm' -> 38.int8
    'n' -> 39.int8
    'o' -> 40.int8
    'p' -> 41.int8
    'q' -> 42.int8
    'r' -> 43.int8
    's' -> 44.int8
    't' -> 45.int8
    'u' -> 46.int8
    'v' -> 47.int8
    'w' -> 48.int8
    'x' -> 49.int8
    'y' -> 50.int8
    'z' -> 51.int8
    '0' -> 52.int8
    '1' -> 53.int8
    '2' -> 54.int8
    '3' -> 55.int8
    '4' -> 56.int8
    '5' -> 57.int8
    '6' -> 58.int8
    '7' -> 59.int8
    '8' -> 60.int8
    '9' -> 61.int8
    '+' -> 62.int8
    '/' -> 63.int8
    _ -> throw("decode: invalid character")

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
        Nothing -> throw("decode: invalid length")
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
