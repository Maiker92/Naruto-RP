using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.Windows.Forms;
using System.Media;
using System.Runtime.InteropServices;
namespace AnimeFantasyLauncher.Classes
{
    class SND
    {
        const int DEFAULT_SE_VOLUME = 750, DEFAULT_BGM_VOLUME = 150;
        public static void Load(GPL.Game g, GPL.Sound s)
        {
            s.Player.Open(GTA.Path(GTA.GTASAPath.AFSounds, g) + "\\" + s.SoundName);
        }
        public static void Unload(GPL.Sound s)
        {
            //s.Player.Pause(true);
            s.Player.Stop();
            s.Player.Close();
        }
        public static void Play(GPL.Sound s, int type, bool loop = false, bool use3d = false, double[] position = null, double dist = 0.0)
        {
            s.Player.Looping = loop;
            switch(type)
            {
                case 1: s.Player.VolumeAll = DEFAULT_SE_VOLUME; break; // System Sound
                case 2: s.Player.VolumeAll = DEFAULT_SE_VOLUME; break; // Sound Effect
                case 3: s.Player.VolumeAll = DEFAULT_BGM_VOLUME; break; // Background Music
                case 4: s.Player.VolumeAll = DEFAULT_SE_VOLUME; break; // Voice
            }
            s.FirstVolume = s.Player.VolumeAll;
            if (APP.MainForm.isActive)
                s.Player.Play();
            if (use3d)
                s.Use3D(position[0], position[1], position[2], dist);
            else
                s.Position = null;
            APP.MainForm.playingSounds.Add(s);
        }
        public static void Stop(GPL.Sound s, bool smooth = false)
        {
            if (smooth)
                APP.MainForm.soundsToStop.Add(s);
            else
            {
                s.Player.Stop();
                APP.MainForm.playingSounds.Remove(s);
            }
        }
    }
}