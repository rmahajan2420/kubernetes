#!/bin/bash
INSTANCE_ID=$(curl -S http://169.254.169.254/latest/meta-data/instance-id)
/usr/local/bin/aws ec2 create-tags --region 'us-east-1' --resources $INSTANCE_ID --tags "Key=Name,Value=fame-kubernetes-aws-minion Spot" "Key=Role,Value=fame-kubernetes-aws-minion" "Key=KubernetesCluster,Value=fame-kubernetes-aws"
/bin/mkdir -p /root/.docker
cat > /root/.docker/config.json << EOF_JSON
{
  "auths": {
    "https://hub.docker.com": {
      "auth": "dHRuZGZhbWU6ZmFtZWRlZmF1bHQ="
    },
    "https://index.docker.io/v1/": {
      "auth": "dHRuZGZhbWU6ZmFtZWRlZmF1bHQ="
    }
  }
}
EOF_JSON
mkfs -t ext4 /dev/xvdba
mkdir -p /var/log/app
mount /dev/xvdba /var/log/app
curl -L http://toolbelt.treasuredata.com/sh/install-ubuntu-precise-td-agent2.sh | sh
wget -O /etc/td-agent/td-agent.conf https://s3.amazonaws.com/fameplus-uat-2/kubernetes/kibana/td-agent.conf
service td-agent restart
mkdir -p /var/cache/kubernetes-install
cd /var/cache/kubernetes-install
cat > kube_env.yaml << __EOF_KUBE_ENV_YAML
ENV_TIMESTAMP: '2016-08-05T06:34:14+0000'
INSTANCE_PREFIX: 'fame-kubernetes-aws'
NODE_INSTANCE_PREFIX: 'fame-kubernetes-aws-minion'
NODE_TAGS: ''
CLUSTER_IP_RANGE: '10.244.0.0/16'
SERVER_BINARY_TAR_URL: 'https://s3.amazonaws.com/kubernetes-staging-e6d10ab1af467cc8275c04f77d832cf0/devel/kubernetes-server-linux-amd64.tar.gz'
SERVER_BINARY_TAR_HASH: '7b89205ccf43a53636b772747549394fa16a44dd'
SALT_TAR_URL: 'https://s3.amazonaws.com/kubernetes-staging-e6d10ab1af467cc8275c04f77d832cf0/devel/kubernetes-salt.tar.gz'
SALT_TAR_HASH: '4b03e83264eef7c00f80a0f93fade46d378cc35a'
SERVICE_CLUSTER_IP_RANGE: '10.0.0.0/16'
KUBERNETES_MASTER_NAME: 'fame-kubernetes-aws-master'
ALLOCATE_NODE_CIDRS: 'true'
ENABLE_CLUSTER_MONITORING: 'influxdb'
DOCKER_REGISTRY_MIRROR_URL: ''
ENABLE_L7_LOADBALANCING: 'none'
ENABLE_CLUSTER_LOGGING: 'true'
ENABLE_CLUSTER_UI: 'true'
ENABLE_NODE_PROBLEM_DETECTOR: 'false'
ENABLE_NODE_LOGGING: 'true'
LOGGING_DESTINATION: 'elasticsearch'
ELASTICSEARCH_LOGGING_REPLICAS: '1'
ENABLE_CLUSTER_DNS: 'true'
ENABLE_CLUSTER_REGISTRY: 'false'
CLUSTER_REGISTRY_DISK: ''
CLUSTER_REGISTRY_DISK_SIZE: ''
DNS_REPLICAS: '1'
DNS_SERVER_IP: '10.0.0.10'
DNS_DOMAIN: 'cluster.local'
KUBELET_TOKEN: '769zTv4Swvgyr4B5dUPC1zEjtVhkS6Wu'
KUBE_PROXY_TOKEN: 'nipU29STE7iteTLSSMY6KGCX8x8m4ale'
ADMISSION_CONTROL: 'NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,ResourceQuota'
MASTER_IP_RANGE: '10.246.0.0/24'
RUNTIME_CONFIG: ''
CA_CERT: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURYRENDQWtTZ0F3SUJBZ0lKQU5RTC9qODVSUjJETUEwR0NTcUdTSWIzRFFFQkN3VUFNQ014SVRBZkJnTlYKQkFNVUdEVXlMakl3Tnk0Mk9TNHhNamxBTVRRM01ETTNPRGd4TnpBZUZ3MHhOakE0TURVd05qTXpNemRhRncweQpOakE0TURNd05qTXpNemRhTUNNeElUQWZCZ05WQkFNVUdEVXlMakl3Tnk0Mk9TNHhNamxBTVRRM01ETTNPRGd4Ck56Q0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU5IS3ZTL0txSExuUkxES0VyNTgKc3k4NUN3TEpYR1BVOXd6K2cxRWpzc1gvZnpyOFFRTVZSdHBLZlhya0FVTU9KaXIxaVVQVldGTit6dkVJZHdVbgpVUjc0VE5adzlkMGxVY3lqZjBUbGZrMS8rMmFGQVJVUGNXK3JDMW5OWjYveFpTeG1zZ1o4OGpBZ1JOVzU5N0JPClp0dGQ2YURITGYvOUJhd0pBOE1PVzlWNTI4dUFHV1pQbCtwaURNb2ZyTTA1ZnBMbUE3RnJhT014eXFjWWVpazYKL012OUhhZGIvcU1LNGdFeXJ0aG5TTEwweDMwdzFtZ3UraGpYWWkwQVRjbWEzbTh0MzhtNG9URnJFU0hBM2U2QwpUcytNYk5wTlpnQmFWaVJzUTlMTUdtWi9MT3pPMi9FVFBzNmRJUHlKT1pLUWc4SU9DYzA4aFY0RDhSdWxvY0x6ClM4a0NBd0VBQWFPQmtqQ0JqekFkQmdOVkhRNEVGZ1FVQXBQd3dYUmxMY1pBUncwc3JEci9zSXZ5eVhjd1V3WUQKVlIwakJFd3dTb0FVQXBQd3dYUmxMY1pBUncwc3JEci9zSXZ5eVhlaEo2UWxNQ014SVRBZkJnTlZCQU1VR0RVeQpMakl3Tnk0Mk9TNHhNamxBTVRRM01ETTNPRGd4TjRJSkFOUUwvajg1UlIyRE1Bd0dBMVVkRXdRRk1BTUJBZjh3CkN3WURWUjBQQkFRREFnRUdNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUFLM0NBbnAyNUlyd005em44VDREbHYKQjhQczNpVklIL0hjVnllaVhRVmZJKzNkYSt0NUxLM3JZWGFjaHFoTUt2TmN0UXVEK01GZ3pZOVF2RlhLcSt5dAozbHdHbkdHZ2k3L1QvVjJhRWpmQnZZQTF5YWpjZU1ta0NNRWMxSC9rV3ZDMVVhaXlSZ2pVMWI1Rkh0cVNlaFc2CjNGODd5SDl5UkdDaCtub1d4bERPTjRxRElaZ2c0RC9FSnJwQlplQUNpQ2xFUHdxOFZmTG5wYnVMelM0RC83MUgKSU44OXNNK1BMdjdXU1lNQkh5MlFYb1k3L0tBUHJkYlF4c3NRSkszVmNKUFV6NFVnRnROWU82M1I0cFk0akk1VQpaR2tDaHMrdmQzZE9uS0pzaVhJV2RmU1phenBqdHVmQVJ1Zk1Rcmt3aXVSdFZBZEgxT2ZIOFBZYmNBWmlZRWhtCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K'
KUBELET_CERT: 'Q2VydGlmaWNhdGU6CiAgICBEYXRhOgogICAgICAgIFZlcnNpb246IDMgKDB4MikKICAgICAgICBTZXJpYWwgTnVtYmVyOiAyICgweDIpCiAgICBTaWduYXR1cmUgQWxnb3JpdGhtOiBzaGEyNTZXaXRoUlNBRW5jcnlwdGlvbgogICAgICAgIElzc3VlcjogQ049NTIuMjA3LjY5LjEyOUAxNDcwMzc4ODE3CiAgICAgICAgVmFsaWRpdHkKICAgICAgICAgICAgTm90IEJlZm9yZTogQXVnICA1IDA2OjMzOjM3IDIwMTYgR01UCiAgICAgICAgICAgIE5vdCBBZnRlciA6IEF1ZyAgMyAwNjozMzozNyAyMDI2IEdNVAogICAgICAgIFN1YmplY3Q6IENOPWt1YmVsZXQKICAgICAgICBTdWJqZWN0IFB1YmxpYyBLZXkgSW5mbzoKICAgICAgICAgICAgUHVibGljIEtleSBBbGdvcml0aG06IHJzYUVuY3J5cHRpb24KICAgICAgICAgICAgICAgIFB1YmxpYy1LZXk6ICgyMDQ4IGJpdCkKICAgICAgICAgICAgICAgIE1vZHVsdXM6CiAgICAgICAgICAgICAgICAgICAgMDA6Yjc6N2E6YWY6NTI6YTY6NTk6ODA6ZjA6Mjc6ZTI6ZTc6YzY6YmQ6NWQ6CiAgICAgICAgICAgICAgICAgICAgZTg6NTI6ODE6YzU6Mzk6ZjA6MDM6NWQ6ZTU6ZmM6NzU6ZTM6MjY6MjM6N2I6CiAgICAgICAgICAgICAgICAgICAgM2M6ODU6OGM6ZTY6ZGY6NjY6Zjk6MGI6MTg6ZWY6YjI6NTI6YjY6ZjE6ZGM6CiAgICAgICAgICAgICAgICAgICAgYTQ6YTE6ZDI6NWI6NGY6ZmU6OGQ6OTU6MzY6OTE6NmY6Yjg6YWU6MmU6YTI6CiAgICAgICAgICAgICAgICAgICAgOWI6M2Q6MGI6NzI6OWQ6ZjI6M2U6NzM6YmU6NDQ6YjE6YmM6NjI6Zjg6YmY6CiAgICAgICAgICAgICAgICAgICAgMjM6M2I6ZDM6YWQ6YTU6ZTY6ZGQ6MTM6ODU6YmY6OWY6OTI6ZTU6MTg6ZWE6CiAgICAgICAgICAgICAgICAgICAgN2Y6ZWM6NTQ6OGQ6Y2Y6Nzc6ODI6ZGM6NTE6ZjA6NDI6Yzc6N2Y6MGM6NjQ6CiAgICAgICAgICAgICAgICAgICAgNWI6Yzc6OGQ6YmY6MGY6MjE6ZGM6OTk6Yzc6YTY6YjQ6NTU6YWY6ZDQ6ZDU6CiAgICAgICAgICAgICAgICAgICAgMDQ6YmU6ZTY6ZWM6YTI6ZTQ6MWU6ZGY6Yjc6ZGQ6YzY6YmU6OWQ6ZjY6ZGQ6CiAgICAgICAgICAgICAgICAgICAgYjM6NzE6OTA6YmI6ZDU6MjY6MDI6ZDE6NGY6ZGE6Mjg6Yjk6ZmM6Njc6MDY6CiAgICAgICAgICAgICAgICAgICAgZjk6MzA6ZGY6NmI6Njc6MzI6YzM6MDA6ZjU6MGE6NTc6ZGM6ZmE6NTc6NDU6CiAgICAgICAgICAgICAgICAgICAgZjU6ZmM6NDA6OTc6M2I6Yzk6MmY6YTQ6MDM6N2U6Mzk6NTI6NjE6YTU6YTI6CiAgICAgICAgICAgICAgICAgICAgNzk6Y2Y6Mjc6NjU6ZTI6ZmI6N2E6MjY6Y2E6OGM6MTk6ZmQ6ODI6NjY6NDQ6CiAgICAgICAgICAgICAgICAgICAgODk6ZTY6NDk6OTg6OWU6Mjk6OTI6YmI6Njc6M2I6Zjc6NTY6YTc6ZGY6MjE6CiAgICAgICAgICAgICAgICAgICAgOTg6ZmQ6YzE6ZDY6ODA6MGM6ZTM6Zjk6ZjU6OWI6Mjk6NWY6NjY6Njc6OTA6CiAgICAgICAgICAgICAgICAgICAgMmI6MjQ6MGU6ZTQ6YzY6OTc6ODE6ZDU6NGU6Yzk6NzU6YjU6NmQ6N2Y6Y2M6CiAgICAgICAgICAgICAgICAgICAgNDI6NzA6Y2I6ZDg6MDU6N2Q6NGY6MDI6OGQ6Yjc6YWI6NWY6MzA6MzA6MzI6CiAgICAgICAgICAgICAgICAgICAgODM6ZmYKICAgICAgICAgICAgICAgIEV4cG9uZW50OiA2NTUzNyAoMHgxMDAwMSkKICAgICAgICBYNTA5djMgZXh0ZW5zaW9uczoKICAgICAgICAgICAgWDUwOXYzIEJhc2ljIENvbnN0cmFpbnRzOiAKICAgICAgICAgICAgICAgIENBOkZBTFNFCiAgICAgICAgICAgIFg1MDl2MyBTdWJqZWN0IEtleSBJZGVudGlmaWVyOiAKICAgICAgICAgICAgICAgIEVGOjlCOkJBOjZBOjg4OkE0Ojk5OkFCOjFFOjMyOkM4OkRGOkJDOkU5OjMzOjVBOjMwOjA0OkI1OkM4CiAgICAgICAgICAgIFg1MDl2MyBBdXRob3JpdHkgS2V5IElkZW50aWZpZXI6IAogICAgICAgICAgICAgICAga2V5aWQ6MDI6OTM6RjA6QzE6NzQ6NjU6MkQ6QzY6NDA6NDc6MEQ6MkM6QUM6M0E6RkY6QjA6OEI6RjI6Qzk6NzcKICAgICAgICAgICAgICAgIERpck5hbWU6L0NOPTUyLjIwNy42OS4xMjlAMTQ3MDM3ODgxNwogICAgICAgICAgICAgICAgc2VyaWFsOkQ0OjBCOkZFOjNGOjM5OjQ1OjFEOjgzCgogICAgICAgICAgICBYNTA5djMgRXh0ZW5kZWQgS2V5IFVzYWdlOiAKICAgICAgICAgICAgICAgIFRMUyBXZWIgQ2xpZW50IEF1dGhlbnRpY2F0aW9uCiAgICAgICAgICAgIFg1MDl2MyBLZXkgVXNhZ2U6IAogICAgICAgICAgICAgICAgRGlnaXRhbCBTaWduYXR1cmUKICAgIFNpZ25hdHVyZSBBbGdvcml0aG06IHNoYTI1NldpdGhSU0FFbmNyeXB0aW9uCiAgICAgICAgIDQ0OjE1OmI5OjU3OjBhOjc5OmI2OjJkOjY2OjYzOmVhOmU5OjU4OmE3OjM2OjJjOmM3OjIxOgogICAgICAgICAwMDo2ODo0NzpkZTpiNTozYzpiZDoyZTo2YjphMzo4YjpmMDo4MjpiMTpkYToxMDphOTo2NDoKICAgICAgICAgOGI6YTQ6NDY6ODY6YmE6NmM6Yzc6MmQ6ZDM6ZGE6ZTI6ZDE6MzY6Y2Q6Y2E6ZTc6ZDA6YTE6CiAgICAgICAgIGMwOjhmOjVjOmZjOmI2OjA5OjZlOmM3OjQ0OmRlOjAwOmY5OjVmOjk0OmVmOjZiOmI4OmIxOgogICAgICAgICA4ODpiNDpkZToyMzpmNTo2OTpjYjphNTpmYzo3MDo1NDo2ODpjMjozMTpjYjowODo5YTphOToKICAgICAgICAgN2Q6ZWY6ODM6NGM6OTg6ZWE6ZWY6NWY6YTM6OWU6ZmU6NzM6NGI6YmQ6MGU6YmI6YWI6ZDg6CiAgICAgICAgIDdhOjFkOjRlOjE5OmMwOjg2OjVmOjcwOjUzOjIyOjM0OjE1OjYxOmNhOmM3OmNjOjQ5OjBkOgogICAgICAgICA5NjpkNzpmMjphOTpmYjozYzo2Njo4MzoxZToxMzoyNDoxZjpiMzo3MTpjYTo2YzpjZDo0YzoKICAgICAgICAgMTE6ZWM6Y2Q6NTg6NTk6YzA6ZDQ6MzY6OTE6NTI6OWI6ODA6ODI6NDk6NzE6Mzg6NGY6MzQ6CiAgICAgICAgIGNiOmVmOjQ5OjAzOjY0OjQ4OjUyOjJhOmJiOmMwOjMyOjZmOjBlOjBkOmIzOjBjOjA5OmE2OgogICAgICAgICBkZTowMzpjMzpiYToyYTo0Njo4NTphNzo4YzpkYTphNjowNTo2ODo1ZTpkZTo1YjplNTplOToKICAgICAgICAgMWY6M2Q6MjI6YzY6NTY6ODc6MzQ6NzA6ZGM6M2M6MzY6Yjk6ZmY6MDc6ZWE6Y2E6OGM6YTY6CiAgICAgICAgIDllOjA5OjY1Ojc5OjNmOjkwOjgyOjBiOmIyOjVlOmU4OjU3OjRjOjc5OjY4OjViOjNmOjU1OgogICAgICAgICBlZDoyODpjYTo1YzphYTo5MzplYTo5Mjo2ZDpjMjplMjo0NTphMjoxYjoxZTo1NzowMjpjNToKICAgICAgICAgMDA6OTk6Yzk6ZjcKLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURWVENDQWoyZ0F3SUJBZ0lCQWpBTkJna3Foa2lHOXcwQkFRc0ZBREFqTVNFd0h3WURWUVFERkJnMU1pNHkKTURjdU5qa3VNVEk1UURFME56QXpOemc0TVRjd0hoY05NVFl3T0RBMU1EWXpNek0zV2hjTk1qWXdPREF6TURZegpNek0zV2pBU01SQXdEZ1lEVlFRREV3ZHJkV0psYkdWME1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBCk1JSUJDZ0tDQVFFQXQzcXZVcVpaZ1BBbjR1Zkd2VjNvVW9IRk9mQURYZVg4ZGVNbUkzczhoWXptMzJiNUN4anYKc2xLMjhkeWtvZEpiVC82TmxUYVJiN2l1THFLYlBRdHluZkkrYzc1RXNieGkrTDhqTzlPdHBlYmRFNFcvbjVMbApHT3AvN0ZTTnozZUMzRkh3UXNkL0RHUmJ4NDIvRHlIY21jZW10Rld2MU5VRXZ1YnNvdVFlMzdmZHhyNmQ5dDJ6CmNaQzcxU1lDMFUvYUtMbjhad2I1TU45clp6TERBUFVLVjl6NlYwWDEvRUNYTzhrdnBBTitPVkpocGFKNXp5ZGwKNHZ0NkpzcU1HZjJDWmtTSjVrbVluaW1TdTJjNzkxYW4zeUdZL2NIV2dBemorZldiS1Y5bVo1QXJKQTdreHBlQgoxVTdKZGJWdGY4eENjTXZZQlgxUEFvMjNxMTh3TURLRC93SURBUUFCbzRHa01JR2hNQWtHQTFVZEV3UUNNQUF3CkhRWURWUjBPQkJZRUZPK2J1bXFJcEptckhqTEkzN3pwTTFvd0JMWElNRk1HQTFVZEl3Uk1NRXFBRkFLVDhNRjAKWlMzR1FFY05MS3c2LzdDTDhzbDNvU2VrSlRBak1TRXdId1lEVlFRREZCZzFNaTR5TURjdU5qa3VNVEk1UURFMApOekF6TnpnNE1UZUNDUURVQy80L09VVWRnekFUQmdOVkhTVUVEREFLQmdnckJnRUZCUWNEQWpBTEJnTlZIUThFCkJBTUNCNEF3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUVRVnVWY0tlYll0Wm1QcTZWaW5OaXpISVFCb1I5NjEKUEwwdWE2T0w4SUt4MmhDcFpJdWtSb2E2Yk1jdDA5cmkwVGJOeXVmUW9jQ1BYUHkyQ1c3SFJONEErVitVNzJ1NApzWWkwM2lQMWFjdWwvSEJVYU1JeHl3aWFxWDN2ZzB5WTZ1OWZvNTcrYzB1OURydXIySG9kVGhuQWhsOXdVeUkwCkZXSEt4OHhKRFpiWDhxbjdQR2FESGhNa0g3Tnh5bXpOVEJIc3pWaFp3TlEya1ZLYmdJSkpjVGhQTk12dlNRTmsKU0ZJcXU4QXlidzROc3d3SnB0NER3N29xUm9XbmpOcW1CV2hlM2x2bDZSODlJc1pXaHpSdzNEdzJ1ZjhINnNxTQpwcDRKWlhrL2tJSUxzbDdvVjB4NWFGcy9WZTBveWx5cWsrcVNiY0xpUmFJYkhsY0N4UUNaeWZjPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=='
KUBELET_KEY: 'LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRQzNlcTlTcGxtQThDZmkKNThhOVhlaFNnY1U1OEFOZDVmeDE0eVlqZXp5RmpPYmZadmtMR08reVVyYngzS1NoMGx0UC9vMlZOcEZ2dUs0dQpvcHM5QzNLZDhqNXp2a1N4dkdMNHZ5TTcwNjJsNXQwVGhiK2ZrdVVZNm4vc1ZJM1BkNExjVWZCQ3gzOE1aRnZICmpiOFBJZHlaeDZhMFZhL1UxUVMrNXV5aTVCN2Z0OTNHdnAzMjNiTnhrTHZWSmdMUlQ5b291ZnhuQnZrdzMydG4KTXNNQTlRcFgzUHBYUmZYOFFKYzd5UytrQTM0NVVtR2xvbm5QSjJYaSszb215b3daL1lKbVJJbm1TWmllS1pLNwpaenYzVnFmZklaajl3ZGFBRE9QNTlac3BYMlpua0Nza0R1VEdsNEhWVHNsMXRXMS96RUp3eTlnRmZVOENqYmVyClh6QXdNb1AvQWdNQkFBRUNnZ0VBT08rZ1VrUit4ODArZzJJclFQNVFKckpRY3A4eFhFVVBKOEg2UnM1cVJJTXAKN2E5MW51VDVGTndvR3p1OTl0MWhLcHl5Y05oREgya3UzQmZubG5UajkzR0J3Y2NNYUI4dWswUTArYzdCTnhkQwpDVm5hMGZqeWtOM01IcGxLZkZQNHpzZTZoKzZDVldVYk9meVppbWVXbmozZlZGeTJ1SlAxNmd1YzZSdGpIVWJaCkNkRitwZ0NlMVZBRElZT20rd29kMHdvVndZdDNDdnI5YTlwb1plWm1jRWJXenc0Ti9temxhS0gwaWpZVEVUenYKYWdOM2ZsMlRYZis5d1RqdnhTZVpkK0R1Mk5lWlB5QlJsa2gwaG1iWGFHQXhHbElSQ3phMGRvQzVMTUNXTnBFTwoxL0xJNjhQektPaHZuM1ZrcTR0dDRKR3dKRVF3bWI3b3VOajNQT2o3RVFLQmdRRHhSUmJtOGl0RHBnL2dxTW9yCmEwNk5ZK3FuRFNkeFpGZFZ3b04zUUJ5aTc5cWZ4RlhyMWt2cVAzckpzMGZwc0ErcHY4alVUMzBYa3lxek9VcDIKOG40N2o3bXBWaU43ZEUvSjZ2OEFwcFVTZFpib01vVDhvK1YwTzIzNGdtdTV4YXdqN2s3RE4ydW5MZ20rUkpqRgpiZ2kwNVkrVmZ5QmZDbkxDemdwZmtvM2NHUUtCZ1FEQ3JseFI5TnVxQThrbnlnWmRCZGhOaGFoV3M5K3pCU29DCm1ZdnU4RnJGd2JISEVnT2dNOWR5MzRuUGxxVmlYcFp1cGtobXBrSkZOQmg3Rmd6QW9Cd1d2d3hsd2llc2Q2L28KZWtlK3FNcVM1RmQ2SGtQcnV6TzlLM2FPd2Q0bVJHd1Y1bU4xN2RKQklodUNjMnk5TklzQXRlYTNWMUZpSkdWTApjbm9DMUpsajF3S0JnSER1ZWUzWDVOQmhab1V0L0pPZVFzS0R4azR6SmdjNWhIZXIrSVZWQ1JKcld0WDF2SklMCldMVm95VHlvSWowTUlBakFzR3hRV0trMFJZUm1pS2hza1JHb0VLdG1tbTBxNEQ0UE5SVkU0L29qK0dMdllyZ3UKcnpSY3JQanBjeXNkajVteDdrUUtLT1d6OHZPUWdFSEpZMkhwSWZCRDlROEhnUGdXSVZ6aTZHdmhBb0dCQU1EQgpsT1VNMU1ZRVU1SVM1TFFNQ252UFA3c0JCQmVqb0ZITXFCR2ZaN0R3TkU2UGxvbHphdm54UE9rT0ZwaE1ZUlFUCmpoSWN3ZmIxT3R2OEhBcEpQU2FFYVFrRDhQWkIxeWtPa2FURVNUYWg0YjhtNGtjd0ptMUI4SFF1bmY4enRmVUYKRlN0NW1ya2t4U29ua04zUmZXUHB0eE9HNEN5VkxycENFVzVtQTY0bkFvR0JBTlVseWtBMDFvQ1M4L3JBSzRGTwp1aVZVKzlEbE1pRk9wVi9jM1U0TFl4eHlOY29ZbWN6WG9zbWUrb1FiNEV3d2VGck5QclBNQWtPelpZWWU1eWZQCkI3b1pCNXJUT3BlM3VHMEJjUXREY29LaTc2Y3VMaGZXTm1CWWd6K0tWbGZYMVpYT1lxMXdpZTVEWS9LbUlydzMKMzlvaE5DeHlMaXBjcDZXTW9kZm51MkZoCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K'
NETWORK_PROVIDER: 'none'
PREPULL_E2E_IMAGES: ''
HAIRPIN_MODE: ''
OPENCONTRAIL_TAG: 'R2.20'
OPENCONTRAIL_KUBERNETES_TAG: 'master'
OPENCONTRAIL_PUBLIC_SUBNET: '10.1.0.0/16'
E2E_STORAGE_TEST_ENVIRONMENT: 'false'
KUBE_IMAGE_TAG: ''
KUBE_DOCKER_REGISTRY: ''
KUBE_ADDON_REGISTRY: ''
MULTIZONE: ''
NON_MASQUERADE_CIDR: '10.0.0.0/8'
KUBE_UID: '2697411300'
KUBERNETES_MASTER: 'false'
ZONE: 'us-east-1c'
EXTRA_DOCKER_OPTS: ''
AUTO_UPGRADE: 'true'
DOCKER_STORAGE: 'aufs'
API_SERVERS: '172.31.32.9'
__EOF_KUBE_ENV_YAML

wget -O bootstrap https://s3.amazonaws.com/kubernetes-staging-e6d10ab1af467cc8275c04f77d832cf0/devel/bootstrap-script
chmod +x bootstrap
mkdir -p /etc/kubernetes
mv kube_env.yaml /etc/kubernetes
mv bootstrap /etc/kubernetes/
cat > /etc/rc.local << EOF_RC_LOCAL
#!/bin/sh -e
/etc/kubernetes/bootstrap
/bin/cp /root/.docker/config.json /var/lib/kubelet/
mount /dev/xvdba /var/log/app
exit 0
EOF_RC_LOCAL
/etc/kubernetes/bootstrap
