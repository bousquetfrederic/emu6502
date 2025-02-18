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

   To_Next_Instruction : constant array (T_Addressing_Types)
     of T_Address_Increment :=
   (NONE        => 0,
    ACCUMULATOR => 1,
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

   procedure Reset (Proc : out T_Cpu) is
   begin
      Proc.Registers.SR := Reset_SR;
      Proc.Registers.SP := 16#FD#;
      Proc.Registers.PC := 16#FFFB#;
      Proc.Registers.A  := 16#00#;
      Proc.Registers.X  := 16#00#;
      Proc.Registers.Y  := 16#00#;
      Proc.Last_Finished_Instruction := (INVALID, NONE, 0);
      Proc.Current_Instruction := (RESET, NONE, 7);
   end Reset;

   procedure Tick (Proc : in out T_Cpu;
                   Mem  : in out Memory.T_Memory)
   is
      PC_Before_Tick : constant Data_Types.T_Address
        := Proc.Registers.PC;
   begin
      --  One more cycle
      Proc.Current_Instruction.Cycles :=
        Proc.Current_Instruction.Cycles - 1;
      --  Did the current instruction finish?
      if Proc.Current_Instruction.Cycles = 0 then
         Proc.Last_Finished_Instruction :=
           Proc.Current_Instruction;
         --  Perform the instruction
         case Proc.Current_Instruction.Instruction_Type is
            when KILL =>
               raise Cpu_Was_Killed;
            when RESET =>
               Proc.Current_Instruction := (JMP, ABSOLUTE, 1);
            when BRANCH =>
               --  This is just to way for extra cycles
               --  after a Branch instruction.
               --  PC has already been changed
               null;
            when ADC =>
               Operations.Add_With_Carry (Proc, Mem);
            when ASL | ROL =>
               Operations.Shift_Or_Rotate_Left (Proc, Mem);
            when AND_I | EOR | ORA =>
               Operations.Logic_Mem_With_A (Proc, Mem);
            when BCC | BCS | BEQ | BMI |
                 BNE | BPL | BVC | BVS =>
               Operations.Branch (Proc, Mem);
            when LDA | LDX | LDY =>
               Operations.Load_Value (Proc, Mem);
            when STA | STX | STY =>
               Operations.Store_Value (Proc, Mem);
            when JMP =>
               Operations.Jump (Proc, Mem);
            when others =>
               raise Invalid_Instruction;
         end case;
         --  Now store the next instruction and finish the tick
         --  If there is still a cycle left, it means an
         --  instruction was added in the processing above
         --  (RESET adds a JMP), so don't do anything
         if Proc.Current_Instruction.Cycles = 0 then
            --  Move the PC to the next instruction
            --  unless it was changed by the current
            --  instruction (exemple: JMP)
            if Proc.Registers.PC = PC_Before_Tick then
               Proc.Registers.PC := Proc.Registers.PC
                 + To_Next_Instruction
                     (Proc.Current_Instruction.Addressing);
            end if;
            --  Fetch the new instruction
            Operations.Change_Instruction
              (Proc,
               Instruction_From_OP_Code
                (Memory.Read_Byte (Mem, Proc.Registers.PC)));
         end if;
      end if;
   end Tick;

end Cpu;