with Ada.Text_IO;

package Connectables.Video.Logging is

   Debug_On : Boolean := True;
   Debug_File : Ada.Text_IO.File_Type :=
                  Ada.Text_IO.Standard_Output;

   procedure Dump_Screen (Vid : T_Video);

end Connectables.Video.Logging;