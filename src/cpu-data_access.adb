with Data_Types;

package body Cpu.Data_Access is

   function Following_Byte
     (Bus : Data_Bus.T_Data_Bus;
      PC  : Data_Types.T_Address)
     return Data_Types.T_Byte
   is
      use type Data_Types.T_Byte;
   begin
      return Data_Bus.Read_Byte
        (Bus      => Bus,
         Address  => PC + Data_Types.One_Byte);
   end Following_Byte;

   function Following_Word
     (Bus : Data_Bus.T_Data_Bus;
      PC  : Data_Types.T_Address)
     return Data_Types.T_Word
   is
      use type Data_Types.T_Byte;
      Tmp_Word : Data_Types.T_Word;
   begin
      Tmp_Word.Low := Data_Bus.Read_Byte (Bus, PC + Data_Types.One_Byte);
      Tmp_Word.High := Data_Bus.Read_Byte (Bus, PC + 2 * Data_Types.One_Byte);
      return Tmp_Word;
   end Following_Word;

   function Byte_To_Zero_Page (B : Data_Types.T_Byte)
     return Data_Types.T_Address
   is (Data_Types.Word_To_Address
         ((Low => B, High => 16#00#)));

   function Get_Address_At_Address
     (Bus     : Data_Bus.T_Data_Bus;
      Address : Data_Types.T_Address)
   return Data_Types.T_Address is
      use type Data_Types.T_Byte;
      Tmp_Word : Data_Types.T_Word;
   begin
      Tmp_Word.Low := Data_Bus.Read_Byte (Bus, Address);
      Tmp_Word.High := Data_Bus.Read_Byte (Bus, Address + Data_Types.One_Byte);
      return Data_Types.Word_To_Address (Tmp_Word);
   end Get_Address_At_Address;

   function Addressing_Points_To
     (Addressing_Type : T_Valid_Addressing_Types;
      Bus             : Data_Bus.T_Data_Bus;
      Registers       : T_Registers)
   return T_Location is
      use all type Data_Types.T_Byte;
      use type Data_Types.T_Address;
      Where_To : Data_Types.T_Address := 16#0000#;
   begin
      case Addressing_Type is
         when IMPLIED =>
            raise Cpu_Internal_Wrong_Data_Access;
         when ACCUMULATOR =>
            return (L_ACCUMULATOR, Where_To);
         when X =>
            return (L_X, Where_To);
         when Y =>
            return (L_Y, Where_To);
         when RELATIVE =>
            Where_To := Registers.PC
              + Byte_To_Signed (Following_Byte (Bus, Registers.PC));
         when IMMEDIATE =>
            Where_To := Registers.PC + Data_Types.One_Byte;
         when ZERO_PAGE   =>
            --  operand is zeropage address
            --  (hi-byte is zero, address = $00LL)
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Bus, Registers.PC);
            begin
               Where_To := Byte_To_Zero_Page (Where_In_ZP);
            end;
         when ZERO_PAGE_X =>
            --  operand is zeropage address;
            --  effective address is address incremented by X without carry
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Bus, Registers.PC)
                    + Registers.X;
            begin
               Where_To := Byte_To_Zero_Page (Where_In_ZP);
            end;
         when ZERO_PAGE_Y =>
            --  operand is zeropage address;
            --  effective address is address incremented by X without carry
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Bus, Registers.PC)
                    + Registers.Y;
            begin
               Where_To := Byte_To_Zero_Page (Where_In_ZP);
            end;
         when INDIRECT    =>
            --  operand is address;
            --  effective address is contents of word at address
            declare
               Where_Is_Address : constant Data_Types.T_Address
                 := Data_Types.Word_To_Address
                   (Following_Word (Bus, Registers.PC));
            begin
               Where_To := Get_Address_At_Address
                             (Bus, Where_Is_Address);
            end;
         when INDIRECT_X  =>
            --  operand is zeropage address;
            --  effective address is word in (ZP + X) without carry
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Bus, Registers.PC)
                    + Registers.X;
               Where_Is_Address : constant Data_Types.T_Address
                 := Byte_To_Zero_Page (Where_In_ZP);
            begin
               Where_To := Get_Address_At_Address
                             (Bus, Where_Is_Address);
            end;
         when INDIRECT_Y  =>
            --  operand is zeropage address;
            --  effective address is word in ZP, incremented by Y with carry
            --  TODO : NEED TO HANDLE THE EXTRA CYCLE IF
            --         PAGE TRANSITION OCCURS
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Bus, Registers.PC);
               Where_Is_Address : constant Data_Types.T_Address
                 := Byte_To_Zero_Page (Where_In_ZP);
            begin
               Where_To := Get_Address_At_Address
                            (Bus, Where_Is_Address) + Registers.Y;
            end;
         when ABSOLUTE    =>
            --  operand is address
            Where_To := Data_Types.Word_To_Address
                          (Following_Word (Bus, Registers.PC));
         when ABSOLUTE_X  =>
            --  operand is address;
            --  effective address is address incremented by X with carry
            --  TODO : NEED TO HANDLE THE EXTRA CYCLE IF
            --         PAGE TRANSITION OCCURS
            Where_To := Data_Types.Word_To_Address
                          (Following_Word (Bus, Registers.PC))
                        + Registers.X;
         when ABSOLUTE_Y  =>
            --  operand is address;
            --  effective address is address incremented by Y with carry
            --  TODO : NEED TO HANDLE THE EXTRA CYCLE IF
            --         PAGE TRANSITION OCCURS
            Where_To := Data_Types.Word_To_Address
                         (Following_Word (Bus, Registers.PC))
                        + Registers.Y;
      end case;
      return (L_MEMORY, Where_To);
   end Addressing_Points_To;

   function Addresses_On_Same_Page
     (Address_1 : Data_Types.T_Address;
      Address_2 : Data_Types.T_Address)
   return Boolean is
      use type Data_Types.T_Address;
   begin
      return (Address_1 and 16#FF00#) = (Address_2 and 16#FF00#);
   end Addresses_On_Same_Page;
   --  -------------------------------------------------------
   --  Get the address where the addressing type
   --  tells you to.
   --  -------------------------------------------------------
   function Fetch_Address
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Bus             : Data_Bus.T_Data_Bus;
      Registers       : T_Registers)
     return Data_Types.T_Address
   is
      Where_Is_Address : constant T_Location
        := Addressing_Points_To
             (Addressing_Type => Addressing_Type,
              Bus             => Bus,
              Registers       => Registers);
   begin
      if Where_Is_Address.Kind = L_ACCUMULATOR then
         raise Cpu_Internal_Wrong_Data_Access;
      end if;
      return Where_Is_Address.Address;
   end Fetch_Address;

   function Fetch_Byte
     (Location  : T_Location;
      Bus       : Data_Bus.T_Data_Bus;
      Registers : T_Registers)
   return Data_Types.T_Byte is
   begin
      case Location.Kind is
         when L_ACCUMULATOR =>
            --  operand is AC (implied single byte instruction)
            return Registers.A;
         when L_X =>
            return Registers.X;
         when L_Y =>
            return Registers.Y;
         when L_MEMORY      =>
            return Data_Bus.Read_Byte
               (Bus     => Bus,
                Address => Location.Address
               );
      end case;
   end Fetch_Byte;

   --  -------------------------------------------------
   --  Get the byte from where the addressing type
   --  tells you to.
   --  -------------------------------------------------
   function Fetch_Byte
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Bus             : Data_Bus.T_Data_Bus;
      Registers       : T_Registers)
     return Data_Types.T_Byte
   is
      Where_Is_Byte : constant T_Location
        := Addressing_Points_To
             (Addressing_Type => Addressing_Type,
              Bus             => Bus,
              Registers       => Registers);
   begin
      return Fetch_Byte (Where_Is_Byte, Bus, Registers);
   end Fetch_Byte;

   function SP_To_Location
     (SP         : Data_Types.T_Byte;
      Stack_Page : Data_Types.T_Address)
   return T_Location
   is
      use type Data_Types.T_Address;
   begin
      return (L_MEMORY, Stack_Page + SP);
   end SP_To_Location;

   procedure Pull_Address
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :    out Data_Types.T_Address;
      Stack_Page :        Data_Types.T_Address)
   is
      Value_As_Word : Data_Types.T_Word;
   begin
      Pull_Byte (Bus        => Bus,
                 Registers  => Registers,
                 Value      => Value_As_Word.Low,
                 Stack_Page => Stack_Page);
      Pull_Byte (Bus        => Bus,
                 Registers  => Registers,
                 Value      => Value_As_Word.High,
                 Stack_Page => Stack_Page);
      Value := Data_Types.Word_To_Address (Value_As_Word);
   end Pull_Address;

   procedure Pull_Byte
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :    out Data_Types.T_Byte;
      Stack_Page :        Data_Types.T_Address)
   is
      use type Data_Types.T_Byte;
      Where_From : Data_Access.T_Location;
   begin
      Registers.SP
        := Registers.SP + Data_Types.One_Byte;
      Where_From
        := SP_To_Location
            (Registers.SP, Stack_Page);
      Value :=
         Fetch_Byte
           (Location  => Where_From,
            Bus       => Bus,
            Registers => Registers);
   end Pull_Byte;

   procedure Push_Address
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :        Data_Types.T_Address;
      Stack_Page :        Data_Types.T_Address)
   is
      Value_As_Word : constant Data_Types.T_Word
         := Data_Types.Address_To_Word (Value);
   begin
      Push_Byte
        (Bus        => Bus,
         Registers  => Registers,
         Value      => Value_As_Word.High,
         Stack_Page => Stack_Page);
      Push_Byte
        (Bus        => Bus,
         Registers  => Registers,
         Value      => Value_As_Word.Low,
         Stack_Page => Stack_Page);
   end Push_Address;

   procedure Push_Byte
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :        Data_Types.T_Byte;
      Stack_Page :        Data_Types.T_Address)
   is
      use type Data_Types.T_Byte;
      Where_To : constant Data_Access.T_Location
        := Data_Access.SP_To_Location
            (Registers.SP, Stack_Page);
   begin
      Store_Byte
        (Location  => Where_To,
         Bus       => Bus,
         Registers => Registers,
         Value     => Value);
      Registers.SP
        := Registers.SP - Data_Types.One_Byte;
   end Push_Byte;

   procedure Store_Byte
     (Location  :        T_Location;
      Bus       :        Data_Bus.T_Data_Bus;
      Registers : in out T_Registers;
      Value     :        Data_Types.T_Byte)
   is
   begin
      case Location.Kind is
         when L_ACCUMULATOR =>
            Registers.A := Value;
         when L_X =>
            Registers.X := Value;
         when L_Y =>
            Registers.Y := Value;
         when L_MEMORY      =>
            Data_Bus.Write_Byte (Bus     => Bus,
                                 Address => Location.Address,
                                 Value   => Value);
      end case;
   end Store_Byte;

   procedure Store_Byte
     (Addressing_Type :        T_Addressing_Types_To_Fetch_Bytes;
      Bus             :        Data_Bus.T_Data_Bus;
      Registers       : in out T_Registers;
      Value           :        Data_Types.T_Byte)
   is
      Where_To : constant T_Location
        := Addressing_Points_To
             (Addressing_Type => Addressing_Type,
              Bus             => Bus,
              Registers       => Registers);
   begin
      Store_Byte (Where_To, Bus, Registers, Value);
   end Store_Byte;

end Cpu.Data_Access;