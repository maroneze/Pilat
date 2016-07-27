(**************************************************************************)
(*                                                                        *)
(*  This file is part of Frama-C.                                         *)
(*                                                                        *)
(*  Copyright (C) 2007-2016                                               *)
(*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
(*         alternatives)                                                  *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file LICENCE).                      *)
(*                                                                        *)
(**************************************************************************)

open Pilat_matrix
open Poly_utils

module Float_deterministic : Poly_assign.S = Poly_assign.Make(Lacaml_matrix)(F_poly)

module Q_deterministic : Poly_assign.S = Poly_assign.Make(QMat)(QPoly)

module Float_non_deterministic : Poly_assign.S
  = Poly_assign.Make(PMat)(NF_poly)

module Q_non_deterministic : Poly_assign.S = Poly_assign.Make(PQMat)(NQF_poly)


module Determinizer (ND_assign : Poly_assign.S) = 
struct
let nd_mat_to_d_mat mat = 
  let module F = (Float_deterministic) in
  let module Fn = (ND_assign) in
  F.M.create_mat
    (Fn.M.get_dim_row mat)
    (Fn.M.get_dim_col mat)
    (fun i j -> 
      let poly = Fn.M.get_coef i j mat in 
      F.P.R.float_to_t (Fn.P.deter (Fn.P.const poly))
    )
    
  
end
