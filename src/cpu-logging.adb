with Ada; use Ada;
with Cpu.Status_Register; use Cpu.Status_Register;

package body Cpu.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Status (Cpu  : T_Cpu;
                          File : Ada.Text_IO.File_Type) is
   begin
      Byte_IO.Default_Base := 16;
      Address_IO.Default_Base := 16;
      Text_IO.Put_Line (File, "------------------------");
      Text_IO.Put_Line
        (File, "Last Finished Intruction = "
               & Cpu.Last_Finished_Instruction.Instruction_Type'Image
               & " - "
               & Cpu.Last_Finished_Instruction.Addressing'Image);
      Text_IO.Put_Line
        (File, "Current Instruction = "
               & Cpu.Current_Instruction.Instruction_Type'Image
               & " - "
               & Cpu.Current_Instruction.Addressing'Image);
      Text_IO.Put_Line
        (File, "Cycles Left = "
               & Cpu.Current_Instruction.Cycles'Image);
      Text_IO.Put (File, "A = ");
      Byte_IO.Put (File, Cpu.Registers.A);
      Text_IO.Put (File, "  X = ");
      Byte_IO.Put (File, Cpu.Registers.X);
      Text_IO.Put (File, "  Y = ");
      Byte_IO.Put (File, Cpu.Registers.Y);
      Text_IO.Put (File, "  SP = ");
      Byte_IO.Put (File, Cpu.Registers.SP);
      Text_IO.Put (File, "  PC = ");
      Address_IO.Put (File, Cpu.Registers.PC);
      Text_IO.New_Line (File);
      Text_IO.Put (File, "SR = ");
      Byte_IO.Put (File, SR_As_Byte (Cpu.Registers.SR),
                   Width => 8, Base => 2);
      Text_IO.New_Line (File);
   end Dump_Status;

end Cpu.Logging;