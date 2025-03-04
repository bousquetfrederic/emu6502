with Ada; use Ada;
with Cpu.Status_Register; use Cpu.Status_Register;

package body Cpu.Logging is

   package Byte_IO is new Text_IO.Modular_IO (Data_Types.T_Byte);
   package Address_IO is new Text_IO.Modular_IO (Data_Types.T_Address);

   procedure Dump_Current_Instruction (Proc : T_Cpu) is
   begin
      if Debug_On then
         Text_IO.Put
           (Debug_File, "CPU : " &
                        Proc.Clock_Counter'Image &
                        " : ");
         Text_IO.Put_Line
           (Debug_File, Proc.Current_Instruction.Instruction_Type'Image
               & " - "
               & Proc.Current_Instruction.Addressing'Image);
      end if;
   end Dump_Current_Instruction;

   procedure Dump_Clock_Counter (Proc : T_Cpu) is
   begin
      if Debug_On then
         Text_IO.Put_Line
           (Debug_File, "CPU : " & Proc.Clock_Counter'Image);
      end if;
   end Dump_Clock_Counter;

   procedure Dump_Registers (Proc : T_Cpu) is
   begin
      if Debug_On then
         Byte_IO.Default_Base := 16;
         Address_IO.Default_Base := 16;
         Text_IO.Put
           (Debug_File, "CPU : " &
                        Proc.Clock_Counter'Image &
                        " : ");
         Text_IO.Put (Debug_File, "A = ");
         Byte_IO.Put (Debug_File, Proc.Registers.A);
         Text_IO.Put (Debug_File, "  X = ");
         Byte_IO.Put (Debug_File, Proc.Registers.X);
         Text_IO.Put (Debug_File, "  Y = ");
         Byte_IO.Put (Debug_File, Proc.Registers.Y);
         Text_IO.Put (Debug_File, "  SP = ");
         Byte_IO.Put (Debug_File, Proc.Registers.SP);
         Text_IO.Put (Debug_File, "  PC = ");
         Address_IO.Put (Debug_File, Proc.Registers.PC);
         Text_IO.Put (Debug_File, " SR = ");
         Byte_IO.Put (Debug_File, SR_As_Byte (Proc.Registers.SR),
                     Width => 8, Base => 2);
         Text_IO.New_Line (Debug_File);
      end if;
   end Dump_Registers;

   procedure Dump_Status (Proc : T_Cpu) is
   begin
      if Debug_On then
         Text_IO.Put_Line (Debug_File, "------------------------");
         Text_IO.Put_Line
           (Debug_File, "Next Instruction: "
            & Proc.Current_Instruction.Instruction_Type'Image
            & " - "
            & Proc.Current_Instruction.Addressing'Image
         );
         Dump_Registers (Proc);
         Text_IO.Put_Line (Debug_File, "------------------------");
      end if;
   end Dump_Status;

end Cpu.Logging;