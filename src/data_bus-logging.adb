with Ada; use Ada;
with Ada.Text_IO;
with Debug;

package body Data_Bus.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Read (Bus     : T_Data_Bus;
                        Address : Data_Types.T_Address;
                        Value   : Data_Types.T_Byte;
                        Force   : Boolean := False)
   is
      DF : Text_IO.File_Type renames Debug.Debug_File;
   begin
      if Debug_On and then
         (Force or else
          Connectables.Address_In_Address_Space
           (Address, Address_Space_Of_Interest))
      then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (DF, "BUS : " &
                Bus.Clock_Counter'Image & " : ");
         Text_IO.Put
           (DF, "Read at : ");
         Address_IO.Put
           (DF, Address);
         Text_IO.Put
           (DF, " : ");
         Byte_IO.Put
           (DF, Value);
         Text_IO.New_Line (DF);
      end if;
   end Dump_Read;

   procedure Dump_Write (Bus     : T_Data_Bus;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte)
   is
      DF : Text_IO.File_Type renames Debug.Debug_File;
   begin
      if Debug_On and then
         Connectables.Address_In_Address_Space
           (Address, Address_Space_Of_Interest)
      then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (DF, "BUS : " &
                 Bus.Clock_Counter'Image & " : ");
         Text_IO.Put
           (DF, "Write at : ");
         Address_IO.Put
           (DF, Address);
         Text_IO.Put
           (DF, " : ");
         Byte_IO.Put
           (DF, Value);
         Text_IO.New_Line (DF);
      end if;
   end Dump_Write;

end Data_Bus.Logging;