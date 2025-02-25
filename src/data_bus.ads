with Memory;
with Data_Types;

package Data_Bus is

   type T_Data_Bus is private;

   type T_Data_Device is access all Memory.T_Memory;

   procedure Connect_Device
      (Data_Bus : in out T_Data_Bus;
       Device   :        T_Data_Device);

private

   type T_Data_Bus is
   record
      Device : T_Data_Device;
   end record;

end Data_Bus;