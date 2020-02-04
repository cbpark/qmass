module Main where

import HEP.Data.AlphaS (alphasQ, mkAlphaS)

main :: IO ()
main = do
    let mt = 173.0
        mZ = 91.188
        aMZ = 0.118

    as <- mkAlphaS mt mZ aMZ

    let printAlphaS q = alphasQ as q >>= print
    mapM_ printAlphaS [4.18, mZ, mt]
