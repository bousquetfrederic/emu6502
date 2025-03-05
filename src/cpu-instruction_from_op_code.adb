separate (Cpu)
function Instruction_From_OP_Code (OP : Data_Types.T_Byte)
return T_Instruction is
   OP_to_I : constant array (Data_Types.T_Byte)
             of T_Instruction :=
   (
   --  ADC --
   16#69# => (ADC, IMMEDIATE,   2),
   16#65# => (ADC, ZERO_PAGE,   3),
   16#75# => (ADC, ZERO_PAGE_X, 4),
   16#6D# => (ADC, ABSOLUTE,    4),
   16#7D# => (ADC, ABSOLUTE_X,  4),
   16#79# => (ADC, ABSOLUTE_Y,  4),
   16#61# => (ADC, INDIRECT_X,  6),
   16#71# => (ADC, INDIRECT_Y,  5),
   --  AND --
   16#29# => (AND_I, IMMEDIATE,   2),
   16#25# => (AND_I, ZERO_PAGE,   3),
   16#35# => (AND_I, ZERO_PAGE_X, 4),
   16#2D# => (AND_I, ABSOLUTE,    4),
   16#3D# => (AND_I, ABSOLUTE_X,  4),
   16#39# => (AND_I, ABSOLUTE_Y,  4),
   16#21# => (AND_I, INDIRECT_X,  6),
   16#31# => (AND_I, INDIRECT_Y,  5),
   --  ASL --
   16#0A# => (ASL, ACCUMULATOR, 2),
   16#06# => (ASL, ZERO_PAGE,   5),
   16#16# => (ASL, ZERO_PAGE_X, 6),
   16#0E# => (ASL, ABSOLUTE,    6),
   16#1E# => (ASL, ABSOLUTE_X,  6),
   --  BCC --
   16#90# => (BCC, RELATIVE,    2),
   --  BCS --
   16#B0# => (BCS, RELATIVE,    2),
   --  BEQ --
   16#F0# => (BEQ, RELATIVE,    2),
   --  BIT --
   16#24# => (BIT, ZERO_PAGE,   3),
   16#2C# => (BIT, ABSOLUTE,    4),
   --  BMI --
   16#30# => (BMI, RELATIVE,    2),
   --  BNE --
   16#D0# => (BNE, RELATIVE,    2),
   --  BPL --
   16#10# => (BPL, RELATIVE,    2),
   --  BRK --
   16#00# => (BRK, IMPLIED,     7),
   --  BVC --
   16#50# => (BVC, RELATIVE,    2),
   --  BVS --
   16#70# => (BVS, RELATIVE,    2),
   --  CLC --
   16#18# => (CLC, IMPLIED,     2),
   --  CLD --
   16#D8# => (CLD, IMPLIED,     2),
   --  CLI --
   16#58# => (CLI, IMPLIED,     2),
   --  CLV --
   16#B8# => (CLV, IMPLIED,     2),
   --  CMP --
   16#C9# => (CMP, IMMEDIATE,   2),
   16#C5# => (CMP, ZERO_PAGE,   3),
   16#D5# => (CMP, ZERO_PAGE_X, 4),
   16#CD# => (CMP, ABSOLUTE,    4),
   16#DD# => (CMP, ABSOLUTE_X,  4),
   16#D9# => (CMP, ABSOLUTE_Y,  4),
   16#C1# => (CMP, INDIRECT_X,  6),
   16#D1# => (CMP, INDIRECT_Y,  5),
   --  CPX --
   16#E0# => (CPX, IMMEDIATE,   2),
   16#E4# => (CPX, ZERO_PAGE,   3),
   16#EC# => (CPX, ABSOLUTE,    4),
   --  CPY --
   16#C0# => (CPY, IMMEDIATE,   2),
   16#C4# => (CPY, ZERO_PAGE,   3),
   16#CC# => (CPY, ABSOLUTE,    4),
   --  DEC --
   16#C6# => (DEC, ZERO_PAGE,   5),
   16#D6# => (DEC, ZERO_PAGE_X, 6),
   16#CE# => (DEC, ABSOLUTE,    6),
   16#DE# => (DEC, ABSOLUTE_X,  7),
   --  DEX --
   16#CA# => (DEX, X,           2),
   --  DEY --
   16#88# => (DEY, Y,           2),
   --  EOR --
   16#49# => (EOR, IMMEDIATE,   2),
   16#45# => (EOR, ZERO_PAGE,   3),
   16#55# => (EOR, ZERO_PAGE_X, 4),
   16#4D# => (EOR, ABSOLUTE,    4),
   16#5D# => (EOR, ABSOLUTE_X,  4),
   16#59# => (EOR, ABSOLUTE_Y,  4),
   16#41# => (EOR, INDIRECT_X,  6),
   16#51# => (EOR, INDIRECT_Y,  5),
   --  INC --
   16#E6# => (INC, ZERO_PAGE,   5),
   16#F6# => (INC, ZERO_PAGE_X, 6),
   16#EE# => (INC, ABSOLUTE,    6),
   16#FE# => (INC, ABSOLUTE_X,  7),
   --  INX --
   16#E8# => (INX, X,           2),
   --  INY --
   16#C8# => (INY, Y,           2),
   --  JMP --
   16#4C# => (JMP, ABSOLUTE,    3),
   16#6C# => (JMP, INDIRECT,    5),
   --  JSR --
   16#20# => (JSR, ABSOLUTE,    6),
   --  LDA --
   16#A9# => (LDA, IMMEDIATE,   2),
   16#A5# => (LDA, ZERO_PAGE,   3),
   16#B5# => (LDA, ZERO_PAGE_X, 4),
   16#AD# => (LDA, ABSOLUTE,    4),
   16#BD# => (LDA, ABSOLUTE_X,  4),
   16#B9# => (LDA, ABSOLUTE_Y,  4),
   16#A1# => (LDA, INDIRECT_X,  6),
   16#B1# => (LDA, INDIRECT_Y,  5),
   --  LDX --
   16#A2# => (LDX, IMMEDIATE,   2),
   16#A6# => (LDX, ZERO_PAGE,   3),
   16#B6# => (LDX, ZERO_PAGE_Y, 4),
   16#AE# => (LDX, ABSOLUTE,    4),
   16#BE# => (LDX, ABSOLUTE_Y,  4),
   --  LDY --
   16#A0# => (LDY, IMMEDIATE,   2),
   16#A4# => (LDY, ZERO_PAGE,   3),
   16#B4# => (LDY, ZERO_PAGE_X, 4),
   16#AC# => (LDY, ABSOLUTE,    4),
   16#BC# => (LDY, ABSOLUTE_X,  4),
   --  LSR --
   16#4A# => (LSR, ACCUMULATOR, 2),
   16#46# => (LSR, ZERO_PAGE,   5),
   16#56# => (LSR, ZERO_PAGE_X, 6),
   16#4E# => (LSR, ABSOLUTE,    6),
   16#5E# => (LSR, ABSOLUTE_X,  7),
   --  NOP --
   16#EA# => (NOP, IMPLIED,     2),
   --  ORA --
   16#09# => (ORA, IMMEDIATE,   2),
   16#05# => (ORA, ZERO_PAGE,   3),
   16#15# => (ORA, ZERO_PAGE_X, 4),
   16#0D# => (ORA, ABSOLUTE,    4),
   16#1D# => (ORA, ABSOLUTE_X,  4),
   16#19# => (ORA, ABSOLUTE_Y,  4),
   16#01# => (ORA, INDIRECT_X,  6),
   16#11# => (ORA, INDIRECT_Y,  5),
   --  PHA --
   16#48# => (PHA, IMPLIED,     3),
   --  PHP --
   16#08# => (PHP, IMPLIED,     3),
   --  PLA --
   16#68# => (PLA, IMPLIED,     4),
   --  PLP --
   16#28# => (PLP, IMPLIED,     4),
   --  ROL --
   16#2A# => (ROL, ACCUMULATOR, 2),
   16#26# => (ROL, ZERO_PAGE,   5),
   16#36# => (ROL, ZERO_PAGE_X, 6),
   16#2E# => (ROL, ABSOLUTE,    6),
   16#3E# => (ROL, ABSOLUTE_X,  7),
   --  ROR --
   16#6A# => (ROR, ACCUMULATOR, 2),
   16#66# => (ROR, ZERO_PAGE,   5),
   16#76# => (ROR, ZERO_PAGE_X, 6),
   16#6E# => (ROR, ABSOLUTE,    6),
   16#7E# => (ROR, ABSOLUTE_X,  7),
   --  RTI --
   16#40# => (RTI, IMPLIED,     6),
   --  RTS --
   16#60# => (RTS, IMPLIED,     6),
   --  SBC --
   16#E9# => (SBC, IMMEDIATE,   2),
   16#E5# => (SBC, ZERO_PAGE,   3),
   16#F5# => (SBC, ZERO_PAGE_X, 4),
   16#ED# => (SBC, ABSOLUTE,    4),
   16#FD# => (SBC, ABSOLUTE_X,  4),
   16#F9# => (SBC, ABSOLUTE_Y,  4),
   16#E1# => (SBC, INDIRECT_X,  6),
   16#F1# => (SBC, INDIRECT_Y,  5),
   --  SEC --
   16#38# => (SEC, IMPLIED,     2),
   --  SED --
   16#F8# => (SED, IMPLIED,     2),
   --  SEI --
   16#78# => (SEI, IMPLIED,     2),
   --  STA --
   16#85# => (STA, ZERO_PAGE,   3),
   16#95# => (STA, ZERO_PAGE_X, 4),
   16#8D# => (STA, ABSOLUTE,    4),
   16#9D# => (STA, ABSOLUTE_X,  5),
   16#99# => (STA, ABSOLUTE_Y,  5),
   16#81# => (STA, INDIRECT_X,  6),
   16#91# => (STA, INDIRECT_Y,  6),
   --  STX --
   16#86# => (STX, ZERO_PAGE,   3),
   16#96# => (STX, ZERO_PAGE_Y, 4),
   16#8E# => (STX, ABSOLUTE,    4),
   --  STY --
   16#84# => (STY, ZERO_PAGE,   3),
   16#94# => (STY, ZERO_PAGE_X, 4),
   16#8C# => (STY, ABSOLUTE,    4),
   --  TAX --
   16#AA# => (TAX, IMPLIED,     2),
   --  TAY --
   16#A8# => (TAY, IMPLIED,     2),
   --  TSX --
   16#BA# => (TSX, IMPLIED,     2),
   --  TXA --
   16#8A# => (TXA, IMPLIED,     2),
   --  TXS --
   16#9A# => (TXS, IMPLIED,     2),
   --  TYA --
   16#98# => (TYA, IMPLIED,     2),
   --  JAM KILL THE CPU --
   16#02# | 16#12# | 16#22# | 16#32# | 16#42# |
   16#52# | 16#62# | 16#72# | 16#92# | 16#B2# |
   16#D2# | 16#F2#  => (KILL, NONE, 1),
   --  Invalid --
   others => (INVALID, NONE,    1)
   );
begin
   return OP_to_I (OP);
end Instruction_From_OP_Code;