using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Resources;
using System.Text;
using System.Windows.Forms;
using C = AnimeFantasyLauncher.Classes;
namespace AnimeFantasyLauncher
{
    public partial class Launcher : Form
    {
        private C.GPL.Game launchedGame = null;
        private string launchedGameCode = string.Empty;
        public Launcher(string gameCode)
        {
            InitializeComponent();
            launchedGameCode = gameCode;
        }
        private void Launcher_Load(object sender, EventArgs e)
        {
            for (int i = 0; i < C.APP.Games.Count; i++)
                if (C.APP.Games[i].CodeName == launchedGameCode)
                    launchedGame = C.APP.Games[i];
            if (launchedGame == null)
            {
                C.APP.Exit();
                return;
            }
            label3.Text = label3.Text.Replace("{MODENAME}", launchedGame.Name);
            ResourceSet list = Resources.LauncherImages.ResourceManager.GetResourceSet(new System.Globalization.CultureInfo("en-us"), true, true);
            List<Image> imgList = new List<Image>();
            foreach (DictionaryEntry img in list)
                if(img.Key.ToString().StartsWith(launchedGame.CodeName))
                    imgList.Add(img.Value as Image);
            this.BackgroundImage = imgList[new Random().Next(imgList.Count)];
            for (int i = 0; i < menuStrip1.Items.Count; i++)
                menuStrip1.Items[i].BackColor = Color.FromArgb(150, Color.RoyalBlue);
            for (int i = 0; i < launchedGame.Servers.Count; i++)
                comboBox1.Items.Add(launchedGame.Servers[i].IP + ":" + launchedGame.Servers[i].Port + " - " + launchedGame.Servers[i].Name);
            if (launchedGame.Servers.Count == 0)
                comboBox1.Items.Add("- NO SERVER AVAILABLE -");
            else
                comboBox1.SelectedIndex = 0;
            if(!launchedGame.IsInstalled())
            {
                bool installed = false;
                Forms.InstallGame ig = null;
                if (MessageBox.Show("Game \"" + launchedGame.Name + "\" is not installed.\nDo you want to install now?", "Install", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    installed = true;
                    ig = new Forms.InstallGame(launchedGame);
                    ig.ShowDialog();
                }
                SendMessage(!installed ? "Installation required." : (ig.success ? ("Game \"" + launchedGame.Name + "\" have been installed successfully! You can play now.") : ("Installation of \"" + launchedGame.Name + "\" have been failed!")), Color.Green);
            }
            C.APP.Fix();
            if(launchedGame.CheckForUpdates())
            {
                bool updated = false;
                Forms.InstallGame ig = null;
                if (MessageBox.Show("Game \"" + launchedGame.Name + "\" requires an update.\nDo you want to update now?", "Update", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    updated = true;
                    ig = new Forms.InstallGame(launchedGame, true);
                    ig.ShowDialog();
                }
                SendMessage(!updated ? "Update required." : (ig.success ? ("Game \"" + launchedGame.Name + "\" have been updated successfully! You can play now.") : ("Update of \"" + launchedGame.Name + "\" have been failed!")), Color.Green);
            }
        }
        protected override void WndProc(ref Message m)
        {
            switch (m.Msg)
            {
                case 0x84:
                    base.WndProc(ref m);
                    if ((int)m.Result == 0x1)
                        m.Result = (IntPtr)0x2;
                    return;
            }
            base.WndProc(ref m);
        }
        private void closeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!C.APP.MainForm.ShowInTaskbar)
                C.APP.Exit();
            else
                this.Close();
        }
        private void fullBrowserToolStripMenuItem_Click(object sender, EventArgs e)
        {
            C.APP.SetMainFormVisible(true);
            C.APP.MainForm.Focus();
        }
        private void forumsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (launchedGame.Site.Length > 0)
                C.NET.OpenWebpage(launchedGame.Site);
        }
        private void uCPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            C.APP.MainForm.userControlPanelToolStripMenuItem_Click(sender, e);
        }
        private void button1_Click(object sender, EventArgs e)
        {
            if (comboBox1.SelectedIndex == -1)
                SendMessage("Please select a server.", Color.White);
            else
            {
                C.GPL.Server launchedServer = null;
                string sel = comboBox1.Items[comboBox1.SelectedIndex].ToString();
                for (int i = 0; i < launchedGame.Servers.Count && launchedServer == null; i++)
                    if (sel.Contains(launchedGame.Servers[i].IP) && sel.Contains(launchedGame.Servers[i].Name))
                        launchedServer = launchedGame.Servers[i];
                string err = C.APP.MainForm.Play(launchedGame, launchedServer);
                if (err.Length > 0)
                    SendMessage(err, Color.Red);
            }
        }
        public void SendMessage(string msg, Color col)
        {
            label3.Text = msg;
            label3.ForeColor = col;
        }
        private void Launcher_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (!C.APP.MainForm.ShowInTaskbar)
                C.APP.Exit();
        }
    }
}