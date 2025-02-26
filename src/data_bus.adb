package body Data_Bus is

   procedure Connect_Device
      (Bus    : in out T_Data_Bus;
       Device :        T_Data_Device)
   is
   begin
      Bus.Device := Device;
   end Connect_Device;

   function Read_Byte (Bus      : T_Data_Bus;
                       Address  : Data_Types.T_Address)
   return Data_Types.T_Byte is
   begin
      return Connectables.Read_Byte (Bus.Device.all, Address);
   end Read_Byte;

   procedure Write_Byte (Bus     :        T_Data_Bus;
                         Address :        Data_Types.T_Address;
                         Value   :        Data_Types.T_Byte) is
   begin
      Connectables.Write_Byte (Bus.Device.all, Address, Value);
   end Write_Byte;

end Data_Bus;