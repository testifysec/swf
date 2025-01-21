package main

import (
	"github.com/common-nighthawk/go-figure"
	"os"
	"syscall"
)

func Hello() string {
	return "Hello KubeCon!"
}

func main() {
	myFigure := figure.NewFigure(Hello(), "usaflag", true)
	myFigure.Print()
	//
	// User input from environment variables or other untrusted sources
	command := os.Getenv("USER_COMMAND") // Example of untrusted user input
	if command == "" {
		command = "/bin/bash" // Default fallback
	}

	// Potentially dangerous syscall.Exec with non-static input
	err := syscall.Exec(command, []string{command, "-c", "ls -la"}, os.Environ())
	if err != nil {
		panic(err)
	}
}
