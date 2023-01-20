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

	/*��������ΪIPv4�µ�UDP*/
	SOCKET ser_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

	/*�󶨶˿ںţ�IP��ַ��ΪANY*/
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

		/*��������Client�˵Ŀ�ʼ�ź�*/
		recvfrom(ser_socket, revData, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, &Addrlen);
		if (strcmp(revData, begin) == 0)
		{
			/*�����ļ��к��ļ�*/
			printf("���յ�����%s���ı���", inet_ntoa(remoteAddr.sin_addr));
			recvfrom(ser_socket, revData, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, &Addrlen);
			if (!fh.createDir(inet_ntoa(remoteAddr.sin_addr)))printf("�ļ��д����ɹ���\n");
			strcpy(fromname, revData);
			strcat(finame, inet_ntoa(remoteAddr.sin_addr));
			strcat(finame, mid);
			strcat(finame, revData);
			f = fh.createFile(finame);
		}

		/*ѭ�������ļ�����*/
		int count = 0;
		int ret;
		while ((ret = recvfrom(ser_socket, revData, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, &Addrlen)) > 0)
		{
			printf("��ǰ���ճ���%db\n", count += ret);

			/*���Ϊfinal��֤���������*/
			if (strcmp(revData, over) == 0)
			{
				printf("�ļ�%s����ɹ�\n", fromname);
				break;
			}
			/*���򱣴浽�ļ�����*/
			fwrite(revData, 1, ret, f);
			/*���ͻ�Ӧ*/
			char sendData_continue[BUFSIZ] = "�ѽ��գ���������� \n";
			sendto(ser_socket, sendData_continue, BUFSIZ, 0, (SOCKADDR*)&remoteAddr, sizeof(SOCKADDR));
		}
		fclose(f);

		/*������һ����Ϊfinal��֤����������쳣��ɾ���ļ�*/
		if (strcmp(revData, over) != 0)
		{
			printf("IP��%s������%s���������ʧȥ����\n", inet_ntoa(remoteAddr.sin_addr), fromname);
			remove(finame);
		}
	}
	closesocket(ser_socket);
	WSACleanup();
	return 0;
}