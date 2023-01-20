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

	/*建立socket，描述socket类型为IPv4的TCP服务*/
	SOCKET slisten = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (slisten == INVALID_SOCKET)
	{
		printf("socket error !");
		return 0;
	}

	/*使用bind绑定协议端口号，IP地址设为ANY，使该计算机可以在任意IP地址下通过这个端口号来接收请求*/
	sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(8888);
	sin.sin_addr.S_un.S_addr = INADDR_ANY;
	if (bind(slisten, (LPSOCKADDR)&sin, sizeof(sin)) == SOCKET_ERROR)
	{
		printf("bind error !");
	}

	/*启动监听，设定请求队列长度为5*/
	if (listen(slisten, 5) == SOCKET_ERROR)
	{
		printf("listen error !");
		return 0;
	}

	SOCKET sClient;
	sockaddr_in remoteAddr;
	int nAddrlen = sizeof(remoteAddr);
	char revData[BUFSIZ];
	while (true)
	{
		printf("等待连接...\n");

		/*当接收到请求的时候，将远端地址的信息传递给remoteAddr，并建立一个新的全相关socket sClient*/
		sClient = accept(slisten, (SOCKADDR*)&remoteAddr, &nAddrlen);
		if (sClient == INVALID_SOCKET)
		{
			printf("accept error !");
			continue;
		}

		/*通过远端地址，生成文件夹*/
		printf("接受到一个连接：%s \r\n", inet_ntoa(remoteAddr.sin_addr));
		if (!fh.createDir(inet_ntoa(remoteAddr.sin_addr)))printf("文件夹创建成功！\n");

		/*根据接收到的信息，生成文件名*/
		int ret = recv(sClient, revData, BUFSIZ, 0);
		if (strcmp(revData, "Final") == 0) {
			printf("IP：%s断开连接\n", inet_ntoa(remoteAddr.sin_addr));
			continue;
		}
		char finame[MAX_PATH] = {};
		strcat(finame, inet_ntoa(remoteAddr.sin_addr));
		strcat(finame, "\\");
		strcat(finame, revData);
		FILE* f = fh.createFile(finame);

		char sendData[BUFSIZ] = "你好，这里是TCP客户端！\n";
		char over[BUFSIZ] = "Final";
		send(sClient, sendData, BUFSIZ, 0);

		/*记录文件名*/
		char fromname[BUFSIZ] = {};
		strcpy(fromname, revData);

		/*记录接收长度*/
		long long count = 0;

		/*循环接收*/
		while ((ret = recv(sClient, revData, BUFSIZ, 0)) > 0)
		{
			printf("当前接收长度%db\n", count += ret);

			/*当接收到的信息为final时，结束接收*/
			if (strcmp(revData, over) == 0)
			{
				printf("文件%s传输成功\n", fromname);
				send(sClient, over, BUFSIZ, 0);
				break;
			}

			/*否则，将接收到的信息保存到文件当中*/
			fwrite(revData, 1, ret, f);

			/*发送回应*/
			char sendData_continue[BUFSIZ] = "已接收，请继续发送 \n";
			send(sClient, sendData_continue, BUFSIZ, 0);
		}
		fclose(f);

		/*当最后一次接收到信息不为final时，代表传输异常，客户端断开来连接，此时将文件删除*/
		if (strcmp(revData, over) != 0)
		{
			printf("IP：%s发来的%s传输过程中失去连接\n", inet_ntoa(remoteAddr.sin_addr), fromname);
			remove(finame);
		}
		closesocket(sClient);
	}
	closesocket(slisten);
	WSACleanup();
	return 0;
}