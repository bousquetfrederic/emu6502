with Ada.Text_IO; use Ada.Text_IO;
with Data_Bus;
with Data_Bus.Logging;
with Connectables.Memory;
with Connectables.Video;
with Cpu;
with Cpu.Logging;
with Data_Types;

package body Emulation is

   procedure Run_Rom (Rom_Name : String;
                      Rom_Type : T_Rom_Type) is

      package CM renames Connectables.Memory;
      package CV renames Connectables.Video;

      use type Data_Types.T_Address;
      use type Data_Types.T_Clock_Counter;

      MyCPU : Cpu.T_Cpu;
      MyBus : Data_Bus.T_Data_Bus;
      MyRom_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#C000#, 16#FFFF#);
      MyRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#0000#, 16#BB7F#);
      MyVid_Ptr : constant CV.T_Video_Ptr
      := new CV.T_Video (16#BB80#, 40, 28);
      MySmallRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#BFE0#, 16#BFFF#);
      MyScreen  : Ada.Text_IO.File_Type;

      Dummy_Boolean : Boolean;

   begin

      CM.Set_Writable (MyRam_Ptr.all, True);
      CM.Set_Writable (MyRom_Ptr.all, True);
      CM.Set_Writable (MySmallRam_Ptr.all, True);

      if Rom_Type = TEXT then
         declare
            MyProgram : Ada.Text_IO.File_Type;
         begin
            --  Reset Vector $C000
            CM.Write_Byte (MyRom_Ptr.all, 16#FFFC#, 16#00#);
            CM.Write_Byte (MyRom_Ptr.all, 16#FFFD#, 16#C0#);
            --  IRQ Vector $D000
            CM.Write_Byte (MyRom_Ptr.all, 16#FFFE#, 16#00#);
            CM.Write_Byte (MyRom_Ptr.all, 16#FFFF#, 16#D0#);
            --  NMI Vector $E000
            CM.Write_Byte (MyRom_Ptr.all, 16#FFFA#, 16#00#);
            CM.Write_Byte (MyRom_Ptr.all, 16#FFFB#, 16#E0#);

            --  NMI does Push A, LDA EE, Pull A and return
            CM.Write_Byte (MyRom_Ptr.all, 16#E000#, 16#48#);
            CM.Write_Byte (MyRom_Ptr.all, 16#E001#, 16#A9#);
            CM.Write_Byte (MyRom_Ptr.all, 16#E002#, 16#EE#);
            CM.Write_Byte (MyRom_Ptr.all, 16#E003#, 16#68#);
            CM.Write_Byte (MyRom_Ptr.all, 16#E004#, 16#40#);

            --  IRQ/BRK does Push A, LDA BB, Pull A and return
            CM.Write_Byte (MyRom_Ptr.all, 16#D000#, 16#48#);
            CM.Write_Byte (MyRom_Ptr.all, 16#D001#, 16#A9#);
            CM.Write_Byte (MyRom_Ptr.all, 16#D002#, 16#BB#);
            CM.Write_Byte (MyRom_Ptr.all, 16#D003#, 16#68#);
            CM.Write_Byte (MyRom_Ptr.all, 16#D004#, 16#40#);

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
            Cpu.Logging.Debug_On := False;
            Data_Bus.Logging.Debug_On := True;
            Data_Bus.Logging.Address_Space_Of_Interest
              := (16#BB80#, 16#BFDF#);
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
       Device => Data_Bus.T_Data_Device (MyRam_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MySmallRam_Ptr));

      Data_Bus.Connect_Device
      (Bus    => MyBus,
       Device => Data_Bus.T_Data_Device (MyVid_Ptr));

      Cpu.Reset (MyCPU);

      loop
         begin
            Cpu.Tick (MyCPU, MyBus, Dummy_Boolean);
            Data_Bus.Tick (MyBus);
            if Cpu.Clock_Counter (MyCPU) mod 1000000 = 0 then
               Ada.Text_IO.Put_Line ("1 second");
            end if;
            if Cpu.Clock_Counter (MyCPU) mod 20000 = 1 then
               Create (MyScreen, Out_File, "screen.txt");
               MyVid_Ptr.Refresh (MyScreen);
               Close (MyScreen);
            end if;
            if Cpu.Clock_Counter (MyCPU) mod 200000 = 99999
            then
               Cpu.Interrupt (MyCPU, False);
            end if;
         exception
            when Cpu.Cpu_Was_Killed =>
               exit;
         end;
      end loop;

   end Run_Rom;

end Emulation;