with Interfaces;            use Interfaces;
with Interfaces.C;          use Interfaces.C;
with System;                use type System.Address;

--  Dependency-free presenter using the Win32 GDI API directly.
--  user32.dll / gdi32.dll ship with Windows, so the mingw GNAT
--  linker resolves these with no install and no DLL hunting.
--  This is pure Ada: the Win32 C ABI is reached through imported
--  subprograms, the same technique a C-library binding uses.
package body Screen is

   pragma Linker_Options ("-lgdi32");
   pragma Linker_Options ("-luser32");

   subtype DWORD   is Interfaces.Unsigned_32;
   subtype WORD    is Interfaces.Unsigned_16;
   subtype UINT    is Interfaces.Unsigned_32;
   subtype LONG    is Interfaces.Integer_32;
   subtype W_Param  is Interfaces.Unsigned_64;
   subtype L_Param  is Interfaces.Integer_64;
   subtype L_Result is Interfaces.Integer_64;
   subtype BOOL    is Interfaces.C.int;

   type WNDPROC is access function
     (HWnd   : System.Address;
      Msg    : UINT;
      WParam : W_Param;
      LParam : L_Param) return L_Result
     with Convention => Stdcall;

   type WNDCLASSA is record
      Style       : UINT           := 0;
      Wnd_Proc    : WNDPROC        := null;
      Cls_Extra   : Interfaces.C.int := 0;
      Wnd_Extra   : Interfaces.C.int := 0;
      Instance    : System.Address := System.Null_Address;
      Icon        : System.Address := System.Null_Address;
      Cursor      : System.Address := System.Null_Address;
      Background  : System.Address := System.Null_Address;
      Menu_Name   : System.Address := System.Null_Address;
      Class_Name  : System.Address := System.Null_Address;
   end record with Convention => C;

   type POINT is record
      X, Y : LONG := 0;
   end record with Convention => C;

   type MSG is record
      HWnd     : System.Address := System.Null_Address;
      Message  : UINT    := 0;
      WParam   : W_Param  := 0;
      LParam   : L_Param  := 0;
      Time     : DWORD   := 0;
      Pt       : POINT;
      LPrivate : DWORD   := 0;
   end record with Convention => C;

   type BITMAPINFOHEADER is record
      Size           : DWORD := 40;
      Width          : LONG  := 0;
      Height         : LONG  := 0;
      Planes         : WORD  := 1;
      Bit_Count      : WORD  := 32;
      Compression    : DWORD := 0;   --  BI_RGB
      Size_Image     : DWORD := 0;
      X_Pels_Per_M   : LONG  := 0;
      Y_Pels_Per_M   : LONG  := 0;
      Clr_Used       : DWORD := 0;
      Clr_Important  : DWORD := 0;
   end record with Convention => C;

   --  Win32 imports -------------------------------------------------------

   function Get_Module_Handle (Name : System.Address) return System.Address
     with Import, Convention => Stdcall, External_Name => "GetModuleHandleA";

   function Register_Class (WC : System.Address) return WORD
     with Import, Convention => Stdcall, External_Name => "RegisterClassA";

   function Create_Window
     (Ex_Style    : DWORD;
      Class_Name  : System.Address;
      Window_Name : System.Address;
      Style       : DWORD;
      X, Y        : Interfaces.C.int;
      W, H        : Interfaces.C.int;
      Parent      : System.Address;
      Menu        : System.Address;
      Instance    : System.Address;
      Param       : System.Address) return System.Address
     with Import, Convention => Stdcall, External_Name => "CreateWindowExA";

   function Show_Window (HWnd : System.Address; Cmd : Interfaces.C.int)
     return BOOL
     with Import, Convention => Stdcall, External_Name => "ShowWindow";

   function Def_Window_Proc
     (HWnd : System.Address; Msg : UINT;
      WParam : W_Param; LParam : L_Param) return L_Result
     with Import, Convention => Stdcall, External_Name => "DefWindowProcA";

   procedure Post_Quit_Message (Code : Interfaces.C.int)
     with Import, Convention => Stdcall, External_Name => "PostQuitMessage";

   function Peek_Message
     (Msg : System.Address; HWnd : System.Address;
      Min, Max, Remove : UINT) return BOOL
     with Import, Convention => Stdcall, External_Name => "PeekMessageA";

   function Translate_Message (Msg : System.Address) return BOOL
     with Import, Convention => Stdcall, External_Name => "TranslateMessage";

   function Dispatch_Message (Msg : System.Address) return L_Result
     with Import, Convention => Stdcall, External_Name => "DispatchMessageA";

   function Get_DC (HWnd : System.Address) return System.Address
     with Import, Convention => Stdcall, External_Name => "GetDC";

   function Release_DC (HWnd, DC : System.Address) return Interfaces.C.int
     with Import, Convention => Stdcall, External_Name => "ReleaseDC";

   function Destroy_Window (HWnd : System.Address) return BOOL
     with Import, Convention => Stdcall, External_Name => "DestroyWindow";

   function Stretch_DI_Bits
     (DC : System.Address;
      X_Dst, Y_Dst, W_Dst, H_Dst : Interfaces.C.int;
      X_Src, Y_Src, W_Src, H_Src : Interfaces.C.int;
      Bits : System.Address;
      Info : System.Address;
      Usage : UINT;
      Rop : DWORD) return Interfaces.C.int
     with Import, Convention => Stdcall, External_Name => "StretchDIBits";

   --  Window constants ----------------------------------------------------

   WS_OVERLAPPEDWINDOW : constant DWORD := 16#00CF_0000#;
   WS_VISIBLE          : constant DWORD := 16#1000_0000#;
   CW_USEDEFAULT       : constant Interfaces.C.int := Interfaces.C.int'First;
   SW_SHOW             : constant Interfaces.C.int := 5;
   PM_REMOVE           : constant UINT := 1;
   WM_DESTROY          : constant UINT := 16#0002#;
   WM_CLOSE            : constant UINT := 16#0010#;
   WM_QUIT             : constant UINT := 16#0012#;
   SRCCOPY             : constant DWORD := 16#00CC_0020#;
   DIB_RGB_COLORS      : constant UINT := 0;

   --  State ---------------------------------------------------------------

   type Pixel is mod 2 ** 32;
   type Pixel_Buffer is
     array (0 .. Oric_Display.Width * Oric_Display.Height - 1)
     of aliased Pixel with Convention => C;

   --  0x00RRGGBB, the in-memory layout of a 32-bpp BI_RGB DIB.
   Palette : constant array (Oric_Display.Color_Index) of Pixel :=
     (0 => 16#00_0000#, 1 => 16#FF_0000#, 2 => 16#00_FF00#,
      3 => 16#FF_FF00#, 4 => 16#00_00FF#, 5 => 16#FF_00FF#,
      6 => 16#00_FFFF#, 7 => 16#FF_FFFF#);

   Pixels      : aliased Pixel_Buffer := (others => 0);
   Info        : aliased BITMAPINFOHEADER;
   HWnd        : System.Address := System.Null_Address;
   The_Scale   : Positive := 3;
   Quit_Flag   : Boolean := False;
   Window_Text : aliased Interfaces.C.char_array (0 .. 127) :=
     (others => Interfaces.C.nul);
   Class_Name  : aliased constant Interfaces.C.char_array :=
     Interfaces.C.To_C ("OricEmuWindow");

   function Wnd_Proc
     (HWnd   : System.Address;
      Msg    : UINT;
      WParam : W_Param;
      LParam : L_Param) return L_Result
     with Convention => Stdcall;

   function Wnd_Proc
     (HWnd   : System.Address;
      Msg    : UINT;
      WParam : W_Param;
      LParam : L_Param) return L_Result
   is
   begin
      if Msg = WM_CLOSE or else Msg = WM_DESTROY then
         Quit_Flag := True;
         Post_Quit_Message (0);
         return 0;
      end if;
      return Def_Window_Proc (HWnd, Msg, WParam, LParam);
   end Wnd_Proc;

   procedure Open (Title : String; Scale : Positive := 3)
   is
      HInst : constant System.Address :=
        Get_Module_Handle (System.Null_Address);
      WC    : aliased WNDCLASSA;
      Atom  : WORD;
      T     : constant Interfaces.C.char_array := Interfaces.C.To_C (Title);
   begin
      The_Scale := Scale;

      for I in T'Range loop
         exit when I > Window_Text'Last - 1;
         Window_Text (I) := T (I);
      end loop;

      WC.Style      := 3;                 --  CS_HREDRAW or CS_VREDRAW
      WC.Wnd_Proc   := Wnd_Proc'Access;
      WC.Instance   := HInst;
      WC.Class_Name := Class_Name'Address;

      Atom := Register_Class (WC'Address);
      if Atom = 0 then
         raise Program_Error with "RegisterClass failed";
      end if;

      HWnd := Create_Window
        (Ex_Style    => 0,
         Class_Name  => Class_Name'Address,
         Window_Name => Window_Text'Address,
         Style       => WS_OVERLAPPEDWINDOW or WS_VISIBLE,
         X           => CW_USEDEFAULT,
         Y           => CW_USEDEFAULT,
         W           => Interfaces.C.int
                          (Oric_Display.Width  * Scale + 16),
         H           => Interfaces.C.int
                          (Oric_Display.Height * Scale + 39),
         Parent      => System.Null_Address,
         Menu        => System.Null_Address,
         Instance    => HInst,
         Param       => System.Null_Address);

      if HWnd = System.Null_Address then
         raise Program_Error with "CreateWindowEx failed";
      end if;

      --  Top-down DIB (negative height) so row 0 is the top line.
      Info.Width  := LONG (Oric_Display.Width);
      Info.Height := -LONG (Oric_Display.Height);

      declare
         Ignore : constant BOOL := Show_Window (HWnd, SW_SHOW);
      begin
         null;
      end;
   end Open;

   procedure Present (Fb : Oric_Display.Framebuffer)
   is
      DC : constant System.Address := Get_DC (HWnd);
   begin
      for Y in 0 .. Oric_Display.Height - 1 loop
         for X in 0 .. Oric_Display.Width - 1 loop
            Pixels (Y * Oric_Display.Width + X) := Palette (Fb (Y, X));
         end loop;
      end loop;

      declare
         Ignore : constant Interfaces.C.int := Stretch_DI_Bits
           (DC    => DC,
            X_Dst => 0, Y_Dst => 0,
            W_Dst => Interfaces.C.int (Oric_Display.Width  * The_Scale),
            H_Dst => Interfaces.C.int (Oric_Display.Height * The_Scale),
            X_Src => 0, Y_Src => 0,
            W_Src => Interfaces.C.int (Oric_Display.Width),
            H_Src => Interfaces.C.int (Oric_Display.Height),
            Bits  => Pixels'Address,
            Info  => Info'Address,
            Usage => DIB_RGB_COLORS,
            Rop   => SRCCOPY);
         Ignore_2 : constant Interfaces.C.int := Release_DC (HWnd, DC);
      begin
         null;
      end;
   end Present;

   function Quit_Requested return Boolean
   is
      M : aliased MSG;
   begin
      while Peek_Message
              (M'Address, System.Null_Address, 0, 0, PM_REMOVE) /= 0
      loop
         if M.Message = WM_QUIT then
            Quit_Flag := True;
         end if;
         declare
            Ignore   : constant BOOL := Translate_Message (M'Address);
            Ignore_2 : constant L_Result := Dispatch_Message (M'Address);
         begin
            null;
         end;
      end loop;
      return Quit_Flag;
   end Quit_Requested;

   procedure Close
   is
   begin
      if HWnd /= System.Null_Address then
         declare
            Ignore : constant BOOL := Destroy_Window (HWnd);
         begin
            HWnd := System.Null_Address;
         end;
      end if;
   end Close;

end Screen;
