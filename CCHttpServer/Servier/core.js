var fs = require('fs');
var url = require('url');
var querystring = require('querystring');
var formidable = require('formidable');

var currentNum;

var debugFlag = 0;

var defaultImage = 'http://localhost:8088/uploadFiles/userimages/cc_logo.png';

exports.start = function()
{
    var data = fs.readFileSync('./users/userinfo.json');
    var json = JSON.parse(data);
    if(json['currentNum'] == undefined)
    {
        currentNum = 100001;
    }
    else
    {
        currentNum = parseInt(json['currentNum']);
    }
}

exports.dealGet = function(request, response)
{
    	var params = url.parse(request.url, true).query;
    
    	console.log('params', params);
    
    	messagename = params['messagename'];
    
        if('searchAccount' == messagename)
        {
            searchAccount(params['searchAccount'], response);
        }
        else if('addFriend' == messagename)
        {
            addFriend(params['account'], params['addAccount'], response);
        }
        else if('getFriends' == messagename)
        {
            getFriends(params['account'], response);
        }
        else
        {
            response.send({'result' : '-1',
                          'message' : '未知接口名称'
                          });
        }
}

function getFriends(account, response)
{
    fs.readFile('./users/userinfo.json', function(err, data){
                
                if(debugFlag)
                {
                console.log('searchAccount readFile');
                }
                if(err)
                {
                response.send({
                              'result':'-1',
                              'message':'获取失败',
                              'reason':'读取用户信息文件错误'
                              });
                return console.error(err);
                }
                
                var json = JSON.parse(data);
                var userInfo = json[account];
                
                var temp = userInfo['friends'];
                
                if(temp == undefined)
                {
                response.send({
                              'result':'-1',
                              'message':'获取失败',
                              'reason':'没有好友'
                              });
                return ;
                }
                else
                {
                
                var friendList = [];
                
                for(var i = 0; i < temp.length; ++ i)
                {
                var friend = temp[i];
                var frientInfo = json[friend];
                var tempFriendInfo = {};
                tempFriendInfo['account'] = frientInfo['account'];
                tempFriendInfo['headimage']= frientInfo['headimage'];
                tempFriendInfo['username'] = frientInfo['username'];
                friendList[i] = tempFriendInfo;
                }
                
                response.send({
                    'result':'1',
                    'friends':friendList
                }
                );
                }
                });
}

function addFriend(account, addAccount, response)
{
    fs.readFile('./users/userinfo.json', function(err, data){
                
                if(debugFlag)
                {
                console.log('searchAccount readFile');
                }
                if(err)
                {
                response.send({
                              'result':'-1',
                              'message':'添加失败',
                              'reason':'读取用户信息文件错误'
                              });
                return console.error(err);
                }
                
                var json = JSON.parse(data);
                var userInfo = json[account];
                var addUserInfo = json[addAccount];
                
                var temp = userInfo['friends'];
                
                if(temp == undefined)
                {
                var friends = [];
                friends[friends.length] = addAccount;
                userInfo['friends'] = friends;
                
                var addFriends = [];
                addFriends[addFriends.length] = account;
                addUserInfo['friends'] = addFriends;
                }
                else
                {
                
                for(var i = 0; i < temp.length; ++ i)
                {
                    if(temp[i] == addAccount)
                    {
                    response.send({
                              'result':'-1',
                              'message':'添加失败',
                              'reason':'对方已是您好友,不能重复添加'
                              });
                    return ;
                    }
                }
                temp[temp.length] = addAccount;
                
                var addTemp = addUserInfo['friends'];
                addTemp[addTemp.length] = account;
                }
                
                
                
                
                fs.writeFile('./users/userinfo.json', JSON.stringify(json), function(err)
                             {
                             if(err)
                             {
                             response.send({
                                           'result':'-1',
                                           'message':'添加失败',
                                           'reason':'写入用户数据失败'
                                           });
                             return console.error(err);
                             }
                             
                             response.send({
                                           'result':'1',
                                           'message':'添加成功',
                                           });
                             });
                
                });
}

function searchAccount(searchAcc, response)
{
    fs.readFile('./users/userinfo.json', function(err, data){
                
                if(debugFlag)
                {
                console.log('searchAccount readFile');
                }
                if(err)
                {
                response.send({
                              'result':'-1',
                              'message':'查询失败',
                              'reason':'读取用户信息文件错误'
                              });
                return console.error(err);
                }
                
                var json = JSON.parse(data);
                var userInfo = json[searchAcc];
                if(userInfo == undefined)
                {
                response.send({
                              'result':'-1',
                              'message':'查询失败',
                              'reason':'账号不存在'
                              });
                return console.error(err);
                }
                else
                {
                response.send({'result' : '1',
                              'message' : '查询成功',
                              'userAccount' : searchAcc,
                              'userName' : userInfo['username'],
                              'userHeadImage' : userInfo['headimage']
                
                });
                }
                });
}

