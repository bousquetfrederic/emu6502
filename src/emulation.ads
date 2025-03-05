package Emulation is

   type T_Rom_Type is (BINARY, TEXT);

   procedure Run_Rom (Rom_Name : String;
                           Rom_Type : T_Rom_Type);

end Emulation;