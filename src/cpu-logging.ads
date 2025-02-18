with Ada.Text_IO;
package Cpu.Logging is

   Debug_On : Boolean := True;
   Debug_File : Ada.Text_IO.File_Type :=
                  Ada.Text_IO.Standard_Output;

   procedure Dump_Status (Cpu : T_Cpu);
   procedure Dump_Current_Instruction (Cpu : T_Cpu);
   procedure Dump_Last_Finished_Instruction (Cpu : T_Cpu);
   procedure Dump_Registers (Cpu : T_Cpu);

end Cpu.Logging;