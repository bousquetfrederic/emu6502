with Cpu.Status_Register;
with Cpu.Bit_Test;

package body Cpu.Arithmetic is

   function Is_Overflown
     (Value_1 :        Data_Types.T_Byte;
      Value_2 :        Data_Types.T_Byte;
      Result  :        Data_Types.T_Byte)
   return Boolean
   is
      S_Val_1  : constant Boolean := Bit_Test.Bit_X_Is_Set (Value_1, 7);
      S_Val_2  : constant Boolean := Bit_Test.Bit_X_Is_Set (Value_2, 7);
      S_Result : constant Boolean := Bit_Test.Bit_X_Is_Set (Result, 7);
   begin
      return (S_Val_1 and S_Val_2 and not S_Result)
              or else
             (not S_Val_1 and not S_Val_2 and S_Result);
   end Is_Overflown;

   procedure Shift_Or_Rotate_Right
     (Value        :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Is_Rotate    :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Zero         : out Boolean)
   is
      use type Data_Types.T_Byte;
      Bit_7_After : Data_Types.T_Byte := 0;
   begin
      if Is_Rotate and then Carry_Before then
         --  ROR puts the Carry into the
         --  bit 7 of the result.
         --  LSR puts zero.
         Bit_7_After := 2#10000000#;
      end if;
      Result := (Value / 2#10#) or Bit_7_After;
      Carry_After := Bit_Test.Bit_X_Is_Set (Value, 0);
      Negative := Bit_Test.Bit_X_Is_Set (Result, 7);
      Zero := Data_Types.Is_Zero (Result);
   end Shift_Or_Rotate_Right;

   procedure Shift_Or_Rotate_Left
     (Value        :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Is_Rotate    :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Zero         : out Boolean)
   is
      use type Data_Types.T_Byte;
      use type Data_Types.T_9_Bits;
      Shifted : constant Data_Types.T_9_Bits
        := Data_Types.T_9_Bits (Value) * 2#10#;
      Shifted_8_Bits : Data_Types.T_Byte
        := Data_Types.T_Byte (Shifted and 2#011111111#);
   begin
      --  If it's a ROTATE not a SHIFT
      --  add the Carry in bit 0
      if Is_Rotate then
         Shifted_8_Bits
           := Shifted_8_Bits
              + Status_Register.C_As_Byte (Carry_Before);
      end if;
      Result := Shifted_8_Bits;
      Carry_After := Bit_Test.Bit_8_Is_Set (Shifted);
      Negative := Bit_Test.Bit_X_Is_Set (Shifted_8_Bits, 7);
      Zero     := Data_Types.Is_Zero (Shifted_8_Bits);
   end Shift_Or_Rotate_Left;

   procedure Add_With_Carry
     (Value_1      :     Data_Types.T_Byte;
      Value_2      :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Overflow     : out Boolean;
      Zero         : out Boolean)
   is
      use type Data_Types.T_9_Bits;
      Total : constant Data_Types.T_9_Bits
        := Value_1 + Value_2
             + Status_Register.C_As_Byte (Carry_Before);
      Total_8_Bits : constant Data_Types.T_Byte
        := Data_Types.T_Byte (Total and 2#011111111#);
   begin
      Carry_After := Bit_Test.Bit_8_Is_Set (Total);
      Overflow := Is_Overflown (Value_1, Value_2, Total_8_Bits);
      Negative := Bit_Test.Bit_X_Is_Set (Total_8_Bits, 7);
      Zero     := Data_Types.Is_Zero (Total_8_Bits);
      Result := Total_8_Bits;
   end Add_With_Carry;

   --  From http://www.6502.org/tutorials/decimal_mode.html
   procedure Decimal_Add_With_Carry
     (Value_1      :     Data_Types.T_Byte;
      Value_2      :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Overflow     : out Boolean;
      Zero         : out Boolean)
   is

      function Low_Digit (Value : Data_Types.T_Byte)
      return Data_Types.T_9_Bits
      is
         use type Data_Types.T_Byte;
      begin
         return Data_Types.T_9_Bits (Value and 16#F#);
      end Low_Digit;

      function High_Digit (Value : Data_Types.T_Byte)
      return Data_Types.T_9_Bits
      is
         use type Data_Types.T_Byte;
      begin
         return Data_Types.T_9_Bits (Value and 16#F0#);
      end High_Digit;

      use type Data_Types.T_Byte;
      use type Data_Types.T_9_Bits;
      Carry_Before_As_9_Bits : Data_Types.T_9_Bits;
      Low_Digit_Result       : Data_Types.T_9_Bits;
      Full_Result            : Data_Types.T_9_Bits;
   begin
      if Carry_Before then
         Carry_Before_As_9_Bits := 1;
      else
         Carry_Before_As_9_Bits := 0;
      end if;
      Low_Digit_Result := Low_Digit (Value_1)
                          + Low_Digit (Value_2)
                          + Carry_Before_As_9_Bits;
      if Low_Digit_Result >= 10 then
         Low_Digit_Result := ((Low_Digit_Result
                               + Data_Types.T_9_Bits (6))
                              and 16#F#)
                             + Data_Types.T_9_Bits (16#10#);
      end if;
      Full_Result := High_Digit (Value_1)
                     + High_Digit (Value_2)
                     + Low_Digit_Result;
      if Full_Result >= 16#A0# then
         Full_Result := Full_Result + Data_Types.T_9_Bits (16#60#);
      end if;
      Result      := Data_Types.T_Byte (Full_Result and 2#011111111#);
      Carry_After := Full_Result > 16#100#;
      Zero        := Result = 0;
      Overflow    := False;
      Negative    := False;
   end Decimal_Add_With_Carry;

   procedure Substract_With_Carry
     (Value_1      :     Data_Types.T_Byte;
      Value_2      :     Data_Types.T_Byte;
      Carry_Before :     Boolean;
      Result       : out Data_Types.T_Byte;
      Carry_After  : out Boolean;
      Negative     : out Boolean;
      Overflow     : out Boolean;
      Zero         : out Boolean)
   is

      function Opposite_Of (B : Data_Types.T_Byte)
      return Data_Types.T_Byte
      is
         use type Data_Types.T_Byte;
      begin
         return (B xor 2#11111111#);
      end Opposite_Of;

   begin
      Add_With_Carry
        (Value_1      => Value_1,
         Value_2      => Opposite_Of (Value_2),
         Carry_Before => Carry_Before,
         Result       => Result,
         Carry_After  => Carry_After,
         Negative     => Negative,
         Overflow     => Overflow,
         Zero         => Zero);
   end Substract_With_Carry;

end Cpu.Arithmetic;