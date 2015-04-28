bold
------



[![Build Status](https://api.travis-ci.org/ropensci/bold.png)](https://travis-ci.org/ropensci/bold)
[![Build status](https://ci.appveyor.com/api/projects/status/hifii9wvk2h7wc7f/branch/master)](https://ci.appveyor.com/project/sckott/bold/branch/master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/bold)](https://github.com/metacran/cranlogs.app)

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
#> [1] "BBHYL406-10"
#> 
#> $name
#> [1] "Coelioxys moesta"
#> 
#> $gene
#> [1] "BBHYL406-10"
#> 
#> $sequence
#> [1] "TATAATATATATAATTTTTGCAATATGATCAGGAATAATTGGATCTTCTATAAGTATAATTATTCGAATAGAATTAAGAATCCCAGGATCATGAATTAATAATGATCAAATTTATAACTCTTTTATTACAGCACATGCATTTTTAATAATTTTTTTTTTAGTTATACCTTTTTTAATTGGAGGGTTTGGAAATTGATTAACACCATTAATATTAGGAGCTCCTGATATAGCTTTCCCTCGAATAAATAATATTAGATTTTGATTATTACCCCCATCTTTATTAATATTATTATCAAGAAATTTAATTAATCCAAGACCAGGTACAGGATGAACTGTTTACCCTCCTTTATCCTCATATATATATCATCCTTCACCATCAGTAGATTTAGCTATTTTTTCTTTACACTTATCTGGTATTTCTTCAATTATTGGATCAATAAATTTTATTGTAACAATTTTAATAATAAAAAATTATTCAATAAATTATAATCAAATACCCCTATTTCCATGATCAGTTTTAATTACTACAATTTTATTATTATTATCATTACCGGTATTAGCAGGAGCAATTACAATATTATTATTTGATCGAAATTTAAATTCATCTTTTTTTGATCCTATAGGAGGAGGAGATCCTATTTTATACCAACATTTATTT"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$headers
#> $date
#> [1] "Sun, 26 Oct 2014 23:43:10 GMT"
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
#> 1  BBHYL363-10     10BBCHY-3317  1769806     10BBCHY-3317   L#PC2010YO-001
#> 2  BBHYL365-10     10BBCHY-3319  1769808     10BBCHY-3319   L#PC2010YO-150
#> 3 BCHYM1491-13 BC ZSM HYM 19351  4005340 BC ZSM HYM 19351 BC ZSM HYM 19351
#> 4  FBAPB676-09 BC ZSM HYM 02151  1289037 BC ZSM HYM 02151 BC ZSM HYM 02151
#> 5  FBAPB682-09 BC ZSM HYM 02157  1289043 BC ZSM HYM 02157 BC ZSM HYM 02157
#> 6  FBAPB719-09 BC ZSM HYM 02194  1289080 BC ZSM HYM 02194 BC ZSM HYM 02194
#>                    institution_storing      bin_uri phylum_taxID
#> 1    Biodiversity Institute of Ontario BOLD:ABZ0288           20
#> 2    Biodiversity Institute of Ontario BOLD:AAC8510           20
#> 3 Bavarian State Collection of Zoology BOLD:AAK6070           20
#> 4 Bavarian State Collection of Zoology BOLD:AAI1788           20
#> 5 Bavarian State Collection of Zoology BOLD:AAO8736           20
#> 6 Bavarian State Collection of Zoology BOLD:AAE5490           20
```

### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $`BBHYL363-10`
#> [1] "AATTTTATATATAATTTTTGCTATATGATCAGGTATAATTGGATCAGCAATAAGAATTATTATTCGTATAGAATTAAGAATTCCCGGTTCATGAATTTCAAATGATCAAACTTATAATTCTTTAGTAACTGCTCATGCCTTTTTAATAATTTTTTTCTTAGTTATACCATTTTTAATTGGAGGATTTGGTAATTGATTAATTCCTTTAATATTAGGAATTCCAGATATAGCTTTCCCCCGAATAAATAATATTAGATTTTGACTTTTACCTCCCTCATTAATATTATTACTTTTAAGAAATTTTCTTAATCCAAGACCAGGTACTGGATGAACTGTTTATCCTCCTCTTTCTTCTCATTTATTTCATTCCTCTCCTTCAATTGATATAGCTATTTTTTCTTTACATATTTCTGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTAACAATTATTATAATAAAAAATATTTCTTTAAAACATATTCAATTACCTTTATTTCCATGATCTGTATTTATTACTACTATTTTATTACTTCTTTCTTTACCTGTTTTAGCAGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACTTCATTTTTTGATCCTACAGGAGGAGGAGATCCAATTCTTTATCAACATTTATTT"
#> 
#> $`BBHYL365-10`
#> [1] "AATATTATATATAATTTTTGCTTTGTGATCTGGAATAATTGGTTCATCTATAAGAATTATTATTCGTATAGAATTAAGAATTCCTGGTTCATGAATTTCAAATGATCAAGTTTATAATTCATTAGTTACAGCTCATGCTTTTTTAATAATTTTTTTTTTAGTTATACCATTTATAATTGGAGGATTTGGAAATTGATTAGTTCCTTTAATATTAGGAATTCCTGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGATTATTACCACCATCATTAATACTTTTACTTTTAAGAAATTTTTTTAATCCAAGTTCAGGAACTGGATGAACTGTATATCCTCCTCTTTCATCATATTTATTTCATTCTTCACCTTCTGTTGATTTAGCTATTTTTTCTCTTCATATATCAGGTTTATCTTCTATTATAGGTTCATTAAACTTTATTGTAACTATTATTATAATAAAAAATATTTCTTTAAAGTATATTCAATTACCATTATTTCCATGATCTGTTTTTATTACTACAATTCTTTTATTATTATCATTACCAGTTTTAGCAGGTGCTATTACTATATTATTATTTGATCGAAATTTTAATACTTCATTTTTTGATCCTACAGGAGGGGGAGATCCAATTTTATATCAACATTTATTT"
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

* [Please report any issues or bugs](https://github.com/ropensci/bold/issues).
* License: MIT
* Get citation information for `bold` in R doing `citation(package = 'bold')`

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
