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

	/*ָ��������IP��ַ�Ͷ˿ں�*/
	sockaddr_in serAddr;
	serAddr.sin_family = AF_INET;
	serAddr.sin_port = htons(8888);
	serAddr.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");

	while (true)
	{
		/*����socket������socket����ΪIPv4��TCP����*/
		SOCKET sclient = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		if (sclient == INVALID_SOCKET)
		{
			printf("invalid socket !");
			return 0;
		}

		/*��������*/
		if (connect(sclient, (sockaddr*)&serAddr, sizeof(serAddr)) == SOCKET_ERROR)
		{
			printf("connect error !");
			closesocket(sclient);
			return 0;
		}

		/*ѡ���ļ�*/
		FILE* f = fh.selectfile();

		char sendData[BUFSIZ];
		char recData[BUFSIZ];
		char over[BUFSIZ] = "Final";
		char* name = fh.getFileName();
		strcpy(sendData, name);
		printf("%s\n", sendData);
		int nCount;
		long long sum = 0;

		/*�����ļ�����*/
		send(sclient, sendData, strlen(sendData) + 1, 0);
		int ret = recv(sclient, recData, BUFSIZ, 0);
		printf("recv message:%s", recData);

		/*ѭ�������ļ�����*/
		while ((nCount = fread(sendData, 1, BUFSIZ, f)) > 0)
		{
			send(sclient, sendData, nCount, 0);

			/*���ջ�Ӧ*/
			int ret = recv(sclient, recData, BUFSIZ, 0);
			if (ret > 0)
			{
				printf("recv message:%s", recData);
			}
			/*���û�л�Ӧ����������Ͽ�*/
			else
			{
				printf("�������ʧȥ����");
				break;
			}
		}

		/*����final�źţ�������ܵ�final�źŴ�����ɹ�*/
		send(sclient, over, BUFSIZ, 0);
		ret = recv(sclient, recData, BUFSIZ, 0);
		if (ret > 0 && strcmp(recData, over) == 0)
		{
			printf("����ɹ���\n");
		}
		fclose(f);
		closesocket(sclient);
	}
	WSACleanup();
	return 0;
}