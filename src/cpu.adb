with Cpu;
with Cpu.Operations;
with Data_Types;
use type Data_Types.T_Address;

package body Cpu is

   Stack_Page : constant Data_Types.T_Address := 16#100#;

   Reset_SR : constant T_SR :=
   (
      U      => True,
      others => False
   );

   To_Next_Instruction : constant array (T_Valid_Addressing_Types)
     of T_Address_Increment :=
   (ACCUMULATOR => 1,
    IMPLIED     => 1,
    IMMEDIATE   => 2,
    ZERO_PAGE   => 2,
    ZERO_PAGE_X => 2,
    ZERO_PAGE_Y => 2,
    INDIRECT_X  => 2,
    INDIRECT_Y  => 2,
    RELATIVE    => 2,
    INDIRECT    => 3,
    ABSOLUTE    => 3,
    ABSOLUTE_X  => 3,
    ABSOLUTE_Y  => 3);

   function SP_To_Address (SP : Data_Types.T_Byte)
   return Data_Types.T_Address is (Stack_Page + SP);

   function Instruction_From_OP_Code (OP : Data_Types.T_Byte)
     return T_Instruction is separate;

   procedure Reset (Cpu : out T_Cpu) is
   begin
      Cpu.Registers.SR := Reset_SR;
      Cpu.Registers.SP := 16#FD#;
      Cpu.Registers.PC := 16#FFFB#;
      Cpu.Registers.A  := 16#00#;
      Cpu.Registers.X  := 16#00#;
      Cpu.Registers.Y  := 16#00#;
      Cpu.Last_Finished_Instruction := (INVALID, NONE, 0);
      Cpu.Current_Instruction := (RESET, NONE, 7);
   end Reset;

   procedure Tick (Cpu : in out T_Cpu;
                   Mem : in out Memory.T_Memory)
   is
      PC_Before_Tick : constant Data_Types.T_Address
        := Cpu.Registers.PC;
   begin
      --  One more cycle
      Cpu.Current_Instruction.Cycles :=
        Cpu.Current_Instruction.Cycles - 1;
      --  Did the current instruction finish?
      if Cpu.Current_Instruction.Cycles = 0 then
         Cpu.Last_Finished_Instruction :=
           Cpu.Current_Instruction;
         --  Perform the instruction
         case Cpu.Current_Instruction.Instruction_Type is
            when RESET =>
               Cpu.Current_Instruction := (JMP, ABSOLUTE, 1);
            when ADC =>
               Operations.Add_With_Carry (Cpu, Mem);
            when ASL =>
               Operations.Shift_Left (Cpu, Mem);
            when AND_I | EOR | ORA =>
               Operations.Logic_Mem_With_A (Cpu, Mem);
            when LDA | LDX | LDY =>
               Operations.Load_Value (Cpu, Mem);
            when STA | STX | STY =>
               Operations.Store_Value (Cpu, Mem);
            when JMP =>
               Operations.Jump (Cpu, Mem);
            when others =>
               raise Invalid_Instruction;
         end case;
         --  Now store the next instruction and finish the tick
         --  If there is still a cycle left, it means an
         --  instruction was added in the processing above
         --  (RESET adds a JMP), so don't do anything
         if Cpu.Current_Instruction.Cycles = 0 then
            --  Move the PC to the next instruction
            --  unless it was changed by the current
            --  instruction (exemple: JMP)
            if Cpu.Registers.PC = PC_Before_Tick then
               Cpu.Registers.PC := Cpu.Registers.PC
                 + To_Next_Instruction
                     (Cpu.Current_Instruction.Addressing);
            end if;
            --  Fetch the new instruction
            Cpu.Current_Instruction :=
              Instruction_From_OP_Code
                (Memory.Read_Byte (Mem, Cpu.Registers.PC));
         end if;
      end if;
   end Tick;

end Cpu;