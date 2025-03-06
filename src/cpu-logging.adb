with Ada; use Ada;
with Cpu.Status_Register; use Cpu.Status_Register;

package body Cpu.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Current_Instruction (Proc : T_Cpu)
   is
      DF : Text_IO.File_Access renames Proc.Debugging.Debug_File;
   begin
      if Proc.Debugging.Debug_On then
         Text_IO.Put
           (DF.all,
            "CPU : " &
            Proc.Clock_Counter'Image &
            " : ");
         Text_IO.Put_Line
           (DF.all,
            Proc.Current_Instruction.Instruction_Type'Image
            & " - "
            & Proc.Current_Instruction.Addressing'Image);
      end if;
   end Dump_Current_Instruction;

   procedure Dump_Clock_Counter (Proc : T_Cpu)
   is
      DF : Text_IO.File_Access renames Proc.Debugging.Debug_File;
   begin
      if Proc.Debugging.Debug_On then
         Text_IO.Put_Line
           (DF.all,
            "CPU : " & Proc.Clock_Counter'Image);
      end if;
   end Dump_Clock_Counter;

   procedure Dump_Registers (Proc : T_Cpu)
   is
      DF : Text_IO.File_Access renames Proc.Debugging.Debug_File;
   begin
      if Proc.Debugging.Debug_On then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (DF.all,
            "CPU : " &
            Proc.Clock_Counter'Image &
            " : ");
         Text_IO.Put (DF.all, "A = ");
         Byte_IO.Put (DF.all, Proc.Registers.A);
         Text_IO.Put (DF.all, "  X = ");
         Byte_IO.Put (DF.all, Proc.Registers.X);
         Text_IO.Put (DF.all, "  Y = ");
         Byte_IO.Put (DF.all, Proc.Registers.Y);
         Text_IO.Put (DF.all, "  SP = ");
         Byte_IO.Put (DF.all, Proc.Registers.SP);
         Text_IO.Put (DF.all, "  PC = ");
         Address_IO.Put (DF.all, Proc.Registers.PC);
         Text_IO.Put (DF.all, " SR = ");
         Byte_IO.Put (DF.all,
                      SR_As_Byte (Proc.Registers.SR),
                     Width => 8, Base => 2);
         Text_IO.New_Line (DF.all);
      end if;
   end Dump_Registers;

   procedure Dump_Status (Proc : T_Cpu)
   is
      DF : Text_IO.File_Access renames Proc.Debugging.Debug_File;
   begin
      if Proc.Debugging.Debug_On then
         Text_IO.Put_Line (DF.all,
                           "------------------------");
         Text_IO.Put_Line
           (DF.all,
            "Next Instruction: "
            & Proc.Current_Instruction.Instruction_Type'Image
            & " - "
            & Proc.Current_Instruction.Addressing'Image
         );
         Dump_Registers (Proc);
         Text_IO.Put_Line (DF.all,
                           "------------------------");
      end if;
   end Dump_Status;

end Cpu.Logging;