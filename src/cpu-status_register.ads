with Data_Types;

private package Cpu.Status_Register is

   procedure Set_V
     (SR      : in out T_SR;
      Value_1 :        Data_Types.T_Byte;
      Value_2 :        Data_Types.T_Byte;
      Result  :        Data_Types.T_Byte);

   procedure Set_N_And_Z
     (SR    : in out T_SR;
      Value :        Data_Types.T_Byte);

   procedure Set_C
     (SR    : in out T_SR;
      Value :        Data_Types.T_9_Bits);

   function C_As_Byte (C : Boolean)
     return Data_Types.T_Byte;

end Cpu.Status_Register;