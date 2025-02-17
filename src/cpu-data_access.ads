private with Memory;

private package Cpu.Data_Access is

   function Fetch_Address
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
   return Data_Types.T_Address
   with
      Pre => Addressing_Type = ABSOLUTE
             or else
             Addressing_Type = INDIRECT;

   function Fetch_Byte
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
     return Data_Types.T_Byte;

   procedure Store_Byte
     (Addressing_Type :        T_Addressing_Types_To_Fetch_Bytes;
      Mem             : in out Memory.T_Memory;
      Registers       :        T_Registers;
      Value           :        Data_Types.T_Byte);

end Cpu.Data_Access;