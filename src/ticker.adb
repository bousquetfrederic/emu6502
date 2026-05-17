with Ada.Real_Time; use Ada.Real_Time;

package body Ticker is

   --  20000 cycles at 1 MHz == 20 ms == one 50 Hz video frame.
   Frame_Period : constant Time_Span := Microseconds (20_000);

   I_Clock_Counter : Data_Types.T_Clock_Counter := 0;
   I_Next_Frame    : Time;

   function Clock_Counter return Data_Types.T_Clock_Counter
   is (I_Clock_Counter);

   procedure Init_Clock
   is
   begin
      I_Clock_Counter := 0;
      I_Next_Frame := Clock + Frame_Period;
   end Init_Clock;

   procedure Count_Cycle
   is
      use type Data_Types.T_Clock_Counter;
   begin
      I_Clock_Counter := I_Clock_Counter + 1;
   end Count_Cycle;

   procedure End_Of_Frame
   is
   begin
      --  If the emulator kept up, wait for the frame boundary.
      --  If it fell behind, the deadline is already in the past
      --  and we run flat out to catch up.
      delay until I_Next_Frame;
      I_Next_Frame := I_Next_Frame + Frame_Period;
   end End_Of_Frame;

end Ticker;
