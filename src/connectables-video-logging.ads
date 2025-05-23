with Ada.Text_IO;

package Connectables.Video.Logging is

   Log_On : Boolean := False;

   procedure Dump_Screen (Vid  : T_Video;
                          File : Ada.Text_IO.File_Type
                          := Ada.Text_IO.Standard_Output);

end Connectables.Video.Logging;