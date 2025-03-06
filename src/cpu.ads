--  As per https://www.masswerk.at/6502/6502_instruction_set.html
with Ada.Text_IO;
with Data_Bus;
with Data_Types;
with Debug;

package Cpu is

   type T_Cpu is limited private;

   Invalid_Instruction : exception;
   Cpu_Was_Killed      : exception;

   function Clock_Counter (Proc : T_Cpu)
     return Data_Types.T_Clock_Counter;

   procedure Interrupt (Proc     : in out T_Cpu;
                        Maskable :        Boolean);

   procedure Reset (Proc : out T_Cpu);

   procedure Tick
     (Proc            : in out T_Cpu;
      Bus             : in out Data_Bus.T_Data_Bus;
      New_Instruction :    out Boolean);

   procedure Set_Debug (Proc      : in out T_Cpu;
                        Debugging :        Debug.T_Debug);

private

   type T_SR is
   record
      C : Boolean := False;
      Z : Boolean := False;
      I : Boolean := False;
      D : Boolean := False;
      B : Boolean := False;
      U : Boolean := True;
      V : Boolean := False;
      N : Boolean := False;
   end record;

   for T_SR use record
      C at 0 range 0 .. 0;
      Z at 0 range 1 .. 1;
      I at 0 range 2 .. 2;
      D at 0 range 3 .. 3;
      B at 0 range 4 .. 4;
      U at 0 range 5 .. 5;
      V at 0 range 6 .. 6;
      N at 0 range 7 .. 7;
   end record;

   type T_Registers is
   record
      A    : Data_Types.T_Byte;            --  Accumulator
      X, Y : Data_Types.T_Byte;
      SP   : Data_Types.T_Byte := 16#FD#;  --  Stack Pointer
      SR   : T_SR;                         --  Status
      PC   : Data_Types.T_Address;         --  Program Counter
   end record;

   type T_Cycle_Number is range 0 .. 7;

   subtype T_Address_Increment is
           Data_Types.T_Address range 0 .. 3;

   type T_Addressing_Types is
   (NONE,
    IMPLIED,
    RELATIVE,
    ACCUMULATOR, X, Y,
    IMMEDIATE,
    ABSOLUTE,    ABSOLUTE_X,  ABSOLUTE_Y,
    ZERO_PAGE,   ZERO_PAGE_X, ZERO_PAGE_Y,
    INDIRECT,    INDIRECT_X,  INDIRECT_Y
    );

   subtype T_Valid_Addressing_Types is
     T_Addressing_Types range IMPLIED .. INDIRECT_Y;

   subtype T_Addressing_Types_To_Fetch_Bytes is
     T_Addressing_Types range ACCUMULATOR .. INDIRECT_Y;

   type T_Instruction_Types is
   (INVALID,
    KILL,
    RESET,
    IRQ,
    NMI,
    BRANCH,
    ADC, AND_I, ASL,
    BCC, BCS, BEQ, BIT, BMI, BNE, BPL, BRK, BVC, BVS,
    CLC, CLD, CLI, CLV, CMP, CPX, CPY, DEC, DEX, DEY,
    EOR,
    INC, INX, INY,
    JMP, JSR,
    LDA, LDX, LDY, LSR,
    NOP,
    ORA,
    PHA, PHP, PLA, PLP,
    ROL, ROR, RTI, RTS,
    SBC, SEC, SED, SEI, STA, STX, STY,
    TAX, TAY, TSX, TXA, TXS, TYA);

   type T_Instruction is
   record
      Instruction_Type : T_Instruction_Types;
      Addressing       : T_Addressing_Types;
      Cycle            : T_Cycle_Number;
   end record;

   type T_Interrupt is (NONE, IRQ, NMI);

   use type Data_Types.T_Clock_Counter;

   type T_Cpu is
   record
      Registers : T_Registers;
      Clock_Counter : Data_Types.T_Clock_Counter := 0;
      Current_Instruction : T_Instruction
        := (RESET, NONE, 7);
      Interrupt : T_Interrupt := NONE;
      Debugging : Debug.T_Debug;
   end record;

   function Instruction_From_OP_Code (OP : Data_Types.T_Byte)
     return T_Instruction;

end Cpu;