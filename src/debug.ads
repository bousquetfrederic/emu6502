with Ada.Text_IO;

package Debug is

   type T_Debug is
   record
      Debug_On   : Boolean;
      Debug_File : Ada.Text_IO.File_Access
        := Ada.Text_IO.Standard_Output;
   end record;

end Debug;