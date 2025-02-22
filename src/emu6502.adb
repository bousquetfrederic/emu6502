with Cpu;
with Memory;
with Ada.Text_IO; use Ada.Text_IO;

procedure Emu6502 is

   MyCPU : Cpu.T_Cpu;
   MyMem : Memory.T_Memory;
   MyProgram : Ada.Text_IO.File_Type;

begin
   --  Reset Vector $C000
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFC#, 16#00#);
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFD#, 16#C0#);
   --  IRQ Vector $D000
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFE#, 16#00#);
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFF#, 16#D0#);
   --  NMI Vector $E000
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFA#, 16#00#);
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFB#, 16#E0#);

   --  NMI does Push A, LDA EE, Pull A and return
   Memory.Write_Byte_To_ROM (MyMem, 16#E000#, 16#48#);
   Memory.Write_Byte_To_ROM (MyMem, 16#E001#, 16#A9#);
   Memory.Write_Byte_To_ROM (MyMem, 16#E002#, 16#EE#);
   Memory.Write_Byte_To_ROM (MyMem, 16#E003#, 16#68#);
   Memory.Write_Byte_To_ROM (MyMem, 16#E004#, 16#40#);

   --  IRQ/BRK does Push A, LDA BB, Pull A and return
   Memory.Write_Byte_To_ROM (MyMem, 16#D000#, 16#48#);
   Memory.Write_Byte_To_ROM (MyMem, 16#D001#, 16#A9#);
   Memory.Write_Byte_To_ROM (MyMem, 16#D002#, 16#BB#);
   Memory.Write_Byte_To_ROM (MyMem, 16#D003#, 16#68#);
   Memory.Write_Byte_To_ROM (MyMem, 16#D004#, 16#40#);

   Open (MyProgram, In_File, "rom.txt");

   Memory.Load_Text_File_To_ROM
     (MyMem, 16#C000#, MyProgram);

   Close (MyProgram);

   Cpu.Reset (MyCPU);

   loop
      begin
         Cpu.Tick (MyCPU, MyMem);
         if Cpu.Clock_Counter (MyCPU) = 143
         then
            Cpu.Interrupt (MyCPU, False);
         end if;
      exception
         when Cpu.Cpu_Was_Killed =>
            exit;
      end;
   end loop;

end Emu6502;
