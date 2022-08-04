// Import Functional Typescript Libraries
import { pipe }                     from 'fp-ts/function'
import { findFirst, findLast}  from 'fp-ts/Array' 
import { match, Option }            from 'fp-ts/Option'
 
// Define types 
export type Pair = {Integer:number, Roman:string}
type Pairs = Pair[]


// Enumeration to control pattern matchin
export enum CaseType  {
    CaseOne,    // Number Exist in Mapping Table (e.g., 1, 5, 10, 50 ...)
    CaseTwo,    // UB - PN exist in Mapping Table (e.g., 4, 9, 40, 90 ...)
    CaseThree,  // UB - LB > PN Repeating group implies (PN - LB) / LB (e.g., 20, 30, 200, 300 => XX, XXX, CC, CCC) 
    CaseFour    // UB - LB < PN implies LB with PLB times (PN - LB) / PLB (e.g., 60, 70, 80, 600, 700, 800)
} 

//#region  Build Mapping Table

const zero:Pair         = { Integer: 0, Roman: '' } // Default

const one:Pair          = {Integer:1, Roman:"I"}
const five:Pair         = {Integer:5, Roman:"V"}
const ten:Pair          = {Integer:10, Roman:"X"}
const fifty:Pair        = {Integer:50, Roman:"L"}
const hundred:Pair      = {Integer:100, Roman:"C"}
const five_hundred:Pair = {Integer:500, Roman:"D"}
const thounsand:Pair    = {Integer:1000, Roman:"M"}

const mapping_table:Pairs =  [one, five, ten, fifty, hundred, five_hundred, thounsand]

//#endregion

//#region Calc Exact Upper, Lower, and Prov Lower Bound functions

/**
 * unwarp:: Option of Pair -> Pair
 * Unbox the Optional Pair returned from the findFirst, findLast function
 * @param optPair Represents an Option of Pair return from  either findFirst or findLast
 * @returns The unwrapped Pair
 */
const unwarp = (optPair:Option<Pair>) : Pair => match( () => zero, (p:Pair) => p) (optPair)

/**
 * getProcessNumber:: Number -> Number
 * Given a number it will return the Procesing Number 
 * @param n Represents the number being process
 * @returns Given 735 it will return 700 | Given 35 it will return 30 | Given 5 it will return 5
 */
const getProcessNumber = (n:number) : number=>  {
        
    // Function to ten base exponent -> 10^x
    const pow = (x:number) => Math.pow(10,x)      

    const base:number = pipe(n, Math.log10, Math.trunc, pow)

    const pn:number = Math.trunc(n/base) * base     

    return pn
    }

/**
 * getExtact:: Number -> Pair
 * @param x Represents a look-up number into the Mapping Table
 * @returns Pair from Mapping Table or Pair default value (e.g., zero Pair)
 */
const getExtact = (x:number)  : Pair =>
        pipe(mapping_table, 
        findFirst((pair: Pair) => pair.Integer === x ),
        unwarp
        )

/**
 * Get the Upper Bound
 * getUpperBound:: Number -> Pair
 * @param x Represents the Proicessing Number
 * @returns The Upper Bound of the Processing Number
 */
const getUpperBound = (x:number) : Pair  => 
      pipe(mapping_table, 
      findFirst((pair: Pair) => pair.Integer >= x ),
      unwarp
      )

/**
 * getLowerBound:: Number -> Pair
 * Get the Lower Bound
 * @param x Represents the Proicessing Number
 * @returns The Lower Bound of the Processing Number
 */
const getLowerBound = (x:number) : Pair  =>
        pipe(mapping_table, 
        findLast((pair: Pair) => pair.Integer <= x ),
        unwarp       
        )

/**
 * adjustLB:: Number  -> Number
 * Adjust the Lower Bound to prevent an out of index 
 * When the Lower Bound passed is less than five is overrided by five
 * otherwise it is a passthru
 * @param x Represents the Lower Bound
 * @returns an adjusted Lower Bound number
 */
const adjustLB = (x:number) : number => (x < 5) ? 5 : x 
 
/**
 * getPrevLowerBound:: Number -> Pair
 *  Calculates the Previous Lower Bound
 * @param x Represents the Procession Number
 * @returns Represents the Lower Bound of the current Lower Bound
 */
const getPrevLowerBound = (x:number) : Pair   =>
        pipe(mapping_table, 
        findLast((pair: Pair) => pair.Integer < x ),
        unwarp           
        )

// Calcuate the case scenario
/**
 * getCaseType:: Number -> Pair -> Pair -> CaseType
 * @param pn processing Number
 * @param ub Upper Bount of Processing Number
 * @param lb LowerBount of Processing Number
 * @returns Represents the Case Scenario 
 */
const getCaseType = (pn:number) =>( ub:Pair) => (lb:Pair) : CaseType => {

    // Check if Upper Bounfd minus Processin Number exists in the Mapping Table
    const exactNumber:Pair = getExtact(ub.Integer - pn)   
    
    // Processing Number matches Upper Bound
    if (pn === ub.Integer) return CaseType.CaseOne

    // Diff between Upper Boiund and Processing Nuber exist in the Mapping Table
    if (exactNumber.Integer !== 0) return CaseType.CaseTwo

    // Diff of Upper minus Lower Bound is greater than Processing Number
    if (ub.Integer - lb.Integer > pn) return CaseType.CaseThree
    
    // Otherwise Diff of Upper minus Lower Bound is less than Processing Number
    return CaseType.CaseFour     
}

/**
 * getRomanNumber:: (CaseType -> Number -> Pair -> Pair -> Pair) -> String
 * @param caseType 
 * @param pn Processing Number
 * @param ub Upper Bount of Processing Number
 * @param lb LowerBount of Processing Number
 * @param plb Prev LowerBount of Processing Number -> Lower Bound of the Lower Bound
 * @returns The converted Roman Number based on the input Processing Number
 */

const getRomanNumber = (caseType:CaseType) => (pn:number) => (ub:Pair) => (lb:Pair) => (plb:Pair) : string => {

    let exactNumber:Pair = getExtact(ub.Integer - pn)   

    switch (caseType) {
        case CaseType.CaseOne:
            return ub.Roman            
        case CaseType.CaseTwo:
            return exactNumber.Roman + ub.Roman 
        case CaseType.CaseThree:
                return lb.Roman + lb.Roman.repeat((pn - lb.Integer) / lb.Integer) 
        default:
            return lb.Roman + plb.Roman.repeat((pn - lb.Integer) / plb.Integer) 
             
    }
}

//#endregion

/**
 * convertToRoman:: Number -> String
 * Public function :: Convert to Roman (e.g., given 9 it will convert to IX)
 * @param num Represents the input number to be converted to roman
 * @returns The roman version of the input
 */
export const convertToRoman = (num:number) :  string => {

    /**
     * mainLoop: (Number -> String) -> String
     */
    function helper(num:number, rst:string) : string {

        // While num is greater that zeros
        if (num > 0 ) {
            
            const processingNumber:number = getProcessNumber(num)

            const ub:Pair                 = getUpperBound(processingNumber)
            const lb:Pair                 = getLowerBound(processingNumber)
            const plb:Pair                = getPrevLowerBound(adjustLB(lb.Integer))    

            const caseType:CaseType       = getCaseType(processingNumber) (ub) (lb)

            const romanNumber:string      = getRomanNumber(caseType) (processingNumber)  (ub) (lb) (plb) 
            
            return helper(num - processingNumber, rst + romanNumber)
        }
    
        return rst
    }

    return `${num}-> ${helper(num,"")}` 

}
 