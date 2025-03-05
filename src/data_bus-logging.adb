with Ada; use Ada;

package body Data_Bus.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Read (Bus     : T_Data_Bus;
                        Address : Data_Types.T_Address;
                        Value   : Data_Types.T_Byte;
                        Force   : Boolean := False)
   is begin
      if Debug_On and then
         (Force or else
          Connectables.Address_In_Address_Space
           (Address, Address_Space_Of_Interest))
      then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (Debug_File, "BUS : " &
                        Bus.Clock_Counter'Image & " : ");
         Text_IO.Put
           (Debug_File, "Read at : ");
         Address_IO.Put
           (Debug_File, Address);
         Text_IO.Put
           (Debug_File, " : ");
         Byte_IO.Put
           (Debug_File, Value);
         Text_IO.New_Line (Debug_File);
      end if;
   end Dump_Read;

   procedure Dump_Write (Bus     : T_Data_Bus;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte)
   is begin
      if Debug_On and then
         Connectables.Address_In_Address_Space
           (Address, Address_Space_Of_Interest)
      then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (Debug_File, "BUS : " &
                        Bus.Clock_Counter'Image & " : ");
         Text_IO.Put
           (Debug_File, "Write at : ");
         Address_IO.Put
           (Debug_File, Address);
         Text_IO.Put
           (Debug_File, " : ");
         Byte_IO.Put
           (Debug_File, Value);
         Text_IO.New_Line (Debug_File);
      end if;
   end Dump_Write;

end Data_Bus.Logging;