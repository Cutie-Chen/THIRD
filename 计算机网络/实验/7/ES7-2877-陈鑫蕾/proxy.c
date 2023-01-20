#define _GNU_SOURCE
#include <sys/types.h>
#include <stdio.h>
#include <stdarg.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <netdb.h>
#include <sys/select.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <pthread.h>

#define BUFSIZE 65536
#define IPSIZE 4
#define ARRAY_SIZE(x) (sizeof(x) / sizeof(x[0]))
#define ARRAY_INIT \
	{              \
		0          \
	}

unsigned short int port = 1080;
int daemon_mode = 0;
int auth_type;
char* arg_username;
char* arg_password;
FILE* log_file;
pthread_mutex_t lock;

enum socks
{
	RESERVED = 0x00,
	VERSION4 = 0x04,
	VERSION5 = 0x05
};

enum socks_auth_methods
{
	NOAUTH = 0x00,
	USERPASS = 0x02,
	NOMETHOD = 0xff
};

enum socks_auth_userpass
{
	AUTH_OK = 0x00,
	AUTH_VERSION = 0x01,
	AUTH_FAIL = 0xff
};

enum socks_command
{
	CONNECT = 0x01
};

enum socks_command_type
{
	IP = 0x01,
	DOMAIN = 0x03
};

enum socks_status
{
	OK = 0x00,
	FAILED = 0x05
};

//打印日志信息
void log_message(const char* message, ...)
{
	//只有守护进程模式为0时,才会打印日志信息
	if (daemon_mode)
	{
		return;
	}

	char vbuffer[255];
	va_list args;
	va_start(args, message);
	vsnprintf(vbuffer, ARRAY_SIZE(vbuffer), message, args);
	va_end(args);

	time_t now;
	time(&now);
	char* date = ctime(&now);
	date[strlen(date) - 1] = '\0';

	pthread_t self = pthread_self();

	if (errno != 0)
	{
		pthread_mutex_lock(&lock);
		fprintf(log_file, "[%s][%lu] Critical: %s - %s\n", date, self,
			vbuffer, strerror(errno));
		errno = 0;
		pthread_mutex_unlock(&lock);
	}
	else
	{
		fprintf(log_file, "[%s][%lu] Info: %s\n", date, self, vbuffer);
	}
	fflush(log_file);
}

//格式化读入,用于处理一些规格化表达式
int readn(int fd, void* buf, int n)
{
	int nread, left = n;
	while (left > 0)
	{
		if ((nread = read(fd, buf, left)) == -1)
		{
			if (errno == EINTR || errno == EAGAIN)
			{
				continue;
			}
		}
		else
		{
			if (nread == 0)
			{
				return 0;
			}
			else
			{
				left -= nread;
				buf += nread;
			}
		}
	}
	return n;
}
//格式化写入,用于处理一些规格化表达式
int writen(int fd, void* buf, int n)
{
	int nwrite, left = n;
	while (left > 0)
	{
		if ((nwrite = write(fd, buf, left)) == -1)
		{
			if (errno == EINTR || errno == EAGAIN)
			{
				continue;
			}
		}
		else
		{
			if (nwrite == n)
			{
				return 0;
			}
			else
			{
				left -= nwrite;
				buf += nwrite;
			}
		}
	}
	return n;
}

//结束程序的某一进程
void app_thread_exit(int ret, int fd)
{
	close(fd);
	pthread_exit((void*)&ret);
}

