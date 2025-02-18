with Cpu;
with Cpu.Logging;
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

--   Memory.Load_To_ROM (MyMem, 16#C000#,
--     (16#A9#, 16#10#,          --  LDA #10
--      16#8D#, 16#00#, 16#30#,  --  STA #3000
--      16#AE#, 16#00#, 16#30#,  --  LDX #3000
--      16#BD#, 16#ED#, 16#FF#   --  LDA FFED,X
--      )
--   );

   Cpu.Reset (MyCPU);

   Cpu.Logging.Dump_Status (MyCPU, Standard_Output);
   loop
      begin
         Cpu.Tick (MyCPU, MyMem);
      exception
         when Cpu.Cpu_Was_Killed =>
            exit;
      end;
      Cpu.Logging.Dump_Status (MyCPU, Standard_Output);
   end loop;

end Emu6502;
