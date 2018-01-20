#!/bin/bash

export UCP_IPADDR=$(cat /vagrant/env/ucp-node1-ipaddr)
export DTR_IPADDR=$(cat /vagrant/env/dtr-node1-ipaddr)
export UCP_PASSWORD=$(cat /vagrant/env/ucp_password)
export DTR_REPLICA_ID=$(cat /vagrant/env/dtr-replica-id)
export DTR_FQDN=dtr.local
export DTR_VERSION=2.5.0-beta3

docker run --rm -it docker/dtr:${DTR_VERSION} destroy \
  --replica-id ${DTR_REPLICA_ID} --ucp-url ${UCP_IPADDR} --ucp-username docker \
  --ucp-password dockeradmin --ucp-insecure-tls

cp /vagrant/dtr_backup.tar .

docker run --rm docker/dtr:${DTR_VERSION} restore --ucp-url ${UCP-IPADDR} --ucp-username docker \
  --ucp-password dockeradmin --dtr-external-url ${DTR_FQDN} --ucp-node dtr-node1 \
  --ucp-insecure-tls  < dtr_backup.tar
