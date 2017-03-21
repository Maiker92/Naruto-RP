using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Win32;
namespace AnimeFantasyLauncher.Classes
{
    class REG
    {
        public static object Read(string key, string defaultValue, string reg)
        {
            RegistryKey RegKey = Registry.CurrentUser.OpenSubKey(reg);
            if (RegKey == null)
                return null;
            object tmp = RegKey.GetValue(key, defaultValue);
            RegKey.Close();
            return tmp;
        }
        public static void Write(string key, string value, string reg, bool c = false)
        {
            RegistryKey RegKey = c ? Registry.CurrentUser.CreateSubKey(reg) : Registry.CurrentUser.OpenSubKey(reg, true);
            RegKey.SetValue(key, value);
            RegKey.Close();
        }
    }
}