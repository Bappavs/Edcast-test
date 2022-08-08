Step 1- Build a application in Go
    make run_local
    make build
    ./build/go-calc ## For Linux
Step 2- Apply Docker containers to a Go application
    # Dockerfile 

    # Start from the latest golang base image
    FROM golang:latest as builder

    # Add Maintainer Info
    LABEL maintainer="Vishal"

    # Set the Current Working Directory inside the container
    WORKDIR /go-calc


    # Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
    RUN go mod download

    # Copy the source from the current directory to the Working Directory inside the container
    COPY . .


    ######## Start a new stage from scratch #######
    FROM alpine:latest  

    RUN apk --no-cache add ca-certificates

    WORKDIR /root/

    # Copy the Pre-built binary file from the previous stage
    COPY --from=builder /go-calc .

    # Expose port 8080 to the outside world
    EXPOSE 8080

    # Command to run the executable
    CMD ["./go-calc "] 

Step 3- Integrate the Docker image to Docker hub
    # Build the docker image
    $ docker build -t go-kubernetes .

    # Tag the image
    $ docker tag go-kubernetes bappa0209/go-calc

    # Login to docker with your docker Id
    $ docker login
    Login with your Docker ID to push and pull images from Docker Hub. If you do not have a Docker ID, head over to https://hub.docker.com to create one.
    Username (bappa0209): bappa0209
    Password:
    Login Succeeded

    # Push the image to docker hub
    $ docker push bappa0209/go-calc

Step 4- Creating a Kubernetes deployment--k8s-deployment.yml

	---
	apiVersion: apps/v1
	kind: Deployment                 # Type of Kubernetes resource
	metadata:
	name: go-calc          # Name of the Kubernetes resource
	spec:
	replicas: 1                    # Number of pods to run at any given time
	selector:
		matchLabels:
		app: go-calc        # This deployment applies to any Pods matching the specified label
	template:                      # This deployment will create a set of pods using the configurations in this template
		metadata:
		labels:                    # The labels that will be applied to all of the pods in this deployment
			app: go-calc 
		spec:                        # Spec for the container which will run in the Pod
		containers:
		- name: go-calc
			image: bappa0209/go-calc 
			imagePullPolicy: IfNotPresent
			ports:
			- containerPort: 8080  # Should match the port number that the Go application listens on
			livenessProbe:           # To check the health of the Pod
			httpGet:
				path: /health
				port: 8080
				scheme: HTTP
			initialDelaySeconds: 5
			periodSeconds: 15
			timeoutSeconds: 5
			readinessProbe:          # To check if the Pod is ready to serve traffic or not
			httpGet:
				path: /readiness
				port: 8080
				scheme: HTTP
			initialDelaySeconds: 5
			timeoutSeconds: 1   

Step 5- Create Kubernetes cluster using Minikube for deploying the app

	minikube start
	kubectl apply -f k8s-deployment.yml
  	deployment.apps/go-hello-world created
	kubectl get deployments
	NAME             READY   UP-TO-DATE   AVAILABLE   AGE
  	go-calc   3/3     3            3           25s
	kubectl get pods
	kubectl get pods
	NAME                              READY   STATUS    RESTARTS   AGE
	go-calc -69b45499fb-7fh87   1/1     Running   0          37s
	go-calc -69b45499fb-rt2xj   1/1     Running   0          37s
	go-calc -69b45499fb-xjmlq   1/1     Running   0          37s
	kubectl port-forward go-calc-69b45499fb-7fh87 8080:8080
	Forwarding from 127.0.0.1:8080 -> 8080 
	Forwarding from [::1]:8080 -> 8080 
	curl localhost:8080