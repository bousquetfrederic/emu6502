with Ada.Text_IO; use Ada.Text_IO;
with Data_Bus;
with Data_Bus.Logging;
with Connectables.Memory;
with Connectables.Video;
with Connectables.Versatile_Interface_Adapter;
with Cpu;
with Data_Types;
with Ticker;

package body Emulation is

   procedure Run_Rom (Rom_Name : String;
                      Rom_Type : T_Rom_Type) is

      package CM renames Connectables.Memory;
      package CV renames Connectables.Video;
      package CVia renames Connectables.Versatile_Interface_Adapter;

      use type Data_Types.T_Address;

      MyCPU : Cpu.T_Cpu;
      MyBus : Data_Bus.T_Data_Bus;
      MyRom_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#C000#, 16#FFFF#);
      MyLowRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#0000#, 16#2FF#);
      MyVia_Ptr : constant CVia.T_VIA_Ptr
      := new CVia.T_VIA (16#300#);
      MyPage3Ram_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#310#, 16#3FF#);
      MyHighRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#400#, 16#BB7F#);
      MyVid_Ptr : constant CV.T_Video_Ptr
      := new CV.T_Video (16#BB80#, 28, 40);
      MySmallRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#BFE0#, 16#BFFF#);
      MyScreen  : Ada.Text_IO.File_Type;

      Dummy_Boolean : Boolean;

   begin

      CM.Set_Writable (MyLowRam_Ptr.all, True);
      CM.Set_Writable (MyRom_Ptr.all, True);
      CM.Set_Writable (MyPage3Ram_Ptr.all, True);
      CM.Set_Writable (MyHighRam_Ptr.all, True);
      CM.Set_Writable (MySmallRam_Ptr.all, True);
      if Rom_Type = TEXT then
         declare
            MyProgram : Ada.Text_IO.File_Type;
         begin
            Data_Bus.Logging.Address_Space_Of_Interest
              := (16#0000#, 16#FFFF#);
            --  No synthetic reset/IRQ/NMI vectors: a real Oric ROM
            --  carries its own vectors and handlers at $FFFA-$FFFF.

            Open (MyProgram, In_File, Rom_Name);

            CM.Load_Text_File_To_Memory
              (MyRom_Ptr.all, 16#C000#, MyProgram);

            Close (MyProgram);
         end;
      else
         declare
            MyProgram : CM.Byte_Sequential_IO.File_Type;
            use CM.Byte_Sequential_IO;
         begin
            Data_Bus.Logging.Address_Space_Of_Interest
              := (16#0000#, 16#FFFF#);
            CM.Byte_Sequential_IO.Open (MyProgram, In_File, Rom_Name);
            CM.Load_Binary_File_To_Memory
              (MyRom_Ptr.all, 16#C000#, MyProgram);
         end;
      end if;

      CM.Set_Writable (MyRom_Ptr.all, False);

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyRom_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyLowRam_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyVia_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyPage3Ram_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyHighRam_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MySmallRam_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyVid_Ptr));

      Cpu.Reset (MyCPU);

      Ticker.Init_Clock;

      Frames :
      loop
         for Cycle in 1 .. Ticker.Cycles_Per_Frame loop
            begin
               Cpu.Tick (MyCPU, MyBus, Dummy_Boolean);
               Data_Bus.Tick (MyBus);
               --  The 6522 VIA timers drive the maskable IRQ.
               if CVia.Irq_Asserted (MyVia_Ptr.all) then
                  Cpu.Interrupt (MyCPU, True);
               end if;
               Ticker.Count_Cycle;
            exception
               when Cpu.Cpu_Was_Killed =>
                  exit Frames;
            end;
         end loop;

         --  One video frame is done: refresh the screen and
         --  pace the emulation to a real 50 Hz / 1 MHz.
         Create (MyScreen, Out_File, "screen.txt");
         MyVid_Ptr.Refresh (MyScreen);
         Close (MyScreen);
         Ticker.End_Of_Frame;
      end loop Frames;

   end Run_Rom;

end Emulation;