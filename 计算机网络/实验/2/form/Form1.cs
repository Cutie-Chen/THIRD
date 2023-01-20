using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.IO.Ports;
using System.Threading;

namespace form
{
    public partial class Form1 : Form
    {

        private DateTime now = new DateTime();//时间
        public Form1()
        {
            InitializeComponent();
        }

        private void groupBox1_Enter(object sender, EventArgs e)
        {

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            string[] ports = System.IO.Ports.SerialPort.GetPortNames();//获取电脑上可用串口号
            portname.Items.AddRange(ports);//给comboBox1添加数据
            portname.SelectedIndex = portname.Items.Count > 0 ? 0 : -1;//如果里面有数据,显示第0个
            baudrate.Text = "115200";
            stopbit.Text = "1";
            databit.Text = "8";
            parity.Text = "无";

        }


        private void button1_Click(object sender, EventArgs e)
        {
            if (button_open.Text == "打开串口")
            {
                try
                {
                    //设定相应信息
                    serialPort1.PortName = portname.Text;
                    serialPort1.BaudRate = int.Parse(baudrate.Text);
                    serialPort1.DataBits = int.Parse(databit.Text);

                    if (stopbit.Text == "1") { serialPort1.StopBits = System.IO.Ports.StopBits.One; }
                    else if (stopbit.Text == "1.5") { serialPort1.StopBits = StopBits.OnePointFive; }
                    else if (stopbit.Text == "2") { serialPort1.StopBits = StopBits.Two; }

                    if (parity.Text == "无") { serialPort1.Parity = System.IO.Ports.Parity.None; }
                    else if (parity.Text == "奇校验") { serialPort1.Parity = Parity.Odd; }
                    else if (parity.Text == "偶校验") { serialPort1.Parity = Parity.Even; }

                    serialPort1.Open();
                    button_open.Text = "关闭串口";
                }
                catch (Exception err)
                {
                    MessageBox.Show("打开失败" + err.ToString(), "提示!");
                }
            }
            else
            {
                try
                {
                    serialPort1.Close();
                }
                catch (Exception) { }
                button_open.Text = "打开串口";
            }
        }



        private void serialPort1_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            try
            {
                string t = serialPort1.ReadExisting();
                this.Invoke((EventHandler)(delegate
                {

                    now = System.DateTime.Now;//获取时间
                    text_receive.AppendText("[RESV " + now.ToString("G") + "]" + t + "\r\n");//添加到接受文本框
                   
                })
                );
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);//异常信息

            }
        }


        private void button2_Click(object sender, EventArgs e)
        {
            text_receive.Clear();//清除接收
        }

        private void button4_Click(object sender, EventArgs e)
        {
            text_send.Clear();//清除发送
        }

        private void button3_Click(object sender, EventArgs e)
        {

            if (serialPort1.IsOpen)
            {
                if (text_send.Text != "")
                {

                    try
                    {
                        now = System.DateTime.Now;
                        serialPort1.Write("[SENT " + now.ToString("G") + "] " + text_send.Text);//写入串行端口
                        text_receive.AppendText("[SENT " + now.ToString("G") + "] " + text_send.Text + "\r\n");//添加到接收文本框
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.Message);//异常信息
                        button_c_r.Enabled = true;
                        button_send.Enabled = false;


                    }
                }
            }
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void text_send_TextChanged(object sender, EventArgs e)
        {

        }

        private void send_Enter(object sender, EventArgs e)
        {

        }


    }
}
