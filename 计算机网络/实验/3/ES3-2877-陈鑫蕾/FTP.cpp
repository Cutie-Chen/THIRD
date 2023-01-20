#include <pcap.h>
#include <ctime>
#include <map>
#include <string>
#include <functional>
#include <cassert>
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
	u_int seq;
	u_int ack;
	u_short len;
	u_short wind;
	u_short crc;
	u_short ur_point;
};

// 将日志信息写入文件流f
void Log(const char* timestr, const EthernetHeader* mh, const IPHeader* ih, u_short sport, u_short dport, FILE* f = stdout) {
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
}

// 记录完整的一次FTP登录，包括使用的用户名、密码以及结果
class FTPLogin {
private:
	std::string info;
	std::string user, pwd;
	int flag;
public:
	FTPLogin(std::string info) : info(info) {
		flag = -1;
	}
	void SetUser(std::string user) {
		this->user = user;
	}
	void SetPwd(std::string pwd) {
		this->pwd = pwd;
	}
	void SetFlag(bool flag) {
		this->flag = flag;
	}
	// FTP登录信息是否统计完整
	bool IsIntergral() {
		return !user.empty() && !pwd.empty() && flag != -1;
	}
	// 将登录信息输出到文件流f
	void Print(FILE* f = stdout) {
		assert(flag != -1);
		fprintf(f, "%s,%s,%s,%s\n", info.c_str(), user.c_str(), pwd.c_str(), flag == 1 ? "SUCCEED" : "FAILED");
	}
};

// 所有不完整FTP登录请求的存储集合
class FTPSet {
public:
	// 将FTP登录额外信息（时间、源地址、目标地址、源端口、目标端口）转换为字符串，swap参数用于控制是否反转发送/接收方
	static std::string ConvertToString(const char* timestr, const EthernetHeader* mh, const IPHeader* ih, int sport, int dport, bool swap = false) {
		char buffer[128];
		if (!swap) {
			sprintf_s(buffer, "%s,%02X-%02X-%02X-%02X-%02X-%02X,%d.%d.%d.%d:%d,%02X-%02X-%02X-%02X-%02X-%02X,%d.%d.%d.%d:%d",
				timestr,
				mh->smac[0], mh->smac[1], mh->smac[2], mh->smac[3], mh->smac[4], mh->smac[5],
				ih->saddr.byte[0], ih->saddr.byte[1], ih->saddr.byte[2], ih->saddr.byte[3], sport,
				mh->dmac[0], mh->dmac[1], mh->dmac[2], mh->dmac[3], mh->dmac[4], mh->dmac[5],
				ih->daddr.byte[0], ih->daddr.byte[1], ih->daddr.byte[2], ih->daddr.byte[3], dport
			);
		}
		else {
			sprintf_s(buffer, "%s,%02X-%02X-%02X-%02X-%02X-%02X,%d.%d.%d.%d:%d,%02X-%02X-%02X-%02X-%02X-%02X,%d.%d.%d.%d:%d",
				timestr,
				mh->dmac[0], mh->dmac[1], mh->dmac[2], mh->dmac[3], mh->dmac[4], mh->dmac[5],
				ih->daddr.byte[0], ih->daddr.byte[1], ih->daddr.byte[2], ih->daddr.byte[3], dport,
				mh->smac[0], mh->smac[1], mh->smac[2], mh->smac[3], mh->smac[4], mh->smac[5],
				ih->saddr.byte[0], ih->saddr.byte[1], ih->saddr.byte[2], ih->saddr.byte[3], sport
			);
		}
		return std::string(buffer);
	}

	// 将发送方IP与接收方IP转换为字符串，作为区分FTP登录请求的key
	static std::string IPCS(const IPV4& client, const IPV4& server) {
		char buffer[128];
		sprintf_s(buffer, "%d.%d.%d.%d %d.%d.%d.%d",
			client.byte[0], client.byte[1], client.byte[2], client.byte[3],
			server.byte[0], server.byte[1], server.byte[2], server.byte[3]
		);
		return std::string(buffer);
	}

