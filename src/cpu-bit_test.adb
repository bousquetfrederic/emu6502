package body Cpu.Bit_Test is

   function Bit_7_Is_Set (Byte : Data_Types.T_Byte)
     return Boolean
   is
      use type Data_Types.T_Byte;
      Bit_7_Mask : constant Data_Types.T_Byte
        := 2#10000000#;
   begin
      return (Byte and Bit_7_Mask) /= 0;
   end Bit_7_Is_Set;

end Cpu.Bit_Test;