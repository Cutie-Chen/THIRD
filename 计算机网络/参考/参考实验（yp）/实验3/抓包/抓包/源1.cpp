#include <pcap.h>
#include <ctime>
#include <map>
#include <string>
#pragma comment(lib,"ws2_32.lib")

struct IPV4 {
	u_char byte[4];

	void print(FILE* f = stdout) const {
		fprintf(f, "%d.%d.%d.%d", byte[0], byte[1], byte[2], byte[3]);
	}
};

struct EthernetHeader {
	u_char dmac[6];
	u_char smac[6];
	u_short type;

	static void printMac(const u_char mac[6], FILE* f = stdout) {
		fprintf(f, "%02X-%02X-%02X-%02X-%02X-%02X", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	}
};

struct IPHeader {
	u_char ver_ihl;
	u_char tos;
	u_short tlen;
	u_short identification;
	u_short flags_fo;
	u_char ttll;
	u_char proto;
	u_short crc;
	IPV4 saddr;
	IPV4 daddr;
	//u_int op_pad;
};

struct TCPHeader {
	u_short sport;
	u_short dport;
	union {
		u_short _seq[2];
		u_int sequence;
	};
	union {
		u_short _conf[2];
		u_int confirm;
	};
	u_short len;
	u_short wind;
	u_short crc;
	u_short ur_point;
};

void Log(const char* timestr, const EthernetHeader* mh, const IPHeader* ih, u_short sport, u_short dport, u_int len, FILE* f = stdout) {
	fprintf(f, "%s", timestr);
	// source mac
	fprintf(f, ",");
	EthernetHeader::printMac(mh->smac, f);

	// source ip
	fprintf(f, ",");
	ih->saddr.print(f);
	fprintf(f, ":%d", sport);

	// dest mac
	fprintf(f, ",");
	EthernetHeader::printMac(mh->dmac, f);

	// dest ip
	fprintf(f, ",");
	ih->daddr.print(f);
	fprintf(f, ":%d", dport);

	// length
	fprintf(f, ",%d\n", len);
}

class Counter {
private:
	std::map<std::string, u_int> _send, _recv;

	// 将MAC地址与IP地址转换为字符串
	// e.g. AA:BB:CC:DD:EE:FF 192.168.  1.  1
	std::string _convertToString(const u_char mac[6], const u_char ip[4]) {
		char buffer[64];
		sprintf_s(buffer, "%02X-%02X-%02X-%02X-%02X-%02X %3d.%3d.%3d.%3d",
			mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
			ip[0], ip[1], ip[2], ip[3]);
		return std::string(buffer);
	}

