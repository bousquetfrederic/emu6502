with Ada; use Ada;
with Ada.Text_IO;
with Cpu.Status_Register; use Cpu.Status_Register;
with Debug;

package body Cpu.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Current_Instruction (Proc : T_Cpu)
   is
      DF : Text_IO.File_Type renames Debug.Debug_File;
   begin
      if Debug_On then
         Text_IO.Put
           (DF,
            "CPU : " &
            Proc.Clock_Counter'Image &
            " : ");
         Text_IO.Put_Line
           (DF,
            Proc.Current_Instruction.Instruction_Type'Image
            & " - "
            & Proc.Current_Instruction.Addressing'Image);
      end if;
   end Dump_Current_Instruction;

   procedure Dump_Clock_Counter (Proc : T_Cpu)
   is
      DF : Text_IO.File_Type renames Debug.Debug_File;
   begin
      if Debug_On then
         Text_IO.Put_Line
           (DF,
            "CPU : " & Proc.Clock_Counter'Image);
      end if;
   end Dump_Clock_Counter;

   procedure Dump_Registers (Proc : T_Cpu)
   is
      DF : Text_IO.File_Type renames Debug.Debug_File;
   begin
      if Debug_On then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (DF,
            "CPU : " &
            Proc.Clock_Counter'Image &
            " : ");
         Text_IO.Put (DF, "A = ");
         Byte_IO.Put (DF, Proc.Registers.A);
         Text_IO.Put (DF, "  X = ");
         Byte_IO.Put (DF, Proc.Registers.X);
         Text_IO.Put (DF, "  Y = ");
         Byte_IO.Put (DF, Proc.Registers.Y);
         Text_IO.Put (DF, "  SP = ");
         Byte_IO.Put (DF, Proc.Registers.SP);
         Text_IO.Put (DF, "  PC = ");
         Address_IO.Put (DF, Proc.Registers.PC);
         Text_IO.Put (DF, " SR = ");
         Byte_IO.Put (DF,
                      SR_As_Byte (Proc.Registers.SR),
                     Width => 8, Base => 2);
         Text_IO.New_Line (DF);
      end if;
   end Dump_Registers;

   procedure Dump_Status (Proc : T_Cpu)
   is
      DF : Text_IO.File_Type renames Debug.Debug_File;
   begin
      if Debug_On then
         Text_IO.Put_Line (DF,
                           "------------------------");
         Text_IO.Put_Line
           (DF,
            "Next Instruction: "
            & Proc.Current_Instruction.Instruction_Type'Image
            & " - "
            & Proc.Current_Instruction.Addressing'Image
         );
         Dump_Registers (Proc);
         Text_IO.Put_Line (DF,
                           "------------------------");
      end if;
   end Dump_Status;

end Cpu.Logging;