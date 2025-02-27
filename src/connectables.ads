with Data_Types;

package Connectables is

   Connectable_Not_Writable : exception;
   Connectable_Address_Not_In_Range : exception;

   type T_Address_Space is
   record
      First_Address : Data_Types.T_Address;
      Last_Address : Data_Types.T_Address;
   end record;

   function Address_Spaces_Separated
     (AS_1, AS_2 : T_Address_Space)
   return Boolean is
     ((AS_1.First_Address not in AS_2.First_Address .. AS_2.Last_Address)
      and then
      (AS_1.Last_Address not in AS_2.First_Address .. AS_2.Last_Address));

   function Address_In_Address_Space
     (Address : Data_Types.T_Address;
      AS      : T_Address_Space)
   return Boolean is
     (Address in AS.First_Address .. AS.Last_Address);

   type T_Connectable is abstract tagged limited private;

   procedure Tick (C : in out T_Connectable'Class);

   function Read_Byte (C       : T_Connectable;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte
   is abstract;

   procedure Write_Byte (C       : in out T_Connectable;
                         Address : Data_Types.T_Address;
                         Value   : Data_Types.T_Byte)
   is abstract;

   function Get_Address_Space (C : T_Connectable)
   return T_Address_Space is abstract;

private

   type T_Connectable is abstract tagged limited
   record
      Clock_Counter : Data_Types.T_Clock_Counter := 0;
   end record;

end Connectables;