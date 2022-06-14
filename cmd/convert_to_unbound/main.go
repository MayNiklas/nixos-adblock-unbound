package convert_to_unbound

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
)

var (
	adlist = flag.String("adlist", "hosts", "The adlist to convert.")
)

func Run() {

	flag.Parse()
	log.Println("converting: " + *adlist)

	data, err := ioutil.ReadFile(*adlist)
	if err != nil {
		fmt.Println("File reading error", err)
		return
	}
	fmt.Println("Contents of file:", string(data))

}
