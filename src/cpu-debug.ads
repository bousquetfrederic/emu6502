package Cpu.Debug is

   function Get_PC (Proc : T_Cpu) return Long_Integer;
   function Get_A (Proc : T_Cpu) return Long_Integer;
   function Get_X (Proc : T_Cpu) return Long_Integer;
   function Get_Y (Proc : T_Cpu) return Long_Integer;
   function Get_SP (Proc : T_Cpu) return Long_Integer;
   function Get_SR (Proc : T_Cpu) return Long_Integer;

   procedure Set_PC (Proc : in out T_Cpu; PC : Long_Integer);
   procedure Set_A (Proc : in out T_Cpu; A : Long_Integer);
   procedure Set_X (Proc : in out T_Cpu; X : Long_Integer);
   procedure Set_Y (Proc : in out T_Cpu; Y : Long_Integer);
   procedure Set_SP (Proc : in out T_Cpu; SP : Long_Integer);
   procedure Set_SR (Proc : in out T_Cpu; SR : Long_Integer);

   procedure Tick_One_Instruction
     (Proc       : in out T_Cpu;
      Bus        : in out Data_Bus.T_Data_Bus);

end Cpu.Debug;