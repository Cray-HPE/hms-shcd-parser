This project contains the logic to parse an SHCD Excel spreadsheet and gather information necessary for HMS purposes (like discovery) and output them in machine friendly format. The intention is for this image to be used directly without any specific knowledge required to make it as easy as possible for the end user.

To generate the output JSON run the following from in the directory where your SHCD Excel spreadsheet is:

```text
$ docker run --rm -it --name hms-shcd-parser -v $(pwd)/sls_test_shcd-gamora.xlsx:/input/shcd_file.xlsx -v $(pwd):/output dtr.dev.cray.com/cray/hms-shcd-parser:latest
2020-06-12T20:17:22.078Z	INFO	shcd-parser/main.go:147	Wrote HMN connections to file.	{"outputFile": "/output/hmn_connections.json"}
2020-06-12T20:17:22.078Z	INFO	shcd-parser/main.go:150	Configuration generated.
```

In the directory you run that from you will now have a `hmn_connections.json` file.