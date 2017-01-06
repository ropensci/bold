bold
====



[![Build Status](https://api.travis-ci.org/ropensci/bold.png)](https://travis-ci.org/ropensci/bold)
[![Build status](https://ci.appveyor.com/api/projects/status/hifii9wvk2h7wc7f/branch/master)](https://ci.appveyor.com/project/sckott/bold/branch/master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/bold)](https://github.com/metacran/cranlogs.app)
[![codecov.io](https://codecov.io/github/ropensci/bold/coverage.svg?branch=master)](https://codecov.io/github/ropensci/bold?branch=master)
[![cran version](http://www.r-pkg.org/badges/version/bold)](https://cran.r-project.org/package=bold)

`bold` accesses BOLD barcode data.

[Documentation for the BOLD API](http://www.boldsystems.org/index.php/resources/api).


## Installation

Stable CRAN version


```r
install.packages("bold")
```

Development version from Github

Install `sangerseqR` first


```r
source("http://bioconductor.org/biocLite.R")
biocLite("sangerseqR")
```

Then `bold`


```r
devtools::install_github("ropensci/bold")
```


```r
library("bold")
```


## Search for sequence data only

Default is to get a list back


```r
bold_seq(taxon='Coelioxys')[[1]]
#> $id
#> [1] "BBHYL407-10"
#> 
#> $name
#> [1] "Coelioxys porterae"
#> 
#> $gene
#> [1] "BBHYL407-10"
#> 
#> $sequence
#> [1] "TATAATATATATAATTTTTGCAATATGATCAGGTATAATTGGATCTTCTTTAAGAATAATTATCCGAATAGAATTAAGAATTCCAGGATCATGAATTAGTAATGATCAAATTTATAATTCTTTCATTACAGCACATGCATTCCTAATAATTTTTTTTTTAGTTATACCTTTTTTAATTGGAGGATTTGGTAATTGATTAACCCCACTAATATTAGGAGCTCCTGATATAGCTTTCCCTCGTATAAATAATATTAGATTTTGATTATTACCCCCTGCTCTATTAATATTATTATCAAGAAATTTAATTAATCCAAGACCTGGAACAGGATGAACTGTATACCCCCCTTTATCTTCTTATACTTACCACCCTTCTCCATCTGTAGATTTAGCAATTTTTTCTTTACATTTATCAGGAATTTCTTCAATTATTGGATCAATAAATTTTATTGTAACAATTTTAATAATAAAAAATTATTCAATAAATTATAATCAAATACCATTATTCCCATGATCAGTATTAATTACTACAATTTTATTATTATTATCTCTTCCTGTATTAGCAGGAGCAATTACTATATTATTATTTGATCGAAATTTAAATTCATCATTTTTTGACCCTATAGGAGGAGGAGACCCAATTTTATATCAACATTTATTT"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$headers
#> $date
#> [1] "Fri, 06 Jan 2017 18:27:39 GMT"
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
#> 
#> attr(,"class")
#> [1] "insensitive" "list"
```

## Search for specimen data only

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
#>     processid         sampleid recordID       catalognum         fieldnum
#> 1 ASGCB255-13   BIOUG07489-F04  3955532                    BIOUG07489-F04
#> 2 FBAPB679-09 BC ZSM HYM 02154  1289040 BC ZSM HYM 02154 BC ZSM HYM 02154
#> 3 FBAPB751-09 BC ZSM HYM 02226  1289112 BC ZSM HYM 02226 BC ZSM HYM 02226
#> 4 FBAPC359-10 BC ZSM HYM 05964  1709625 BC ZSM HYM 05964 BC ZSM HYM 05964
#> 5 FBAPC368-10 BC ZSM HYM 05973  1709634 BC ZSM HYM 05973 BC ZSM HYM 05973
#> 6 FBAPC540-11 BC ZSM HYM 07000  2021833 BC ZSM HYM 07000 BC ZSM HYM 07000
#>                         institution_storing      bin_uri phylum_taxID
#> 1         Biodiversity Institute of Ontario BOLD:ABZ2181           20
#> 2 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAI1788           20
#> 3 SNSB, Zoologische Staatssammlung Muenchen                        20
#> 4 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAI1999           20
#> 5 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAK5820           20
#> 6 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAY5201           20
```

## Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $`ASGCB255-13`
#> [1] "-------------------------------GGAATAATTGGTTCTGCTATAAGTATTATTATTCGAATAGAATTAAGAATTCCTGGATCATTCATTTCTAATGATCAAACTTATAATTCTTTAGTAACAGCTCATGCTTTTTTAATAATTTTTTTTCTTGTAATACCATTTTTAATTGGTGGATTTGGAAATTGATTAATTCCATTAATATTAGGAATCCCAGATATAGCATTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCCCCATCCTTAATAATTTTACTTTTAAGAAATTTCTTAAATCCAAGTCCAGGAACAGGTTGAACTGTATATCCCCCCCTTTCTTCTTATTTATTTCATTCTTCCCCTTCTGTTGATTTAGCTATTTTTTCTCTTCATATTTCTGGTTTATCTTCCATCATAGGTTCTTTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCATTAAAACATATTCAATTACCTTTATTTCCTTGATCCGTTTTTATTACAACTATTTTACTATTATTTTCTTTACCTGTTCTAGCAGGAGCTATTACTATATTATTATTTGATCGAAACTTTAATACTTCATTTTTTGATCCAACTGGAGGAGGAGATCCAATTTTATATCAACATTTATTC"
#> 
#> $`FBAPB679-09`
#> [1] "----------------------------TCTGGAATAATTGGGTCAGCAATAAGAATTATTATTCGAATAGAATTAAGTATTCCAGGATCATGAATTTCTAATGATCAAACATATAATTCTTTAGTAACTGCACATGCTTTTTTAATAATTTTTTTTCTTGTTATACCATTTTTAATTGGAGGATTTGGTAATTGATTAGTTCCATTAATATTAGGAATTCCAGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCTCCATCTTTAACATTATTACTTCTAAGAAATTTTCTAAATCCAAGTCCCGGAACAGGATGAACTATTTATCCTCCATTATCTTCAAATTTATTTCATACATCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTCTATCTTCTATTATAGGTTCATTAAACTTTATTGTTACTATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTCCTTGATCTGTTTTTATTACTACTATCCTTTTACTTTTTTCATTACCTGTATTAGCTGGAGCAATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTT"
```

Or you can index to a specific sequence like


```r
res$fasta['GBAH0293-06']
#> $`GBAH0293-06`
#> [1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```

## Get trace files

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

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/bold/issues).
* License: MIT
* Get citation information for `bold` in R doing `citation(package = 'bold')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
