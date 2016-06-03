#ifndef TCPSERVER_H
#define TCPSERVER_H

#include <map>
#include <string>

class TcpServer
{
public:
	TcpServer();
	~TcpServer();

private:
	static void* threadFunc(void*);

	int m_nFd;
	std::map<std::string, int> m_mapUserInfo;
};

#endif



