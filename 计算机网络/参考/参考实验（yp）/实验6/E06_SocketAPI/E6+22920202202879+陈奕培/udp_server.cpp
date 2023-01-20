#include <stdio.h>
#include <stdio.h>
#include <winsock2.h>
#include "FileHelper.h"
#pragma comment(lib,"ws2_32.lib")

int main(int argc, char* argv[])
{
	WORD sockVersion = MAKEWORD(2, 2);
	WSADATA wsaData;
	FileHelper fh;
	if (WSAStartup(sockVersion, &wsaData) != 0)
	{
		return 0;
	}

	/*声明类型为IPv4下的UDP*/
	SOCKET ser_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

	/*绑定端口号，IP地址设为ANY*/
	sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(8888);
	sin.sin_addr.S_un.S_addr = INADDR_ANY;
	bind(ser_socket, (LPSOCKADDR)&sin, sizeof(sin));

	sockaddr_in remoteAddr;
	int Addrlen = sizeof(remoteAddr);
	char revData[BUFSIZ];
	while (true)
	{
		DWORD Time_out = 10;
		char begin[BUFSIZ] = "Start";
		char over[BUFSIZ] = "Final";
      char fromname[BUFSIZ] = {};
		char mid[3] = "\\";
		char finame[MAX_PATH] = {};
		FILE* f = NULL;
		if (setsockopt(ser_socket, SOL_SOCKET, SO_SNDTIMEO, (char*)&Time_out, sizeof(Time_out)))
		{
			printf("err!");
			continue;
		}

		/*接受来自Client端的开始信号*/
		recvfrom(ser_socket, revData, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, &Addrlen);
		if (strcmp(revData, begin) == 0)
		{
			/*创建文件夹和文件*/
			printf("接收到来自%s的文本报", inet_ntoa(remoteAddr.sin_addr));
			recvfrom(ser_socket, revData, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, &Addrlen);
			if (!fh.createDir(inet_ntoa(remoteAddr.sin_addr)))printf("文件夹创建成功！\n");
			strcpy(fromname, revData);
			strcat(finame, inet_ntoa(remoteAddr.sin_addr));
			strcat(finame, mid);
			strcat(finame, revData);
			f = fh.createFile(finame);
		}

		/*循环接受文件内容*/
		int count = 0;
		int ret;
		while ((ret = recvfrom(ser_socket, revData, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, &Addrlen)) > 0)
		{
			printf("当前接收长度%db\n", count += ret);

			/*如果为final，证明传输结束*/
			if (strcmp(revData, over) == 0)
			{
				printf("文件%s传输成功\n", fromname);
				break;
			}
			/*否则保存到文件当中*/
			fwrite(revData, 1, ret, f);
			/*发送回应*/
			char sendData_continue[BUFSIZ] = "已接收，请继续发送 \n";
			sendto(ser_socket, sendData_continue, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, sizeof(SOCKADDR));
		}
		fclose(f);

		/*如果最后一条不为final，证明传输出现异常，删除文件*/
		if (strcmp(revData, over) != 0)
		{
			printf("IP：%s发来的%s传输过程中失去连接\n", inet_ntoa(remoteAddr.sin_addr), fromname);
			remove(finame);
		}
	}
	closesocket(ser_socket);
	WSACleanup();
	return 0;
}