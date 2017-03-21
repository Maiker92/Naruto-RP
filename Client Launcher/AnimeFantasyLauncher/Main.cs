using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Diagnostics;
using SAMP;
using C = AnimeFantasyLauncher.Classes;
using F = AnimeFantasyLauncher.Forms;
using R = AnimeFantasyLauncher.Resources;
using System.Threading;
using System.Reflection;
using System.Resources;
namespace AnimeFantasyLauncher
{
    public partial class Main : Form
    {
        public Form pointTo = null;
        public int cd = 0, ctime = 0, textLength = 0, playerid = -1, clientid = -1, playtime = 0, abortcd = -1, REC_idx = 0;
        public bool connected = false, isChatting = false, keysStatus = false, isActive = false, soundsPaused = false;
        public static string lastsent = string.Empty, textToSend = string.Empty, copy = string.Empty, REC_text = string.Empty;
        public F.Playing playing = null;
        public C.GPL.Server selectedServer;
        public Keys[] chatKeys = { Keys.Return, Keys.Escape, Keys.F6, Keys.T };
        public long ticks = DateTime.Now.Ticks / 10000, uptime = 0;
        public List<C.GPL.Sound> soundsToStop = new List<C.GPL.Sound>(), playingSounds = new List<C.GPL.Sound>();
        public double[] playerPosition = new double[4];
        public Main()
        {
            InitializeComponent();
            // (Loading these ones here so we can use them via Launcher.cs too)
            // Net settings
            WebRequest.DefaultWebProxy = null;
            ServicePointManager.DefaultConnectionLimit = int.MaxValue;
            Classes.NET.WC.Proxy = null;
            // Loading config
            copy += "\n1 - " + ((DateTime.Now.Ticks / 10000) - ticks);
            ticks = (DateTime.Now.Ticks / 10000);
            C.APP.LoadConfig();
        }
        public void Main_Load(object sender, EventArgs e)
        {
            long first = ticks;
            // Other settings
            Control.CheckForIllegalCrossThreadCalls = false; // TEMPORARY SHIT
            this.Text += R.Strings.Version;
            copy += "\n2 - " + ((DateTime.Now.Ticks / 10000) - ticks);
            ticks = (DateTime.Now.Ticks / 10000);
            if (R.Strings.Version != C.APP.CFG["version"].ToString())
            {
                MessageBox.Show("Outdated client version (your: " + R.Strings.Version + ", newest: " + C.APP.CFG["version"] + ")");
                C.APP.Exit();
            }
            else
            {
                if (!C.APP.IsInstalled())
                    UpdateText("Hello, and welcome to Anime Fantasy. You should first install a game. Start by pressing Games > Install, then select your game.");
                else
                {
                    // Loading Games
                    List<C.GPL.Game> installedGames = new List<C.GPL.Game>();
                    for (int i = 0; i < C.APP.Games.Count; i++)
                        if (C.APP.Games[i].IsInstalled())
                            installedGames.Add(C.APP.Games[i]);
                    if (installedGames.Count == 0)
                        UpdateText("Welcome back. You have no installed games. To install, press Games > Install and select your game.");
                    else
                    {
                        string tmp = string.Empty;
                        if (installedGames.Count == 1)
                            tmp = "Welcome back. Your currently installed game is " + installedGames[0].Name + ".";
                        else
                        {
                            tmp = "Welcome back. Your currently installed games are ";
                            for (int i = 0; i < installedGames.Count; i++)
                            {
                                if (i == 0)
                                    tmp += installedGames[i].Name;
                                else if (i == installedGames.Count - 1)
                                    tmp += " and " + installedGames[i].Name;
                                else
                                    tmp += ", " + installedGames[i].Name;
                            }
                            tmp += ".";
                        }
                        UpdateText(tmp);
                    }
                }
                for (int i = 0; i < C.APP.Games.Count; i++)
                {
                    installToolStripMenuItem.DropDownItems.Add(C.APP.Games[i].Name);
                    installToolStripMenuItem.DropDownItems[i].Click += new EventHandler(Install_Click);
                    uninstallToolStripMenuItem.DropDownItems.Add(C.APP.Games[i].Name);
                    uninstallToolStripMenuItem.DropDownItems[i].Click += new EventHandler(Uninstall_Click);
                    toolStripMenuItem1.DropDownItems.Add(C.APP.Games[i].Name);
                    toolStripMenuItem1.DropDownItems[i].Click += new EventHandler(Launcher_Click);
                }
                copy += "\n3 - " + ((DateTime.Now.Ticks / 10000) - ticks);
                ticks = (DateTime.Now.Ticks / 10000);
                // Background Workers
                C.TRD.CreateBackgroundWorkers();
                C.TRD.AddWork(new C.TRD.BackgroundWork("ReloadServerList"));
                backgroundWorker1.RunWorkerAsync();
                copy += "\n4 - " + ((DateTime.Now.Ticks / 10000) - ticks);
                ticks = (DateTime.Now.Ticks / 10000);
                // Loading Settings
                checkBox2.Checked = Convert.ToBoolean(C.REG.Read("savedetails", true.ToString(), R.Strings.RegKey));
                string name = string.Empty, pass = string.Empty;
                if (checkBox2.Checked && (name = (string)C.REG.Read("username", null, R.Strings.RegKey)) != null && (pass = (string)C.REG.Read("password", null, R.Strings.RegKey)) != null)
                {
                    textBox1.Text = name;
                    textBox2.Text = pass;
                }
                else
                    textBox1.Text = (string)C.REG.Read("PlayerName", null, R.Strings.SAMPRegKey);
                copy += "\n5 - " + ((DateTime.Now.Ticks / 10000) - ticks);
                ticks = (DateTime.Now.Ticks / 10000);
                // Preparing Connection
                C.NET.Socket.Initialize(this);
                string ip = C.UID.PlayerIP;
                copy += "\n6 - " + ((DateTime.Now.Ticks / 10000) - ticks);
                ticks = (DateTime.Now.Ticks / 10000);
                // Fix any errors that occured in previous games
                C.APP.Fix();
                // Timers
                timer3.Start();
                copy += "\n7 - " + ((DateTime.Now.Ticks / 10000) - ticks);
                //ticks = (DateTime.Now.Ticks / 10000);
            }
            //Clipboard.SetText(copy);
        }
        public void Install_Click(object sender, EventArgs e)
        {
            C.GPL.Game gamePressed = null;
            for (int i = 0; i < C.APP.Games.Count; i++)
                if (C.APP.Games[i].Name == sender.ToString())
                    gamePressed = C.APP.Games[i];
            if (gamePressed.IsInstalled())
                UpdateText("Game \"" + gamePressed.Name + "\" is already installed.");
            else if (C.APP.Playing)
                UpdateText("You can't install while playing. Quit from the game, and then retry.");
            else
            {
                F.InstallGame ig = new F.InstallGame(gamePressed);
                ig.ShowDialog();
                UpdateText(ig.success ? ("Game \"" + gamePressed.Name + "\" have been installed successfully!") : ("Installation of \"" + gamePressed.Name + "\" have been failed!"));
            }
        }
        public void Uninstall_Click(object sender, EventArgs e)
        {
            C.GPL.Game gamePressed = null;
            for (int i = 0; i < C.APP.Games.Count; i++)
                if (C.APP.Games[i].Name == sender.ToString())
                    gamePressed = C.APP.Games[i];
            if (!gamePressed.IsInstalled())
                UpdateText("Game \"" + gamePressed.Name + "\" is not installed.");
            else if (C.APP.Playing)
                UpdateText("You can't uninstall while playing. Quit from the game, and then retry.");
            else if (MessageBox.Show("Are you sure you want to uninstall \"" + gamePressed.Name + "\"?", "Uninstall", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == System.Windows.Forms.DialogResult.Yes)
            {
                UpdateText("Uninstalling \"" + gamePressed.Name + "\". This could take a few seconds...");
                try
                {
                    gamePressed.Uninstall();
                    UpdateText("Game \"" + gamePressed.Name + "\" uninstalled successfully.");
                }
                catch
                {
                    UpdateText("Failed to uninstall \"" + gamePressed.Name + "\".");
                }
            }
        }
        public void Launcher_Click(object sender, EventArgs e)
        {
            C.GPL.Game gamePressed = null;
            for (int i = 0; i < C.APP.Games.Count; i++)
                if (C.APP.Games[i].Name == sender.ToString())
                    gamePressed = C.APP.Games[i];
            if (!gamePressed.IsInstalled())
                UpdateText("Game \"" + gamePressed.Name + "\" is not installed.");
            else if (MessageBox.Show("Create a desktop launcher application for \"" + gamePressed.Name + "\"?", "Create a Desktop Launcher", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == System.Windows.Forms.DialogResult.Yes)
            {
                UpdateText("Creating a desktop launcher for \"" + gamePressed.Name + "\"...");
                try
                {
                    C.APP.CreateShortcut(gamePressed.Name, gamePressed.CodeName.ToUpper(), "launcher " + gamePressed.CodeName);
                    UpdateText("Created a desktop launcher for \"" + gamePressed.Name + "\".");
                }
                catch
                {
                    UpdateText("Failed to create a desktop launcher for \"" + gamePressed.Name + "\".");
                }
            }
        }
        public void PointTo(Form to)
        {
            if (to != null)
            {
                Classes.APP.SetMainFormVisible(false);
                (pointTo = to).Show();
            }
        }
        public bool ValidateConnection(C.GPL.Server server)
        {
            if (C.NET.Socket.IsConnected())
                C.NET.Socket.Release(true);
            if (!C.NET.Socket.IsConnected())
                C.NET.Socket.Connect(server.IP, server.IP == "127.0.0.1" ? 7776 : int.Parse(C.NET.ReadFromWeb(R.Strings.Site + "assign/" + server.Assigned + "_" + server.Port)));
            return C.NET.Socket.IsConnected();
        }
        public string Play(C.GPL.Game game, C.GPL.Server server)
        {
            if (C.APP.LoadedGame != null || C.APP.Playing)
                CancelConnection();
            if (!C.APP.IsInstalled())
                return "Anime Fantasy is not installed in your computer. Install at least one gamemode.";
            else if (!game.IsInstalled())
                return "This game is not installed in your computer. Install it to play.";
            else if (game.Servers.Count == 0)
                return "Due to a problem, you can't play right now.";
            else if (C.UID.PlayerIP.Length == 0)
                return "Anime Fantasy program couldn't find out your internet IP address yet, please wait.";
            else if(game.CheckForUpdates())
            {
                bool updated = false;
                F.InstallGame ig = null;
                if(MessageBox.Show("Game \"" + game.Name + "\" requires an update.\nDo you want to update now?", "Update", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    updated = true;
                    ig = new F.InstallGame(game, true);
                    ig.ShowDialog();
                }
                return !updated ? "Update required." : (ig.success ? ("Game \"" + game.Name + "\" have been updated successfully! You can play now.") : ("Update of \"" + game.Name + "\" have been failed!"));
            }
            else if (C.PRC.IsRunning(C.PRC.MonitoredProcesses.SAMP))
            {
                F.CloseSamp cs = new F.CloseSamp();
                cs.ShowDialog();
                if (!cs.cont)
                    return "Close SA-MP client to play.";
            }
            string name = (string)C.REG.Read("PlayerName", null, R.Strings.SAMPRegKey);
            if (textBox1.Text != name && C.APP.IsValidNickname(textBox1.Text))
                C.REG.Write("PlayerName", textBox1.Text, R.Strings.SAMPRegKey);
            C.APP.Playing = true;
            C.APP.CurrentServer = server;
            game.Load();
            cd = 20;
            if(ValidateConnection(server))
                C.NET.Socket.Send("connect " + C.UID.UniqueID(C.APP.CurrentServer.IP == "127.0.0.1") + " " + R.Strings.Version);
            else
                return "Couldn't connect to the server due to a network error.";
            return string.Empty;
        }
        public void CancelConnection()
        {
            try
            {
                C.APP.LoadedGame.Unload();
                C.APP.Playing = false;
                C.APP.CurrentServer = null;
                C.NET.Socket.Release(true);
            }
            catch
            {
            }
        }
        public C.GPL.Server FindServer(int index)
        {
            int c = 0;
            for (int i = 0; i < C.APP.Games.Count; i++)
                for (int j = 0; j < C.APP.Games[i].Servers.Count; j++)
                    if ((c++) == index)
                        return C.APP.Games[i].Servers[j];
            return null;
        }
        public void timer1_Tick(object sender, EventArgs e) // Every second - to start or stop gta_sa
        {
            bool unloadEverything = false;
            if (C.PRC.IsRunning(C.PRC.MonitoredProcesses.GTASA))
            {
                C.MEM.OpenGTAProcess();
                timer1.Stop();
                playing = new F.Playing(C.APP.LoadedGame.Name, C.APP.CurrentServer.Name);
                playing.ShowDialog();
                C.NET.Socket.Disconnect("Game aborted");
                cd = 0;
                C.APP.Playing = false;
                unloadEverything = true;
            }
            else if (cd == 0)
            {
                timer1.Stop();
                C.APP.Playing = false;
                MessageBox.Show("GTASA takes too much time to start. You can't play.");
                C.NET.Socket.Disconnect("GTASA start timeout");
            }
            if (!C.APP.Playing)
            {
                if (abortcd == -1)
                    abortcd = 2;
                if (abortcd > 0)
                    abortcd--;
                else if (abortcd == 0)
                {
                    abortcd = -1;
                    unloadEverything = true;
                }
            }
            cd--;
            if (unloadEverything)
                CloseEverything();
        }
        public void timer2_Tick(object sender, EventArgs e) // Every 100ms - to send/recieve sockets
        {
            uptime += timer2.Interval;
            // Recieving...
            if (textBox3.Visible)
                textBox3.Text += "Rec " + REC_idx;
            if (/*REC_idx == 0 || */REC_idx == 2)
            {
                if (Classes.NET.Socket.IsConnected())
                {
                    if (textBox3.Visible)
                        textBox3.Text += "...\r\n";
                    /*if (REC_idx == 0)
                    {
                        REC_idx = 1;
                        new Thread(() =>
                            {
                                REC_text = C.NET.Socket.Receive();
                                REC_idx = 2;
                            }).Start();
                    }*/
                    if (REC_idx == 2)
                    {
                        if (REC_text != null && REC_text.Length > 0)
                        {
                            if (textBox3.Visible)
                                textBox3.Text += "R: " + REC_text + "\r\n";
                            if (REC_text != lastsent)
                            {
                                try
                                {
                                    string[] splited = (REC_text[REC_text.Length - 1] == ';' ? (REC_text = REC_text.Remove(REC_text.Length - 1)) : REC_text).Split(';');
                                    string prefix = DateTime.Now.ToLongDateString() + "|" + DateTime.Now.ToLongTimeString() + "|";
                                    if (splited.Length > 1)
                                    {
                                        for (int i = 0; i < splited.Length; i++)
                                            if (splited[i].Length > 1)
                                                SocketRecieved((lastsent = (prefix + splited[i])).Split('|')[2]);
                                    }
                                    else
                                        SocketRecieved((lastsent = (prefix + REC_text)).Split('|')[2]);
                                }
                                catch
                                {
                                    C.NET.Socket.Disconnect("", false);
                                }
                            }
                        }
                        REC_idx = 0;
                    }
                }
            }
            if (uptime % 1500 == 0)
            {
                // Disconnecting?
                /*if (ctime > 0 && !connected)
                {
                    ctime--;
                    if (ctime == 0)
                        C.NET.Socket.Release(true);
                }*/
                // Playing!
                if (playtime > 0)
                {
                    playtime--;
                    if (playtime == 0)
                    {
                        string passwd = string.Empty;
                        if (C.APP.CurrentServer.Password.Length > 0 && C.APP.CurrentServer.Password != "0")
                            passwd = " " + C.APP.CurrentServer.Password;
                        C.PRC.Start(C.PRC.MonitoredProcesses.SAMP, C.APP.CurrentServer.IP + ":" + C.APP.CurrentServer.Port + passwd);
                    }
                }
            }
            if (uptime % 500 == 0)
            {
                // Sending...
                try
                {
                    if (connected && playerid != -1 && isActive)
                    {
                        string toSend = string.Empty;
                        if (uptime % 2 == 0)
                        {
                            toSend = "infoint";
                            string[] info = new string[]
                            {
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Fireproof)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Joypad)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.PlayerState)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.JumpState)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.RunningState)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.RadioVolume)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.SfxVolume)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.MoonSize)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.NightVision)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.ThermalVision)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.HUD)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Lock)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Widescreen)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.InfiniteRun)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Cheat_SuperJump)).ToString()
                            };
                            for (int i = 0; i < info.Length; i++)
                                toSend += " " + info[i];
                        }
                        else if (uptime % 2 == 1)
                        {
                            toSend = "infofloat";
                            string[] info = new string[]
                            {
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Gravity)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.WaveLevel)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.RotationSpeed)).ToString(),
                                C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Camera1)).ToString()
                            };
                            for (int i = 0; i < info.Length; i++)
                                toSend += " " + info[i];
                        }
                        C.NET.Socket.Send(toSend);
                    }
                }
                catch
                {
                }
            }
            // Update Position
            if(uptime % 150 == 0)
            {
                playerPosition[0] = Convert.ToDouble(C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.PosX)));
                playerPosition[1] = Convert.ToDouble(C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.PosY)));
                playerPosition[2] = Convert.ToDouble(C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.PosZ)));
                double ang = C.APP.RadianToDegree(Convert.ToDouble(C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.ZAngle))));
                if(ang < 0.0)
                    ang *= -2;
                playerPosition[3] = ang;
            }
            // Keys thing
            if (connected && playerid != -1)
            {
                try
                {
                    if (isActive)
                    {
                        if (!keysStatus)
                        {
                            C.KEY.ToggleAllHotkeys(true);
                            keysStatus = true;
                        }
                    }
                    else
                    {
                        if (keysStatus)
                        {
                            C.KEY.ToggleAllHotkeys(false);
                            keysStatus = false;
                        }
                    }
                }
                catch
                {
                }
            }
        }
        public void SocketRecieved(string data)
        {
            string cmd = data.Contains(":") ? data.Split(':')[0] : data;
            if (cmd == "connected")
            {
                C.NET.Socket.Send("hwid " + C.UID.GetHWID());
                C.NET.Socket.Send("login " + textBox1.Text + " " + textBox2.Text);
                ctime = 0;
                clientid = int.Parse(data.Split(':')[1]);
                playerid = int.Parse(data.Split(':')[2]);
                if (C.APP.Playing && playing != null)
                    playing.SetPID(playerid);
                connected = true;
            }
            else if (cmd == "logged")
            {
                int status = int.Parse(data.Split(':')[1]);
                bool loggedIn = false;
                string msg = string.Empty;
                switch (status)
                {
                    case 0:
                        msg = "User name or ID not found.";
                        break;
                    case 1:
                        msg = "One of the login details is missing.";
                        break;
                    case 2:
                        msg = "You've successfully logged in to \"" + textBox1.Text + "\" as user ID " + int.Parse(data.Split(':')[2]) + ".";
                        loggedIn = true;
                        break;
                    case 3:
                        msg = "Incorrect password or user name / ID.";
                        break;
                }
                UpdateText(msg);
                if (pointTo != null)
                    if (pointTo is Launcher)
                        (pointTo as Launcher).SendMessage(msg, loggedIn ? Color.Green : Color.Red);
                if (loggedIn)
                {
                    playtime = 3;
                    timer1.Start();
                }
                else
                    CancelConnection();
                ctime = 0;
            }
            else if (cmd == "id")
            {
                playerid = int.Parse(data.Split(':')[1]);
                if (C.APP.Playing && playing != null)
                    playing.SetPID(playerid);
            }
            else if (cmd == "webpage")
                Process.Start("http://" + C.NET.Socket.GetString(data));
            else if (cmd == "quit")
                C.PRC.Stop(C.PRC.MonitoredProcesses.GTASA);
            else if (cmd == "removejoypad")
            {
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Joypad, 1);
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.MenuJoypad, 0);
            }
            else if (cmd == "gravity")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Gravity, Convert.ToSingle(data.Split(':')[1]));
            else if (cmd == "fireproof")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Fireproof, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "rain")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Rain, Convert.ToSingle(0.9));
            else if (cmd == "waves")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.WaveLevel, Convert.ToSingle(data.Split(':')[1]));
            else if (cmd == "camera")
            {
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Camera1, Convert.ToSingle(data.Split(':')[1]));
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Camera2, Convert.ToSingle(data.Split(':')[1]));
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Camera3, Convert.ToSingle(data.Split(':')[1]));
            }
            else if (cmd == "camerareset")
            {
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Camera1, Convert.ToSingle(1.5));
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Camera2, Convert.ToSingle(3.6));
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Camera3, Convert.ToSingle(0.06));
            }
            else if (cmd == "close")
                C.NET.Socket.Disconnect("Disconnected from server by function");
            else if (cmd == "moonsize")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.MoonSize, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "vision")
                switch (Convert.ToUInt16(data.Split(':')[1]))
                {
                    case 0: C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.NightVision, Convert.ToUInt16(data.Split(':')[2])); break;
                    case 1: C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.ThermalVision, Convert.ToUInt16(data.Split(':')[2])); break;
                }
            else if (cmd == "hud")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.HUD, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "sound")
            {
                try
                {
                    C.GPL.Sound s = null;
                    for (int i = 0; i < C.APP.LoadedGame.Sounds.Count && s == null; i++)
                        if (C.APP.LoadedGame.Sounds[i].SoundName == data.Split(':')[2])
                            s = C.APP.LoadedGame.Sounds[i];
                    if (s != null)
                    {
                        string[] floats;
                        Int16 type = Convert.ToInt16(data.Split(':')[3]);
                        switch (data.Split(':')[1])
                        {
                            case "play":
                                C.SND.Play(s, type);
                                break;
                            case "loop":
                                C.SND.Play(s, type, true);
                                break;
                            case "stop":
                                C.SND.Stop(s);
                                break;
                            case "stops":
                                C.SND.Stop(s, true);
                                break;
                            case "play3d":
                                floats = data.Split(':')[4].Split(',');
                                C.SND.Play(s, type, use3d: true, position: new double[] { Convert.ToDouble(floats[0]), Convert.ToDouble(floats[1]), Convert.ToDouble(floats[2]) }, dist: Convert.ToDouble(floats[3]));
                                break;
                            case "loop3d":
                                floats = data.Split(':')[4].Split(',');
                                C.SND.Play(s, type, true, true, new double[] { Convert.ToDouble(floats[0]), Convert.ToDouble(floats[1]), Convert.ToDouble(floats[2]) }, Convert.ToDouble(floats[3]));
                                break;
                        }
                        C.NET.Socket.Send("sndlen " + s.Player.AudioLength + " " + s.SoundName);
                    }
                }
                catch (Exception ex)
                {
                    while (ex != null)
                    {
                        MessageBox.Show(ex.Message);
                        ex = ex.InnerException;
                    }
                }
            }
            else if (cmd == "lock")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Lock, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "hotkey")
            {
                int vk = Convert.ToUInt16(data.Split(':')[2]), mod = Convert.ToUInt16(data.Split(':')[3]);
                switch (Convert.ToUInt16(data.Split(':')[1]))
                {
                    case 1:
                        {
                            C.KEY.AddHotkey(vk, mod);
                            break;
                        }
                    case 2:
                        {
                            C.KEY.RemoveHotkey(vk, mod);
                            break;
                        }
                }
            }
            else if (cmd == "clipboard")
                Clipboard.SetText(data.Remove(0, data.IndexOf(':') + 1));
            else if (cmd == "widescreen")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Widescreen, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "rotspeed")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.RotationSpeed, Convert.ToSingle(data.Split(':')[1]));
            else if (cmd == "infiniterun")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.InfiniteRun, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "superjump")
                C.MEM.WriteMemory(C.MEM.GTAMemoryAddresses.Cheat_SuperJump, Convert.ToUInt16(data.Split(':')[1]));
            else if (cmd == "cursor")
                C.KEY.Cursor.SetPos(C.PRC.Get(C.PRC.MonitoredProcesses.GTASA).MainWindowHandle, new Point(Convert.ToInt16(data.Split(':')[1]), Convert.ToInt16(data.Split(':')[2])));
            else if (cmd == "teamspeak")
                Process.Start("ts3server://" + data.Split(':')[1] + "?port=" + data.Split(':')[2]);
            if(textBox3.Visible)
                textBox3.Text += "A: " + data + "\r\n";
        }
        public void Main_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (pointTo != null)
            {
                Classes.APP.SetMainFormVisible(false);
                e.Cancel = true;
                return;
            }
            if (C.APP.Playing || C.APP.LoadedGame != null)
            {
                //e.Cancel = true;
                if (C.PRC.IsRunning(C.PRC.MonitoredProcesses.GTASA))
                    C.PRC.Stop(C.PRC.MonitoredProcesses.GTASA);
                C.APP.Release();
                //return;
            }
            C.REG.Write("autologin", checkBox2.Checked.ToString(), R.Strings.RegKey, true);
            C.REG.Write("username", textBox1.Text, R.Strings.RegKey, true);
            C.REG.Write("password", textBox2.Text, R.Strings.RegKey, true);
            C.NET.Socket.Release(true);
            CloseEverything();
            //C.APP.Exit(); HAVE I PUT THAT HERE?!
        }
        public void UpdateText(string text)
        {
            label1.Text = string.Empty;
            textLength = 0;
            textToSend = text;
        }
        public void timer3_Tick(object sender, EventArgs e)
        {
            if (label1.Text.Length != textToSend.Length)
            {
                label1.Text += textToSend[textLength];
                textLength++;
            }
            isActive = C.GTA.IsActive();
            /*if (isActive)
                if ((int)C.MEM.ValueOf(C.MEM.ReadMemory(C.MEM.GTAMemoryAddresses.Menu)) != 43)
                    isActive = false;*/
            if (connected && playerid != -1 && isActive)
                for (int i = 0; i < chatKeys.Length; i++)
                    if (C.KEY.Pressed(chatKeys[i]))
                        OnKeyPressed((int)chatKeys[i], 0);
            if(soundsToStop.Count > 0 && isActive)
                for (int i = 0; i < soundsToStop.Count; i++)
                    if ((soundsToStop[i].Player.VolumeAll -= (int)((double)soundsToStop[i].FirstVolume * 0.01)) <= 0)
                    {
                        if(playingSounds.Contains(soundsToStop[i])) playingSounds.Remove(soundsToStop[i]);
                        soundsToStop[i].Player.Close();
                        soundsToStop.RemoveAt(i);
                        break;
                    }
            if(playingSounds.Count > 0)
            {
                bool startValue = soundsPaused;
                if (!isActive && !soundsPaused) soundsPaused = true;
                else if (isActive && soundsPaused) soundsPaused = false;
                if(startValue != soundsPaused)
                    for (int i = 0; i < playingSounds.Count; i++)
                        playingSounds[i].Player.Pause(soundsPaused);
                if (!soundsPaused)
                {
                    double pdistance = 0.0, volume = 0.0;
                    for (int i = 0; i < playingSounds.Count; i++)
                        if (playingSounds[i].Position != null)
                        {
                            // 3D sounds (master volume only! without right/left channel volumes)
                            pdistance = Math.Sqrt(Math.Pow(Math.Abs(playingSounds[i].Position[0] - playerPosition[0]), 2) + Math.Pow(Math.Abs(playingSounds[i].Position[1] - playerPosition[1]), 2) + Math.Pow(Math.Abs(playingSounds[i].Position[2] - playerPosition[2]), 2));
                            volume = Math.Max((pdistance <= playingSounds[i].Distance ? (1.0f - (pdistance / playingSounds[i].Distance)) : 0.0) * playingSounds[i].FirstVolume, playingSounds[i].FirstVolume);
                            playingSounds[i].Player.VolumeAll = (int)volume;
                        }
                }
            }
            /* 3D sound system with channel volumes that I didn't wanted to finish
            double soundX = -17.6445, soundY = -472.2797, soundZ = 25.2863;
            double sdistance = 10.0;
            bool isRight = soundX >= playerPosition[0] + (-0.001 * C.APP.RadianToDegree(Math.Sin(-(playerPosition[3] - 90.0))))
                && soundY >= playerPosition[1] + (-0.001 * C.APP.RadianToDegree(Math.Cos(-(playerPosition[3] - 90.0))));
            if(mp != null && mp.Looping)
            {
                double distance = Math.Sqrt(Math.Pow(Math.Abs(soundX - playerPosition[0]), 2) + Math.Pow(Math.Abs(soundY - playerPosition[1]), 2) + Math.Pow(Math.Abs(soundZ - playerPosition[2]), 2));
                double volume = distance <= sdistance ? (1.0f - (distance / sdistance)) : 0.0;
                volume *= 1000;
                this.Text = volume.ToString() + " = " + (int)(volume);
                mp.VolumeAll = (int)volume;
                mp.VolumeRight = (int)volume - (int)(volume * (playerPosition[0] > soundX ? (Math.Abs(playerPosition[0] - soundX) / sdistance) : 0.0));
                mp.VolumeLeft = (int)volume - (int)(volume * (playerPosition[0] < soundX ? (Math.Abs(playerPosition[0] - soundX) / sdistance) : 0.0));
                this.Text = volume.ToString() + " = " + (int)(volume) + ", >" + mp.VolumeRight + ", <" + mp.VolumeLeft + " / " + playerPosition[0] + ", " + playerPosition[1] + ", " + playerPosition[2] + ", " + playerPosition[3];
            } */
        }
        public void refreshServerListToolStripMenuItem_Click(object sender, EventArgs e)
        {
            C.TRD.AddWork(new C.TRD.BackgroundWork("ReloadServerList"));
        }
        public void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            C.APP.Exit();
        }
        public void playToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (textBox1.Text.Length == 0 || textBox2.Text.Length == 0)
                UpdateText("Please enter your username and password in-game, or register at the server's website.");
            else
            {
                C.GPL.Game selectedGame = null;
                for (int i = 0; i < C.APP.Games.Count && selectedGame == null; i++)
                    if (C.APP.Games[i].Name == dataGridView1.Rows[dataGridView1.SelectedRows[0].Index].Cells[4].Value.ToString())
                        selectedGame = C.APP.Games[i];
                for (int i = 0; i < selectedGame.Servers.Count && selectedServer == null; i++)
                    if (selectedGame.Servers[i].Name == dataGridView1.Rows[dataGridView1.SelectedRows[0].Index].Cells[1].Value.ToString())
                        selectedServer = selectedGame.Servers[i];
                UpdateText("Connecting");
                string err = Play(selectedGame, selectedServer);
                if (err.Length > 0)
                    UpdateText(err);
            }
        }
        public void refreshToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows[0].Index == -1)
                return;
            // replace
        }
        public void copyIPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows[0].Index == -1)
                return;
            C.GPL.Server found = FindServer(dataGridView1.SelectedRows[0].Index);
            if (found == null)
                return;
            Clipboard.SetText(found.IP + ":" + found.Port);
        }
        public void copyServerInfoToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows[0].Index == -1)
                return;
            // copy info
        }
        public void openWebsiteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows[0].Index == -1)
                return;
            C.GPL.Server found = FindServer(dataGridView1.SelectedRows[0].Index);
            if (found == null)
                return;
            C.NET.OpenWebpage(found.Website);
        }
        public void listOfGameModesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // list of gamemodes
        }
        public void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // settings window
        }
        public void helpCenterToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // help center
        }
        public void supportForumToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // support forum
        }
        public void animeFantasyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // anime fantasy website
        }
        public void oversightGroupToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // os
        }
        public void userControlPanelToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // ucp
        }
        public void settingsToolStripMenuItem_Click_1(object sender, EventArgs e)
        {
            // settings
        }
        public void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
        }
        public void button1_Click(object sender, EventArgs e)
        {
        }
        public void button2_Click(object sender, EventArgs e)
        {
            copyServerInfoToolStripMenuItem_Click(sender, e);
        }
        public void button4_Click(object sender, EventArgs e)
        {
            openWebsiteToolStripMenuItem_Click(sender, e);
        }
        public void button3_Click(object sender, EventArgs e)
        {
            playToolStripMenuItem_Click(sender, e);
        }
        private void button5_Click(object sender, EventArgs e)
        {
        }
        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
        }
        public void playLocalHostToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("As long as this application is on a beta version,\r\nYou can't play in a local host.\r\nHowever - this option will be enabled soon.", "Local host", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        public void timer4_Tick(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 0)
                return;
            C.GPL.Server selectedServer = FindServer(dataGridView1.SelectedRows[0].Index);
            if (selectedServer == null)
                return;
            if (connected && playerid != -1)
                C.TRD.AddWork(new C.TRD.BackgroundWork("RefreshServer", selectedServer, dataGridView1.SelectedRows[0].Index));
        }
        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);
            if (m.Msg == C.KEY.WM_HOTKEY)
                OnKeyPressed((((int)m.LParam >> 16) & 0xFFFF), ((int)m.LParam & 0xFFFF));
        }
        public void OnKeyPressed(int vk, int mod)
        {
            //MessageBox.Show(((Keys)vk).ToString());
            bool isChattingOld = isChatting;
            if (isChatting && (vk == (int)Keys.Escape || vk == (int)Keys.Return))
                isChatting = false;
            else if (!isChatting && vk == (int)Keys.T)
                isChatting = true;
            else if (vk == (int)Keys.F6)
                isChatting = !isChatting;
            if (isChattingOld != isChatting)
                C.KEY.ToggleAllHotkeys(!isChatting);
            else
                C.NET.Socket.Send("key " + vk + " " + mod);
        }
        private void dataGridView1_SelectionChanged(object sender, EventArgs e)
        {
            if (dataGridView1.SelectedRows.Count == 0)
                return;
            selectedServer = FindServer(dataGridView1.SelectedRows[0].Index);
            if (selectedServer == null)
                return;
            label4.Text = selectedServer.Name;
            label3.Text = selectedServer.IP + ":" + selectedServer.Port;
            linkLabel1.Text = selectedServer.Website;
            C.TRD.AddWork(new C.TRD.BackgroundWork("RefreshServer", selectedServer, dataGridView1.SelectedRows[0].Index));
        }
        private void CloseEverything()
        {
            if (C.APP.LoadedGame != null)
                C.APP.LoadedGame.Unload();
            C.KEY.ToggleAllHotkeys(false);
            keysStatus = false;
            C.MEM.CloseGTAProcess();
            soundsPaused = false;
            playingSounds.Clear();
            soundsToStop.Clear();
        }
        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            while (true)
            {
                if (REC_idx == 0)
                {
                    REC_idx = 1;
                    REC_text = C.NET.Socket.Receive();
                    REC_idx = 2;
                }
            }
        }
    }
}