	int _interval;
public:
	Counter(int interval) : _interval(interval) {
	}
	// 添加发送包统计
	// mac: 发送方mac地址
	// ip: 发送方ip地址
	// bytes: 包字节数
	void AddSend(const u_char mac[6], const u_char ip[4], u_int bytes) {
		std::string s = _convertToString(mac, ip);
		if (!_send.count(s))
			_send[s] = 0;
		_send[s] += bytes;
	}
	// 添加接收方统计
	// 参数同发送包统计
	void AddRecv(const u_char mac[6], const u_char ip[4], u_int bytes) {
		std::string s = _convertToString(mac, ip);
		if (!_recv.count(s))
			_recv[s] = 0;
		_recv[s] += bytes;
	}
	// 清空计数器
	void Clear() {
		_send.clear();
		_recv.clear();
	}
	// 打印统计信息
	// f: 目标文件流，默认为保准输出流
	void Print(FILE* f = stdout) {
		fprintf(f, "\nStatistics in last %d seconds:\n\nBytes sended:\n", _interval);
		for (auto& s : _send) {
			fprintf(f, "%s: %10u\n", s.first.c_str(), s.second);
		}
		fprintf(f, "\n\nBytes recieved:\n");
		for (auto& s : _recv) {
			fprintf(f, "%s: %10u\n", s.first.c_str(), s.second);
		}
	}
};

int main() {
	pcap_if_t* all_devs;
	pcap_if_t* d;

	int i = 0;
	char errbuf[PCAP_ERRBUF_SIZE];

	// get adapters
	if (pcap_findalldevs_ex(PCAP_SRC_IF_STRING, NULL, &all_devs, errbuf) == -1) {
		fprintf(stderr, "Error in pcap_findalldevs_ex: %s\n", errbuf);
		return 1;
	}

	for (d = all_devs; d != NULL; d = d->next) {
		printf("%d. %s", ++i, d->name);
		if (d->description)
			printf(" (%s)\n", d->description);
		else
			printf(" (No description available)\n");
	}

	if (i == 0) {
		printf("\nNo interfaces found! Make sure Npcap is installed.\n");
		return 0;
	}

	// select adapter
	printf("Enter the interface number (1-%d): ", i);
	int inum = -1;
	for (scanf_s("%d", &inum); inum < 1 || inum > i; scanf_s("%d", &inum))
		printf("\nInterface number out of range.\nPlease input again.\n");

	for (d = all_devs, i = 0; i < inum - 1; d = d->next, ++i);

	pcap_t* adhandle;

	if ((adhandle = pcap_open(d->name, 65536, PCAP_OPENFLAG_PROMISCUOUS, 1000, NULL, errbuf)) == NULL) {
		fprintf(stderr, "\nUnable to open the adapter. %s is not supported by Npcap\n", d->name);
		pcap_freealldevs(all_devs);
		return 1;
	}

	if (pcap_datalink(adhandle) != DLT_EN10MB) {
		fprintf(stderr, "\nThis program works only on Ethernet networks.\n");
		pcap_freealldevs(all_devs);
		return -1;
	}

	int netmask;
	if (d->addresses != NULL) {
		netmask = ((sockaddr_in*)(d->addresses->netmask))->sin_addr.S_un.S_addr;
	}
	else {
		netmask = 0xffffff;
	}

	// filtering
	bpf_program fcode;
	if (pcap_compile(adhandle, &fcode, "ip and tcp", 1, netmask) < 0) {
		fprintf(stderr, "\nUnable to compile the packet filter. Check the syntax.\n");
		pcap_freealldevs(all_devs);
		return 1;
	}

	if (pcap_setfilter(adhandle, &fcode) < 0) {
		fprintf(stderr, "\nError setting the filter.\n");
		pcap_freealldevs(all_devs);
		return 1;
	}

	// listening
	printf("\nListening on %s...\n", d->description);

	pcap_freealldevs(all_devs);

	pcap_pkthdr* header;
	const u_char* pkt_data;
	int res;
	time_t startTime = 0;
	const int interval = 5;
	Counter c(interval);

	FILE* log;
	fopen_s(&log, "./log.csv", "w");

	for (res = pcap_next_ex(adhandle, &header, &pkt_data); res >= 0; res = pcap_next_ex(adhandle, &header, &pkt_data)) {
		if (res == 0)
			continue;

		tm ltime;
		char timestr[64];
		time_t local_tv_sec;

		// 解析包头时间
		local_tv_sec = header->ts.tv_sec;
		localtime_s(&ltime, &local_tv_sec);
		strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", &ltime);

		if (startTime == 0)
			startTime = local_tv_sec;

		// 解析头部
		EthernetHeader* mh = (EthernetHeader*)pkt_data;
		IPHeader* ih = (IPHeader*)(pkt_data + 14);
		int ip_len = (ih->ver_ihl & 0xf) * 4;
		TCPHeader* th = (TCPHeader*)((u_char*)ih + ip_len);

		// 解析端口
		u_short sport, dport;
		sport = ntohs(th->sport);
		dport = ntohs(th->dport);

		// 写入csv
		Log(timestr, mh, ih, sport, dport, header->len, log);
		// 更新counter
		c.AddSend(mh->smac, ih->saddr.byte, header->len);
		c.AddRecv(mh->dmac, ih->daddr.byte, header->len);

		// 超时后打印统计信息
		if (local_tv_sec - startTime > interval) {
			c.Print();
			c.Clear();
			startTime = 0;
		}
	}

	fclose(log);

	if (res == -1) {
		printf("Error reading the packets: %s\n", pcap_geterr(adhandle));
		return -1;
	}

	return 0;
}