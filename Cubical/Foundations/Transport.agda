{- Basic theory about transport:

- transport is invertible
- transport is an equivalence ([transportEquiv])

-}
{-# OPTIONS --cubical --safe #-}
module Cubical.Foundations.Transport where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.Isomorphism

-- Direct definition of transport filler, note that we have to
-- explicitly tell Agda that the type is constant (like in CHM)
transpFill : ∀ {ℓ} {A : Type ℓ}
             (φ : I)
             (A : (i : I) → Type ℓ [ φ ↦ (λ _ → A) ])
             (u0 : outS (A i0))
           → --------------------------------------
             PathP (λ i → outS (A i)) u0 (transp (λ i → outS (A i)) φ u0)
transpFill φ A u0 i = transp (λ j → outS (A (i ∧ j))) (~ i ∨ φ) u0

transport⁻ : ∀ {ℓ} {A B : Type ℓ} → A ≡ B → B → A
transport⁻ p = transport (λ i → p (~ i))

transport⁻Transport : ∀ {ℓ} {A B : Type ℓ} → (p : A ≡ B) → (a : A) →
                          transport⁻ p (transport p a) ≡ a
transport⁻Transport p a j =
  transp (λ i → p (~ i ∧ ~ j)) j (transp (λ i → p (i ∧ ~ j)) j a)

transportTransport⁻ : ∀ {ℓ} {A B : Type ℓ} → (p : A ≡ B) → (b : B) →
                        transport p (transport⁻ p b) ≡ b
transportTransport⁻ p b j =
  transp (λ i → p (i ∨ j)) j (transp (λ i → p (~ i ∨ j)) j b)

-- Transport is an equivalence
isEquivTransport : ∀ {ℓ} {A B : Type ℓ} (p : A ≡ B) → isEquiv (transport p)
isEquivTransport {A = A} {B = B} p =
  transport (λ i → isEquiv (λ x → transp (λ j → p (i ∧ j)) (~ i) x)) (idIsEquiv A)

transportEquiv : ∀ {ℓ} {A B : Type ℓ} → A ≡ B → A ≃ B
transportEquiv p = (transport p , isEquivTransport p)

pathToIso : ∀ {ℓ} {A B : Type ℓ} → A ≡ B → Iso A B
pathToIso x = iso (transport x) (transport⁻ x ) ( transportTransport⁻ x) (transport⁻Transport x)

isSet-subst : ∀ {ℓ ℓ′} {A : Type ℓ} {B : A → Type ℓ′}
                → (isSet-A : isSet A)
                → ∀ {a : A}
                → (p : a ≡ a) → (x : B a) → subst B p x ≡ x
isSet-subst {B = B} isSet-A p x = subst (λ p′ → subst B p′ x ≡ x) (isSet-A _ _ refl p) (substRefl {B = B} x)

-- substituting along a composite path is equivalent to substituting twice
substComposite-□ : ∀ {ℓ ℓ′} {A : Type ℓ} → (B : A → Type ℓ′)
                     → {x y z : A} (p : x ≡ y) (q : y ≡ z) (u : B x)
                     → subst B (p □ q) u ≡ subst B q (subst B p u)
substComposite-□ B p q Bx = sym (substRefl {B = B} _) ∙ helper where
  compSq : I → I → _
  compSq = compPath'-filler p q
  helper : subst B refl (subst B (p □ q) Bx) ≡ subst B q (subst B p Bx)
  helper i = subst B (λ k → compSq (~ i ∧ ~ k) (~ i ∨ k)) (subst B (λ k → compSq (~ i ∨ ~ k) (~ i ∧ k)) Bx)

-- substitution commutes with morphisms in slices
substCommSlice : ∀ {ℓ ℓ′} {A : Type ℓ}
                   → (B C : A → Type ℓ′)
                   → (F : ∀ i → B i → C i)
                   → {x y : A} (p : x ≡ y) (u : B x)
                   → subst C p (F x u) ≡ F y (subst B p u)
substCommSlice B C F p Bx i = comp pathC (λ k → λ where
      (i = i0) → toPathP {A = pathC} (λ _ → subst C p (F _ Bx)) k
      (i = i1) → F (p k) (toPathP {A = pathB} (λ _ → subst B p Bx) k)
    ) (F _ Bx) where
  pathC : I → Type _
  pathC i = cong C p i
  pathB : I → Type _
  pathB i = cong B p i
