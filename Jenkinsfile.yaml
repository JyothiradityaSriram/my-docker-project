pipeline:
  agent:
    any: true

  environment:
    IMAGE_NAME: "sriramhukum/mytestapp"
    TAG: "latest"

  stages:
    - stage: Checkout
      steps:
        - sh: |
            git clone https://github.com/JyothiradityaSriram/my-docker-project repo
            cd repo
            ls -la

    - stage: Build Docker Image
      steps:
        - sh: |
            cd repo
            docker build -t $IMAGE_NAME:$TAG .

    - stage: Login to DockerHub
      steps:
        - sh: |
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
      environment:
        DOCKER_USER: "${DOCKER_USER}"
        DOCKER_PASS: "${DOCKER_PASS}"
      credentials:
        - dockerhub-creds

    - stage: Push Image
      steps:
        - sh: |
            docker push $IMAGE_NAME:$TAG

  post:
    always:
      - sh: |
          echo "Pipeline Completed"
