package convert_to_unbound

import (
	"flag"
	"log"
)

var (
	adlist = flag.String("adlist", "hosts", "The adlist to convert.")
)

func Run() {

	flag.Parse()

	log.Println("converting: " + *adlist)

}
