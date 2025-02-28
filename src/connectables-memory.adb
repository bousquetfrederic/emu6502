package body Connectables.Memory is

   use type Data_Types.T_Address;

   overriding
   function Read_Byte (Mem     : T_Memory;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte is
   begin
      if not Address_In_Address_Space (Address, Mem.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      else
         return Mem.Data (Address);
      end if;
   end Read_Byte;

   procedure Set_Writable
     (Mem : in out T_Memory;
      W : Boolean := True) is
   begin
      Mem.Is_Writable := W;
   end Set_Writable;

   procedure Load_To_Memory
     (Mem     : in out T_Memory'Class;
      Address :        Data_Types.T_Address;
      Bytes   :        Data_Types.T_Byte_Array)
   is
      End_Address : constant Data_Types.T_Address
        := Address + Data_Types.T_Address (Bytes'Length)
           - Data_Types.One_Byte;
   begin
      --  If the last byte would end up outside of the limit
      --  of the memory, we can't write this
      if Address_In_Address_Space (Address, Mem.Get_Address_Space)
      then
         Mem.Data (Address .. End_Address)
           := Bytes (Bytes'Range);
      else
         raise Connectable_Address_Not_In_Range
           with Data_Types.T_Address'Image (Address)
           & " .. "
           & Data_Types.T_Address'Image (End_Address);
      end if;
   end Load_To_Memory;

   procedure Load_Text_File_To_Memory
     (Mem     : in out T_Memory'Class;
      Address : Data_Types.T_Address;
      File    : Ada.Text_IO.File_Type)
   is
      use Ada.Text_IO;
      Where_To : Data_Types.T_Address := Address;
   begin
      while not End_Of_File (File) loop
         declare
            S : constant String := Get_Line (File);
         begin
            if S (S'First) /= '#'
            then
               Write_Byte
                 (Mem, Where_To, Data_Types.T_Byte'Value
                                   ("16#" & S (1 .. 2) & "#"));
               Where_To := Where_To + Data_Types.One_Byte;
            end if;
         end;
      end loop;
   end Load_Text_File_To_Memory;

   overriding
   procedure Write_Byte
     (Mem     : in out T_Memory;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte) is
   begin
      if not Mem.Is_Writable
      then
         --  Do nothing if not writable
         --  TODO : there should be some log
         null;
      elsif not Address_In_Address_Space (Address, Mem.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range
           with Address'Image & " vs " &
                Mem.Get_Address_Space.First_Address'Image & " .." &
                Mem.Get_Address_Space.Last_Address'Image;
      else
         Mem.Data (Address) := Value;
      end if;
   end Write_Byte;

end Connectables.Memory;