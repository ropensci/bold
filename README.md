bold
------



[![Build Status](https://api.travis-ci.org/ropensci/bold.png)](https://travis-ci.org/ropensci/bold)
[![Build status](https://ci.appveyor.com/api/projects/status/hifii9wvk2h7wc7f/branch/master)](https://ci.appveyor.com/project/sckott/bold/branch/master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/bold)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/bold)](http://cran.rstudio.com/web/packages/bold)

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
#> [1] "FBAPB491-09"
#> 
#> $name
#> [1] "Coelioxys conica"
#> 
#> $gene
#> [1] "FBAPB491-09"
#> 
#> $sequence
#> [1] "---------------------ACCTCTTTAAGAATAATTATTCGTATAGAAATAAGAATTCCAGGATCTTGAATTAATAATGATCAAATTTATAACTCCTTTATTACAGCACATGCATTTTTAATAATTTTTTTTTTAGTTATACCTTTTCTTATTGGAGGATTTGGAAATTGATTAGTACCTTTAATATTAGGATCACCAGATATAGCTTTCCCACGAATAAATAATATTAGATTTTGATTATTACCTCCTTCTTTATTAATATTATTATTAAGTAATTTAATAAATCCCAGACCAGGAACAGGCTGAACAGTTTATCCTCCTTTATCTTTATACACATACCACCCTTCTCCCTCAGTTGATTTAGCAATTTTTTCACTACATCTATCAGGAATCTCTTCTATTATTGGATCTATAAATTTTATTGTTACAATTTTAATAATAAAAAACTTTTCAATAAATTATAATCAAATACCATTATTCCCATGATCTATTTTAATTACTACTATTTTATTATTATTATCACTACCTGTATTAGCTGGTGCTATTACTATATTATTATTTGATCGAAATTTAAATTCTTCTTTTTTTGACCCTATAGGAGGAGGAGACCCAATTTTATACCAACATTTA"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$headers
#> $date
#> [1] "Tue, 15 Sep 2015 20:20:56 GMT"
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
#> 1  ASGCB261-13   BIOUG07489-F10  3955538                    BIOUG07489-F10
#> 2 BCHYM1499-13 BC ZSM HYM 19359  4005348 BC ZSM HYM 19359 BC ZSM HYM 19359
#> 3  BCHYM412-13 BC ZSM HYM 18272  3896353 BC ZSM HYM 18272 BC ZSM HYM 18272
#> 4  BCHYM413-13 BC ZSM HYM 18273  3896354 BC ZSM HYM 18273 BC ZSM HYM 18273
#> 5  FBAPB706-09 BC ZSM HYM 02181  1289067 BC ZSM HYM 02181 BC ZSM HYM 02181
#> 6  FBAPB730-09 BC ZSM HYM 02205  1289091 BC ZSM HYM 02205 BC ZSM HYM 02205
#>                         institution_storing      bin_uri phylum_taxID
#> 1         Biodiversity Institute of Ontario BOLD:AAB8874           20
#> 2 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAD6282           20
#> 3 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAP2416           20
#> 4 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAP2416           20
#> 5 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAE4126           20
#> 6 SNSB, Zoologische Staatssammlung Muenchen BOLD:AAK5820           20
```

### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $`ASGCB261-13`
#> [1] "AATTTTATATATAATTTTTGCTATATGATCAGGAATAATTGGTTCAGCAATAAGAATTATTATTCGAATAGAATTAAGAATTCCTGGTTCATGAATTTCAAATGATCAAACTTATAATTCTTTAGTTACTGCTCATGCTTTTTTAATAATTTTTTTCTTAGTTATACCATTCTTAATTGGGGGATTTGGAAATTGATTAATTCCTTTAATATTAGGAATTCCAGATATAGCATTTCCACGAATAAATAATATTAGATTTTGACTTTTACCTCCTTCTTTAATACTTTTATTATTAAGAAATTTTATAAATCCTAGTCCAGGAACTGGATGAACTGTTTATCCACCTTTATCTTCTCATTTATTTCATTCTTCTCCTTCAGTTGATATAGCTATTTTTTCTTTACATATTTCTGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAACATATTCAATTACCTTTATTTCCTTGATCTGTCTTTATTACTACTATTTTATTACTTTTTTCTTTACCTGTTTTAGCAGGTGCAATTACTATATTATTATTTGATCGAAATTTTAATACTTCATTTTTTGATCCTACAGGAGGAGGAGATCCTATTCTTTATCAACATTTATTT"
#> 
#> $`BCHYM1499-13`
#> [1] "AATTCTTTACATAATTTTTGCTTTATGATCTGGAATAATTGGGTCAGCAATAAGAATTATTATTCGAATAGAATTAAGTATCCCAGGTTCATGAATTACTAATGATCAAATTTATAATTCTTTAGTAACTGCACATGCTTTTTTAATAATTTTTTTTCTTGTGATACCATTTTTAATTGGAGGATTTGGAAATTGATTAATTCCTTTAATATTAGGAATTCCAGATATAGCTTTCCCACGAATAAACAATATTAGATTTTGATTATTACCGCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCCCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTGCCTTTATTTCCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTGTTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCTACAGGAGGAGGAGATCCAATTCTTTATCAACATTTATTT"
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
x <- bold_trace(ids='ACRJP618-11', dest="~/mytarfiles", progress = FALSE)
read_trace(x$ab1[2])
#> Number of datapoints: 9533
#> Number of basecalls: 349
#> 
#> Primary Basecalls: NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNGNNNANNGGNTCATCCATAAGATTATTAATTCGTATAGAATTAAGTCATCCTGGTATATGAATCAATAATGATCAAATTTATAATTCATTAGTTACAAATCATGCATTTTTAATAATTTTTTTTATAGTTATACCATTTATAATTGGAGGATTTGGAAATTACTTAATTCCATTAATATTAGGATCATCTGATATAGCTTTTCCACGAATAAATAATATTAGATTCTGATCACTTCCTCCATCTCTTTTTATATTACTTTTAAGAAATTTATTCACACCAAATGTAGGAACNGGATGAANTNNNNNNNNNNNNN
#> 
#> Secondary Basecalls:
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/bold/issues).
* License: MIT
* Get citation information for `bold` in R doing `citation(package = 'bold')`

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
