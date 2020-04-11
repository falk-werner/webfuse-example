[![Build Status](https://travis-ci.org/falk-werner/webfuse-example.svg?branch=master)](https://travis-ci.org/falk-werner/webfuse-example)

# webfuse-example
Example of webfuse.

## Build

    docker build --rm --build-arg "USERID=`id -u`" --tag webfuse .

## Run

    docker run -p 8080:8080 --rm -it \
      --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
      --user `id -u` \
      webfuse bash
    webfused -f /etc/webfused.conf

Open a webbrowser and visit http://localhost:8080 and follow the instruction on the screen.

Then open another terminal and connect to the container.

    docker exec -it <name of container> bash
    cat /tmp/test/hello.txt

## Fellow Repositories

*   [webfuse library](https://github.com/falk-werner/webfuse)  
    Create webfuse adapters and providers in C/C++

*   [webfuse daemon](https://github.com/falk-werner/webfused)  
    Reference implementation of webfuse adapter (server)

*   [webfuse-js](https://github.com/falk-werner/webfuse-js)  
    Create webfuse provider (client) in JavaScript

## Further Reading

*   [Webfuse Protocol Specification](https://github.com/falk-werner/webfuse/blob/master/doc/protocol.md)
