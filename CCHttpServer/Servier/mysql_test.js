var sys = require('sys');
var Client = require('mysql');



var client = Client.createConnection({user: 'root',password: '24832@zhao'});

client.user = 'root';
client.password = '24832@zhao';
client.connect(function(error, results){
    if(error)
    {
        console.log('connection error: ' + error.message);
        return ;
    }
    
    console.log('connected to mysql');
    ClientConnectionReady(client);
});

ClientConnectionReady = function(client)
{
    client.query('use sql_test', function(error, results){
        if(error)
        {
            console.log('ClientConnectionReady error: ' + error.message);
            client.end();
            return ;
        }
        
        ClientReady(client);
    });

};

ClientReady = function(client)
{
    client.query('select * from Students', function(error, results, fields){
        if(error)
        {
            console.log('ClientReady error: ' + error.message);
            client.end();
            return ;
        }
        
        console.log('ClientReady results: ' + results);
        console.log('ClientReady fields: ' + fields);
        
        if(results.length > 0)
        {
            var firstResult = results[0];
            console.log('SNO: ' + firstResult['SNO']);
            console.log('SNAME: ' + firstResult['SNAME']);
            console.log('AGE: ' + firstResult['AGE']);
            console.log('SEX: ' + firstResult['SEX']);
            console.log('BPLACE: ' + firstResult['BPLACE']);
        }
    });
}





