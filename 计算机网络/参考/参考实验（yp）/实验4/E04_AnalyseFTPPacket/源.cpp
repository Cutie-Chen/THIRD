#define HAVE_REMOTE

#ifndef _XKEYCHECK_H
#define _XKEYCHECK_H
#endif
#pragma comment(lib, "Packet")
#pragma comment(lib, "wpcap")
#pragma comment(lib, "WS2_32")

#include <pcap.h>
#include <Packet32.h>
#include <ntddndis.h>
#include <remote-ext.h>
#include <iostream>
#include <iomanip> 
#include <fstream>
#include <cstdio>
#include <time.h>
#include <cstdlib>
#include <string>
#include <sstream>
#include <stdio.h>
using namespace std;
#define threshold 1024*1024
time_t tt = time(NULL); tm t;
int num = 0;
u_char ip_addr[4] = { 121,192,180,66 };

typedef struct ip_header {
	u_char ver_ihl;			//Version (4 bits) + Internet header length (4 bits)
	u_char tos;					//Type of service
	u_short tlen;				//Total length
	u_short identification; //Identification
	u_short flags_fo;			//Flags (3 bits) + Fragment offset (13 bits)
	u_char ttl;					//Time to live
	u_char proto;				//Protocol
	u_short crc;				//Header checksum
	u_char saddr[4];			//Source address
	u_char daddr[4];			//Destination address
} ip_header;

typedef struct mac_header {
	u_char dest_addr[6];
	u_char src_addr[6];
	u_char type[2];
} mac_header;

typedef struct tcp_header {
	u_short sport;
	u_short dport;
	u_int th_seq;
	u_int th_ack;
	u_short doff : 4, hlen : 4, fin : 1, syn : 1, rst : 1, psh : 1, ack : 1, urg : 1, ece : 1, cwr : 1;
	u_short th_win;
	u_short th_sum;
	u_short th_urp;
}tcp_header;

enum State {
	client_to_server, server_to_client
};

void packet_handler(u_char* param, const struct pcap_pkthdr* header, const u_char* pkt_data);
bool is_num_or_alp(char);
bool is_num(char);
bool ip_exist(const u_char*);

int main() {
	pcap_if_t* alldevs;
	pcap_if_t* d;
	int inum;
	int i = 0;
	pcap_t* adhandle;
	char errbuf[PCAP_ERRBUF_SIZE];
	u_int netmask;
	struct bpf_program fcode;
	char packet_filter[] = "ip and tcp";

	if (pcap_findalldevs_ex((char*)PCAP_SRC_IF_STRING, NULL, &alldevs, errbuf) == -1) {
		cout << "Error in pcap_findalldevs: " << errbuf << "\n" << endl;
		system("pause");
		exit(1);
	}

	for (d = alldevs; d; d = d->next) {
		printf("%d. %s", ++i, d->name);
		if (d->description)
			printf(" (%s)\n", d->description);
		else
			printf(" (No description available)\n");
	}
	if (i == 0) {
		printf("\nNo interfaces found! Make sure WinPcap is installed.\n");
		return -1;
	}

	printf("Enter the interface number (1-%d):", i);
	cin >> inum;

	if (inum < 1 || inum > i) {
		printf("\nInterface number out of range.\n");
		pcap_freealldevs(alldevs);
		system("pause");
		return -1;
	}

	for (d = alldevs, i = 0; i < inum - 1; d = d->next, i++);

	if ((adhandle = pcap_open(
		d->name,
		65536,
		PCAP_OPENFLAG_PROMISCUOUS,
		//PCAP_OPENFLAG_DATATX_UDP,
		//PCAP_OPENFLAG_NOCAPTURE_RPCAP,
		1000,
		NULL,
		errbuf
	)) == NULL) {
		cout << "Unable to open the adapter. " << d->name << " is not supported by WinPcap.\n" << endl;
		pcap_freealldevs(alldevs);
		system("pause");
		return -1;
	}

	if (pcap_datalink(adhandle) != DLT_EN10MB) {
		cout << "This program works only on Ethernet networks." << endl;
		pcap_freealldevs(alldevs);
		system("pause");
		return -1;

	}

	if (d->addresses != NULL)
		netmask = ((struct sockaddr_in*)(d->addresses->netmask))->sin_addr.S_un.S_addr;
	else
		netmask = 0xffffff;

	if (pcap_compile(adhandle, &fcode, packet_filter, 1, netmask) < 0) {
		cout << "\nUnable to compile the packet filter.Check the syntax." << endl;
		pcap_freealldevs(alldevs);
		system("pause");
		return -1;
	}
	if (pcap_setfilter(adhandle, &fcode) < 0) {
		cout << "\nError setting the filter." << endl;
		pcap_freealldevs(alldevs);
		system("pause");
		return -1;
	}

	printf("\nListening on %s...\n", d->description);
	pcap_freealldevs(alldevs);

	pcap_loop(adhandle, 0, packet_handler, NULL);

	system("pause");
	return 0;
}

