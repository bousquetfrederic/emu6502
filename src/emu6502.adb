with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Emulation;

procedure Emu6502 is

   Argument_Count_Error : exception;

   package Cli renames Ada.Command_Line;

begin

   --  Command line arguments can be :
   --  text [name of rom]
   --  json [name of test file]
   if Cli.Argument_Count /= 2 then
      raise Argument_Count_Error;
   end if;

   if Cli.Argument (1) = "text" then
      Emulation.Run_Text_Rom (Cli.Argument (2));
   end if;

exception

   when Argument_Count_Error =>

      New_Line;
      Put_Line ("Format is:");
      Put_Line ("emu6502 text [text rom filename]");
      Put_Line ("emu6502 json [json test filename]");

end Emu6502;
