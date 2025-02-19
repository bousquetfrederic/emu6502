private with Memory;

private package Cpu.Data_Access is

   Cpu_Internal_Wrong_Data_Access : exception;

   type T_Location_Kind is (L_ACCUMULATOR, L_X, L_Y, L_MEMORY);
   type T_Location is
   record
      Kind : T_Location_Kind;
      Address : Data_Types.T_Address;
   end record;

   function Addressing_Points_To
     (Addressing_Type : T_Valid_Addressing_Types;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
   return T_Location;

   function Fetch_Address
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
   return Data_Types.T_Address
   with
      Pre => Addressing_Type = ABSOLUTE
             or else
             Addressing_Type = INDIRECT;

   function Addresses_On_Same_Page
     (Address_1 : Data_Types.T_Address;
      Address_2 : Data_Types.T_Address)
   return Boolean;

   function Fetch_Byte
     (Location  : T_Location;
      Mem       : Memory.T_Memory;
      Registers : T_Registers)
   return Data_Types.T_Byte;

   function Fetch_Byte
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
     return Data_Types.T_Byte;

   procedure Store_Byte
     (Location  :        T_Location;
      Mem       : in out Memory.T_Memory;
      Registers : in out T_Registers;
      Value     :        Data_Types.T_Byte);

   procedure Store_Byte
     (Addressing_Type :        T_Addressing_Types_To_Fetch_Bytes;
      Mem             : in out Memory.T_Memory;
      Registers       : in out T_Registers;
      Value           :        Data_Types.T_Byte);

end Cpu.Data_Access;