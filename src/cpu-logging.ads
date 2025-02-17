with Ada.Text_IO;
package Cpu.Logging is

   procedure Dump_Status (Cpu  : T_Cpu;
                          File : Ada.Text_IO.File_Type);

end Cpu.Logging;