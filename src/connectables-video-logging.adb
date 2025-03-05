with Ada; use Ada;

package body Connectables.Video.Logging is

   procedure Dump_Screen (Vid : T_Video)
   is
   begin
      if Debug_On then
         for L in Vid.Data'Range (1) loop
            Text_IO.Put
              (Debug_File, "VIDEO : " &
                           Vid.Clock_Counter'Image &
                           " : ");
            for C in Vid.Data'Range (2) loop
               Text_IO.Put
                 (Debug_File, Character'Val
                   (Vid.Data (L, C)));
            end loop;
            Text_IO.New_Line (Debug_File);
         end loop;
      end if;
   end Dump_Screen;

end Connectables.Video.Logging;