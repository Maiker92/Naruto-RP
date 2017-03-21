using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Windows.Forms;
using R = AnimeFantasyLauncher.Resources;
using System.Media;
using System.Threading;
using System.Reflection;
using System.Resources;
using System.Collections;
namespace AnimeFantasyLauncher.Classes
{
    public class GPL
    {
        public class Game
        {
            public string Name = string.Empty, CodeName = string.Empty, GameDirectory = string.Empty, Site = string.Empty;
            public List<Skin> Skins = null;
            public List<Server> Servers = null;
            public List<ReplacedFile> ReplacedFiles = null;
            public List<Sound> Sounds = null;
            public Game(string name, string cn)
            {
                Name = name;
                CodeName = cn;
                GameDirectory = GTA.Path(GTA.GTASAPath.AF) + "\\" + Name;
                Skins = new List<Skin>();
                Servers = new List<Server>();
                ReplacedFiles = new List<ReplacedFile>();
                Sounds = new List<Sound>();
                ResourceSet list = Resources.Sites.ResourceManager.GetResourceSet(new System.Globalization.CultureInfo("en-us"), true, true);
                foreach (DictionaryEntry str in list)
                    if (str.Key.ToString() == CodeName)
                    {
                        Site = str.Value.ToString();
                        break;
                    }
                string gameURL = R.Strings.Site + CodeName;
                string[] lines = APP.ReadLines(NET.ReadFromWeb(gameURL + "/models.txt")), tmp;
                for (int i = 0; i < lines.Length; i++)
                {
                    tmp = lines[i].Split(';');
                    Skins.Add(new Skin(tmp[0].Trim(), tmp[2].Trim(), tmp[1].Trim()));
                }
                lines = APP.ReadLines(NET.ReadFromWeb(gameURL + "/servers.txt"));
                for (int i = 0; i < lines.Length; i++)
                {
                    tmp = lines[i].Split(';');
                    Servers.Add(new Server(tmp[0].Trim(), tmp[1].Trim(), tmp[2].Trim(), Convert.ToInt16(tmp[3]), tmp[4].Trim(), tmp[5].Trim()));
                }
                lines = APP.ReadLines(NET.ReadFromWeb(gameURL + "/files.txt"));
                for (int i = 0; i < lines.Length; i++)
                {
                    tmp = lines[i].Split(';');
                    ReplacedFiles.Add(new ReplacedFile(tmp[0].Trim(), tmp[1].Trim(), tmp[2].Trim(), Convert.ToInt16(tmp[3].Trim())));
                }
                lines = APP.ReadLines(NET.ReadFromWeb(gameURL + "/sounds.txt"));
                for (int i = 0; i < lines.Length; i++)
                    Sounds.Add(new Sound(lines[i].Trim()));
            }
            public bool IsInstalled()
            {
                return Directory.Exists(GameDirectory);
            }
            public void Install(ref Forms.InstallGame ig)
            {
                ig.UpdateStep(0, "Preparing installation...");
                ig.PrepareLoading(1);
                Classes.APP.AppInitialInstall();
                List<string> directories = new List<string>();
                directories.Add(GameDirectory);
                directories.Add(GameDirectory + "\\models");
                directories.Add(GameDirectory + "\\required");
                directories.Add(GameDirectory + "\\sounds");
                ig.PrepareLoading(100); // copy gta3
                ig.PrepareLoading(25); // load gta3
                ig.PrepareLoading(directories.Count);
                ig.PrepareLoading(Skins.Count * 2); // dl, replace in gta3
                ig.PrepareLoading(ReplacedFiles.Count);
                ig.PrepareLoading(Sounds.Count);
                ig.PrepareLoading(5); // reg
                ig.PrepareLoading(2); // shortcut
                ig.UpdateStep(0, "Creating directories...");
                for (int i = 0; i < directories.Count; i++)
                {
                    ig.UpdateStep(0, "Creating: " + directories[i]);
                    if (!Directory.Exists(directories[i]))
                        Directory.CreateDirectory(directories[i]);
                    ig.UpdateStep(1, "Created: " + directories[i]);
                }
                ig.UpdateStep(0, "Directories successfully created. Creating a copy of gta3.img (this could take a few seconds/minutes)...");
                string gameURL = R.Strings.Site + CodeName, gameIMG = GameDirectory + "\\gta3.img";
                File.Copy(GTA.Path(GTA.GTASAPath.GTA3IMG), gameIMG);
                ig.UpdateStep(100, "Copy created successfully. Downloading models...");
                for (int i = 0; i < Skins.Count; i++)
                {
                    try
                    {
                        NET.Download(gameURL + "/skins/" + Skins[i].WebName + ".txd", GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".txd");
                        NET.Download(gameURL + "/skins/" + Skins[i].WebName + ".dff", GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".dff");
                        ig.UpdateStep(1, "Downloaded successfully: \"" + Skins[i].SkinName + "\"");
                    }
                    catch
                    {
                        ig.UpdateStep(1, "Downloaded failed: \"" + Skins[i].SkinName + "\"");
                    }
                }
                ig.UpdateStep(0, "All skins downloaded successfully. Loading gta3.img...");
                IMG.ModelList gta3 = IMG.Load(gameIMG);
                ig.UpdateStep(25, "Loaded successfully. Installing skins...");
                for (int i = 0; i < Skins.Count; i++)
                {
                    try
                    {
                        IMG.Replace(gta3, (gta3.IndexPointers[Skins[i].ModelTarget + ".txd"] as IMG.Model).Offset, (gta3.IndexPointers[Skins[i].ModelTarget + ".txd"] as IMG.Model).Size / 2 * 2048, GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".txd");
                        IMG.Replace(gta3, (gta3.IndexPointers[Skins[i].ModelTarget + ".dff"] as IMG.Model).Offset, (gta3.IndexPointers[Skins[i].ModelTarget + ".dff"] as IMG.Model).Size / 2 * 2048, GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".dff");
                        ig.UpdateStep(1, "Installed successfully: \"" + Skins[i].SkinName + "\"");
                    }
                    catch
                    {
                        ig.UpdateStep(1, "Installation failed: \"" + Skins[i].SkinName + "\"");
                    }
                }
                ig.UpdateStep(0, "Finished installing skins. Downloading required files...");
                for (int i = 0; i < ReplacedFiles.Count; i++)
                {
                    try
                    {
                        if (ReplacedFiles[i].FileType == ReplacedFile.FT_MANUAL)
                            File.Move(Environment.CurrentDirectory + "\\" + ReplacedFiles[i].WebName, GameDirectory + "\\required\\" + ReplacedFiles[i].WebName);
                        else
                            NET.Download(gameURL + "/files/" + ReplacedFiles[i].WebName, GameDirectory + "\\required\\" + ReplacedFiles[i].WebName);
                        ig.UpdateStep(1, "Downloaded successfully: \"" + ReplacedFiles[i].Description + "\"");
                    }
                    catch
                    {
                        ig.UpdateStep(1, "Download failed: \"" + ReplacedFiles[i].Description + "\"");
                    }
                }
                ig.UpdateStep(0, "Finished downloading required files. Downloading sound files...");
                for (int i = 0; i < Sounds.Count; i++)
                {
                    try
                    {
                        NET.Download(gameURL + "/sounds/" + Sounds[i].SoundName, GameDirectory + "\\sounds\\" + Sounds[i].SoundName);
                        ig.UpdateStep(1, "Downloaded successfully: \"" + Sounds[i].SoundName + "\"");
                    }
                    catch
                    {
                        ig.UpdateStep(1, "Download failed: \"" + Sounds[i].SoundName + "\"");
                    }
                }
                ig.UpdateStep(0, "Finished downloading sound files. Creating registry keys...");
                REG.Write("username", string.Empty, R.Strings.RegKey, true);
                REG.Write("password", string.Empty, R.Strings.RegKey, true);
                REG.Write("savedetails", true.ToString(), R.Strings.RegKey, true);
                REG.Write("autologin", true.ToString(), R.Strings.RegKey, true);
                ig.UpdateStep(5, "Finished writing registry keys. Creating a desktop shortcut...");
                APP.CreateShortcut(Name, CodeName.ToUpper(), "launcher " + CodeName);
                ig.UpdateStep(2, "Finished creating a desktop shortcut.");
                ig.UpdateStep(0, "\r\n\r\nGamemode \"" + Name + "\" installed successfully.");
            }
            public void Uninstall()
            {
                if (APP.LoadedGame != null)
                    return;
                Directory.Delete(GameDirectory, true);
            }
            public void Load()
            {
                if (APP.LoadedGame != null)
                    return;
                string gameIMG = GameDirectory + "\\gta3.img";
                File.Move(GTA.Path(GTA.GTASAPath.GTA3IMG), GTA.Path(GTA.GTASAPath.GTA3Backup));
                File.Move(gameIMG, GTA.Path(GTA.GTASAPath.GTA3IMG));
                for (int i = 0; i < ReplacedFiles.Count; i++)
                {
                    if (ReplacedFiles[i].FileType == ReplacedFile.FT_REPLACE || ReplacedFiles[i].FileType == ReplacedFile.FT_MANUAL)
                        File.Move(GTA.Path(GTA.GTASAPath.Directory) + ReplacedFiles[i].Path, GTA.Path(GTA.GTASAPath.Directory) + ReplacedFiles[i].Path + "-AF-Backup");
                    File.Move(GameDirectory + "\\required\\" + ReplacedFiles[i].WebName, GTA.Path(GTA.GTASAPath.Directory) + ReplacedFiles[i].Path);
                }
                for (int i = 0; i < Sounds.Count; i++)
                    SND.Load(this, Sounds[i]);
                APP.LoadedGame = this;
            }
            public void Unload()
            {
                if (APP.LoadedGame != this)
                    return;
                string gameIMG = GameDirectory + "\\gta3.img";
                File.Move(GTA.Path(GTA.GTASAPath.GTA3IMG), gameIMG);
                File.Move(GTA.Path(GTA.GTASAPath.GTA3Backup), GTA.Path(GTA.GTASAPath.GTA3IMG));
                for (int i = 0; i < ReplacedFiles.Count; i++)
                {
                    File.Move(GTA.Path(GTA.GTASAPath.Directory) + ReplacedFiles[i].Path, GameDirectory + "\\required\\" + ReplacedFiles[i].WebName);
                    if (ReplacedFiles[i].FileType == ReplacedFile.FT_REPLACE || ReplacedFiles[i].FileType == ReplacedFile.FT_MANUAL)
                        File.Move(GTA.Path(GTA.GTASAPath.Directory) + ReplacedFiles[i].Path + "-AF-Backup", GTA.Path(GTA.GTASAPath.Directory) + ReplacedFiles[i].Path);
                }
                for (int i = 0; i < Sounds.Count; i++)
                    SND.Unload(Sounds[i]);
                APP.LoadedGame = null;
            }
            public bool CheckForUpdates()
            {
                string gameURL = R.Strings.Site + CodeName;
                for (int i = 0; i < Skins.Count; i++)
                    if (!File.Exists(GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".txd") ||
                        !File.Exists(GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".dff")) return true;
                for (int i = 0; i < ReplacedFiles.Count; i++)
                    if (!File.Exists(GameDirectory + "\\required\\" + ReplacedFiles[i].WebName))
                        return true;
                for (int i = 0; i < Sounds.Count; i++)
                    if (!File.Exists(GameDirectory + "\\sounds\\" + Sounds[i].SoundName))
                        return true;
                return false;
            }
            public int GetUpdateCount(int updateType)
            {
                string gameURL = R.Strings.Site + CodeName;
                int c = 0;
                switch (updateType)
                {
                    case 1:
                        for (int i = 0; i < Skins.Count; i++)
                            if (!File.Exists(GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".txd") ||
                                !File.Exists(GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".dff")) c++;
                        break;
                    case 2:
                        for (int i = 0; i < ReplacedFiles.Count; i++)
                            if (!File.Exists(GameDirectory + "\\required\\" + ReplacedFiles[i].WebName))
                                c++;
                        break;
                    case 3:
                        for (int i = 0; i < Sounds.Count; i++)
                            if (!File.Exists(GameDirectory + "\\sounds\\" + Sounds[i].SoundName))
                                c++;
                        break;
                }
                return c;
            }
            public void Update(ref Forms.InstallGame ig)
            {
                List<int> skins = new List<int>();
                ig.UpdateStep(0, "Preparing update...");
                ig.PrepareLoading(GetUpdateCount(1) * 2); // skins
                ig.PrepareLoading(GetUpdateCount(2)); // sounds
                ig.PrepareLoading(GetUpdateCount(3)); // files
                ig.PrepareLoading(25); // load gta3
                string gameURL = R.Strings.Site + CodeName, gameIMG = GameDirectory + "\\gta3.img";
                ig.UpdateStep(0, "Downloading new models...");
                for (int i = 0; i < Skins.Count; i++)
                    if (!File.Exists(GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".txd") ||
                        !File.Exists(GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".dff"))
                    {
                        try
                        {
                            skins.Add(i);
                            NET.Download(gameURL + "/skins/" + Skins[i].WebName + ".txd", GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".txd");
                            NET.Download(gameURL + "/skins/" + Skins[i].WebName + ".dff", GameDirectory + "\\models\\" + Skins[i].ModelTarget + ".dff");
                            ig.UpdateStep(1, "Downloaded successfully: \"" + Skins[i].SkinName + "\"");
                        }
                        catch
                        {
                            ig.UpdateStep(1, "Downloaded failed: \"" + Skins[i].SkinName + "\"");
                        }
                    }
                ig.UpdateStep(0, "All new skins downloaded successfully. Loading gta3.img...");
                IMG.ModelList gta3 = IMG.Load(gameIMG);
                ig.UpdateStep(25, "Loaded successfully. Installing skins...");
                for (int i = 0; i < skins.Count; i++)
                {
                    try
                    {
                        IMG.Replace(gta3, (gta3.IndexPointers[Skins[skins[i]].ModelTarget + ".txd"] as IMG.Model).Offset, (gta3.IndexPointers[Skins[skins[i]].ModelTarget + ".txd"] as IMG.Model).Size / 2 * 2048, GameDirectory + "\\models\\" + Skins[skins[i]].ModelTarget + ".txd");
                        IMG.Replace(gta3, (gta3.IndexPointers[Skins[skins[i]].ModelTarget + ".dff"] as IMG.Model).Offset, (gta3.IndexPointers[Skins[skins[i]].ModelTarget + ".dff"] as IMG.Model).Size / 2 * 2048, GameDirectory + "\\models\\" + Skins[skins[i]].ModelTarget + ".dff");
                        ig.UpdateStep(1, "Installed successfully: \"" + Skins[skins[i]].SkinName + "\"");
                    }
                    catch
                    {
                        ig.UpdateStep(1, "Installation failed: \"" + Skins[skins[i]].SkinName + "\"");
                    }
                }
                ig.UpdateStep(0, "Finished installing new skins. Downloading new required files...");
                for (int i = 0; i < ReplacedFiles.Count; i++)
                    if (!File.Exists(GameDirectory + "\\required\\" + ReplacedFiles[i].WebName))
                    {
                        try
                        {
                            if (ReplacedFiles[i].FileType == ReplacedFile.FT_MANUAL)
                                File.Move(Environment.CurrentDirectory + "\\" + ReplacedFiles[i].WebName, GameDirectory + "\\required\\" + ReplacedFiles[i].WebName);
                            else
                                NET.Download(gameURL + "/files/" + ReplacedFiles[i].WebName, GameDirectory + "\\required\\" + ReplacedFiles[i].WebName);
                            ig.UpdateStep(1, "Downloaded successfully: \"" + ReplacedFiles[i].Description + "\"");
                        }
                        catch
                        {
                            ig.UpdateStep(1, "Download failed: \"" + ReplacedFiles[i].Description + "\"");
                        }
                    }
                ig.UpdateStep(0, "Finished downloading new required files. Downloading new sound files...");
                for (int i = 0; i < Sounds.Count; i++)
                {
                    if (!File.Exists(GameDirectory + "\\sounds\\" + Sounds[i].SoundName))
                    {
                        try
                        {
                            NET.Download(gameURL + "/sounds/" + Sounds[i].SoundName, GameDirectory + "\\sounds\\" + Sounds[i].SoundName.Trim());
                            ig.UpdateStep(1, "Downloaded successfully: \"" + Sounds[i].SoundName + "\"");
                        }
                        catch
                        {
                            ig.UpdateStep(1, "Download failed: \"" + Sounds[i].SoundName + "\"");
                        }
                    }
                }
                ig.UpdateStep(0, "Finished downloading new sound files.");
                ig.UpdateStep(0, "\r\n\r\nGamemode \"" + Name + "\" updated successfully.");
            }
        }
        public class Server
        {
            public string Name = string.Empty, IP = string.Empty, Assigned = string.Empty, Password = string.Empty, Website = string.Empty;
            public int Port = 0;
            public long LastRecreate = 0;
            public SAMP.Server Instance = null;
            public Server(string name, string ip, string assigned, int port, string pass, string url)
            {
                Name = name;
                IP = ip;
                Assigned = assigned;
                Port = port;
                Password = pass;
                Website = url;
                LastRecreate = DateTime.Now.Ticks;
            }
        }
        public class Skin
        {
            public string SkinName = string.Empty, WebName = string.Empty, ModelTarget = string.Empty;
            public Skin(string sn, string wn, string mt)
            {
                SkinName = sn;
                WebName = wn;
                ModelTarget = mt;
            }
        }
        public class ReplacedFile
        {
            public string Description = string.Empty, WebName = string.Empty, Path = string.Empty;
            public int FileType = FT_NONE;
            public const int FT_NONE = 0, FT_REPLACE = 1, FT_NEW = 2, FT_MANUAL = 3;
            public ReplacedFile(string desc, string wn, string path, int type)
            {
                Description = desc;
                WebName = wn;
                Path = path;
                FileType = type;
            }
        }
        public class Sound
        {
            public string SoundName = string.Empty;
            public MP3 Player = null;
            public double[] Position = null;
            public double Distance = 0.0;
            public int FirstVolume = 0;
            public Sound(string sn)
            {
                SoundName = sn;
                Player = new MP3();
            }
            public void Use3D(double x, double y, double z, double d)
            {
                Position = new double[] { x, y, z };
                Distance = d;
            }
        }
    }
}