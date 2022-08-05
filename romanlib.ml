 
(** Types definitions*)
type pair  = {integer:int; roman:string}
type pairs  =  pair list
type case_type = CaseOne | CaseTwo | CaseThree | CaseFour
type boundary_record = {ub:pair; lb:pair; plb:pair; exact:pair option }

(** Construct each pair*)
let one: pair                 = {integer=1;roman="I"}
let five: pair                = {integer=5;roman="V"}
let ten: pair                 = {integer=10;roman="X"}
let fifty: pair               = {integer=50;roman="L"}
let hundred: pair             = {integer=100;roman="C"}
let five_hundred: pair        = {integer=500;roman="D"}
let thousand: pair            = {integer=1000;roman="M"}

(** Maping table *)
let mapping_tab: pairs        = [one; five; ten; fifty; hundred;
                                five_hundred; thousand]
(** Constant Five *)
let five_bound: int = 5

(** Get an Exact entry from the mapping table and retuen an optional *)
let get_exact (p:int)  : pair  option =
  let x = List.filter (fun x -> x.integer ==  p) mapping_tab in
  begin 
    match x with
      [] -> None
    | _ -> Some (List.hd x)
  end

(** Upper Bound *)
let get_upper_bound (p:int) : pair =
  List.filter (fun x -> x.integer >=  p) mapping_tab |> List.hd

(** Lower Bound *)
let get_lower_bound (p:int) : pair =
  List.filter (fun x -> x.integer <=  p) mapping_tab |> List.rev |> List.hd

(** Get the Previous Lower Bound *)
let get_pre_lower_bound (p:int) : pair =
  
  (** First => Get the Lower Bound *)
  let lb: pair = get_lower_bound p in  
  
  (** Adjust the Lower bound> when less the five set it to five *)
  let new_value:int = if lb.integer < five_bound then five_bound else lb.integer  in
  (** Previous Lower Bound *)
  List.filter (fun x -> x.integer <  new_value) mapping_tab |> List.rev |> List.hd

(** Build the boundary record *) 
let get_boundary (p:int) : boundary_record =  {ub=get_upper_bound p; 
                                              lb=get_lower_bound p; 
                                              plb= get_pre_lower_bound p;
                                              exact=get_exact p}
(** Check for case two => IV IX XL XC *)
let isCaseTwo(p:int) (boundary:boundary_record) : bool = 
  (boundary.ub.integer - p |> get_exact) != None

(** Check for case thre => II III XX XXX CC CCC*)
let isCaseThree (p:int) (boundary:boundary_record) : bool = 
  boundary.ub.integer - p > boundary.lb.integer

(** Calculate the Case Type *)    
let get_case_type (p:int) (boundary: boundary_record) : case_type =
  if boundary.exact != None then CaseOne         (* Case One  Extract Number: Number that exists in the mapping table *)
  else if isCaseTwo p boundary then CaseTwo      (* Case Two Componded   IV IX XL XC *)
  else if isCaseThree p boundary then CaseThree  (* Case Repeat Pattern  II II XX XXX CC CCC *)
  else CaseFour                                  (* Case Four VI XVII XVIII LVI LVII  *)


(** Get the value out of the optional container*)
let unwrap_roman  = function
    Some rn -> rn.roman
  | None -> ""

(** Repeart an string a number of times*)
let rec repeat (n:int) (s:string) : string=
  if n = 0 then "" else s ^ repeat (n - 1) s

(** Display the roman nuimber 29 => XXIX *)
let display_roman (p:int) : string  = 
  let boundary = get_boundary p in 
  let case = get_case_type p boundary in match case with
    CaseOne -> boundary.ub.roman
  | CaseTwo -> (boundary.ub.integer - p |> get_exact |> unwrap_roman) ^ boundary.ub.roman
  | CaseThree -> repeat (p / boundary.lb.integer) boundary.lb.roman
  | CaseFour -> boundary.lb.roman ^ repeat ((p -  boundary.lb.integer) / boundary.plb.integer) boundary.plb.roman

(** function 10^x *)
let pow = ( ** ) 10.

(** Get the process number 235 => 200 *)
let get_processing_number (n:int) : int =
  
  (** Calculate the base number*)
  let base_number : int  = 
                       n 
                    |> float            (** Convert to float *)
                    |> log10            (** Get Log base 10 *)
                    |> Int.of_float     (** To Integer *)
                    |> float            (** Convert to float *)
                    |> pow              (** pow 10 of x *)
                    |> Int.of_float in  (** To Integer *)
  
  (** return the number to process*)                                       
  let p : int = n / base_number * base_number in p

(** Convert interger to roman using tail recursion *)
let rec convert_to_roman_helper (n:int) (rst:string): string = 
    match n with
      0 -> rst (** Base case *)
    | _ ->  
        begin 
        (** Process the number and display roman version *)
          let roman_number :string  = display_roman (get_processing_number n) in
          convert_to_roman_helper (n - (get_processing_number n)) (rst ^ roman_number)
        end

(** Main Driver Logic *)
let convert_to_roman (n:int) : string = 
  let rst:string  =  convert_to_roman_helper n "" in 
  rst
