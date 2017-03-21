using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.Windows.Forms;
using System.Drawing;
using System.Resources;
using System.Reflection;
using System.Linq;
using R = AnimeFantasyLauncher.Resources;
using IWshRuntimeLibrary;
namespace AnimeFantasyLauncher.Classes
{
    class APP
    {
        public static Hashtable CFG = new Hashtable();
        public static List<GPL.Game> Games = new List<GPL.Game>();
        public static GPL.Server CurrentServer = null;
        public static GPL.Game LoadedGame = null;
        public static bool Playing = false;
        public static Main MainForm = null;
        public static void LoadConfig()
        {
            CFG.Clear();
            string[] lines = NET.ReadFromWeb(R.Strings.Site + "configuration.txt").Trim().Split('\n'), lines2;
            for (int i = 0, count = lines.GetLength(0); i < count; i++)
                CFG[lines[i].Split('=')[0]] = lines[i].Split('=')[1];
            lines = APP.CFG["games"].ToString().Split('|');
            lines2 = APP.CFG["gamecodes"].ToString().Split('|');
            for (int i = 0, count = lines.GetLength(0); i < count; i++)
                APP.Games.Add(new GPL.Game(lines[i], lines2[i]));
        }
        public static void Exit()
        {
            Environment.Exit(0);
        }
        public static void UpdateChangelog(ref TextBox textBox, string text)
        {
            textBox.Text += text + "\r\n";
            textBox.SelectionStart = textBox.Text.Length;
            textBox.ScrollToCaret();
            textBox.Parent.Refresh();
            textBox.Refresh();
        }
        public static void Release()
        {
            if (System.IO.File.Exists(GTA.Path(GTA.GTASAPath.GTA3Backup)))
            {
                string gameIMG = LoadedGame.GameDirectory + "\\gta3.img";
                System.IO.File.Move(GTA.Path(GTA.GTASAPath.GTA3IMG), gameIMG);
                System.IO.File.Move(GTA.Path(GTA.GTASAPath.GTA3Backup), GTA.Path(GTA.GTASAPath.GTA3IMG));
                for (int i = 0; i < LoadedGame.ReplacedFiles.Count; i++)
                {
                    System.IO.File.Move(GTA.Path(GTA.GTASAPath.Directory) + LoadedGame.ReplacedFiles[i].Path, LoadedGame.GameDirectory + "\\required\\" + LoadedGame.ReplacedFiles[i].WebName);
                    if (LoadedGame.ReplacedFiles[i].FileType == GPL.ReplacedFile.FT_REPLACE || LoadedGame.ReplacedFiles[i].FileType == GPL.ReplacedFile.FT_MANUAL)
                        System.IO.File.Move(GTA.Path(GTA.GTASAPath.Directory) + LoadedGame.ReplacedFiles[i].Path + "-AF-Backup", GTA.Path(GTA.GTASAPath.Directory) + LoadedGame.ReplacedFiles[i].Path);
                }
            }
            LoadedGame = null;
        }
        public static bool GameExists(string cn)
        {
            for (int i = 0; i < Games.Count; i++)
                if (Games[i].CodeName == cn)
                    return true;
            return false;
        }
        public static bool IsInstalled()
        {
            return Directory.Exists(GTA.Path(GTA.GTASAPath.AF));
        }
        public static void CreateShortcut(string shortcutName, string icon, string par = "")
        {
            try
            {
                using (LNK shortcut = new LNK())
                {
                    shortcut.Target = Application.ExecutablePath;
                    //shortcut.WorkingDirectory = Path.GetDirectoryName(Application.ExecutablePath); (CJ) I don't need this shit!
                    shortcut.Description = shortcutName;
                    shortcut.DisplayMode = LNK.LinkDisplayMode.edmNormal;
                    shortcut.IconPath = Classes.GTA.Path(GTA.GTASAPath.AFIcons) + "/" + icon + ".ico";
                    shortcut.Arguments = par;
                    shortcut.Save(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), shortcutName + ".lnk"));
                }
                /* Old shortcut
                string shortcutLocation = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), shortcutName + ".lnk");
                WshShell shell = new WshShell();
                IWshShortcut shortcut = (IWshShortcut)shell.CreateShortcut(shortcutLocation);
                shortcut.Description = shortcutName;
                shortcut.IconLocation = Classes.GTA.Path(GTA.GTASAPath.AFIcons) + "/" + icon + ".ico";
                shortcut.TargetPath = Assembly.GetExecutingAssembly().Location;
                shortcut.Arguments = par;
                shortcut.Save();*/
            }
            catch
            {
                MessageBox.Show("Error in shortcut creating.");
            }
        }
        public static void AppInitialInstall()
        {
            if (!Directory.Exists(GTA.Path(GTA.GTASAPath.AF)))
                Directory.CreateDirectory(GTA.Path(GTA.GTASAPath.AF));
            if (!Directory.Exists(GTA.Path(GTA.GTASAPath.AFIcons)))
            {
                Directory.CreateDirectory(GTA.Path(GTA.GTASAPath.AFIcons));
                ResourceSet list = Resources.Icons.ResourceManager.GetResourceSet(new System.Globalization.CultureInfo("en-us"), true, true);
                foreach (DictionaryEntry img in list)
                    using (FileStream s = new FileStream(GTA.Path(GTA.GTASAPath.AFIcons) + "/" + img.Key + ".ico", FileMode.Create))
                        (img.Value as Icon).Save(s);
            }
            CreateShortcut("Anime Fantasy", "A");
        }
        public static void SetMainFormVisible(bool toggle)
        {
            Classes.APP.MainForm.ShowInTaskbar = toggle;
            Classes.APP.MainForm.WindowState = toggle ? FormWindowState.Normal : FormWindowState.Minimized;
        }
        public static void Fix()
        {
            for(int i = 0; i < Games.Count; i++)
            {
                LoadedGame = Games[i];
                Release();
            }
            LoadedGame = null;
        }
        public static string[] ReadLines(string text)
        {
            return text.Trim().Split('\n').Where(x => !x.StartsWith("#")).ToArray();
        }
        public static bool IsValidNickname(string name)
        {
            for (int i = 0; i < name.Length; i++)
                if (!(name[i] >= '0' && name[i] <= '9')
                && !(name[i] >= 'A' && name[i] <= 'Z')
                && !(name[i] >= 'a' && name[i] <= 'z')
                && name[i] != '_' && name[i] != '[' && name[i] != ']'
                && name[i] != '.' && name[i] != '(' && name[i] != ')'
                && name[i] != '@' && name[i] != '$')
                    return false;
            return name.Length >= 3 || name.Length <= 24;
        }
        public static double RadianToDegree(double angle)
        {
            return angle * (180.0 / Math.PI);
        }
    }
}