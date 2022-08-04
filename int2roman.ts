
// Import Functional Typescript Libraries
import {convertToRoman} from './roman-convert'
import { map }          from 'fp-ts/Array' 

console.log("Start")
 
// Input Array
const nums:number[] = [23,24,27,33,36,37,38,62,66,67,77,88,90]

// Map Array over with convertToRoman function  
const rst =  map(convertToRoman) (nums)

console.log(nums)
console.log(rst)
 
console.log("Done")
 