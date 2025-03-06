with Data_Types;
with Cpu.Arithmetic;
with Cpu.Bit_Test;
with Cpu.Data_Access;
with Cpu.Logging;
with Cpu.Status_Register;

package body Cpu.Operations is

   procedure Set_N_And_Z
        (Value    :     Data_Types.T_Byte;
         Negative : out Boolean;
         Zero     : out Boolean)
   is
   begin
      Negative := Bit_Test.Bit_X_Is_Set (Value, 7);
      Zero     := Data_Types.Is_Zero (Value);
   end Set_N_And_Z;

   procedure Change_Instruction
     (Proc       : in out T_Cpu;
      I          :        T_Instruction) is
   begin
      if Proc.Current_Instruction.Addressing /= NONE
      then
         Logging.Dump_Current_Instruction (Proc);
         Logging.Dump_Registers (Proc);
      end if;
      Proc.Current_Instruction := I;
   end Change_Instruction;

   procedure Branch
     (Proc       : in out T_Cpu;
      Bus        :        Data_Bus.T_Data_Bus)
   is
      use all type Data_Access.T_Location_Kind;
      Where_To  : Data_Access.T_Location;
      Condition : Boolean;
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when BCC =>
            Condition := not Proc.Registers.SR.C;
         when BCS =>
            Condition := Proc.Registers.SR.C;
         when BEQ =>
            Condition := Proc.Registers.SR.Z;
         when BMI =>
            Condition := Proc.Registers.SR.N;
         when BNE =>
            Condition := not Proc.Registers.SR.Z;
         when BPL =>
            Condition := not Proc.Registers.SR.N;
         when BVC =>
            Condition := not Proc.Registers.SR.V;
         when BVS =>
            Condition := Proc.Registers.SR.V;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Proc.Current_Instruction.Instruction_Type'Image;
      end case;
      if Condition then
         Where_To := Data_Access.Addressing_Points_To
           (Addressing_Type => Proc.Current_Instruction.Addressing,
            Bus             => Bus,
            Registers       => Proc.Registers);
         if Where_To.Kind = L_ACCUMULATOR
         then
            raise Cpu_Internal_Wrong_Operation;
         end if;
         declare
            New_Instruction : T_Instruction;
         begin
            New_Instruction.Instruction_Type := BRANCH;
            New_Instruction.Addressing := NONE;
            if Data_Access.Addresses_On_Same_Page
                 (Proc.Registers.PC, Where_To.Address)
            then
               New_Instruction.Cycle := 1;
            else
               New_Instruction.Cycle := 2;
            end if;
            Proc.Registers.PC := Where_To.Address;
            Change_Instruction (Proc, New_Instruction);
         end;
      end if;
   end Branch;

   procedure Pull
     (Proc       : in out T_Cpu;
      Bus        : in out Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address)
   is
      Value : Data_Types.T_Byte;
   begin
      Data_Access.Pull_Byte
        (Bus        => Bus,
         Registers  => Proc.Registers,
         Value      => Value,
         Stack_Page => Stack_Page);
      case Proc.Current_Instruction.Instruction_Type is
         when PLA =>
            Proc.Registers.A := Value;
            Set_N_And_Z (Value    => Proc.Registers.A,
                         Negative => Proc.Registers.SR.N,
                         Zero     => Proc.Registers.SR.Z);
         when PLP =>
            --  Keep Break flag and bit 5
            --  Pull the rest
            declare
               Tmp_SR : constant T_SR :=
                 Status_Register.Byte_As_SR (Value);
            begin
               Proc.Registers.SR :=
                 (C => Tmp_SR.C,
                  Z => Tmp_SR.Z,
                  I => Tmp_SR.I,
                  D => Tmp_SR.D,
                  B => Proc.Registers.SR.B,
                  U => Proc.Registers.SR.U,
                  V => Tmp_SR.V,
                  N => Tmp_SR.N);
            end;
         when others =>
            raise Cpu_Internal_Wrong_Operation;
      end case;
   end Pull;

   procedure Push
     (Proc       : in out T_Cpu;
      Bus        : in out Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address)
   is
      use type Data_Types.T_Byte;
      Value : Data_Types.T_Byte;
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when PHA =>
            Value := Proc.Registers.A;
         when PHP =>
            Value := Status_Register.SR_As_Byte
                      (Proc.Registers.SR)
                     or 2#00010000#;  --  Break flag
         when others =>
            raise Cpu_Internal_Wrong_Operation;
      end case;
      Data_Access.Push_Byte
        (Bus        => Bus,
         Registers  => Proc.Registers,
         Value      => Value,
         Stack_Page => Stack_Page);
   end Push;

   procedure Return_From_Interrupt
     (Proc       : in out T_Cpu;
      Bus        :        Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address)
   is
      Tmp_SR_As_Byte : Data_Types.T_Byte;
      Tmp_SR         : T_SR;
      Tmp_PC         : Data_Types.T_Address;
   begin
      Data_Access.Pull_Byte
        (Bus        => Bus,
         Registers  => Proc.Registers,
         Value      => Tmp_SR_As_Byte,
         Stack_Page => Stack_Page);
      Tmp_SR := Status_Register.Byte_As_SR (Tmp_SR_As_Byte);
      Proc.Registers.SR :=
       (C => Tmp_SR.C,
        Z => Tmp_SR.Z,
        I => Tmp_SR.I,
        D => Tmp_SR.D,
        B => Proc.Registers.SR.B,
        U => Proc.Registers.SR.U,
        V => Tmp_SR.V,
        N => Tmp_SR.N);
      Data_Access.Pull_Address
        (Bus        => Bus,
         Registers  => Proc.Registers,
         Value      => Tmp_PC,
         Stack_Page => Stack_Page);
      Proc.Registers.PC := Tmp_PC;
   end Return_From_Interrupt;

   procedure Return_From_Sub
     (Proc       : in out T_Cpu;
      Bus        :        Data_Bus.T_Data_Bus;
      Stack_Page :        Data_Types.T_Address)
   is
      use type Data_Types.T_Address;
      Tmp_PC : Data_Types.T_Address;
   begin
      Data_Access.Pull_Address
        (Bus        => Bus,
         Registers  => Proc.Registers,
         Value      => Tmp_PC,
         Stack_Page => Stack_Page);
      Proc.Registers.PC := Tmp_PC + Data_Types.One_Byte;
   end Return_From_Sub;

   procedure Clear_SR
     (Proc : in out T_Cpu) is
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when CLC =>
            Proc.Registers.SR.C := False;
         when CLD =>
            Proc.Registers.SR.D := False;
         when CLI =>
            Proc.Registers.SR.I := False;
         when CLV =>
            Proc.Registers.SR.V := False;
         when others =>
            raise Cpu_Internal_Wrong_Operation;
      end case;
   end Clear_SR;

   procedure Set_SR
     (Proc : in out T_Cpu) is
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when SEC =>
            Proc.Registers.SR.C := True;
         when SED =>
            Proc.Registers.SR.D := True;
         when SEI =>
            Proc.Registers.SR.I := True;
         when others =>
            raise Cpu_Internal_Wrong_Operation;
      end case;
   end Set_SR;

   procedure Shift_Or_Rotate
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus)
   is
      Where_Is_Data : constant Data_Access.T_Location
        := Data_Access.Addressing_Points_To
             (Addressing_Type => Proc.Current_Instruction.Addressing,
              Bus             => Bus,
              Registers       => Proc.Registers);
      Shifted_8_Bits : Data_Types.T_Byte;
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when ASL | ROL =>
            Arithmetic.Shift_Or_Rotate_Left
             (Value        =>
              Data_Access.Fetch_Byte
               (Location  => Where_Is_Data,
                Bus       => Bus,
                Registers => Proc.Registers),
               Carry_Before => Proc.Registers.SR.C,
               Is_Rotate    => Proc.Current_Instruction.Instruction_Type = ROL,
               Result       => Shifted_8_Bits,
               Carry_After  => Proc.Registers.SR.C,
               Negative     => Proc.Registers.SR.N,
               Zero         => Proc.Registers.SR.Z);
         when LSR | ROR =>
            Arithmetic.Shift_Or_Rotate_Right
             (Value        =>
              Data_Access.Fetch_Byte
               (Location  => Where_Is_Data,
                Bus       => Bus,
                Registers => Proc.Registers),
               Carry_Before => Proc.Registers.SR.C,
               Is_Rotate    => Proc.Current_Instruction.Instruction_Type = ROR,
               Result       => Shifted_8_Bits,
               Carry_After  => Proc.Registers.SR.C,
               Negative     => Proc.Registers.SR.N,
               Zero         => Proc.Registers.SR.Z);
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Proc.Current_Instruction.Instruction_Type'Image;
      end case;
      Data_Access.Store_Byte
        (Location  => Where_Is_Data,
         Bus       => Bus,
         Registers => Proc.Registers,
         Value     => Shifted_8_Bits);
   end Shift_Or_Rotate;

   procedure Subtract_with_Carry
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus)
   is
   begin
      if Proc.Registers.SR.D then
         Arithmetic.Decimal_Subtract_With_Carry
           (Value_1      => Proc.Registers.A,
            Value_2      =>
              Data_Access.Fetch_Byte
               (Addressing_Type => Proc.Current_Instruction.Addressing,
               Bus             => Bus,
               Registers       => Proc.Registers),
            Carry_Before => Proc.Registers.SR.C,
            Result       => Proc.Registers.A,
            Carry_After  => Proc.Registers.SR.C,
            Negative     => Proc.Registers.SR.N,
            Overflow     => Proc.Registers.SR.V,
            Zero         => Proc.Registers.SR.Z);
      else
         Arithmetic.Subtract_With_Carry
           (Value_1      => Proc.Registers.A,
            Value_2      =>
              Data_Access.Fetch_Byte
               (Addressing_Type => Proc.Current_Instruction.Addressing,
               Bus             => Bus,
               Registers       => Proc.Registers),
            Carry_Before => Proc.Registers.SR.C,
            Result       => Proc.Registers.A,
            Carry_After  => Proc.Registers.SR.C,
            Negative     => Proc.Registers.SR.N,
            Overflow     => Proc.Registers.SR.V,
            Zero         => Proc.Registers.SR.Z);
      end if;
   end Subtract_with_Carry;

   procedure Add_With_Carry
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus)
   is
   begin
      if Proc.Registers.SR.D then
         Arithmetic.Decimal_Add_With_Carry
           (Value_1      => Proc.Registers.A,
            Value_2      =>
            Data_Access.Fetch_Byte
               (Addressing_Type => Proc.Current_Instruction.Addressing,
               Bus             => Bus,
               Registers       => Proc.Registers),
            Carry_Before => Proc.Registers.SR.C,
            Result       => Proc.Registers.A,
            Carry_After  => Proc.Registers.SR.C,
            Negative     => Proc.Registers.SR.N,
            Overflow     => Proc.Registers.SR.V,
            Zero         => Proc.Registers.SR.Z);
      else
         Arithmetic.Add_With_Carry
           (Value_1      => Proc.Registers.A,
            Value_2      =>
            Data_Access.Fetch_Byte
               (Addressing_Type => Proc.Current_Instruction.Addressing,
               Bus             => Bus,
               Registers       => Proc.Registers),
            Carry_Before => Proc.Registers.SR.C,
            Result       => Proc.Registers.A,
            Carry_After  => Proc.Registers.SR.C,
            Negative     => Proc.Registers.SR.N,
            Overflow     => Proc.Registers.SR.V,
            Zero         => Proc.Registers.SR.Z);
      end if;
   end Add_With_Carry;

   procedure Compare
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus)
   is
      Register_Value : Data_Types.T_Byte;
      Dummy_Result   : Data_Types.T_Byte;
      Dummy_Overflow : Boolean;
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when CMP =>
            Register_Value := Proc.Registers.A;
         when CPX =>
            Register_Value := Proc.Registers.X;
         when CPY =>
            Register_Value := Proc.Registers.Y;
         when others =>
            raise Cpu_Internal_Wrong_Operation;
      end case;
      Arithmetic.Subtract_With_Carry
        (Value_1      => Register_Value,
         Value_2      =>
           Data_Access.Fetch_Byte
            (Addressing_Type => Proc.Current_Instruction.Addressing,
             Bus             => Bus,
             Registers       => Proc.Registers),
         Carry_Before => True,
         Result       => Dummy_Result,
         Carry_After  => Proc.Registers.SR.C,
         Negative     => Proc.Registers.SR.N,
         Overflow     => Dummy_Overflow,
         Zero         => Proc.Registers.SR.Z);
   end Compare;

   procedure Decrement
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus)
   is
      use type Data_Types.T_Byte;
      Where_Is_Data : constant Data_Access.T_Location
        := Data_Access.Addressing_Points_To
             (Addressing_Type => Proc.Current_Instruction.Addressing,
              Bus             => Bus,
              Registers       => Proc.Registers);
      Value : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
            (Location  => Where_Is_Data,
             Bus       => Bus,
             Registers => Proc.Registers)
           - Data_Types.One_Byte;
   begin
      Data_Access.Store_Byte
        (Location  => Where_Is_Data,
         Bus       => Bus,
         Registers => Proc.Registers,
         Value     => Value);
      Set_N_And_Z
        (Value    => Value,
         Negative => Proc.Registers.SR.N,
         Zero     => Proc.Registers.SR.Z);
   end Decrement;

   procedure Increment
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus)
   is
      use type Data_Types.T_Byte;
      Where_Is_Data : constant Data_Access.T_Location
        := Data_Access.Addressing_Points_To
             (Addressing_Type => Proc.Current_Instruction.Addressing,
              Bus             => Bus,
              Registers       => Proc.Registers);
      Value : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
            (Location  => Where_Is_Data,
             Bus       => Bus,
             Registers => Proc.Registers)
           + Data_Types.One_Byte;
   begin
      Data_Access.Store_Byte
        (Location  => Where_Is_Data,
         Bus       => Bus,
         Registers => Proc.Registers,
         Value     => Value);
      Set_N_And_Z
        (Value    => Value,
         Negative => Proc.Registers.SR.N,
         Zero     => Proc.Registers.SR.Z);
   end Increment;

   procedure Jump (Proc       : in out T_Cpu;
                   Bus        : in out Data_Bus.T_Data_Bus;
                   Stack_Page : Data_Types.T_Address)
   is
      use type Data_Types.T_Byte;
   begin
      if Proc.Current_Instruction.Instruction_Type = JSR then
         Data_Access.Push_Address
           (Bus        => Bus,
            Registers  => Proc.Registers,
            Value      => Proc.Registers.PC + 2 * Data_Types.One_Byte,
            Stack_Page => Stack_Page);
      end if;
      Proc.Registers.PC :=
        Data_Access.Fetch_Address
         (Addressing_Type => Proc.Current_Instruction.Addressing,
          Bus             => Bus,
          Registers       => Proc.Registers);
   end Jump;

   procedure Load_Value
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus)
   is
      Value : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Addressing_Type => Proc.Current_Instruction.Addressing,
              Bus             => Bus,
              Registers       => Proc.Registers);
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when LDA =>
            Proc.Registers.A := Value;
         when LDX =>
            Proc.Registers.X := Value;
         when LDY =>
            Proc.Registers.Y := Value;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Proc.Current_Instruction.Instruction_Type'Image;
      end case;
      Set_N_And_Z
        (Value    => Value,
         Negative => Proc.Registers.SR.N,
         Zero     => Proc.Registers.SR.Z);
   end Load_Value;

   procedure Store_Value
     (Proc : in out T_Cpu;
      Bus  : in out Data_Bus.T_Data_Bus)
   is
      Value : Data_Types.T_Byte;
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when STA =>
            Value := Proc.Registers.A;
         when STX =>
            Value := Proc.Registers.X;
         when STY =>
            Value := Proc.Registers.Y;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Proc.Current_Instruction.Instruction_Type'Image;
      end case;
      Data_Access.Store_Byte
        (Addressing_Type => Proc.Current_Instruction.Addressing,
         Bus             => Bus,
         Registers       => Proc.Registers,
         Value           => Value);
   end Store_Value;

   procedure Bit_Mem_With_A
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus)
   is
      use type Data_Types.T_Byte;
      Value         : Data_Types.T_Byte;
      Dummy_Boolean : Boolean;
      Byte_From_Mem : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Addressing_Type => Proc.Current_Instruction.Addressing,
              Bus             => Bus,
              Registers       => Proc.Registers);
   begin
      Value := Proc.Registers.A and Byte_From_Mem;
      --  Transfer N and V to the Status Register
      Proc.Registers.SR.N := Bit_Test.Bit_X_Is_Set (Byte_From_Mem, 7);
      Proc.Registers.SR.V := Bit_Test.Bit_X_Is_Set (Byte_From_Mem, 6);
      --  Set Z
      Set_N_And_Z (Value => Value,
                   Negative => Dummy_Boolean,
                   Zero => Proc.Registers.SR.Z);
      --  Don't store the value
   end Bit_Mem_With_A;

   procedure Logic_Mem_With_A
     (Proc : in out T_Cpu;
      Bus  :        Data_Bus.T_Data_Bus)
   is
      use type Data_Types.T_Byte;
      Value : Data_Types.T_Byte;
      Byte_From_Mem  : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Addressing_Type => Proc.Current_Instruction.Addressing,
              Bus             => Bus,
              Registers       => Proc.Registers);
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when AND_I =>
            Value := Proc.Registers.A and Byte_From_Mem;
         when EOR =>
            Value := Proc.Registers.A xor Byte_From_Mem;
         when ORA =>
            Value := Proc.Registers.A or Byte_From_Mem;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Proc.Current_Instruction.Instruction_Type'Image;
      end case;
      Proc.Registers.A := Value;
      Set_N_And_Z
        (Value    => Value,
         Negative => Proc.Registers.SR.N,
         Zero     => Proc.Registers.SR.Z);
   end Logic_Mem_With_A;

   procedure Transfer
     (Proc : in out T_Cpu)
   is
   begin
      case Proc.Current_Instruction.Instruction_Type is
         when TAX =>
            Proc.Registers.X := Proc.Registers.A;
            Set_N_And_Z
              (Value    => Proc.Registers.X,
               Negative => Proc.Registers.SR.N,
               Zero     => Proc.Registers.SR.Z);
         when TAY =>
            Proc.Registers.Y := Proc.Registers.A;
            Set_N_And_Z
              (Value    => Proc.Registers.Y,
               Negative => Proc.Registers.SR.N,
               Zero     => Proc.Registers.SR.Z);
         when TSX =>
            Proc.Registers.X := Proc.Registers.SP;
            Set_N_And_Z
              (Value    => Proc.Registers.X,
               Negative => Proc.Registers.SR.N,
               Zero     => Proc.Registers.SR.Z);
         when TXA =>
            Proc.Registers.A := Proc.Registers.X;
            Set_N_And_Z
              (Value    => Proc.Registers.A,
               Negative => Proc.Registers.SR.N,
               Zero     => Proc.Registers.SR.Z);
         when TXS =>
            Proc.Registers.SP := Proc.Registers.X;
         when TYA =>
            Proc.Registers.A := Proc.Registers.Y;
            Set_N_And_Z
              (Value    => Proc.Registers.A,
               Negative => Proc.Registers.SR.N,
               Zero     => Proc.Registers.SR.Z);
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Proc.Current_Instruction.Instruction_Type'Image;
      end case;

   end Transfer;

   procedure Interrupt (Proc       : in out T_Cpu;
                        Bus        : in out Data_Bus.T_Data_Bus;
                        Vector     :        Data_Types.T_Address;
                        Stack_Page :        Data_Types.T_Address)
   is
      use type Data_Types.T_Byte;
      PC_To_Push : Data_Types.T_Address;
      SR_To_Push : T_SR := Proc.Registers.SR;
   begin
      --  BRK pushes PC+2 (extra byte of space after the BRK)
      if Proc.Current_Instruction.Instruction_Type = BRK
      then
         PC_To_Push := Proc.Registers.PC + 2 * Data_Types.One_Byte;
         SR_To_Push.B := True;
      else
         PC_To_Push := Proc.Registers.PC;
      end if;
      --  Maskable interrupt do nothing if I bit is set
      if Proc.Current_Instruction.Instruction_Type /= IRQ
         or else not Proc.Registers.SR.I
      then
         Data_Access.Push_Address
           (Bus        => Bus,
            Registers  => Proc.Registers,
            Value      => PC_To_Push,
            Stack_Page => Stack_Page);
         Data_Access.Push_Byte
           (Bus        => Bus,
            Registers  => Proc.Registers,
            Value      => Status_Register.SR_As_Byte
                            (SR_To_Push),
            Stack_Page => Stack_Page);
         --  Set the Interrupt bit
         --  (not in the SR we pushed to the stack)
         Proc.Registers.SR.I := True;
         --  Create a JMP instruction which will look at $Vector
         --  for its address (so we artificially move PC to $Vector-1)
         Proc.Registers.PC := Vector - Data_Types.One_Byte;
         Change_Instruction (Proc, (JMP, ABSOLUTE, 1));
      end if;
   end Interrupt;

end Cpu.Operations;