
{- Conversion table from Integer to Roman-}
mapping ::[(Int,String)]
mapping = [(1,"I"),(5,"V"),(10,"X"),(50,"L"),(100,"C"),(500,"D"),(1000,"M")]

{- x to the  power of y -}
pow::Int->Int->Int 
pow = (^) 

five::Int
five = 5

{- Extract the most left digit from the input number 
    e.g., 974 => 900 or 74 => 70 
    -}  
getProcessingNumber :: Int -> Int
getProcessingNumber n =   div n p * p
    where p  = pow 10 $ floor $ logBase 10 (fromIntegral  n)

getExactNumber::Int->[(Int,String)]
getExactNumber n = filter (\x -> fst x  == n)  mapping

{- Get the Upper Bound of the Processing number -}
getUpperBound::Int->(Int,String)
getUpperBound n  = head $ filter (\x -> fst x  >= n)  mapping

{- Get the Lower Bound of the Processing number -}
getLowerBound::Int->(Int,String)
getLowerBound n  = last $ filter (\x -> fst x  <= n)  mapping

{- Get the Lower Bound of the Lower Bound -}
getPrevLowerBound::Int->(Int,String)
getPrevLowerBound n  = last $ filter (\x -> fst x  < lmt)  mapping
    where lmt = if n <= five then five else n

{- Convert and Integer into a Roman  Number e.g.; 1 -> I, 4 -> IV, 10 -> X -}
getRomanNumber::Int->String
getRomanNumber processingNumber =
    nxtRst
    where 
      upperBound      = getUpperBound processingNumber
      lowerBound      = getLowerBound processingNumber
      prevLowerBound  = getPrevLowerBound $  fst lowerBound
      diff            = fst upperBound -  processingNumber
      diffLower       = div (processingNumber - fst lowerBound) (fst lowerBound) 
      diffPrevLower   = div (processingNumber - fst lowerBound) (fst prevLowerBound)
      toChar token       = snd token !! 0 
      nxtRst 
        -- Case 1 Exact Match
        | fst upperBound == fst lowerBound      = snd upperBound
        
        -- Case 2 When difference between the upper bound and processing number
        -- exists in conversion table case for 4, 9, 90, 400 ... IV, IX, XC, CD  
        | not $ null (getExactNumber diff)     = snd ( head $ getExactNumber diff )  ++ snd upperBound
   
        -- Case 3 When processing number is less than the difference between the upper bound and lower bound
        | processingNumber < fst upperBound - fst lowerBound = snd lowerBound ++ (replicate  diffLower $ toChar lowerBound)
        
        -- Case 4 When processing number is greater than the difference between the upper bound and lower bound
        | processingNumber > fst upperBound - fst lowerBound = snd lowerBound ++ (replicate  diffPrevLower $  toChar prevLowerBound)
        | otherwise = "Error"

{- Helper to convert to allow tail recurse calls -}
convertHelper::Int->String->String
convertHelper n rst = 
    if n == 0 
        then rst 
        else convertHelper (n - getProcessingNumber n) (rst ++ getRomanNumber (getProcessingNumber n))

{- Convert an Integer to a Roman Number &&-}        
convertToRoman::Int->String
convertToRoman n = convertHelper n ""

{- Entry Point impure function -}
main :: IO ()
main =  do
 
    print $ map (\n -> (n,convertToRoman n )) [1,2,3,4,5,9,10,19,27,38,45,53,66,77,88,90]

