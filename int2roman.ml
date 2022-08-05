open Romanlib

(**  Entry Point *)
let () =
  begin
    let nums :int list  = [1;2;3;4;5;6;7;8;9;10;22;24;27;38;45;66;77;88;90] in
    List.iter (Printf.printf "%d ") nums; 
    Printf.printf "\n";
    
    let roms : string list = List.map  Romanlib.convert_to_roman nums in  
    List.iter (Printf.printf "%s ") roms;      
    Printf.printf "\n"
  end
 
  
  
