with Data_Types;

private package Cpu.Status_Register is

   procedure Set_N_And_Z
     (SR    : in out T_SR;
      Value :        Data_Types.T_Byte);

end Cpu.Status_Register;