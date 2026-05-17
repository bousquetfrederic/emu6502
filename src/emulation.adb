with Data_Bus;
with Data_Bus.Logging;
with Connectables.Memory;
with Connectables.Versatile_Interface_Adapter;
with Cpu;
with Data_Types;
with Ticker;
with Oric_Display;
with Screen;

package body Emulation is

   procedure Run_Rom (Rom_Name : String) is

      package CM renames Connectables.Memory;
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
      --  $0400-$BFFF is plain RAM; the ULA scans the screen
      --  ($BB80) and character generator ($B400) out of it.
      MyHighRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#400#, 16#BFFF#);

      Dummy_Boolean : Boolean;
      Frame_No      : Natural := 0;
      Fb            : Oric_Display.Framebuffer;

   begin

      CM.Set_Writable (MyLowRam_Ptr.all, True);
      CM.Set_Writable (MyRom_Ptr.all, True);
      CM.Set_Writable (MyPage3Ram_Ptr.all, True);
      CM.Set_Writable (MyHighRam_Ptr.all, True);
      declare
         MyProgram : CM.Byte_Sequential_IO.File_Type;
         use CM.Byte_Sequential_IO;
      begin
         Data_Bus.Logging.Address_Space_Of_Interest
           := (16#0000#, 16#FFFF#);
         --  No synthetic reset/IRQ/NMI vectors: a real Oric ROM
         --  carries its own vectors and handlers at $FFFA-$FFFF.
         CM.Byte_Sequential_IO.Open (MyProgram, In_File, Rom_Name);
         CM.Load_Binary_File_To_Memory
           (MyRom_Ptr.all, 16#C000#, MyProgram);
      end;

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

      Cpu.Reset (MyCPU);

      Screen.Open ("Oric");
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

         --  One video frame is done: render the Oric screen, show
         --  it in the window, and pace to a real 50 Hz / 1 MHz.
         Oric_Display.Render (MyBus, Frame_No, Fb);
         Screen.Present (Fb);
         exit Frames when Screen.Quit_Requested;
         Frame_No := Frame_No + 1;
         Ticker.End_Of_Frame;
      end loop Frames;

      Screen.Close;

   end Run_Rom;

end Emulation;