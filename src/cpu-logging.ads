package Cpu.Logging is

   Log_On : Boolean := False;

   procedure Dump_Current_Instruction (Proc : T_Cpu);
   procedure Dump_Registers (Proc : T_Cpu);
   procedure Dump_Status (Proc : T_Cpu);

end Cpu.Logging;