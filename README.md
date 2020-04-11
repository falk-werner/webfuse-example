[![Build Status](https://travis-ci.org/falk-werner/webfuse-example.svg?branch=master)](https://travis-ci.org/falk-werner/webfuse-example)

# webfuse-example
Example of webfuse.

## Build

    docker build --rm --build-arg "USERID=`id -u`" --tag webfuse .

## Run

    docker run -p 8080:8080 --rm -it \
      --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
      webfuse

Open a webbrowser, visit http://localhost:8080 and follow the instruction on the screen.

Once connected, you can also display the provided filesystem inside the container.

    cat /tmp/test/hello.txt

### Logging

To view log messages from webfuse, open another terminal an conntect to the container.  
Log files can be found in /var/log/socklog/daemon directory.

    docker exec -it <container> bash
    tail -f /var/log/socklog/daemon/current

## Fellow Repositories

*   [webfuse library](https://github.com/falk-werner/webfuse)  
    Create webfuse adapters and providers in C/C++

*   [webfuse daemon](https://github.com/falk-werner/webfused)  
    Reference implementation of webfuse adapter (server)

*   [webfuse-js](https://github.com/falk-werner/webfuse-js)  
    Create webfuse provider (client) in JavaScript

## Further Reading

*   [Webfuse Protocol Specification](https://github.com/falk-werner/webfuse/blob/master/doc/protocol.md)
