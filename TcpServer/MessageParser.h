#ifndef MESSAGEPARSER_H
#define MESSAGEPARSER_H

#include <string>

struct Socket_Message
{
    /*  messageType
        1 登陆
        2 退出
        3 消息
        4 声音
        5 视频
        6 文件传输
        0 无
     
     */
	unsigned int messageType;
    unsigned int messageLength;
	void* messageBody; // 消息内容
};

class MessageParser
{
public:
	MessageParser(int socket_fd);
	~MessageParser();
	
	Socket_Message m_structSM;

private:
	void parse();
	
	int m_nFd;
};

#endif

