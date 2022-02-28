from math import pow, floor,log10
from typing import Tuple, Callable, List, Final

mappingTable:List[Tuple[int,str]] = [(1,"I"), (5,"V"), (10,"X"), (50,"L"),
                                  (100,"C"), (500, "D"), (1000,"M"),(5000,"V\u0305"),
                                  (10000,"X\u0305"),(50000,"L\u0305"),
                                  (100000,"C\u0305"), (500000,"D\u0305"),
                                  (1000000,"M\u0305")]

ZERO:Final = 0

# Inline functions to capture boundaries
getUpperBound:Callable[[int],Tuple[int,str]] = \
    lambda x: min(filter(lambda n: n[ZERO] >= x, mappingTable))
getLowerBound:Callable[[int],Tuple[int,str]] = \
    lambda x: max(filter(lambda n: n[ZERO] <= x, mappingTable))
getPrevLowerBound:Callable[[int],Tuple[int,str]] = \
    lambda x: max(filter(lambda n: n[ZERO] < x, mappingTable))
getExtractRomanNumber:Callable[[int],List[Tuple[int,str]]] = \
    lambda x: list(filter(lambda n: n[ZERO] == x, mappingTable))

def getProcessingNumber(num:int)->int:
    """Extract the most left digit from the input number 
    e.g., 974 => 900 or 74 => 70"""
    n:int = num // int(pow(10,floor(log10(num))))
    p:int = floor(log10(num))
    return int(pow(10,p) * n)

def getRomanNumber(processingNumber:int)->str:
    """Convert to Roman Number"""

    # Local Identifiers
    INTEGER:Final  = 0
    ROMAN:Final = 1
    FIVE:Final = 5
    THOUSAND:Final = 1000
    ROMAN_THOUSAND:Final = "I\u0305"

    # Get the minimin and maximum boundaries
    lowerBound:Tuple[int,str] = getLowerBound(processingNumber)
    upperBound:Tuple[int,str] = getUpperBound(processingNumber)

    # Calculate the diference between the processing number and upper boundary
    diff:int = upperBound[INTEGER] - processingNumber

    # Check that diff is in the conversion table
    diffRomanNumber:List[Tuple[int,str]] = getExtractRomanNumber(diff)

    # Adjusting for the base number when Lower Bound equals 5
    prevLowerBound:Tuple[int,str] = lowerBound if upperBound[INTEGER] <= FIVE \
        else getPrevLowerBound(lowerBound[INTEGER])

    # When number matches the lower bound then done
    # Case ! Extract Match
    if processingNumber == lowerBound[INTEGER]:
        return lowerBound[ROMAN]

    # The difference is in the conversion table
    # Case 2 subtrasction pattern
    elif diffRomanNumber != []: 
        # To resolve Roamn subtract notation e.g.; -> 4,9,40,90,400,900 ...
        # Account for Exception in the thousands
        return (ROMAN_THOUSAND if diff == THOUSAND \
            else diffRomanNumber[ZERO][ROMAN]) + upperBound[ROMAN]

    #Case  3 When processing number is less that the difference between the upper bound and lower bound
    elif   processingNumber <  upperBound[INTEGER] - lowerBound[INTEGER]:
        return lowerBound[ROMAN] + \
            ( lowerBound[ROMAN] * \
                ((processingNumber - lowerBound[INTEGER]) // lowerBound[INTEGER]))
 
    #Case 4 When processing number is greater that the difference between the upper bound and lower bound
    elif   processingNumber >  upperBound[INTEGER] - lowerBound[INTEGER]:
        return lowerBound[ROMAN] + \
            ( prevLowerBound[ROMAN] * \
                ((processingNumber - lowerBound[INTEGER]) // prevLowerBound[INTEGER]))

def integerToRoman(num:int)->str:
    """Convert an Integer into a Roman Number"""

    def integerToRomanHelper(num:int, rst:str)->str:
        """Inner function to facilitate recurse calls"""
        if num == ZERO:
            return rst

        return integerToRomanHelper(num - getProcessingNumber(num), \
            rst + getRomanNumber(getProcessingNumber(num)))

    return integerToRomanHelper(num,"")

# Entry Point Impure Function
if __name__ == "__main__":
    for n in [1,4,5,9,10,27, 38, 66, 77, 88]:
        (print)(n,integerToRoman(n))
