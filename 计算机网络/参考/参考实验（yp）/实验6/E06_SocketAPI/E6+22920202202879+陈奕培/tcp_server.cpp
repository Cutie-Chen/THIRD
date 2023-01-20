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

	/*����socket������socket����ΪIPv4��TCP����*/
	SOCKET slisten = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (slisten == INVALID_SOCKET)
	{
		printf("socket error !");
		return 0;
	}

	/*ʹ��bind��Э��˿ںţ�IP��ַ��ΪANY��ʹ�ü��������������IP��ַ��ͨ������˿ں�����������*/
	sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(8888);
	sin.sin_addr.S_un.S_addr = INADDR_ANY;
	if (bind(slisten, (LPSOCKADDR)&sin, sizeof(sin)) == SOCKET_ERROR)
	{
		printf("bind error !");
	}

	/*�����������趨������г���Ϊ5*/
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
		printf("�ȴ�����...\n");

		/*�����յ������ʱ�򣬽�Զ�˵�ַ����Ϣ���ݸ�remoteAddr��������һ���µ�ȫ���socket sClient*/
		sClient = accept(slisten, (SOCKADDR*)&remoteAddr, &nAddrlen);
		if (sClient == INVALID_SOCKET)
		{
			printf("accept error !");
			continue;
		}

		/*ͨ��Զ�˵�ַ�������ļ���*/
		printf("���ܵ�һ�����ӣ�%s \r\n", inet_ntoa(remoteAddr.sin_addr));
		if (!fh.createDir(inet_ntoa(remoteAddr.sin_addr)))printf("�ļ��д����ɹ���\n");

		/*���ݽ��յ�����Ϣ�������ļ���*/
		int ret = recv(sClient, revData, BUFSIZ, 0);
		if (strcmp(revData, "Final") == 0) {
			printf("IP��%s�Ͽ�����\n", inet_ntoa(remoteAddr.sin_addr));
			continue;
		}
		char finame[MAX_PATH] = {};
		strcat(finame, inet_ntoa(remoteAddr.sin_addr));
		strcat(finame, "\\");
		strcat(finame, revData);
		FILE* f = fh.createFile(finame);

		char sendData[BUFSIZ] = "��ã�������TCP�ͻ��ˣ�\n";
		char over[BUFSIZ] = "Final";
		send(sClient, sendData, BUFSIZ, 0);

		/*��¼�ļ���*/
		char fromname[BUFSIZ] = {};
		strcpy(fromname, revData);

		/*��¼���ճ���*/
		long long count = 0;

		/*ѭ������*/
		while ((ret = recv(sClient, revData, BUFSIZ, 0)) > 0)
		{
			printf("��ǰ���ճ���%db\n", count += ret);

			/*�����յ�����ϢΪfinalʱ����������*/
			if (strcmp(revData, over) == 0)
			{
				printf("�ļ�%s����ɹ�\n", fromname);
				send(sClient, over, BUFSIZ, 0);
				break;
			}

			/*���򣬽����յ�����Ϣ���浽�ļ�����*/
			fwrite(revData, 1, ret, f);

			/*���ͻ�Ӧ*/
			char sendData_continue[BUFSIZ] = "�ѽ��գ���������� \n";
			send(sClient, sendData_continue, BUFSIZ, 0);
		}
		fclose(f);

		/*�����һ�ν��յ���Ϣ��Ϊfinalʱ���������쳣���ͻ��˶Ͽ������ӣ���ʱ���ļ�ɾ��*/
		if (strcmp(revData, over) != 0)
		{
			printf("IP��%s������%s���������ʧȥ����\n", inet_ntoa(remoteAddr.sin_addr), fromname);
			remove(finame);
		}
		closesocket(sClient);
	}
	closesocket(slisten);
	WSACleanup();
	return 0;
}