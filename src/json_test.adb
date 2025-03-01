with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Vectors;
with Cpu.Logging;
with Data_Bus;
with Connectables.Memory;
with Cpu;
with Cpu.Debug;
with Data_Types;
with JSON.Parsers;
with JSON.Types;

package body JSON_Test is

   --  Load a JSON scenario of https://github.com/SingleStepTests/65x02
   function Load_JSON_Scenario
     (File : Ada.Text_IO.File_Type;
      S    : String)
   return Natural
   is

      package CM renames Connectables.Memory;
      MyCPU : Cpu.T_Cpu;
      MyBus : Data_Bus.T_Data_Bus;
      MyRam_Ptr : constant CM.T_Memory_Ptr
      := new CM.T_Memory (16#0000#, 16#FFFF#);

      --  json-ada usage from Copilot
      package Types is new JSON.Types (Long_Integer, Long_Float);
      package Parsers is new JSON.Parsers (Types);
      Parser     : Parsers.Parser := Parsers.Create_From_File (S);
      JSON_Value : constant Types.JSON_Value := Parser.Parse;
      use type Types.Value_Kind;

      type T_Memory_Cell is
      record
         Address : Long_Integer;
         Value   : Long_Integer;
      end record;

      package Mem_Vectors is new Ada.Containers.Vectors
        (Index_Type => Natural, Element_Type => T_Memory_Cell);
      Initial_PC  : Long_Integer;
      Initial_A   : Long_Integer;
      Initial_X   : Long_Integer;
      Initial_Y   : Long_Integer;
      Initial_SP  : Long_Integer;
      Initial_SR  : Long_Integer;
      Final_PC    : Long_Integer;
      Final_A     : Long_Integer;
      Final_X     : Long_Integer;
      Final_Y     : Long_Integer;
      Final_SP    : Long_Integer;
      Final_SR    : Long_Integer;
      Initial_Ram : Mem_Vectors.Vector;
      Final_Ram   : Mem_Vectors.Vector;

      Mem_Ok        : Boolean;
      Mem_Value     : Long_Integer;
      Success_Count : Natural := 0;

   begin

      Cpu.Logging.Debug_On := False;

      CM.Set_Writable (MyRam_Ptr.all, True);
      Data_Bus.Connect_Device
        (Bus    => MyBus,
         Device => Data_Bus.T_Data_Device (MyRam_Ptr));

      --  Parse the JSON
      for Element of JSON_Value loop
         Initial_PC := Element.Get ("initial").Get ("pc").Value;
         Initial_A  := Element.Get ("initial").Get ("a").Value;
         Initial_X  := Element.Get ("initial").Get ("x").Value;
         Initial_Y  := Element.Get ("initial").Get ("y").Value;
         Initial_SP := Element.Get ("initial").Get ("s").Value;
         Initial_SR := Element.Get ("initial").Get ("p").Value;
         Final_PC   := Element.Get ("final").Get ("pc").Value;
         Final_A    := Element.Get ("final").Get ("a").Value;
         Final_X    := Element.Get ("final").Get ("x").Value;
         Final_Y    := Element.Get ("final").Get ("y").Value;
         Final_SP   := Element.Get ("final").Get ("s").Value;
         Final_SR   := Element.Get ("final").Get ("p").Value;
         Initial_Ram := Mem_Vectors.Empty_Vector;
         for Mem_Entry of Element.Get ("initial").Get ("ram") loop
            Initial_Ram.Append
              ((Address => Mem_Entry.Get (1).Value,
                Value   => Mem_Entry.Get (2).Value));
         end loop;
         Final_Ram := Mem_Vectors.Empty_Vector;
         for Mem_Entry of Element.Get ("final").Get ("ram") loop
            Final_Ram.Append
              ((Address => Mem_Entry.Get (1).Value,
                Value   => Mem_Entry.Get (2).Value));
         end loop;

         --  Load the RAM
         for M of Initial_Ram loop
            Data_Bus.Write_Byte
              (Bus     => MyBus,
               Address => Data_Types.T_Address (M.Address),
               Value   => Data_Types.T_Byte (M.Value));
         end loop;
         --  Load the CPU
         Cpu.Debug.Set_PC (MyCPU, Initial_PC);
         Cpu.Debug.Set_A (MyCPU, Initial_A);
         Cpu.Debug.Set_X (MyCPU, Initial_X);
         Cpu.Debug.Set_Y (MyCPU, Initial_Y);
         Cpu.Debug.Set_SP (MyCPU, Initial_SP);
         Cpu.Debug.Set_SR (MyCPU, Initial_SR);
         --  Tick the CPU
         Cpu.Debug.Tick_One_Instruction (MyCPU, MyBus);
         --  Check the Result
         if Cpu.Debug.Get_PC (MyCPU) = Final_PC and then
            Cpu.Debug.Get_A (MyCPU) = Final_A and then
            Cpu.Debug.Get_X (MyCPU) = Final_X and then
            Cpu.Debug.Get_Y (MyCPU) = Final_Y and then
            Cpu.Debug.Get_SP (MyCPU) = Final_SP and then
            Cpu.Debug.Get_SR (MyCPU) = Final_SR
         then
            --  If all registers are Ok
            --  also check the RAM.
            Mem_Ok := True;
            for M of Final_Ram loop
               Mem_Value := Long_Integer
                             (Data_Bus.Read_Byte
                               (Bus     => MyBus,
                                Address => Data_Types.T_Address
                                            (M.Address)));
               if M.Value /= Mem_Value
               then
                  Put_Line (File, "Name: " &
                            Element.Get ("name").Image);
                  Put_Line (File, "Address " & M.Address'Image &
                            " should be " & M.Value'Image &
                            " found " & Mem_Value'Image);
                  Mem_Ok := False;
                  exit;
               end if;
            end loop;
            if Mem_Ok then
               Success_Count := Success_Count + 1;
            end if;
         else
            Put_Line (File, "Name: " & Element.Get ("name").Image);
            if Cpu.Debug.Get_PC (MyCPU) /= Final_PC then
               Put_Line (File, "PC should be " & Final_PC'Image &
                        " found " & Cpu.Debug.Get_PC (MyCPU)'Image);
            end if;
            if Cpu.Debug.Get_A (MyCPU) /= Final_A then
               Put_Line (File, "A  should be " & Final_A'Image &
                        " found " & Cpu.Debug.Get_A (MyCPU)'Image);
            end if;
            if Cpu.Debug.Get_X (MyCPU) /= Final_X then
               Put_Line (File, "X  should be " & Final_X'Image &
                        " found " & Cpu.Debug.Get_X (MyCPU)'Image);
            end if;
            if Cpu.Debug.Get_Y (MyCPU) /= Final_Y then
               Put_Line (File, "Y  should be " & Final_Y'Image &
                        " found " & Cpu.Debug.Get_Y (MyCPU)'Image);
            end if;
            if Cpu.Debug.Get_SP (MyCPU) /= Final_SP then
               Put_Line (File, "SP should be " & Final_SP'Image &
                        " found " & Cpu.Debug.Get_SP (MyCPU)'Image);
            end if;
            if Cpu.Debug.Get_SR (MyCPU) /= Final_SR then
               Put_Line (File, "SR should be " & Final_SR'Image &
                        " found " & Cpu.Debug.Get_SR (MyCPU)'Image);
            end if;
         end if;
      end loop;
         Put_Line (File, "Nb success:" & Success_Count'Image);
      return Success_Count;
   end Load_JSON_Scenario;

end JSON_Test;