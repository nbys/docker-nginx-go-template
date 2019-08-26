package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello world!")
	})

	log.Fatal(http.ListenAndServeTLS(":443", "../.certs/server/server.crt", "../.certs/server/server.key.unencrypted.pem", nil))
}
