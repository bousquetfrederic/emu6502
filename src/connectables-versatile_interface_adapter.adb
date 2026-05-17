package body Connectables.Versatile_Interface_Adapter is

   use type Data_Types.T_Address;
   use type Data_Types.T_Byte;

   subtype T_Address_Range is Data_Types.T_Address
               range 0 .. 16#F#;

   --  Interrupt flag / enable bit masks (6522).
   IRQ_T1  : constant Data_Types.T_Byte := 16#40#;  --  bit 6: Timer 1
   IRQ_T2  : constant Data_Types.T_Byte := 16#20#;  --  bit 5: Timer 2
   IRQ_ANY : constant Data_Types.T_Byte := 16#80#;  --  bit 7: master flag

   --  ACR bit 6 selects Timer 1 free-run (continuous) mode.
   ACR_T1_FREE_RUN : constant Data_Types.T_Byte := 16#40#;

   function Address_To_VIA_Byte
     (Via : T_VIA;
      Address : Data_Types.T_Address)
   return T_VIA_Bytes
   is
      --  Standard 6522 register map. Note that the Oric ROM
      --  relies on $..D being IFR and $..E being IER.
      Pos_To_Byte : constant array (T_Address_Range)
                      of T_VIA_Bytes
        := (16#0# => PORT_B,
            16#1# => PORT_A_HS,
            16#2# => DATA_DIR_B,
            16#3# => DATA_DIR_A,
            16#4# => TIMER_1_LOW,
            16#5# => TIMER_1_HIGH,
            16#6# => TIMER_1_LATCH_LOW,
            16#7# => TIMER_1_LATCH_HIGH,
            16#8# => TIMER_2_LOW,
            16#9# => TIMER_2_HIGH,
            16#A# => SHIFT_REGISTER,
            16#B# => AUX_CONTROL,
            16#C# => PERIPH_CONTROL,
            16#D# => INTERRUPT_FLAGS,
            16#E# => INTERRUPT_ENABLE,
            16#F# => PORT_A_NO_HS);
   begin
      return Pos_To_Byte (Address - Via.Address);
   end Address_To_VIA_Byte;

   overriding
   function Get_Address_Space (Via : T_VIA)
   return T_Address_Space
   is
   begin
      return (First_Address => Via.Address,
              Last_Address  => Via.Address + T_Address_Range'Last);
   end Get_Address_Space;

   --  Computed IFR: bit 7 is set when any enabled flag is active.
   function Effective_Ifr (State : T_VIA_State) return Data_Types.T_Byte
   is
      Base : constant Data_Types.T_Byte := State.Ifr and 16#7F#;
   begin
      if (State.Ifr and State.Ier and 16#7F#) /= 0 then
         return Base or IRQ_ANY;
      else
         return Base;
      end if;
   end Effective_Ifr;

   function Irq_Asserted (Via : T_VIA) return Boolean
   is
   begin
      return (Via.State.Ifr and Via.State.Ier and 16#7F#) /= 0;
   end Irq_Asserted;

   overriding
   function Read_Byte (Via     : T_VIA;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte
   is
      State : T_VIA_State renames Via.State.all;
   begin
      if not Address_In_Address_Space (Address, Via.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      end if;

      case Via.Address_To_VIA_Byte (Address) is
         when TIMER_1_LOW =>
            --  Reading T1C-L acknowledges the Timer 1 interrupt.
            State.Ifr := State.Ifr and not IRQ_T1;
            return Data_Types.Address_To_Word (State.T1_Counter).Low;
         when TIMER_1_HIGH =>
            return Data_Types.Address_To_Word (State.T1_Counter).High;
         when TIMER_1_LATCH_LOW =>
            return Data_Types.Address_To_Word (State.T1_Latch).Low;
         when TIMER_1_LATCH_HIGH =>
            return Data_Types.Address_To_Word (State.T1_Latch).High;
         when TIMER_2_LOW =>
            --  Reading T2C-L acknowledges the Timer 2 interrupt.
            State.Ifr := State.Ifr and not IRQ_T2;
            return Data_Types.Address_To_Word (State.T2_Counter).Low;
         when TIMER_2_HIGH =>
            return Data_Types.Address_To_Word (State.T2_Counter).High;
         when INTERRUPT_FLAGS =>
            return Effective_Ifr (State);
         when INTERRUPT_ENABLE =>
            return State.Ier or IRQ_ANY;
         when AUX_CONTROL =>
            return State.Acr;
         when PORT_B =>
            --  Keyboard not emulated yet (Phase 3). Port B bit 7 is
            --  the keyboard sense line, pulled high; a pressed key
            --  pulls it low. Forcing bit 7 = 1 makes the Atmos ROM
            --  scan conclude "no key pressed" instead of repeating a
            --  phantom key from the default port value.
            return Via.Bytes (PORT_B) or 16#80#;
         when others =>
            return Via.Bytes (Via.Address_To_VIA_Byte (Address));
      end case;
   end Read_Byte;

   overriding
   procedure Write_Byte
     (Via     : in out T_VIA;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte)
   is
      State : T_VIA_State renames Via.State.all;

      procedure Set_Low (A : in out Data_Types.T_Address;
                          B :        Data_Types.T_Byte)
      is
         W : Data_Types.T_Word := Data_Types.Address_To_Word (A);
      begin
         W.Low := B;
         A := Data_Types.Word_To_Address (W);
      end Set_Low;

      procedure Set_High (A : in out Data_Types.T_Address;
                          B :        Data_Types.T_Byte)
      is
         W : Data_Types.T_Word := Data_Types.Address_To_Word (A);
      begin
         W.High := B;
         A := Data_Types.Word_To_Address (W);
      end Set_High;
   begin
      if not Address_In_Address_Space (Address, Via.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      end if;

      case Via.Address_To_VIA_Byte (Address) is
         when TIMER_1_LOW | TIMER_1_LATCH_LOW =>
            Set_Low (State.T1_Latch, Value);
         when TIMER_1_HIGH =>
            --  Writing T1C-H loads the counter from the latch
            --  and starts/clears the Timer 1 interrupt.
            Set_High (State.T1_Latch, Value);
            State.T1_Counter := State.T1_Latch;
            State.Ifr := State.Ifr and not IRQ_T1;
         when TIMER_1_LATCH_HIGH =>
            Set_High (State.T1_Latch, Value);
            State.Ifr := State.Ifr and not IRQ_T1;
         when TIMER_2_LOW =>
            State.T2_Latch_Low := Value;
         when TIMER_2_HIGH =>
            Set_High (State.T2_Counter, Value);
            Set_Low (State.T2_Counter, State.T2_Latch_Low);
            State.Ifr := State.Ifr and not IRQ_T2;
            State.T2_Active := True;
         when INTERRUPT_FLAGS =>
            --  Writing a 1 clears the corresponding flag.
            State.Ifr := State.Ifr and not (Value and 16#7F#);
         when INTERRUPT_ENABLE =>
            if (Value and IRQ_ANY) /= 0 then
               State.Ier := State.Ier or (Value and 16#7F#);
            else
               State.Ier := State.Ier and not (Value and 16#7F#);
            end if;
         when AUX_CONTROL =>
            State.Acr := Value;
            Via.Bytes (AUX_CONTROL) := Value;
         when others =>
            Via.Bytes (Via.Address_To_VIA_Byte (Address)) := Value;
      end case;
   end Write_Byte;

   overriding
   procedure Tick (Via : in out T_VIA)
   is
      State : T_VIA_State renames Via.State.all;
   begin
      --  Timer 1: free-running 16-bit down counter.
      if State.T1_Counter = 0 then
         State.Ifr := State.Ifr or IRQ_T1;
         if (State.Acr and ACR_T1_FREE_RUN) /= 0 then
            State.T1_Counter := State.T1_Latch;
         else
            State.T1_Counter :=
              State.T1_Counter - Data_Types.T_Address'(1);  --  wraps
         end if;
      else
         State.T1_Counter :=
           State.T1_Counter - Data_Types.T_Address'(1);
      end if;

      --  Timer 2: one-shot 16-bit down counter.
      if State.T2_Active then
         if State.T2_Counter = 0 then
            State.Ifr := State.Ifr or IRQ_T2;
            State.T2_Active := False;
         end if;
         State.T2_Counter :=
           State.T2_Counter - Data_Types.T_Address'(1);
      end if;
   end Tick;

end Connectables.Versatile_Interface_Adapter;
