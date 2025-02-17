with Cpu.Bit_Test;

package body Cpu.Status_Register is

   procedure Set_V
     (SR      : in out T_SR;
      Value_1 :        Data_Types.T_Byte;
      Value_2 :        Data_Types.T_Byte;
      Result  :        Data_Types.T_Byte)
   is
      S_Val_1  : constant Boolean := Bit_Test.Bit_X_Is_Set (Value_1, 7);
      S_Val_2  : constant Boolean := Bit_Test.Bit_X_Is_Set (Value_2, 7);
      S_Result : constant Boolean := Bit_Test.Bit_X_Is_Set (Result, 7);
   begin
      SR.V := (S_Val_1 and S_Val_2 and S_Result)
              or else
              (not S_Val_1 and not S_Val_2 and not S_Result);
   end Set_V;

   procedure Set_N_And_Z
     (SR    : in out T_SR;
      Value :        Data_Types.T_Byte)
   is
      use type Data_Types.T_Byte;
   begin
      SR.N := Bit_Test.Bit_X_Is_Set (Value, 7);
      SR.Z := Value = 0;
   end Set_N_And_Z;

   procedure Set_C
     (SR    : in out T_SR;
      Value :        Data_Types.T_9_Bits)
   is
   begin
      SR.C := Bit_Test.Bit_8_Is_Set (Value);
   end Set_C;

   function C_As_Byte (C : Boolean)
     return Data_Types.T_Byte
   is
   begin
      if C then
         return Data_Types.One_Byte;
      else
         return 0;
      end if;
   end C_As_Byte;

end Cpu.Status_Register;