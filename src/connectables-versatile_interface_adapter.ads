package Connectables.Versatile_Interface_Adapter is

   type T_VIA (First_Address : Data_Types.T_Address)
   is new T_Connectable with private;

   type T_VIA_Ptr is access all T_VIA;

   overriding
   function Read_Byte (Via     : T_VIA;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte;

   overriding
   procedure Write_Byte
     (Via     : in out T_VIA;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte);

private

   type T_VIA_Bytes is
     (PORT_B,
      PORT_A_HS,
      DATA_DIR_B, DATA_DIR_A,
      TIMER_1_LOW, TIMER_1_HIGH,
      TIMER_1_LATCH_LOW, TIMER_1_LATCH_HIGH,
      TIMER_2_LOW, TIMER_2_HIGH,
      SHIFT_REGISTER,
      AUX_CONTROL,
      PERIPH_CONTROL,
      INTERRUPT_ENABLE,
      INTERRUPT_FLAGS,
      PORT_A_NO_HS);

   type T_VIA_Bytes_Array is array (T_VIA_Bytes)
     of Data_Types.T_Byte;

   type T_VIA (First_Address : Data_Types.T_Address)
   is new T_Connectable
   with record
      Address : Data_Types.T_Address := First_Address;
      Bytes   : T_VIA_Bytes_Array;
   end record;

   overriding
   function Get_Address_Space (Via : T_VIA)
   return T_Address_Space;

end Connectables.Versatile_Interface_Adapter;