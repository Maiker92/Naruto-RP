using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Collections;
using System.Drawing;
namespace AnimeFantasyLauncher.Classes
{
    class KEY
    {
        [DllImport("user32.dll")]
        public static extern int RegisterHotKey(IntPtr hwnd, int id, int fsModifiers, int vk);
        [DllImport("user32.dll")]
        public static extern bool UnregisterHotKey(IntPtr hWnd, int id);
        [DllImport("user32.dll")]
        private static extern short GetAsyncKeyState(Keys vKey);
        [DllImport("user32.dll")]
        private static extern bool SetCursorPos(int X, int Y);
        [DllImport("User32.Dll")]
        private static extern bool ClientToScreen(IntPtr hWnd, ref Point point);
        public static List<HotKey> RegisteredHotKeys = new List<HotKey>();
        public const int
            MOD_ALT = 0x1,
            MOD_CONTROL = 0x2,
            MOD_SHIFT = 0x4,
            MOD_WIN = 0x8,
            MOD_KEYUP = 0x1000,
            WM_HOTKEY = 0x312;
        private static bool toggled = false;
        private static bool[] pressing = new bool[255];
        public static int GetRegisteredHotkeyIndex(int vk, int mod)
        {
            for (int i = 0; i < RegisteredHotKeys.Count; i++)
                if (RegisteredHotKeys[i].vk == vk && RegisteredHotKeys[i].mod == mod)
                    return i;
            return -1;
        }
        public static void ToggleAllHotkeys(bool toggle)
        {
            toggled = toggle;
            for (int i = 0; i < RegisteredHotKeys.Count; i++)
            {
                if (toggle)
                    RegisterHotKey(Classes.APP.MainForm.Handle, RegisteredHotKeys[i].idformat, RegisteredHotKeys[i].mod, RegisteredHotKeys[i].vk);
                else
                    UnregisterHotKey(Classes.APP.MainForm.Handle, RegisteredHotKeys[i].idformat);
            }
        }
        public static void ToggleHotkey(int idx, bool toggle)
        {
            if (toggle)
                RegisterHotKey(Classes.APP.MainForm.Handle, RegisteredHotKeys[idx].idformat, RegisteredHotKeys[idx].mod, RegisteredHotKeys[idx].vk);
            else
                UnregisterHotKey(Classes.APP.MainForm.Handle, RegisteredHotKeys[idx].idformat);
        }
        public static void AddHotkey(int vk, int mod)
        {
            if (GetRegisteredHotkeyIndex(vk, mod) == -1)
            {
                HotKey k = new HotKey(vk, mod);
                RegisteredHotKeys.Add(k);
                if (toggled)
                    RegisterHotKey(Classes.APP.MainForm.Handle, k.idformat, k.mod, k.vk);
            }
        }
        public static void RemoveHotkey(int vk, int mod)
        {
            int kIndex = -1;
            if ((kIndex = GetRegisteredHotkeyIndex(vk, mod)) != -1)
            {
                if (toggled)
                    UnregisterHotKey(Classes.APP.MainForm.Handle, RegisteredHotKeys[kIndex].idformat);
                RegisteredHotKeys.RemoveAt(kIndex);
            }
        }
        public static bool Pressed(Keys key)
        {
            int k = (int)key;
            if (k < 0 || k >= pressing.Length)
                return false;
            int r = (int)GetAsyncKeyState(key);
            if (r != 0)
            {
                if ((bool)pressing[k])
                    return false;
                pressing[k] = true;
                return true;
            }
            else
            {
                if ((bool)pressing[k])
                    pressing[k] = false;
                return false;
            }
        }
        public class HotKey
        {
            public int vk = 0, mod = 0, idformat = 0;
            public HotKey(int v, int m)
            {
                vk = v;
                mod = m;
                idformat = Convert.ToInt32(vk.ToString() + mod.ToString());
            }
        }
        public class Cursor
        {
            public static void SetPos(IntPtr handle, Point p)
            {
                ClientToScreen(handle, ref p);
                SetCursorPos(p.X, p.Y);
            }
        }
    }
}
