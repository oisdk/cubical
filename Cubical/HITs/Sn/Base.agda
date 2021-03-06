{-# OPTIONS --cubical --safe #-}
module Cubical.HITs.Sn.Base where

open import Cubical.HITs.Susp
open import Cubical.Data.Nat
open import Cubical.Data.NatMinusOne
open import Cubical.Data.Empty
open import Cubical.Foundations.Prelude

S₊ : ℕ₋₁ → Type₀
S₊ neg1 = ⊥
S₊ (suc n) = Susp (S₊ n)

S : ℕ → Type₀
S n = S₊ (ℕ→ℕ₋₁ n)