void packet_handler(u_char* param, const struct pcap_pkthdr* header, const u_char* pkt_data) {
	mac_header* mh;
	ip_header* ih;
	tcp_header* th;
	ofstream fout;
	State state;

	mh = (mac_header*)pkt_data;
	ih = (ip_header*)(pkt_data + sizeof(mac_header));
	th = (tcp_header*)(pkt_data + sizeof(mac_header) + sizeof(ip_header));
	int length = sizeof(mac_header) + sizeof(ip_header) + sizeof(tcp_header);
	localtime_s(&t, &tt);

	/*用于过滤指定ip*/
	if (!(ip_exist(ih->saddr) || ip_exist(ih->daddr))) return;

	/*输出基本项，时间、长度等*/
	cout << "\n\nNO." << ++num << endl << endl;

	printf("Time:%d-%d-%d %d:%d:%d,", t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
	printf(" len:%u\n", ntohs(ih->tlen) + sizeof(mac_header));

	printf("DEST MAC: ");
	for (int i = 0; i < 6; i++) {
		printf("%02X ", mh->dest_addr[i]);
	}
	printf("\n");
	printf("SRC MAC: ");
	for (int i = 0; i < 6; i++) {
		printf("%02X ", mh->src_addr[i]);
	}
	printf("\n");

	/*判断是否为IP数据报*/
	if (!(pkt_data[12] == 8 && pkt_data[13] == 0)) return;
	cout << "\nget an IP packet" << endl;
	printf("DEST IP: ");
	for (int i = 0; i < 4; i++) {
		printf("%d.", ih->daddr[i]);
	}
	printf("\n");
	printf("SRC IP: ");
	for (int i = 0; i < 4; i++) {
		printf("%d.", ih->saddr[i]);
	}
	printf("\n");

	/*判断是否为TCP*/
	if (ih->proto != 6) return;
	cout << "\n->get an TCP packet" << endl;
	cout << "-->SRC PORT: " << ntohs(th->sport) << endl;
	cout << "-->DEST PORT: " << ntohs(th->dport) << endl;

	cout << "6比特标志位" << endl;
	cout << "URG = " << th->urg << "  "
		  << "ACK = " << th->ack << "  "
		  << "PSH = " << th->psh << "  "
		  << "RST = " << th->rst << "  "
		  << "SYN = " << th->syn << "  "
		  << "FIN = " << th->fin << endl;
	if (th->syn == 1) cout << "握手包" << endl;
	if (th->fin == 1) cout << "挥手包" << endl;

	/*判断是否为TFP*/
	string com = "";
	for (int i = 0;i < 4;i++) {
		if (!is_num_or_alp((char)pkt_data[length + i])) return;
		com += (char)pkt_data[length + i];
	}
	if (is_num((char)pkt_data[length])) state = server_to_client;
	else state = client_to_server;

	ostringstream sout;
	for (int i = length;pkt_data[i] != 13;i++) {
		sout << (char)pkt_data[i];
	}
	string message = sout.str();

	cout << "\nget an FTP packet" << endl;
	switch (state) {
	case client_to_server:
		cout << "client--->ftp server" << endl;
		break;
	case server_to_client:
		cout << "ftp server--->client" << endl;
		cout << "ftp data: ";
		cout << message << endl;
	default:
		return;
	}

	/*对user、pass、quit命令单独输出*/
	if (com == "USER") {
		cout << "CMD: " << com << endl;
		cout << "user name: ";
		for (int i = length + 5;pkt_data[i] != 13;i++) {
			cout << pkt_data[i];
		}
		cout << endl;
		return;
	}
	if (com == "PASS") {
		cout << "CMD: " << com << endl;
		cout << "user password: ";
		for (int i = length + 5;pkt_data[i] != 13;i++) {
			cout << pkt_data[i];
		}
		cout << endl;
		return;
	}
	if (com == "QUIT") {
		cout << "CMD: " << com << endl;
		return;
	}
	cout << message << endl;
}

bool is_num_or_alp(char c) {
	if ('0' <= c && c <= '9') return true;
	if ('a' <= c && c <= 'z') return true;
	if ('A' <= c && c <= 'Z') return true;
	if (c == 32) return true;
	return false;
}

bool is_num(char c) {
	if ('0' <= c && c <= '9') return true;
	return false;
}

bool ip_exist(const u_char* arr) {
	for (int i = 0;i < 4;i++) {
		if (arr[i] != ip_addr[i]) return false;
	}
	return true;
}
