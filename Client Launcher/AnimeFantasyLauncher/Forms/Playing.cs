using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using C = AnimeFantasyLauncher.Classes;
namespace AnimeFantasyLauncher.Forms
{
    public partial class Playing : Form
    {
        public Playing(string game, string server)
        {
            InitializeComponent();
            label1.Text = label1.Text.Replace("#GAME", game).Replace("#SERVER", server);
            timer1.Start();
        }
        private void button1_Click(object sender, EventArgs e)
        {
            Abort();
        }
        private void timer1_Tick(object sender, EventArgs e)
        {
            if (!C.PRC.IsRunning(C.PRC.MonitoredProcesses.GTASA))
                this.Close();
        }
        public void SetPID(int pid)
        {
            this.Text = "Currently playing" + (pid > -1 ? (" (Player ID: " + pid + ")") : string.Empty);
        }
        public void Abort()
        {
            C.PRC.Stop(C.PRC.MonitoredProcesses.GTASA);
            //C.NET.Socket.Disconnect("Game aborted");
            this.Close();
            this.Dispose();
        }
    }
}