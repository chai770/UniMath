(** * Algebra I. Part D.  Rigs and rings. Vladimir Voevodsky. Aug. 2011 - . *)
Require Import UniMath.Algebra.Groups.
(** Contents
- Standard Algebraic Structures
 - Rigs - semirings with 1, 0, and x * 0 = 0 * x = 0
  - General definitions
  - Homomorphisms of rigs (rig functions)
  - Relations similar to "greater" or "greater or equal" on rigs
  - Subobjects
  - Quotient objects
  - Direct products
  - Opposite rigs
  - Nonzero rigs
  - Group of units
 - Commutative rigs
  - General definitions
  - Relations similar to "greater" on commutative rigs
  - Subobjects
  - Quotient objects
  - Direct products
  - Opposite commutative rigs
 - Rings
  - General definitions
  - Homomorphisms of rings
  - Computation lemmas for rings
  - Relations compatible with the additive structure on rings
  - Relations compatible with the multiplicative structure on rings
  - Relations "inversely compatible" with the multiplicative structure
    on rings
  - Relations on rings and ring homomorphisms
  - Subobjects
  - Quotient objects
  - Direct products
  - Opposite rings
  - Ring of differences associated with a rig
  - Canonical homomorphism to the ring associated with a rig (ring of
    differences)
  - Relations similar to "greater" or "greater or equal" on the ring
    associated with a rig
  - Relations and the canonical homomorphism to the ring associated
    with a rig (ring of differences)
 - Commutative rings
  - General definitions
  - Computational lemmas for commutative rings
  - Subobjects
  - Quotient objects
  - Direct products
  - Opposite commutative rings
  - Commutative rigs to commutative rings
  - Rings of fractions
  - Canonical homomorphism to the ring of fractions
  - Ring of fractions in the case when all elements which are being
    inverted are cancelable
  - Relations similar to "greater" or "greater or equal" on the rings
    of fractions
  - Relations and the canonical homomorphism to the ring of fractions
*)


(** ** Preamble *)

(** Settings *)

Unset Kernel Term Sharing.

(** Imports *)

Require Import UniMath.MoreFoundations.Sets.
Require Import UniMath.MoreFoundations.Orders.
Require Export UniMath.Algebra.Monoids.

Local Open Scope logic.

(** To upstream files *)


(** ** Standard Algebraic Structures (cont.) *)

(** *** Rigs - semirings with 1, 0 and x * 0 = 0 * x = 0 *)

(** **** General definitions *)

Definition rig : UU := ∑ (X : setwith2binop), isrigops (@op1 X) (@op2 X).

Definition make_rig {X : setwith2binop} (is : isrigops (@op1 X) (@op2 X)) : rig :=
  X ,, is.

Definition pr1rig : rig → setwith2binop :=
  @pr1 _ (λ X : setwith2binop, isrigops (@op1 X) (@op2 X)).
Coercion pr1rig : rig >-> setwith2binop.

Definition rigaxs (X : rig) : isrigops (@op1 X) (@op2 X) := pr2 X.

Definition rigop1axs (X : rig) : isabmonoidop (@op1 X) := rigop1axs_is (pr2 X).

Definition rigassoc1 (X : rig) : isassoc (@op1 X) := assocax_is (rigop1axs X).

Definition rigunel1 {X : rig} : X := unel_is (rigop1axs X).

Definition riglunax1 (X : rig) : islunit op1 (@rigunel1 X) := lunax_is (rigop1axs X).

Definition rigrunax1 (X : rig) : isrunit op1 (@rigunel1 X) := runax_is (rigop1axs X).

Definition rigmult0x (X : rig) : ∏ x : X, op2 (@rigunel1 X) x = @rigunel1 X :=
  rigmult0x_is (pr2 X).

Definition rigmultx0 (X : rig) : ∏ x : X, op2 x (@rigunel1 X) = @rigunel1 X :=
  rigmultx0_is (pr2 X).

Definition rigcomm1 (X : rig) : iscomm (@op1 X) := commax_is (rigop1axs X).

Definition rigop2axs (X : rig) : ismonoidop (@op2 X) := rigop2axs_is (pr2 X).

Definition rigassoc2 (X : rig) : isassoc (@op2 X) := assocax_is (rigop2axs X).

Definition rigunel2 {X : rig} : X := unel_is (rigop2axs X).

Definition riglunax2 (X : rig) : islunit op2 (@rigunel2 X) := lunax_is (rigop2axs X).

Definition rigrunax2 (X : rig) : isrunit op2 (@rigunel2 X) := runax_is (rigop2axs X).

Definition rigdistraxs (X : rig) : isdistr (@op1 X) (@op2 X) := pr2 (pr2 X).

Definition rigldistr (X : rig) : isldistr (@op1 X) (@op2 X) := pr1 (pr2 (pr2 X)).

Definition rigrdistr (X : rig) : isrdistr (@op1 X) (@op2 X) := pr2 (pr2 (pr2 X)).

Definition rigconstr {X : hSet} (opp1 opp2 : binop X) (ax11 : ismonoidop opp1)
           (ax12 : iscomm opp1) (ax2 : ismonoidop opp2)
           (m0x : ∏ x : X, opp2 (unel_is ax11) x = unel_is ax11)
           (mx0 : ∏ x : X, opp2 x (unel_is ax11) = unel_is ax11)
           (dax : isdistr opp1 opp2) : rig.
Proof.
  intros. exists (make_setwith2binop X (opp1 ,, opp2)). split.
  - exists ((ax11 ,, ax12) ,, ax2).
    apply (m0x ,, mx0).
  - apply dax.
Defined.

Definition rigaddabmonoid (X : rig) : abmonoid :=
  make_abmonoid (make_setwithbinop X op1) (rigop1axs X).

Definition rigmultmonoid (X : rig) : monoid := make_monoid (make_setwithbinop X op2) (rigop2axs X).

Declare Scope rig_scope.
Notation "x + y" := (op1 x y) : rig_scope.
Notation "x * y" := (op2 x y) : rig_scope.
Notation "0" := (rigunel1) : rig_scope.
Notation "1" := (rigunel2) : rig_scope.

Delimit Scope rig_scope with rig.


(** **** Homomorphisms of rigs (rig functions) *)

Definition isrigfun {X Y : rig} (f : X → Y) : UU :=
  @ismonoidfun (rigaddabmonoid X) (rigaddabmonoid Y) f ×
  @ismonoidfun (rigmultmonoid X) (rigmultmonoid Y) f.

Definition make_isrigfun {X Y : rig} {f : X → Y}
           (H1 : @ismonoidfun (rigaddabmonoid X) (rigaddabmonoid Y) f)
           (H2 : @ismonoidfun (rigmultmonoid X) (rigmultmonoid Y) f) : isrigfun f :=
  H1 ,, H2.

Definition isrigfunisaddmonoidfun {X Y : rig} {f : X → Y} (H : isrigfun f) :
  @ismonoidfun (rigaddabmonoid X) (rigaddabmonoid Y) f := dirprod_pr1 H.

Definition isrigfunismultmonoidfun {X Y : rig} {f : X → Y} (H : isrigfun f) :
  @ismonoidfun (rigmultmonoid X) (rigmultmonoid Y) f := dirprod_pr2 H.

Lemma isapropisrigfun {X Y : rig} (f : X → Y) : isaprop (isrigfun f).
Proof.
  use isapropdirprod.
  - use isapropismonoidfun.
  - use isapropismonoidfun.
Qed.

Definition rigfun (X Y : rig) : UU := ∑ (f : X → Y), isrigfun f.

Definition isasetrigfun (X Y : rig) : isaset (rigfun X Y).
Proof.
  use isaset_total2.
  - use isaset_set_fun_space.
  - intros x. use isasetaprop. use isapropisrigfun.
Qed.

Definition rigfunconstr {X Y : rig} {f : X → Y} (is : isrigfun f) : rigfun X Y := f ,, is.

Definition pr1rigfun (X Y : rig) : rigfun X Y → (X → Y) := @pr1 _ _.
Coercion pr1rigfun : rigfun >-> Funclass.

Definition rigaddfun {X Y : rig} (f : rigfun X Y) :
  monoidfun (rigaddabmonoid X) (rigaddabmonoid Y) := make_monoidfun (pr1 (pr2 f)).

Definition rigmultfun {X Y : rig} (f : rigfun X Y) :
  monoidfun (rigmultmonoid X) (rigmultmonoid Y) := make_monoidfun (pr2 (pr2 f)).

Definition rigfun_to_unel_rigaddmonoid {X Y : rig} (f : rigfun X Y) : f (0%rig) = 0%rig :=
  pr2 (pr1 (pr2 f)).

Definition rigfuncomp {X Y Z : rig} (f : rigfun X Y) (g : rigfun Y Z) : rigfun X Z.
Proof.
  use rigfunconstr.
  - exact (g ∘ f).
  - use make_isrigfun.
    + exact (ismonoidfun_monoidfun (monoidfuncomp (rigaddfun f) (rigaddfun g))).
    + exact (ismonoidfun_monoidfun (monoidfuncomp (rigmultfun f) (rigmultfun g))).
Defined.

Lemma rigfun_paths {X Y : rig} (f g : rigfun X Y) (e : pr1 f = pr1 g) : f = g.
Proof.
  use total2_paths_f.
  - exact e.
  - use proofirrelevance. use isapropisrigfun.
Qed.

Definition rigiso (X Y : rig) : UU := ∑ (f : X ≃ Y), isrigfun f.

Definition make_rigiso {X Y : rig} (f : X ≃ Y) (is : isrigfun f) : rigiso X Y := f ,, is.

Definition pr1rigiso (X Y : rig) : rigiso X Y → X ≃ Y := @pr1 _ _.
Coercion pr1rigiso : rigiso >-> weq.

Definition rigisoisrigfun {X Y : rig} (f : rigiso X Y) : isrigfun f := pr2 f.

Definition rigaddiso {X Y : rig} (f : rigiso X Y) :
  monoidiso (rigaddabmonoid X) (rigaddabmonoid Y) :=
  @make_monoidiso (rigaddabmonoid X) (rigaddabmonoid Y) (pr1 f) (pr1 (pr2 f)).

Definition rigmultiso {X Y : rig} (f : rigiso X Y) :
  monoidiso (rigmultmonoid X) (rigmultmonoid Y) :=
  @make_monoidiso (rigmultmonoid X) (rigmultmonoid Y) (pr1 f) (pr2 (pr2 f)).

Definition rigiso_paths {X Y : rig} (f g : rigiso X Y) (e : pr1 f = pr1 g) : f = g.
Proof.
  use total2_paths_f.
  - exact e.
  - use proofirrelevance. use isapropisrigfun.
Qed.

Definition rigisotorigfun {X Y : rig} (f : rigiso X Y) : rigfun X Y := rigfunconstr (pr2 f).

Lemma isrigfuninvmap {X Y : rig} (f : rigiso X Y) : isrigfun (invmap f).
Proof.
  intros. split.
  - apply (ismonoidfuninvmap (rigaddiso f)).
  - apply  (ismonoidfuninvmap (rigmultiso f)).
Defined.

Definition invrigiso {X Y : rig} (f : rigiso X Y) : rigiso Y X :=
  make_rigiso (invweq f) (isrigfuninvmap f).

Definition idrigiso (X : rig) : rigiso X X.
Proof.
  use make_rigiso.
  - exact (idweq X).
  - use make_isrigfun.
    + use make_ismonoidfun.
      * use make_isbinopfun.
        intros x x'. use idpath.
      * use idpath.
    + use make_ismonoidfun.
      * use make_isbinopfun.
        intros x x'. use idpath.
      * use idpath.
Defined.


