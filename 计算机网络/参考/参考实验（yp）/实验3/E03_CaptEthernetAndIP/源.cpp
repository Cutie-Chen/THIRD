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
using namespace std;
#define threshold 1024*1024

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
	u_int op_pad;				//Option + Padding
} ip_header;

typedef struct mac_header {
	u_char dest_addr[6];
	u_char src_addr[6];
	u_char type[2];
} mac_header;

void packet_handler(u_char* param, const struct pcap_pkthdr* header, const u_char* pkt_data);

int main() {
	pcap_if_t* alldevs;
	pcap_if_t* d;
	int inum;
	int i = 0;
	pcap_t* adhandle;
	char errbuf[PCAP_ERRBUF_SIZE];
	u_int netmask;
	struct bpf_program fcode;
	//char packet_filter[] = "";
	char packet_filter[] = "ip and icmp or arp";

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
	ofstream fout;

	ih = (ip_header*)(pkt_data + sizeof(mac_header));
	mh = (mac_header*)pkt_data;
	int length = sizeof(mac_header) + sizeof(ip_header);

	time_t tt = time(NULL);
	tm t;
	localtime_s(&t, &tt);

	/*printf("Time:%d-%d-%d %d:%d:%d,", t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
	printf(" len:%u\n", ntohs(ih->tlen) + sizeof(mac_header));

	for (int i = 0; i < length; i++) {
		printf("%02X ", pkt_data[i]);
		if ((i & 0xF) == 0xF)
			printf("\n");
	}

	printf("\n");

	printf("mac_header:\n");
	printf("\tdest_addr: ");
	for (int i = 0; i < 6; i++) {
		printf("%02X ", mh->dest_addr[i]);
	}
	printf("\n");
	printf("\tsrc_addr: ");
	for (int i = 0; i < 6; i++) {
		printf("%02X ", mh->src_addr[i]);
	}
	printf("\n");
	
	printf("\ttype: %04X", ntohs((u_short)mh->type));
	printf("\ttype: %04u", (u_short)mh->type);
	printf("\ttype: %04d", (u_short)pkt_data[12] * 100 + (u_short)pkt_data[13]);
	
	printf("\n");


	printf("ip_header\n");
	printf("\t%-10s: %02X\n", "ver_ihl", ih->ver_ihl);
	printf("\t%-10s: %02X\n", "tos", ih->tos);
	printf("\t%-10s: %04X\n", "tlen", ntohs(ih->tlen));
	printf("\t%-10s: %04X\n", "identification", ntohs(ih->identification));
	printf("\t%-10s: %04X\n", "flags_fo", ih->flags_fo);
	printf("\t%-10s: %02X\n", "ttl", ih->ttl);
	printf("\t%-10s: %02X\n", "proto", ih->proto);
	printf("\t%-10s: %04X\n", "crc", ih->crc);
	printf("\t%-10s: %08X\n", "op_pad", ih->op_pad);
	printf("\t%-10s: ", "saddr");
	for (int i = 0; i < 4; i++) {
		printf("%02X ", ih->saddr[i]);
	}
	printf(" ");
	for (int i = 0; i < 4; i++) {
		printf("%d.", ih->saddr[i]);
	}
	printf("\n");
	printf("\t%-10s: ", "daddr");
	for (int i = 0; i < 4; i++) {
		printf("%02X ", ih->daddr[i]);
	}
	printf(" ");
	for (int i = 0; i < 4; i++) {
		printf("%d.", ih->daddr[i]);
	}
	printf("\n\n\n");*/

	string result;
	int frame_type = (u_short)pkt_data[12] * 100 + (u_short)pkt_data[13];
	switch (frame_type)
	{
	case 800:
		if (ih->proto != 1)
			return;
		result = "ICMP";
		break;
	case 806:
		result = "arp";
		break;
	default:
		return;
	}

	printf("Time:%d-%d-%d %d:%d:%d,", t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
	printf(" len:%u\n", ntohs(ih->tlen) + sizeof(mac_header));

	if (result == "ICMP") cout << "get an ip packet" << endl;
	cout << "get an " << result << " packet";

	printf("mac_header:\n");
	printf("DEST MAC: ");
	for (int i = 0; i < 6; i++) {
		printf("%02X ", mh->dest_addr[i]);
	}
	printf("\n");
	printf("SRC MAC: ");
	for (int i = 0; i < 6; i++) {
		printf("%02X ", mh->src_addr[i]);
	}
	printf("\n\n\n");
	
	if (ntohs(ih->tlen) < threshold) {
		FILE* file = NULL;
		fopen_s(&file, "output.csv", "a");
		fprintf_s(file, "%d-%d-%d %d:%d:%d,", t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
		for (int i = 0; i < 5; i++) {
			fprintf_s(file, "%02X-", mh->src_addr[i]);
		}
		fprintf_s(file, "%02X,", mh->src_addr[5]);
		for (int i = 0; i < 3; i++) {
			fprintf_s(file, "%d.", ih->saddr[i]);
		}
		fprintf_s(file, "%d,", ih->saddr[3]);
		for (int i = 0; i < 5; i++) {
			fprintf_s(file, "%02X-", mh->dest_addr[i]);
		}
		fprintf_s(file, "%02X,", mh->dest_addr[5]);
		for (int i = 0; i < 3; i++) {
			fprintf_s(file, "%d.", ih->daddr[i]);
		}
		fprintf_s(file, "%d,", ih->daddr[3]);
		fprintf_s(file, "%d\n", ntohs(ih->tlen));
		fclose(file);
	}

}