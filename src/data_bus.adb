package body Data_Bus is

   procedure Connect_Device
      (Data_Bus : in out T_Data_Bus;
       Device   :        T_Data_Device)
   is
   begin
      Data_Bus.Device := Device;
   end Connect_Device;

end Data_Bus;