(** **** (X = Y) ≃ (rigiso X Y)
    We use the following composition

                              (X = Y) ≃ (X ╝ Y)
                                      ≃ (rigiso' X Y)
                                      ≃ (rigiso X Y)

    where the second weak equivalence is given by univalence for setwith2binop,
    [setwith2binop_univalence]. The reason to define rigiso' is that it allows us to use
    [setwith2binop_univalence].
*)

Local Definition rigiso' (X Y : rig) : UU :=
  ∑ D : (∑ w : X ≃ Y, istwobinopfun w),
        ((pr1 D) (@rigunel1 X) = @rigunel1 Y) × ((pr1 D) (@rigunel2 X) = @rigunel2 Y).

Local Definition make_rigiso' (X Y : rig) (w : X ≃ Y) (H1 : istwobinopfun w)
           (H2 : w (@rigunel1 X) = @rigunel1 Y) (H3 : w (@rigunel2 X) = @rigunel2 Y) :
  rigiso' X Y := (w ,, H1) ,, H2 ,, H3.

Definition rig_univalence_weq1 (X Y : rig) : (X = Y) ≃ (X ╝ Y) :=
  total2_paths_equiv _ _ _.

Definition rig_univalence_weq2 (X Y : rig) : (X ╝ Y) ≃ (rigiso' X Y).
Proof.
  use weqbandf.
  - exact (setwith2binop_univalence X Y).
  - intros e. cbn. use invweq. induction X as [X Xop]. induction Y as [Y Yop]. cbn in e.
    cbn. induction e. use weqimplimpl.
    + intros i. use proofirrelevance. use isapropisrigops.
    + intros i. now induction i.
    + use isapropdirprod.
      * use setproperty.
      * use setproperty.
    + use isapropifcontr. exact (@isapropisrigops X op1 op2 Xop Yop).
Defined.
Opaque rig_univalence_weq2.

Definition rig_univalence_weq3 (X Y : rig) : (rigiso' X Y) ≃ (rigiso X Y).
Proof.
  use make_weq.
  - intros i'.
    use make_rigiso.
    + exact (pr1 (pr1 i')).
    + use make_isrigfun.
      * use make_ismonoidfun.
        -- use make_isbinopfun.
           exact (dirprod_pr1 (pr2 (pr1 i'))).
        -- exact (dirprod_pr1 (pr2 i')).
      *  use make_ismonoidfun.
        -- use make_isbinopfun.
           exact (dirprod_pr2 (pr2 (pr1 i'))).
        -- exact (dirprod_pr2 (pr2 i')).
  - use isweq_iso.
    + intros i. use make_rigiso'.
      * exact (pr1rigiso _ _ i).
      * use make_istwobinopfun.
        -- exact (ismonoidfunisbinopfun (isrigfunisaddmonoidfun (rigisoisrigfun i))).
        -- exact (ismonoidfunisbinopfun (isrigfunismultmonoidfun (rigisoisrigfun i))).
      * exact (ismonoidfununel (isrigfunisaddmonoidfun (rigisoisrigfun i))).
      * exact (ismonoidfununel (isrigfunismultmonoidfun (rigisoisrigfun i))).
    + intros x. use idpath.
    + intros x. use idpath.
Defined.
Opaque rig_univalence_weq3.

Definition rig_univlalence_map (X Y : rig) : X = Y → rigiso X Y.
Proof.
  intros e. induction e. exact (idrigiso X).
Defined.

Lemma rig_univalence_isweq (X Y : rig) : isweq (rig_univlalence_map X Y).
Proof.
  use isweqhomot.
  - exact (weqcomp (rig_univalence_weq1 X Y)
                   (weqcomp (rig_univalence_weq2 X Y) (rig_univalence_weq3 X Y))).
  - intros e. induction e.
    refine (weqcomp_to_funcomp_app @ _).
    exact weqcomp_to_funcomp_app.
  - use weqproperty.
Defined.
Opaque rig_univalence_isweq.

Definition rig_univalence (X Y : rig) : (X = Y) ≃ (rigiso X Y)
  := make_weq
    (rig_univlalence_map X Y)
    (rig_univalence_isweq X Y).


(** **** Relations similar to "greater" or "greater or equal" on rigs *)

Definition isrigmultgt (X : rig) (R : hrel X) :=
  ∏ (a b c d : X), R a b → R c d → R (op1 (op2 a c) (op2 b d)) (op1 (op2 a d) (op2 b c)).

Definition isinvrigmultgt (X : rig) (R : hrel X) : UU :=
  (∏ (a b c d : X), R (op1 (op2 a c) (op2 b d)) (op1 (op2 a d) (op2 b c)) → R a b → R c d) ×
  (∏ (a b c d : X), R (op1 (op2 a c) (op2 b d)) (op1 (op2 a d) (op2 b c)) → R c d → R a b).


(** **** Subobjects *)

Definition issubrig {X : rig} (A : hsubtype X) : UU :=
  (@issubmonoid (rigaddabmonoid X) A) × (@issubmonoid (rigmultmonoid X) A).

Lemma isapropissubrig {X : rig} (A : hsubtype X) : isaprop (issubrig A).
Proof.
  intros. apply (isofhleveldirprod 1).
  - apply isapropissubmonoid.
  - apply isapropissubmonoid.
Defined.

Definition subrig (X : rig) : UU := ∑ ( A : hsubtype X), issubrig A.

Definition make_subrig {X : rig}
  (t : hsubtype X)
  (H : issubrig t)
  : subrig X
  := t ,, H.

Definition pr1subrig (X : rig) : @subrig X → hsubtype X :=
  @pr1 _ (λ  A : hsubtype X, issubrig A).

Definition subrigtosubsetswith2binop (X : rig) : subrig X → @subsetswith2binop X :=
  λ A, make_subsetswith2binop (pr1 A) (pr1 (pr1 (pr2 A)) ,, pr1 (pr2 (pr2 A))).
Coercion subrigtosubsetswith2binop : subrig >-> subsetswith2binop.

Definition rigaddsubmonoid {X : rig} : subrig X → @subabmonoid (rigaddabmonoid X) :=
  λ A, @make_submonoid (rigaddabmonoid X) (pr1 A) (pr1 (pr2 A)).

Definition rigmultsubmonoid {X : rig} : subrig X → @submonoid (rigmultmonoid X) :=
  λ A, @make_submonoid (rigmultmonoid X) (pr1 A) (pr2 (pr2 A)).

Lemma isrigcarrier {X : rig} (A : subrig X) : isrigops (@op1 A) (@op2 A).
Proof.
  intros. split.
  - exists (isabmonoidcarrier (rigaddsubmonoid A) ,, ismonoidcarrier (rigmultsubmonoid A)).
    + split.
      * intro a. apply (invmaponpathsincl _ (isinclpr1carrier A)).
        simpl. apply rigmult0x.
      * intro a. apply (invmaponpathsincl _ (isinclpr1carrier A)).
        simpl. apply rigmultx0.
  - split.
    * intros a b c. apply (invmaponpathsincl _ (isinclpr1carrier A)).
      simpl. apply rigldistr.
    * intros a b c. apply (invmaponpathsincl _ (isinclpr1carrier A)).
      simpl. apply rigrdistr.
Defined.

Definition carrierofasubrig (X : rig) (A : subrig X) : rig.
Proof. intros. exists A. apply isrigcarrier. Defined.
Coercion carrierofasubrig : subrig >-> rig.

(** **** Quotient objects *)

Definition rigeqrel {X : rig} : UU := @twobinopeqrel X.
Identity Coercion id_rigeqrel : rigeqrel >-> twobinopeqrel.

Definition addabmonoideqrel {X : rig} (R : @rigeqrel X) :
  @binopeqrel (rigaddabmonoid X) := @make_binopeqrel (rigaddabmonoid X) (pr1 R) (pr1 (pr2 R)).

Definition multmonoideqrel {X : rig} (R : @rigeqrel X) :
  @binopeqrel (rigmultmonoid X) := @make_binopeqrel (rigmultmonoid X) (pr1 R) (pr2 (pr2 R)).

Lemma isrigquot {X : rig} (R : @rigeqrel X) :
  isrigops (@op1 (setwith2binopquot R)) (@op2 (setwith2binopquot R)).
Proof.
  intros. split.
  - exists (isabmonoidquot (addabmonoideqrel R) ,, ismonoidquot (multmonoideqrel R)).
    set (opp1 := @op1 (setwith2binopquot R)).
    set (opp2 := @op2 (setwith2binopquot R)).
    set (zr := setquotpr R (@rigunel1 X)).
    split.
    + apply (setquotunivprop
               R (λ x , make_hProp _ (setproperty (setwith2binopquot R) (opp2 zr x) zr))).
      intro x. apply (maponpaths (setquotpr R) (rigmult0x X x)).
    + apply (setquotunivprop
               R (λ x , make_hProp _ (setproperty (setwith2binopquot R) (opp2 x zr) zr))).
      intro x. apply (maponpaths (setquotpr R) (rigmultx0 X x)).
  - set (opp1 := @op1 (setwith2binopquot R)).
    set (opp2 := @op2 (setwith2binopquot R)).
    split.
    + unfold isldistr.
      apply (setquotuniv3prop
               R (λ x x' x'',
                    make_hProp _ (setproperty (setwith2binopquot R) (opp2  x'' (opp1 x x'))
                                             (opp1 (opp2 x'' x) (opp2 x'' x'))))).
      intros x x' x''. apply (maponpaths (setquotpr R) (rigldistr X x x' x'')).
    + unfold isrdistr.
      apply (setquotuniv3prop
               R (λ x x' x'',
                    make_hProp _ (setproperty (setwith2binopquot R) (opp2  (opp1 x x') x'')
                                             (opp1 (opp2 x x'') (opp2 x' x''))))).
      intros x x' x''. apply (maponpaths (setquotpr R) (rigrdistr X x x' x'')).
Defined.

Definition rigquot {X : rig} (R : @rigeqrel X) : rig :=
  @make_rig (setwith2binopquot R) (isrigquot R).


(** **** Direct products *)

Lemma isrigdirprod (X Y : rig) :
  isrigops (@op1 (setwith2binopdirprod X Y)) (@op2 (setwith2binopdirprod X Y)).
Proof.
  intros. split.
  - exists (isabmonoiddirprod (rigaddabmonoid X) (rigaddabmonoid Y) ,,
            ismonoiddirprod (rigmultmonoid X) (rigmultmonoid Y)).
    simpl. split.
    + intro xy. unfold setwith2binopdirprod. unfold op1. unfold op2.
      unfold ismonoiddirprod. unfold unel_is. simpl. apply pathsdirprod.
      apply (rigmult0x X). apply (rigmult0x Y).
    + intro xy. unfold setwith2binopdirprod. unfold op1. unfold op2.
      unfold ismonoiddirprod. unfold unel_is. simpl. apply pathsdirprod.
      apply (rigmultx0 X). apply (rigmultx0 Y).
  - split.
    + intros xy xy' xy''. unfold setwith2binopdirprod. unfold op1. unfold op2.
      simpl. apply pathsdirprod. apply (rigldistr X). apply (rigldistr Y).
    + intros xy xy' xy''. unfold setwith2binopdirprod. unfold op1. unfold op2.
      simpl. apply pathsdirprod. apply (rigrdistr X). apply (rigrdistr Y).
Defined.

Definition rigdirprod (X Y : rig) : rig := @make_rig (setwith2binopdirprod X Y) (isrigdirprod X Y).

(** **** Opposite rigs *)

Local Open Scope rig.

(** Following Bourbaki's Algebra, I, §8.3, Example V *)
Definition opposite_rig (X : rig) : rig.
Proof.

  (* Use the same underlying set and addition, flip the multiplication *)
  refine (make_setwith2binop (pr1 (pr1rig X))
                            (pr1 (pr2 (pr1rig X)) ,, λ x y, y * x),, _).

  unfold op2; cbn; fold (@op1 X) (@op2 X).
  apply (make_isrigops (rigop1axs X)).

  (* For these proofs, we just have to switch some arguments around *)
  - apply make_ismonoidop.
    * exact (λ x y z, !rigassoc2 _ z y x).
    * refine (1,, _). (* same unit, opposite proofs *)
      exact (rigrunax2 _ ,, riglunax2 _).
  - exact (rigmultx0 _).
  - exact (rigmult0x _).
  - exact (rigrdistr _ ,, rigldistr _).
Defined.

(** In Emacs, use the function insert-char and choose SUPERSCRIPT ZERO *)
Notation "X ⁰" := (opposite_rig X) (at level 12) : rig_scope.

Definition opposite_opposite_rig (X : rig) : rigiso X ((X⁰)⁰).
Proof.
  refine ((idfun X,, idisweq X),, _).
  repeat split.
Defined.

(** **** Nonzero rigs *)

Definition isnonzerorig (X : rig) : hProp.
Proof.
  intros; use make_hProp.
  - exact ((1 : X) != 0).
  - apply isapropneg.
Defined.

Local Close Scope rig.

(** *** Commutative rigs *)

(** **** General definitions *)

Definition commrig : UU := ∑ (X : setwith2binop), iscommrigops (@op1 X) (@op2 X).

Definition make_commrig (X : setwith2binop) (is : iscommrigops (@op1 X) (@op2 X)) : commrig :=
  X ,, is.

Definition commrigconstr {X : hSet} (opp1 opp2 : binop X)
           (ax11 : ismonoidop opp1) (ax12 : iscomm opp1)
           (ax2 : ismonoidop opp2) (ax22 : iscomm opp2)
           (m0x : ∏ x : X, opp2 (unel_is ax11) x = unel_is ax11)
           (mx0 : ∏ x : X, opp2 x (unel_is ax11) = unel_is ax11)
           (dax : isdistr opp1 opp2) : commrig.
Proof.
  intros. exists  (make_setwith2binop X (opp1 ,, opp2)).
  split.
  - split.
    + exists ((ax11 ,, ax12) ,, ax2).
      apply (m0x ,, mx0).
    + apply dax.
  - apply ax22.
Defined.

Definition commrigtorig : commrig → rig := λ X, @make_rig (pr1 X) (pr1 (pr2 X)).
Coercion commrigtorig : commrig >-> rig.

Definition rigcomm2 (X : commrig) : iscomm (@op2 X) := pr2 (pr2 X).

Definition commrigop2axs (X : commrig) : isabmonoidop (@op2 X) :=
  rigop2axs X ,, rigcomm2 X.

Definition commrigmultabmonoid (X : commrig) : abmonoid :=
  make_abmonoid (make_setwithbinop X op2) (rigop2axs X ,, rigcomm2 X).


(** **** (X = Y) ≃ (rigiso X Y)
    We use the following composition

                          (X = Y) ≃ (make_commrig' X = make_commrig' Y)
                                  ≃ ((pr1 (make_commrig' X)) = (pr1 (make_commrig' Y)))
                                  ≃ (rigiso X Y)

    where the third weak equivalence uses univalence for rigs, [rig_univalence]. We define
    [commrig'] to be able to apply it.
 *)

Local Definition commrig' : UU :=
  ∑ D : (∑ X : setwith2binop, isrigops (@op1 X) (@op2 X)), iscomm (@op2 (pr1 D)).

Local Definition make_commrig' (CR : commrig) : commrig' :=
  (pr1 CR ,, dirprod_pr1 (pr2 CR)) ,, (dirprod_pr2 (pr2 CR)).

Definition commrig_univalence_weq1 : commrig ≃ commrig' :=
  weqtotal2asstol
    (λ X : setwith2binop, isrigops (@op1 X) (@op2 X))
    (λ y : (∑ (X : setwith2binop), isrigops (@op1 X) (@op2 X)), iscomm (@op2 (pr1 y))).

Definition commrig_univalence_weq1' (X Y : commrig) : (X = Y) ≃ (make_commrig' X = make_commrig' Y) :=
  make_weq _ (@isweqmaponpaths commrig commrig' commrig_univalence_weq1 X Y).

Definition commrig_univalence_weq2 (X Y : commrig) :
  ((make_commrig' X) = (make_commrig' Y)) ≃ ((pr1 (make_commrig' X)) = (pr1 (make_commrig' Y))).
Proof.
  use subtypeInjectivity.
  intros w. use isapropiscomm.
Defined.
Opaque commrig_univalence_weq2.

Definition commrig_univalence_weq3 (X Y : commrig) :
  ((pr1 (make_commrig' X)) = (pr1 (make_commrig' Y))) ≃ (rigiso X Y) :=
  rig_univalence (pr1 (make_commrig' X)) (pr1 (make_commrig' Y)).

Definition commrig_univalence_map (X Y : commrig) : (X = Y) → (rigiso X Y).
Proof.
  intros e. induction e. exact (idrigiso X).
Defined.

Lemma commrig_univalence_isweq (X Y : commrig) : isweq (commrig_univalence_map X Y).
Proof.
  use isweqhomot.
  - exact (weqcomp (commrig_univalence_weq1' X Y)
                   (weqcomp (commrig_univalence_weq2 X Y) (commrig_univalence_weq3 X Y))).
  - intros e. induction e.
    refine (weqcomp_to_funcomp_app @ _).
    exact weqcomp_to_funcomp_app.
  - use weqproperty.
Defined.
Opaque commrig_univalence_isweq.

Definition commrig_univalence (X Y : commrig) : (X = Y) ≃ (rigiso X Y)
  := make_weq
  (commrig_univalence_map X Y)
  (commrig_univalence_isweq X Y).


(** **** Relations similar to "greater" on commutative rigs *)

Lemma isinvrigmultgtif (X : commrig) (R : hrel X)
      (is2 : ∏ a b c d, R (op1 (op2 a c) (op2 b d)) (op1 (op2 a d) (op2 b c)) → R a b → R c d) :
  isinvrigmultgt X R.
Proof.
  intros. split.
  - apply is2.
  - intros a b c d r rcd.
    rewrite (rigcomm1 X (op2 a d) _) in r.
    rewrite (rigcomm2 X a c) in r.
    rewrite (rigcomm2 X b d) in r.
    rewrite (rigcomm2 X b c) in r.
    rewrite (rigcomm2 X a d) in r.
    apply (is2 _ _ _ _ r rcd).
Defined.


(** **** Subobjects *)

Lemma iscommrigcarrier {X : commrig} (A : @subrig X) : iscommrigops (@op1 A) (@op2 A).
Proof.
  intros. exists (isrigcarrier A).
  apply (pr2 (@isabmonoidcarrier (commrigmultabmonoid X) (rigmultsubmonoid A))).
Defined.

(* ??? slows down at the last [ apply ] and at [ Defined ] (oct.16.2011 - does
  not slow down anymore with two Dan's patches) *)

Definition carrierofasubcommrig {X : commrig} (A : @subrig X) : commrig :=
  make_commrig A (iscommrigcarrier A).


(** **** Quotient objects *)

Lemma iscommrigquot {X : commrig} (R : @rigeqrel X) :
  iscommrigops (@op1 (setwith2binopquot R)) (@op2 (setwith2binopquot R)).
Proof.
  intros. exists (isrigquot R).
  apply (pr2 (@isabmonoidquot  (commrigmultabmonoid X) (multmonoideqrel R))).
Defined.

Definition commrigquot {X : commrig} (R : @rigeqrel X) : commrig :=
  make_commrig (setwith2binopquot R) (iscommrigquot R).


(** **** Direct products *)

Lemma iscommrigdirprod (X Y : commrig) :
  iscommrigops (@op1 (setwith2binopdirprod X Y)) (@op2 (setwith2binopdirprod X Y)).
Proof.
  intros. exists (isrigdirprod X Y).
  apply (pr2 (isabmonoiddirprod (commrigmultabmonoid X) (commrigmultabmonoid Y))).
Defined.

Definition commrigdirprod (X Y : commrig) : commrig :=
  make_commrig (setwith2binopdirprod X Y) (iscommrigdirprod X Y).

(** **** Opposite commutative rigs *)

Local Open Scope rig.

(** We reuse much of the proof for general rigs *)
Definition opposite_commrig (X : commrig) : commrig :=
  (pr1 (X⁰),, (pr2 (X⁰) ,, λ x y, rigcomm2 X y x)).

(** Commutativity makes taking the opposite trivial *)
Definition iso_commrig_opposite (X : commrig) : rigiso X (opposite_commrig X).
Proof.
  refine ((idfun X,, idisweq X),, _).
  repeat split.
  unfold isbinopfun.
  exact (λ x y, rigcomm2 X x y).
Defined.

Local Close Scope rig.


(** *** Rings *)


(** **** General definitions *)

Definition ring : UU := ∑ (X : setwith2binop), isringops (@op1 X) (@op2 X).

Definition make_ring {X : setwith2binop} (is : isringops (@op1 X) (@op2 X)) : ring :=
  X ,, is.

Definition pr1ring : ring → setwith2binop :=
  @pr1 _ (λ X : setwith2binop, isringops (@op1 X) (@op2 X)).
Coercion pr1ring : ring >-> setwith2binop.

Definition ringaxs (X : ring) : isringops (@op1 X) (@op2 X) := pr2 X.

Definition ringop1axs (X : ring) : isabgrop (@op1 X) := pr1 (pr1 (pr2 X)).

Definition ringassoc1 (X : ring) : isassoc (@op1 X) := assocax_is (ringop1axs X).

Definition ringunel1 {X : ring} : X := unel_is (ringop1axs X).

Definition ringlunax1 (X : ring) : islunit op1 (@ringunel1 X) := lunax_is (ringop1axs X).

Definition ringrunax1 (X : ring) : isrunit op1 (@ringunel1 X) := runax_is (ringop1axs X).

Definition ringinv1 {X : ring} : X → X := grinv_is (ringop1axs X).

Definition ringlinvax1 (X : ring) : ∏ x : X, op1 (ringinv1 x) x = ringunel1 :=
  grlinvax_is (ringop1axs X).

Definition ringrinvax1 (X : ring) : ∏ x : X, op1 x (ringinv1 x) = ringunel1 :=
  grrinvax_is (ringop1axs X).

Definition ringcomm1 (X : ring) : iscomm (@op1 X) := commax_is (ringop1axs X).

Definition ringop2axs (X : ring) : ismonoidop (@op2 X) := pr2 (pr1 (pr2 X)).

Definition ringassoc2 (X : ring) : isassoc (@op2 X) := assocax_is (ringop2axs X).

Definition ringunel2 {X : ring} : X := unel_is (ringop2axs X).

Definition ringlunax2 (X : ring) : islunit op2 (@ringunel2 X) := lunax_is (ringop2axs X).

Definition ringrunax2 (X : ring) : isrunit op2 (@ringunel2 X) := runax_is (ringop2axs X).

Definition ringdistraxs (X : ring) : isdistr (@op1 X) (@op2 X) := pr2 (pr2 X).

Definition ringldistr (X : ring) : isldistr (@op1 X) (@op2 X) := pr1 (pr2 (pr2 X)).

Definition ringrdistr (X : ring) : isrdistr (@op1 X) (@op2 X) := pr2 (pr2 (pr2 X)).

Definition ringconstr {X : hSet} (opp1 opp2 : binop X) (ax11 : isgrop opp1) (ax12 : iscomm opp1)
           (ax2 : ismonoidop opp2) (dax : isdistr opp1 opp2) : ring :=
  @make_ring (make_setwith2binop X (opp1 ,, opp2))
           (((ax11 ,, ax12) ,, ax2) ,, dax).

Definition ringmultx0 (X : ring) : ∏ x : X, (op2 x ringunel1) = ringunel1 :=
  ringmultx0_is (ringaxs X).

Definition ringmult0x (X : ring) : ∏ x : X, (op2 ringunel1 x) = ringunel1 :=
  ringmult0x_is (ringaxs X).

Definition ringminus1 {X : ring} : X := ringminus1_is (ringaxs X).

Definition ringmultwithminus1 (X : ring) : ∏ x : X, op2 ringminus1 x = ringinv1 x :=
  ringmultwithminus1_is (ringaxs X).

Definition ringaddabgr (X : ring) : abgr := make_abgr (make_setwithbinop X op1) (ringop1axs X).
Coercion ringaddabgr : ring >-> abgr.

Definition ringmultmonoid (X : ring) : monoid := make_monoid (make_setwithbinop X op2) (ringop2axs X).

Declare Scope ring_scope.
Notation "x + y" := (op1 x y) : ring_scope.
Notation "x - y" := (op1 x (ringinv1 y)) : ring_scope.
Notation "x * y" := (op2 x y) : ring_scope.
Notation "0" := (ringunel1) : ring_scope.
Notation "1" := (ringunel2) : ring_scope.
Notation "-1" := (ringminus1) (at level 0) : ring_scope.
Notation " - x " := (ringinv1 x) : ring_scope.

Delimit Scope ring_scope with ring.

Definition ringtorig (X : ring) : rig := @make_rig _ (pr2 X).
Coercion ringtorig : ring >-> rig.

(** **** Homomorphisms of rings *)

Definition isringfun {X Y : ring} (f : X → Y) := @isrigfun X Y f.

Definition ringfun (X Y : ring) := rigfun X Y.

Lemma isaset_ringfun (X Y : ring) : isaset (ringfun X Y).
Proof.
   apply (isofhleveltotal2 2).
   - use impred_isaset. intro x.
     apply setproperty.
   - intro f. apply isasetaprop.
     apply isapropisrigfun.
Defined.

Definition ringfunconstr {X Y : ring} {f : X → Y} (is : isringfun f) : ringfun X Y := rigfunconstr is.
Identity Coercion id_ringfun : ringfun >-> rigfun.

Definition ringaddfun {X Y : ring} (f : ringfun X Y) : monoidfun X Y := make_monoidfun (pr1 (pr2 f)).

Definition ringmultfun {X Y : ring} (f : ringfun X Y) :
  monoidfun (ringmultmonoid X) (ringmultmonoid Y) := make_monoidfun (pr2 (pr2 f)).

Definition ringiso (X Y : ring) := rigiso X Y.

Definition make_ringiso {X Y : ring} (f : X ≃ Y) (is : isringfun f) : ringiso X Y := f ,, is.
Identity Coercion id_ringiso : ringiso >-> rigiso.

Definition isringfuninvmap {X Y : ring} (f : ringiso X Y) : isringfun (invmap f) := isrigfuninvmap f.


(** **** (X = Y) ≃ (ringiso X Y)
    We use the following composition

                           (X = Y) ≃ (make_ring' X = make_ring' Y)
                                   ≃ ((pr1 (make_ring' X)) = (pr1 (make_ring' Y)))
                                   ≃ (ringiso X Y)

    where the third weak equivalence is given by univalence for rigs, [rig_univalence]. We define
    ring' to be able to apply [rig_univalence].
 *)

Local Definition ring' : UU :=
  ∑ D : (∑ X : setwith2binop, isrigops (@op1 X) (@op2 X)),
        invstruct (@op1 (pr1 D)) (dirprod_pr1 (dirprod_pr1 (pr1 (pr1 (pr2 D))))).

Local Definition make_ring' (R : ring) : ring'.
Proof.
  use tpair.
  - exists (pr1 R).
    use make_isrigops.
    + use make_isabmonoidop.
      * exact (pr1 (dirprod_pr1 (dirprod_pr1 (dirprod_pr1 (pr2 R))))).
      * exact (dirprod_pr2 (dirprod_pr1 (dirprod_pr1 (pr2 R)))).
    + exact (dirprod_pr2 (dirprod_pr1 (pr2 R))).
    + exact (@mult0x_is_l (pr1 R) (@op1 (pr1 R)) (@op2 (pr1 R))
                          (dirprod_pr1 (dirprod_pr1 (dirprod_pr1 (pr2 R))))
                          (dirprod_pr2 (dirprod_pr1 (pr2 R))) (dirprod_pr2 (pr2 R))).
    + exact (@multx0_is_l (pr1 R) (@op1 (pr1 R)) (@op2 (pr1 R))
                          (dirprod_pr1 (dirprod_pr1 (dirprod_pr1 (pr2 R))))
                          (dirprod_pr2 (dirprod_pr1 (pr2 R))) (dirprod_pr2 (pr2 R))).
    + exact (dirprod_pr2 (pr2 R)).
  - exact (pr2 (dirprod_pr1 (dirprod_pr1 (dirprod_pr1 (pr2 R))))).
Defined.

Local Definition make_ring_from_ring' (R : ring') : ring.
Proof.
  use make_ring.
  - exact (pr1 (pr1 R)).
  - use make_isringops.
    + use make_isabgrop.
      * use make_isgrop.
        -- exact (dirprod_pr1 (dirprod_pr1 (pr1 (dirprod_pr1 (pr2 (pr1 R)))))).
        -- exact (pr2 R).
      * exact (dirprod_pr2 (dirprod_pr1 (pr1 (dirprod_pr1 (pr2 (pr1 R)))))).
    + exact (dirprod_pr2 (pr1 (dirprod_pr1 (pr2 (pr1 R))))).
    + exact (dirprod_pr2 (pr2 (pr1 R))).
Defined.

Definition ring_univalence_weq1 : ring ≃ ring'.
Proof.
  use make_weq.
  - intros R. exact (make_ring' R).
  - use isweq_iso.
    + intros R'. exact (make_ring_from_ring' R').
    + intros R. use idpath.
    + intros R'.
      use total2_paths_f.
      * use total2_paths_f.
        -- use idpath.
        -- use proofirrelevance. use isapropisrigops.
      * use proofirrelevance. use isapropinvstruct.
Defined.

Definition ring_univalence_weq1' (X Y : ring) : (X = Y) ≃ (make_ring' X = make_ring' Y) :=
  make_weq _ (@isweqmaponpaths ring ring' ring_univalence_weq1 X Y).

Definition ring_univalence_weq2 (X Y : ring) :
  ((make_ring' X) = (make_ring' Y)) ≃ ((pr1 (make_ring' X)) = (pr1 (make_ring' Y))).
Proof.
  use subtypeInjectivity.
  intros w. use isapropinvstruct.
Defined.
Opaque ring_univalence_weq2.

Definition ring_univalence_weq3 (X Y : ring) :
  ((pr1 (make_ring' X)) = (pr1 (make_ring' Y))) ≃ (rigiso X Y) :=
  rig_univalence (pr1 (make_ring' X)) (pr1 (make_ring' Y)).

Definition ring_univalence_map (X Y : ring) : (X = Y) → (ringiso X Y).
Proof.
  intros e. induction e. exact (idrigiso X).
Defined.

Lemma ring_univalence_isweq (X Y : ring) : isweq (ring_univalence_map X Y).
Proof.
  use isweqhomot.
  - exact (weqcomp (ring_univalence_weq1' X Y)
                   (weqcomp (ring_univalence_weq2 X Y) (ring_univalence_weq3 X Y))).
  - intros e. induction e.
    refine (weqcomp_to_funcomp_app @ _).
    exact weqcomp_to_funcomp_app.
  - use weqproperty.
Defined.
Opaque ring_univalence_isweq.

Definition ring_univalence (X Y : ring) : (X = Y) ≃ (ringiso X Y)
  := make_weq
    (ring_univalence_map X Y)
    (ring_univalence_isweq X Y).


(** **** Computation lemmas for rings *)

Local Open Scope ring_scope.

Definition ringinvunel1 (X : ring) : -0 = 0 := grinvunel X.

Lemma ringismultlcancelableif (X : ring) (x : X) (isl : ∏ y, x * y = 0 → y = 0) :
  islcancelable op2 x.
Proof.
  intros.
  apply (@isinclbetweensets X X).
  - apply setproperty.
  - apply setproperty.
  - intros x1 x2 e.
    set (e' := maponpaths (λ a, a + (x * (-x2))) e). simpl in e'.
    rewrite <- (ringldistr X _ _ x) in e'.
    rewrite <- (ringldistr X _ _ x) in e'.
    rewrite (ringrinvax1 X x2) in e'.
    rewrite (ringmultx0 X _) in e'.
    set (e'' := isl (x1 - x2) e').
    set (e''' := maponpaths (λ a, a + x2) e''). simpl in e'''.
    rewrite (ringassoc1 X _ _ x2) in e'''.
    rewrite (ringlinvax1 X x2) in e'''.
    rewrite (ringlunax1 X _) in e'''.
    rewrite (ringrunax1 X _) in e'''.
    apply e'''.
Qed.

Lemma ringismultrcancelableif (X : ring) (x : X) (isr : ∏ y, y * x = 0 → y = 0) :
  isrcancelable op2 x.
Proof.
  intros. apply (@isinclbetweensets X X).
  - apply setproperty.
  - apply setproperty.
  - intros x1 x2 e.
    set (e' := maponpaths (λ a, a + ((-x2) * x)) e).  simpl in e'.
    rewrite <- (ringrdistr X _ _ x) in e'.
    rewrite <- (ringrdistr X _ _ x) in e'.
    rewrite (ringrinvax1 X x2) in e'.
    rewrite (ringmult0x X _) in e'.
    set (e'' := isr (x1 - x2) e').
    set (e''' := maponpaths (λ a, a + x2) e''). simpl in e'''.
    rewrite (ringassoc1 X _ _ x2) in e'''.
    rewrite (ringlinvax1 X x2) in e'''.
    rewrite (ringlunax1 X _) in e'''.
    rewrite (ringrunax1 X _) in e'''.
    apply e'''.
Qed.

Lemma ringismultcancelableif (X : ring) (x : X) (isl : ∏ y, x * y = 0 → y = 0)
      (isr : ∏ y, y * x = 0 → y = 0) : iscancelable op2 x.
Proof.
  intros.
  exact (ringismultlcancelableif X x isl ,, ringismultrcancelableif X x isr).
Defined.

Lemma ringlmultminus (X : ring) (a b : X) : -a * b = -(a * b).
Proof.
  intros. apply (@grrcan X _ _ (a * b)).
  change (-a * b + a * b = - (a * b) + a * b).
  rewrite (ringlinvax1 X _). rewrite <- (ringrdistr X _ _ _).
  rewrite (ringlinvax1 X _). rewrite (ringmult0x X _).
  apply idpath.
Qed.

Lemma ringrmultminus (X : ring) (a b : X) : a * -b = -(a * b).
Proof.
  intros. apply (@grrcan X _ _ (a * b)).
  change (a * (- b) + a * b = - (a * b) + a * b).
  rewrite (ringlinvax1 X _). rewrite <- (ringldistr X _ _ _).
  rewrite (ringlinvax1 X _). rewrite (ringmultx0 X _).
  apply idpath.
Qed.

Lemma ringmultminusminus (X : ring) (a b : X) : -a * -b = a * b.
Proof.
  intros. apply (@grrcan X _ _ (- a * b)). simpl.
  rewrite <- (ringldistr X _ _ (- a)).
  rewrite <- (ringrdistr X _ _ b).
  rewrite (ringlinvax1 X b). rewrite (ringrinvax1 X a).
  rewrite (ringmult0x X _). rewrite (ringmultx0 X _).
  apply idpath.
Qed.

Lemma ringminusminus (X : ring) (a : X) : --a = a.
Proof. intros. apply (grinvinv X a). Defined.

Definition ringinvmaponpathsminus (X : ring) {a b : X} : -a = -b → a = b := grinvmaponpathsinv X.


(** **** Relations compatible with the additive structure on rings *)

Definition ringfromgt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R)
           {x : X} (is : R x 0) : R 0 (- x) := grfromgtunel X is0 is.

Definition ringtogt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R) {x : X}
           (is : R 0 (- x)) : R x 0 := grtogtunel X is0 is.

Definition ringfromlt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R) {x : X}
           (is : R 0 x) : R (- x) 0 := grfromltunel X is0 is.

Definition ringtolt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R) {x : X}
           (is : R (- x) 0) : R 0 x := grtoltunel X is0 is.


(** **** Relations compatible with the multiplicative structure on rings *)

Definition isringmultgt (X : ring) (R : hrel X) : UU := ∏ a b, R a 0 → R b 0 → R (a * b) 0.

Lemma ringmultgt0lt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R) (is : isringmultgt X R) {x y : X}
      (isx : R x 0) (isy : R 0 y) : R 0 (x * y).
Proof.
  intros.
  set (isy' := grfromltunel X is0 isy).
  assert (r := is _ _ isx isy').
  change (pr1 (R (x * (- y)) 0)) in r.
  rewrite (ringrmultminus X _ _) in r.
  assert (r' := grfromgtunel X is0 r).
  change (pr1 (R 0 (- - (x * y)))) in r'.
  rewrite (ringminusminus X (x * y)) in r'.
  apply r'.
Qed.

Lemma ringmultlt0gt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R) (is : isringmultgt X R) {x y : X}
      (isx : R 0 x) (isy : R y 0) : R 0 (x * y).
Proof.
  intros.
  set (isx' := grfromltunel X is0 isx).
  assert (r := is _ _ isx' isy).
  change (pr1 (R ((- x) * y) 0)) in r.
  rewrite (ringlmultminus X _ _) in r.
  assert (r' := grfromgtunel X is0 r).
  change (pr1 (R 0 (- - (x * y)))) in r'.
  rewrite (ringminusminus X (x * y)) in r'.
  apply r'.
Qed.

Lemma ringmultlt0lt0 (X : ring) {R : hrel X} (is0 : @isbinophrel X R) (is : isringmultgt X R) {x y : X}
      (isx : R 0 x) (isy : R 0 y) : R (x * y) 0.
Proof.
  intros.
  set (rx := ringfromlt0 _ is0 isx).
  assert (ry := ringfromlt0 _ is0 isy).
  assert (int := is _ _ rx ry).
  rewrite (ringmultminusminus X _ _) in int.
  apply int.
Qed.

Lemma isringmultgttoislringmultgt (X : ring) {R : hrel X} (is0 : @isbinophrel X R)
      (is : isringmultgt X R) : ∏ a b c : X, R c 0 → R a b → R (c * a) (c * b).
Proof.
  intros a b c rc0 rab.
  set (rab':= (pr2 is0) _ _ (- b) rab). clearbody rab'.
  change (pr1 (R (a - b) (b - b))) in rab'.
  rewrite (ringrinvax1 X b) in rab'.
  set (r' := is _ _ rc0 rab'). clearbody r'.
  set (r'' := (pr2 is0) _ _ (c * b) r').  clearbody r''.
  change (pr1 (R (c * (a - b) + c * b) (0 + c * b))) in r''.
  rewrite (ringlunax1 X _) in r''.
  rewrite <- (ringldistr X _ _ c) in r''.
  rewrite (ringassoc1 X a _ _) in r''.
  rewrite (ringlinvax1 X b) in r''.
  rewrite (ringrunax1 X _) in r''.
  apply r''.
Qed.

Lemma islringmultgttoisringmultgt (X : ring) {R : hrel X}
      (is : ∏ a b c : X, R c 0 → R a b → R (c * a) (c * b)) : isringmultgt X R.
Proof.
  intros. intros a b ra rb.
  set (int := is b 0 a ra rb). clearbody int. rewrite (ringmultx0 X _) in int.
  apply int.
Qed.

Lemma isringmultgttoisrringmultgt (X : ring) {R : hrel X} (is0 : @isbinophrel X R)
      (is : isringmultgt X R) : ∏ a b c : X, R c 0 → R a b → R (a * c) (b * c).
Proof.
  intros a b c rc0 rab.
  set (rab' := (pr2 is0) _ _ (- b) rab). clearbody rab'.
  change (pr1 (R (a - b) (b - b))) in rab'.
  rewrite (ringrinvax1 X b) in rab'.
  set (r' := is _ _ rab' rc0). clearbody r'.
  set (r'' :=  (pr2 is0) _ _ (b * c) r'). clearbody r''.
  change (pr1 (R ((a - b) * c + b * c) (0 + b * c))) in r''.
  rewrite (ringlunax1 X _) in r''.
  rewrite <- (ringrdistr X _ _ c) in r''.
  rewrite (ringassoc1 X a _ _) in r''.
  rewrite (ringlinvax1 X b) in r''.
  rewrite (ringrunax1 X _) in r''.
  apply r''.
Qed.

Lemma isrringmultgttoisringmultgt (X : ring) {R : hrel X}
      (is1 : ∏ a b c : X, R c 0 → R a b → R (a * c) (b * c)) : isringmultgt X R.
Proof.
  intros. intros a b ra rb.
  set (int := is1 _ _ _ rb ra). clearbody int.
  rewrite (ringmult0x X _) in int. apply int.
Qed.

Lemma isringmultgtaspartbinophrel (X : ring) (R : hrel X) (is0 : @isbinophrel X R) :
  (isringmultgt X R) <-> (@ispartbinophrel (ringmultmonoid X) (λ a, R a 0) R).
Proof.
  intros. split.
  - intro ism. split.
    + apply (isringmultgttoislringmultgt X is0 ism).
    + apply (isringmultgttoisrringmultgt X is0 ism).
  - intro isp. apply (islringmultgttoisringmultgt X (pr1 isp)).
Defined.

Lemma isringmultgttoisrigmultgt (X : ring) {R : hrel X} (is0 : @isbinophrel X R)
      (is : isringmultgt X R) : isrigmultgt X R.
Proof.
  intros. set (rer := abmonoidrer X). simpl in rer.
  intros a b c d rab rcd.
  assert (intab : R (a - b) 0).
  {
    induction (ringrinvax1 X b).
    apply ((pr2 is0) _ _ (- b)).
    apply rab.
  }
  assert (intcd : R (c - d) 0).
  {
    induction (ringrinvax1 X d).
    apply ((pr2 is0) _ _ (- d)).
    apply rcd.
  }
  set (int := is _ _ intab intcd). rewrite (ringrdistr X _ _ _) in int.
  rewrite (ringldistr X _ _ _) in int. rewrite (ringldistr X _ _ _) in int.
  set (int' := (pr2 is0) _ _ (a * d + b * c) int). clearbody int'.
  simpl in int'.
  rewrite (ringlunax1 _) in int'. rewrite (ringcomm1 X (- b * c) _) in int'.
  rewrite (rer _ (a * - d) _ _) in int'.
  rewrite (ringassoc1 X  _ (a * - d + - b * c) _) in int'.
  rewrite (rer _ _ (a * d) _) in int'.
  rewrite <- (ringldistr X _ _ a) in int'.
  rewrite (ringlinvax1 X d) in int'.
  rewrite (ringmultx0 X _) in int'.
  rewrite <- (ringrdistr X _ _ c) in int'.
  rewrite (ringlinvax1 X b) in int'.
  rewrite (ringmult0x X _) in int'.
  rewrite (ringrunax1 X _) in int'.
  rewrite (ringrunax1 X _) in int'.
  rewrite (ringmultminusminus X b d) in int'.
  apply int'.
Qed.

Lemma isrigmultgttoisringmultgt (X : ring) {R : hrel X} (is : isrigmultgt X R) : isringmultgt X R.
Proof.
  intros. intros a b ra0 rb0. set (is' := is _ _ _ _ ra0 rb0). simpl in is'.
  fold (pr1ring) in is'. rewrite 2? (ringmult0x X _) in is'.
  rewrite (ringmultx0 X _) in is'. rewrite 2? (ringrunax1 X _) in is'.
  exact is'.
Qed.

(** **** Relations "inversely compatible" with the multiplicative structure on rings *)


Definition isinvringmultgt (X : ring) (R : hrel X) : UU :=
  (∏ a b, R (a * b) 0 → R a 0 → R b 0) ×
  (∏ a b, R (a * b) 0 → R b 0 → R a 0).

Lemma isinvringmultgttoislinvringmultgt (X : ring) {R : hrel X} (is0 : @isbinophrel X R)
      (is : isinvringmultgt X R) : ∏ a b c : X, R c 0 → R (c * a) (c * b) → R a b.
Proof.
  intros a b c rc0 r.
  set (rab':= (pr2 is0) _ _ (c * - b) r).
  clearbody rab'.
  change (pr1 (R (c * a + c * - b) (c * b + c * - b))) in rab'.
  rewrite <- (ringldistr X _ _ c) in rab'.
  rewrite <- (ringldistr X _ _ c) in rab'.
  rewrite (ringrinvax1 X b) in rab'. rewrite (ringmultx0 X _) in rab'.
  set (r' := (pr1 is) _ _ rab' rc0). clearbody r'.
  set (r'' := (pr2 is0) _ _ b r'). clearbody r''.
  change (pr1 (R (a - b + b) (0 + b))) in r''.
  rewrite (ringlunax1 X _) in r''. rewrite (ringassoc1 X a _ _) in r''.
  rewrite (ringlinvax1 X b) in r''. rewrite (ringrunax1 X _) in r''.
  apply r''.
Qed.

Lemma isinvringmultgttoisrinvringmultgt (X : ring) {R : hrel X} (is0 : @isbinophrel X R)
      (is : isinvringmultgt X R) : ∏ a b c : X, R c 0 → R (a * c) (b * c) → R a b.
Proof.
  intros a b c rc0 r.
  set (rab':= (pr2 is0) _ _ (- b * c) r). clearbody rab'.
  change (pr1 (R (a * c + - b * c) (b * c + - b * c))) in rab'.
  rewrite <- (ringrdistr X _ _ c) in rab'.
  rewrite <- (ringrdistr X _ _ c) in rab'.
  rewrite (ringrinvax1 X b) in rab'.
  rewrite (ringmult0x X _) in rab'.
  set (r' := (pr2 is) _ _ rab' rc0).
  clearbody r'. set (r'' := (pr2 is0) _ _ b r').
  clearbody r''. change (pr1 (R (a - b + b) (0 + b))) in r''.
  rewrite (ringlunax1 X _) in r''. rewrite (ringassoc1 X a _ _) in r''.
  rewrite (ringlinvax1 X b) in r''. rewrite (ringrunax1 X _) in r''.
  apply r''.
Qed.

Lemma islrinvringmultgttoisinvringmultgt (X : ring) {R : hrel X}
      (isl : ∏ a b c : X, R c 0 → R (c * a) (c * b) → R a b)
      (isr : ∏ a b c : X, R c 0 → R (a * c) (b * c) → R a b) : isinvringmultgt X R.
Proof.
  intros. split.
  - intros a b rab ra.
    rewrite <- (ringmultx0 X a) in rab.
    apply (isl _ _ _ ra rab).
  - intros a b rab rb.
    rewrite <- (ringmult0x X b) in rab.
    apply (isr _ _ _ rb rab).
Qed.

Lemma isinvringmultgtaspartinvbinophrel (X : ring) (R : hrel X) (is0 : @isbinophrel X R) :
  (isinvringmultgt X R) <-> (@ispartinvbinophrel (ringmultmonoid X) (λ a, R a 0) R).
Proof.
  intros. split.
  - intro ism. split.
    + apply (isinvringmultgttoislinvringmultgt X is0 ism).
    + apply (isinvringmultgttoisrinvringmultgt X is0 ism).
  - intro isp.
    apply (islrinvringmultgttoisinvringmultgt X (pr1 isp) (pr2 isp)).
Defined.

Lemma isinvringmultgttoisinvrigmultgt (X : ring) {R : hrel X}
      (is0 : @isbinophrel X R) (is : isinvringmultgt X R) : isinvrigmultgt X R.
Proof.
  intros. set (rer := abmonoidrer X). simpl in rer. split.
  - intros a b c d r rab.
    set (r' := (pr2 is0) _ _ (a * - d + - b * c) r). clearbody r'. simpl in r'.
    rewrite (rer _ (b * c) _ _) in r'.
    rewrite <- (ringldistr X _ _ a) in r'.
    rewrite <- (ringrdistr X _ _ c) in r'.
    rewrite (ringrinvax1 X d) in r'.
    rewrite (ringrinvax1 X b) in r'.
    rewrite (ringmult0x X _) in r'.
    rewrite (ringmultx0 X _) in r'.
    rewrite (ringlunax1 X) in r'.
    rewrite (rer _ (b * d) _ _) in r'.
    rewrite <- (ringldistr X _ _ a) in r'.
    simpl in r'.
    fold pr1ring in r'.     (* fold stopped working *)
    change (pr1 X) with (pr1ring X) in r'.
    rewrite <- (ringmultminusminus X b d) in r'.
    rewrite <- (ringldistr X _ _ (- b)) in r'.
    rewrite (ringcomm1 X _ c) in r'.
    rewrite <- (ringrdistr X _ _ _) in r'.
    set (rab' := (pr2 is0) _ _ (- b) rab). clearbody rab'.
    simpl in rab'. rewrite (ringrinvax1 X b) in rab'.
    set (rcd' := (pr1 is) _ _ r' rab').
    set (rcd'' := (pr2 is0) _ _ d rcd'). simpl in rcd''.
    rewrite (ringassoc1 _ _ _) in rcd''. rewrite (ringlinvax1 X _) in rcd''.
    rewrite (ringlunax1 X _) in rcd''. rewrite (ringrunax1 X _) in rcd''.
    apply rcd''.
  - intros a b c d r rcd.
    set (r' := (pr2 is0) _ _ (a * - d + - b * c) r). clearbody r'. simpl in r'.
    rewrite (rer _ (b * c) _ _) in r'.
    rewrite <- (ringldistr X _ _ a) in r'.
    rewrite <- (ringrdistr X _ _ c) in r'.
    rewrite (ringrinvax1 X d) in r'.
    rewrite (ringrinvax1 X b) in r'.
    rewrite (ringmult0x X _) in r'.
    rewrite (ringmultx0 X _) in r'.
    rewrite (ringlunax1 X) in r'.
    rewrite (rer _ (b * d) _ _) in r'.
    rewrite <- (ringldistr X _ _ a) in r'.
    simpl in r'.
    fold pr1ring in r'. (* fold stopped working *)
    change (pr1 X) with (pr1ring X) in r'.
    rewrite <- (ringmultminusminus X b d) in r'.
    rewrite <- (ringldistr X _ _ (- b)) in r'.
    rewrite (ringcomm1 X _ c) in r'.
    rewrite <- (ringrdistr X _ _ _) in r'.
    set (rcd' := (pr2 is0) _ _ (- d) rcd). clearbody rcd'. simpl in rcd'.
    rewrite (ringrinvax1 X d) in rcd'.
    set (rab' := (pr2 is) _ _ r' rcd').
    set (rab'' := (pr2 is0) _ _ b rab'). simpl in rab''.
    rewrite (ringassoc1 _ _ _) in rab''.
    rewrite (ringlinvax1 X _) in rab''.
    rewrite (ringlunax1 X _) in rab''.
    rewrite (ringrunax1 X _) in rab''.
    apply rab''.
Qed.


(** **** Relations on rings and ring homomorphisms *)

Lemma ringaddhrelandfun {X Y : ring} (f : ringfun X Y) (R : hrel Y) (isr : @isbinophrel Y R) :
  @isbinophrel X (λ x x', R (f x) (f x')).
Proof. intros. apply (binophrelandfun (ringaddfun f) R isr). Defined.

Lemma ringmultgtandfun {X Y : ring} (f : ringfun X Y) (R : hrel Y) (isr : isringmultgt Y R) :
  isringmultgt X (λ x x', R (f x) (f x')).
Proof.
  intros. intros a b ra rb.
  set (ax0 := (pr2 (pr1 (pr2 f))) : (f 0) = 0).
  set (ax1 := (pr1 (pr2 (pr2 f))) : ∏ a b, f (a * b) = f a * f b).
  rewrite ax0 in ra. rewrite ax0 in rb.
  rewrite ax0. rewrite (ax1 _ _).
  apply (isr _ _ ra rb).
Defined.

Lemma ringinvmultgtandfun {X Y : ring} (f : ringfun X Y) (R : hrel Y) (isr : isinvringmultgt Y R) :
  isinvringmultgt X (λ x x', R (f x) (f x')).
Proof.
  intros.
  set (ax0 := (pr2 (pr1 (pr2 f))) : (f 0) = 0).
  set (ax1 := (pr1 (pr2 (pr2 f))) : ∏ a b, f (a * b) = f a * f b).
  split.
  - intros a b rab ra.
    rewrite ax0 in ra. rewrite ax0 in rab.
    rewrite ax0. rewrite (ax1 _ _) in rab.
    apply ((pr1 isr) _ _ rab ra).
  - intros a b rab rb. rewrite ax0 in rb.
    rewrite ax0 in rab. rewrite ax0.
    rewrite (ax1 _ _) in rab.
    apply ((pr2 isr) _ _ rab rb).
Defined.

Close Scope ring_scope.


(** **** Subobjects *)

Definition issubring {X : ring} (A : hsubtype X) : UU :=
  (@issubgr X A) ×
  (@issubmonoid (ringmultmonoid X) A).

Lemma isapropissubring {X : ring} (A : hsubtype X) : isaprop (issubring A).
Proof.
  intros. apply (isofhleveldirprod 1).
  - apply isapropissubgr.
  - apply isapropissubmonoid.
Defined.

Definition subring (X : ring) : UU := ∑ (A : hsubtype X), issubring A.

Definition make_gsubring {X : ring}
  (t : hsubtype X)
  (H : issubring t)
  : subring X
  := t ,, H.

Definition pr1subring (X : ring) : @subring X → hsubtype X :=
  @pr1 _ (λ A : hsubtype X, issubring A).

Definition subringtosubsetswith2binop (X : ring) : subring X → @subsetswith2binop X :=
  λ A, make_subsetswith2binop
              (pr1 A) (pr1 (pr1 (pr1 (pr2 A))) ,, pr1 (pr2 (pr2 A))).
Coercion subringtosubsetswith2binop : subring >-> subsetswith2binop.

Definition addsubgr {X : ring} : subring X → @subgr X :=
  λ A, @make_subgr X (pr1 A) (pr1 (pr2 A)).

Definition multsubmonoid {X : ring} : subring X → @submonoid (ringmultmonoid X) :=
  λ A, @make_submonoid (ringmultmonoid X) (pr1 A) (pr2 (pr2 A)).

Lemma isringcarrier {X : ring} (A : subring X) : isringops (@op1 A) (@op2 A).
Proof.
  intros.
  exists (isabgrcarrier (addsubgr A) ,, ismonoidcarrier (multsubmonoid A)).
  split.
  - intros a b c.
    apply (invmaponpathsincl _ (isinclpr1carrier A)).
    simpl. apply ringldistr.
  - intros a b c.
    apply (invmaponpathsincl _ (isinclpr1carrier A)).
    simpl. apply ringrdistr.
Defined.

Definition carrierofasubring (X : ring) (A : subring X) : ring.
Proof. intros. exists A. apply isringcarrier. Defined.
Coercion carrierofasubring : subring >-> ring.


(** **** Quotient objects *)

Definition ringeqrel {X : ring} := @twobinopeqrel X.
Identity Coercion id_ringeqrel : ringeqrel >-> twobinopeqrel.

Definition ringaddabgreqrel {X : ring} (R : @ringeqrel X) :
  @binopeqrel X := @make_binopeqrel X (pr1 R) (pr1 (pr2 R)).

Definition ringmultmonoideqrel {X : ring} (R : @ringeqrel X) :
  @binopeqrel (ringmultmonoid X) := @make_binopeqrel (ringmultmonoid X) (pr1 R) (pr2 (pr2 R)).

Lemma isringquot {X : ring} (R : @ringeqrel X) :
  isringops (@op1 (setwith2binopquot R)) (@op2 (setwith2binopquot R)).
Proof.
  intros.
  exists (isabgrquot (ringaddabgreqrel R) ,, ismonoidquot (ringmultmonoideqrel R)).
  simpl.
  set (opp1 := @op1 (setwith2binopquot R)).
  set (opp2 := @op2 (setwith2binopquot R)).
  split.
  - unfold isldistr.
    apply (setquotuniv3prop
             R (λ x x' x'', make_hProp _ (setproperty (setwith2binopquot R) (opp2  x'' (opp1 x x'))
                                                      (opp1 (opp2 x'' x) (opp2 x'' x'))))).
    intros x x' x''. apply (maponpaths (setquotpr R) (ringldistr X x x' x'')).
  - unfold isrdistr.
    apply (setquotuniv3prop
             R (λ x x' x'', make_hProp _ (setproperty (setwith2binopquot R) (opp2  (opp1 x x') x'')
                                                      (opp1 (opp2 x x'') (opp2 x' x''))))).
    intros x x' x''. apply (maponpaths (setquotpr R) (ringrdistr X x x' x'')).
Defined.

Definition ringquot {X : ring} (R : @ringeqrel X) : ring :=
  @make_ring (setwith2binopquot R) (isringquot R).


(** **** Direct products *)

Lemma isringdirprod (X Y : ring) :
  isringops (@op1 (setwith2binopdirprod X Y)) (@op2 (setwith2binopdirprod X Y)).
Proof.
  intros.
  exists (isabgrdirprod X Y ,, ismonoiddirprod (ringmultmonoid X) (ringmultmonoid Y)).
  simpl. split.
  - intros xy xy' xy''. unfold setwith2binopdirprod.
    unfold op1. unfold op2. simpl.
    apply pathsdirprod.
    + apply (ringldistr X).
    + apply (ringldistr Y).
  - intros xy xy' xy''. unfold setwith2binopdirprod.
    unfold op1. unfold op2. simpl.
    apply pathsdirprod.
    + apply (ringrdistr X).
    + apply (ringrdistr Y).
Defined.

Definition ringdirprod (X Y : ring) : ring := @make_ring (setwith2binopdirprod X Y) (isringdirprod X Y).

(** **** Opposite rings *)

Local Open Scope rig.

(** We just need to reuse and rearrange the opposite rig *)
Definition opposite_ring (X : ring) : ring.
Proof.
  refine (pr1 (X⁰),, _).
  split.
  - split.
    apply make_isabgrop.
    * exact (pr1 (rigop1axs (X⁰)),, pr2 (pr1 (ringop1axs X))).
    * exact (pr2 (ringop1axs X)).
    * exact (rigop2axs (X⁰)).
  - exact (rigdistraxs (X⁰)).
Defined.

Notation "X ⁰" := (opposite_ring X) (at level 12) : ring_scope.

Local Close Scope rig.

(** **** Ring of differences associated with a rig *)

Local Open Scope rig_scope.

Definition rigtoringaddabgr (X : rig) : abgr := abgrdiff (rigaddabmonoid X).

Definition rigtoringcarrier (X : rig) : hSet := pr1 (pr1 (rigtoringaddabgr X)).

Definition rigtoringop1int (X : rig) : binop (X × X) :=
  λ x x', pr1 x + pr1 x' ,, pr2 x + pr2 x'.

Definition rigtoringop1 (X : rig) : binop (rigtoringcarrier X) := @op (rigtoringaddabgr X).

Definition rigtoringop1axs (X : rig) : isabgrop (rigtoringop1 X) := pr2 (rigtoringaddabgr X).

Definition rigtoringunel1 (X : rig) : rigtoringcarrier X := unel (rigtoringaddabgr X).

Definition eqrelrigtoring (X : rig) : eqrel (X × X) := eqrelabgrdiff (rigaddabmonoid X).

Definition rigtoringop2int (X : rig) : binop (X × X) :=
  λ xx xx' : X × X,
   pr1 xx * pr1 xx' + pr2 xx * pr2 xx' ,, pr1 xx * pr2 xx' + pr2 xx * pr1 xx'.

Definition rigtoringunel2int (X : rig) : X × X := 1 ,, 0.

Lemma rigtoringop2comp (X : rig) :
  iscomprelrelfun2 (eqrelrigtoring X) (eqrelrigtoring X) (rigtoringop2int X).
Proof.
  intros. apply iscomprelrelfun2if.
  - intros xx xx' aa. simpl.
    apply @hinhfun. intro tt1. induction tt1 as [ x0 e ].
    exists (x0 * pr2 aa + x0 * pr1 aa).
    set (rd := rigrdistr X). set (cm1 := rigcomm1 X).
    set (as1 := rigassoc1 X). set (rr := abmonoidoprer (rigop1axs X)).

    rewrite (cm1 (pr1 xx * pr1 aa) (pr2 xx  * pr2 aa)).
    rewrite (rr _ (pr1 xx * pr1 aa) (pr1 xx' * pr2 aa) _).
    rewrite (cm1 (pr2 xx * pr2 aa) (pr1 xx' * pr2 aa)).
    induction (rd (pr1 xx) (pr2 xx') (pr1 aa)).
    induction (rd (pr1 xx') (pr2 xx) (pr2 aa)).
    rewrite (rr ((pr1 xx' + pr2 xx) * pr2 aa)
                ((pr1 xx + pr2 xx') * pr1 aa) (x0 * pr2 aa) (x0 * pr1 aa)).
    induction (rd (pr1 xx' + pr2 xx) x0 (pr2 aa)).
    induction (rd (pr1 xx + pr2 xx') x0 (pr1 aa)).

    rewrite (cm1 (pr1 xx' * pr1 aa) (pr2 xx'  * pr2 aa)).
    rewrite (rr _ (pr1 xx' * pr1 aa) (pr1 xx * pr2 aa) _).
    rewrite (cm1 (pr2 xx' * pr2 aa) (pr1 xx * pr2 aa)).
    induction (rd (pr1 xx') (pr2 xx) (pr1 aa)).
    induction (rd (pr1 xx) (pr2 xx') (pr2 aa)).
    rewrite (rr ((pr1 xx + pr2 xx') * pr2 aa)
                ((pr1 xx' + pr2 xx) * pr1 aa) (x0 * pr2 aa) (x0 * pr1 aa)).
    induction (rd (pr1 xx + pr2 xx') x0 (pr2 aa)).
    induction (rd (pr1 xx' + pr2 xx) x0 (pr1 aa)).
    induction e. apply idpath.

  - intros aa xx xx'. simpl. apply @hinhfun. intro tt1.
    induction tt1 as [ x0 e ]. exists (pr1 aa * x0 + pr2 aa * x0).
    set (ld := rigldistr X). set (cm1 := rigcomm1 X).
    set (as1 := rigassoc1 X). set (rr := abmonoidoprer (rigop1axs X)).

    rewrite (rr _ (pr2 aa * pr2 xx) (pr1 aa * pr2 xx') _).
    induction (ld (pr1 xx) (pr2 xx') (pr1 aa)).
    induction (ld (pr2 xx) (pr1 xx') (pr2 aa)).
    rewrite (rr _ (pr2 aa * (pr2 xx + pr1 xx')) (pr1 aa * x0) _).
    induction (ld (pr1 xx + pr2 xx') x0 (pr1 aa)).
    induction (ld (pr2 xx + pr1 xx') x0 (pr2 aa)).

    rewrite (rr _ (pr2 aa * pr2 xx') (pr1 aa * pr2 xx) _).
    induction (ld (pr1 xx') (pr2 xx) (pr1 aa)).
    induction (ld (pr2 xx') (pr1 xx) (pr2 aa)).
    rewrite (rr _ (pr2 aa * (pr2 xx' + pr1 xx)) (pr1 aa * x0) _).
    induction (ld (pr1 xx' + pr2 xx) x0 (pr1 aa)).
    induction (ld (pr2 xx' + pr1 xx) x0 (pr2 aa)).
    rewrite (cm1 (pr2 xx) (pr1 xx')).
    rewrite (cm1 (pr2 xx') (pr1 xx)).
    induction e. apply idpath.
Qed.

Definition rigtoringop2 (X : rig) : binop (rigtoringcarrier X) :=
  setquotfun2 (eqrelrigtoring X) (eqrelrigtoring X) (rigtoringop2int X) (rigtoringop2comp X).

Lemma rigtoringassoc2 (X : rig) : isassoc (rigtoringop2 X).
Proof.
  unfold isassoc.
  apply (setquotuniv3prop _ (λ x x' x'', _ = _)).
  intros x x' x''.
  change (setquotpr (eqrelrigtoring X) (rigtoringop2int X (rigtoringop2int X x x') x'')
        = setquotpr (eqrelrigtoring X) (rigtoringop2int X x (rigtoringop2int X x' x''))).
  apply (maponpaths (setquotpr (eqrelrigtoring X))). unfold rigtoringop2int.
  simpl.
  set (rd := rigrdistr X). set (ld := rigldistr X).
  set (cm1 := rigcomm1 X).
  set (as1 := rigassoc1 X). set (as2 := rigassoc2 X).
  set (rr := abmonoidoprer (rigop1axs X)). apply pathsdirprod.

  rewrite (rd _ _ (pr1 x'')). rewrite (rd _ _ (pr2 x'')).
  rewrite (ld _ _ (pr1 x)). rewrite (ld _ _ (pr2 x)).
  induction (as2 (pr1 x) (pr1 x') (pr1 x'')).
  induction (as2 (pr1 x) (pr2 x') (pr2 x'')).
  induction (as2 (pr2 x) (pr1 x') (pr2 x'')).
  induction (as2 (pr2 x) (pr2 x') (pr1 x'')).
  induction (cm1 (pr2 x * pr2 x' * pr1 x'') (pr2 x * pr1 x' * pr2 x'')).
  rewrite (rr _ (pr2 x * pr2 x' * pr1 x'') (pr1 x * pr2 x' * pr2 x'') _).
  apply idpath.

  rewrite (rd _ _ (pr1 x'')). rewrite (rd _ _ (pr2 x'')).
  rewrite (ld _ _ (pr1 x)). rewrite (ld _ _ (pr2 x)).
  induction (as2 (pr1 x) (pr1 x') (pr2 x'')).
  induction (as2 (pr1 x) (pr2 x') (pr1 x'')).
  induction (as2 (pr2 x) (pr1 x') (pr1 x'')).
  induction (as2 (pr2 x) (pr2 x') (pr2 x'')).
  induction (cm1 (pr2 x * pr2 x' * pr2 x'') (pr2 x * pr1 x' * pr1 x'')).
  rewrite (rr _ (pr1 x * pr2 x' * pr1 x'') (pr2 x * pr2 x' * pr2 x'') _).
  apply idpath.
Qed.

Definition rigtoringunel2 (X : rig) : rigtoringcarrier X :=
  setquotpr (eqrelrigtoring X) (rigtoringunel2int X).

Lemma rigtoringlunit2 (X : rig) : islunit (rigtoringop2 X) (rigtoringunel2 X).
Proof.
  unfold islunit.
  apply (setquotunivprop _ (λ x, _ = _)).
  intro x.
  change (setquotpr (eqrelrigtoring X) (rigtoringop2int X (rigtoringunel2int X) x)
        = setquotpr (eqrelrigtoring X) x).
  apply (maponpaths (setquotpr (eqrelrigtoring X))).
  unfold rigtoringop2int. simpl. induction x as [ x1 x2 ]. simpl.
  set (lu2 := riglunax2 X). set (ru1 := rigrunax1 X). set (m0x := rigmult0x X).
  apply pathsdirprod.
  - rewrite (lu2 x1). rewrite (m0x x2). apply (ru1 x1).
  - rewrite (lu2 x2). rewrite (m0x x1). apply (ru1 x2).
Qed.

Lemma rigtoringrunit2 (X : rig) : isrunit (rigtoringop2 X) (rigtoringunel2 X).
Proof.
  unfold isrunit.
  apply (setquotunivprop _ (λ x, _ = _)).
  intro x.
  change (setquotpr (eqrelrigtoring X) (rigtoringop2int X x (rigtoringunel2int X))
        = setquotpr (eqrelrigtoring X) x).
  apply (maponpaths (setquotpr (eqrelrigtoring X))). unfold rigtoringop2int.
  simpl. induction x as [ x1 x2 ]. simpl.
  set (ru1 := rigrunax1 X). set (ru2 := rigrunax2 X).
  set (lu1 := riglunax1 X). set (mx0 := rigmultx0 X).
  apply pathsdirprod.
  - rewrite (ru2 x1). rewrite (mx0 x2). apply (ru1 x1).
  - rewrite (ru2 x2). rewrite (mx0 x1). apply (lu1 x2).
Qed.

Definition rigtoringisunit (X : rig) : isunit (rigtoringop2 X) (rigtoringunel2 X) :=
  rigtoringlunit2 X ,, rigtoringrunit2 X.

Definition rigtoringisunital (X : rig) : isunital (rigtoringop2 X) :=
  rigtoringunel2 X ,, rigtoringisunit X.

Definition rigtoringismonoidop2 (X : rig) : ismonoidop (rigtoringop2 X) :=
  rigtoringassoc2 X ,, rigtoringisunital X.

Lemma rigtoringldistr (X : rig) : isldistr (rigtoringop1 X) (rigtoringop2 X).
Proof.
  unfold isldistr.
  apply (setquotuniv3prop _ (λ x x' x'', _ = _)).
  intros x x' x''.
  change (setquotpr (eqrelrigtoring X) (rigtoringop2int X x'' (rigtoringop1int X x x'))
        = setquotpr _ (rigtoringop1int X (rigtoringop2int X x'' x) (rigtoringop2int X x'' x'))).
  apply (maponpaths (setquotpr (eqrelrigtoring X))).
  unfold rigtoringop1int. unfold rigtoringop2int. simpl.
  set (ld := rigldistr X). set (cm1 := rigcomm1 X).
  set (rr := abmonoidoprer (rigop1axs X)).
  apply pathsdirprod.
  - rewrite (ld _ _ (pr1 x'')). rewrite (ld _ _ (pr2 x'')).
    apply (rr _ (pr1 x'' * pr1 x') (pr2 x'' * pr2 x) _).
  - rewrite (ld _ _ (pr1 x'')). rewrite (ld _ _ (pr2 x'')).
    apply (rr _ (pr1 x'' * pr2 x') (pr2 x'' * pr1 x) _).
Qed.

Lemma rigtoringrdistr (X : rig) : isrdistr (rigtoringop1 X) (rigtoringop2 X).
Proof.
  unfold isrdistr.
  apply (setquotuniv3prop _ (λ x x' x'', _ = _)).
  intros x x' x''.
  change (setquotpr (eqrelrigtoring X) (rigtoringop2int X (rigtoringop1int X x x') x'')
        = setquotpr _ (rigtoringop1int X (rigtoringop2int X x x'') (rigtoringop2int X x' x''))).
  apply (maponpaths (setquotpr (eqrelrigtoring X))).
  unfold rigtoringop1int. unfold rigtoringop2int. simpl.
  set (rd := rigrdistr X). set (cm1 := rigcomm1 X).
  set (rr := abmonoidoprer (rigop1axs X)).
  apply pathsdirprod.
  - rewrite (rd _ _ (pr1 x'')). rewrite (rd _ _ (pr2 x'')).
    apply (rr _ (pr1 x' * pr1 x'') (pr2 x * pr2 x'') _).
  - rewrite (rd _ _ (pr1 x'')). rewrite (rd _ _ (pr2 x'')).
    apply (rr _ (pr1 x' * pr2 x'') (pr2 x * pr1 x'') _).
Qed.

Definition rigtoringdistr (X : rig) : isdistr (rigtoringop1 X) (rigtoringop2 X) :=
  rigtoringldistr X ,, rigtoringrdistr X.

Definition rigtoring (X : rig) : ring.
Proof.
  exists (@make_setwith2binop (rigtoringcarrier X) (rigtoringop1 X ,, rigtoringop2 X)).
  split.
  - apply (rigtoringop1axs X ,, rigtoringismonoidop2 X).
  - apply (rigtoringdistr X).
Defined.


(** **** Canonical homomorphism to the ring associated with a rig (ring of differences) *)

Definition toringdiff (X : rig) (x : X) : rigtoring X := setquotpr _ (x ,, 0).

Lemma isbinop1funtoringdiff (X : rig) : @isbinopfun (rigaddabmonoid X) (rigtoring X) (toringdiff X).
Proof.
  intros. unfold isbinopfun. intros x x'.
  apply (isbinopfuntoabgrdiff (rigaddabmonoid X) x x').
Qed.

Lemma isunital1funtoringdiff (X : rig) : (toringdiff X 0) = 0%ring.
Proof.
  apply idpath.
Qed.

Definition isaddmonoidfuntoringdiff (X : rig) :
  @ismonoidfun (rigaddabmonoid X) (rigtoring X) (toringdiff X) :=
  isbinop1funtoringdiff X ,, isunital1funtoringdiff X.

Lemma isbinop2funtoringdiff (X : rig) :
  @isbinopfun (rigmultmonoid X) (ringmultmonoid (rigtoring X)) (toringdiff X).
Proof.
  intros. unfold isbinopfun. intros x x'.
  change (setquotpr (eqrelrigtoring X) (x * x' ,, 0)
        = setquotpr _ (rigtoringop2int X (x ,, 0) (x' ,, 0))).
  apply (maponpaths (setquotpr _)). unfold rigtoringop2int. simpl.
  apply pathsdirprod.
  - rewrite (rigmultx0 X _). rewrite (rigrunax1 X _). apply idpath.
  - rewrite (rigmult0x X _). rewrite (rigmultx0 X _). rewrite (rigrunax1 X _).
    apply idpath.
Defined.

Lemma isunital2funtoringdiff  (X : rig) : (toringdiff X 1) = 1%ring.
Proof.
  apply idpath.
Qed.

Definition ismultmonoidfuntoringdiff (X : rig) :
  @ismonoidfun (rigmultmonoid X) (ringmultmonoid (rigtoring X)) (toringdiff X) :=
  isbinop2funtoringdiff X ,, isunital2funtoringdiff X.

Definition isrigfuntoringdiff (X : rig) : @isrigfun X (rigtoring X) (toringdiff X) :=
  isaddmonoidfuntoringdiff X ,, ismultmonoidfuntoringdiff X.

Definition isincltoringdiff (X : rig) (iscanc : ∏ x : X, @isrcancelable X (@op1 X) x) :
  isincl (toringdiff X) := isincltoabgrdiff (rigaddabmonoid X) iscanc.


(** **** Relations similar to "greater" or "greater or equal" on the ring associated with a rig *)

Definition rigtoringrel (X : rig) {R : hrel X} (is : @isbinophrel (rigaddabmonoid X) R) :
  hrel (rigtoring X) := abgrdiffrel (rigaddabmonoid X) is.

Lemma isringrigtoringmultgt (X : rig) {R : hrel X} (is0 : @isbinophrel (rigaddabmonoid X) R)
      (is : isrigmultgt X R) : isringmultgt (rigtoring X) (rigtoringrel X is0).
Proof.
  intros.
  set (assoc := rigassoc1 X). set (comm := rigcomm1 X).
  set (rer := (abmonoidrer (rigaddabmonoid X)) :
                ∏ a b c d : X, (a + b) + (c + d) = (a + c) + (b + d)).
  set (ld := rigldistr X). set (rd := rigrdistr X).
  assert (int : ∏ a b, isaprop (rigtoringrel X is0 a ringunel1 → rigtoringrel X is0 b ringunel1 →
                                rigtoringrel X is0 (a * b) ringunel1)).
  {
    intros a b.
    apply impred. intro.
    apply impred. intro.
    apply (pr2 _).
  }
  unfold isringmultgt.
  apply (setquotuniv2prop _ (λ a b, make_hProp _ (int a b))).

  intros xa1 xa2.
  change ((abgrdiffrelint (rigaddabmonoid X) R) xa1 (@rigunel1 X ,, @rigunel1 X) →
          (abgrdiffrelint (rigaddabmonoid X) R) xa2 (@rigunel1 X ,, @rigunel1 X) →
          (abgrdiffrelint (rigaddabmonoid X) R (@rigtoringop2int X xa1 xa2)
                          (@rigunel1 X ,, @rigunel1 X))).
  unfold abgrdiffrelint. simpl. apply hinhfun2. intros t22 t21.
  set (c2 := pr1 t21). set (c1 := pr1 t22).
  set (r1 := pr2 t21). set (r2 := pr2 t22).
  set (x1 := pr1 xa1). set (a1 := pr2 xa1).
  set (x2 := pr1 xa2). set (a2 := pr2 xa2).
  exists
  ((x1 * c2 + a1 * c2) + ((c1 * x2 + c1 * c2) + (c1 * a2 + c1 * c2))).
  change (pr1 (R (x1 * x2 + a1 * a2 + 0 +
                  ((x1 * c2 + a1 * c2) + ((c1 * x2 + c1 * c2) + (c1 * a2 + c1 * c2))))
                 (0 + (x1 * a2 + a1 * x2) +
                  (x1 * c2 + a1 * c2 + ((c1 * x2 + c1 * c2) + (c1 * a2 + c1 * c2)))))).
  rewrite (riglunax1 X _). rewrite (rigrunax1 X _).
  rewrite (assoc (x1 * c2) _ _).
  rewrite (rer _ (a1 * a2) _ _). rewrite (rer _ (a1 * x2) _ _).
  rewrite <- (assoc (a1 * a2) _ _).
  rewrite <- (assoc (a1 * x2) _ _).
  rewrite <- (assoc (x1 * x2 + _) _ _).
  rewrite <- (assoc (x1 * a2 + _) _ _).
  rewrite (rer _ (a1 * a2 + _) _ _). rewrite (rer _ (a1 * x2 + _) _ _).
  rewrite <- (ld _ _ x1). rewrite <- (ld _ _ x1).
  rewrite <- (ld _ _ c1). rewrite <- (ld _ _ c1).
  rewrite <- (ld _ _ a1). rewrite <- (ld _ _ a1).
  rewrite <- (rd _ _ (x2 + c2)).
  rewrite <- (rd _ _ (a2 + c2)).
  rewrite (comm (a1 * _) _).  rewrite (rer _ (c1 * _) _ _).
  rewrite <- (rd _ _ (x2 + c2)).
  rewrite <- (rd _ _ (a2 + c2)).
  clearbody r1. clearbody r2.
  change (pr1 (R (x2 + 0 + c2) (0 + a2 + c2))) in r1.
  change (pr1 (R (x1 + 0 + c1) (0 + a1 + c1))) in r2.
  rewrite (rigrunax1 X _) in r1. rewrite (riglunax1 X _) in r1.
  rewrite (rigrunax1 X _) in r2. rewrite (riglunax1 X _) in r2.
  rewrite (comm c1 a1).
  apply (is _ _ _ _ r2 r1).
Qed.

Definition isdecrigtoringrel (X : rig) {R : hrel X} (is : @isbinophrel (rigaddabmonoid X) R)
           (is' : @isinvbinophrel (rigaddabmonoid X) R) (isd : isdecrel R) :
  isdecrel (rigtoringrel X is).
Proof. intros. apply (isdecabgrdiffrel (rigaddabmonoid X) is is' isd). Defined.

Lemma isinvringrigtoringmultgt (X : rig) {R : hrel X} (is0 : @isbinophrel (rigaddabmonoid X) R)
      (is1 : @isinvbinophrel (rigaddabmonoid X) R) (is : isinvrigmultgt X R) :
  isinvringmultgt (rigtoring X) (rigtoringrel X is0).
Proof.
  intros. split.
  - assert (int : ∏ a b, isaprop (rigtoringrel X is0 (a * b) ringunel1 →
                                  rigtoringrel X is0 a ringunel1 →
                                  rigtoringrel X is0 b ringunel1)).
    intros.
    apply impred. intro.
    apply impred. intro.
    apply (pr2 _).
    apply (setquotuniv2prop _ (λ a b, make_hProp _ (int a b))).

    intros xa1 xa2.
    change ((abgrdiffrelint (rigaddabmonoid X) R (@rigtoringop2int X xa1 xa2)
                            (@rigunel1 X ,, @rigunel1 X)) →
            (abgrdiffrelint (rigaddabmonoid X) R) xa1 (@rigunel1 X ,, @rigunel1 X) →
            (abgrdiffrelint (rigaddabmonoid X) R) xa2 (@rigunel1 X ,, @rigunel1 X)).
    unfold abgrdiffrelint. simpl. apply hinhfun2. intros t22 t21.
    set (c2 := pr1 t22). set (c1 := pr1 t21).
    set (r1 := pr2 t21). set (r2 := pr2 t22).
    set (x1 := pr1 xa1). set (a1 := pr2 xa1).
    set (x2 := pr1 xa2). set (a2 := pr2 xa2).
    simpl in r2. clearbody r2.
    change (pr1 (R (x1 * x2 + a1 * a2 + 0 + c2) (0 + (x1 * a2 + a1 * x2) + c2))) in r2.
    rewrite (riglunax1 X _) in r2. rewrite (rigrunax1 X _) in r2.
    rewrite (rigrunax1 X _). rewrite (riglunax1 X _).
    set (r2' := (pr2 is1) _ _ c2 r2). clearbody r1.
    change (pr1 (R (x1 + 0 + c1) (0 + a1 + c1))) in r1.
    rewrite (riglunax1 X _) in r1. rewrite (rigrunax1 X _) in r1.
    set (r1' := (pr2 is1) _ _ c1 r1). exists 0.
    rewrite (rigrunax1 X _). rewrite (rigrunax1 X _).
    apply ((pr1 is) _ _ _ _ r2' r1').

  - assert (int : ∏ a b, isaprop (rigtoringrel X is0 (a * b) ringunel1 →
                                  rigtoringrel X is0 b ringunel1 →
                                  rigtoringrel X is0 a ringunel1)).
    intros.
    apply impred. intro.
    apply impred. intro.
    apply (pr2 _).
    apply (setquotuniv2prop _ (λ a b, make_hProp _ (int a b))).

    intros xa1 xa2.
    change ((abgrdiffrelint (rigaddabmonoid X) R (@rigtoringop2int X xa1 xa2)
                            (@rigunel1 X ,, @rigunel1 X)) →
            (abgrdiffrelint (rigaddabmonoid X) R) xa2 (@rigunel1 X ,, @rigunel1 X) →
            (abgrdiffrelint (rigaddabmonoid X) R) xa1 (@rigunel1 X ,, @rigunel1 X)).
    unfold abgrdiffrelint. simpl. apply hinhfun2. intros t22 t21.
    set (c2 := pr1 t22). set (c1 := pr1 t21).
    set (r1 := pr2 t21). set (r2 := pr2 t22).
    set (x1 := pr1 xa1). set (a1 := pr2 xa1).
    set (x2 := pr1 xa2). set (a2 := pr2 xa2).
    simpl in r2. clearbody r2.
    change (pr1 (R (x1 * x2 + a1 * a2 + 0 + c2)
                   (0 + (x1 * a2 + a1 * x2) + c2))) in r2.
    rewrite (riglunax1 X _) in r2. rewrite (rigrunax1 X _) in r2.
    rewrite (rigrunax1 X _). rewrite (riglunax1 X _).
    set (r2' := (pr2 is1) _ _ c2 r2). clearbody r1.
    change (pr1 (R (x2 + 0 + c1) (0 + a2 + c1))) in r1.
    rewrite (riglunax1 X _) in r1. rewrite (rigrunax1 X _) in r1.
    set (r1' := (pr2 is1) _ _ c1 r1). exists 0.
    rewrite (rigrunax1 X _). rewrite (rigrunax1 X _).
    apply ((pr2 is) _ _ _ _ r2' r1').
Qed.


(** **** Relations and the canonical homomorphism to the ring associated with a rig (ring of differences) *)

Lemma iscomptoringdiff (X : rig) {L : hrel X} (is0 : @isbinophrel (rigaddabmonoid X) L) :
  iscomprelrelfun L (rigtoringrel X is0) (toringdiff X).
Proof.
  apply (iscomptoabgrdiff (rigaddabmonoid X)).
Qed.

Close Scope rig_scope.


(** *** Commutative rings *)

(** **** General definitions *)

Definition iscommring (X : setwith2binop) : UU := iscommringops (@op1 X) (@op2 X).

Definition commring : UU := ∑ (X : setwith2binop), iscommringops (@op1 X) (@op2 X).

Definition make_commring (X : setwith2binop) (is : iscommringops (@op1 X) (@op2 X)) :
  ∑ X0 : setwith2binop, iscommringops op1 op2 :=
  X ,, is.

Definition commringconstr {X : hSet} (opp1 opp2 : binop X)
           (ax11 : isgrop opp1) (ax12 : iscomm opp1)
           (ax21 : ismonoidop opp2) (ax22 : iscomm opp2)
           (dax : isdistr opp1 opp2) : commring :=
  @make_commring (make_setwith2binop X (opp1 ,, opp2))
               ((((ax11 ,, ax12) ,, ax21) ,, dax) ,, ax22).

Definition commringtoring : commring → ring := λ X, @make_ring (pr1 X) (pr1 (pr2 X)).
Coercion commringtoring : commring >-> ring.

Definition ringcomm2 (X : commring) : iscomm (@op2 X) := pr2 (pr2 X).

Definition commringop2axs (X : commring) : isabmonoidop (@op2 X) :=
  ringop2axs X ,, ringcomm2 X.

Definition ringmultabmonoid (X : commring) : abmonoid :=
  make_abmonoid (make_setwithbinop X op2) (ringop2axs X ,, ringcomm2 X).

Definition commringtocommrig (X : commring) : commrig := make_commrig _ (pr2 X).
Coercion commringtocommrig : commring >-> commrig.


(** **** (X = Y) ≃ (ringiso X Y)
    We use the following composition

                          (X = Y) ≃ (make_commring' X = make_commring' Y)
                                  ≃ ((pr1 (make_commring' X)) = (pr1 (make_commring' Y)))
                                  ≃ (ringiso X Y)

    where the third weak equivalence is given by univalence for ring, [ring_univalence]. We define
    [commring'] to be able to use [ring_univalence].
 *)

Local Definition commring' : UU :=
  ∑ D : (∑ X : setwith2binop, isringops (@op1 X) (@op2 X)), iscomm (@op2 (pr1 D)).

Local Definition make_commring' (CR : commring) : commring' :=
  (pr1 CR ,, dirprod_pr1 (pr2 CR)) ,, dirprod_pr2 (pr2 CR).

Definition commring_univalence_weq1 : commring ≃ commring' :=
  weqtotal2asstol
    (λ X : setwith2binop, isringops (@op1 X) (@op2 X))
    (λ (y : (∑ (X : setwith2binop), isringops (@op1 X) (@op2 X))), iscomm (@op2 (pr1 y))).

Definition commring_univalence_weq1' (X Y : commring) : (X = Y) ≃ (make_commring' X = make_commring' Y) :=
  make_weq _ (@isweqmaponpaths commring commring' commring_univalence_weq1 X Y).

Definition commring_univalence_weq2 (X Y : commring) :
  ((make_commring' X) = (make_commring' Y)) ≃ ((pr1 (make_commring' X)) = (pr1 (make_commring' Y))).
Proof.
  use subtypeInjectivity.
  intros w. use isapropiscomm.
Defined.
Opaque commring_univalence_weq2.

Definition commring_univalence_weq3 (X Y : commring) :
  ((pr1 (make_commring' X)) = (pr1 (make_commring' Y))) ≃ (ringiso X Y) :=
  ring_univalence (pr1 (make_commring' X)) (pr1 (make_commring' Y)).

Definition commring_univalence_map (X Y : commring) : (X = Y) → (ringiso X Y).
Proof.
  intros e. induction e. exact (idrigiso X).
Defined.

Lemma commring_univalence_isweq (X Y : commring) : isweq (commring_univalence_map X Y).
Proof.
  use isweqhomot.
  - exact (weqcomp (commring_univalence_weq1' X Y)
                   (weqcomp (commring_univalence_weq2 X Y) (commring_univalence_weq3 X Y))).
  - intros e. induction e.
    refine (weqcomp_to_funcomp_app @ _).
    exact weqcomp_to_funcomp_app.
  - use weqproperty.
Defined.
Opaque commring_univalence_isweq.

Definition commring_univalence (X Y : commring) : (X = Y) ≃ (ringiso X Y)
  := make_weq
    (commring_univalence_map X Y)
    (commring_univalence_isweq X Y).


(** **** Computational lemmas for commutative rings *)

Local Open Scope ring_scope.

Lemma commringismultcancelableif (X : commring) (x : X) (isl : ∏ y, x * y = 0 → y = 0) :
  iscancelable op2 x.
Proof.
  intros. split.
  - apply (ringismultlcancelableif X x isl).
  - assert (isr : ∏ y, y * x = 0 → y = 0).
    intros y e. rewrite (ringcomm2 X _ _) in e. apply (isl y e).
    apply (ringismultrcancelableif X x isr).
Qed.

Close Scope ring_scope.


(** **** Subobjects *)

Lemma iscommringcarrier {X : commring} (A : @subring X) : iscommringops (@op1 A) (@op2 A).
Proof.
  intros. exists (isringcarrier A).
  apply (pr2 (@isabmonoidcarrier (ringmultabmonoid X) (multsubmonoid A))).
Defined.

Definition carrierofasubcommring {X : commring} (A : @subring X) : commring :=
  make_commring A (iscommringcarrier A).


(** **** Quotient objects *)

Lemma iscommringquot {X : commring} (R : @ringeqrel X) :
  iscommringops (@op1 (setwith2binopquot R)) (@op2 (setwith2binopquot R)).
Proof.
  intros. exists (isringquot R).
  apply (pr2 (@isabmonoidquot (ringmultabmonoid X) (ringmultmonoideqrel R))).
Defined.

Definition commringquot {X : commring} (R : @ringeqrel X) : commring :=
  make_commring (setwith2binopquot R) (iscommringquot R).


(** **** Direct products *)

Lemma iscommringdirprod (X Y : commring) :
  iscommringops (@op1 (setwith2binopdirprod X Y)) (@op2 (setwith2binopdirprod X Y)).
Proof.
  intros. exists (isringdirprod X Y).
  apply (pr2 (isabmonoiddirprod (ringmultabmonoid X) (ringmultabmonoid Y))).
Defined.

Definition commringdirprod (X Y : commring) : commring :=
  make_commring (setwith2binopdirprod X Y) (iscommringdirprod X Y).

(** **** Opposite commutative rings *)

Local Open Scope ring.

(** We reuse much of the proof for general rigs *)
Definition opposite_commring (X : commring) : commring :=
  pr1 (X⁰),, pr2 (X⁰) ,, λ x y, @ringcomm2 X y x.

(** Commutativity makes taking the opposite trivial *)
Definition iso_commring_opposite (X : commring) : rigiso X (opposite_commring X) :=
  iso_commrig_opposite X.

Local Close Scope rig.

(** **** Commutative rigs to commutative rings *)

Local Open Scope rig_scope.

Lemma commrigtocommringcomm2 (X : commrig) : iscomm (rigtoringop2 X).
Proof.
  unfold iscomm.
  apply (setquotuniv2prop _ (λ x x', _ = _)).
  intros x x'.
  change (setquotpr (eqrelrigtoring X) (rigtoringop2int X x x')
        = setquotpr (eqrelrigtoring X) (rigtoringop2int X x' x)).
  apply (maponpaths (setquotpr (eqrelrigtoring X))).
  unfold rigtoringop2int.
  set (cm1 := rigcomm1 X). set (cm2 := rigcomm2 X).
  apply pathsdirprod.
  - rewrite (cm2 (pr1 x) (pr1 x')). rewrite (cm2 (pr2 x) (pr2 x')).
    apply idpath.
  - rewrite (cm2 (pr1 x) (pr2 x')). rewrite (cm2 (pr2 x) (pr1 x')).
    apply cm1.
Qed.

Definition commrigtocommring (X : commrig) : commring.
Proof.
  exists (rigtoring X). split.
  - apply (pr2 (rigtoring X)).
  - apply (commrigtocommringcomm2 X).
Defined.

Close Scope rig_scope.


(** **** Rings of fractions *)

Local Open Scope ring_scope.

Definition commringfracop1int (X : commring) (S : @subabmonoid (ringmultabmonoid X))
  : binop (X × S)
  := λ (x1s1 x2s2 : X × S),
      pr1 (pr2 x2s2) * pr1 x1s1 + pr1 (pr2 x1s1) * pr1 x2s2 ,,
      op (pr2 x1s1) (pr2 x2s2).

Definition commringfracop2int (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  binop (X × S) := abmonoidfracopint (ringmultabmonoid X) S.

Definition commringfracunel1int (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  X × S := 0 ,, unel S.

Definition commringfracunel2int (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  X × S := 1 ,, unel S.

Definition commringfracinv1int (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  X × S → X × S := λ xs, -1 * pr1 xs ,, pr2 xs.

Definition eqrelcommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  eqrel (X × S) := eqrelabmonoidfrac (ringmultabmonoid X) S.

Lemma commringfracl1 (X : commring) (x1 x2 x3 x4 a1 a2 s1 s2 s3 s4 : X)
      (eq1 : (x1 * s2) * a1 = (x2 * s1) * a1)
      (eq2 : (x3 * s4) * a2 = (x4 * s3) * a2) :
  ((s3 * x1 + s1 * x3) * (s2 * s4)) * (a1 * a2)
= ((s4 * x2 + s2 * x4) * (s1 * s3)) * (a1 * a2).
Proof.
  intros.
  set (rdistr := ringrdistr X). set (assoc2 := ringassoc2 X).
  set (op2axs := commringop2axs X). set (comm2 := ringcomm2 X).
  set (rer := abmonoidoprer op2axs).

  rewrite (rdistr (s3 * x1) (s1 * x3)  (s2 * s4)).
  rewrite (rdistr (s4 * x2) (s2 * x4) (s1 * s3)).
  rewrite (rdistr ((s3 * x1) * (s2 * s4)) ((s1 * x3) * (s2 * s4)) (a1 * a2)).
  rewrite (rdistr ((s4 * x2) * (s1 * s3)) ((s2 * x4) * (s1 * s3)) (a1 * a2)).
  clear rdistr.
  assert (e1 : ((s3 * x1) * (s2 * s4)) * (a1 * a2)
             = ((s4 * x2) * (s1 * s3)) * (a1 * a2)).
  {
    induction (assoc2 (s3 * x1) s2 s4).
    rewrite (assoc2 s3 x1 s2). rewrite (rer (s3 * (x1 * s2)) s4 a1 a2).
    rewrite (assoc2 s3 (x1 * s2) a1).
    induction (assoc2 (s4 * x2) s1 s3).
    rewrite (assoc2 s4 x2 s1). rewrite (rer (s4 * (x2 * s1)) s3 a1 a2).
    rewrite (assoc2 s4 (x2 * s1) a1). induction eq1.
    rewrite (comm2 s3 ((x1 * s2) * a1)). rewrite (comm2 s4 ((x1 * s2) * a1)).
    rewrite (rer ((x1 * s2) * a1) s3 s4 a2).
    apply idpath.
  }
  assert (e2 : ((s1 * x3) * (s2 * s4)) * (a1 * a2)
             = ((s2 * x4) * (s1 * s3)) * (a1 * a2)).
  {
    induction (comm2 s4 s2). induction (comm2 s3 s1). induction (comm2 a2 a1).
    induction (assoc2 (s1 * x3) s4 s2). induction (assoc2 (s2 * x4) s3 s1).
    rewrite (assoc2 s1 x3 s4). rewrite (assoc2 s2 x4 s3).
    rewrite (rer (s1 * (x3 * s4)) s2 a2 a1).
    rewrite (rer (s2 * (x4 * s3)) s1 a2 a1).
    rewrite (assoc2 s1 (x3 * s4) a2).
    rewrite (assoc2 s2 (x4 * s3) a2).
    induction eq2. induction (comm2 ((x3 * s4) * a2) s1).
    induction (comm2 ((x3 *s4) * a2) s2).
    rewrite (rer ((x3 * s4) * a2) s1 s2 a1).
    apply idpath.
  }
  induction e1. induction e2. apply idpath.
Qed.

Lemma commringfracop1comp (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  iscomprelrelfun2 (eqrelcommringfrac X S) (eqrelcommringfrac X S) (commringfracop1int X S).
Proof.
  intros. intros xs1 xs2 xs3 xs4. simpl.
  set (ff := @hinhfun2). simpl in ff. apply ff. clear ff.
  intros tt1 tt2. exists (@op S (pr1 tt1) (pr1 tt2)).
  set (eq1 := pr2 tt1). simpl in eq1.
  set (eq2 := pr2 tt2). simpl in eq2.
  unfold pr1carrier.
  apply (commringfracl1 X (pr1 xs1) (pr1 xs2) (pr1 xs3) (pr1 xs4)
                       (pr1 (pr1 tt1)) (pr1 (pr1 tt2)) (pr1 (pr2 xs1))
                       (pr1 (pr2 xs2)) (pr1 (pr2 xs3)) (pr1 (pr2 xs4)) eq1 eq2).
Qed.

Definition commringfracop1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  binop (setquotinset (eqrelcommringfrac X S)) :=
  setquotfun2 (eqrelcommringfrac X S) (eqrelcommringfrac X S)
              (commringfracop1int X S) (commringfracop1comp X S).

Lemma commringfracl2 (X : commring) (x x' x'' s s' s'' : X) :
  s'' * (s' * x + s * x') + (s * s') * x''
= (s' * s'') * x + s * (s'' * x' + s' * x'').
Proof.
  intros.
  set (ldistr := ringldistr X). set (comm2 := ringcomm2 X).
  set (assoc2 := ringassoc2 X). set (assoc1 := ringassoc1 X).
  rewrite (ldistr (s' * x) (s * x') s'').
  rewrite (ldistr (s'' * x') (s' * x'') s).
  induction (comm2 s'' s').
  induction (assoc2 s'' s' x). induction (assoc2 s'' s x').
  induction (assoc2 s s'' x').
  induction (comm2 s s'').
  induction (assoc2 s s' x'').
  apply (assoc1 ((s'' * s') * x) ((s * s'') * x') ((s * s') * x'')).
Qed.

Lemma commringfracassoc1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  isassoc (commringfracop1 X S).
Proof.
  intros.
  set (R := eqrelcommringfrac X S).
  set (add1int := commringfracop1int X S).
  set (add1 := commringfracop1 X S).
  unfold isassoc.
  assert (int : ∏ (xs xs' xs'' : X × S),
                setquotpr R (add1int (add1int xs xs') xs'')
              = setquotpr R (add1int xs (add1int xs' xs''))).
  unfold add1int. unfold commringfracop1int. intros xs xs' xs''.
  apply (@maponpaths _ _ (setquotpr R)). simpl. apply pathsdirprod.
  - unfold pr1carrier.
    apply (commringfracl2 X (pr1 xs) (pr1 xs') (pr1 xs'') (pr1 (pr2 xs))
                         (pr1 (pr2 xs')) (pr1 (pr2 xs''))).
  - apply (invmaponpathsincl _ (isinclpr1carrier (pr1 S))).
    unfold pr1carrier. simpl. set (assoc2 := ringassoc2 X).
    apply (assoc2 (pr1 (pr2 xs)) (pr1 (pr2 xs')) (pr1 (pr2 xs''))).
  - apply (setquotuniv3prop R (λ x x' x'', _ = _)), int.
Qed.

Lemma commringfraccomm1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  iscomm (commringfracop1 X S).
Proof.
  intros.
  set (R := eqrelcommringfrac X S).
  set (add1int := commringfracop1int X S).
  set (add1 := commringfracop1 X S).
  unfold iscomm.
  apply (setquotuniv2prop _ (λ x x', _ = _)).
  intros xs xs'.
  apply (@maponpaths _ _ (setquotpr R) (add1int xs xs') (add1int xs' xs)).
  unfold add1int. unfold commringfracop1int.
  induction xs as [ x s ]. induction s as [ s iss ].
  induction xs' as [ x' s' ]. induction s' as [ s' iss' ].
  simpl.
  apply pathsdirprod.
  - change (s' * x + s * x' = s * x' + s' * x).
    induction (ringcomm1 X (s' * x) (s * x')). apply idpath.
  - apply (invmaponpathsincl _ (isinclpr1carrier (pr1 S))).
    simpl. change (s * s' = s' * s). apply (ringcomm2 X).
Qed.

Definition commringfracunel1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  setquot (eqrelcommringfrac X S) := setquotpr (eqrelcommringfrac X S) (commringfracunel1int X S).

Definition commringfracunel2 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  setquot (eqrelcommringfrac X S) := setquotpr (eqrelcommringfrac X S) (commringfracunel2int X S).

Lemma commringfracinv1comp (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  iscomprelrelfun (eqrelcommringfrac X S) (eqrelcommringfrac X S) (commringfracinv1int X S).
Proof.
  intros.
  set (assoc2 := ringassoc2 X). intros xs xs'. simpl.
  set (ff := @hinhfun). simpl in ff. apply ff. clear ff.
  intro tt0. exists (pr1 tt0).
  set (x := pr1 xs). set (s := pr1 (pr2 xs)).
  set (x' := pr1 xs'). set (s' := pr1 (pr2 xs')).
  set (a0 := pr1 (pr1 tt0)).
  change (-1 * x * s' * a0 = -1 * x' * s * a0).
  rewrite (assoc2 -1 x s'). rewrite (assoc2 -1 x' s).
  rewrite (assoc2 -1 (x * s') a0). rewrite (assoc2 -1 (x' * s) a0).
  apply (maponpaths (λ x0 : X, -1 * x0) (pr2 tt0)).
Defined.

Definition commringfracinv1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  setquot (eqrelcommringfrac X S) → setquot (eqrelcommringfrac X S) :=
  setquotfun (eqrelcommringfrac X S) (eqrelcommringfrac X S)
             (commringfracinv1int X S) (commringfracinv1comp X S).

Lemma commringfracisinv1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  isinv (commringfracop1 X S) (commringfracunel1 X S) (commringfracinv1 X S).
Proof.
  intros.
  assert (isl : islinv (commringfracop1 X S) (commringfracunel1 X S) (commringfracinv1 X S)).
  {
    set (R := eqrelcommringfrac X S).
    set (add1int := commringfracop1int X S).
    set (add1 := commringfracop1 X S).
    set (inv1 := commringfracinv1 X S).
    set (inv1int := commringfracinv1int X S).
    set (qunel1int := commringfracunel1int X S).
    set (qunel1 := commringfracunel1 X S).
    set (assoc2 := ringassoc2 X).
    unfold islinv.
    apply (setquotunivprop _ (λ x, _ = _)).
    intro xs.
    apply (iscompsetquotpr R  (add1int (inv1int xs) xs) qunel1int).
    simpl. apply hinhpr. exists (unel S).
    set (x := pr1 xs). set (s := pr1 (pr2 xs)).
    change ((s * (-1 * x) + s * x) * 1 * 1 = 0 * (s * s) * 1).
    induction (ringldistr X (-1 * x) x s).
    rewrite (ringmultwithminus1 X x). rewrite (ringlinvax1 X x).
    rewrite (ringmultx0 X s). rewrite (ringmult0x X 1).
    rewrite (ringmult0x X 1). rewrite (ringmult0x X (s * s)).
    exact (!ringmult0x X 1).
  }
  exact (isl ,, weqlinvrinv _ (commringfraccomm1 X S) _ (commringfracinv1 X S) isl).
Qed.

Lemma commringfraclunit1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  islunit (commringfracop1 X S) (commringfracunel1 X S).
Proof.
  intros.
  set (R := eqrelcommringfrac X S). set (add1int := commringfracop1int X S).
  set (add1 := commringfracop1 X S). set (un1 := commringfracunel1 X S).
  unfold islunit.
  apply (setquotunivprop R (λ x, _ = _)).
  intro xs.
  assert (e0 : add1int (commringfracunel1int X S) xs = xs).
  {
    unfold add1int. unfold commringfracop1int.
    induction xs as [ x s ]. induction s as [ s iss ].
    apply pathsdirprod.
    - simpl. change (s * 0 + 1 * x = x).
      rewrite (@ringmultx0 X s).
      rewrite (ringlunax2 X x).
      rewrite (ringlunax1 X x).
      apply idpath.
    - apply (invmaponpathsincl _ (isinclpr1carrier (pr1 S))).
      change (1 * s = s). apply (ringlunax2 X s).
  }
  apply (maponpaths (setquotpr R) e0).
Qed.

Lemma commringfracrunit1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  isrunit (commringfracop1 X S) (commringfracunel1 X S).
Proof.
  intros.
  apply (weqlunitrunit (commringfracop1 X S) (commringfraccomm1 X S)
                       (commringfracunel1 X S) (commringfraclunit1 X S)).
Qed.

Definition commringfracunit1 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  ismonoidop (commringfracop1 X S)
  := commringfracassoc1 X S ,,
    commringfracunel1 X S ,,
    commringfraclunit1 X S ,,
    commringfracrunit1 X S.

Definition commringfracop2 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  binop (setquotinset (eqrelcommringfrac X S)) := abmonoidfracop (ringmultabmonoid X) S.

Lemma commringfraccomm2 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  iscomm (commringfracop2 X S).
Proof.
  intros.
  apply (commax (abmonoidfrac (ringmultabmonoid X) S)).
Qed.

Lemma commringfracldistr (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  isldistr (commringfracop1 X S) (commringfracop2 X S).
Proof.
  intros.
  set (R := eqrelcommringfrac X S).
  set (mult1int := commringfracop2int X S).
  set (mult1 := commringfracop2 X S).
  set (add1int := commringfracop1int X S).
  set (add1 := commringfracop1 X S).
  unfold isldistr.
  apply (setquotuniv3prop _ (λ x x' x'', _ = _)).
  intros xs xs' xs''.
  apply (iscompsetquotpr R (mult1int xs'' (add1int xs xs'))
                         (add1int (mult1int xs'' xs) (mult1int xs'' xs'))).

  induction xs as [ x s ]. induction xs' as [ x' s' ].
  induction xs'' as [ x'' s'' ]. induction s'' as [ s'' iss'' ].
  simpl. apply hinhpr. exists (unel S).
  induction s as [ s iss ]. induction s' as [ s' iss' ]. simpl.

  change (((x'' * (s' * x + s * x')) * ((s'' * s) * (s'' * s'))) * 1
        = (((s'' * s') * (x'' * x) + (s'' * s) * (x'' * x')) * (s'' * (s * s'))) * 1).

  rewrite (ringldistr X (s' * x) (s * x') x'').
  rewrite (ringrdistr X _ _ ((s'' * s) * (s'' * s'))).
  rewrite (ringrdistr X _ _ (s'' * (s * s'))).
  set (assoc := ringassoc2 X). set (comm := ringcomm2 X).
  set (rer := @abmonoidoprer X (@op2 X) (commringop2axs X)).

  assert (e1 : (x'' * (s' * x)) * ((s'' * s) * (s'' * s'))
             = ((s'' * s') * (x'' * x)) * (s'' * (s * s'))).
  {
    induction (assoc x'' s' x). induction (comm s' x'').
    rewrite (assoc s' x'' x). induction (comm (x'' * x) s').
    induction (comm (x'' * x) (s'' * s')). induction (assoc s'' s s').
    induction (comm (s'' * s') (s'' * s)). induction (comm s' (s'' * s)).
    induction (rer (x'' * x) s' (s'' * s') (s'' * s)).
    apply idpath.
  }
  assert (e2 : (x'' * (s * x')) * ((s'' * s) * (s'' * s'))
             = ((s'' * s) * (x'' * x')) * (s'' * (s * s'))).
  {
    induction (assoc x'' s x'). induction (comm s x'').
    rewrite (assoc s x'' x'). induction (comm (x'' * x') s).
    induction (comm (x'' * x') (s'' * s)).
    induction (rer (x'' * x') (s'' * s) s (s'' * s')).
    induction (assoc s s'' s'). induction (assoc s'' s s').
    induction (comm s s'').
    apply idpath.
  }
  rewrite e1. rewrite e2. apply idpath.
Qed.

Lemma commringfracrdistr (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  isrdistr (commringfracop1 X S) (commringfracop2 X S).
Proof.
  intros.
  apply (weqldistrrdistr (commringfracop1 X S) (commringfracop2 X S)
                         (commringfraccomm2 X S) (commringfracldistr X S)).
Defined.

(** Notes :

1. Construction of the addition on the multiplicative monoid of fractions
   requires only commutativity and associativity of multiplication and (right)
   distributivity. No properties of the addition are used.

2. The proof of associtivity for the addition on the multiplicative monoid of
   fractions requires in the associativity of the original addition but no other
   properties.
*)

Definition commringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) : commring.
Proof.
  intros.
  set (R := eqrelcommringfrac  X S).
  set (mult1 := commringfracop2 X S).
  set (add1 := commringfracop1 X S).
  set (uset := setquotinset R).
  apply (commringconstr add1 mult1).
  - exists (commringfracunit1 X S).
    exists (commringfracinv1 X S).
    apply (commringfracisinv1 X S).
  - apply (commringfraccomm1 X S).
  - apply (pr2 (abmonoidfrac (ringmultabmonoid X) S)).
  - apply (commringfraccomm2 X S).
  - apply (commringfracldistr X S ,, commringfracrdistr X S).
Defined.

Definition prcommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  X → S → commringfrac X S := λ x s, setquotpr _ (x ,, s).

Lemma invertibilityincommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  ∏ a a' : S, isinvertible (@op2 (commringfrac X S)) (prcommringfrac X S (pr1 a) a').
Proof.
  intros.
  apply (invertibilityinabmonoidfrac (ringmultabmonoid X) S).
Defined.


(** **** Canonical homomorphism to the ring of fractions *)

Definition tocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) (x : X) :
  commringfrac X S := setquotpr _ (x ,, unel S).

Lemma isbinop1funtocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  @isbinopfun X (commringfrac X S) (tocommringfrac X S).
Proof.
  intros. unfold isbinopfun. intros x x'.
  change (setquotpr (eqrelcommringfrac X S) (x + x' ,, unel S)
        = setquotpr _ (commringfracop1int X S (x ,, unel S) (x' ,, unel S))).
  apply (maponpaths (setquotpr _)). unfold commringfracop1int.
  simpl. apply pathsdirprod.
  - rewrite (ringlunax2 X _). rewrite (ringlunax2 X _). apply idpath.
  - change (unel S = op (unel S) (unel S)).
    exact (!runax S _).
Qed.

Lemma isunital1funtocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  (tocommringfrac X S 0) = 0.
Proof.
  intros.
  apply idpath.
Qed.

Definition isaddmonoidfuntocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  @ismonoidfun X (commringfrac X S) (tocommringfrac X S) :=
  isbinop1funtocommringfrac X S ,, isunital1funtocommringfrac X S.

Definition tocommringfracandminus0 (X : commring) (S : @subabmonoid (ringmultabmonoid X)) (x : X) :
  tocommringfrac X S (- x) = - tocommringfrac X S x :=
  binopfun_preserves_inv _ (isbinop1funtocommringfrac X S) x.

Definition tocommringfracandminus (X : commring) (S : @subabmonoid (ringmultabmonoid X)) (x y : X) :
  tocommringfrac X S (x - y) = tocommringfrac X S x - tocommringfrac X S y.
Proof.
  intros.
  rewrite ((isbinop1funtocommringfrac X S x (- y)) :
             tocommringfrac X S (x - y)
           = tocommringfrac X S x + tocommringfrac X S (- y)).
  rewrite (tocommringfracandminus0 X S y).
  apply idpath.
Qed.

Definition isbinop2funtocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  @isbinopfun (ringmultmonoid X) (ringmultmonoid (commringfrac X S)) (tocommringfrac X S) :=
  isbinopfuntoabmonoidfrac (ringmultabmonoid X) S.

Lemma isunital2funtocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  (tocommringfrac X S 1) = 1.
Proof.
  intros.
  apply idpath.
Qed.

Definition ismultmonoidfuntocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  @ismonoidfun (ringmultmonoid X) (ringmultmonoid (commringfrac X S)) (tocommringfrac X S) :=
  isbinop2funtocommringfrac X S ,, isunital2funtocommringfrac X S.

Definition isringfuntocommringfrac (X : commring) (S : @subabmonoid (ringmultabmonoid X)) :
  @isringfun X (commringfrac X S) (tocommringfrac X S) :=
  isaddmonoidfuntocommringfrac X S ,, ismultmonoidfuntocommringfrac X S.


(** **** Ring of fractions in the case when all elements which are being inverted are cancelable *)

Definition hrelcommringfrac0 (X : commring) (S : @submonoid (ringmultabmonoid X)) :
  hrel (X × S) :=
  λ xa yb : setdirprod X S, (pr1 xa) * (pr1 (pr2 yb)) = (pr1 yb) * (pr1 (pr2 xa)).

Lemma weqhrelhrel0commringfrac (X : commring) (S : @submonoid (ringmultabmonoid X))
      (iscanc : ∏ a : S, isrcancelable (@op2 X) (pr1carrier _ a)) (xa xa' : X × S) :
  (eqrelcommringfrac X S xa xa') ≃ (hrelcommringfrac0 X S xa xa').
Proof.
  intros. unfold eqrelabmonoidfrac. unfold hrelabmonoidfrac. simpl.
  apply weqimplimpl.
  - apply (@hinhuniv _ (_ = _)).
    intro ae. induction ae as [ a eq ].
    apply (invmaponpathsincl _ (iscanc a) _ _ eq).
  - intro eq. apply hinhpr. exists (unel S).
    rewrite (ringrunax2 X). rewrite (ringrunax2 X).
    apply eq.
  - apply (isapropishinh _).
  - apply (setproperty X).
Qed.

Lemma isinclprcommringfrac (X : commring) (S : @submonoid (ringmultabmonoid X))
      (iscanc : ∏ a : S, isrcancelable (@op2 X) (pr1carrier _ a)) :
  ∏ a' : S, isincl (λ x, prcommringfrac X S x a').
Proof.
  intros. apply isinclbetweensets.
  apply (setproperty X). apply (setproperty (commringfrac X S)).
  intros x x'. intro e.
  set (e' := invweq (weqpathsinsetquot
                       (eqrelcommringfrac X S) (x ,, a') (x' ,, a')) e).
  set (e'' := weqhrelhrel0commringfrac
                X S iscanc (_ ,, _) (_ ,, _) e').
  simpl in e''. apply (invmaponpathsincl _ (iscanc a')). apply e''.
Defined.

Definition isincltocommringfrac (X : commring) (S : @submonoid (ringmultabmonoid X))
           (iscanc : ∏ a : S, isrcancelable (@op2 X) (pr1carrier _ a)) :
  isincl (tocommringfrac X S) := isinclprcommringfrac X S iscanc (unel S).

Lemma isdeceqcommringfrac (X : commring) (S : @submonoid (ringmultabmonoid X))
      (iscanc : ∏ a : S, isrcancelable (@op2 X) (pr1carrier _ a)) (is : isdeceq X) :
  isdeceq (commringfrac X S).
Proof.
  intros. apply (isdeceqsetquot (eqrelcommringfrac X S)). intros xa xa'.
  apply (isdecpropweqb (weqhrelhrel0commringfrac X S iscanc xa xa')).
  apply isdecpropif. unfold isaprop. simpl.
  set (int := setproperty X (pr1 xa * pr1 (pr2 xa')) (pr1 xa' * pr1 (pr2 xa))).
  simpl in int. apply int. unfold hrelcommringfrac0.
  simpl. apply (is _ _).
Defined.


(** **** Relations similar to "greater" or "greater or equal"  on the rings of fractions *)

Lemma ispartbinopcommringfracgt (X : commring) (S : @submonoid (ringmultabmonoid X)) {R : hrel X}
      (is0 : @isbinophrel (rigaddabmonoid X) R) (is1 : isringmultgt X R)
      (is2 : ∏ c : X, S c → R c 0) : @ispartbinophrel (ringmultabmonoid X) S R.
Proof.
  intros. split.
  - intros a b c s rab.
    apply (isringmultgttoislringmultgt X is0 is1 _ _ _ (is2 c s) rab).
  - intros a b c s rab.
    apply (isringmultgttoisrringmultgt X is0 is1 _ _ _ (is2 c s) rab).
Defined.

Definition commringfracgt (X : commring) (S : @submonoid (ringmultabmonoid X)) {R : hrel X}
           (is0 : @isbinophrel (rigaddabmonoid X) R) (is1 : isringmultgt X R)
           (is2 : ∏ c : X, S c → R c 0) : hrel (commringfrac X S) :=
  abmonoidfracrel (ringmultabmonoid X) S (ispartbinopcommringfracgt X S is0 is1 is2).

Lemma isringmultcommringfracgt (X : commring) (S : @submonoid (ringmultabmonoid X)) {R : hrel X}
      (is0 : @isbinophrel (rigaddabmonoid X) R) (is1 : isringmultgt X R)
      (is2 : ∏ c : X, S c → R c 0) : isringmultgt (commringfrac X S) (commringfracgt X S is0 is1 is2).
Proof.
  intros.
  set (rer2 := abmonoidrer (ringmultabmonoid X) :
                ∏ a b c d : X, (a * b) * (c * d) = (a * c) * (b * d)).
  apply islringmultgttoisringmultgt.
  assert (int : ∏ (a b c : ringaddabgr (commringfrac X S)),
                isaprop (commringfracgt X S is0 is1 is2 c 0 →
                         commringfracgt X S is0 is1 is2 a b →
                         commringfracgt X S is0 is1 is2 (c * a) (c * b))).
  {
    intros a b c.
    apply impred. intro.
    apply impred. intro.
    apply (pr2 _).
  }
  apply (setquotuniv3prop _ (λ a b c, make_hProp _ (int a b c))).
  intros xa1 xa2 xa3.
  change (abmonoidfracrelint (ringmultabmonoid X) S R xa3 (0 ,, unel S) →
          abmonoidfracrelint (ringmultabmonoid X) S R xa1 xa2 →
          abmonoidfracrelint (ringmultabmonoid X) S R
                             (commringfracop2int X S xa3 xa1)
                             (commringfracop2int X S xa3 xa2)).
  simpl. apply hinhfun2. intros t21 t22.
  set (c1s := pr1 t21). set (c1 := pr1 c1s). set (r1 := pr2 t21).
  set (c2s := pr1 t22). set (c2 := pr1 c2s). set (r2 := pr2 t22).
  set (x1 := pr1 xa1). set (a1 := pr1 (pr2 xa1)).
  set (x2 := pr1 xa2). set (a2 := pr1 (pr2 xa2)).
  set (x3 := pr1 xa3). set (a3 := pr1 (pr2 xa3)).
  exists (@op S c1s c2s).
  change (pr1 (R (x3 * x1 * (a3 * a2) * (c1 * c2))
                 (x3 * x2 * (a3 * a1) * (c1 * c2)))).
  rewrite (ringcomm2 X a3 a2).
  rewrite (ringcomm2 X a3 a1).
  rewrite (ringassoc2 X _ _ (c1 * c2)).
  rewrite (ringassoc2 X (x3 * x2) _ (c1 * c2)).
  rewrite (rer2 _ a3 c1 _).
  rewrite (rer2 _ a3 c1 _).
  rewrite (ringcomm2 X a2 c1).
  rewrite (ringcomm2 X a1 c1).
  rewrite <- (ringassoc2 X (x3 * x1) _ _).
  rewrite <- (ringassoc2 X (x3 * x2) _ _).
  rewrite (rer2 _ x1 c1 _). rewrite (rer2 _ x2 c1 _).
  rewrite (ringcomm2 X a3 c2).
  rewrite <- (ringassoc2 X _ c2 a3).
  rewrite <- (ringassoc2 X _ c2 _).
  apply ((isringmultgttoisrringmultgt X is0 is1) _ _ _ (is2 _ (pr2 (pr2 xa3)))).
  rewrite (ringassoc2 X _ _ c2). rewrite (ringassoc2 X _ (x2 * a1) c2).

  simpl in r1. clearbody r1. simpl in r2. clearbody r2.
  change (pr1 (R (x3 * 1 * c1) (0 * a3 * c1))) in r1.
  rewrite (ringrunax2 _ _) in r1. rewrite (ringmult0x X _) in r1.
  rewrite (ringmult0x X _) in r1.
  apply ((isringmultgttoislringmultgt X is0 is1) _ _ _ r1 r2).
Qed.

Lemma isringaddcommringfracgt (X : commring) (S : @submonoid (ringmultabmonoid X)) {R : hrel X}
      (is0 : @isbinophrel (rigaddabmonoid X) R) (is1 : isringmultgt X R)
      (is2 : ∏ c : X, S c → R c 0) : @isbinophrel (commringfrac X S) (commringfracgt X S is0 is1 is2).
Proof.
  intros.
  set (rer2 := (abmonoidrer (ringmultabmonoid X)) :
                 ∏ a b c d : X, (a * b) * (c * d) = (a * c) * (b * d)).
  apply isbinophrelif. intros a b. apply (ringcomm1 (commringfrac X S) a b).

  assert (int : ∏ (a b c : ringaddabgr (commringfrac X S)),
                isaprop (commringfracgt X S is0 is1 is2 a b →
                         commringfracgt X S is0 is1 is2 (op c a) (op c b))).
  {
    intros a b c.
    apply impred. intro.
    apply (pr2 _).
  }
  apply (setquotuniv3prop _ (λ a b c, make_hProp _ (int a b c))).
  intros xa1 xa2 xa3.
  change (abmonoidfracrelint (ringmultabmonoid X) S R xa1 xa2 →
          abmonoidfracrelint (ringmultabmonoid X) S R
                             (commringfracop1int X S xa3 xa1)
                             (commringfracop1int X S xa3 xa2)).
  simpl. apply hinhfun. intro t2.
  set (c0s := pr1 t2). set (c0 := pr1 c0s). set (r := pr2 t2).
  exists c0s.
  set (x1 := pr1 xa1). set (a1 := pr1 (pr2 xa1)).
  set (x2 := pr1 xa2). set (a2 := pr1 (pr2 xa2)).
  set (x3 := pr1 xa3). set (a3 := pr1 (pr2 xa3)).
  change (pr1 (R ((a1 * x3 + a3 * x1) * (a3 * a2) * c0)
                 ((a2 * x3 + a3 * x2) * (a3 * a1) * c0))).
  rewrite (ringassoc2 X _ _ c0). rewrite (ringassoc2 X _ (a3 * _) c0).
  rewrite (ringrdistr X _ _ _). rewrite (ringrdistr X _ _ _).
  rewrite (rer2 _ x3 _ _).  rewrite (rer2 _ x3 _ _).
  rewrite (ringcomm2 X a3 a2). rewrite (ringcomm2 X a3 a1).
  rewrite <- (ringassoc2 X a1 a2 a3).
  rewrite <- (ringassoc2 X a2 a1 a3).
  rewrite (ringcomm2 X a1 a2).  apply ((pr1 is0) _ _ _).
  rewrite (ringcomm2 X a2 a3). rewrite (ringcomm2 X  a1 a3).
  rewrite (ringassoc2 X a3 a2 c0). rewrite (ringassoc2 X a3 a1 c0).
  rewrite (rer2 _ x1 a3 _). rewrite (rer2 _ x2 a3 _).
  rewrite <- (ringassoc2 X x1 _ _).
  rewrite <- (ringassoc2 X x2 _ _).
  apply ((isringmultgttoislringmultgt X is0 is1)
           _ _ _ (is2 _ (pr2 (@op S (pr2 xa3) (pr2 xa3)))) r).
Qed.

Definition isdeccommringfracgt (X : commring) (S : @submonoid (ringmultabmonoid X)) {R : hrel X}
           (is0 : @isbinophrel (rigaddabmonoid X) R) (is1 : isringmultgt X R)
           (is2 : ∏ c : X, S c → R c 0) (is' : @ispartinvbinophrel (ringmultabmonoid X) S R)
           (isd : isdecrel R) : isdecrel (commringfracgt X S is0 is1 is2).
Proof.
  intros.
  apply (isdecabmonoidfracrel
           (ringmultabmonoid X) S (ispartbinopcommringfracgt X S is0 is1 is2) is' isd).
Defined.

Lemma StrongOrder_correct_commrngfrac (X : commring) (Y : @subabmonoid (ringmultabmonoid X))
      (gt : StrongOrder X)
      Hgt Hle Hmult Hpos :
  commringfracgt X Y (R := gt) Hle Hmult Hpos = StrongOrder_abmonoidfrac Y gt Hgt.
Proof.
  apply funextfun ; intros x.
  apply funextfun ; intros y.
  apply (maponpaths (λ H, abmonoidfracrel (ringmultabmonoid X) Y H x y)).
  apply isaprop_ispartbinophrel.
Defined.

(** **** Relations and the canonical homomorphism to the ring of fractions *)

Lemma iscomptocommringfrac (X : commring) (S : @submonoid (ringmultabmonoid X)) {L : hrel X}
           (is0 : @isbinophrel (rigaddabmonoid X) L) (is1 : isringmultgt X L)
           (is2 : ∏ c : X, S c → L c 0) :
  iscomprelrelfun L (commringfracgt X S is0 is1 is2) (tocommringfrac X S).
Proof.
  apply (iscomptoabmonoidfrac (ringmultabmonoid X)).
Qed.

Close Scope ring_scope.

(* End of the file *)