//代理连接外网函数
int app_connect(int type, void* buf, unsigned short int portnum)
{
	int fd;
	struct sockaddr_in remote;
	char address[16];

	memset(address, 0, ARRAY_SIZE(address));

	if (type == IP)
	{
		//使用ip来初始化套接字结构体remote
		char* ip = (char*)buf;
		snprintf(address, ARRAY_SIZE(address), "%hhu.%hhu.%hhu.%hhu",
			ip[0], ip[1], ip[2], ip[3]);
		memset(&remote, 0, sizeof(remote));
		remote.sin_family = AF_INET;
		remote.sin_addr.s_addr = inet_addr(address);
		remote.sin_port = htons(portnum);

		//为连接网站而创建一个新的套接字接口
		fd = socket(AF_INET, SOCK_STREAM, 0);
		//使用connect函数连接该网站
		if (connect(fd, (struct sockaddr*)&remote, sizeof(remote)) < 0)
		{
			log_message("connect() in app_connect");
			close(fd);
			return -1;
		}

		return fd;
	}
	else if (type == DOMAIN)
	{
		char portaddr[6];
		struct addrinfo* res;
		snprintf(portaddr, ARRAY_SIZE(portaddr), "%d", portnum);
		log_message("getaddrinfo: %s %s", (char*)buf, portaddr);

		//域名解析
		int ret = getaddrinfo((char*)buf, portaddr, NULL, &res);
		if (ret == EAI_NODATA)
		{
			return -1;
		}
		else if (ret == 0)
		{
			struct addrinfo* r;
			//域名解析过程可能会有多个相同的ip
			for (r = res; r != NULL; r = r->ai_next)
			{
				fd = socket(r->ai_family, r->ai_socktype,
					r->ai_protocol);
				if (fd == -1)
				{
					continue;
				}
				//使用connect函数连接该网站
				ret = connect(fd, r->ai_addr, r->ai_addrlen);
				if (ret == 0)
				{
					freeaddrinfo(res);
					return fd;
				}
				else
				{
					close(fd);
				}
			}
		}
		freeaddrinfo(res);
		return -1;
	}

	return -1;
}

//创建套接字
int socks_invitation(int fd, int* version)
{
	char init[2];
	//格式化读取套接字版本信息,并进行相应的判断
	int nread = readn(fd, (void*)init, ARRAY_SIZE(init));
	if (nread == 2 && init[0] != VERSION5 && init[0] != VERSION4)
	{
		log_message("They send us %hhX %hhX", init[0], init[1]);
		log_message("Incompatible version!");
		app_thread_exit(0, fd);
	}
	log_message("Initial %hhX %hhX", init[0], init[1]);
	*version = init[0];
	return init[1];
}

//获取用户输入的用户名
char* socks5_auth_get_user(int fd)
{
	unsigned char size;
	readn(fd, (void*)&size, sizeof(size));

	char* user = (char*)malloc(sizeof(char) * size + 1);
	readn(fd, (void*)user, (int)size);
	user[size] = 0;

	return user;
}

//获取用户输入的密码
char* socks5_auth_get_pass(int fd)
{
	unsigned char size;
	readn(fd, (void*)&size, sizeof(size));

	char* pass = (char*)malloc(sizeof(char) * size + 1);
	readn(fd, (void*)pass, (int)size);
	pass[size] = 0;

	return pass;
}

//判断用户输入的用户名和密码是否合法且正确
int socks5_auth_userpass(int fd)
{
	char answer[2] = { VERSION5, USERPASS };
	writen(fd, (void*)answer, ARRAY_SIZE(answer));
	char resp;
	readn(fd, (void*)&resp, sizeof(resp));
	log_message("auth %hhX", resp);
	char* username = socks5_auth_get_user(fd);
	char* password = socks5_auth_get_pass(fd);
	log_message("l: %s p: %s", username, password);
	if (strcmp(arg_username, username) == 0 && strcmp(arg_password, password) == 0)
	{
		char answer[2] = { AUTH_VERSION, AUTH_OK };
		writen(fd, (void*)answer, ARRAY_SIZE(answer));
		free(username);
		free(password);
		return 0;
	}
	else
	{
		char answer[2] = { AUTH_VERSION, AUTH_FAIL };
		writen(fd, (void*)answer, ARRAY_SIZE(answer));
		free(username);
		free(password);
		return 1;
	}
}

//当身份验证模式为NOAUTH时,无需验证用户名和密码
int socks5_auth_noauth(int fd)
{
	char answer[2] = { VERSION5, NOAUTH };
	writen(fd, (void*)answer, ARRAY_SIZE(answer));
	return 0;
}

void socks5_auth_notsupported(int fd)
{
	char answer[2] = { VERSION5, NOMETHOD };
	writen(fd, (void*)answer, ARRAY_SIZE(answer));
}

