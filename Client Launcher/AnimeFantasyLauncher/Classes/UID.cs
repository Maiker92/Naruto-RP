using System;
using System.Collections.Generic;
using System.Text;
using System.Management;
using System.Text.RegularExpressions;
using R = AnimeFantasyLauncher.Resources;
using C = AnimeFantasyLauncher.Classes;
namespace AnimeFantasyLauncher.Classes
{
    class UID
    {
        private static bool flag = false;
        private static string PlayerIP_ = string.Empty;
        public static string PlayerIP
        {
            get
            {
                try
                {
                    if (PlayerIP_.Length == 0)
                    {
                        if (!flag)
                        {
                            C.TRD.AddWork(new TRD.BackgroundWork("GetIP"));
                            flag = true;
                        }
                        return string.Empty;
                    }
                    else return PlayerIP_;
                }
                catch
                {
                    return string.Empty;
                }
            }
        }
        public static void UpdateIP(string ip)
        {
            PlayerIP_ = ip;
        }
        public static string UniqueID(bool localhost = false)
        {
            return REG.Read("PlayerName", "Player", R.Strings.SAMPRegKey).ToString() + "/" + (localhost ? "127.0.0.1" : UID.PlayerIP);
        }
        public static string GetHWID()
        {
            ManagementObjectCollection mbsList = null;
            ManagementObjectSearcher mbs = new ManagementObjectSearcher("Select * From Win32_processor");
            mbsList = mbs.Get();
            string hwid = string.Empty;
            foreach (ManagementObject mo in mbsList)
                hwid = mo["ProcessorID"].ToString();
            return hwid;
        }
    }
}