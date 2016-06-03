#include "MessageParser.h"
#include <iostream>
using namespace std;


MessageParser::MessageParser(int socket_fd)
{
	this->m_nFd = socket_fd;
	this->m_structSM.messageType = 0;
	parse();
}

MessageParser::~MessageParser()
{
	
}

void MessageParser::parse()
{
	cout << "start parse" << endl;
	unsigned char tempBuffer[8] = {};
	memset(tempBuffer, 0, sizeof(tempBuffer));

    int nReadByte = read(this->m_nFd, tempBuffer, sizeof(tempBuffer));
	if(nReadByte < 0)
	{
		cout << "read error!" << endl;
		return ;
	}

    this->m_structSM.messageType = *((unsigned int*)tempBuffer);
    this->m_structSM.messageLength = *((unsigned int*)(tempBuffer + (sizeof(unsigned int))));
    
    unsigned int nTotalLength = this->m_structSM.messageLength - 8;
    
    cout << "recive head data, messageType: " << this->m_structSM.messageType << "messageLength: " << this->m_structSM.messageLength << endl;
    
    if(1 == m_structSM.messageType ||
       2 == m_structSM.messageType ||
       3 == m_structSM.messageType) // 登陆, 退出, 文字消息
    {
        char* bodyBuffer = new char[nTotalLength + 1];
        memset(bodyBuffer, 0, nTotalLength + 1);
        
        unsigned int nTotalReadLen = 0;
        while(nTotalReadLen < nTotalLength)
        {
            nReadByte = read(this->m_nFd, bodyBuffer + nTotalReadLen, nTotalLength - nTotalReadLen);
            
            if(-1 == nReadByte)
                break;
            
            nTotalReadLen += (unsigned int)nReadByte;
        }
        
        m_structSM.messageBody = bodyBuffer;
        
        cout << "recive body data" << endl;
    }
    else if(4 == m_structSM.messageType) // 声音消息
    {
        unsigned char* bodyBuffer = new unsigned char[nTotalLength];
        memset(bodyBuffer, 0, nTotalLength);
        
        unsigned int nTotalReadLen = 0;
        while(nTotalReadLen < nTotalLength)
        {
            nReadByte = read(this->m_nFd, bodyBuffer + nTotalReadLen, nTotalLength - nTotalReadLen);
            
            if(-1 == nReadByte)
                break;
            
            nTotalReadLen += (unsigned int)nReadByte;
        }
        
        m_structSM.messageBody = bodyBuffer;
        
        cout << "recive body data" << endl;
    }
    else if(5 == m_structSM.messageType)
    {
        
    }
    else if(6 == m_structSM.messageType)
    {
        
    }
}


