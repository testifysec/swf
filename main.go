package main

import (
	"github.com/common-nighthawk/go-figure"
)

func Hello() string {
	return "Hello KubeCon!"
}

func main() {
	myFigure := figure.NewFigure(Hello(), "usaflag", true)
	myFigure.Print()
}