//对用户进行身份验证
void socks5_auth(int fd, int methods_count)
{
	int supported = 0;
	int num = methods_count;
	for (int i = 0; i < num; i++)
	{
		char type;
		readn(fd, (void*)&type, 1);
		log_message("Method AUTH %hhX", type);
		if (type == auth_type)
		{
			supported = 1;
		}
	}
	if (supported == 0)
	{
		socks5_auth_notsupported(fd);
		app_thread_exit(1, fd);
	}
	int ret = 0;
	switch (auth_type)
	{
	case NOAUTH:
		ret = socks5_auth_noauth(fd);
		break;
	case USERPASS:
		ret = socks5_auth_userpass(fd);
		break;
	}
	if (ret == 0)
	{
		return;
	}
	else
	{
		app_thread_exit(1, fd);
	}
}

int socks5_command(int fd)
{
	char command[4];
	readn(fd, (void*)command, ARRAY_SIZE(command));
	log_message("Command %hhX %hhX %hhX %hhX", command[0], command[1],
		command[2], command[3]);
	return command[3];
}

//获取套接字中的端口信息
unsigned short int socks_read_port(int fd)
{
	unsigned short int p;
	readn(fd, (void*)&p, sizeof(p));
	log_message("Port %hu", ntohs(p));
	return p;
}

//获取套接字中的ip地址
char* socks_ip_read(int fd)
{
	char* ip = (char*)malloc(sizeof(char) * IPSIZE);
	readn(fd, (void*)ip, IPSIZE);
	log_message("IP %hhu.%hhu.%hhu.%hhu", ip[0], ip[1], ip[2], ip[3]);
	return ip;
}

//编写要向指定ip地址发送的信息
void socks5_ip_send_response(int fd, char* ip, unsigned short int port)
{
	char response[4] = { VERSION5, OK, RESERVED, IP };
	writen(fd, (void*)response, ARRAY_SIZE(response));
	writen(fd, (void*)ip, IPSIZE);
	writen(fd, (void*)&port, sizeof(port));
}

//获取套接字中的域名信息
char* socks5_domain_read(int fd, unsigned char* size)
{
	unsigned char s;
	readn(fd, (void*)&s, sizeof(s));
	char* address = (char*)malloc((sizeof(char) * s) + 1);
	readn(fd, (void*)address, (int)s);
	address[s] = 0;
	log_message("Address %s", address);
	*size = s;
	return address;
}

//编写要向指定域名发送的信息
void socks5_domain_send_response(int fd, char* domain, unsigned char size,
	unsigned short int port)
{
	char response[4] = { VERSION5, OK, RESERVED, DOMAIN };
	writen(fd, (void*)response, ARRAY_SIZE(response));
	writen(fd, (void*)&size, sizeof(size));
	writen(fd, (void*)domain, size * sizeof(char));
	writen(fd, (void*)&port, sizeof(port));
}

int socks4_is_4a(char* ip)
{
	return (ip[0] == 0 && ip[1] == 0 && ip[2] == 0 && ip[3] != 0);
}

int socks4_read_nstring(int fd, char* buf, int size)
{
	char sym = 0;
	int nread = 0;
	int i = 0;

	while (i < size)
	{
		nread = recv(fd, &sym, sizeof(char), 0);

		if (nread <= 0)
		{
			break;
		}
		else
		{
			buf[i] = sym;
			i++;
		}

		if (sym == 0)
		{
			break;
		}
	}

	return i;
}

