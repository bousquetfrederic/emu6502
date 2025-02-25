with Ada.Text_IO;
with Data_Types;

package Memory is

   type T_Memory is limited private;

   Invalid_Address : exception;

   function Read_Byte (Mem     : T_Memory;
                       Address : Data_Types.T_Address)
     return Data_Types.T_Byte;

--   function Read_Word (Mem     : T_Memory;
--                       Address : Data_Types.T_Address)
--     return Data_Types.T_Word;

   procedure Write_Byte (Mem     : in out T_Memory;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte);

   procedure Write_Byte_To_ROM
     (Mem     : in out T_Memory;
      Address : Data_Types.T_Address;
      Value   : Data_Types.T_Byte);

   procedure Load_To_RAM (Mem     : in out T_Memory;
                          Address :        Data_Types.T_Address;
                          Bytes   :        Data_Types.T_Byte_Array);

   procedure Load_To_ROM (Mem     : in out T_Memory;
                          Address :        Data_Types.T_Address;
                          Bytes   :        Data_Types.T_Byte_Array);

   procedure Load_Text_File_To_ROM (Mem : in out T_Memory;
                                    Address : Data_Types.T_Address;
                                    File    : Ada.Text_IO.File_Type);

private

   subtype T_RAM_Address is
     Data_Types.T_Address range 16#0000# .. 16#BFFF#;

   subtype T_ROM_Address is
     Data_Types.T_Address range 16#C000# .. 16#FFFF#;

   type T_Memory is
   record
      RAM : Data_Types.T_Byte_Array (T_RAM_Address);
      ROM : Data_Types.T_Byte_Array (T_ROM_Address);
   end record;

end Memory;
