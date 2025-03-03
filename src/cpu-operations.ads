with Data_Bus;

private package Cpu.Operations is

   Cpu_Internal_Wrong_Operation : exception;

   procedure Change_Instruction
     (Proc : in out T_Cpu;
      I    :        T_Instruction);

   procedure Add_With_Carry
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Bit_Mem_With_A
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Branch
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Clear_SR
     (Proc : in out T_Cpu);

   procedure Compare
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Decrement
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus);

   procedure Increment
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus);

   procedure Interrupt (Proc       : in out T_Cpu;
                        Bus        : in out Data_Bus.T_Data_Bus;
                        Vector     :        Data_Types.T_Address;
                        Stack_Page :        Data_Types.T_Address);

   procedure Jump
     (Proc       : in out T_Cpu;
      Bus        : in out Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address);

   procedure Load_Value
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Logic_Mem_With_A
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Push
     (Proc       : in out T_Cpu;
      Bus        : in out Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address);

   procedure Pull
     (Proc       : in out T_Cpu;
      Bus        : in out Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address);

   procedure Return_From_Interrupt
     (Proc       : in out T_Cpu;
      Bus        :        Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address);

   procedure Return_From_Sub
     (Proc       : in out T_Cpu;
      Bus        :        Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address);

   procedure Set_SR
     (Proc : in out T_Cpu);

   procedure Shift_Or_Rotate
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus);

   procedure Store_Value
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus);

   procedure Subtract_with_Carry
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus);

   procedure Transfer
     (Proc : in out T_Cpu);

end Cpu.Operations;