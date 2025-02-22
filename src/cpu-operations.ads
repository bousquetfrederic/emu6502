with Memory;

private package Cpu.Operations is

   Cpu_Internal_Wrong_Operation : exception;

   procedure Change_Instruction
     (Proc : in out T_Cpu;
      I    :        T_Instruction);

   procedure Add_With_Carry
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory);

   procedure Bit_Mem_With_A
     (Proc : in out T_Cpu;
      Mem :        Memory.T_Memory);

   procedure Branch
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory);

   procedure Clear_SR
     (Proc : in out T_Cpu);

   procedure Compare
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory);

   procedure Decrement
     (Proc : in out T_Cpu;
      Mem  : in out Memory.T_Memory);

   procedure Increment
     (Proc : in out T_Cpu;
      Mem  : in out Memory.T_Memory);

   procedure Interrupt (Proc       : in out T_Cpu;
                        Mem        : in out Memory.T_Memory;
                        Vector     :        Data_Types.T_Address;
                        Stack_Page :        Data_Types.T_Address);

   procedure Jump
     (Proc       : in out T_Cpu;
      Mem        : in out Memory.T_Memory;
      Stack_Page :        Data_Types.T_Address);

   procedure Load_Value
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory);

   procedure Logic_Mem_With_A
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory);

   procedure Push
     (Proc       : in out T_Cpu;
      Mem        : in out Memory.T_Memory;
      Stack_Page :        Data_Types.T_Address);

   procedure Pull
     (Proc       : in out T_Cpu;
      Mem        : in out Memory.T_Memory;
      Stack_Page :        Data_Types.T_Address);

   procedure Return_From_Interrupt
     (Proc       : in out T_Cpu;
      Mem        :        Memory.T_Memory;
      Stack_Page :        Data_Types.T_Address);

   procedure Return_From_Sub
     (Proc       : in out T_Cpu;
      Mem        :        Memory.T_Memory;
      Stack_Page :        Data_Types.T_Address);

   procedure Set_SR
     (Proc : in out T_Cpu);

   procedure Shift_Or_Rotate
     (Proc : in out T_Cpu;
      Mem  : in out Memory.T_Memory);

   procedure Store_Value
     (Proc : in out T_Cpu;
      Mem  : in out Memory.T_Memory);

   procedure Substract_with_Carry
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory);

   procedure Transfer
     (Proc : in out T_Cpu);

end Cpu.Operations;