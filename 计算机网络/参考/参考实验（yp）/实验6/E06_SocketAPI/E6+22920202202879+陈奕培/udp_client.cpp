#include <stdio.h>
#include <WINSOCK2.H>
#include"FileHelper.h"
#pragma  comment(lib,"ws2_32.lib")


int main(int argc, char* argv[])
{
	WORD sockVersion = MAKEWORD(2, 2);
	WSADATA data;
	FileHelper fh;
	if (WSAStartup(sockVersion, &data) != 0)
	{
		return 0;
	}

	/*声明IP地址和端口号*/
	sockaddr_in serAddr;
	serAddr.sin_family = AF_INET;
	serAddr.sin_port = htons(8888);
	serAddr.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

	while (true)
	{
		/*声明类型为IPv4下的UDP*/
		SOCKET sclient = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

		/*选择文件*/
		FILE* f = fh.selectfile();
		char sendData[BUFSIZ];
		char revData[BUFSIZ];
		char begin[BUFSIZ] = "Start";
		char over[BUFSIZ] = "Final";
		char* name = fh.getFileName();
		strcpy(sendData, name);
		printf("%s\n", name);
		int nCount;
		int sum = 0;

		/*发送开始信号和文件名*/
		sendto(sclient, begin, BUFSIZ, 0, (SOCKADDR*)&serAddr, sizeof(SOCKADDR));
		sendto(sclient, name, BUFSIZ, 0, (SOCKADDR*)&serAddr, sizeof(SOCKADDR));
		
		/*循环发送文件内容*/
		while ((nCount = fread(sendData, 1, BUFSIZ, f)) > 0)
		{
			Sleep(1);
			sendto(sclient, sendData, nCount, 0, (SOCKADDR*)&serAddr, sizeof(SOCKADDR));
			int Addrlen = sizeof(serAddr);

			/*如果无回应，证明服务器断开*/
			int ret = recvfrom(sclient, revData, BUFSIZ, 0, (SOCKADDR*)&serAddr, &Addrlen);
			if (ret > 0)
			{
				printf("recv message:%s", revData);
			}
			else
			{
				printf("与服务器失去连接");
				break;
			}
		}

		/*发送结束信号*/
		sendto(sclient, over, BUFSIZ, 0, (SOCKADDR*)&serAddr, sizeof(SOCKADDR));

		fclose(f);
		closesocket(sclient);
	}
	WSACleanup();
	return 0;
}