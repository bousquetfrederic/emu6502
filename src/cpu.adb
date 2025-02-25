with Cpu;
with Cpu.Operations;
with Cpu.Logging;
with Data_Types;
use type Data_Types.T_Address;

package body Cpu is

   function Clock_Counter (Proc : T_Cpu) return Natural
   is (Natural (Proc.Clock_Counter));

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

   procedure Interrupt (Proc     : in out T_Cpu;
                        Maskable :        Boolean) is
   begin
      if Maskable then
         Proc.Interrupt := IRQ;
      else
         Proc.Interrupt := NMI;
      end if;
   end Interrupt;

   procedure Reset (Proc : out T_Cpu) is
   begin
      Proc.Registers.SR := Reset_SR;
      Proc.Registers.SP := 16#FD#;
      Proc.Registers.PC := 16#FFFB#;
      Proc.Registers.A  := 16#00#;
      Proc.Registers.X  := 16#00#;
      Proc.Registers.Y  := 16#00#;
      Proc.Clock_Counter := 0;
      Proc.Current_Instruction := (RESET, NONE, 7);
   end Reset;

   procedure Tick (Proc : in out T_Cpu;
                   Bus  : in out Data_Bus.T_Data_Bus)
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
            when IRQ =>
               Operations.Interrupt (Proc, Bus, 16#FFFE#, Stack_Page);
            when NMI =>
               Operations.Interrupt (Proc, Bus, 16#FFFA#, Stack_Page);
            when ADC =>
               Operations.Add_With_Carry (Proc, Bus);
            when ASL | LSR | ROL | ROR =>
               Operations.Shift_Or_Rotate (Proc, Bus);
            when AND_I | EOR | ORA =>
               Operations.Logic_Mem_With_A (Proc, Bus);
            when BCC | BCS | BEQ | BMI |
                 BNE | BPL | BVC | BVS =>
               Operations.Branch (Proc, Bus);
            when BIT =>
               Operations.Bit_Mem_With_A (Proc, Bus);
            when BRK =>
               Operations.Interrupt (Proc, Bus, 16#FFFE#, Stack_Page);
            when CLC | CLD | CLI | CLV =>
               Operations.Clear_SR (Proc);
            when CMP | CPX | CPY =>
               Operations.Compare (Proc, Bus);
            when DEC | DEX | DEY =>
               Operations.Decrement (Proc, Bus);
            when LDA | LDX | LDY =>
               Operations.Load_Value (Proc, Bus);
            when INC | INX | INY =>
               Operations.Increment (Proc, Bus);
            when JMP | JSR =>
               Operations.Jump (Proc, Bus, Stack_Page);
            when NOP =>
               null;
            when PHA | PHP =>
               Operations.Push (Proc, Bus, Stack_Page);
            when PLA | PLP =>
               Operations.Pull (Proc, Bus, Stack_Page);
            when RTI =>
               Operations.Return_From_Interrupt (Proc, Bus, Stack_Page);
            when RTS =>
               Operations.Return_From_Sub (Proc, Bus, Stack_Page);
            when STA | STX | STY =>
               Operations.Store_Value (Proc, Bus);
            when SBC =>
               Operations.Substract_with_Carry (Proc, Bus);
            when SEC | SED | SEI =>
               Operations.Set_SR (Proc);
            when TAX | TAY | TSX | TXA | TXS | TYA =>
               Operations.Transfer (Proc);
            when others =>
               raise Invalid_Instruction
                 with Proc.Current_Instruction.Instruction_Type'Image;
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
            --  If there was an interrupt during the
            --  processing of the instruction,
            --  now perform the interrupt.
            --  (only 6 cycles because we'll add a
            --  JMP with one cycle when processing
            --  the interrupt)
            if Proc.Interrupt = NMI then
               Proc.Interrupt := NONE;
               Operations.Change_Instruction
                 (Proc, (NMI, IMPLIED, 6));
            elsif Proc.Interrupt = IRQ
                  and then not Proc.Registers.SR.I
            then
               Proc.Interrupt := NONE;
               Operations.Change_Instruction
                 (Proc, (IRQ, IMPLIED, 6));
            else
               --  No interrupt occured during last instruction,
               --  but perhaps an IRQ was masked, so we need to
               --  clear it.
               Proc.Interrupt := NONE;
               --  Fetch the new instruction
               Operations.Change_Instruction
                 (Proc,
                  Instruction_From_OP_Code
                    (Data_Bus.Read_Byte (Bus, Proc.Registers.PC)));
            end if;
         end if;
      end if;
   end Tick;

end Cpu;