exports.dealPost = function(request, response)
{
    var postData = '';
    request.on('data', function(chunk){
               postData += chunk;
               });
    
    request.on('end', function(){
               postData = querystring.parse(postData);
               
               console.log('messagename ', postData['messagename']);
               
               var messagename = postData['messagename'];
               if('register' == messagename)
               {
               registerNew(postData['username'], postData['password'], response);
               }
               else if('login' == messagename)
               {
               login(postData['account'], postData['password'], response);
               }
               else if('uploadHeadImage' == messagename)
               {
               uploadHeadImage(postData['account'], postData['image']);
               }
               else
               {
               response.send({'result' : '-1',
                             'message' : '未知接口名称'
               });
               }
               
               });
    
               
}

exports.dealUploadFiles = function(request, response)
{
    console.log('dealUploadFiles');
    var form = new formidable.IncomingForm();
    form.parse(request, function(err, fields, files) {
               //               fs.renameSync(files.file.path, "./temp/test.png");
               if(err)
               {
               response.send({
                             'result':'-1',
                             'message':'上传失败',
                             'reason':'数据解析错误'
                             });
               return console.error(err);
               }
               console.error('fields: ', fields);
               console.error('files: ', files);
               
               var messagename = fields['messagename'];
               if('uploadHeadImage' == messagename)
               {
               uploadHeadImage(fields['account'], files, response);
               }
               else
               {
               response.send({'result' : '-1',
                             'message' : '未知消息'});
               }
               
               });
}

function uploadHeadImage(account, files, response)
{
    var filePath = './source/uploadFiles/userimages/' + account.toString() + '_head.png';
    console.log('filePath: '  + filePath);
    
    fs.renameSync(files.image.path, filePath);
    
    fs.readFile('./users/userinfo.json', function(err, data){
                
                if(debugFlag)
                {
                console.log('uploadHeadImage readFile');
                }
                if(err)
                {
                response.send({
                              'result':'-1',
                              'message':'上传失败',
                              'reason':'读取用户信息文件错误'
                              });
                return console.error(err);
                }
                
                var json = JSON.parse(data);
                var userInfo = json[account];
                if(userInfo == undefined)
                {
                response.send({
                              'result':'-1',
                              'message':'上传失败',
                              'reason':'账号不存在'
                              });
                return console.error(err);
                }
                
                var imageurl = 'http://localhost:8088/uploadFiles/userimages/' + files.image.name;
                
                if(userInfo['headimage'] == defaultImage)
                {
                userInfo['headimage'] = imageurl;
                writeUploadImage(json, imageurl, response);
                }
                else
                {
                response.send({
                              'result':'1',
                              'message':'上传成功',
                              'imageurl':imageurl
                              });
                }
                });
}

function writeUploadImage(json, imageurl, response)
{
    fs.writeFile('./users/userinfo.json', JSON.stringify(json), function(err)
                 {
                 if(err)
                 {
                 response.send({
                               'result':'-1',
                               'message':'上传失败',
                               'reason':'写入用户数据失败'
                               });
                 return console.error(err);
                 }
                 
                 response.send({
                               'result':'1',
                               'message':'上传成功',
                               'imageurl':imageurl
                               });
                 });
}

function login(userAccount, password, response)
{
    fs.readFile('./users/userinfo.json', function(err, data){
        
                if(debugFlag)
                {
                console.log('login readFile');
                }
                if(err)
                {
                response.send({
                              'result':'-1',
                              'message':'登陆失败',
                              'reason':'读取用户信息文件错误'
                              });
                return console.error(err);
                }
        
                var json = JSON.parse(data);
                var userInfo = json[userAccount.toString()];
                if(userInfo == undefined)
                {
                response.send({
                              'result':'-1',
                              'message':'登陆失败',
                              'reason':'账号不存在'
                              });
                return console.error(err);
                }
                
                if(userInfo['password'] == password)
                {
                response.send({
                              'result':'1',
                              'message':'登陆成功',
                              'reason':'密码正确',
                              'userinfo' : userInfo
                              });
                }
                else
                {
                response.send({
                              'result':'-1',
                              'message':'登陆失败',
                              'reason':'密码错误'
                              });
                }
                
    });
}

function registerNew(username, password, response)
{
               fs.readFile('./users/userinfo.json', function(err, data){
                           if(debugFlag)
                           {
                           console.log('registerNew readFile');
                           }
                           if(err)
                           {
                           response.send({
                            'result':'-1',
                            'message':'注册失败',
                            'reason':'读取用户信息文件错误'
                           });
                           return console.error(err);
                           }
                           
                           var json = JSON.parse(data);
                           var jsonUser = {
                           'account' : currentNum.toString(),
                           'username' : username,
                           'password' : password,
                           'headimage' : defaultImage
                           };
                           
                           json['currentNum'] = (currentNum + 1).toString();
                           
                           json[currentNum.toString()] = jsonUser;
                           
                           writeNew(json, response);
               });
}

function writeNew(json, response)
{
               fs.writeFile('./users/userinfo.json', JSON.stringify(json), function(err)
                 {
                            if(err)
                            {
                            return console.error(err);
                            }

                            response.send({
                                          'result':'1',
                                          'message':'注册成功',
                                          'userAccount':currentNum.toString()
                            });
                            
                            currentNum += 1;
                            
                            });
}

function responseInfo(result, message, reason)
{
    return {'result':result, 'message':message, 'reason':reason};
}

