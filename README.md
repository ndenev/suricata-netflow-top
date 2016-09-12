# Suricata-Netflow-Top
Simple web UI showing top flows seen by Suricata.

![](/suricata-netflow-top.png)

**DISCLAIMER: I made this some time ago to play with JavaScript for the first time, so this
might explain why it is so ugly**


## Requirements
This won't go into deep detail on how to setup and is assuming you have working installations of:

* Nginx with Lua plugin (or better OpenResty)
* Suricata with EVE and Redis support.
* Redis instance.


## Installation

Pick a directory where to install the files. For the purposes of this guide we'll use */usr/local/suricata-netflow-top*. In this directory you should have the netflow.lua script
and the netflow directory containing html+java-script.

### Configure your nginx/openresty to point to the http directory and the lua script:

```
location /netflow {
    root '/usr/local/suricata-netflow-top';
}

location /netflow.json {
    default_type 'text/event-stream';
    lua_check_client_abort on;
    content_by_lua_file "/usr/local/suricata-netflow-top/netflow.lua";
}
```

**NOTE: If your redis instance is not on the same host as your nginx you will need
to edit the netflow.lua script to set the  proper redis host for your environment**

### Configure your Suricata instance to log netflow data in Redis:

Basically you need to add the following to your *suricata.yaml*, substituting
$your_redis_host$ for.... you've quessed it: your Redis host!

```
- eve-log:
    enabled: yes
    filetype: redis
    redis:
      server: $your_redis_host$
      port: 6379
      mode: channel
      key: suricata
```
