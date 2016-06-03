#include "TcpServer.h"
#include "MessageParser.h"

#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <unistd.h>
#include <iostream>
using namespace std;

struct Socket_Info
{
    void* server;
    int socket_fd;
};

pthread_mutex_t plock = PTHREAD_MUTEX_INITIALIZER;

TcpServer::TcpServer()
{
	m_nFd = socket(AF_INET, SOCK_STREAM, 0);
	if(-1 == this->m_nFd)
	{
		cout << "create socket error!" << endl;
		return ;
	}
	
	cout << "create server socket successfully" << endl;
	
	struct sockaddr_in server_addr;
	server_addr.sin_len = sizeof(server_addr);
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(4832);
	server_addr.sin_addr.s_addr = INADDR_ANY;
	bzero(&(server_addr.sin_zero),8);

	int nRet = bind(m_nFd,(struct sockaddr*)&server_addr, sizeof(server_addr));
	if(-1 == nRet)
	{
		cout << "bind error!" << endl;
		return ;
	}

	nRet = listen(m_nFd, 10);
	if(-1 == nRet)
	{
		cout << "listen error!" << endl;
		return ;
	}

	while(1)
	{					
		struct sockaddr_in client_address;
		socklen_t address_len;
		
		cout << "start accept" << endl;
		
		int client_socket = accept(m_nFd,(struct sockaddr*)&client_address, &address_len);
		if(-1 == client_socket)
		{
			cout << "accept error!" << endl;
			return ;
		}

		cout << "new client socket" << client_socket << endl;

		pthread_t td = 0;
		struct Socket_Info* info = new Socket_Info;
		info->server = (void*)this;
		info->socket_fd = client_socket;

		int nTd = pthread_create(&td, 0, threadFunc, (void*)info);
		if(0 != nTd)
		{
			cout << "pthread_create error!" << endl;
			continue;
		}
	}

}

TcpServer::~TcpServer()
{
    close(m_nFd);
}

void* TcpServer::threadFunc(void* context)
{
	Socket_Info* info = (Socket_Info*)context;
    TcpServer* server = (TcpServer*)info->server;
	
	while(1)
	{
		MessageParser parser = MessageParser(info->socket_fd);
		Socket_Message sm = parser.m_structSM;
        
        if(0 == sm.messageType)
        {
            cout << "无效消息" << endl;
            
            map<string,int>::iterator map_iter;
            for(map_iter = server->m_mapUserInfo.begin(); map_iter != server->m_mapUserInfo.end(); ++ map_iter)
            {
                if(map_iter->second == info->socket_fd)
                {
                    pthread_mutex_lock(&plock);
                    
                    server->m_mapUserInfo.erase(map_iter);
                    
                    pthread_mutex_unlock(&plock);
                    
                    delete info;
                    
                    break;
                }
            }
            
            break;
        }
		else if(1 == sm.messageType)
		{
            string userAccount = string((char*)sm.messageBody);
            cout << "userAccount: " << userAccount << endl;
            
            if(server->m_mapUserInfo.find(userAccount) == server->m_mapUserInfo.end())
            {
                pthread_mutex_lock(&plock);
                
                server->m_mapUserInfo[userAccount] = info->socket_fd;
                pthread_mutex_unlock(&plock);
            }
            
            delete[] ((char*)sm.messageBody);
		}
		else if(2 == sm.messageType)
		{
            string userAccount = string((char*)sm.messageBody);
            cout << "userAccount: " << userAccount << endl;
            
            map<string,int>::iterator map_iter;
            map_iter = server->m_mapUserInfo.find(userAccount);
            if(map_iter != server->m_mapUserInfo.end())
            {
                int nSocket = map_iter->second;
                close(nSocket);
             
                pthread_mutex_lock(&plock);
                
                server->m_mapUserInfo.erase(map_iter);
                
                pthread_mutex_unlock(&plock);
            }
            
            
            delete info;
            delete[] ((char*)sm.messageBody);
            
            break;
		}
		else if(3 == sm.messageType)
		{
            string strBody((char*)sm.messageBody);
            cout << "strBody: " << strBody << endl;
            
            int nIndex = strBody.find_first_of(',');
            if(nIndex != string::npos)
            {
                string friendAcc = strBody.substr(0, nIndex);
                cout << "friendAcc: " << friendAcc << endl;
                
                map<string, int>::iterator map_iter;
                map_iter = server->m_mapUserInfo.find(friendAcc);
                if(map_iter != server->m_mapUserInfo.end())
                {
                    int nSocket = map_iter->second;
                    
                    cout << "friendSocket: " << nSocket << endl;
                    
                    unsigned char headBuffer[8] = {};
                    memset(headBuffer, 0, sizeof(headBuffer));
                    
                    *((unsigned int*)headBuffer) = sm.messageType;
                    *((unsigned int*)(headBuffer + sizeof(unsigned int))) = sm.messageLength;
                    
                    int nRet = write(nSocket, headBuffer, sizeof(headBuffer));
                    if(nRet < 0)
                    {
                        cout << "write head error!" << endl;
                    }
                    
                    unsigned int nWrittenLen = 0;
                    char* bodyBuffer = (char*)sm.messageBody;
                    
                    while(nWrittenLen < (sm.messageLength - 8))
                    {
                        nRet = write(nSocket, bodyBuffer + nWrittenLen, (sm.messageLength-8 - nWrittenLen));
                        if(nRet < 0)
                            break;
                        
                        nWrittenLen += (unsigned int)nRet;
                    }
                }
                else
                {
                    cout << "can't find friend socket" << endl;
                }
            }
            
			delete[] ((char*)sm.messageBody);
		}
		else if(4 == sm.messageType)
		{
            unsigned int strLen = *((unsigned int*)sm.messageBody);
            
            string strAcc = string((char*)sm.messageBody + sizeof(unsigned int),(char*)sm.messageBody + sizeof(unsigned int) + strLen);
            
            int nIndex = strAcc.find_first_of(',');
            if(nIndex != string::npos)
            {
                string friendAcc = strAcc.substr(0, nIndex);
                cout << "friendAcc: " << friendAcc << endl;
                
                map<string, int>::iterator map_iter;
                map_iter = server->m_mapUserInfo.find(friendAcc);
                if(map_iter != server->m_mapUserInfo.end())
                {
                    int nSocket = map_iter->second;
                    
                    cout << "friendSocket: " << nSocket << endl;
                    
                    unsigned char headBuffer[8] = {};
                    memset(headBuffer, 0, sizeof(headBuffer));
                    
                    *((unsigned int*)headBuffer) = sm.messageType;
                    *((unsigned int*)(headBuffer + sizeof(unsigned int))) = sm.messageLength;
                    
                    int nRet = write(nSocket, headBuffer, sizeof(headBuffer));
                    if(nRet < 0)
                    {
                        cout << "write head error!" << endl;
                    }
                    
                    unsigned int nWrittenLen = 0;
                    unsigned char* bodyBuffer = (unsigned char*)sm.messageBody;
                    
                    while(nWrittenLen < (sm.messageLength - 8))
                    {
                        nRet = write(nSocket, bodyBuffer + nWrittenLen, (sm.messageLength-8 - nWrittenLen));
                        if(nRet < 0)
                            break;
                        
                        nWrittenLen += (unsigned int)nRet;
                    }
                }
                
                else
                {
                    cout << "can't find friend socket" << endl;
                }
            }
            
            delete[] ((unsigned char*)sm.messageBody);
		}
    }
	
	return 0;
}



