/* client.c - code for example client program that uses TCP */
#ifndef unix
#define WIN32
#include <windows.h>
#include <winsock.h>
#else
#define closesocket close
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#endif

#include <stdio.h>
#include <string.h>

#define PROTOPORT 5193 /* default protocol port number */
extern int errno;
char localhost[] = "localhost"; /* default host name*/

/*------------------------------------------------------------------------
* Program: client
*
* Purpose: allocate a socket, connect to a server, and print all output
*
* Syntax: client [ host [port] ]
*
* host - name of a computer on which server is executing
* port - protocol port number server is using
*
* Note: Both arguments are optional. If no host name is specified,
* the client uses "localhost"; if no protocol port is
* specified, the client uses the default given by PROTOPORT.
*
*------------------------------------------------------------------------
*/

int main(int argc, char* argv)
{
	struct hostent* ptrh; /* pointer to a host table entry */
	struct protoent* ptrp; /* pointer to a protocol table entry */
	struct sockaddr_in sad; /* structure to hold an IP address */
	int sd; /* socket descriptor */
	int port; /* protocol port number */
	char* host; /* pointer to host name */
	int n; /* number of characters read */
	char buf[1000]; /* buffer for data from the server */

#ifdef WIN32
	WSADATA wsaData;
	WSAStartup(0x0101, &wsaData);
#endif
	memset((char*)&sad, 0, sizeof(sad)); /* clear sockaddr structure */
	sad.sin_family = AF_INET; /* set family to Internet */
	/* Check command-line argument for protocol port and extract */
	/* port number if one is specified. Otherwise, use the default */
	/* port value given by constant PROTOPORT*/

	if (argc > 1 && argv[1] == '?')
	{
		printf("Program: client\n");
		printf("Purpose: allocate a socket, connect to a server, and print all output\n");
		printf("Syntax: client [ host [port] ]\n");
		printf(" host - name of a computer on which server is executing\n");
		printf(" port - protocol port number server is using\n");
		printf("Note: Both arguments are optional. If no host name is specified, \n");
		printf(" the client uses \"localhost\"; if no protocol port is\n");
		printf(" specified, the client uses the default given by PROTOPORT.\n");
		exit(1);
	}

	if (argc > 2) { /* if protocol port specified */
		port = atoi(&argv[2]); /* convert to binary */
	}
	else {
		port = PROTOPORT; /* use default port number */
	}
	if (port > 0) /* test for legal value */
		sad.sin_port = htons((u_short)port);
	else { /* print error message and exit */
		fprintf(stderr, "bad port number %s\n", argv[2]);
		exit(1);
	}
	/* Check host argument and assign host name. */
	if (argc > 1) {
		host = &argv[1]; /* if host argument specified */
	}
	else {
		host = localhost;
	}

	/* Convert host name to equivalent IP address and copy to sad. */
	ptrh = gethostbyname(host);
	if (((char*)ptrh) == NULL) {
		fprintf(stderr, "invalid host: %s\n", host);
		exit(1);
	}
	memcpy(&sad.sin_addr, ptrh->h_addr, ptrh->h_length);
	/* Map TCP transport protocol name to protocol number. */
	if (((unsigned long long)(ptrp = getprotobyname("tcp"))) == 0) {
		fprintf(stderr, "cannot map \"tcp\" to protocol number");
		exit(1);
	}
	/* Create a socket. */
	sd = socket(PF_INET, SOCK_STREAM, ptrp->p_proto);
	if (sd < 0) {
		fprintf(stderr, "socket creation failed\n");
		exit(1);
	}

	/* Connect the socket to the specified server. */
	if (connect(sd, (struct sockaddr*)&sad, sizeof(sad)) < 0) {
		fprintf(stderr, "connect failed\n");
		exit(1);
	}

	/* Repeatedly read data from socket and write to user's screen. */
	n = recv(sd, buf, sizeof(buf), 0);
	while (n > 0) {
		printf("1");
		printf("\n%d", buf);
		printf("\n%d", n);
		n = recv(sd, buf, sizeof(buf), 0);
	}
	/* Close the socket. */
	closesocket(sd);
	/* Terminate the client program gracefully. */
	exit(0);
}