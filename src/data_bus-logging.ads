package Data_Bus.Logging is

   Log_On : Boolean := False;

   Address_Space_Of_Interest : Connectables.T_Address_Space
     := (Data_Types.T_Address'First, Data_Types.T_Address'Last);

   procedure Dump_Read (Address : Data_Types.T_Address;
                        Value   : Data_Types.T_Byte;
                        Force   : Boolean := False);

   procedure Dump_Write (Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte);

end Data_Bus.Logging;