""" Convert Integer to its Roman Number Representation e.g.; 123 CXXIII"""
from functools import partial, reduce
from math import floor, log10
from types import FunctionType

from typing import List, Final, Callable, Optional, Iterator, NewType, Any, Tuple
from collections import namedtuple

### Constants
ZERO:Final[int] = 0
ONE:Final[int] = 1
FIVE:Final[int] = 5
EMPTY_STR:Final[str] = ""

### Named Collection
Pair = namedtuple('Pair', ['number', 'roman'])

### New Type
CallableFunction = NewType('CallableFunction', FunctionType)

### Logic Combinators

### λfgx.f(gx) ⇒ (f∘g)x
bluebird:Callable[[List[CallableFunction]], Callable[[Any],Any]]  = \
    lambda fns: lambda x: reduce(lambda fn1, fn2: fn2(fn1),fns,x)

### λfgx.fx(gx)
starling:Callable[[CallableFunction], Callable[[CallableFunction],Callable[[int],int]]]  = \
    lambda f: lambda g: lambda x: int(f(x)(g(x)))

### Curry multiply and division
multiply:Callable[[int],Callable[[int],int]] = lambda x:lambda y: x * y
division:Callable[[int],Callable[[int],int]] = lambda x:lambda y: x // y

### head and tail function for List
getHead:Callable[[List[int]],int] = lambda lst: lst[ZERO]
getTail:Callable[[List[int]],List[int]] =  lambda lst: lst[ONE:]

### {f1,f2, … fn} list of function to implement a pipe
fnList:List[CallableFunction] =[log10, floor, partial(pow, 10), int]

### Cross Reference Table
MAPPING_TABLE:Final[List[Pair]] = [Pair(1,"I"), Pair(5,"V"),
                                Pair(10,"X"), Pair(50,"L"),
                                Pair(100,"C"), Pair(500, "D"),
                                Pair(1000,"M"),Pair(5000,"V\u0305"),
                                Pair(10000,"X\u0305"),Pair(50000,"L\u0305"),
                                Pair(100000,"C\u0305"), Pair(500000,"D\u0305"),
                                Pair(1000000,"M\u0305")]

### Auxiliary function
getUpperBound:Callable[[int],Pair] =  \
    lambda processingNumber: min(filter(lambda pair: pair.number >= processingNumber, MAPPING_TABLE))

getLowerBound:Callable[[int],Pair] =  \
    lambda processingNumber: max(filter(lambda pair: pair.number <= processingNumber, MAPPING_TABLE))

adjustLowerBound:Callable[[int],Pair] = \
    lambda processingNumber:   getLowerBound(FIVE) if processingNumber < FIVE else getLowerBound(processingNumber)

getPrevLowerBound:Callable[[int],Pair] = \
    lambda processingNumber: max(filter(lambda pair: pair.number < adjustLowerBound(processingNumber).number, MAPPING_TABLE))

### Computational functions
def getExtractValue(processing_number: int, upper_bound: Pair)->Optional[Pair]:
    """Return Pair if Upper Bound minus the Processing Number exist in the Mapping Table, othewise return None\n
    getExtractValue :: int -> Pair -> Optional Pair"""
    seq:Iterator[Pair] = filter(lambda pair: pair.number == upper_bound.number - processing_number, MAPPING_TABLE)
    return next(seq, None)

def separateDigits(number: int)->List[int]:
    """Separate the argument in individual digits (e.g., given 123 returns [100, 20, 3]) using tail recursion\n
    separateDigits :: int -> [int]"""

    def separateDigitsHelper(num: int,rst: List[int])->List[int]:
        """Auxiliary local function to separate the digits\n
        separateDigitsHelper :: int -> [int] -> [int]"""

        ## Currying Functions using Logic Combinators and lazyness
        # Get the base
        base_number:Callable[[],int]  = lambda : int(bluebird(fnList)(num))

        # Get single digit
        single_digit:Callable[[],int] = lambda : int(starling(division)(bluebird(fnList))(num))

        # Get the Processing Number -> Base times digit
        processing_number:Callable[[],int] = lambda : int(multiply(base_number())(single_digit()))

        return rst if num == ZERO \
            else  separateDigitsHelper(num - processing_number(), rst + [processing_number()])

    return separateDigitsHelper(number,[])                                                # Call Auxiliary Function

def convertToRomanNumber(processing_number_lst: List[int])->str:
    """Get the List of Processing Numbers and convert them to their corresponding Roman Numbers\n
    convertToRomanNumber :: [int] -> str"""

    def convertToRomanNumberHelper(processing_array_number: List[int],rst:str)->str:
        """Auxiliary tail recursion Function ->
        Get the List of Processing Numbers and convert them
        to their corresponding Roman Number\n
        convertToRomanNumberHelper :: [int] -> str -> str"""

        def getRomanNumber()->str:
            """Returns the Roman Number string\n
            getRomanNumber :: str"""

            ### Lazy Evaluation
            case_one:Callable[[],str] = lambda : str(upper_bound.roman)

            case_two:Callable[[],str] = lambda : str(extract_value.roman + upper_bound.roman)

            case_three:Callable[[],str] = lambda : \
                str(lower_bound.roman + prev_lower_bound.roman \
                    * repeat_char (processing_number)(lower_bound.number)(prev_lower_bound.number))

            case_four:Callable[[],str] = lambda : \
                str(lower_bound.roman + lower_bound.roman \
                    * repeat_char (processing_number)(lower_bound.number)(lower_bound.number))

            repeat_char:Callable[[int,int,int],str] = lambda pn: lambda lb: lambda plb:  (pn-lb) // plb

            return case_one() if upper_bound.number == lower_bound.number \
                else  case_two() if extract_value is not None \
                else  case_three() if processing_number > upper_bound.number - lower_bound.number \
                else  case_four()

        if processing_array_number == []:                                               # When List is empty exit
            return rst

        processing_number:int = getHead(processing_array_number)                        # Get the processing number

        upper_bound:Pair =  getUpperBound(processing_number)                            # Calculate Upper Bound
        lower_bound:Pair =  getLowerBound(processing_number)                            # Calculate Lower Bound
        prev_lower_bound:Pair = getPrevLowerBound(processing_number)                    # Calculate Preivoius Lower Bound
        extract_value:Optional[Pair] = getExtractValue(processing_number,upper_bound)   # Check for exact value

        return convertToRomanNumberHelper(getTail(processing_array_number) ,rst + getRomanNumber()) # Call recursively

    return convertToRomanNumberHelper(processing_number_lst, EMPTY_STR)                 # Call Auxiliary Function

def main(nums:List[int])->None:
    """Logic Driver Entry Point\n
    main :: [int] -> Unit"""

    ### Compose (f ∘ g) ≡ λf.λg.λx.f(gx)
    fns:List[CallableFunction] =[separateDigits, convertToRomanNumber]
    roman_number:List[str] = list(map(bluebird(fns),nums))
    result:List[Tuple[int,str]] = list(zip(nums,roman_number))
    (print)(result)                                                          # Display the result
    print()

if __name__ == "__main__":

    NUMBERS:Final[List[int]]  = [1,4,5,9,10,27, 38, 66, 77, 88]
    main(NUMBERS)
