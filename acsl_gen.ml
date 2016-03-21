(* Logic_const.new_code_annotation *)
open Cil_types
open Matrix_ast

module Var_cpt = State_builder.SharedCounter(struct let name = "pilat_counter" end)
let new_name () = Mat_option.NameConst.get () ^ (string_of_int (Var_cpt.next ()))

let to_code_annot (pred:predicate named) = 
  
  Logic_const.new_code_annotation (AInvariant ([],true,pred))

let monomial_to_mul_term m = 
  
  let rec __m_to_term vars = 
    match vars with
      [] -> Logic_const.term (TConst (Integer (Integer.one,(Some "1")))) Linteger
    | var :: [] -> 
      let lvar = Cil.cvar_to_lvar var in
      
      Logic_const.term 
	(TLval 
	   (TVar lvar,TNoOffset)
	) 
	Linteger
    | var :: tl -> 
      let lvar = Cil.cvar_to_lvar var in
      let tlval = Logic_const.term (TLval (TVar lvar,TNoOffset)) Linteger in
      let end_term =  __m_to_term tl in
      
      Logic_const.term (TBinOp (Mult,tlval,end_term)) Linteger
  in
 
  __m_to_term (F_poly.to_var m)

let vec_to_term (base:int Matrix_ast.F_poly.Monom.Map.t) (vec : Lacaml_D.vec) =
  let zero =  Logic_const.term (TConst (Integer (Integer.zero,(Some "0")))) Linteger
  in
  F_poly.Monom.Map.fold
    (fun monom row acc -> 
      let logic_cst = 
	{ r_literal = string_of_float vec.{row};
	  r_nearest = vec.{row} ;
	  r_upper = vec.{row} ;    
	  r_lower = vec.{row} ;
	}
      in
      let term_cst = Logic_const.term (TConst (LReal logic_cst)) Linteger  in
      let monom_term = 
	Logic_const.term
	  (TBinOp
	     (Mult,
 	      term_cst,
	      monomial_to_mul_term monom)
	  ) Linteger 
	  
      in
      
      Logic_const.term (TBinOp (PlusA,acc,monom_term)) Linteger 
	
    )
    base
    zero

let vec_space_to_predicate
    (base:int Matrix_ast.F_poly.Monom.Map.t) 
    (vec_list : Lacaml_D.vec list) 
    : predicate named =
  let zero =  (Logic_const.term (TConst (Integer (Integer.zero,(Some "0"))))) Linteger 
  in
  let term = 
    List.fold_left
      (fun acc vec -> 
	let term = vec_to_term base vec 
	in
	let new_ghost_var = Cil.makeGlobalVar (new_name ()) (TInt (IInt,[]))
	in
	new_ghost_var.vghost <- true;     
	let lvar = Cil.cvar_to_lvar new_ghost_var in
        let term_gvar = 
	  Logic_const.term
	    (TLval ((TVar lvar),TNoOffset)) Linteger 
	in
	let prod_term = 
	  Logic_const.term
	    (TBinOp
	       (Mult,
 		term_gvar,
		term) 
	    ) Linteger 
	    
	in
	Logic_const.term
	   (TBinOp (PlusA,acc,prod_term)) Linteger 
	    
      )
      zero
      vec_list
  in
  let pred = 
    Prel
      (Req,
       term,
       zero)
  in
   
  Logic_const.unamed pred

let add_loop_annots kf stmt base vec_lists = 
  let annots =   
    List.map 
      (fun vec -> 
	to_code_annot (vec_space_to_predicate base vec)
      )
      vec_lists
      

  in
  List.iter (Annotations.add_code_annot Mat_option.emitter ~kf stmt) annots
