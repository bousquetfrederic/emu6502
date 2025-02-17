--  As per https://www.masswerk.at/6502/6502_instruction_set.html
with Memory;
with Data_Types;

package Cpu is

   type T_Cpu is limited private;

   Invalid_Instruction : exception;

   procedure Reset (Cpu : out T_Cpu);

   procedure Tick (Cpu    : in out T_Cpu;
                   Mem    : in out Memory.T_Memory);

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

   type T_Clock_Counter is mod 2**16;

   type T_Cycle_Number is range 0 .. 7;

   subtype T_Address_Increment is
           Data_Types.T_Address range 1 .. 3;

   type T_Addressing_Types is
   (NONE,
    IMPLIED,
    RELATIVE,
    ACCUMULATOR,
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
    RESET,
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
      Cycles           : T_Cycle_Number;
   end record;

   type T_Cpu is
   record
      Registers : T_Registers;
      Clock_Counter : T_Clock_Counter := 0;
      Last_Finished_Instruction : T_Instruction
        := (INVALID, NONE, 0);
      Current_Instruction : T_Instruction
        := (RESET, NONE, 7);
   end record;

end Cpu;