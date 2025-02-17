package Data_Types is

   type T_Address is mod 2**16;
   type T_Byte is mod 2**8;

   subtype T_Bit_Position is Natural range 0 .. 7;

   One_Byte : constant T_Byte := T_Byte (1);

   type T_Byte_Array is array (T_Address range <>) of T_Byte;

   type T_Word is record
      Low  : T_Byte;
      High : T_Byte;
   end record;

   --  Add a Byte to an Address, with Carry (FF+1 = 100)
   function "+" (L : T_Address; R : T_Byte) return T_Address
     is (L + T_Address (R));

   function Word_To_Address (W : T_Word) return T_Address
     is (T_Address (W.High) * 256 + W.Low);

   --  Used to Add with Carry (Carry is bit 8)
   type T_9_Bits is mod 2**9;
   function "+" (L, R : T_Byte) return T_9_Bits
     is (T_9_Bits (L) + T_9_Bits (R));
   function "+" (L : T_9_Bits; R : T_Byte) return T_9_Bits
     is (L + T_9_Bits (R));

end Data_Types;