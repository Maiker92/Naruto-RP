using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Windows.Forms;
using R = AnimeFantasyLauncher.Resources;
using System.Threading;
namespace AnimeFantasyLauncher.Classes
{
    class NET
    {
        public static WebClient WC = new WebClient();
        public static string ReadFromWeb(string site)
        {
            string s = string.Empty;
            try
            {
                s = WC.DownloadString(site);
                /*System.IO.Stream y = WC.OpenRead(site);
                System.IO.StreamReader z = new System.IO.StreamReader(y, Encoding.UTF8);
                s = z.ReadToEnd();
                z.Close();
                y.Close();*/
            }
            catch
            {
                return null;
            }
            return s;
        }
        public static bool Download(string url, string target)
        {
            try
            {
                WC.DownloadFile(url, target);
            }
            catch
            {
                return false;
            }
            return true;
        }
        public static string IPFromDomain(string domainname)
        {
            return domainname[0] >= '0' && domainname[0] <= '9' ? domainname : Dns.GetHostAddresses(domainname)[0].ToString();
        }
        public static void OpenWebpage(string url)
        {
            System.Diagnostics.Process.Start("http://" + url);
        }
        public class Socket
        {
            public static TcpClient S = null;
            public static Main m = null;
            public static byte[] buffer = new byte[1024];
            public static NetworkStream stream;
            public static void Initialize(Main mainForm)
            {
                m = mainForm;
            }
            public static bool IsConnected()
            {
                return S != null && S.Connected;
            }
            public static bool Connect(string ip, int port)
            {
                if (S != null)
                    S.Close();
                S = new TcpClient(ip, port);
                //S.ReceiveTimeout = 100;
                S.SendTimeout = 500;
                S.NoDelay = true;
                stream = S.GetStream();
                if (S.Connected)
                {
                    m.ctime = 3;
                    m.timer2.Start();
                    return true;
                }
                else
                    Release(false);
                return false;
            }
            public static void Disconnect(string reason, bool serverAlive = true)
            {
                try
                {
                    if (serverAlive)
                    {
                        Send("disconnect " + reason);
                        if (m.textBox3.Visible)
                            m.textBox3.Text += "Disconnect\r\n";
                        S.Close();
                    }
                    Release(false);
                }
                catch
                {
                }
            }
            public static void Send(string data)
            {
                if (S == null || !S.Connected)
                    return;
                byte[] d = Encoding.ASCII.GetBytes(data + ";");
                stream.Write(d, 0, d.Length);
            }
            public static string Receive()
            {
                if (S == null || !S.Connected)
                    return string.Empty;
                try
                {
                    int bytes = stream.Read(buffer, 0, buffer.Length);
                    return Encoding.ASCII.GetString(buffer, 0, bytes);
                }
                catch (SocketException se)
                {
                    if (m.textBox3.Visible)
                        m.textBox3.Text += "SE " + se.ErrorCode + "\r\n";
                    return string.Empty;
                }
                catch (System.IO.IOException)
                {
                    if (m.textBox3.Visible)
                        m.textBox3.Text += "IO\r\n";
                    return string.Empty;
                }
                catch
                {
                    if (m.textBox3.Visible)
                        m.textBox3.Text += "Failed\r\n";
                    return null;
                }
                /*try
                {
                    byte[] buffer = new byte[1024];
                    int iRx = S.Receive(buffer);
                    char[] chars = new char[iRx];
                    Decoder d = System.Text.Encoding.UTF8.GetDecoder();
                    int charLen = d.GetChars(buffer, 0, iRx, chars, 0);
                    return new string(chars);
                }
                catch
                {
                    if (m.textBox3.Visible)
                        m.textBox3.Text += "Failed\r\n";
                }*/
            }
            public static void Release(bool socket)
            {
                if (APP.Playing && m.playing != null)
                    m.playing.Abort();
                if(m.timer2.Enabled)
                    m.timer2.Stop();
                if(socket && S != null && S.Connected)
                {
                    if (m.textBox3.Visible)
                        m.textBox3.Text += "Release\r\n";
                    m.connected = false;
                    S.Close();
                }
            }
            public static string GetString(string data, string sep = ":")
            {
                return data.Remove(0, data.IndexOf(sep) + 1);
            }
        }
    }
}