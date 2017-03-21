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
    public partial class CloseSamp : Form
    {
        public CloseSamp()
        {
            InitializeComponent();
        }
        public bool cont = false;
        private void button1_Click(object sender, EventArgs e)
        {
            C.PRC.Stop(C.PRC.MonitoredProcesses.SAMP);
            this.Close();
            cont = true;
        }
        private void button2_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}