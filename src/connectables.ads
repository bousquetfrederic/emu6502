with Data_Types;

package Connectables is

   Connectable_Not_Writable : exception;
   Connectable_Address_Not_In_Range : exception;

   type T_Connectable is abstract tagged limited private;

   function Read_Byte (C       : T_Connectable;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte
   is abstract;

   procedure Write_Byte (C       : in out T_Connectable;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte)
   is abstract;

   function Size (C : T_Connectable) return Data_Types.T_Address
   is abstract;

private

   type T_Connectable is abstract tagged limited null record;

end Connectables;