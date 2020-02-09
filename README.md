# webfuse-example
Example of webfuse.

## Build

    docker build --rm --buildarg "USERID=`id -u`" -tag webfuse .

# Run

    docker run -p 8080:8080 --rm -it --user "`id -u`" webfuse bash
    webfused -m /tmp -d /var/www -p 8080

Open a webbrowser and visit http://localhost:8080.