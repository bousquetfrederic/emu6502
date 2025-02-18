with Data_Types;
with Cpu.Data_Access;
with Cpu.Status_Register;
with Cpu.Logging;

package body Cpu.Operations is

   procedure Change_Instruction
     (Proc : in out T_Cpu;
      I    :        T_Instruction) is
   begin
      Logging.Dump_Current_Instruction (Proc);
      Logging.Dump_Registers (Proc);
      Proc.Current_Instruction := I;
   end Change_Instruction;

   procedure Branch
     (Proc : in out T_Cpu;
      Mem  :        Memory.T_Memory)
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
            Mem             => Mem,
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
               New_Instruction.Cycles := 1;
            else
               New_Instruction.Cycles := 2;
            end if;
            Change_Instruction (Proc, New_Instruction);
            Proc.Registers.PC := Where_To.Address;
         end;
      end if;
   end Branch;

   procedure Shift_Or_Rotate_Left
     (Cpu : in out T_Cpu;
      Mem : in out Memory.T_Memory)
   is
      use type Data_Types.T_Byte;
      use type Data_Types.T_9_Bits;
      Where_Is_Data : constant Data_Access.T_Location
        := Data_Access.Addressing_Points_To
             (Addressing_Type => Cpu.Current_Instruction.Addressing,
              Mem             => Mem,
              Registers       => Cpu.Registers);
      Value : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Location  => Where_Is_Data,
              Mem       => Mem,
              Registers => Cpu.Registers);
      Shifted : constant Data_Types.T_9_Bits
        := Data_Types.T_9_Bits (Value) * 2#10#;
      Shifted_8_Bits : Data_Types.T_Byte
        := Data_Types.T_Byte (Shifted and 2#011111111#);
   begin
      --  If it's a ROTATE not a SHIFT
      --  add the Carry in bit 0
      if Cpu.Current_Instruction.Instruction_Type = ROL
      then
         Shifted_8_Bits
           := Shifted_8_Bits
              + Status_Register.C_As_Byte (Cpu.Registers.SR);
      end if;
      Data_Access.Store_Byte
        (Location  => Where_Is_Data,
         Mem       => Mem,
         Registers => Cpu.Registers,
         Value     => Shifted_8_Bits);
      Status_Register.Set_C
        (SR    => Cpu.Registers.SR,
         Value => Shifted);
      Status_Register.Set_N_And_Z
        (SR    => Cpu.Registers.SR,
         Value => Shifted_8_Bits);
   end Shift_Or_Rotate_Left;

   procedure Add_With_Carry
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory)
   is
      use type Data_Types.T_9_Bits;
      Value : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Addressing_Type => Cpu.Current_Instruction.Addressing,
              Mem             => Mem,
              Registers       => Cpu.Registers);
      Total : constant Data_Types.T_9_Bits
        := Cpu.Registers.A + Value
             + Status_Register.C_As_Byte (Cpu.Registers.SR);
      Total_8_bits : constant Data_Types.T_Byte
        := Data_Types.T_Byte (Total and 2#011111111#);
   begin
      Status_Register.Set_C
        (SR    => Cpu.Registers.SR,
         Value => Total);
      Status_Register.Set_V
        (SR => Cpu.Registers.SR,
         Value_1 => Cpu.Registers.A,
         Value_2 => Value,
         Result  => Total_8_bits);
      Status_Register.Set_N_And_Z
        (SR    => Cpu.Registers.SR,
         Value => Total_8_bits);
      Cpu.Registers.A := Total_8_bits;
   end Add_With_Carry;

   procedure Jump (Cpu : in out T_Cpu;
                   Mem :        Memory.T_Memory) is
   begin
      Cpu.Registers.PC :=
        Data_Access.Fetch_Address
         (Addressing_Type => Cpu.Current_Instruction.Addressing,
          Mem             => Mem,
          Registers       => Cpu.Registers);
   end Jump;

   procedure Load_Value
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory)
   is
      Value : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Addressing_Type => Cpu.Current_Instruction.Addressing,
              Mem             => Mem,
              Registers       => Cpu.Registers);
   begin
      case Cpu.Current_Instruction.Instruction_Type is
         when LDA =>
            Cpu.Registers.A := Value;
         when LDX =>
            Cpu.Registers.X := Value;
         when LDY =>
            Cpu.Registers.Y := Value;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Cpu.Current_Instruction.Instruction_Type'Image;
      end case;
      Status_Register.Set_N_And_Z
        (SR    => Cpu.Registers.SR,
         Value => Value);
   end Load_Value;

   procedure Store_Value
     (Cpu : in out T_Cpu;
      Mem : in out Memory.T_Memory)
   is
      Value : Data_Types.T_Byte;
   begin
      case Cpu.Current_Instruction.Instruction_Type is
         when STA =>
            Value := Cpu.Registers.A;
         when STX =>
            Value := Cpu.Registers.X;
         when STY =>
            Value := Cpu.Registers.Y;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Cpu.Current_Instruction.Instruction_Type'Image;
      end case;
      Data_Access.Store_Byte
        (Addressing_Type => Cpu.Current_Instruction.Addressing,
         Mem             => Mem,
         Registers       => Cpu.Registers,
         Value           => Value);
   end Store_Value;

   procedure Logic_Mem_With_A
     (Cpu : in out T_Cpu;
      Mem :        Memory.T_Memory)
   is
      use type Data_Types.T_Byte;
      Value : Data_Types.T_Byte;
      Byte_From_Mem  : constant Data_Types.T_Byte
        := Data_Access.Fetch_Byte
             (Addressing_Type => Cpu.Current_Instruction.Addressing,
              Mem             => Mem,
              Registers       => Cpu.Registers);
   begin
      case Cpu.Current_Instruction.Instruction_Type is
         when AND_I =>
            Value := Cpu.Registers.A and Byte_From_Mem;
         when EOR =>
            Value := Cpu.Registers.A xor Byte_From_Mem;
         when ORA =>
            Value := Cpu.Registers.A or Byte_From_Mem;
         when others =>
            raise Cpu_Internal_Wrong_Operation
              with Cpu.Current_Instruction.Instruction_Type'Image;
      end case;
      Cpu.Registers.A := Value;
      Status_Register.Set_N_And_Z
        (SR    => Cpu.Registers.SR,
         Value => Value);
   end Logic_Mem_With_A;

end Cpu.Operations;