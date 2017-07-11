bold
====



[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
![](https://img.shields.io/badge/CRAN/GitHub-0.4.0_/0.4.4.9120-blue.svg)


`bold` accesses BOLD barcode data.

The Barcode of Life Data Systems (BOLD) is designed to support the generation and application of DNA barcode data. The platform consists of four main modules: a data portal, a database of barcode clusters, an educational portal, and a data collection workbench.

This package retrieves data from the BOLD database of barcode clusters, and allows for searching of over 1.7M public records using multiple search criteria including sequence data, specimen data, specimen *plus* sequence data, as well as trace files.

[Documentation for the BOLD API](http://www.boldsystems.org/index.php/resources/api).


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
#> [1] "BBHYA1441-12"
#> 
#> $name
#> [1] "Coelioxys mexicana"
#> 
#> $gene
#> [1] "BBHYA1441-12"
#> 
#> $sequence
#> [1] "-------------------------------------------TCTTCCCTAAGAATAATCATCCGTATAGAATTAAGTATTCCAGGTTCTTGGATTAATAATGATCAAATTTATAATTCATTTATTACAGCCCATGCTTTTTTAATAATTTTTTTTTTAGTAATACCTTTTTTAATTGGTGGATTTGGAAATTGATTAGCTCCTTTAATAATCGGAGCCCCAGATATAGCATTCCCACGAATAAACAATATTAGATTTTGATTACTTCCCCCTTCATTATTATTTCTATTATCAAGAAATTTAATCTCCCCTAGTCCCGGTACAGGATGAACTGTATATCCTCCCTTATCTTCCTATACATTTCATCCCTCTCCTTCGGTTGACTTGGCTATTTTTTCTTTACATTTATCAGGAATCTCTTCAATTATTGGATCAATAAATTTTATTGTAACTATTTTAATAATAAAAAATTACTCTTTAAATTACAGACAAATACCTTTATTCCCATGATCAGTATTAATTACTACAATTTTATTATTACTTTCTTTACCTGTACTAGCAGGAGCTATCACAATATTATTATTTGATCGAAATTTAAATTCTTCTTTTTTTGACCCTATGGGAGGAGGAGATCCTATTTTATATCAACATTTATTT\r"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$response_headers
#> $status
#> [1] "HTTP/1.1 200 OK"
#> 
#> $date
#> [1] "Tue, 11 Jul 2017 17:13:47 GMT"
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
#>     processid
#> 1   image_ids
#> 2 FBAPB671-09
#> 3      663009
#> 4 FBAPB679-09
#> 5      663017
#> 6 FBAPB727-09
#>                                                                sampleid
#> 1                                                            image_urls
#> 2                                                      BC ZSM HYM 02146
#> 3 http://www.boldsystems.org/pics/FBAPB/BC_ZSM_HYM_02146+1259765280.JPG
#> 4                                                      BC ZSM HYM 02154
#> 5 http://www.boldsystems.org/pics/FBAPB/BC_ZSM_HYM_02154+1259765280.JPG
#> 6                                                      BC ZSM HYM 02202
#>                                                   recordID
#> 1                                       copyright_licenses
#> 2                                                  1289032
#> 3 CreativeCommons - Attribution Non-Commercial Share-Alike
#> 4                                                  1289040
#> 5 CreativeCommons - Attribution Non-Commercial Share-Alike
#> 6                                                  1289088
#>                catalognum
#> 1               trace_ids
#> 2        BC ZSM HYM 02146
#> 3                 2474894
#> 4        BC ZSM HYM 02154
#> 5 2578904|2474899|2578877
#> 6        BC ZSM HYM 02202
#>                                                                                                                                                            fieldnum
#> 1                                                                                                                                                       trace_links
#> 2                                                                                                                                                  BC ZSM HYM 02146
#> 3                                                                                                             http://trace.boldsystems.org/traceIO/bold.org/2165735
#> 4                                                                                                                                                  BC ZSM HYM 02154
#> 5 http://trace.boldsystems.org/traceIO/bold.org/2263489|http://trace.boldsystems.org/traceIO/bold.org/2165740|http://trace.boldsystems.org/traceIO/bold.org/2263462
#> 6                                                                                                                                                  BC ZSM HYM 02202
#>                                           institution_storing
#> 1                                                   run_dates
#> 2                   SNSB, Zoologische Staatssammlung Muenchen
#> 3                                         2010-10-28 09:39:39
#> 4                   SNSB, Zoologische Staatssammlung Muenchen
#> 5 2010-12-08 21:46:32|2010-10-28 09:39:39|2010-12-08 20:19:35
#> 6                   SNSB, Zoologische Staatssammlung Muenchen
#>                                                                                                 bin_uri
#> 1                                                                                    sequencing_centers
#> 2                                                                                                      
#> 3                                                                     Biodiversity Institute of Ontario
#> 4                                                                                          BOLD:AAI1788
#> 5 Biodiversity Institute of Ontario|Biodiversity Institute of Ontario|Biodiversity Institute of Ontario
#> 6                                                                                          BOLD:AAE5457
#>   phylum_taxID
#> 1   directions
#> 2           20
#> 3            F
#> 4           20
#> 5        R|F|F
#> 6           20
```

### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
#> $image_ids
#> [1] ""
#> 
#> $`FBAPB671-09`
#> [1] "------------------------------------------------------AATTTTAATTCGAATAGAATTAAGAATTCCCGGATCATGAATTTCTAATGATCAAGTTTATAATTCTTTAGTAACTGCTCATGCTTTTTTAATAATTTTTTTTCTTGTAATACCATTTTTAATTGGTGGATTTGGAAATTGATTAATTCCTTTAATATTAGGAATTCCTGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTCTACCTCCATCTTTAATATTATTACTTTTGAGAAATTTTTTAAATCCAAGTCCAGGNACNGGATGAACT------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
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
