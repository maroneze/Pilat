include Plugin.Register
  (struct 
    let name = "Pilat"
    let shortname = "pilat"
    let help = "Frama-C Polynomial invariant generator"
   end)

module Enabled = False
  (struct 
    let option_name = "-pilat"
    let help = "when on, generates polynomial invariants for each solvable loop of the program" 
   end)
      
module Degree = Int
  (struct 2
    let option_name = "-pilat-degree"
    let help = "sets the maximum degree of the invariants"
    let arg_name = "n"
    let default = 2
   end)

module NameConst = String
  (struct 
    let option_name = "-pilat-const-name"
    let arg_name = "str"
    let default = "__PILAT__"
    let help = "sets the name of the constants used in invariants (default" ^ default ^ ")"
   end)

module Output_C_File =
  Empty_string
    (struct
       let option_name = "-pilat-output"
       let arg_name = ""
       let help = "specifies generated file name for annotated C code"
     end)

module Use_zarith = 
  True
    (struct
      let option_name = "-pilat-z"
      let help = "When on, uses zarith library." 
   end)

module Ev_leq = 
  Int
    (struct
        let option_name = "-pilat-ev"  
	let help = "sets the maximal eigenvalue searched for when using zarith"
	let arg_name = "n"
	let default = 10
     end)

module Var_focus = 
  Empty_string
    (struct
      let option_name = "-pilat-vars"
      let arg_name = "x:y:..."
      let help = "specifies which variables will be analyzed. "
     
     end)

(** Tools for ACSL generation *)

let emitter = Emitter.create 
  "Pilat_emitter"
  [Emitter.Code_annot;Emitter.Global_annot]
  ~correctness:
  [Degree.parameter]
  ~tuning:[]

(** Misc. *)

let var_list () = 
  let str = Var_focus.get () in
  let list = Str.split (Str.regexp ":") str
  in
  List.fold_left
    (fun acc str_v ->
      try 
	Cil_datatype.Varinfo.Set.add (Globals.Vars.find_from_astinfo str_v Cil_types.VGlobal) acc
      with
	Not_found ->
	  try
	    Cil_datatype.Varinfo.Set.add 
	      (Globals.Vars.find_from_astinfo 
		 str_v
		 (Cil_types.VLocal (Globals.Functions.find_by_name "main")))
		acc
	      
	  with
	    Not_found -> 
	      (feedback "Variable %s not found") str_v; acc)
    Cil_datatype.Varinfo.Set.empty
    list

(** Timers *)

let whole_rel_time = ref 0.

let parsing_timer = ref 0.

let invar_timer = ref 0.

let inter_timer = ref 0.

let nullspace_timer = ref 0.

let ltoq_timer = ref 0.

let ev_timer = ref 0.

let char_poly_timer = ref 0.  