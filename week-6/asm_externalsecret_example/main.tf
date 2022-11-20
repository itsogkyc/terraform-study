# 사전에 external-secrets 가 설치되어 있다는 가정하에 진행합니다.
# aws secret manager 에서 키를 가져오는 테스트를 해보겠습니다.
# 시크릿 스토어가 사용할 aws credential secret 생성
echo -n 'KEYID' > ./access-key
echo -n 'SECRETKEY' > ./secret-access-key
kubectl create secret generic awssm-secret --from-file=./access-key  --from-file=./secret-access-key


#cli를 사용해 시크릿을 생성
aws secretsmanager create-secret \
     --name super-secret \
     --secret-string my-custom-secret \
     --region us-west-2


# aws secret manager 를 추상화한 secret store 를 생성합니다
cat <<EOF | kubectl apply -f - 
apiVersion: external-secrets.io/v1alpha1
kind: SecretStore
metadata:
  name: my-secret-store
spec:
  provider:
    aws:  # secret provider를 입력합니다.
      service: SecretsManager # secretsManager를 사용합니다.
      region: us-west-2   # 리전을 입력합니다.
      auth:
        secretRef:
          accessKeyIDSecretRef: 
            name: awssm-secret # 위에서 만든 aws credential 정보를 입력합니다.
            key: access-key  
          secretAccessKeySecretRef:
            name: awssm-secret
            key: secret-access-key
EOF


# external secret을 사용해 가져올 시크릿 값을 입력한다
cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: my-external-secret
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: my-secret-store # 위에서 생성한 스키릿스토어명을 입력합니다.
    kind: SecretStore
  target:
    name: my-kubernetes-secret # 생성할 시크릿명을 입력합니다.
  data:
  - secretKey: password # 저장될 시크릿의 이름을 입력합니다. 
    remoteRef:
      key: super-secret # secret key를 입력
EOF

# secret 값 확인하기
kubectl get secrets my-kubernetes-secret -o json | jq -r .data.password | base64 -d

# externalsecret object 의 status가 secretsynced이면 정상입니다
