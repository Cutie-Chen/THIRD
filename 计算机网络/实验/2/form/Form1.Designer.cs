
namespace form
{
    partial class Form1
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.button_open = new System.Windows.Forms.Button();
            this.portname = new System.Windows.Forms.ComboBox();
            this.parity = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.databit = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.stopbit = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.baudrate = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.serialPort1 = new System.IO.Ports.SerialPort(this.components);
            this.text_receive = new System.Windows.Forms.TextBox();
            this.button_c_r = new System.Windows.Forms.Button();
            this.send = new System.Windows.Forms.GroupBox();
            this.button_c_s = new System.Windows.Forms.Button();
            this.button_send = new System.Windows.Forms.Button();
            this.text_send = new System.Windows.Forms.TextBox();
            this.groupBox1.SuspendLayout();
            this.send.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.button_open);
            this.groupBox1.Controls.Add(this.portname);
            this.groupBox1.Controls.Add(this.parity);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.databit);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.stopbit);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.baudrate);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Location = new System.Drawing.Point(21, 18);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(234, 266);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "串口配置";
            this.groupBox1.Enter += new System.EventHandler(this.groupBox1_Enter);
            // 
            // button_open
            // 
            this.button_open.Location = new System.Drawing.Point(95, 215);
            this.button_open.Name = "button_open";
            this.button_open.Size = new System.Drawing.Size(121, 34);
            this.button_open.TabIndex = 12;
            this.button_open.Text = "打开串口";
            this.button_open.UseVisualStyleBackColor = true;
            this.button_open.Click += new System.EventHandler(this.button1_Click);
            // 
            // portname
            // 
            this.portname.FormattingEnabled = true;
            this.portname.Location = new System.Drawing.Point(95, 27);
            this.portname.Name = "portname";
            this.portname.Size = new System.Drawing.Size(121, 26);
            this.portname.TabIndex = 7;
            // 
            // parity
            // 
            this.parity.FormattingEnabled = true;
            this.parity.Items.AddRange(new object[] {
            "无",
            "奇校验",
            "偶校验"});
            this.parity.Location = new System.Drawing.Point(95, 176);
            this.parity.Name = "parity";
            this.parity.Size = new System.Drawing.Size(121, 26);
            this.parity.TabIndex = 11;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(8, 32);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(80, 18);
            this.label1.TabIndex = 1;
            this.label1.Text = "端口号：";
            // 
            // databit
            // 
            this.databit.FormattingEnabled = true;
            this.databit.Items.AddRange(new object[] {
            "8",
            "7",
            "6",
            "5"});
            this.databit.Location = new System.Drawing.Point(95, 137);
            this.databit.Name = "databit";
            this.databit.Size = new System.Drawing.Size(121, 26);
            this.databit.TabIndex = 10;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(8, 67);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(80, 18);
            this.label2.TabIndex = 2;
            this.label2.Text = "波特率：";
            // 
            // stopbit
            // 
            this.stopbit.FormattingEnabled = true;
            this.stopbit.Items.AddRange(new object[] {
            "1",
            "1.5",
            "2"});
            this.stopbit.Location = new System.Drawing.Point(95, 99);
            this.stopbit.Name = "stopbit";
            this.stopbit.Size = new System.Drawing.Size(121, 26);
            this.stopbit.TabIndex = 9;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(8, 104);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(80, 18);
            this.label3.TabIndex = 3;
            this.label3.Text = "停止位：";
            // 
            // baudrate
            // 
            this.baudrate.FormattingEnabled = true;
            this.baudrate.Items.AddRange(new object[] {
            "1382400",
            "921600",
            "460800",
            "256000",
            "230400",
            "128000",
            "115200",
            "76800",
            "57600",
            "43000",
            "38400",
            "19200",
            "14400",
            "9600",
            "4800",
            "1200"});
            this.baudrate.Location = new System.Drawing.Point(95, 62);
            this.baudrate.Name = "baudrate";
            this.baudrate.Size = new System.Drawing.Size(121, 26);
            this.baudrate.TabIndex = 8;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(8, 141);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(80, 18);
            this.label4.TabIndex = 4;
            this.label4.Text = "数据位：";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(8, 180);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(80, 18);
            this.label5.TabIndex = 5;
            this.label5.Text = "校验位：";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(8, 220);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(80, 18);
            this.label6.TabIndex = 6;
            this.label6.Text = "操  作：";
            // 
            // serialPort1
            // 
            this.serialPort1.DataReceived += new System.IO.Ports.SerialDataReceivedEventHandler(this.serialPort1_DataReceived);
            // 
            // text_receive
            // 
            this.text_receive.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.text_receive.Location = new System.Drawing.Point(301, 18);
            this.text_receive.Multiline = true;
            this.text_receive.Name = "text_receive";
            this.text_receive.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.text_receive.Size = new System.Drawing.Size(460, 266);
            this.text_receive.TabIndex = 1;
            this.text_receive.TextChanged += new System.EventHandler(this.textBox1_TextChanged);
            // 
            // button_c_r
            // 
            this.button_c_r.Location = new System.Drawing.Point(77, 290);
            this.button_c_r.Name = "button_c_r";
            this.button_c_r.Size = new System.Drawing.Size(121, 34);
            this.button_c_r.TabIndex = 3;
            this.button_c_r.Text = "清除接收";
            this.button_c_r.UseVisualStyleBackColor = true;
            this.button_c_r.Click += new System.EventHandler(this.button2_Click);
            // 
            // send
            // 
            this.send.Controls.Add(this.button_c_s);
            this.send.Controls.Add(this.button_send);
            this.send.Controls.Add(this.text_send);
            this.send.Location = new System.Drawing.Point(32, 348);
            this.send.Name = "send";
            this.send.Size = new System.Drawing.Size(729, 215);
            this.send.TabIndex = 5;
            this.send.TabStop = false;
            this.send.Text = "数据发送";
            this.send.Enter += new System.EventHandler(this.send_Enter);
            // 
            // button_c_s
            // 
            this.button_c_s.Location = new System.Drawing.Point(559, 91);
            this.button_c_s.Name = "button_c_s";
            this.button_c_s.Size = new System.Drawing.Size(116, 35);
            this.button_c_s.TabIndex = 2;
            this.button_c_s.Text = "清除发送";
            this.button_c_s.UseVisualStyleBackColor = true;
            this.button_c_s.Click += new System.EventHandler(this.button4_Click);
            // 
            // button_send
            // 
            this.button_send.Location = new System.Drawing.Point(559, 47);
            this.button_send.Name = "button_send";
            this.button_send.Size = new System.Drawing.Size(114, 38);
            this.button_send.TabIndex = 1;
            this.button_send.Text = "发送";
            this.button_send.UseVisualStyleBackColor = true;
            this.button_send.Click += new System.EventHandler(this.button3_Click);
            // 
            // text_send
            // 
            this.text_send.Location = new System.Drawing.Point(22, 27);
            this.text_send.Multiline = true;
            this.text_send.Name = "text_send";
            this.text_send.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.text_send.Size = new System.Drawing.Size(478, 159);
            this.text_send.TabIndex = 0;
            this.text_send.TextChanged += new System.EventHandler(this.text_send_TextChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 18F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 594);
            this.Controls.Add(this.send);
            this.Controls.Add(this.button_c_r);
            this.Controls.Add(this.text_receive);
            this.Controls.Add(this.groupBox1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.send.ResumeLayout(false);
            this.send.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button button_open;
        private System.Windows.Forms.ComboBox portname;
        private System.Windows.Forms.ComboBox parity;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox databit;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox stopbit;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox baudrate;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label6;
        private System.IO.Ports.SerialPort serialPort1;
        private System.Windows.Forms.TextBox text_receive;
        private System.Windows.Forms.Button button_c_r;
        private System.Windows.Forms.GroupBox send;
        private System.Windows.Forms.Button button_c_s;
        private System.Windows.Forms.Button button_send;
        private System.Windows.Forms.TextBox text_send;
    }
}

