/*
 * MIT License
 *
 * (C) Copyright [2020-2021] Hewlett Packard Enterprise Development LP
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package main

import (
	"encoding/json"
	"fmt"
	"github.com/namsral/flag"
	"github.com/tealeg/xlsx/v3"
	"go.uber.org/zap"
	"io/ioutil"
	"os"
	shcd_parser "stash.us.cray.com/HMS/hms-shcd-parser/pkg/shcd-parser"
)

const STARTING_ROW = 20

var (
	shcdExcelFile = flag.String("shcd_file", "",
		"Location for the SHCD/CCD Excel spreadsheet to process for HMN connections")
	outputFile = flag.String("output_file", "",
		"Output file to dump HMN connections JSON into.")

	logger *zap.Logger

	Rows []shcd_parser.HMNRow
)

func parseSHCDFile() {
	excelFile, err := xlsx.OpenFile(*shcdExcelFile)
	if err != nil {
		logger.Fatal("Failed to open SHCD file!", zap.Error(err))
	}

	hmnSheet, sheetExists := excelFile.Sheet["HMN"]
	if !sheetExists {
		logger.Fatal("HMN sheet does not exist in SHCD file!", zap.String("shcdExcelFile", *shcdExcelFile))
	}

	/*
		The HMN sheet looks like the following:

		      J (9)   K (10) L (11)    M (12)         N (13)  (O/P/Q) R (17) S (18)    (T) U (20)
		 16   Source  Rack   Location  (SubLocation)  Parent          Rack   Location      Port
		 17   mn01    x3000  u01                                      x3000  u22           j25
		 ...

		And has as many rows as there are connections.

		The logic here is to start from row 20, column 10 and work our way through the spreadsheet building a
		better data structure. But first, verify we're in the neighborhood by checking the header.
	*/
	sourceHeaderCell, err := hmnSheet.Cell(STARTING_ROW-1, 9)
	if err != nil {
		logger.Fatal("Failed to parse Source header cell!", zap.Error(err))
	}
	if sourceHeaderCell.Value != "Source" {
		logger.Fatal("Tried to match known header value to value at J20 but it did not match!")
	}

	rowIndex := STARTING_ROW
	for true {
		sourceCell, err := hmnSheet.Cell(rowIndex, 9)
		if err != nil {
			logger.Fatal("Failed to parse Source cell!", zap.Error(err))
		}
		sourceRackCell, err := hmnSheet.Cell(rowIndex, 10)
		if err != nil {
			logger.Fatal("Failed to parse Rack cell!", zap.Error(err))
		}
		sourceLocation, err := hmnSheet.Cell(rowIndex, 11)
		if err != nil {
			logger.Fatal("Failed to parse source Location cell!", zap.Error(err))
		}
		sourceSubLocation, err := hmnSheet.Cell(rowIndex, 12)
		if err != nil {
			logger.Fatal("Failed to parse source SubLocation cell!", zap.Error(err))
		}
		sourceParent, err := hmnSheet.Cell(rowIndex, 13)
		if err != nil {
			logger.Fatal("Failed to parse source Parent cell!", zap.Error(err))
		}
		destinationRackCell, err := hmnSheet.Cell(rowIndex, 17)
		if err != nil {
			logger.Fatal("Failed to parse destination Rack cell!", zap.Error(err))
		}
		destinationLocationCell, err := hmnSheet.Cell(rowIndex, 18)
		if err != nil {
			logger.Fatal("Failed to parse destination Location cell!", zap.Error(err))
		}
		destinationPort, err := hmnSheet.Cell(rowIndex, 20)
		if err != nil {
			logger.Fatal("Failed to parse destination Port cell!", zap.Error(err))
		}

		row := shcd_parser.HMNRow{
			Source:              sourceCell.Value,
			SourceRack:          sourceRackCell.Value,
			SourceLocation:      sourceLocation.Value,
			SourceSubLocation:   sourceSubLocation.Value,
			SourceParent:        sourceParent.Value,
			DestinationRack:     destinationRackCell.Value,
			DestinationLocation: destinationLocationCell.Value,
			DestinationPort:     destinationPort.Value,
		}

		if row == (shcd_parser.HMNRow{}) {
			break
		}

		Rows = append(Rows, row)

		rowIndex++
	}
}

func main() {
	// Parse the arguments.
	flag.Parse()

	// Setup logging.
	var err error
	logger, err = zap.NewDevelopment()
	if err != nil {
		panic(fmt.Sprintf("Can't initialize zap logger: %v", err))
	}
	defer logger.Sync()

	if *shcdExcelFile == "" {
		logger.Fatal("SHCD file not specified!")
	}
	if *outputFile == "" {
		logger.Fatal("Output file not specified!")
	}

	// Parse the SHCD Excel.
	parseSHCDFile()

	// Now dump the contents to file.
	payloadJSON, _ := json.MarshalIndent(Rows, "", "    ")
	fmt.Println(string(payloadJSON))

	// Write JSON to file.
	writeErr := ioutil.WriteFile(*outputFile, payloadJSON, os.ModePerm)

	if writeErr != nil {
		logger.Fatal("Failed to write JSON!", zap.Error(writeErr))
	} else {
		logger.Info("Wrote HMN connections to file.", zap.String("outputFile", *outputFile))
	}

	logger.Info("Configuration generated.")
}
