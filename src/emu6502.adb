with Cpu;
with Memory;
with Ada.Text_IO; use Ada.Text_IO;

procedure Emu6502 is

   MyCPU : Cpu.T_Cpu;
   MyMem : Memory.T_Memory;
   MyProgram : Ada.Text_IO.File_Type;

begin
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFC#, 16#00#);
   Memory.Write_Byte_To_ROM (MyMem, 16#FFFD#, 16#C0#);

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
