with Ada.Text_IO;
package Data_Bus.Logging is

   Debug_On : Boolean := True;
   Debug_File : Ada.Text_IO.File_Type :=
                  Ada.Text_IO.Standard_Output;

   procedure Dump_Read (Bus     : T_Data_Bus;
                        Address : Data_Types.T_Address;
                        Value   : Data_Types.T_Byte);

   procedure Dump_Write (Bus     : T_Data_Bus;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte);

end Data_Bus.Logging;