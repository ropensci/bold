<!--
%\VignetteEngine{knitr::docco_classic}
%\VignetteIndexEntry{bold vignette}
-->

`bold` is an R package to connect to BOLD Systems \url{http://www.boldsystems.org/} via their API. Functions in `bold` let you search for sequence data, specimen data, sequence + specimen data, and download raw trace files.

### bold info

+ [BOLD home page](http://boldsystems.org/)
+ [BOLD API docs](boldsystems.org/index.php/resources/api)

### Using bold

**Install**

Install `bold`


```r
devtools::install_github("ropensci/bold")
```


```r
library("bold")
```

### Search for sequence data only

Default is to get a list back


```r
bold_seq(taxon='Coelioxys')[1:2]
```

```
## [[1]]
## [[1]]$id
## [1] "CNPPJ1450-12"
## 
## [[1]]$name
## [1] "Coelioxys sayi"
## 
## [[1]]$gene
## [1] "CNPPJ1450-12"
## 
## [[1]]$sequence
## [1] "TATTATATATATAATTTTTGCAATATGATCAGGAATAATTGGATCTTCCTTAAGAATAATTATTCGAATAGAATTAAGAATT---CCAGGATCATGAATTAGTAATGACCAAATTTATAATTCCTTTATTACAGCGCACGCATTTTTAATAATTTTCTTTTTAGTTATACCGTTTTTAATTGGTGGATTTGGAAATTGACTCACACCTTTAATATTAGGAGCCCCTGATATAGCTTTCCCCCGTATAAATAATATTAGATTTTGATTATTACCCCCCTCATTATTAATATTATTATCAAGAAATTTAATTAACCCAAGACCTGGAACAGGATGAACAGTTTATCCACCACTATCTTCTTATACTTATCATCCTTCTCCTTCTGTAGATCTAGCAATTTTTTCTTTACACTTATCAGGTATTTCTTCTATTATTGGATCAATAAATTTTATTGTAACAATTTTATTAATAAAAAATTATTCAATAAATTATAATCAAATACCTTTATTTCCCTGATCTGTTTTAATTACAACAATTTTATTACTATTATCACTACCTGTATTAGCAGGAGCAATTACAATATTATTATTT---------GATCGAAATTTAAATTCATCATTTTTCGACCCTATAGGAGGAGGAG-----------------------------"
## 
## 
## [[2]]
## [[2]]$id
## [1] "GBMIN26386-13"
## 
## [[2]]$name
## [1] "Coelioxys sp. HMG-2011"
## 
## [[2]]$gene
## [1] "GBMIN26386-13"
## 
## [[2]]$sequence
## [1] "CGAATAAATAATATTAGATTTTGATTATTACCCCCATCACTATTATTACTTCTATTAAGTAATTTGATTAAACCAAGACCAGGTACAGGATGAACCGTATACCCTCCCTTATCTTTATATCTTTATCACCCTTCACCATCAGTTGATTTTGCAATTTTTTCTTTACATTTATCAGGAATTTCATCTATTATTGGTTCATTAAATTTTATTGTAACAATTTTAATAATAAAAAATTGATCTTTAAATTATAGACAAATATCATTATTTCCTTGATCAATTTTTATTACTACAATTTTATTATTA"
```

You can optionally get back the `httr` response object


```r
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$headers
```

```
## $date
## [1] "Wed, 28 May 2014 20:11:59 GMT"
## 
## $server
## [1] "Apache/2.2.15 (Red Hat)"
## 
## $`x-powered-by`
## [1] "PHP/5.3.15"
## 
## $`content-disposition`
## [1] "attachment; filename=fasta.fas"
## 
## $connection
## [1] "close"
## 
## $`transfer-encoding`
## [1] "chunked"
## 
## $`content-type`
## [1] "application/x-download"
## 
## $status
## [1] "200"
## 
## $statusmessage
## [1] "OK"
## 
## attr(,"class")
## [1] "insensitive" "list"
```

### Search for specimen data only

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
```

```
##     processid sampleid recordID catalognum fieldnum
## 1 GBAH0293-06 AF250940   470890                    
## 2 GBAH3879-08 EU726628   856410   EU726628         
## 3 GBAH3880-08 EU726627   856411   EU726627         
## 4 GBAH3888-08 EU726619   856419   EU726619         
## 5 GBAH3904-08 EU726603   856435   EU726603         
## 6 GBAH3909-08 EU726598   856440   EU726598         
##        institution_storing      bin_uri phylum_taxID
## 1 Mined from GenBank, NCBI BOLD:AAD6282           20
## 2 Mined from GenBank, NCBI BOLD:AAA4494           20
## 3 Mined from GenBank, NCBI BOLD:AAA4494           20
## 4 Mined from GenBank, NCBI BOLD:AAA4494           20
## 5 Mined from GenBank, NCBI BOLD:AAA4494           20
## 6 Mined from GenBank, NCBI BOLD:AAA4494           20
```


### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
```

```
## $`GBAH0293-06`
## [1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
## 
## $`GBAH3879-08`
## [1] "---------------------------------------ATTCTATATATAATTTTTGCTTTATGATCTGGAATAATTGGATCAGCAATA---AGAATTATTATTCGAATAGAATTAAGTATCCCAGGATCATGAATTTCTAAT---GATCAAATTTATAATTCTTTAGTAACTGGTCATGCCTTTTTAATAATTTTTTTTCTTGTCATACCATTTTTAATTGGAGGATTTGGAAATTGATTAATTCCATTAATA---TTAGGAATTCCAGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCACCATCCTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGACCTGGAACAGGATGAACAATTTATCCACCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTA---GCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAACATTTCCTTAAAATATATTCAATTATCCTTATTTCCTTGATCTGTATTTATTACTACTATTCTTTTACTTTTTTCTTTACCTGTATTAGCTGGA---GCAATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGTGGAGATCCAATTCTTTATCAACATTTA------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```

Or you can index to a specific sequence like


```r
res$fasta['GBAH0293-06']
```

```
## $`GBAH0293-06`
## [1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```


### Get trace files

This function downloads files to your machine - it does not load them into your R session - but prints out where the files are for your information.


```r
bold_trace(taxon='Osmia', quiet=TRUE)
```

```
## Trace file extracted with files: 
## 
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/HMBCH056-07_F.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/HMBCH056-07_R.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/HMBCH063-07_F.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/HMBCH063-07_R.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/Osm_aur_T505_LCOHym_D04_008_copy.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/Osm_aur_T505_NancyFull_D10_008_copy.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/Osm_ruf_T309_LCOHym_C06_006_copy.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/Osm_ruf_T309_Nancy_C06_006_copy.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/TRACE_FILE_INFO.txt
```