void socks4_send_response(int fd, int status)
{
	char resp[8] = { 0x00, (char)status, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
	writen(fd, (void*)resp, ARRAY_SIZE(resp));
}

void app_socket_pipe(int fd0, int fd1)
{
	int maxfd, ret;
	fd_set rd_set;
	size_t nread;
	char buffer_r[BUFSIZE];

	log_message("Connecting two sockets");

	maxfd = (fd0 > fd1) ? fd0 : fd1;
	while (1)
	{
		FD_ZERO(&rd_set);
		FD_SET(fd0, &rd_set);
		FD_SET(fd1, &rd_set);
		ret = select(maxfd + 1, &rd_set, NULL, NULL, NULL);

		if (ret < 0 && errno == EINTR)
		{
			continue;
		}

		if (FD_ISSET(fd0, &rd_set))
		{
			nread = recv(fd0, buffer_r, BUFSIZE, 0);
			if (nread <= 0)
				break;
			send(fd1, (const void*)buffer_r, nread, 0);
		}

		if (FD_ISSET(fd1, &rd_set))
		{
			nread = recv(fd1, buffer_r, BUFSIZE, 0);
			if (nread <= 0)
				break;
			send(fd0, (const void*)buffer_r, nread, 0);
		}
	}
}

//程序子进程处理函数
void* app_thread_process(void* fd)
{
	int net_fd = *(int*)fd;
	int version = 0;
	int inet_fd = -1;
	//为子进程创建socks4或5的socks代理服务
	char methods = socks_invitation(net_fd, &version);

	//根据socks4或socks5,进行不同的操作来访问外网
	switch (version)
	{
	case VERSION5:
	{
		//进行身份验证
		socks5_auth(net_fd, methods);
		int command = socks5_command(net_fd);

		//进行连接对应的IP地址
		if (command == IP)
		{
			char* ip = socks_ip_read(net_fd);
			unsigned short int p = socks_read_port(net_fd);

			inet_fd = app_connect(IP, (void*)ip, ntohs(p));
			if (inet_fd == -1)
			{
				app_thread_exit(1, net_fd);
			}
			socks5_ip_send_response(net_fd, ip, p);
			free(ip);
			break;
		}
		//进行连接对应的域名地址
		else if (command == DOMAIN)
		{
			unsigned char size;
			char* address = socks5_domain_read(net_fd, &size);
			unsigned short int p = socks_read_port(net_fd);

			inet_fd = app_connect(DOMAIN, (void*)address, ntohs(p));
			if (inet_fd == -1)
			{
				app_thread_exit(1, net_fd);
			}
			socks5_domain_send_response(net_fd, address, size, p);
			free(address);
			break;
		}
		else
		{
			app_thread_exit(1, net_fd);
		}
	}
	case VERSION4:
	{
		if (methods == 1)
		{
			char ident[255];
			unsigned short int p = socks_read_port(net_fd);
			char* ip = socks_ip_read(net_fd);
			socks4_read_nstring(net_fd, ident, sizeof(ident));

			//判断是4a还是4，如果是4a，则对域名进行连接网站，否则用ip地址来连接
			if (socks4_is_4a(ip))
			{
				char domain[255];
				socks4_read_nstring(net_fd, domain, sizeof(domain));
				log_message("Socks4A: ident:%s; domain:%s;", ident, domain);
				inet_fd = app_connect(DOMAIN, (void*)domain, ntohs(p));
			}
			else
			{
				log_message("Socks4: connect by ip & port");
				inet_fd = app_connect(IP, (void*)ip, ntohs(p));
			}

			//回应客户端
			if (inet_fd != -1)
			{
				socks4_send_response(net_fd, 0x5a);
			}
			else
			{
				socks4_send_response(net_fd, 0x5b);
				free(ip);
				app_thread_exit(1, net_fd);
			}

			free(ip);
		}
		else
		{
			log_message("Unsupported mode");
		}
		break;
	}
	}

	app_socket_pipe(inet_fd, net_fd);
	close(inet_fd);
	app_thread_exit(0, net_fd);

	return NULL;
}

int app_loop()
{
	int sock_fd, net_fd;
	int optval = 1;
	struct sockaddr_in local, remote;
	socklen_t remotelen;

	//创建socket,设置为流模式
	if ((sock_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
	{
		log_message("socket()");
		exit(1);
	}

	//设置socket状态,SO_REUSEADDR表示允许在bind ()过程中本地地址可重复使用
	if (setsockopt(sock_fd, SOL_SOCKET, SO_REUSEADDR, (char*)&optval,
		sizeof(optval)) < 0)
	{
		log_message("setsockopt()");
		exit(1);
	}

	//初始化本地socket地址为0.0.0.0和端口号(默认值为1080)
	memset(&local, 0, sizeof(local));
	local.sin_family = AF_INET;
	local.sin_addr.s_addr = htonl(INADDR_ANY);
	local.sin_port = htons(port);

	//使用bind()来绑定socket
	if (bind(sock_fd, (struct sockaddr*)&local, sizeof(local)) < 0)
	{
		log_message("bind()");
		exit(1);
	}

	//启动监听函数,获取客户连接信息,并设置监听队列长度为25
	if (listen(sock_fd, 25) < 0)
	{
		log_message("listen()");
		exit(1);
	}

	remotelen = sizeof(remote);
	memset(&remote, 0, sizeof(remote));

	log_message("Listening port %d...", port);

	pthread_t worker;
	while (1)
	{
		//使用accept()函数来处理客户端tcp连接请求
		if ((net_fd =
			accept(sock_fd, (struct sockaddr*)&remote,
				&remotelen)) < 0)
		{
			log_message("accept()");
			exit(1);
		}

		int one = 1;
		setsockopt(sock_fd, SOL_TCP, TCP_NODELAY, &one, sizeof(one));

		//创建子线程来处理该客端户的代理服务
		if (pthread_create(&worker, NULL, &app_thread_process,
			(void*)&net_fd) == 0)
		{
			pthread_detach(worker);
		}
		else
		{
			log_message("pthread_create()");
		}
	}
}

void daemonize()
{
	pid_t pid;
	int x;

	pid = fork();

	if (pid < 0)
	{
		exit(EXIT_FAILURE);
	}

	if (pid > 0)
	{
		exit(EXIT_SUCCESS);
	}

	if (setsid() < 0)
	{
		exit(EXIT_FAILURE);
	}

	signal(SIGCHLD, SIG_IGN);
	signal(SIGHUP, SIG_IGN);

	pid = fork();

	if (pid < 0)
	{
		exit(EXIT_FAILURE);
	}

	if (pid > 0)
	{
		exit(EXIT_SUCCESS);
	}

	umask(0);
	chdir("/");

	for (x = sysconf(_SC_OPEN_MAX); x >= 0; x--)
	{
		close(x);
	}
}

void usage(char* app)
{
	printf("USAGE: %s [-h][-n PORT][-a AUTHTYPE][-u USERNAME][-p PASSWORD][-l LOGFILE]\n",
		app);
	printf("AUTHTYPE: 0 for NOAUTH, 2 for USERPASS\n");
	printf("By default: port is 1080, authtype is no auth, logfile is stdout\n");
	exit(1);
}

int main(int argc, char* argv[])
{
	int ret;
	log_file = stdout; //将日志信息打印到控制台

	//初始化身份验证模式以及用户名和密码
	auth_type = NOAUTH;
	arg_username = "user";
	arg_password = "pass";

	//初始化多线程锁
	pthread_mutex_init(&lock, NULL);

	//设置中断信号signal, 当客户端关闭时,客户端会向服务端发送SIGPIPE信号表明连接断开
	signal(SIGPIPE, SIG_IGN);

	//解析程序命令行参数,一共有-n,-u,-p,-l,-a,-h和-d等7个选项, 其中只有-h和-d命令选项不用带参数
	while ((ret = getopt(argc, argv, "n:u:p:l:a:hd")) != -1)
	{
		switch (ret)
		{
			//设置"守护进程"的模式
		case 'd':
		{

			daemon_mode = 1;
			daemonize();
			break;
		}
		//把-n命令选项后面带的参数赋给port,表示用户设置的监听端口
		case 'n':
		{
			port = atoi(optarg) & 0xffff;
			break;
		}
		//管理员利用-u设置用户名
		case 'u':
		{
			arg_username = strdup(optarg);
			break;
		}
		//管理员利用-p设置密码
		case 'p':
		{
			arg_password = strdup(optarg);
			break;
		}
		//用户利用-l将日志文件保存到自定义文件
		case 'l':
		{
			freopen(optarg, "wa", log_file);
			break;
		}
		//设置身份验证类型
		case 'a':
		{
			auth_type = atoi(optarg);
			break;
		}
		case 'h':
		default:
			usage(argv[0]);
		}
	}
	log_message("Starting with authtype %X", auth_type);

	//如果身份验证不是匿名类型的话,则会打印用户名和密码
	if (auth_type != NOAUTH)
	{
		log_message("Username is %s, password is %s", arg_username,
			arg_password);
	}

	//启动代理进程
	app_loop();
	return 0;
}
