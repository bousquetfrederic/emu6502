with Ada; use Ada;
with Ticker;

package body Connectables.Video.Logging is

   procedure Dump_Screen (Vid : T_Video;
                          File : Ada.Text_IO.File_Type
                          := Ada.Text_IO.Standard_Output)
   is
   begin
      if Log_On then
         for L in Vid.Data'Range (1) loop
            Text_IO.Put
              (File, "VIDEO : " &
                     Ticker.Clock_Counter'Image &
                     " : ");
            for C in Vid.Data'Range (2) loop
               Text_IO.Put
                 (File, Character'Val
                   (Vid.Data (L, C)));
            end loop;
            Text_IO.New_Line (File);
         end loop;
      end if;
   end Dump_Screen;

end Connectables.Video.Logging;