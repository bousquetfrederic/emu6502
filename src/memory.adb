package body Memory is

   function Read_Byte (Mem     : T_Memory;
                       Address : Data_Types.T_Address)
     return Data_Types.T_Byte is
   begin
      if Address in T_RAM_Address then
         return Mem.RAM (Address);
      elsif Address in T_ROM_Address then
         return Mem.ROM (Address);
      else
         raise Invalid_Address;
      end if;
   end Read_Byte;

   function Read_Word (Mem     : T_Memory;
                       Address : Data_Types.T_Address)
     return Data_Types.T_Word
   is
      use type Data_Types.T_Byte;
   begin
      return (Low  => Read_Byte (Mem, Address),
              High => Read_Byte (Mem, Address + Data_Types.One_Byte));
   end Read_Word;

   procedure Write_Byte (Mem     : in out T_Memory;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte) is
   begin
      if Address in T_RAM_Address then
         Mem.RAM (Address) := Value;
      else
         raise Invalid_Address with Data_Types.T_Address'Image (Address);
      end if;
   end Write_Byte;

   procedure Write_Byte_To_ROM
     (Mem     : in out T_Memory;
      Address : Data_Types.T_Address;
      Value   : Data_Types.T_Byte) is
   begin
      if Address in T_ROM_Address
      then
         Mem.ROM (Address) := Value;
      else
         raise Invalid_Address with Data_Types.T_Address'Image (Address);
      end if;
   end Write_Byte_To_ROM;

   procedure Load_To_RAM (Mem     : in out T_Memory;
                          Address :        Data_Types.T_Address;
                          Bytes   :        Data_Types.T_Byte_Array)
   is
      use type Data_Types.T_Address;
      End_Address : constant Data_Types.T_Address
        := Address + Data_Types.T_Address (Bytes'Length)
           - Data_Types.One_Byte;
   begin
      --  If the last byte would end up outside of the limit
      --  of the RAM, we can't write this to RAM
      if End_Address in T_RAM_Address
      then
         Mem.RAM (Address .. End_Address)
           := Bytes (Bytes'Range);
      else
         raise Invalid_Address
           with Data_Types.T_Address'Image (Address)
           & " .. "
           & Data_Types.T_Address'Image (End_Address);
      end if;
   end Load_To_RAM;

   procedure Load_To_ROM (Mem     : in out T_Memory;
                          Address :        Data_Types.T_Address;
                          Bytes   :        Data_Types.T_Byte_Array)
   is
      use type Data_Types.T_Address;
      End_Address : constant Data_Types.T_Address
        := Address + Data_Types.T_Address (Bytes'Length)
           - Data_Types.One_Byte;
   begin
      --  If Address is in RAM, Load_To_RAM should be used
      if Address in T_ROM_Address
      then
         Mem.ROM (Address .. End_Address)
           := Bytes (Bytes'Range);
      else
         raise Invalid_Address
           with Data_Types.T_Address'Image (Address)
           & " .. "
           & Data_Types.T_Address'Image (End_Address);
      end if;
   end Load_To_ROM;

   procedure Load_Text_File_To_ROM
     (Mem     : in out T_Memory;
      Address :        Data_Types.T_Address;
      File    :        Ada.Text_IO.File_Type)
   is
      use Ada.Text_IO;
      use type Data_Types.T_Address;
      Where_To : Data_Types.T_Address := Address;
   begin
      while not End_Of_File (File) loop
         declare
            S : constant String := Get_Line (File);
         begin
            if S (S'First) /= '#'
            then
               Write_Byte_To_ROM
                 (Mem, Where_To, Data_Types.T_Byte'Value
                                   ("16#" & S (1 .. 2) & "#"));
               Where_To := Where_To + Data_Types.One_Byte;
            end if;
         end;
      end loop;
   end Load_Text_File_To_ROM;

end Memory;
