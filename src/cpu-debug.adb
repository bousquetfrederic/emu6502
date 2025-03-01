with Cpu.Status_Register;

package body Cpu.Debug is

   function Get_PC (Proc : T_Cpu) return Data_Types.T_Address
   is (Proc.Registers.PC);
   function Get_A (Proc : T_Cpu) return Data_Types.T_Byte
   is (Proc.Registers.A);
   function Get_X (Proc : T_Cpu) return Data_Types.T_Byte
   is (Proc.Registers.X);
   function Get_Y (Proc : T_Cpu) return Data_Types.T_Byte
   is (Proc.Registers.Y);
   function Get_SP (Proc : T_Cpu) return Data_Types.T_Byte
   is (Proc.Registers.SP);
   function Get_SR (Proc : T_Cpu) return Data_Types.T_Byte
   is (Status_Register.SR_As_Byte (Proc.Registers.SR));

   procedure Set_PC (Proc : in out T_Cpu; PC : Data_Types.T_Address) is
   begin
      Proc.Registers.PC := PC;
   end Set_PC;
   procedure Set_A (Proc : in out T_Cpu; A : Data_Types.T_Byte) is
   begin
      Proc.Registers.A := A;
   end Set_A;
   procedure Set_X (Proc : in out T_Cpu; X : Data_Types.T_Byte) is
   begin
      Proc.Registers.X := X;
   end Set_X;
   procedure Set_Y (Proc : in out T_Cpu; Y : Data_Types.T_Byte) is
   begin
      Proc.Registers.Y := Y;
   end Set_Y;
   procedure Set_SP (Proc : in out T_Cpu; SP : Data_Types.T_Byte) is
   begin
      Proc.Registers.SP := SP;
   end Set_SP;
   procedure Set_SR (Proc : in out T_Cpu; SR : Data_Types.T_Byte) is
   begin
      Proc.Registers.SR := Status_Register.Byte_As_SR (SR);
   end Set_SR;

end Cpu.Debug;