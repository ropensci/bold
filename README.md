bold
------

[![Build Status](https://api.travis-ci.org/ropensci/bold.png)](https://travis-ci.org/ropensci/bold)

`bold` accesses BOLD barcode data.

You do not need an API key.

[Documentation for the BOLD API](http://www.boldsystems.org/index.php/resources/api).

`bold` is part of the rOpenSci project, visit http://ropensci.org to learn more.

## Quickstart

### Install bold from GitHub:

```coffee
devtools::install_github("ropensci/bold")
library("bold")
```

### Search for sequence data only

Default is to get a list back

```coffee
bold_seq(taxon='Coelioxys')
```

```coffee
[[1]]
[[1]]$id
[1] "CNPPJ1450-12"

[[1]]$name
[1] "Coelioxys sayi"

[[1]]$gene
[1] "CNPPJ1450-12"

[[1]]$sequence
[1] "TATTATATATATAATTTTTGCAATATGATCAGGAATAATTGGATCTTCCTTAAGAATAATTATTCGAATAGAATTAAGAATT---CCAGGATCATGAATTAGTAATGACCAAATTTATAATTCCTTTATTACAGCGCACGCATTTTTAATAATTTTCTTTTTAGTTATACCGTTTTTAATTGGTGGATTTGGAAATTGACTCACACCTTTAATATTAGGAGCCCCTGATATAGCTTTCCCCCGTATAAATAATATTAGATTTTGATTATTACCCCCCTCATTATTAATATTATTATCAAGAAATTTAATTAACCCAAGACCTGGAACAGGATGAACAGTTTATCCACCACTATCTTCTTATACTTATCATCCTTCTCCTTCTGTAGATCTAGCAATTTTTTCTTTACACTTATCAGGTATTTCTTCTATTATTGGATCAATAAATTTTATTGTAACAATTTTATTAATAAAAAATTATTCAATAAATTATAATCAAATACCTTTATTTCCCTGATCTGTTTTAATTACAACAATTTTATTACTATTATCACTACCTGTATTAGCAGGAGCAATTACAATATTATTATTT---------GATCGAAATTTAAATTCATCATTTTTCGACCCTATAGGAGGAGGAG-----------------------------"


[[2]]
[[2]]$id
[1] "GBMIN26386-13"

...cutoff
```

You can optionally get back the `httr` response object

```coffee
res <- bold_seq(taxon='Coelioxys', response=TRUE)
res$headers
```

```coffee
$date
[1] "Wed, 28 May 2014 18:52:06 GMT"

$server
[1] "Apache/2.2.15 (Red Hat)"

$`x-powered-by`
[1] "PHP/5.3.15"

$`content-disposition`
[1] "attachment; filename=fasta.fas"

$connection
[1] "close"

$`transfer-encoding`
[1] "chunked"

$`content-type`
[1] "application/x-download"

$status
[1] "200"

$statusmessage
[1] "OK"

attr(,"class")
[1] "insensitive" "list"
```

### Search for specimen data only

By default you download `tsv` format data, which is given back to you as a `data.frame`

```coffee
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
```

```coffee
    processid sampleid recordID catalognum fieldnum      institution_storing      bin_uri phylum_taxID
1 GBAH0293-06 AF250940   470890                     Mined from GenBank, NCBI BOLD:AAD6282           20
2 GBAH3879-08 EU726628   856410   EU726628          Mined from GenBank, NCBI BOLD:AAA4494           20
3 GBAH3880-08 EU726627   856411   EU726627          Mined from GenBank, NCBI BOLD:AAA4494           20
4 GBAH3888-08 EU726619   856419   EU726619          Mined from GenBank, NCBI BOLD:AAA4494           20
5 GBAH3904-08 EU726603   856435   EU726603          Mined from GenBank, NCBI BOLD:AAA4494           20
6 GBAH3909-08 EU726598   856440   EU726598          Mined from GenBank, NCBI BOLD:AAA4494           20
```


### Search for specimen plus sequence data

By default you download `tsv` format data, which is given back to you as a `data.frame`

```coffee
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
```

```coffee
$`GBAH0293-06`
[1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

$`GBAH3879-08`
[1] "---------------------------------------ATTCTATATATAATTTTTGCTTTATGATCTGGAATAATTGGATCAGCAATA---AGAATTATTATTCGAATAGAATTAAGTATCCCAGGATCATGAATTTCTAAT---GATCAAATTTATAATTCTTTAGTAACTGGTCATGCCTTTTTAATAATTTTTTTTCTTGTCATACCATTTTTAATTGGAGGATTTGGAAATTGATTAATTCCATTAATA---TTAGGAATTCCAGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCACCATCCTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGACCTGGAACAGGATGAACAATTTATCCACCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTA---GCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAACATTTCCTTAAAATATATTCAATTATCCTTATTTCCTTGATCTGTATTTATTACTACTATTCTTTTACTTTTTTCTTTACCTGTATTAGCTGGA---GCAATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGTGGAGATCCAATTCTTTATCAACATTTA------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```

Or you can index to a specific sequence like

```coffee
res$fasta['GBAH0293-06']
```

```coffee
$`GBAH0293-06`
[1] "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TTAATGTTAGGGATTCCAGATATAGCTTTTCCACGAATAAATAATATTAGATTTTGACTGTTACCTCCATCTTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGTCCTGGAACAGGATGAACAGTTTATCCTCCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAGTTGATTTAGCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAATATTTCTTTAAAATATATTCAATTACCTTTATTTTCTTGATCTGTATTTATTACTACTATTCTTTTATTATTTTCTTTACCTGTATTAGCTGGAGCTATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGGGGAGATCCAATTCTTTATCAACATTTATTTTGATTTTTTGGTCATCCTGAAGTTTATATTTTAATTTTACCTGGATTTGGATTAATTTCTCAAATTATTTCTAATGAAAGAGGAAAAAAAGAAACTTTTGGAAATATTGGTATAATTTATGCTATATTAAGAATTGGACTTTTAGGTTTTATTGTT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
```


### Get trace files

This function downloads files to your machine - it does not load them into your R session - but prints out where the files are for your information.

```coffee
bold_trace(taxon='Osmia', quiet=TRUE)
```

```
Trace file extracted with files:

/Users/sacmac/bold_trace_files/ACRJP618-11[LepF1,LepR1]_F.ab1
/Users/sacmac/bold_trace_files/ACRJP619-11[LepF1,LepR1]_F.ab1
/Users/sacmac/bold_trace_files/ACRJP619-11[LepF1,LepR1]_R.ab1
/Users/sacmac/bold_trace_files/HMBCH056-07_F.ab1
/Users/sacmac/bold_trace_files/HMBCH056-07_R.ab1
/Users/sacmac/bold_trace_files/HMBCH063-07_F.ab1
/Users/sacmac/bold_trace_files/HMBCH063-07_R.ab1
/Users/sacmac/bold_trace_files/Osm_aur_T505_LCOHym_D04_008_copy.ab1
/Users/sacmac/bold_trace_files/Osm_aur_T505_NancyFull_D10_008_copy.ab1
/Users/sacmac/bold_trace_files/Osm_ruf_T309_LCOHym_C06_006_copy.ab1
/Users/sacmac/bold_trace_files/Osm_ruf_T309_Nancy_C06_006_copy.ab1
/Users/sacmac/bold_trace_files/TRACE_FILE_INFO.txt
```



[Please report any issues or bugs](https://github.com/ropensci/bold/issues).

License: MIT

This package is part of the [rOpenSci](http://ropensci.org/packages) project.

```coffee
To cite package ‘bold’ in publications use:

  Scott Chamberlain (2014). bold: Interface to Bold Systems API methods. R package version 0.0.9. https://github.com/ropensci/bold

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {bold: Interface to Bold Systems API methods},
    author = {Scott Chamberlain},
    year = {2014},
    note = {R package version 0.0.9},
    url = {https://github.com/ropensci/bold},
  }

```

Get citation information for `bold` in R doing `citation(package = 'bold')`

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
