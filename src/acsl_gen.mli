open Cil_types 

val add_loop_annots_zarith : 
  kernel_function 
  -> stmt 
  -> int Poly_affect.F_poly.Monom.Map.t 
  -> Invariant_utils.invar list
  -> unit
