with Cpu;
with Cpu.Operations;
with Cpu.Logging;
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
    X           => 1,
    Y           => 1,
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
      Proc.Current_Instruction := (RESET, NONE, 7);
   end Reset;

   procedure Tick (Proc : in out T_Cpu;
                   Mem  : in out Memory.T_Memory)
   is
      PC_Before_Tick : constant Data_Types.T_Address
        := Proc.Registers.PC;
   begin
      Proc.Clock_Counter := Proc.Clock_Counter + 1;
      Logging.Dump_Clock_Counter (Proc);
      --  One more cycle
      Proc.Current_Instruction.Cycles :=
        Proc.Current_Instruction.Cycles - 1;
      --  Did the current instruction finish?
      if Proc.Current_Instruction.Cycles = 0 then
         --  Perform the instruction
         case Proc.Current_Instruction.Instruction_Type is
            when KILL =>
               raise Cpu_Was_Killed;
            when RESET =>
               Operations.Change_Instruction
                 (Proc, (JMP, ABSOLUTE, 1));
            when BRANCH =>
               --  This is just to way for extra cycles
               --  after a Branch instruction.
               --  PC has already been changed
               null;
            when ADC =>
               Operations.Add_With_Carry (Proc, Mem);
            when ASL | LSR | ROL | ROR =>
               Operations.Shift_Or_Rotate (Proc, Mem);
            when AND_I | EOR | ORA =>
               Operations.Logic_Mem_With_A (Proc, Mem);
            when BCC | BCS | BEQ | BMI |
                 BNE | BPL | BVC | BVS =>
               Operations.Branch (Proc, Mem);
            when BIT =>
               Operations.Bit_Mem_With_A (Proc, Mem);
            when CLC | CLD | CLI | CLV =>
               Operations.Clear_SR (Proc);
            when CMP | CPX | CPY =>
               Operations.Compare (Proc, Mem);
            when DEC | DEX | DEY =>
               Operations.Decrement (Proc, Mem);
            when LDA | LDX | LDY =>
               Operations.Load_Value (Proc, Mem);
            when INC | INX | INY =>
               Operations.Increment (Proc, Mem);
            when JMP | JSR =>
               Operations.Jump (Proc, Mem, Stack_Page);
            when PHA | PHP =>
               Operations.Push (Proc, Mem, Stack_Page);
            when PLA | PLP =>
               Operations.Pull (Proc, Mem, Stack_Page);
            when STA | STX | STY =>
               Operations.Store_Value (Proc, Mem);
            when SBC =>
               Operations.Substract_with_Carry (Proc, Mem);
            when SEC | SED | SEI =>
               Operations.Set_SR (Proc);
            when TAX | TAY | TSX | TXA | TXS | TYA =>
               Operations.Transfer (Proc);
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