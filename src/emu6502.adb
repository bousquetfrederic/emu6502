with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Cpu.Logging;
with Log_File;
with Data_Bus.Logging;
with Emulation;

procedure Emu6502 is

   Argument_Error : exception;

   package Cli renames Ada.Command_Line;

begin

   --  Command line arguments can be :
   --  binary [name of rom]
   if Cli.Argument_Count < 2 then
      raise Argument_Error;
   end if;

   for I in 3 .. Cli.Argument_Count loop
      if Cli.Argument (I) = "log_cpu" then
         Cpu.Logging.Log_On := True;
      elsif Cli.Argument (I) = "log_bus" then
         Data_Bus.Logging.Log_On := True;
      end if;
   end loop;
   Create (Log_File.Log_File, Out_File, "debug.txt");

   if Cli.Argument (1) = "binary" then
      Emulation.Run_Rom (Cli.Argument (2));
   else
      raise Argument_Error;
   end if;

   Close (Log_File.Log_File);

exception

   when Argument_Error =>

      New_Line;
      Put_Line ("Format is:");
      Put_Line ("emu6502 binary [binary rom filename]");

end Emu6502;
