<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{bold vignette}
-->

`bold` is an R package to connect to BOLD Systems \url{http://www.boldsystems.org/} via their API. Functions in `bold` let you search for sequence data, specimen data, sequence + specimen data, and download raw trace files.

### bold info

+ [BOLD home page](http://boldsystems.org/)
+ [BOLD API docs](boldsystems.org/index.php/resources/api)

### Using bold

**Install**

Install `bold` from CRAN



```r
install.packages("bold")
```

Or install the development version from GitHub


```r
devtools::install_github("ropensci/bold")
```

Load the package


```r
library("bold")
```


### Search for taxonomic names via names

`bold_tax_name` searches for names with names.


```r
bold_tax_name(name='Diplura')
```

```
##      name taxonrep  taxid   taxon tax_rank tax_division parentid
## 1 Diplura  Diplura 591238 Diplura    order      Animals       82
## 2 Diplura     <NA> 603673 Diplura    genus     Protists    53974
##         parentname
## 1          Insecta
## 2 Scytosiphonaceae
```


```r
bold_tax_name(name=c('Diplura','Osmia'))
```

```
##      name taxonrep  taxid   taxon tax_rank tax_division parentid
## 1 Diplura  Diplura 591238 Diplura    order      Animals       82
## 2   Osmia     <NA> 603673 Diplura    genus     Protists    53974
## 3 Diplura    Osmia   4940   Osmia    genus      Animals     4962
## 4   Osmia    Osmia   4940   Osmia    genus      Animals     4962
##         parentname
## 1          Insecta
## 2 Scytosiphonaceae
## 3     Megachilinae
## 4     Megachilinae
```


### Search for taxonomic names via BOLD identifiers

`bold_tax_id` searches for names with BOLD identifiers.


```r
bold_tax_id(id=88899)
```

```
##      id taxid   taxon tax_rank tax_division parentid parentname
## 1 88899 88899 Momotus    genus      Animals    88898  Momotidae
```


```r
bold_tax_id(id=c(88899,125295))
```

```
##       id  taxid      taxon tax_rank tax_division parentid parentname
## 1  88899  88899    Momotus    genus      Animals    88898  Momotidae
## 2 125295  88899    Momotus    genus      Animals    88898  Momotidae
## 3  88899 125295 Helianthus    genus       Plants   100962 Asteraceae
## 4 125295 125295 Helianthus    genus       Plants   100962 Asteraceae
```


### Search for sequence data only

The BOLD sequence API gives back sequence data, with a bit of metadata.

The default is to get a list back


```r
bold_seq(taxon='Coelioxys')[1:2]
```

```
## [[1]]
## [[1]]$id
## [1] "CNEID3374-12"
## 
## [[1]]$name
## [1] "Coelioxys funeraria"
## 
## [[1]]$gene
## [1] "CNEID3374-12"
## 
## [[1]]$sequence
## [1] "TATAATATATATAATTTTTGCAATATGATCAGGAATAATTGGTTCTTCATTAAGAATAATTATCCGAATAGAATTAAGAATCCCAGGATCTTGAATTAATAATGATCAAATTTATAATTCTTTTATCACAGCTCACGCATTTTTAATAATTTTTTTTTTAGTTATACCTTTTTTAATTGGAGGATTTGGTAATTGATTAGCCCCTTTAATATTAGGAGCCCCTGATATAGCTTTCCCTCGAATAAACAACATTAGATTTTGATTATTACCTCCTTCCTTATTAATACTTTTATCTAGTAATTTAATTACCCCTAGACCAGGGACAGGGTGAACTATTTACCCTCCATTATCTTTATATAATTATCANCCTTCTCCATCTGTTGATTTAGCAATTTTTTCTTTACATTTATCAGGAATTTCCTCTATTATTGGATCAATAAATTTCATTGTAACAATTTTAATAATAAAAAATTTTTCAATAAATTACAATCAAATACCTTTATTTCCATGATCAATTCTAATTACTACAATTTTATTATTATTATCATTACCTGTATTAGCAGGAGCAATTACAATATTATTATTTGATCGTAATTTAAATTCTTCATTTTTTGATCCAATAGGAGGAGGAGA---------"
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
## [1] "Wed, 06 Aug 2014 22:14:55 GMT"
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
## attr(,"class")
## [1] "insensitive" "list"
```

You can do geographic searches


```r
bold_seq(geo = "USA")
```

```
## [[1]]
## [[1]]$id
## [1] "NEONV108-11"
## 
## [[1]]$name
## [1] "Aedes thelcter"
## 
## [[1]]$gene
## [1] "NEONV108-11"
## 
## [[1]]$sequence
## [1] "AACTTTATACTTCATCTTCGGAGTTTGATCAGGAATAGTTGGTACATCATTAAGAATTTTAATTCGTGCTGAATTAAGTCAACCAGGTATATTTATTGGAAATGACCAAATTTATAATGTAATTGTTACAGCTCATGCTTTTATTATAATTTTCTTTATAGTTATACCTATTATAATTGGAGGATTTGGAAATTGACTAGTTCCTCTAATATTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAATAATATAAGTTTTTGAATACTACCTCCCTCATTAACTCTTCTACTTTCAAGTAGTATAGTAGAAAATGGATCAGGAACAGGATGAACAGTTTATCCACCTCTTTCATCTGGAACTGCTCATGCAGGAGCCTCTGTTGATTTAACTATTTTTTCTCTTCATTTAGCCGGAGTTTCATCAATTTTAGGGGCTGTAAATTTTATTACTACTGTAATTAATATACGATCTGCAGGAATTACTCTTGATCGACTACCTTTATTCGTTTGATCTGTAGTAATTACAGCTGTTTTATTACTTCTTTCACTTCCTGTATTAGCTGGAGCTATTACAATACTATTAACTGATCGAAATTTAAATACATCTTTCTTTGATCCAATTGGAGGAGGAGACCCAATTTTATACCAACATTTATTT"
## 
## 
## [[2]]
## [[2]]$id
## [1] "NEONV109-11"
## 
## [[2]]$name
## [1] "Aedes thelcter"
## 
## [[2]]$gene
## [1] "NEONV109-11"
## 
## [[2]]$sequence
## [1] "AACTTTATACTTCATCTTCGGAGTTTGATCAGGAATAGTTGGTACATCATTAAGAATTTTAATTCGTGCTGAATTAAGTCAACCAGGTATATTTATTGGAAATGACCAAATTTATAATGTAATTGTTACAGCTCATGCTTTTATTATAATTTTCTTTATAGTTATACCTATTATAATTGGAGGATTTGGAAATTGACTAGTTCCTCTAATATTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAATAATATAAGTTTTTGAATACTACCTCCCTCATTAACTCTTCTACTTTCAAGTAGTATAGTAGAAAATGGGTCAGGAACAGGATGAACAGTTTATCCACCTCTTTCATCTGGAACTGCTCATGCAGGAGCCTCTGTTGATTTAACTATTTTTTCTCTTCATTTAGCCGGAGTTTCATCAATTTTAGGGGCTGTAAATTTTATTACTACTGTAATTAATATACGATCTGCAGGAATTACTCTTGATCGACTACCTTTATTCGTTTGATCTGTAGTAATTACAGCTGTTTTATTACTTCTTTCACTTCCTGTATTAGCTGGAGCTATTACAATACTATTAACTGATCGAAATTTAAATACATCTTTCTTTGACCCAATTGGAGGGGGAGACCCAATTTTATACCAACATTTATTT"
```

And you can search by researcher name


```r
bold_seq(researchers='Thibaud Decaens')[[1]]
```

```
## $id
## [1] "AMAZ039-09"
## 
## $name
## [1] "Automeris liberia"
## 
## $gene
## [1] "AMAZ039-09"
## 
## $sequence
## [1] "AACTTTATACTTTATTTTTGGAATTTGAGCAGGAATAGTAGGAACTTCTTTAAGATTGCTAATTCGTGCTGAATTAGGTACCCCCAGATCTTTAATTGGAGATGACCAAATTTATAATACTATTGTCACAGCCCATGCCTTCATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGAAATTGACTAGTTCCTTTAATATTAGGAGCCCCAGATATAGCCTTCCCCCGAATAAATAATATAAGATTTTGACTACTCCCCCCCTCTTTAACTCTTTTAATTTCAAGAAGAATTGTAGAAAATGGTGCCGGTACCGGCTGAACCGTTTACCCCCCTCTTTCTTCTAATATTGCTCACGGAGGATCTTCAGTTGATTTAGCTATTTTTTCCTTACATTTAGCTGGAATTTCCTCAATCTTAGGAGCTATTAATTTTATTACAACAATTATTAATATACGTTTAAATAATATATCTTTTGATCAAATACCTCTATTTGTTTGAGCTGTTGGAATTACAGCATTTTTACTTCTTCTTTCATTACCTGTTTTAGCTGGAGCTATTACTATACTATTAACAGATCGTAATTTAAATACCTCTTTTTTTGACCCTGCTGGAGGGGGAGACCCTATCTTATATCAACATTTATTT"
```

by taxon IDs


```r
bold_seq(ids=c('ACRJP618-11','ACRJP619-11'))
```

```
## [[1]]
## [[1]]$id
## [1] "ACRJP618-11"
## 
## [[1]]$name
## [1] "Lepidoptera"
## 
## [[1]]$gene
## [1] "ACRJP618-11"
## 
## [[1]]$sequence
## [1] "------------------------TTGAGCAGGCATAGTAGGAACTTCTCTTAGTCTTATTATTCGAACAGAATTAGGAAATCCAGGATTTTTAATTGGAGATGATCAAATCTACAATACTATTGTTACGGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGTAATTGATTAGTTCCCCTTATACTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAACAATATAAGTTTTTGGCTTCTTCCCCCTTCACTATTACTTTTAATTTCCAGAAGAATTGTTGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCACTGTCATCTAATATTGCCCATAGAGGTACATCAGTAGATTTAGCTATTTTTTCTTTACATTTAGCAGGTATTTCCTCTATTTTAGGAGCGATTAATTTTATTACTACAATTATTAATATACGAATTAACAGTATAAATTATGATCAAATACCACTATTTGTGTGATCAGTAGGAATTACTGCTTTACTCTTATTACTTTCTCTTCCAGTATTAGCAGGTGCTATCACTATATTATTAACGGATCGAAATTTAAATACATCATTTTTTGATCCTGCAGGAGGAGGAGATCCAATTTTATATCAACATTTATTT"
## 
## 
## [[2]]
## [[2]]$id
## [1] "ACRJP619-11"
## 
## [[2]]$name
## [1] "Lepidoptera"
## 
## [[2]]$gene
## [1] "ACRJP619-11"
## 
## [[2]]$sequence
## [1] "AACTTTATATTTTATTTTTGGTATTTGAGCAGGCATAGTAGGAACTTCTCTTAGTCTTATTATTCGAACAGAATTAGGAAATCCAGGATTTTTAATTGGAGATGATCAAATCTACAATACTATTGTTACGGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGTAATTGATTAGTTCCCCTTATACTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAACAATATAAGTTTTTGGCTTCTTCCCCCTTCACTATTACTTTTAATTTCCAGAAGAATTGTTGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCACTGTCATCTAATATTGCCCATAGAGGTACATCAGTAGATTTAGCTATTTTTTCTTTACATTTAGCAGGTATTTCCTCTATTTTAGGAGCGATTAATTTTATTACTACAATTATTAATATACGAATTAACAGTATAAATTATGATCAAATACCACTATTTGTGTGATCAGTAGGAATTACTGCTTTACTCTTATTACTTTCTCTTCCAGTATTAGCAGGTGCTATCACTATATTATTAACGGATCGAAATTTAAATACATCATTTTTTGATCCTGCAGGAGGAGGAGATCCAATTTTATATCAACATTTATTT"
```

by container (containers include project codes and dataset codes)


```r
bold_seq(container='ACRJP')[[1]]
```

```
## $id
## [1] "ACRJP021-09"
## 
## $name
## [1] "Lepidoptera"
## 
## $gene
## [1] "ACRJP021-09"
## 
## $sequence
## [1] "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------TAAGATTTTGACTCCTCCCCCCCTCCTTAATTTTACTAATTTCTAGTAGTATTGTAGAAAATGGAACTGGTACTGGATGAACAGTTTATCCCCCTTTATCCTCTAACACAGCTCATAGTGGAGCCTCAGTTGATTTAACTATTTTTTCCCTTCATTTAGCAGGCATTTCTTCTATTTTAGGAGCTATTAATTTCATTACTACAATTATTAATATACGATTAAATAGTCTATCATTTGATAAAATACCTTTATTTGTTTGGGCAGTAGGAATTACAGCCCTATTATTACTTTTATCTTTACCAGTCTTAGCTGGAGCTATTACTATATTATTAACTGATCGTAATTTAAACACTTCATTTTTTGACCCTGCAGGAGGTGGTGACCCTATTCTCTACCAACATTTATTT"
```

by bin (a bin is a _Barcode Index Number_)


```r
bold_seq(bin='BOLD:AAA5125')[[1]]
```

```
## $id
## [1] "BLPAB406-06"
## 
## $name
## [1] "Eacles ormondei"
## 
## $gene
## [1] "BLPAB406-06"
## 
## $sequence
## [1] "AACTTTATATTTTATTTTTGGAATTTGAGCAGGTATAGTAGGAACTTCTTTAAGATTACTAATTCGAGCAGAATTAGGTACCCCCGGATCTTTAATTGGAGATGACCAAATTTATAATACCATTGTAACAGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGAAATTGATTAGTACCCCTAATACTAGGAGCTCCTGATATAGCTTTCCCCCGAATAAATAATATAAGATTTTGACTATTACCCCCATCTTTAACTCTTTTAATTTCTAGAAGAATTGTCGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCCCTTTCATCTAATATTGCTCATGGAGGCTCTTCTGTTGATTTAGCTATTTTTTCCCTTCATCTAGCTGGAATCTCATCAATTTTAGGAGCTATTAATTTTATCACAACAATCATTAATATACGACTAAATAATATAATATTTGACCAAATACCTTTATTTGTATGAGCTGTTGGTATTACAGCATTTCTTTTATTGTTATCTTTACCTGTACTAGCTGGAGCTATTACTATACTTTTAACAGATCGAAACTTAAATACATCATTTTTTGACCCAGCAGGAGGAGGAGATCCTATTCTCTATCAACATTTATTT"
```

And there are more ways to query, check out the docs for `?bold_seq`.


### Search for specimen data only

The BOLD specimen API doesn't give back sequences, only specimen data. By default you download `tsv` format data, which is given back to you as a `data.frame`


```r
res <- bold_specimens(taxon='Osmia')
head(res[,1:8])
```

```
##     processid sampleid recordID catalognum fieldnum
## 1 GBAH3890-08 EU726617   856421   EU726617         
## 2 GBAH3894-08 EU726613   856425   EU726613         
## 3 GBAH3898-08 EU726609   856429   EU726609         
## 4 GBAH3899-08 EU726608   856430   EU726608         
## 5 GBAH3900-08 EU726607   856431   EU726607         
## 6 GBAH3902-08 EU726605   856433   EU726605         
##        institution_storing      bin_uri phylum_taxID
## 1 Mined from GenBank, NCBI BOLD:AAA4494           20
## 2 Mined from GenBank, NCBI BOLD:AAA4494           20
## 3 Mined from GenBank, NCBI BOLD:AAA4494           20
## 4 Mined from GenBank, NCBI BOLD:AAA4494           20
## 5 Mined from GenBank, NCBI BOLD:AAA4494           20
## 6 Mined from GenBank, NCBI BOLD:AAA4494           20
```

You can optionally get back the data in `XML` format


```r
bold_specimens(taxon='Osmia', format='xml')
```


```r
<?xml version="1.0" encoding="UTF-8"?>
<bold_records  xsi:noNamespaceSchemaLocation="http://www.boldsystems.org/schemas/BOLDPublic_record.xsd"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <record>
    <record_id>1470124</record_id>
    <processid>BOM1525-10</processid>
    <bin_uri>BOLD:AAN3337</bin_uri>
    <specimen_identifiers>
      <sampleid>DHB 1011</sampleid>
      <catalognum>DHB 1011</catalognum>
      <fieldnum>DHB1011</fieldnum>
      <institution_storing>Marjorie Barrick Museum</institution_storing>
    </specimen_identifiers>
    <taxonomy>
```

You can choose to get the `httr` response object back if you'd rather work with the raw data returned from the BOLD API.


```r
res <- bold_specimens(taxon='Osmia', format='xml', response=TRUE)
res$url
```

```
## [1] "http://www.boldsystems.org/index.php/API_Public/specimen?taxon=Osmia&specimen_download=xml"
```

```r
res$status_code
```

```
## [1] 200
```

```r
res$headers
```

```
## $date
## [1] "Wed, 06 Aug 2014 22:15:33 GMT"
## 
## $server
## [1] "Apache/2.2.15 (Red Hat)"
## 
## $`x-powered-by`
## [1] "PHP/5.3.15"
## 
## $`content-disposition`
## [1] "attachment; filename=bold_data.xml"
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
## attr(,"class")
## [1] "insensitive" "list"
```

### Search for specimen plus sequence data

The specimen/sequence combined API gives back specimen and sequence data. Like the specimen API, this one gives by default `tsv` format data, which is given back to you as a `data.frame`. Here, we're setting `sepfasta=TRUE` so that the sequence data is given back as a list, and taken out of the `data.frame` returned so the `data.frame` is more manageable.


```r
res <- bold_seqspec(taxon='Osmia', sepfasta=TRUE)
res$fasta[1:2]
```

```
## $`GBAH3890-08`
## [1] "---------------------------------------ATTCTATATATAATTTTTGCTTTATGATCTGGAATAATTGGATCAGCAATA---AGAATTATTATTCGAATAGAATTAAGTATCCCAGGATCATGAATTTCTAAT---GATCAAATTTATAATTCTTTAGTAACTGCTCATGCCTTTTTAATAATTTTTTTTCTTGTCATACCATTTTTAATTGGAGGATTTGGAAATTGATTAATTCCATTAATA---TTAGGAATTCCAGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCACCATCCTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGACCTGGAACAGGATGAACAATTTATCCACCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAATTGATTTA---GCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAACATTTCCTTAAAATATATTCAATTATCCTTATTTCCTTGATCTGTATTTATTACTACTATTCTTTTACTTTTTTCTTTACCTGTATTAGCTGGA---GCAATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGTGGAGATCCAATTCTTTATCAACATTTA------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
## 
## $`GBAH3894-08`
## [1] "---------------------------------------ATTCTATATATAATTTTTGCTTTATGATCTGGAATAATTGGATCAGCAATA---AGAATTATTATTCGAATAGAATTAAGTATCCCAGGATCATGAATTTCTAAT---GATCAAATTTATAATTCTTTAGTAACTGCTCATGCCTTTTTAATAATTTTTTTTCTTGTCATACCATTTTTAATTGGAGGATTTGGAAATTGATTAATTCCATTAATA---TTAGGAATTCCAGATATAGCTTTTCCTCGAATAAATAATATTAGATTTTGACTTTTACCACCATCCTTAATATTATTACTTTTAAGAAATTTTTTAAATCCAAGACCTGGAACAGGATGAACAATTTATCCACCTTTATCATCAAATTTATTTCATTCTTCTCCTTCAATTGATTTA---GCAATTTTTTCTTTACATATTTCAGGTTTATCTTCTATTATAGGTTCATTAAATTTTATTGTTACAATTATTATAATAAAAAACATTTCCTTAAAATATATTCAATTATCCTTATTTCCTTGATCTGTATTTATTACTACTATTCTTTTACTTTTTTCTTTACCTGTATTAGCTGGA---GCAATTACTATATTATTATTTGATCGAAATTTTAATACATCTTTTTTTGATCCAACAGGAGGTGGAGATCCAATTCTTTATCAACATTTA------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
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
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/HDBNS084-03~R_1.ab1
## /Users/sacmac/github/ropensci/bold/inst/vign/bold_trace_files/TRACE_FILE_INFO.txt
```
