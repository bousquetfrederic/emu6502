with Data_Types;

private package Cpu.Status_Register is

   function C_As_Byte (C : Boolean)
     return Data_Types.T_Byte;

   function Not_C_As_Byte (C : Boolean)
     return Data_Types.T_Byte;

   function SR_As_Byte (SR : T_SR)
     return Data_Types.T_Byte;

   function Byte_As_SR (B : Data_Types.T_Byte)
     return T_SR;

end Cpu.Status_Register;