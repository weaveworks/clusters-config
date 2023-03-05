package main

import (
	"encoding/json"
	"github.com/meilisearch/meilisearch-go"
	"io"
	"os"
)

func main() {
	client := meilisearch.NewClient(meilisearch.ClientConfig{
		Host: "http://localhost:7700",
	})

	jsonFile, err := os.Open("movies.json")
	defer jsonFile.Close()
	if err != nil {
		panic(err)
	}

	byteValue, err := io.ReadAll(jsonFile)
	if err != nil {
		panic(err)
	}

	var movies []map[string]interface{}
	json.Unmarshal(byteValue, &movies)

	_, err = client.Index("movies").AddDocuments(movies)
	if err != nil {
		panic(err)
	}
}
