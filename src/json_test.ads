with Ada.Text_IO;

package JSON_Test is

   --  Load a JSON scenario of https://github.com/SingleStepTests/65x02
   function Load_JSON_Scenario
     (File : Ada.Text_IO.File_Type;
      S    : String)
   return Natural;

end JSON_Test;