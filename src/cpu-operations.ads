with Memory;

private package Cpu.Operations is

   Cpu_Internal_Wrong_Operation : exception;

   procedure Add_With_Carry
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory);

   procedure Jump
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory);

   procedure Load_Value
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory);

   procedure Logic_Mem_With_A
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory);

   procedure Shift_Left
     (Cpu : in out T_Cpu;
      Mem : in out Memory.T_Memory);

   procedure Store_Value
     (Cpu : in out T_Cpu;
      Mem : in out Memory.T_Memory);

end Cpu.Operations;