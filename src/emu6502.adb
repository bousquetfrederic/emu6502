with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Connectables.Video;
with Connectables.Video.Logging;
with Cpu;
with Cpu.Logging;
with Log_File;
with Data_Bus.Logging;
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

   for I in 3 .. Cli.Argument_Count loop
      if Cli.Argument (I) = "log_cpu" then
         Cpu.Logging.Log_On := True;
      elsif Cli.Argument (I) = "log_bus" then
         Data_Bus.Logging.Log_On := True;
      elsif Cli.Argument (I) = "log_video" then
         Connectables.Video.Logging.Log_On := True;
      end if;
   end loop;
   Create (Log_File.Log_File, Out_File, "debug.txt");

   if Cli.Argument (1) = "text" then
      Emulation.Run_Rom (Cli.Argument (2), Emulation.TEXT);
   elsif Cli.Argument (1) = "binary" then
      Emulation.Run_Rom (Cli.Argument (2), Emulation.BINARY);
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

   Close (Log_File.Log_File);

exception

   when Argument_Error =>

      New_Line;
      Put_Line ("Format is:");
      Put_Line ("emu6502 text [text rom filename]");
      Put_Line ("emu6502 json [json test filename]");

end Emu6502;
