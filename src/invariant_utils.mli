(**************************************************************************)
(*                                                                        *)
(*  This file is part of Frama-C.                                         *)
(*                                                                        *)
(*  Copyright (C) 2007-2017                                               *)
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

type limit = 
    Convergent of float
  | Divergent of float
  | Altern
  | One
  | Zero

type sgn = 
  | Positive
  | Negative
  | Unknown

val pp_limit : Format.formatter -> limit -> unit

val pp_sgn : Format.formatter -> sgn -> unit 

type 'v simp_inv = limit * 'v list

type 'v gen_inv = 'v * 'v

type 'v invariant = 
    Eigenvector of 'v simp_inv
  | Generalized of 'v gen_inv

type q_invar = Pilat_matrix.QMat.vec invariant

module Make : functor 
    (A : Poly_assign.S) -> 
      sig 
  
        (** An invariant is an eigenspace, represented by its base with
            a vec list. 
            When an eigenspace is associated to an eigenvalue strictly 
            lower to one, the invariant is convergent 
            (<e,X> < k => <e,MX> <k).
            When it is higher to one, it is divergent
            (<e,X> > k => <e,MX> > k).
        *)
        type mat = A.mat
        type invar = A.M.vec invariant
            
        val lim_to_string : limit -> string
 
        (** Returns the simple eigenspaces union of the floating matrix 
            as a list of bases. If assignments are non deterministic, the boolean 
            must be set to true *)
        val invariant_computation : bool -> mat -> invar list  
            
        val generalized_invariants : 
         mat -> A.R.t -> int -> invar list
            
        (** Intersects two union of vectorial spaces. Must be "Eigenvectors". *)
	val intersection_invariants :  invar list -> invar list -> invar list
	  
	val zarith_invariant : invar -> q_invar
	val to_invar : q_invar -> invar 
	  
	(** Returns equivalent invariants with integers only. *)
	val integrate_invar : invar -> invar
	  
        (** Tests if the vector represents the constant invariant "1 = 1" *)
        val is_one : A.P.Monom.t A.Imap.t -> A.M.vec -> bool 

        (** Tests if it can decide the initial state of the invariant is positive or 
            negative: Some true if positive, Some false for negative, None if it can't decide.
            
            For now, it only tests if the invariant is "1 = 1".
        *)
        val invar_init_sign : A.P.Monom.t A.Imap.t -> A.M.vec -> sgn

	(** Returns the polynomial associated to a vector with respect to the base in argument. *)
	val vec_to_poly : A.P.Monom.t A.Imap.t -> A.M.vec -> A.P.t

	(** Returns true if an invariant is . *)
	val redundant_invariant : A.P.Monom.t A.Imap.t -> A.M.vec ->  A.M.vec list -> bool
	  
end

