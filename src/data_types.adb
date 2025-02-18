package body Data_Types is

   function Byte_To_Signed (B : T_Byte) return T_Signed_Byte is
   begin
      if B >= 128 then
         return T_Signed_Byte (B - 128) - 127 - 1;
      else
         return T_Signed_Byte (B);
      end if;
   end Byte_To_Signed;
end Data_Types;