package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
)

// Hilfsfunktion: Environment-Variable oder Defaultwert
func getenvOrDefault(key, def string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return def
}

// Ermittelt die (nicht-loopback) IP-Adresse des Hosts
func getLocalIP() string {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return "unknown"
	}
	for _, addr := range addrs {
		if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ip4 := ipnet.IP.To4(); ip4 != nil {
				return ip4.String()
			}
		}
	}
	return "unknown"
}

func main() {
	appVersion := getenvOrDefault("APP_VERSION", "0.0.0")
	appEnv := getenvOrDefault("APP_ENVIRONMENT", "None")

	hostname, err := os.Hostname()
	if err != nil || hostname == "" {
		hostname = "unknown"
	}

	ip := getLocalIP()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)

		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_, _ = fmt.Fprintf(w, `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Status</title>
</head>
<body>
<p>Hostname: %s</p>
<p>IP Address: %s</p>
<p>APP_VERSION: %s</p>
<p>APP_ENVIRONMENT: %s</p>
</body>
</html>`, hostname, ip, appVersion, appEnv)
	})

	addr := ":8080"
	log.Printf("Server listening on %s (hostname=%s, ip=%s, version=%s, env=%s)", addr, hostname, ip, appVersion, appEnv)
	log.Fatal(http.ListenAndServe(addr, nil))
}

