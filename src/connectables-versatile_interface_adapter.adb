package body Connectables.Versatile_Interface_Adapter is

   subtype T_Address_Range is Data_Types.T_Address
               range 0 .. 16#F#;

   function Address_To_VIA_Byte
     (Via : T_VIA;
      Address : Data_Types.T_Address)
   return T_VIA_Bytes
   is
      use type Data_Types.T_Address;

      Pos_To_Byte : constant array (T_Address_Range)
                      of T_VIA_Bytes
        := (16#0# => PORT_B,
            16#1# => PORT_A_HS,
            16#2# => DATA_DIR_A,
            16#3# => DATA_DIR_B,
            16#4# => TIMER_1_LOW,
            16#5# => TIMER_1_HIGH,
            16#6# => TIMER_1_LATCH_LOW,
            16#7# => TIMER_1_LATCH_HIGH,
            16#8# => TIMER_2_LOW,
            16#9# => TIMER_2_HIGH,
            16#A# => SHIFT_REGISTER,
            16#B# => AUX_CONTROL,
            16#C# => PERIPH_CONTROL,
            16#D# => INTERRUPT_ENABLE,
            16#E# => INTERRUPT_FLAGS,
            16#F# => PORT_A_NO_HS);
   begin
      return Pos_To_Byte (Address - Via.Address);
   end Address_To_VIA_Byte;

   overriding
   function Get_Address_Space (Via : T_VIA)
   return T_Address_Space
   is
      use type Data_Types.T_Address;
   begin
      return (First_Address => Via.Address,
              Last_Address  => Via.Address + T_Address_Range'Last);
   end Get_Address_Space;

   overriding
   function Read_Byte (Via     : T_VIA;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte
   is
   begin
      if not Address_In_Address_Space (Address, Via.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      else
         return Via.Bytes (Via.Address_To_VIA_Byte (Address));
      end if;
   end Read_Byte;

   overriding
   procedure Write_Byte
     (Via     : in out T_VIA;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte)
   is
   begin
      if not Address_In_Address_Space (Address, Via.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      else
         Via.Bytes (Via.Address_To_VIA_Byte (Address)) := Value;
      end if;
   end Write_Byte;

end Connectables.Versatile_Interface_Adapter;