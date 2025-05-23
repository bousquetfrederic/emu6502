with Data_Bus;

private package Cpu.Data_Access is

   Cpu_Internal_Wrong_Data_Access : exception;

   type T_Location_Kind is (L_ACCUMULATOR, L_X, L_Y, L_MEMORY);
   type T_Location is
   record
      Kind : T_Location_Kind;
      Address : Data_Types.T_Address;
   end record;

   function Addressing_Points_To
     (Addressing_Type : T_Valid_Addressing_Types;
      Bus             : Data_Bus.T_Data_Bus;
      Registers       : T_Registers)
   return T_Location;

   function Fetch_Address
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Bus             : Data_Bus.T_Data_Bus;
      Registers       : T_Registers)
   return Data_Types.T_Address
   with
      Pre => Addressing_Type = ABSOLUTE
             or else
             Addressing_Type = INDIRECT;

   function Addresses_On_Same_Page
     (Address_1 : Data_Types.T_Address;
      Address_2 : Data_Types.T_Address)
   return Boolean;

   function Fetch_Byte
     (Location  : T_Location;
      Bus       : Data_Bus.T_Data_Bus;
      Registers : T_Registers)
   return Data_Types.T_Byte;

   function Fetch_Byte
     (Addressing_Type : T_Addressing_Types_To_Fetch_Bytes;
      Bus             : Data_Bus.T_Data_Bus;
      Registers       : T_Registers)
     return Data_Types.T_Byte;

   function Get_Address_At_Address
     (Bus      : Data_Bus.T_Data_Bus;
      Address  : Data_Types.T_Address)
   return Data_Types.T_Address;

   procedure Pull_Address
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :    out Data_Types.T_Address;
      Stack_Page :        Data_Types.T_Address);

   procedure Pull_Byte
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :    out Data_Types.T_Byte;
      Stack_Page :        Data_Types.T_Address);

   procedure Push_Address
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :        Data_Types.T_Address;
      Stack_Page :        Data_Types.T_Address);

   procedure Push_Byte
     (Bus        :        Data_Bus.T_Data_Bus;
      Registers  : in out T_Registers;
      Value      :        Data_Types.T_Byte;
      Stack_Page :        Data_Types.T_Address);

   function SP_To_Location
     (SP         : Data_Types.T_Byte;
      Stack_Page : Data_Types.T_Address)
   return T_Location;

   procedure Store_Byte
     (Location  :        T_Location;
      Bus       :        Data_Bus.T_Data_Bus;
      Registers : in out T_Registers;
      Value     :        Data_Types.T_Byte);

   procedure Store_Byte
     (Addressing_Type :        T_Addressing_Types_To_Fetch_Bytes;
      Bus             :        Data_Bus.T_Data_Bus;
      Registers       : in out T_Registers;
      Value           :        Data_Types.T_Byte);

end Cpu.Data_Access;