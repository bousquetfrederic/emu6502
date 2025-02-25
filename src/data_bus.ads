with Memory;
with Data_Types;

package Data_Bus is

   type T_Data_Bus is limited private;

   type T_Data_Device is access all Memory.T_Memory;

   procedure Connect_Device
      (Data_Bus : in out T_Data_Bus;
       Device   :        T_Data_Device);

   function Read_Byte (Bus     : T_Data_Bus;
                       Address : Data_Types.T_Address)
     return Data_Types.T_Byte;

   procedure Write_Byte (Bus     : T_Data_Bus;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte);

private

   type T_Data_Bus is limited
   record
      Device : T_Data_Device;
   end record;

end Data_Bus;