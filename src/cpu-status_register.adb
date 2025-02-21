package body Cpu.Status_Register is

   function C_As_Byte (C : Boolean)
     return Data_Types.T_Byte
   is
   begin
      if C then
         return Data_Types.One_Byte;
      else
         return 0;
      end if;
   end C_As_Byte;

   function Not_C_As_Byte (C : Boolean)
     return Data_Types.T_Byte
   is
   begin
      if not C then
         return Data_Types.One_Byte;
      else
         return 0;
      end if;
   end Not_C_As_Byte;

   function Byte_As_SR (B : Data_Types.T_Byte)
     return T_SR
   is
      use type Data_Types.T_Byte;
   begin
      return
        (C => (B and 2#1#) /= 0,
         Z => (B and 2#10#) /= 0,
         I => (B and 2#100#) /= 0,
         D => (B and 2#1000#) /= 0,
         B => (B and 2#10000#) /= 0,
         U => (B and 2#100000#) /= 0,
         V => (B and 2#1000000#) /= 0,
         N => (B and 2#10000000#) /= 0);
   end Byte_As_SR;

   function SR_As_Byte (SR : T_SR)
     return Data_Types.T_Byte
   is
      use type Data_Types.T_Byte;
      Tmp_Byte : Data_Types.T_Byte := 0;
   begin
      if SR.C then
         Tmp_Byte := Tmp_Byte + 2#1#;
      end if;
      if SR.Z then
         Tmp_Byte := Tmp_Byte + 2#10#;
      end if;
      if SR.I then
         Tmp_Byte := Tmp_Byte + 2#100#;
      end if;
      if SR.D then
         Tmp_Byte := Tmp_Byte + 2#1000#;
      end if;
      if SR.B then
         Tmp_Byte := Tmp_Byte + 2#10000#;
      end if;
      if SR.U then
         Tmp_Byte := Tmp_Byte + 2#100000#;
      end if;
      if SR.V then
         Tmp_Byte := Tmp_Byte + 2#1000000#;
      end if;
      if SR.N then
         Tmp_Byte := Tmp_Byte + 2#10000000#;
      end if;
      return Tmp_Byte;
   end SR_As_Byte;

end Cpu.Status_Register;