private package Cpu.Bit_Test is

   function Bit_X_Is_Set (Value : Data_Types.T_Byte;
                          X     : Data_Types.T_Bit_Position)
     return Boolean;

   function Bit_8_Is_Set (Value : Data_Types.T_9_Bits)
     return Boolean;

end Cpu.Bit_Test;