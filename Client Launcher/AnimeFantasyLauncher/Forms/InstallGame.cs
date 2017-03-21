using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using C = AnimeFantasyLauncher.Classes;
using R = AnimeFantasyLauncher.Resources;
namespace AnimeFantasyLauncher.Forms
{
    public partial class InstallGame : Form
    {
        private C.GPL.Game installing = null;
        private InstallGame self;
        public bool success = false;
        public InstallGame(C.GPL.Game game, bool cfu = false)
        {
            InitializeComponent();
            installing = game;
            self = this;
            progressBar1.Maximum = 0;
            if(cfu)
            {
                this.Text = "Updating: ";
                button1.Text = "Update Now";
            }
        }
        private void InstallGame_Load(object sender, EventArgs e)
        {
            this.Text += installing.Name;
        }
        private void button1_Click(object sender, EventArgs e)
        {
            if (button1.Text[0] == 'F')
                this.Close();
            else
            {
                button1.Enabled = false;
                try
                {
                    if (this.Text[0] == 'I')
                        installing.Install(ref self);
                    else
                        installing.Update(ref self);
                    button1.Text = "Finish";
                    button1.Enabled = true;
                    success = true;
                }
                catch
                {
                }
            }
        }
        public void PrepareLoading(int amount)
        {
            progressBar1.Maximum += amount;
        }
        public void UpdateStep(int n, string text)
        {
            progressBar1.Value += n;
            textBox1.Text += text + "\r\n";
            this.Refresh();
            textBox1.Refresh();
            textBox1.SelectionStart = textBox1.TextLength;
            textBox1.ScrollToCaret();
            progressBar1.Refresh();
        }
    }
}