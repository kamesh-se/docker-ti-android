# Creating build 
docker build -t kamesh/node-ti-app .

# Running the Docker 
docker run -v /Users/admin/Kamesh-Project/:/usr/src/app/ -i -t  /bin/bash
