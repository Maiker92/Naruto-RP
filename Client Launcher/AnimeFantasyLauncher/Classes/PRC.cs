using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using R = AnimeFantasyLauncher.Resources;
namespace AnimeFantasyLauncher.Classes
{
    class PRC
    {
        public enum MonitoredProcesses { GTASA, SAMP }
        public static bool IsRunning(MonitoredProcesses process)
        {
            return Process.GetProcessesByName(ProcessName(process)).Length > 0;
        }
        public static Process Get(MonitoredProcesses process)
        {
            Process[] p = Process.GetProcessesByName(ProcessName(process));
            return p.Length > 0 ? p[0] : null;
        }
        public static void Start(MonitoredProcesses process, string args = "")
        {
            Process.Start(ProcessName(process, true), args);
        }
        public static void Stop(MonitoredProcesses process)
        {
            Process p = Get(process);
            if(p != null)
                p.Kill();
        }
        private static string ProcessName(MonitoredProcesses process, bool fullpath = false)
        {
            switch (process)
            {
                case MonitoredProcesses.GTASA: return fullpath ? (GTA.Path(GTA.GTASAPath.Directory) + "\\" + R.Strings.GTAProcess + ".exe") : R.Strings.GTAProcess;
                case MonitoredProcesses.SAMP: return fullpath ? (GTA.Path(GTA.GTASAPath.Directory) + "\\" + R.Strings.SAMPProcess + ".exe") : R.Strings.SAMPProcess;
            }
            return string.Empty;
        }
    }
}