# Creating build 
docker build -t hybrid/node-ti-app .

# Running the Docker 
docker run -v /Users/admin/hybrid/:/usr/src/app/ -i -t  hybrid/node-ti-app /bin/bash
