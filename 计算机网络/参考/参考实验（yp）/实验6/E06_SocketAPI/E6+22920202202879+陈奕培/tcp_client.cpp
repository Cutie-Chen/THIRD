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

	/*指定服务器IP地址和端口号*/
	sockaddr_in serAddr;
	serAddr.sin_family = AF_INET;
	serAddr.sin_port = htons(8888);
	serAddr.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

	while (true)
	{
		/*建立socket，描述socket类型为IPv4的TCP服务*/
		SOCKET sclient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		if (sclient == INVALID_SOCKET)
		{
			printf("invalid socket !");
			return 0;
		}

		/*发出请求*/
		if (connect(sclient, (sockaddr*)&serAddr, sizeof(serAddr)) == SOCKET_ERROR)
		{
			printf("connect error !");
			closesocket(sclient);
			return 0;
		}

		/*选择文件*/
		FILE* f = fh.selectfile();

		char sendData[BUFSIZ];
		char recData[BUFSIZ];
		char over[BUFSIZ] = "Final";
		char* name = fh.getFileName();
		strcpy(sendData, name);
		printf("%s\n", sendData);
		int nCount;
		long long sum = 0;

		/*发送文件名字*/
		send(sclient, sendData, strlen(sendData) + 1, 0);
		int ret = recv(sclient, recData, BUFSIZ, 0);
		printf("recv message:%s", recData);

		/*循环发送文件内容*/
		while ((nCount = fread(sendData, 1, BUFSIZ, f)) > 0)
		{
			send(sclient, sendData, nCount, 0);

			/*接收回应*/
			int ret = recv(sclient, recData, BUFSIZ, 0);
			if (ret > 0)
			{
				printf("recv message:%s", recData);
			}
			/*如果没有回应代表服务器断开*/
			else
			{
				printf("与服务器失去连接");
				break;
			}
		}

		/*发送final信号，如果接受到final信号代表传输成功*/
		send(sclient, over, BUFSIZ, 0);
		ret = recv(sclient, recData, BUFSIZ, 0);
		if (ret > 0 && strcmp(recData, over) == 0)
		{
			printf("传输成功！\n");
		}
		fclose(f);
		closesocket(sclient);
	}
	WSACleanup();
	return 0;
}