with Memory;

private package Cpu.Operations is

   Cpu_Internal_Wrong_Operation : exception;

   procedure Change_Instruction
     (Proc : in out T_Cpu;
      I    :        T_Instruction);

   procedure Add_With_Carry
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory);

   procedure Branch
     (Proc : in out T_Cpu;
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

   procedure Shift_Or_Rotate_Left
     (Cpu : in out T_Cpu;
      Mem : in out Memory.T_Memory);

   procedure Store_Value
     (Cpu : in out T_Cpu;
      Mem : in out Memory.T_Memory);

end Cpu.Operations;