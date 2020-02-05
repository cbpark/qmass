module Main where

import HEP.Data.AlphaS (AlphaS, alphasQ, mkAlphaS)

import Control.Monad   (zipWithM)

main :: IO ()
main = do
    let mt = poleMass Top
        mb = poleMass Bottom
        mc = poleMass Charm
        mZ = 91.188
        aMZ = 0.118

    as <- mkAlphaS mt mZ aMZ

    putStrLn "\n-- alpha_s:"
    let printAlphaS q = alphasQ as q >>= print
    mapM_ printAlphaS [mt, mZ, mb, mc]

    putStrLn "\n-- mq(mq):"
    mapM (mMSbarQ as) [Top, Bottom, Charm] >>= mapM_ (print . fst)

    putStrLn "\n-- mq(500 GeV):"
    mapM (mMSbarMu as 500) [Top, Bottom, Charm] >>= mapM_ print

    putStrLn "\n-- mq(1000 GeV):"
    mapM (mMSbarMu as 1000) [Top, Bottom, Charm] >>= mapM_ print

data MassiveQuark = Top | Bottom | Charm deriving Eq

poleMass :: MassiveQuark -> Double
poleMass q | q == Top   = 173.0
           | q == Bottom =   4.78
           | q == Charm  =   1.67
           | otherwise   =   0.0

nLight :: MassiveQuark -> Double
nLight q | q == Top    = 5
         | q == Bottom = 4
         | q == Charm  = 3
         | otherwise   = 0

-- | the running mass at quark pole mass.
mMSbarQ :: AlphaS
        -> MassiveQuark
        -> IO (Double, Double)  -- ^ (MSbar mass, pole mass)
mMSbarQ as q = do
    let mQ = poleMass q
        nf = nLight q

    x <- (/pi) <$> alphasQ as mQ

    let c = 1 - 4 * x / 3
            + (1.0414 * nf - 13.4434) * x ** 2
            - (0.6527 * nf * nf - 26.655 * nf + 190.595) * x ** 3
    return (mQ * c, mQ)

-- | the running mass at the given scale.
mMSbarMu :: AlphaS -> Double -> MassiveQuark -> IO Double
mMSbarMu as scale q = do
    (mqMS, mqPole) <- mMSbarQ as q

    [a0, a1] <- mapM (alphasQ as) [mqPole, scale]
    -- [c0, c1] <- mapM (uncurry cAlphaRG) (zip [a0, a1] [mqPole, scale])
    cs <- zipWithM cAlphaRG [a0, a1] [mqPole, scale]

    return $ case cs of
                 [Just c0, Just c1] -> mqMS * c1 / c0
                 _                  -> 0

cAlphaRG :: Double -> Double -> IO (Maybe Double)
cAlphaRG aSmu scale
    | scale < mc = return Nothing
    | otherwise  = do
          let (a0, c0, b0, b1, b2, b3)
                  | scale < mb =
                        (25.0/6, 12.0/25, 1, 1.01413,  1.38921,  1.09054 )
                  | scale < mt =
                        (23.0/6, 12.0/23, 1, 1.17549,  1.50071,  0.172478)
                  | otherwise  =
                        ( 7.0/2,  4.0/ 7, 1, 1.139796, 1.79348, -0.683433)
          return . Just $ (a0 * x) ** c0
                          * (b0 + b1 * x + b2 * x ** 2 + b3 * x ** 3)
    where
      mc = poleMass Charm
      mb = poleMass Bottom
      mt = poleMass Top
      x = aSmu / pi
