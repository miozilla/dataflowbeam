package main

// gcloud auth application-default login
// go get cloud.google.com/go/storage
// go get google.golang.org/api/dataflow/v1b3

import (
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/storage"
	"google.golang.org/api/option"
)

func main() {
	ctx := context.Background()

	// Set project ID
	projectID := "your-project-id"
	bucketName := "your-bucket-name"
	region := "your-region"

	// Create Cloud Storage bucket
	client, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create storage client: %v", err)
	}
	defer client.Close()

	bucket := client.Bucket(bucketName)
	if err := bucket.Create(ctx, projectID, nil); err != nil {
		log.Fatalf("Failed to create bucket: %v", err)
	}
	fmt.Println("Bucket created successfully:", bucketName)

	// Launch Dataflow job
	dataflowService, err := dataflow.NewService(ctx, option.WithoutAuthentication())
	if err != nil {
		log.Fatalf("Failed to create Dataflow service: %v", err)
	}

	job := &dataflow.Job{
		Name: "WordCountJob",
		Environment: &dataflow.Environment{
			StagingLocation: fmt.Sprintf("gs://%s/tmp", bucketName),
		},
		Parameters: map[string]string{
			"inputFile": "gs://dataflow-samples/shakespeare/kinglear.txt",
			"output":    fmt.Sprintf("gs://%s/results/outputs", bucketName),
		},
	}

	_, err = dataflowService.Projects.Locations.Jobs.Create(projectID, region, job).Do()
	if err != nil {
		log.Fatalf("Failed to launch Dataflow job: %v", err)
	}
	fmt.Println("Dataflow job launched successfully!")
}
