var express = require('express');
var app = express();
app.use(express.static('source'));

var core = require('./core');

//app.get('/operation', function(request, response){
//	
//    userRequest = request;
//    userResponse = response;
//        
//	var params = url.parse(request.url, true).query;
//
//	console.log('params', params);
//
//	messagename = params['messagename'];
//        
//    userAc = params['account'];
//    userPd = params['password'];
//        
//    fs.readFile('./users/userinfo.json', readFile);
//})

//app.post('/operation', function(request, response){
//         var postData = '';
//         request.on('data', function(chunk){
//             console.log("chunk", chunk);
//             postData += chunk;
//         });
//         
//         request.on('end', function(){
//                    postData = querystring.parse(postData);
//                    console.log("messagename", postData['messagename']);
//                    console.log("account: ", postData['account']);
//                    console.log("password: ", postData['password']);
//                    
//                    messagename = postData['messagename'];
//                    userAc = postData['account'];
//                    userPd = postData['password'];
//                    
//                    fs.readFile('./users/userinfo.json', readFile);
//        });
//})

app.get('/operation', function(request, response){
        core.dealGet(request, response);
})

app.post('/operation', function(request, response){
         core.dealPost(request, response);
         })

app.post('/upload', function(request, response){
         core.dealUploadFiles(request, response);
})

var server = app.listen(8088, function(){
	var host = server.address().adress
	var port = server.address().port

	console.log("服务器地址: http://%s:%s", host, port)

    core.start();
})


