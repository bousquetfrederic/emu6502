with Data_Types;

package body Cpu.Data_Access is

   function Following_Byte
     (Mem : Memory.T_Memory;
      PC  : Data_Types.T_Address)
     return Data_Types.T_Byte
   is
      use type Data_Types.T_Byte;
   begin
      return Memory.Read_Byte
        (Mem     => Mem,
         Address => PC + Data_Types.One_Byte);
   end Following_Byte;

   function Following_Word
     (Mem : Memory.T_Memory;
      PC  : Data_Types.T_Address)
     return Data_Types.T_Word
   is
      use type Data_Types.T_Byte;
   begin
      return Memory.Read_Word
        (Mem     => Mem,
         Address => PC + Data_Types.One_Byte);
   end Following_Word;

   function Byte_To_Zero_Page (B : Data_Types.T_Byte)
     return Data_Types.T_Address
   is (Data_Types.Word_To_Address
         ((Low => B, High => 16#00#)));

   function Get_Address_At_Address
     (Mem     : Memory.T_Memory;
      Address : Data_Types.T_Address)
   return Data_Types.T_Address is
     (Data_Types.Word_To_Address
         (Memory.Read_Word (Mem, Address)));

   function Addressing_Points_To
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
   return T_Location is
      use type Data_Types.T_Byte;
      Where_To : Data_Types.T_Address := 16#0000#;
   begin
      case Addressing_Type is
         when ACCUMULATOR =>
            return (L_ACCUMULATOR, Where_To);
         when IMMEDIATE =>
            Where_To := Registers.PC + Data_Types.One_Byte;
         when ZERO_PAGE   =>
            --  operand is zeropage address
            --  (hi-byte is zero, address = $00LL)
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Mem, Registers.PC);
            begin
               Where_To := Byte_To_Zero_Page (Where_In_ZP);
            end;
         when ZERO_PAGE_X =>
            --  operand is zeropage address;
            --  effective address is address incremented by X without carry
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Mem, Registers.PC)
                    + Registers.X;
            begin
               Where_To := Byte_To_Zero_Page (Where_In_ZP);
            end;
         when ZERO_PAGE_Y =>
            --  operand is zeropage address;
            --  effective address is address incremented by X without carry
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Mem, Registers.PC)
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
                   (Following_Word (Mem, Registers.PC));
            begin
               Where_To := Get_Address_At_Address
                             (Mem, Where_Is_Address);
            end;
         when INDIRECT_X  =>
            --  operand is zeropage address;
            --  effective address is word in (ZP + X) without carry
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Mem, Registers.PC)
                    + Registers.X;
               Where_Is_Address : constant Data_Types.T_Address
                 := Byte_To_Zero_Page (Where_In_ZP);
            begin
               Where_To := Get_Address_At_Address
                             (Mem, Where_Is_Address);
            end;
         when INDIRECT_Y  =>
            --  operand is zeropage address;
            --  effective address is word in ZP, incremented by Y with carry
            --  TODO : NEED TO HANDLE THE EXTRA CYCLE IF
            --         PAGE TRANSITION OCCURS
            declare
               Where_In_ZP : constant Data_Types.T_Byte
                 := Following_Byte (Mem, Registers.PC);
               Where_Is_Address : constant Data_Types.T_Address
                 := Byte_To_Zero_Page (Where_In_ZP);
            begin
               Where_To := Get_Address_At_Address
                            (Mem, Where_Is_Address + Registers.Y);
            end;
         when ABSOLUTE    =>
            --  operand is address
            Where_To := Data_Types.Word_To_Address
                          (Following_Word (Mem, Registers.PC));
         when ABSOLUTE_X  =>
            --  operand is address;
            --  effective address is address incremented by X with carry
            --  TODO : NEED TO HANDLE THE EXTRA CYCLE IF
            --         PAGE TRANSITION OCCURS
            Where_To := Data_Types.Word_To_Address
                          (Following_Word (Mem, Registers.PC))
                        + Registers.X;
         when ABSOLUTE_Y  =>
            --  operand is address;
            --  effective address is address incremented by Y with carry
            --  TODO : NEED TO HANDLE THE EXTRA CYCLE IF
            --         PAGE TRANSITION OCCURS
            Where_To := Data_Types.Word_To_Address
                         (Following_Word (Mem, Registers.PC))
                        + Registers.Y;
      end case;
      return (L_MEMORY, Where_To);
   end Addressing_Points_To;

   --  -------------------------------------------------------
   --  Get the address where the addressing type
   --  tells you to.
   --  -------------------------------------------------------
   function Fetch_Address
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
     return Data_Types.T_Address
   is
      Where_Is_Address : constant T_Location
        := Addressing_Points_To
             (Addressing_Type => Addressing_Type,
              Mem             => Mem,
              Registers       => Registers);
   begin
      if Where_Is_Address.Kind = L_ACCUMULATOR then
         raise Cpu_Internal_Wrong_Data_Access;
      end if;
      return Where_Is_Address.Address;
   end Fetch_Address;

   function Fetch_Byte
     (Location  : T_Location;
      Mem       : Memory.T_Memory;
      Registers : T_Registers)
   return Data_Types.T_Byte is
   begin
      case Location.Kind is
         when L_ACCUMULATOR =>
            --  operand is AC (implied single byte instruction)
            return Registers.A;
         when L_MEMORY      =>
            return Memory.Read_Byte
               (Mem     => Mem,
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
      Mem             : Memory.T_Memory;
      Registers       : T_Registers)
     return Data_Types.T_Byte
   is
      Where_Is_Byte : constant T_Location
        := Addressing_Points_To
             (Addressing_Type => Addressing_Type,
              Mem             => Mem,
              Registers       => Registers);
   begin
      return Fetch_Byte (Where_Is_Byte, Mem, Registers);
   end Fetch_Byte;

   procedure Store_Byte
     (Location  :        T_Location;
      Mem       : in out Memory.T_Memory;
      Registers : in out T_Registers;
      Value     :        Data_Types.T_Byte)
   is
   begin
      case Location.Kind is
         when L_ACCUMULATOR =>
            Registers.A := Value;
         when L_MEMORY      =>
            Memory.Write_Byte (Mem    => Mem,
                              Address => Location.Address,
                              Value   => Value);
      end case;
   end Store_Byte;

   procedure Store_Byte
     (Addressing_Type :        T_Addressing_Types_To_Fetch_Bytes;
      Mem             : in out Memory.T_Memory;
      Registers       : in out T_Registers;
      Value           :        Data_Types.T_Byte)
   is
      Where_To : constant T_Location
        := Addressing_Points_To
             (Addressing_Type => Addressing_Type,
              Mem             => Mem,
              Registers       => Registers);
   begin
      Store_Byte (Where_To, Mem, Registers, Value);
   end Store_Byte;

end Cpu.Data_Access;