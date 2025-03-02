with Cpu.Operations;
with Cpu.Status_Register;
with Data_Types;

package body Cpu.Debug is

   function Get_PC (Proc : T_Cpu) return Long_Integer
   is (Long_Integer (Proc.Registers.PC));
   function Get_A (Proc : T_Cpu) return Long_Integer
   is (Long_Integer (Proc.Registers.A));
   function Get_X (Proc : T_Cpu) return Long_Integer
   is (Long_Integer (Proc.Registers.X));
   function Get_Y (Proc : T_Cpu) return Long_Integer
   is (Long_Integer (Proc.Registers.Y));
   function Get_SP (Proc : T_Cpu) return Long_Integer
   is (Long_Integer (Proc.Registers.SP));
   function Get_SR (Proc : T_Cpu) return Long_Integer
   is (Long_Integer (Status_Register.SR_As_Byte
         (Proc.Registers.SR)));

   procedure Set_PC (Proc : in out T_Cpu; PC : Long_Integer) is
   begin
      Proc.Registers.PC := Data_Types.T_Address (PC);
   end Set_PC;
   procedure Set_A (Proc : in out T_Cpu; A : Long_Integer) is
   begin
      Proc.Registers.A := Data_Types.T_Byte (A);
   end Set_A;
   procedure Set_X (Proc : in out T_Cpu; X : Long_Integer) is
   begin
      Proc.Registers.X := Data_Types.T_Byte (X);
   end Set_X;
   procedure Set_Y (Proc : in out T_Cpu; Y : Long_Integer) is
   begin
      Proc.Registers.Y := Data_Types.T_Byte (Y);
   end Set_Y;
   procedure Set_SP (Proc : in out T_Cpu; SP : Long_Integer) is
   begin
      Proc.Registers.SP := Data_Types.T_Byte (SP);
   end Set_SP;
   procedure Set_SR (Proc : in out T_Cpu; SR : Long_Integer) is
   begin
      Proc.Registers.SR := Status_Register.Byte_As_SR
                             (Data_Types.T_Byte (SR));
   end Set_SR;

   procedure Tick_One_Instruction
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus)
   is
      New_Instruction : Boolean := False;
   begin
      Operations.Change_Instruction
         (Proc,
          Instruction_From_OP_Code
            (Data_Bus.Read_Byte (Bus, Proc.Registers.PC)));
      Proc.Current_Instruction.Cycles := 1;
      while not New_Instruction loop
         Cpu.Tick (Proc, Bus, New_Instruction);
      end loop;
   end Tick_One_Instruction;

end Cpu.Debug;