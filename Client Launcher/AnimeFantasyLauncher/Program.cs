using System;
using System.Collections.Generic;
using System.Windows.Forms;
namespace AnimeFantasyLauncher
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Classes.APP.MainForm = new Main();
            Form toLoad = null;
            string[] args = Environment.GetCommandLineArgs();
            if (args.Length == 1)
                toLoad = null;
            else if (args.Length >= 2)
            {
                switch (args[1])
                {
                    case "launcher":
                        toLoad = new Launcher(args[2]);
                        break;
                }
            }
            if (toLoad != null)
                Classes.APP.MainForm.PointTo(toLoad);
            Application.Run(Classes.APP.MainForm);
        }
    }
}