module Sensu =

(* Based off json.aug, a generic lens for Json files                       *)
(*                                                                         *)
(* The reason I've copied the contents of json.aug into this lens instead  *)
(* of just calling Json.lns is that the json.aug shipped with pre 0.8.0    *)
(* doesn't seem to work.                                                   *)
(*                                                                         *)
(* Based on the following grammar from http://www.json.org/                *)
(* Object ::= '{'Members ? '}'                                             *)
(* Members ::= Pair+                                                       *)
(* Pair ::= String ':' Value                                               *)
(* Array ::= '[' Elements ']'                                              *)
(* Elements ::= Value ( "," Value )*                                       *)
(* Value ::= String | Number | Object | Array | "true" | "false" | "null"  *)
(* String ::= "\"" Char* "\""                                              *)
(* Number ::= /-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?/                      *)

autoload xfm

let spc = /[ \t\n]*/

let ws = del spc ""
let eol = del spc "\n"
let delim (c:string) (d:string) = del (c . spc) d
let dels (s:string) = del s s

let comma = delim "," ","
let colon = delim ":" ":"
let lbrace = delim "{" "{"
let rbrace = delim "}" "}"
let lbrack = delim "[" "["
let rbrack = delim "]" "]"

let str_store =
  let q =  del "\"" "\"" in
  q . store /[^"]*/ . q . ws             (* " Emacs, relax *)

let number = [ label "number" . store /-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?/ ]
let str = [ label "string" . str_store ]

let const (r:regexp) = [ label "const" . store r . ws ]

let value0 = str | number | const /true|false|null/

let fix_value (value:lens) =
  let array = [ label "array" . lbrack . Build.opt_list value comma . rbrack ] in
  let pair = [ label "entry" . str_store . colon . value ] in
  let obj = [ label "dict" . lbrace . Build.opt_list pair comma . rbrace ] in
  (str | number | obj | array | const /true|false|null/)

(* Typecheck finitely deep nesting *)
let value1 = fix_value value0
let value2 = fix_value value1

(* Process arbitrarily deeply nested JSON objects *)
let rec rlns = fix_value rlns

let lns = ws . rlns

let filter = incl "/etc/sensu/config.json"
let xfm = transform lns filter
