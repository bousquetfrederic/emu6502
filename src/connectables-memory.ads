with Ada.Text_IO;

package Connectables.Memory is

   type T_Memory (First_Address, Last_Address : Data_Types.T_Address)
   is new T_Connectable with private;

   type T_Memory_Ptr is access all T_Memory;

   overriding
   function Read_Byte (Mem     : T_Memory;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte;

   overriding
   function Size (Mem : T_Memory)
   return Data_Types.T_Address;

   function Is_Writable (Mem : T_Memory) return Boolean;

   procedure Set_Writable
     (Mem : in out T_Memory;
      W : Boolean := True);

   procedure Load_To_Memory
     (Mem     : in out T_Memory'Class;
      Address :        Data_Types.T_Address;
      Bytes   :        Data_Types.T_Byte_Array);

   procedure Load_Text_File_To_Memory
     (Mem     : in out T_Memory'Class;
      Address : Data_Types.T_Address;
      File    : Ada.Text_IO.File_Type);

   overriding
   procedure Write_Byte
     (Mem     : in out T_Memory;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte);

private

   use type Data_Types.T_Byte;

   type T_Memory (First_Address, Last_Address : Data_Types.T_Address)
   is new T_Connectable
   with record
      Is_Writable : Boolean := True;
      Data        : Data_Types.T_Byte_Array (First_Address .. Last_Address);
   end record;

   overriding
   function Size (Mem : T_Memory)
   return Data_Types.T_Address
   is (Mem.Data'Length);

   function Is_Writable (Mem : T_Memory) return Boolean
   is (Mem.Is_Writable);

end Connectables.Memory;