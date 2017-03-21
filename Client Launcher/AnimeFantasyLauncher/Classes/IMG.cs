using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.IO;
namespace AnimeFantasyLauncher.Classes
{
    public class IMG
    {
        public static ModelList Load(string file)
        {
            ModelList ret = new ModelList(file, new List<Model>());
            BinaryReader binaryReader = new BinaryReader((Stream)File.OpenRead(file));
            if (new string(binaryReader.ReadChars(4)) == "VER2")
            {
                uint num1 = binaryReader.ReadUInt32(), num3 = 0U, num5 = 0U, num7 = 0U;
                FileInfo fileInfo = new FileInfo(file);
                long num2 = (long)(uint)(8 + (int)num1 * 32), num9 = 0, num10 = 0;
                int num4 = 0, num6 = 0, num8 = 0;
                if ((int)num1 == 0)
                    num3 = num5 = 2048U;
                string str = string.Empty;
                Model added = null;
                for (uint index1 = 0U; index1 < num1; index1++)
                {
                    num7 = (uint)((int)binaryReader.ReadUInt32() * 1024 * 2);
                    num8 = binaryReader.ReadInt32() * 2;
                    if (num7 < num3 || (int)index1 == 0)
                    {
                        num3 = num7;
                        num4 = num8;
                    }
                    if (num7 > num5)
                    {
                        num5 = num7;
                        num6 = num8;
                    }
                    num2 += (long)(num8 * 1024);
                    str = string.Empty;
                    for (byte index2 = (byte)0; (int)index2 < 24; index2++)
                        str += ((char)binaryReader.ReadByte()).ToString();
                    str = str.Split(new char[1])[0];
                    added = new Model(str, num7, num8);
                    ret.Models.Add(added);
                    ret.IndexPointers.Add(str.Trim(), added);
                }
                num9 = ((long)num3 - binaryReader.BaseStream.Position) / 32L;
                ret.FTBA = (int)num9;
                num10 = fileInfo.Length - num2;
                if (num10 != 0L)
                    num9 = num10 > 1048576L ? (num10 / 1024L / 1024L) : (num10 / 1024L);
                ret.FirstOffsetSize[0] = (int)num3;
                ret.FirstOffsetSize[1] = num4;
                ret.LastOffsetSize[0] = (int)num5;
                ret.LastOffsetSize[1] = num6;
                num9 = fileInfo.Length > 1048576L ? (fileInfo.Length / 1024L / 1024L) : (fileInfo.Length / 1024L);
            }
            else
                return null;
            binaryReader.Close();
            return ret;
        }
        public static void Replace(ModelList img, uint old_offset, int old_size, string file)
        {
            FileInfo fileInfo = new FileInfo(file);
            if (fileInfo.Extension.ToLower() != ".ipl" && fileInfo.Extension.ToLower() != ".ifp" && (fileInfo.Extension.ToLower() != ".dff" && fileInfo.Extension.ToLower() != ".col") && fileInfo.Extension.ToLower() != ".txd")
                throw new Exception("IMG: Invalid file extension.");
            else
            {
                int length = roundTo2048byte((int)fileInfo.Length), num5 = 0;
                BinaryWriter binaryWriter = new BinaryWriter((Stream)new FileStream(img.FileName, FileMode.Open, FileAccess.ReadWrite, FileShare.ReadWrite));
                BinaryReader binaryReader = new BinaryReader((Stream)new FileStream(img.FileName, FileMode.Open, FileAccess.ReadWrite, FileShare.ReadWrite));
                uint num2 = 0U;
                //System.Windows.Forms.MessageBox.Show("Replacing #1 " + img.FileName + ": " + file);
                if (length > old_size)
                {
                    num2 = (uint)((ulong)img.LastOffsetSize[0] + (ulong)(img.LastOffsetSize[1] / 2U) * 2048UL);
                    if (length > int.MaxValue)
                    {
                        binaryWriter.Close();
                        binaryReader.Close();
                        throw new Exception("IMG: File is too big.");
                    }
                    else if ((long)num2 + (long)length > (long)uint.MaxValue)
                    {
                        binaryWriter.Close();
                        binaryReader.Close();
                        throw new Exception("IMG: Archive don't have enough space to add file.");
                    }
                    else
                        binaryWriter.BaseStream.Position = (long)num2;
                }
                else
                    binaryWriter.BaseStream.Position = (long)old_offset;
                //System.Windows.Forms.MessageBox.Show("Replacing #2 " + img.FileName + ": " + file);
                byte[] buffer = File.ReadAllBytes(file);
                //System.Windows.Forms.MessageBox.Show("Replacing #3 " + img.FileName + ": " + file);
                binaryWriter.Write(buffer);
                binaryReader.BaseStream.Position = 8L;
                uint num4 = old_offset / 2048U, num3 = 0U;
                string str = string.Empty;
                //System.Windows.Forms.MessageBox.Show("Replacing #4 " + img.FileName + ": " + file);
                for (int offsetFoundOn = 0; offsetFoundOn < img.Models.Count; offsetFoundOn++)
                {
                    if ((int)binaryReader.ReadUInt32() == (int)num4)
                    {
                        num3 = num4;
                        num5 = length / 2048;
                        if (length > old_size)
                        {
                            binaryWriter.BaseStream.Position = binaryReader.BaseStream.Position - 4L;
                            num3 = num2 / 2048U;
                            binaryWriter.Write(num3);
                        }
                        else
                            binaryWriter.BaseStream.Position = binaryReader.BaseStream.Position;
                        str = ValidateFileName(Path.GetFileName(file));
                        binaryWriter.Write(num5);
                        binaryWriter.Write(stringTo24bytes(str));
                        if (length > old_size || offsetFoundOn == img.Models.Count - 1)
                        {
                            img.LastOffsetSize[0] = (int)(num3 * 2048U);
                            img.LastOffsetSize[1] = num5 * 2;
                        }
                        if (img.Models.Count == 1)
                            img.FirstOffsetSize = img.LastOffsetSize;
                        //System.Windows.Forms.MessageBox.Show("Found: " + img.Models[offsetFoundOn].Name);
                        break;
                    }
                    else
                        binaryReader.BaseStream.Position += 28L;
                }
                //System.Windows.Forms.MessageBox.Show("Replacing #5 " + img.FileName + ": " + file);
                binaryWriter.Flush();
                binaryWriter.Close();
                binaryReader.Close();
            }
        }
        public static void Delete(ModelList img, string name)
        {
            img.Models.Remove(img.IndexPointers[name] as Model);
            BinaryWriter binaryWriter = new BinaryWriter((Stream)new FileStream(img.FileName, FileMode.Open, FileAccess.ReadWrite, FileShare.ReadWrite));
            binaryWriter.BaseStream.Position = 4L;
            binaryWriter.Write(img.Models.Count);
            uint num1 = 0U, num3 = 0U, num5 = 0U;
            int num2 = 0, num4 = 0, num6 = 0;
            for (int index = 0; index < img.Models.Count; index++)
            {
                num5 = img.Models[index].Offset;
                num6 = img.Models[index].Size;
                if (num5 < num1 || index == 0)
                {
                    num1 = num5;
                    num2 = num6;
                }
                if (num5 > num3)
                {
                    num3 = num5;
                    num4 = num6;
                }
                binaryWriter.Write((uint)((ulong)num5 / 2048UL));
                binaryWriter.Write((uint)(num6 / 2));
                binaryWriter.Write(stringTo24bytes(img.Models[index].Name));
            }
            binaryWriter.Flush();
            binaryWriter.Close();
            img.FirstOffsetSize[0] = (int)num1;
            img.FirstOffsetSize[1] = num2;
            img.LastOffsetSize[0] = (int)num3;
            img.LastOffsetSize[1] = num4;
        }
        /*private void addFiles(string[] filePaths)
        {
            if (this.label2.Text == "")
                return;
            ArrayList arrayList = this.validateFileNames(filePaths);
            if (arrayList.Count == 0)
            {
                int num1 = (int)MessageBox.Show("All selected files were invalid.", "IMG Manager");
            }
            else
            {
                if (Convert.ToInt32(this.filesCanBeAdd_LBL.Text) < arrayList.Count)
                {
                    int num2 = (int)MessageBox.Show("Adding " + (object)(arrayList.Count - Convert.ToInt32(this.filesCanBeAdd_LBL.Text)) + " more file(s) will require auto rebuild, please wait for a while ?");
                    this.filesRequireinRebuild = this.roundTo2048byte(arrayList.Count * 32);
                    this.rebuildArchiveToolStripMenuItem_Click((object)null, (EventArgs)null);
                }
                string[] strArray1 = (string[])arrayList.ToArray(typeof(string));
                DateTime now = DateTime.Now;
                this.groupBox1.Text = "Import Status";
                this.groupBox1.Visible = true;
                this.Timer_last_fileCount = 0;
                this.progressBar1.Value = 0;
                this.timer1.Enabled = true;
                this.totalFilesWillAdd_LBL.Text = strArray1.Length.ToString("0000");
                this.progressBar1.Step = 1000000 / strArray1.Length;
                BinaryWriter binaryWriter1 = new BinaryWriter((Stream)new FileStream(this.label2.Text, FileMode.Open, FileAccess.Write, FileShare.Write));
                BinaryWriter binaryWriter2 = new BinaryWriter((Stream)new FileStream(this.label2.Text, FileMode.Open, FileAccess.Write, FileShare.Write));
                string[] strArray2 = this.lastOffsetSize_LBL.Text.Split(new char[1]
        {
          '/'
        });
                binaryWriter1.BaseStream.Position = (long)(8 + this.files_DT.Rows.Count * 32);
                binaryWriter2.BaseStream.Position = (long)Convert.ToUInt32(strArray2[0]) + (long)(Convert.ToUInt32(strArray2[1]) / 2U) * 2048L;
                int num3;
                for (int index1 = 0; index1 < strArray1.Length; ++index1)
                {
                    byte[] numArray = File.ReadAllBytes(strArray1[index1]);
                    byte[] buffer = new byte[this.roundTo2048byte(numArray.Length)];
                    numArray.CopyTo((Array)buffer, 0);
                    string data = this.ValidateFileName(Path.GetFileName(strArray1[index1]));
                    binaryWriter1.Write((uint)((ulong)binaryWriter2.BaseStream.Position / 2048UL));
                    binaryWriter1.Write((uint)(buffer.Length / 2048));
                    binaryWriter1.Write(this.stringTo24bytes(data));
                    DataRow row = this.files_DT.NewRow();
                    row[0] = (object)data;
                    row[1] = (object)binaryWriter2.BaseStream.Position;
                    DataRow dataRow = row;
                    int index2 = 2;
                    num3 = buffer.Length / 1024;
                    string str1 = num3.ToString() + " KB";
                    dataRow[index2] = (object)str1;
                    this.files_DT.Rows.Add(row);
                    binaryWriter2.Write(buffer);
                    Label label = this.filesAdded_LBL;
                    num3 = index1 + 1;
                    string str2 = num3.ToString();
                    label.Text = str2;
                    this.progressBar1.PerformStep();
                    Application.DoEvents();
                }
                this.timer1.Enabled = false;
                this.groupBox1.Visible = false;
                TimeSpan timeSpan = DateTime.Now - now;
                if (IMGManager.Properties.Settings.Default.OnImport)
                {
                    int num4 = (int)MessageBox.Show((string)(object)strArray1.Length + (object)" file(s) imported successfully in " + (string)(object)timeSpan.Minutes + ":" + (string)(object)timeSpan.Seconds + ":" + (string)(object)timeSpan.Milliseconds, "IMG Manager");
                }
                this.lastOffsetSize_LBL.Text = this.files_DT.Rows[this.files_DT.Rows.Count - 1][1].ToString() + "/" + this.files_DT.Rows[this.files_DT.Rows.Count - 1][2].ToString().Replace(" KB", "");
                if (this.files_DT.Rows.Count == strArray1.Length)
                    this.firstOffsetSize_LBL.Text = this.files_DT.Rows[0][1].ToString() + "/" + this.files_DT.Rows[0][2].ToString().Replace(" KB", "");
                Label label1 = this.filesCanBeAdd_LBL;
                num3 = Convert.ToInt32(this.filesCanBeAdd_LBL.Text) - strArray1.Length;
                string str = num3.ToString("0000");
                label1.Text = str;
                binaryWriter1.BaseStream.Position = 4L;
                binaryWriter1.Write(this.files_DT.Rows.Count);
                binaryWriter1.Flush();
                binaryWriter2.Flush();
                binaryWriter1.Close();
                binaryWriter2.Close();
                this.dataGridView1.ClearSelection();
                this.dataGridView1.Rows[this.dataGridView1.Rows.Count - 1].Selected = true;
                this.dataGridView1.CurrentCell = this.dataGridView1.SelectedCells[0];
                this.uselessSpace_LBL.Font = this.strikeoutFont;
            }
        }*/
        private static int roundTo2048byte(int value)
        {
            bool flag = true;
            int i1 = value, i2 = 0;
            while (flag)
            {
                i2 += 2048;
                i1 -= 2048;
                flag = i1 > 0;
            }
            return i2;
        }
        private static byte[] stringTo24bytes(string data)
        {
            byte[] numArray = new byte[24];
            for (int index = 0; index < data.Length; ++index)
                numArray[index] = (byte)data[index];
            return numArray;
        }
        private static string ValidateFileName(string data)
        {
            return data.Length <= 24 ? data : data.Remove(20, data.Length - 24);
        }
        public class Model
        {
            public string Name = string.Empty, TXD = string.Empty, DFF = string.Empty;
            public int Size = 0;
            public uint Offset = 0;
            public Model(string name, uint o, int s)
            {
                Name = name;
                TXD = name + ".txd";
                DFF = name + ".dff";
                Offset = o;
                Size = s;
            }
        }
        public class ModelList
        {
            public string FileName = string.Empty;
            public List<Model> Models = null;
            public Hashtable IndexPointers = new Hashtable();
            public int[] FirstOffsetSize = new int[2] { 0, 0 }, LastOffsetSize = new int[2] { 0, 0 };
            public int FTBA = 0;
            public ModelList(string fname, List<Model> m)
            {
                FileName = fname;
                Models = m;
            }
            public void RefreshIndexPointers()
            {
                IndexPointers.Clear();
                for (int i = 0; i < Models.Count; i++)
                    IndexPointers[Models[i].Name] = Models[i];
            }
        }
    }
}