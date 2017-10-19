bold
====



[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![cran version](https://www.r-pkg.org/badges/version/bold)](https://cran.r-project.org/package=bold)


`bold` accesses BOLD barcode data.

The Barcode of Life Data Systems (BOLD) is designed to support the generation and application of DNA barcode data. The platform consists of four main modules: a data portal, a database of barcode clusters, an educational portal, and a data collection workbench.

This package retrieves data from the BOLD database of barcode clusters, and allows for searching of over 1.7M public records using multiple search criteria including sequence data, specimen data, specimen *plus* sequence data, as well as trace files.

[Documentation for the BOLD API](http://v4.boldsystems.org/index.php/api_home).


## Package status and installation

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/bold?branch=master&svg=true)](https://ci.appveyor.com/project/ropensci/bold)
[![Travis-CI Build Status](https://travis-ci.org/ropensci/bold.svg?branch=master)](https://travis-ci.org/)
[![codecov.io](https://codecov.io/github/ropensci/bold/coverage.svg?branch=master)](https://codecov.io/github/ropensci/bold?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/bold)](https://github.com/metacran/cranlogs.app)

__Installation instructions__

__Stable Version__


```r
install.packages("bold")
```

__Development Version__

Install `sangerseqR` first


```r
source("http://bioconductor.org/biocLite.R")
biocLite("sangerseqR")
```

Then `bold`


```r
devtools::install_github("ropensci/bold")
```


## Usage

```r
library("bold")
```


### Search for sequence data only

Default is to get a list back


```r
bold_seq(taxon='Coelioxys')[[1]]
#> $id
#> [1] "BBHYL404-10"
#>
#> $name
#> [1] "Coelioxys rufitarsis"
#>
#> $gene
#> [1] "BBHYL404-10"
#>
#> $sequence
#> [1] "TATAATATATATAATTTTTGCAATATGATCAGGTATAATTGGATCATCTTTAAGAATAATTATTCGAATAGAATTAAGAATCCCAGGTTCATGAATTAGAAATGATCAAATTTATAATTCTTTTATTACAGCACATGCATTTTTAATAATTTTTTTTTTAGTTATGCCTTTTCTAATTGGGGGATTTGGTAATTGATTAACACCATTAATACTTGGAGCTCCTGATATAGCTTTCCCCCGAATAAACAATATTAGATTTTGACTACTCCCACCTTCTTTATTACTTTTATTATCAAGAAATTTAATTAATCCAAGACCAGGAACAGGATGAACTGTTTATCCACCATTATCCTCTTATACATATCATCCATCTCCTTCTGTAGATTTAGCAATTTTTTCTTTACATTTATCAGGAATTTCCTCAATTATTGGATCAATAAATTTTATTGTTACAATTTTAATAATAAAAAATTATTCAATAAATTATAATCAAATACCATTATTCCCATGATCAGTTTTAATTACTACAATTTTATTATTACTATCACTTCCAGTATTAGCAGGAGCAATTACAATATTATTATTTGATCGAAATTTAAATTCTTCTTTTTTTGACCCAATAGGAGGAGGAGACCCAATTTTATATCAACATTTATTT\r"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$response_headers
#> $status
#> [1] "HTTP/1.1 200 OK"
#>
#> $date
#> [1] "Thu, 20 Jul 2017 21:51:40 GMT"
#>
#> $server
#> [1] "Apache/2.2.15 (Red Hat)"
#>
#> $`x-powered-by`
#> [1] "PHP/5.3.15"
#>
#> $`content-disposition`
#> [1] "attachment; filename=fasta.fas"
#>
#> $connection
#> [1] "close"
#>
#> $`transfer-encoding`
#> [1] "chunked"
#>
#> $`content-type`
#> [1] "application/x-download"
```

### Search for specimen data only

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
#>      processid         sampleid recordID       catalognum         fieldnum
#> 1  ASGCB255-13   BIOUG07489-F04  3955532                    BIOUG07489-F04
#> 2  ASGCB258-13   BIOUG07489-F07  3955535                    BIOUG07489-F07
#> 3 BBHYA3298-12   BIOUG02688-A06  2711807   BIOUG02688-A06  L#11BIOBUS-2558
#> 4  BBHYL310-10     10BBCHY-3264  1769753     10BBCHY-3264   L#PC2010KT-025
#> 5 BCHYM1496-13 BC ZSM HYM 19356  4005345 BC ZSM HYM 19356 BC ZSM HYM 19356
#> 6  BCHYM412-13 BC ZSM HYM 18272  3896353 BC ZSM HYM 18272 BC ZSM HYM 18272
#>                                      institution_storing collection_code
#> 1                      Biodiversity Institute of Ontario              NA
#> 2                      Biodiversity Institute of Ontario              NA
#> 3 University of Guelph, Centre for Biodiversity Genomics              NA
#> 4 University of Guelph, Centre for Biodiversity Genomics              NA
#> 5              SNSB, Zoologische Staatssammlung Muenchen              NA
#> 6              SNSB, Zoologische Staatssammlung Muenchen              NA
#>        bin_uri
#> 1 BOLD:ABZ2181
#> 2 BOLD:AAC0884
#> 3 BOLD:ACF5858
#> 4 BOLD:AAC3295
#> 5 BOLD:AAI2010
#> 6 BOLD:AAP2416
```

### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $`ASGCB255-13`
#> [1] "-------------------------------GGAATAATTGGTTCTGCTATAAGTATTATTATTCGAATAGAATTAAGAATTCCTGGATCATTCATTTCTAATGATCAAACTTATAATTCTTTAGTAACAGCTCATGCTTTTTTAATAATTTTTTTTCTTGTAATACCATTTTTAATTGGTGGATTTGGAAATTGATTAATTCCATTAATATTAGGAATCCCAGATATAGCATTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCCCCATCCTTAATAATTTTACTTTTAAGAAATTTCTTAAATCCAAGTCCAGGAACAGGTTGAACTGTATATCCCCCCCTTTCTTCTTATTTATTTCATTCTTCCCCTTCTGTTGATTTAGCTATTTTTTCTCTTCATATTTCTGGTTTATCTTCCATCATAGGTTCTTTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCATTAAAACATATTCAATTACCTTTATTTCCTTGATCCGTTTTTATTACAACTATTTTACTATTATTTTCTTTACCTGTTCTAGCAGGAGCTATTACTATATTATTATTTGATCGAAACTTTAATACTTCATTTTTTGATCCAACTGGAGGAGGAGATCCAATTTTATATCAACATTTATTC"
#>
#> $`ASGCB258-13`
#> [1] "GATTTTATATATAATTTTTGCTATGTGATCAGGAATAATTGGTTCAGCAATAAGAATTATTATTCGAATAGAATTAAGAATTCCAGGTTCATGAATCTCTAATGATCAAATTTATAATTCTTTAGTTACTGCTCACGCTTTTTTAATAATTTTTTTTTTAGTAATACCATTTTTAATTGGAGGATTTGGTAATTGATTAGTTCCATTAATATTAGGAATTCCAGATATAGCATTTCCACGAATAAATAATATTAGATTTTGACTTTTACCTCCTTCTTTAATGTTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCAGGAACTGGATGAACTGTATATCCTCCTCTTTCTTCTCATTTATTTCATTCTTCTCCTTCAGTTGATATAGCTATTTTTTCTTTACATATTTCTGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCATTAAAACATATTCAATTGCCTTTATTTCCTTGATCTGTTTTTATTACTACTATTTTATTACTTTTTTCTTTACCTGTTTTAGCTGGAGCAATTACTATATTATTATTTGATCGAAATTTTAATACTTCATTTTTTGATCCGACAGGAGGTGGAGATCCAATTCTTTATCAACATTTATTT"
```

Or you can index to a specific sequence like


```r
res$fasta['GBAH0293-06']
#> $`GBAH0293-06`
#> [1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```

### Get trace files

This function downloads files to your machine - it does not load them into your R session - but prints out where the files are for your information.


```r
x <- bold_trace(ids = 'ACRJP618-11', progress = FALSE)
read_trace(x$ab1)
#> Number of datapoints: 8877
#> Number of basecalls: 685
#>
#> Primary Basecalls: NNNNNNNNNNNNNNNNNNGNNNTTGAGCAGGNATAGTAGGANCTTCTCTTAGTCTTATTATTCGAACAGAATTAGGAAATCCAGGATTTTTAATTGGAGATGATCAAATCTACAATACTATTGTTACGGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGTAATTGATTAGTTCCCCTTATACTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAACAATATAAGTTTTTGGCTTCTTCCCCCTTCACTATTACTTTTAATTTCCAGAAGAATTGTTGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCACTGTCATCTAATATTGCCCATAGAGGTACATCAGTAGATTTAGCTATTTTTTCTTTACATTTAGCAGGTATTTCCTCTATTTTAGGAGCGATTAATTTTATTACTACAATTATTAATATACGAATTAACAGTATAAATTATGATCAAATACCACTATTTGTGTGATCAGTAGGAATTACTGCTTTACTCTTATTACTTTCTCTTCCAGTATTAGCAGGTGCTATCACTATATTATTAACGGATCGAAATTTAAATACATCATTTTTTGATCCTGCAGGAGGAGGAGATCCAATTTTATATCAACATTTATTTTGATTTTTTGGACNTCNNNNAAGTTTAAN
#>
#> Secondary Basecalls:
```

## Citation

Get citation information for `bold` in R by running: `citation(package = 'bold')`

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.


[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
