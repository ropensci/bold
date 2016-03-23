bold
------



[![Build Status](https://api.travis-ci.org/ropensci/bold.png)](https://travis-ci.org/ropensci/bold)
[![Build status](https://ci.appveyor.com/api/projects/status/hifii9wvk2h7wc7f/branch/master)](https://ci.appveyor.com/project/sckott/bold/branch/master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/bold)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/bold)](https://cran.r-project.org/package=bold)

`bold` accesses BOLD barcode data.

[Documentation for the BOLD API](http://www.boldsystems.org/index.php/resources/api).

## Quickstart

### Install bold

#### From CRAN


```r
install.packages("bold")
```

#### Development version from Github

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


### Search for sequence data only

Default is to get a list back


```r
bold_seq(taxon='Coelioxys')[[1]]
#> $id
#> [1] "FBAPB481-09"
#> 
#> $name
#> [1] "Coelioxys afra"
#> 
#> $gene
#> [1] "FBAPB481-09"
#> 
#> $sequence
#> [1] "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTTCCACGAATAAATAATGTAAGATTTTGACTATTACCTCCCTCAATTTTCTTATTATTATCAAGAACCCTAATTAACCCAAGTGCTGGTACTGGATGAACTGTATATCCTCCTTTATCCTTATATACATTTCATGCCTCACCTTCCGTTGATTTAGCAATTTTTTCACTTCATTTATCAGGAATTTCATCAATTATTGGATCAATAAATTTTATTGTTACAATCTTAATAATAAAAAATTTTTCTTTAAATTATAGACAAATACCATTATTTTCATGATCAGTTTTAATTACTACAATTTTACTTTTATTATCATTACCAATTTTAGCTGGAGCAATTACTATACTCCTATTTGATCGAAATTTAAATACCTCATTCTTTGACCCAATAGGAGGAGGAGATCCAATTTTATATCAACATTTATTT"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$headers
#> $date
#> [1] "Wed, 23 Mar 2016 19:46:25 GMT"
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

### Search for specimen data only

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
#>      processid         sampleid recordID       catalognum         fieldnum
#> 1  ASGCB255-13   BIOUG07489-F04  3955532                    BIOUG07489-F04
#> 2 BCHYM1493-13 BC ZSM HYM 19353  4005342 BC ZSM HYM 19353 BC ZSM HYM 19353
#> 3  CHUBE002-06    CHU05-BEE-002   516711    CHU05-BEE-002    CHU05-BEE-002
#> 4  FBAPB679-09 BC ZSM HYM 02154  1289040 BC ZSM HYM 02154 BC ZSM HYM 02154
#> 5  FBAPB730-09 BC ZSM HYM 02205  1289091 BC ZSM HYM 02205 BC ZSM HYM 02205
#> 6  FBAPB743-09 BC ZSM HYM 02218  1289104 BC ZSM HYM 02218 BC ZSM HYM 02218
#>                                            institution_storing
#> 1                            Biodiversity Institute of Ontario
#> 2                    SNSB, Zoologische Staatssammlung Muenchen
#> 3 University of Manitoba, Wallis Roughley Museum of Entomology
#> 4                    SNSB, Zoologische Staatssammlung Muenchen
#> 5                    SNSB, Zoologische Staatssammlung Muenchen
#> 6                    SNSB, Zoologische Staatssammlung Muenchen
#>        bin_uri phylum_taxID
#> 1 BOLD:ABZ2181           20
#> 2 BOLD:AAK6070           20
#> 3 BOLD:AAD4181           20
#> 4 BOLD:AAI1788           20
#> 5 BOLD:AAK5820           20
#> 6                        20
```

### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $`ASGCB255-13`
#> [1] "-------------------------------GGAATAATTGGTTCTGCTATAAGTATTATTATTCGAATAGAATTAAGAATTCCTGGATCATTCATTTCTAATGATCAAACTTATAATTCTTTAGTAACAGCTCATGCTTTTTTAATAATTTTTTTTCTTGTAATACCATTTTTAATTGGTGGATTTGGAAATTGATTAATTCCATTAATATTAGGAATCCCAGATATAGCATTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCCCCATCCTTAATAATTTTACTTTTAAGAAATTTCTTAAATCCAAGTCCAGGAACAGGTTGAACTGTATATCCCCCCCTTTCTTCTTATTTATTTCATTCTTCCCCTTCTGTTGATTTAGCTATTTTTTCTCTTCATATTTCTGGTTTATCTTCCATCATAGGTTCTTTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCATTAAAACATATTCAATTACCTTTATTTCCTTGATCCGTTTTTATTACAACTATTTTACTATTATTTTCTTTACCTGTTCTAGCAGGAGCTATTACTATATTATTATTTGATCGAAACTTTAATACTTCATTTTTTGATCCAACTGGAGGAGGAGATCCAATTTTATATCAACATTTATTC"
#> 
#> $`BCHYM1493-13`
#> [1] "AATTTTATATATAATTTTTGCTTTATGATCTGGAATAATTGGTTCATCAATAAGAATTTTAATTCGAATAGAATTAAGAATTCCTGGATCATGAATTTCTAATGATCAAGTTTATAATTCTTTAGTAACTGCTCATGCTTTTTTAATAATTTTTTTTCTTGTAATACCATTTTTAATTGGGGGATTTGGAAATTGATTAATTCCTTTAATATTAGGAATTCCTGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCTCCATCTTTAATATTATTATTGTTAAGAAATTTTTTAAATCCAAGTCCAGGAACAGGATGAACTGTTTATCCTCCTCTTTCTTCAAATTTATTTCACTCTTCTCCTTCAGTAGATTTAGCAATTTTTTCATTACATATTTCAGGATTATCATCTATTATAGGATCATTAAATTTTATTGTTACAATTATTTTAATAAAAAATATTTCTTTAAAACATATTCAATTACCTTTATTTCCATGATCTGTTTTTATTACTACAATTCTTTTATTATTATCATTACCAGTTTTAGCAGGAGCTATTACTATACTTTTATTTGATCGAAATTTTAATACTTCTTTTTTTGACCCTATAGGAGGAGGAGATCCAATTCTTTATCAACATTTATTT"
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

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/bold/issues).
* License: MIT
* Get citation information for `bold` in R doing `citation(package = 'bold')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
