with Data_Types;
private package Cpu.Arithmetic is

   procedure Add_With_Carry
     (Value_1      :     Data_Types.T_Byte;
      Value_2      :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Overflow     : out Boolean;
      Zero         : out Boolean);

   procedure Shift_Or_Rotate_Left
     (Value        :   Data_Types.T_Byte;
      Carry_Before :   Boolean;
      Is_Rotate    :   Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Zero         : out Boolean);

   procedure Shift_Or_Rotate_Right
     (Value        :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Is_Rotate    :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Zero         : out Boolean);

   procedure Substract_With_Carry
     (Value_1      :     Data_Types.T_Byte;
      Value_2      :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Overflow     : out Boolean;
      Zero         : out Boolean);

end Cpu.Arithmetic;