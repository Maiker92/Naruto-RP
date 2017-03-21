using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using C = AnimeFantasyLauncher.Classes;
using R = AnimeFantasyLauncher.Resources;
using System.Runtime.InteropServices;
namespace AnimeFantasyLauncher.Classes
{
    class GTA
    {
        [DllImport("user32.dll")]
        private static extern int GetForegroundWindow();
        [DllImport("user32.dll")]
        private static extern int GetWindowText(int hWnd, StringBuilder text, int count); 
        public enum GTASAPath { Directory, GTA3IMG, AF, GTA3Backup, AFSounds, AFIcons }
        private static string Dir()
        {
            string p = REG.Read("gta_sa_exe", Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles) + "/Rockstar Games/GTA San Andreas", R.Strings.SAMPRegKey).ToString();
            return p.Remove(p.LastIndexOf('\\'));
        }
        public static string Path(GTASAPath path, C.GPL.Game game = null)
        {
            switch (path)
            {
                case GTASAPath.Directory: return Dir();
                case GTASAPath.GTA3IMG: return Dir() + "\\models\\gta3.img";
                case GTASAPath.AF: return Dir() + "\\Anime Fantasy";
                case GTASAPath.GTA3Backup: return Dir() + "\\models\\gta3-AF-backup.img";
                case GTASAPath.AFSounds: return Dir() + "\\Anime Fantasy\\" + game.Name + "\\sounds";
                case GTASAPath.AFIcons: return Dir() + "\\Anime Fantasy\\icons";
            }
            return null;
        }
        public static bool IsActive()
        {
            const int nChars = 256;
            int handle = 0;
            StringBuilder Buff = new StringBuilder(nChars);
            handle = GetForegroundWindow();
            if (GetWindowText(handle, Buff, nChars) > 0)
                return Buff.ToString() == "GTA:SA:MP";
            return false;
        }
    }
}