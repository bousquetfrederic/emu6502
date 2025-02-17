with Cpu.Bit_Test;

package body Cpu.Status_Register is

   procedure Set_N_And_Z
     (SR    : in out T_SR;
      Value :        Data_Types.T_Byte)
   is
      use type Data_Types.T_Byte;
   begin
      SR.N := Bit_Test.Bit_7_Is_Set (Value);
      SR.Z := Value = 0;
   end Set_N_And_Z;

end Cpu.Status_Register;