(* 5-31 Type Inference *)

type 'a option = None | Some of 'a

(* None   : int option *)

(* Some 4 : int option *)

let foo (x:int) : int option = failwith "TBD"

let bar a = match foo a with
              None   -> 0
              Some y -> 1 + y


type 'a list = Nil | Cons of 'a * 'a list

type ('key, 'value) table
  = Empty | Bind of 'key * 'value * ('key, 'value) table

let animalNoises
  =  Bind ("cat", "meow"
          , Bind ("dog", "woof foof"
                 , Bind ("fox", 2
                        , Bind ("snake", "hiss"
                               , Empty
                               )
                        )
                 )
          )

(* func1 : int -> int -> int *)
let func1 x1 x2 = x1 + x2

(* func2 : int list -> int *)
let func2 xs = match xs with
  | (x1::x2::xs) -> func2 (func1 x1 x2 :: xs)
  | [x]          -> x
  | []           -> 0

(*
      -------
      n : int

      --------------
      "..." : string

      IF   | e1 : int, e2 : int
      --------------------------
      THEN | e1 + e2 : int

      IF   | e1 : IN -> OUT, e2 : IN
      -------------------------------
      THEN | e1 e2  : OUT


      [x:IN] e : OUT
      ------------------------
      (fun x -> e) : IN -> OUT

      [x:int] x + 1 : int
      -----------------------------------------
      (fun x -> x + 1): int -> int

      [x:string] x ^ "mimimimimimi" : string
      -----------------------------------------
      (fun x -> x ^ "mimimimimimi") : string -> string

 *)
(* Ex 1 *)

let x = 2 + 3

let y = string_of_int x

(* x : int
   string_of_int : int -> string
   y : string
 *)

let concat x y = x ^ y

let inc = fun z -> ((concat x) z)

(*
  x:Tx      = int
  inc:Tinc  = Tz -> Tbody
  z:Tz

 *)


let rec cat = fun xs ->
  match xs with
  | []    -> ""
  | x::xs' -> concat x (cat xs')


let foo i = function ... -> ...
let foo = fun i -> (function ... -> ...)


(*
Tcat  = Txs -> Tbody = string list -> string
Txs   = THING list = string list
Tbody = string
x:Tx  = THING = string
Tx    = string

concat : string -> (string -> string)
x      : Tx
*)

(* BINARY SEARCH TREE *)
