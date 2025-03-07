package Data_Types is

   type T_Address is mod 2**16;
   type T_Byte is mod 2**8;
   type T_Clock_Counter is mod 2**64;
   type T_Clock_1Mhz_Counter is mod 2**20;

   One_Byte : constant T_Byte := T_Byte (1);

   function Is_Zero (B : T_Byte) return Boolean
     is (B = 0);

   type T_Byte_Array is array (T_Address range <>) of T_Byte;

   type T_Byte_Grid is array
     (Positive range <>, Positive range <>) of T_Byte;

   type T_Signed_Byte is range -128 .. +127;

   function Byte_To_Signed (B : T_Byte) return T_Signed_Byte;

   subtype T_Bit_Position is Natural range 0 .. 7;

   type T_Word is record
      Low  : T_Byte;
      High : T_Byte;
   end record;

   --  Add a Byte to an Address, with Carry (FF+1 = 100)
   function "+" (L : T_Address; R : T_Byte) return T_Address
     is (L + T_Address (R));
   function "-" (L : T_Address; R : T_Byte) return T_Address
     is (L - T_Address (R));

   --  Add a signed byte to an Address
   --  for branching (relative addressing)
   function "+" (L : T_Address; R : T_Signed_Byte) return T_Address
     is (T_Address'Mod (Integer (L) + Integer (R)));

   function Word_To_Address (W : T_Word) return T_Address
     is (T_Address (W.High) * 256 + W.Low);

   function Address_To_Word (A : T_Address) return T_Word
     is ((Low  => T_Byte (A and 16#FF#),
          High => T_Byte (A / 256)));

   --  Used to Add with Carry (Carry is bit 8)
   type T_9_Bits is mod 2**9;
   function "+" (L, R : T_Byte) return T_9_Bits
     is (T_9_Bits (L) + T_9_Bits (R));
   function "+" (L : T_9_Bits; R : T_Byte) return T_9_Bits
     is (L + T_9_Bits (R));

end Data_Types;