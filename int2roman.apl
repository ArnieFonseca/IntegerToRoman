map←(1 'I') (5 'V') (10 'X') (50 'L') (100 'C') (500 'D') (1000 'M') ⍝ Mapping table

getPN←{B×⌊⍵÷B←10*⌊10⍟⍵} ⍝ Get Processing Number

getUB←{map⌷⍨⊃⍸(⍵≤⊃)¨map} ⍝ Get Upper Bound

getLB←{ map⌷⍨⊃⊖⍸(⍵≥⊃)¨map} ⍝ Get the Lower from the input

⍝ Get the prev Lower bound from the input
adjustLB←{⍵<5:5 ⋄ ⍵}
getPLB←{lmt←adjustLB(⊃)¨getLB ⍵ ⋄ {map⌷⍨⊃⊖⍸(⍵>⊃)¨map}lmt}

⍝ Get an extact number from the mapping table otherwise return (0 'Z')
getExact←{({≢⍸(⍵=⊃)¨map}⍵)=0:↓(0 'Z') ⋄ {map⌷⍨⍸(⍵=⊃)¨map}⍵}
 	
⍝ Get Roman Component
getRoman←(2∘⊃)¨
⍝ Get Integer Component
getInteger←(⊃)¨

⍝ Local Index variable
UB←2
LB←3
PLB←4
EV←5

getPA←{
 ⍝ Create an array recursely
 ⍝ Give 1972 it produces 1000 900 70 2
     ⍬{
         ⍵=0:⍺         ⍝ Return the array
         pn←getPN ⍵    ⍝ Save Processing Number
         (⍺,pn)∇ ⍵-pn  ⍝ Call in tail recursion fashion
     }⍵
 }

intToRoman←{
     {
    ⍝ Convert an Interger to a Roman Number
         pn←⍵
         ⎕←data←(pn(getUB pn)(getLB pn)(getPLB pn)(getExact pn-⍨getInteger getUB pn))
         {
         ⍝ Case 1 Extract number like 1 5 10 50 ...
             ⍵=getInteger UB⊃data:getRoman UB⊃data

         ⍝ Case 2 UB - PN the diff exist in the mapping table
             (((getInteger UB⊃data)-⍵)=(getInteger EV⊃data)):(getRoman EV⊃data),(getRoman UB⊃data)

         ⍝ Case 3 Processing Number less than Upper Bound - Lower Bound
             ⍵<((getInteger UB⊃data)-(getInteger LB⊃data)):(pn÷(getInteger LB⊃data))⍴(getRoman LB⊃data)

         ⍝ Case 4 Processing Number greater than Upper Bound - Lower Bound
             ⍵>((getInteger UB⊃data)-(getInteger LB⊃data)):(getRoman LB⊃data),(((⊃data)-(getInteger LB⊃data))÷(getInteger PLB⊃data))⍴(getRoman PLB⊃data)
             
         }pn
     }¨getPA ⍵
}