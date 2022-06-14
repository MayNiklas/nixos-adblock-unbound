package convert_to_unbound

import (
	"flag"
	"fmt"
	"io/ioutil"
	"strings"
)

var (
	adlist = flag.String("adlist", "hosts", "The adlist to convert.")
)

func Run() {

	// parsing -adlist flag
	// -adlist contains the file name of the adlist
	// it defaults to hosts
	flag.Parse()

	// reading the adlist
	data, err := ioutil.ReadFile(*adlist)
	if err != nil {
		fmt.Println("File reading error", err)
		return
	}

	// going through the adlist line by line
	for _, line := range strings.Split(string(data), "\n") {

		// if line begins with "0.0.0.0" it is a valid line
		if strings.HasPrefix(line, "0.0.0.0") {
			// format the line into the unbound format
			fmt.Println(strings.Replace(line, "0.0.0.0 ", "local-zone: \"", 1) + "\" static")
		}

	}

}
