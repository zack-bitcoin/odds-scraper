(async function(){


    //first off, looking up the IP address and port for the server. This part could potentially be a hard IP and port, if you plan to always use the api served from the same place.
    const server_ip = document.URL.split("/")[2].split(":")[0];
    var URL_REGEX = /^(https?)?(?:[\:\/]*)([a-z0-9\.-]*)(?:\:([0-9]+))?(\/[^?#]*)?(?:\?([^#]*))?(?:#(.*))?$/i;
    var match = document.URL.match(URL_REGEX);
    var server_port = match[3];
    async function apost(x) {
        return rpc.apost(x, server_ip, server_port);
    };


    
    var page = document.getElementById("page");

    //page.innerHTML = "<h1>Success.<h1>";
    const response = await apost(["test", 1]);
    console.log(JSON.stringify(response.slice(1).map(function(x){return(atob(x))})));

    var response2 = response.slice(1);
    //console.log(JSON.stringify(response2));
    var r2 = response2.map(function(x){
        return(atob(x))});
    //console.log(JSON.stringify(r2));
    //console.log(atob(response[1]));
    //console.log(atob(response[2]));
    //console.log(atob(response[3]));
    
})();
