with Connectables;
with Data_Types;

package Data_Bus is

   Data_Bus_Too_Many_Devices : exception;
   Data_Bus_Address_Range_Overlapping : exception;
   Data_Bus_No_Device_For_Address : exception;

   type T_Data_Bus is limited private;

   type T_Data_Device is access all Connectables.T_Connectable'Class;

   type T_Connected_Device_Nb is range 1 .. 16;

   procedure Connect_Device
      (Bus    : in out T_Data_Bus;
       Device :        T_Data_Device);

   function Read_Byte (Bus     : T_Data_Bus;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte;

   procedure Tick (Bus : in out T_Data_Bus);

   procedure Write_Byte (Bus     : T_Data_Bus;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte);

private

   type T_Connected_Devices_Array is array
     (T_Connected_Device_Nb) of T_Data_Device;

   type T_Data_Bus is limited
   record
      Clock_Counter : Data_Types.T_Clock_Counter := 0;
      Devices       : T_Connected_Devices_Array;
   end record;

end Data_Bus;