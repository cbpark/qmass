{-# LANGUAGE CPP #-}

module HEP.Data.AlphaS (mkAlphaS, alphasQ) where

import Foreign.C.Types       (CDouble (..))
import Foreign.ForeignPtr    (ForeignPtr, newForeignPtr, withForeignPtr)
import Foreign.Marshal.Alloc (finalizerFree)
import Foreign.Ptr           (Ptr)

#include "alphas.h"

newtype CAlphaS = CAlphaS (Ptr CAlphaS)
newtype AlphaS = AlphaS (ForeignPtr CAlphaS)

foreign import ccall "mkAlphaS" c_mkAlphaS ::
    CDouble -> CDouble -> CDouble -> IO CAlphaS

mkAlphaS :: Double -> Double -> Double -> IO AlphaS
mkAlphaS mt mz alpha = do
    CAlphaS cas <- c_mkAlphaS (realToFrac mt) (realToFrac mz) (realToFrac alpha)
    as <- newForeignPtr finalizerFree cas
    return (AlphaS as)

foreign import ccall "alphasQ" c_alphasQ :: CAlphaS -> CDouble -> IO CDouble

alphasQ :: AlphaS -> Double -> IO Double
alphasQ (AlphaS as) q =
    withForeignPtr as (\a -> realToFrac <$> c_alphasQ (CAlphaS a) (realToFrac q))
