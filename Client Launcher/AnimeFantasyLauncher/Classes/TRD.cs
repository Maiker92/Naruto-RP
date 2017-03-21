using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using C = AnimeFantasyLauncher.Classes;
namespace AnimeFantasyLauncher.Classes
{
    class TRD
    {
        public const int MAX_BACKGROUND_WORKERS = 20;
        public static List<BackgroundWorker> bgWorkers = new List<BackgroundWorker>();
        private static Queue<BackgroundWork> worksLeft = new Queue<BackgroundWork>();
        private static string lastsent = string.Empty;
        public static void CreateBackgroundWorkers()
        {
            BackgroundWorker tmp;
            for (int i = 0; i < MAX_BACKGROUND_WORKERS; i++)
            {
                tmp = new BackgroundWorker();
                tmp.WorkerSupportsCancellation = true;
                tmp.DoWork += TRD_DoWork;
                bgWorkers.Add(tmp);
            }
        }
        public static void AddWork(BackgroundWork work)
        {
            int found = -1;
            for (int i = 0; i < MAX_BACKGROUND_WORKERS; i++)
                if (!bgWorkers[i].IsBusy)
                    found = i;
            if (found != -1)
            {
                work.assignedWorker = found;
                bgWorkers[found].RunWorkerAsync(work);
            }
            else
                worksLeft.Enqueue(work);
        }
        public static void WorkFinished(int worker)
        {
            if (worksLeft.Count > 0)
            {
                BackgroundWork work = worksLeft.Dequeue();
                work.assignedWorker = worker;
                bgWorkers[worker].CancelAsync();
                if(!bgWorkers[worker].IsBusy)
                    bgWorkers[worker].RunWorkerAsync(work);
            }
        }
        private static void TRD_DoWork(object sender, DoWorkEventArgs e)
        {
            BackgroundWork work = (BackgroundWork)e.Argument;
            switch(work.work) // Warcraft III orcs' peon
            {
                case "RefreshServer":
                    RefreshServer((C.GPL.Server)work.param[0], (int)work.param[1]);
                    break;
                case "ReloadServerList":
                    C.APP.MainForm.dataGridView1.Rows.Clear();
                    for (int i = 0, c = 0; i < C.APP.Games.Count; i++)
                    {
                        for (int j = 0; j < C.APP.Games[i].Servers.Count; j++)
                        {
                            C.APP.MainForm.dataGridView1.Rows.Add(new object[]
                            {
                                (++c).ToString(),
                                C.APP.Games[i].Servers[j].Name,
                                "0 / 0",
                                "-",
                                C.APP.Games[i].Name,
                                "0"
                            });
                            AddWork(new BackgroundWork("RefreshServer", C.APP.Games[i].Servers[j], C.APP.MainForm.dataGridView1.Rows.Count - 1));
                        }
                    }
                    break;
                case "GetIP":
                    try
                    {
                        Task<string>[] tasks = new[]
                        {
                                Task<string>.Factory.StartNew(() => new WebClient().DownloadString("http://checkip.dyndns.org") ),
                                Task<string>.Factory.StartNew(() => new WebClient().DownloadString("http://icanhazip.com")),
                                Task<string>.Factory.StartNew(() => new WebClient().DownloadString("http://sa-mp.co.il/dm/udmcpapp/whatismyip.php"))
                        };
                        int index = Task.WaitAny(tasks);
                        C.UID.UpdateIP(new Regex(@"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b").Match(tasks[index].Result).Value);
                    }
                    catch
                    {
                    }
                    break;
            }
            WorkFinished(work.assignedWorker);
        }
        public static void RefreshServer(C.GPL.Server server, int index)
        {
            try
            {
                if (server.Instance == null || (new TimeSpan(DateTime.Now.Ticks - server.LastRecreate).TotalSeconds >= 30))
                    server.Instance = new SAMP.Server(server.IP, server.Port);
                server.Instance.GetInfo();
                C.APP.MainForm.dataGridView1.Rows[index].Cells[1].Value = server.Name;
                C.APP.MainForm.dataGridView1.Rows[index].Cells[2].Value = server.Instance.Players.Count + " / " + server.Instance.MaxPlayers;
                C.APP.MainForm.dataGridView1.Rows[index].Cells[3].Value = server.Instance.Ping == 9999 ? "-" : server.Instance.Ping.ToString();
            }
            catch
            {
            }
        }
        public class BackgroundWork
        {
            public string work = string.Empty;
            public object[] param = null;
            public int assignedWorker = -1;
            public BackgroundWork(string work, params object[] parameters)
            {
                this.work = work;
                this.param = parameters;
            }
        }
    }
}