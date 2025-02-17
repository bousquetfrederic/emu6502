package body Cpu.Bit_Test is

   function Bit_X_Is_Set (Value : Data_Types.T_Byte;
                          X     : Data_Types.T_Bit_Position)
     return Boolean
   is
      use type Data_Types.T_Byte;
      Bit_X_Mask : constant Data_Types.T_Byte := 2**X;
   begin
      return (Value and Bit_X_Mask) /= 0;
   end Bit_X_Is_Set;

   function Bit_8_Is_Set (Value : Data_Types.T_9_Bits)
     return Boolean
   is
      use type Data_Types.T_9_Bits;
      Bit_8_Mask : constant Data_Types.T_9_Bits
        := 2#100000000#;
   begin
      return (Value and Bit_8_Mask) /= 0;
   end Bit_8_Is_Set;

end Cpu.Bit_Test;