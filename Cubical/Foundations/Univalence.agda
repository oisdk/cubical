{-

Proof of the standard formulation of the univalence theorem and
various consequences of univalence

- Re-exports Glue types from Cubical.Core.Glue
- The ua constant and its computation rule (up to a path)
- Proof of univalence using that unglue is an equivalence ([EquivContr])
- Equivalence induction ([EquivJ], [elimEquiv])
- Univalence theorem ([univalence])
- The computation rule for ua ([uaβ])
- Isomorphism induction ([elimIso])

-}
{-# OPTIONS --cubical --safe #-}
module Cubical.Foundations.Univalence where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Function
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.GroupoidLaws

open import Cubical.Core.Glue public
  using ( Glue ; glue ; unglue ; lineToEquiv )

private
  variable
    ℓ ℓ' : Level

-- The ua constant
ua : ∀ {A B : Type ℓ} → A ≃ B → A ≡ B
ua {A = A} {B = B} e i = Glue B (λ { (i = i0) → (A , e)
                                   ; (i = i1) → (B , idEquiv B) })

uaIdEquiv : {A : Type ℓ} → ua (idEquiv A) ≡ refl
uaIdEquiv {A = A} i j = Glue A {φ = i ∨ ~ j ∨ j} (λ _ → A , idEquiv A)

-- Give detailed type to unglue, mainly for documentation purposes
ua-unglue : ∀ {A B : Type ℓ} → (e : A ≃ B) → (i : I) (x : ua e i)
            → B [ _ ↦ (λ { (i = i0) → e .fst x ; (i = i1) → x }) ]
ua-unglue e i x = inS (unglue (i ∨ ~ i) x)

-- Give detailed type to glue
ua-glue : ∀ {A B : Type ℓ} (e : A ≃ B) (i : I) (x : A) (y : B)
          → B [ _ ↦ (λ { (i = i0) → e .fst x ; (i = i1) → y }) ]
          → (ua e i) [ _ ↦ (λ { (i = i0) → x ; (i = i1) → y }) ]
ua-glue e i x y s = inS (glue (λ { (i = i0) → x ; (i = i1) → y }) (outS s))

ua-gluePath : ∀ {A B : Type ℓ} (e : A ≃ B) {x : A} {y : B}
              → e .fst x ≡ y
              → PathP (λ i → ua e i) x y
ua-gluePath e {x} {y} p i = glue (λ { (i = i0) → x ; (i = i1) → y }) (p i)

-- Proof of univalence using that unglue is an equivalence:

-- unglue is an equivalence
unglueIsEquiv : ∀ (A : Type ℓ) (φ : I)
                (f : PartialP φ (λ o → Σ[ T ∈ Type ℓ ] T ≃ A)) →
                isEquiv {A = Glue A f} (unglue φ)
equiv-proof (unglueIsEquiv A φ f) = λ (b : A) →
  let u : I → Partial φ A
      u i = λ{ (φ = i1) → equivCtr (f 1=1 .snd) b .snd (~ i) }
      ctr : fiber (unglue φ) b
      ctr = ( glue (λ { (φ = i1) → equivCtr (f 1=1 .snd) b .fst }) (hcomp u b)
            , λ j → hfill u (inS b) (~ j))
  in ( ctr
     , λ (v : fiber (unglue φ) b) i →
         let u' : I → Partial (φ ∨ ~ i ∨ i) A
             u' j = λ { (φ = i1) → equivCtrPath (f 1=1 .snd) b v i .snd (~ j)
                      ; (i = i0) → hfill u (inS b) j
                      ; (i = i1) → v .snd (~ j) }
         in ( glue (λ { (φ = i1) → equivCtrPath (f 1=1 .snd) b v i .fst }) (hcomp u' b)
            , λ j → hfill u' (inS b) (~ j)))

-- Any partial family of equivalences can be extended to a total one
-- from Glue [ φ ↦ (T,f) ] A to A
unglueEquiv : ∀ (A : Type ℓ) (φ : I)
              (f : PartialP φ (λ o → Σ[ T ∈ Type ℓ ] T ≃ A)) →
              (Glue A f) ≃ A
unglueEquiv A φ f = ( unglue φ , unglueIsEquiv A φ f )


-- The following is a formulation of univalence proposed by Martín Escardó:
-- https://groups.google.com/forum/#!msg/homotopytypetheory/HfCB_b-PNEU/Ibb48LvUMeUJ
-- See also Theorem 5.8.4 of the HoTT Book.
--
-- The reason we have this formulation in the core library and not the
-- standard one is that this one is more direct to prove using that
-- unglue is an equivalence. The standard formulation can be found in
-- Cubical/Basics/Univalence.
--
EquivContr : ∀ (A : Type ℓ) → isContr (Σ[ T ∈ Type ℓ ] T ≃ A)
EquivContr {ℓ = ℓ} A =
  ( (A , idEquiv A)
  , idEquiv≡ )
 where
  idEquiv≡ : (y : Σ (Type ℓ) (λ T → T ≃ A)) → (A , idEquiv A) ≡ y
  idEquiv≡ w = \ { i .fst                   → Glue A (f i)
                 ; i .snd .fst              → unglueEquiv _ _ (f i) .fst
                 ; i .snd .snd .equiv-proof → unglueEquiv _ _ (f i) .snd .equiv-proof
                 }
    where
      f : ∀ i → PartialP (~ i ∨ i) (λ x → Σ[ T ∈ Type ℓ ] T ≃ A)
      f i = λ { (i = i0) → A , idEquiv A ; (i = i1) → w }

contrSinglEquiv : {A B : Type ℓ} (e : A ≃ B) → (B , idEquiv B) ≡ (A , e)
contrSinglEquiv {A = A} {B = B} e =
  isContr→isProp (EquivContr B) (B , idEquiv B) (A , e)

-- Equivalence induction
EquivJ : (P : (A B : Type ℓ) → (e : B ≃ A) → Type ℓ')
       → (r : (A : Type ℓ) → P A A (idEquiv A))
       → (A B : Type ℓ) → (e : B ≃ A) → P A B e
EquivJ P r A B e = subst (λ x → P A (x .fst) (x .snd)) (contrSinglEquiv e) (r A)

-- Eliminate equivalences by just looking at the underlying function
elimEquivFun : (B : Type ℓ) (P : (A : Type ℓ) → (A → B) → Type ℓ')
             → (r : P B (λ x → x))
             → (A : Type ℓ) → (e : A ≃ B) → P A (e .fst)
elimEquivFun B P r a e = subst (λ x → P (x .fst) (x .snd .fst)) (contrSinglEquiv e) r

-- Assuming that we have an inverse to ua we can easily prove univalence
module Univalence (au : ∀ {ℓ} {A B : Type ℓ} → A ≡ B → A ≃ B)
                  (aurefl : ∀ {ℓ} {A B : Type ℓ} → au refl ≡ idEquiv A) where

  ua-au : {A B : Type ℓ} (p : A ≡ B) → ua (au p) ≡ p
  ua-au {B = B} p = J (λ b p → ua (au p) ≡ p) (cong ua (aurefl {B = B}) ∙ uaIdEquiv) p

  au-ua : {A B : Type ℓ} (e : A ≃ B) → au (ua e) ≡ e
  au-ua {B = B} e = EquivJ (λ b a f → au (ua f) ≡ f)
                       (λ x → subst (λ r → au r ≡ idEquiv x) (sym uaIdEquiv) (aurefl {B = B}))
                        _ _ e

  thm : ∀ {ℓ} {A B : Type ℓ} → isEquiv au
  thm {A = A} {B = B} = isoToIsEquiv {B = A ≃ B} (iso au ua au-ua ua-au)

pathToEquiv : {A B : Type ℓ} → A ≡ B → A ≃ B
pathToEquiv p = lineToEquiv (λ i → p i)

pathToEquivRefl : {A : Type ℓ} → pathToEquiv refl ≡ idEquiv A
pathToEquivRefl {A = A} = equivEq _ _ (λ i x → transp (λ _ → A) i x)

pathToEquiv-ua : {A B : Type ℓ} (e : A ≃ B) → pathToEquiv (ua e) ≡ e
pathToEquiv-ua = Univalence.au-ua pathToEquiv pathToEquivRefl

ua-pathToEquiv : {A B : Type ℓ} (p : A ≡ B) → ua (pathToEquiv p) ≡ p
ua-pathToEquiv = Univalence.ua-au pathToEquiv pathToEquivRefl

-- Univalence
univalence : {A B : Type ℓ} → (A ≡ B) ≃ (A ≃ B)
univalence = ( pathToEquiv , Univalence.thm pathToEquiv pathToEquivRefl  )

-- The original map from UniMath/Foundations
eqweqmap : {A B : Type ℓ} → A ≡ B → A ≃ B
eqweqmap {A = A} e = J (λ X _ → A ≃ X) (idEquiv A) e

eqweqmapid : {A : Type ℓ} → eqweqmap refl ≡ idEquiv A
eqweqmapid {A = A} = JRefl (λ X _ → A ≃ X) (idEquiv A)

univalenceStatement : {A B : Type ℓ} → isEquiv (eqweqmap {ℓ} {A} {B})
univalenceStatement = Univalence.thm eqweqmap eqweqmapid

univalenceUAH : {A B : Type ℓ} → (A ≡ B) ≃ (A ≃ B)
univalenceUAH = ( _ , univalenceStatement )

univalencePath : {A B : Type ℓ} → (A ≡ B) ≡ Lift (A ≃ B)
univalencePath = ua (compEquiv univalence LiftEquiv)

-- The computation rule for ua. Because of "ghcomp" it is now very
-- simple compared to cubicaltt:
-- https://github.com/mortberg/cubicaltt/blob/master/examples/univalence.ctt#L202
uaβ : {A B : Type ℓ} (e : A ≃ B) (x : A) → transport (ua e) x ≡ e .fst x
uaβ e x = transportRefl (e .fst x)

uaη : ∀ {A B : Type ℓ} → (P : A ≡ B) → ua (pathToEquiv P) ≡ P
uaη = J (λ _ q → ua (pathToEquiv q) ≡ q) (cong ua pathToEquivRefl ∙ uaIdEquiv)

-- Alternative version of EquivJ that only requires a predicate on
-- functions
elimEquiv : {B : Type ℓ} (P : {A : Type ℓ} → (A → B) → Type ℓ') →
            (d : P (idfun B)) → {A : Type ℓ} → (e : A ≃ B) → P (e .fst)
elimEquiv P d e = subst (λ x → P (x .snd .fst)) (contrSinglEquiv e) d

-- Isomorphism induction
elimIso : {B : Type ℓ} → (Q : {A : Type ℓ} → (A → B) → (B → A) → Type ℓ') →
          (h : Q (idfun B) (idfun B)) → {A : Type ℓ} →
          (f : A → B) → (g : B → A) → section f g → retract f g → Q f g
elimIso {ℓ} {ℓ'} {B} Q h {A} f g sfg rfg = rem1 f g sfg rfg
  where
  P : {A : Type ℓ} → (f : A → B) → Type (ℓ-max ℓ' ℓ)
  P {A} f = (g : B → A) → section f g → retract f g → Q f g

  rem : P (idfun B)
  rem g sfg rfg = subst (Q (idfun B)) (λ i b → (sfg b) (~ i)) h

  rem1 : {A : Type ℓ} → (f : A → B) → P f
  rem1 f g sfg rfg = elimEquiv P rem (f , isoToIsEquiv (iso f g sfg rfg)) g sfg rfg


uaInvEquiv : ∀ {A B : Type ℓ} → (e : A ≃ B) → ua (invEquiv e) ≡ sym (ua e)
uaInvEquiv e = EquivJ (λ _ _ e → ua (invEquiv e) ≡ sym (ua e)) rem _ _ e
  where
  rem : (A : Type ℓ) → ua (invEquiv (idEquiv A)) ≡ sym (ua (idEquiv A))
  rem A = cong ua (invEquivIdEquiv A)

uaCompEquiv : ∀ {A B C : Type ℓ} → (e : A ≃ B) (f : B ≃ C) → ua (compEquiv e f) ≡ ua e ∙ ua f
uaCompEquiv {C = C} = EquivJ (λ A B e → (f : A ≃ C) → ua (compEquiv e f) ≡ ua e ∙ ua f) rem _ _
  where
  rem : (A : Type _) (f : A ≃ C) → ua (compEquiv (idEquiv A) f) ≡ ua (idEquiv A) ∙ ua f
  rem _ f = cong ua (compEquivIdEquiv f) ∙ sym (cong (λ x → x ∙ ua f) uaIdEquiv ∙ sym (lUnit (ua f)))