	// 更新指定key对应的FTP登录请求
	// key: 使用IPCS函数生成的key
	// s: FTP包额外信息
	// action: 以key对应的FTPLogin*作为参数的回调函数，用于更新FTPLogin
	// f: FTP登录请求收集完整后结果写入的文件流
	void ModifyFTP(const std::string& key, const std::string& s, std::function<void(FTPLogin*)> action, FILE* f = stdout) {
		if (_map.find(key) == _map.end())
			_map[key] = new FTPLogin(s);
		auto temp = _map[key];
		action(temp);
		if (temp->IsIntergral()) {
			temp->Print(f);
			_map.erase(key);
			delete temp;
		}
	}
private:
	std::map<std::string, FTPLogin*> _map;
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
	if (pcap_compile(adhandle, &fcode, "ip and tcp and port ftp", 1, netmask) < 0) {
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
	FTPSet ftp;

	FILE* f;
	fopen_s(&f, "./FTPresult.csv", "w");

	for (res = pcap_next_ex(adhandle, &header, &pkt_data); res >= 0; res = pcap_next_ex(adhandle, &header, &pkt_data)) {
		if (res == 0)
			continue;

		tm ltime;
		char timestr[64];
		time_t local_tv_sec;

		local_tv_sec = header->ts.tv_sec;
		localtime_s(&ltime, &local_tv_sec);
		strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", &ltime);

		EthernetHeader* mh = (EthernetHeader*)pkt_data;
		IPHeader* ih = (IPHeader*)(pkt_data + 14);
		int ip_len = (ih->ver_ihl & 0xf) * 4;
		TCPHeader* th = (TCPHeader*)((u_char*)ih + ip_len);
		int tcp_len = (th->len >> 4 & 0xf) * 4;
		char* payload = (char*)((u_char*)th + tcp_len);
		int payload_len = header->len - 14 - ip_len - tcp_len;

		u_short sport, dport;
		sport = ntohs(th->sport);
		dport = ntohs(th->dport);

		// 解析USER命令
		if (char cmdArg[64]; sscanf_s(payload, "USER %s", cmdArg, 64) == 1) {
			ftp.ModifyFTP(ftp.IPCS(ih->saddr, ih->daddr), ftp.ConvertToString(timestr, mh, ih, sport, dport), [&cmdArg](FTPLogin* fl) {
				fl->SetUser(cmdArg);
				}, f);
		}
		// 解析PASS命令
		else if (char cmdArg[64]; sscanf_s(payload, "PASS %s", cmdArg, 64) == 1) {
			ftp.ModifyFTP(ftp.IPCS(ih->saddr, ih->daddr), ftp.ConvertToString(timestr, mh, ih, sport, dport), [&cmdArg](FTPLogin* fl) {
				fl->SetPwd(cmdArg);
				}, f);
		}
		// 解析服务器响应，230:成功
		else if (std::string temp(payload); temp.find("230") != std::string::npos) {
			ftp.ModifyFTP(ftp.IPCS(ih->daddr, ih->saddr), ftp.ConvertToString(timestr, mh, ih, sport, dport, true), [](FTPLogin* fl) {
				fl->SetFlag(1);
				}, f);
		}
		// 解析服务器响应，530:失败
		else if (std::string temp(payload); temp.find("530") != std::string::npos) {
			ftp.ModifyFTP(ftp.IPCS(ih->daddr, ih->saddr), ftp.ConvertToString(timestr, mh, ih, sport, dport, true), [](FTPLogin* fl) {
				fl->SetFlag(0);
				}, f);
		}
		fflush(f);
	}

	fclose(f);

	if (res == -1) {
		printf("Error reading the packets: %s\n", pcap_geterr(adhandle));
		return -1;
	}

	return 0;
}