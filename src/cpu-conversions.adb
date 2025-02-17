package body Cpu.Conversions is

   function SR_As_Byte (Cpu : T_Cpu)
     return Data_Types.T_Byte
   is
      use type Data_Types.T_Byte;
      Tmp_Byte : Data_Types.T_Byte := 0;
   begin
      if Cpu.Registers.SR.C then
         Tmp_Byte := Tmp_Byte + 2#1#;
      end if;
      if Cpu.Registers.SR.Z then
         Tmp_Byte := Tmp_Byte + 2#10#;
      end if;
      if Cpu.Registers.SR.I then
         Tmp_Byte := Tmp_Byte + 2#100#;
      end if;
      if Cpu.Registers.SR.D then
         Tmp_Byte := Tmp_Byte + 2#1000#;
      end if;
      if Cpu.Registers.SR.B then
         Tmp_Byte := Tmp_Byte + 2#10000#;
      end if;
      if Cpu.Registers.SR.U then
         Tmp_Byte := Tmp_Byte + 2#100000#;
      end if;
      if Cpu.Registers.SR.V then
         Tmp_Byte := Tmp_Byte + 2#1000000#;
      end if;
      if Cpu.Registers.SR.N then
         Tmp_Byte := Tmp_Byte + 2#10000000#;
      end if;
      return Tmp_Byte;
   end SR_As_Byte;

end Cpu.Conversions;