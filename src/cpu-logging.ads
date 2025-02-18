with Ada.Text_IO;
package Cpu.Logging is

   Debug_On : Boolean := True;
   Debug_File : Ada.Text_IO.File_Type :=
                  Ada.Text_IO.Standard_Output;

   procedure Dump_Clock_Counter (Proc : T_Cpu);
   procedure Dump_Current_Instruction (Proc : T_Cpu);
   procedure Dump_Registers (Proc : T_Cpu);
   procedure Dump_Status (Proc : T_Cpu);

end Cpu.Logging;