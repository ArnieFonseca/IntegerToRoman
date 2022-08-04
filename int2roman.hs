
module Main where

    import RomanLib

    -- | Entry Point impure function
    main :: IO ()
    main =  do
    
        print $ map (\n -> (n,convertToRoman n )) [1,2,3,4,5,9,10,19,27,38,45,53,66,77,88,90]
