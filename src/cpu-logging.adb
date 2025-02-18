with Ada; use Ada;
with Cpu.Status_Register; use Cpu.Status_Register;

package body Cpu.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Last_Finished_Instruction (Cpu : T_Cpu) is
   begin
      if Debug_On then
         Text_IO.Put_Line
           (Debug_File,
               Cpu.Last_Finished_Instruction.Instruction_Type'Image
               & " - "
               & Cpu.Last_Finished_Instruction.Addressing'Image);
      end if;
   end Dump_Last_Finished_Instruction;

   procedure Dump_Current_Instruction (Cpu : T_Cpu) is
   begin
      if Debug_On then
         Text_IO.Put_Line
           (Debug_File, Cpu.Current_Instruction.Instruction_Type'Image
               & " - "
               & Cpu.Current_Instruction.Addressing'Image);
      end if;
   end Dump_Current_Instruction;

   procedure Dump_Registers (Cpu : T_Cpu) is
   begin
      if Debug_On then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put (Debug_File, "A = ");
         Byte_IO.Put (Debug_File, Cpu.Registers.A);
         Text_IO.Put (Debug_File, "  X = ");
         Byte_IO.Put (Debug_File, Cpu.Registers.X);
         Text_IO.Put (Debug_File, "  Y = ");
         Byte_IO.Put (Debug_File, Cpu.Registers.Y);
         Text_IO.Put (Debug_File, "  SP = ");
         Byte_IO.Put (Debug_File, Cpu.Registers.SP);
         Text_IO.Put (Debug_File, "  PC = ");
         Address_IO.Put (Debug_File, Cpu.Registers.PC);
         Text_IO.Put (Debug_File, " SR = ");
         Byte_IO.Put (Debug_File, SR_As_Byte (Cpu.Registers.SR),
                     Width => 8, Base => 2);
         Text_IO.New_Line (Debug_File);
      end if;
   end Dump_Registers;

   procedure Dump_Status (Cpu : T_Cpu) is
   begin
      if Debug_On then
         Text_IO.Put_Line (Debug_File, "------------------------");
         Text_IO.Put_Line
           (Debug_File, "Next Instruction: "
            & Cpu.Current_Instruction.Instruction_Type'Image
            & " - "
            & Cpu.Current_Instruction.Addressing'Image
         );
         Dump_Registers (Cpu);
         Text_IO.Put_Line (Debug_File, "------------------------");
      end if;
   end Dump_Status;

end Cpu.Logging;