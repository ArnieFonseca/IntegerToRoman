module RomanLib
    (convertToRoman) where
    
data Pair = Pair {integer::Int, roman :: String}  deriving (Show, Eq)
type Pairs = [Pair]

 
{- Mapping Table -} 
mapping ::Pairs
mapping = [Pair 1 "I", Pair 5 "V", Pair 10 "X", Pair 50 "L" , Pair 100 "C", Pair 500 "D", Pair 1000 "M"]

-- | x to the  power of y 
pow::Int->Int->Int 
pow = (^) 

-- | Lower Bound Constant
five::Int
five = 5


-- | Extract the most left digit from the input number 
--    e.g., 974 => 900 or 74 => 70       
getProcessingNumber :: Int -> Int
getProcessingNumber n =   div n p * p
    where p  = pow 10  b  
          b = floor  logRst
          logRst =  logBase 10 (fromIntegral  n)::Double


-- | Get Extract number from Mapping Table
-- The processing number exist in the Mapping table
getExactNumber::Int->Pairs
getExactNumber n = filter (\x -> integer x  == n)  mapping

-- | Get the Upper Bound of the Processing number
getUpperBound::Int->Pair
getUpperBound n  = head $ filter (\x -> integer x  >= n)  mapping

-- | Get the Lower Bound of the Processing number 
getLowerBound::Int->Pair
getLowerBound n  = last $ filter (\x -> integer x  <= n)  mapping

-- | Get the Lower Bound of the Lower Bound
getPrevLowerBound::Int->Pair
getPrevLowerBound n  = last $ filter (\x -> integer x  < lmt)  mapping
    where lmt = if n <= five then five else n

-- | Convert and Integer into a Roman  Number e.g.; 1 -> I, 4 -> IV, 10 -> X
getRomanNumber::Int->String
getRomanNumber processingNumber =
    nxtRst
    where 
      upperBound      = getUpperBound processingNumber
      lowerBound      = getLowerBound processingNumber
      prevLowerBound  = getPrevLowerBound $  integer lowerBound
      diff            = integer upperBound -  processingNumber
      diffLower       = div (processingNumber - integer lowerBound) (integer lowerBound) 
      diffPrevLower   = div (processingNumber - integer lowerBound) (integer prevLowerBound)
      toChar token    = head $ roman token 
      nxtRst 
        -- Case 1 Exact Match
        | integer upperBound == integer lowerBound      = roman upperBound
        
        -- Case 2 When difference between the upper bound and processing number
        -- exists in conversion table case for 4, 9, 90, 400 ... IV, IX, XC, CD  
        | not $ null (getExactNumber diff)     = roman ( head $ getExactNumber diff )  ++ roman upperBound
   
        -- Case 3 When processing number is less than the difference between the upper bound and lower bound
        | processingNumber < integer upperBound - integer lowerBound = roman lowerBound ++ replicate diffLower (toChar lowerBound)
        
        -- Case 4 When processing number is greater than the difference between the upper bound and lower bound
        | processingNumber > integer upperBound - integer lowerBound = roman lowerBound ++ replicate diffPrevLower (toChar prevLowerBound)
        | otherwise = "Error"

-- | Helper to convert to Integer to a Roman Number using tail recurse calls
convertHelper::Int->String->String
convertHelper n rst 
    | n == 0 = rst
    | otherwise = convertHelper (n - getProcessingNumber n) (rst ++ getRomanNumber (getProcessingNumber n))


-- | Convert an Integer to a Roman Number
convertToRoman::Int->String
convertToRoman n = convertHelper n ""