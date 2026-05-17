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

   --  True while the VIA is pulling the CPU IRQ line low,
   --  i.e. an enabled interrupt source has its flag set.
   function Irq_Asserted (Via : T_VIA) return Boolean;

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

   --  Mutable state that must be updated even from Read_Byte
   --  (which only sees an "in" T_VIA). Reaching it through an
   --  access value lets the read side-effects of the 6522
   --  (e.g. reading T1C-L clears the T1 interrupt flag) work.
   type T_VIA_State is record
      T1_Counter   : Data_Types.T_Address := 0;
      T1_Latch     : Data_Types.T_Address := 0;
      T2_Counter   : Data_Types.T_Address := 0;
      T2_Latch_Low : Data_Types.T_Byte    := 0;
      T2_Active    : Boolean               := False;
      --  Raw interrupt flag bits (bit 7 is computed on read).
      Ifr          : Data_Types.T_Byte    := 0;
      Ier          : Data_Types.T_Byte    := 0;
      Acr          : Data_Types.T_Byte    := 0;
   end record;

   type T_VIA_State_Ptr is access T_VIA_State;

   type T_VIA (First_Address : Data_Types.T_Address)
   is new T_Connectable
   with record
      Address : Data_Types.T_Address := First_Address;
      Bytes   : T_VIA_Bytes_Array := (others => 0);
      State   : T_VIA_State_Ptr := new T_VIA_State;
   end record;

   overriding
   function Get_Address_Space (Via : T_VIA)
   return T_Address_Space;

   overriding
   procedure Tick (Via : in out T_VIA);

end Connectables.Versatile_Interface_Adapter;