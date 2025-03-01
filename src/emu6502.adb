with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Cpu;
with JSON_Test;
with Emulation;

procedure Emu6502 is

   Argument_Error : exception;

   package Cli renames Ada.Command_Line;

begin

   --  Command line arguments can be :
   --  text [name of rom]
   --  json [name of test file]
   if Cli.Argument_Count < 2 then
      raise Argument_Error;
   end if;

   if Cli.Argument (1) = "text" then
      Emulation.Run_Text_Rom (Cli.Argument (2));
   elsif Cli.Argument (1) = "json" then
      declare
         Result_File : File_Type;
         Test_Score  : Natural;
      begin
         Create (Result_File, Out_File, "results.txt");
         for I in 2 .. Cli.Argument_Count loop
            Put_Line (Result_File, "---------------------------");
            Put_Line (Result_File, "Loading " & Cli.Argument (I));
            begin
               Test_Score :=
                 JSON_Test.Load_JSON_Scenario
                  (Result_File, Cli.Argument (I));
               if Test_Score = 10000
               then
                  Put_Line (Result_File,
                            Cli.Argument (I) & " --> Ok.");
                  Put_Line (Cli.Argument (I) & " --> Ok.");
               else
                  Put_Line (Result_File,
                            Cli.Argument (I) & " --> Not Ok --> " &
                            Test_Score'Image);
                  Put_Line (Cli.Argument (I) & " --> Not Ok --> " &
                            Test_Score'Image);
               end if;
            exception
               when Cpu.Cpu_Was_Killed =>
                  Put_Line (Result_File,
                            Cli.Argument (I) & " --> CPU was killed.");
                  Put_Line (Cli.Argument (I) & " --> CPU was killed.");
               when Cpu.Invalid_Instruction =>
                  Put_Line (Result_File,
                            Cli.Argument (I) & " --> Invalid instruction.");
                  Put_Line (Cli.Argument (I) & " --> Invalid instruction.");
            end;
         end loop;
         Close (Result_File);
      end;
   else
      raise Argument_Error;
   end if;

exception

   when Argument_Error =>

      New_Line;
      Put_Line ("Format is:");
      Put_Line ("emu6502 text [text rom filename]");
      Put_Line ("emu6502 json [json test filename]");

end Emu6502;
