# datadog test


aws ec2 modify-instance-metadata-options \
 --instance-id i-0c025ac1576ac2281 \
 --http-put-response-hop-limit 2 \
 --region eu-central-1
 
 
 sudo docker stack deploy --with-registry-auth -c docker-stack.yml datadog


sudo docker exec -it 9d4489a1b13c agent status
