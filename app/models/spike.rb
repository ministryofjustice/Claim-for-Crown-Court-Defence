 h1 = {
         "original" => {
           true => {
             30 => {
               50 => {
                 :visibility => false,
                 :transfer_fee_full_name => "Fee full name",
                 :allocation_case_type => "grad"
               }
             }
           }
         }
       }

 h2 = {
   "original" => {
     true => {
       30 => {
         60 => {
           :visibility => false,
           :transfer_fee_full_name => "Fee full name",
           :allocation_case_type => "grad"
         }
       }
     }
   }
 }

 require 'awesome_print'
 ap h1.deep_merge(h2)