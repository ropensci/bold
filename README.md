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
install.packages("devtools")
require(devtools)
devtools::install_github("bold", "ropensci")
library(bold)
```

### Search for specimen data

Default is to get XML data

```coffee
bold_specimens(taxon='Osmia')
```

```coffee
<bold_records xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.boldsystems.org/schemas/BOLD_record.xsd">
<record>
<recordID>516711</recordID>
<processid>CHUBE002-06</processid>
<specimen_identifiers>
<sampleid>CHU05-BEE-002</sampleid>
<catalognum>CHU05-BEE-002</catalognum>
<fieldnum>CHU05-BEE-002</fieldnum>
<institution_storing>
University of Manitoba, J. B. Wallis Museum of Entomology
</institution_storing>
</specimen_identifiers>
<taxonomy>
<phylum>
<taxon>
<taxID>20</taxID>
<name>Arthropoda</name>
</taxon>
</phylum>

...
```

But you can optionally get back tsv data, which is given back to you as a `data.frame`

```coffee
res <- bold_specimens(taxon='Osmia', format = 'tsv')
head(res[,1:8])
```

```coffee
    processid sampleid recordID catalognum fieldnum      institution_storing      bin_uri homedb
1 GBAH3885-08 EU726622   856416   EU726622          Mined from GenBank, NCBI BOLD:AAA4494   ncbi
2 GBAH3891-08 EU726616   856422   EU726616          Mined from GenBank, NCBI BOLD:AAA4494   ncbi
3 GBAH3895-08 EU726612   856426   EU726612          Mined from GenBank, NCBI BOLD:AAA4494   ncbi
4 GBAH3898-08 EU726609   856429   EU726609          Mined from GenBank, NCBI BOLD:AAA4494   ncbi
5 GBAH3903-08 EU726604   856434   EU726604          Mined from GenBank, NCBI BOLD:AAA4494   ncbi
6 GBAH3910-08 EU726597   856441   EU726597          Mined from GenBank, NCBI BOLD:AAA4494   ncbi
```

### Search for sequence data

Search for the bee genus _Coelioxys_, and take first two results.

```coffee
bold_seq(taxon='Coelioxys')[1:2]
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
[1] "GBMIN26400-13"

[[2]]$name
[1] "Coelioxys sp. HMG-2011"

[[2]]$gene
[1] "GBMIN26400-13"

[[2]]$sequence
[1] "CGAATAAATAATATTAGATTTTGATTATTACCCCCATCACTATTATTACTTCTATTAAGTAATTTGATTAAACCAAGACCAGGTACAGGATGAACCGTATACCCTCCCTTATCTTTATATCTTTATCACCCTTCACCATCAGTTGATTTTGCAATTTTTTCTTTACACTTATCAGGAATTTCATCTATTATTGGTTCATTAAATTTTATTGTAACAATTTTAATAATAAAAAATTGATCTTTAAATTATAGACAAATATCATTATTTCCTTGATCAATTTTTATTACTACAATTTTATTATTA"
```

Search for two BOLD sequence IDs.

```coffee
bold_seq(ids=c('ACRJP618-11','ACRJP619-11'))
```

```coffee
[[1]]
[[1]]$id
[1] "ACRJP618-11"

[[1]]$name
[1] "Lepidoptera"

[[1]]$gene
[1] "ACRJP618-11"

[[1]]$sequence
[1] "------------------------TTGAGCAGGCATAGTAGGAACTTCTCTTAGTCTTATTATTCGAACAGAATTAGGAAATCCAGGATTTTTAATTGGAGATGATCAAATCTACAATACTATTGTTACGGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGTAATTGATTAGTTCCCCTTATACTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAACAATATAAGTTTTTGGCTTCTTCCCCCTTCACTATTACTTTTAATTTCCAGAAGAATTGTTGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCACTGTCATCTAATATTGCCCATAGAGGTACATCAGTAGATTTAGCTATTTTTTCTTTACATTTAGCAGGTATTTCCTCTATTTTAGGAGCGATTAATTTTATTACTACAATTATTAATATACGAATTAACAGTATAAATTATGATCAAATACCACTATTTGTGTGATCAGTAGGAATTACTGCTTTACTCTTATTACTTTCTCTTCCAGTATTAGCAGGTGCTATCACTATATTATTAACGGATCGAAATTTAAATACATCATTTTTTGATCCTGCAGGAGGAGGAGATCCAATTTTATATCAACATTTATTT"


[[2]]
[[2]]$id
[1] "ACRJP619-11"

[[2]]$name
[1] "Lepidoptera"

[[2]]$gene
[1] "ACRJP619-11"

[[2]]$sequence
[1] "AACTTTATATTTTATTTTTGGTATTTGAGCAGGCATAGTAGGAACTTCTCTTAGTCTTATTATTCGAACAGAATTAGGAAATCCAGGATTTTTAATTGGAGATGATCAAATCTACAATACTATTGTTACGGCTCATGCTTTTATTATAATTTTTTTTATAGTTATACCTATTATAATTGGAGGATTTGGTAATTGATTAGTTCCCCTTATACTAGGAGCCCCAGATATAGCTTTCCCTCGAATAAACAATATAAGTTTTTGGCTTCTTCCCCCTTCACTATTACTTTTAATTTCCAGAAGAATTGTTGAAAATGGAGCTGGAACTGGATGAACAGTTTATCCCCCACTGTCATCTAATATTGCCCATAGAGGTACATCAGTAGATTTAGCTATTTTTTCTTTACATTTAGCAGGTATTTCCTCTATTTTAGGAGCGATTAATTTTATTACTACAATTATTAATATACGAATTAACAGTATAAATTATGATCAAATACCACTATTTGTGTGATCAGTAGGAATTACTGCTTTACTCTTATTACTTTCTCTTCCAGTATTAGCAGGTGCTATCACTATATTATTAACGGATCGAAATTTAAATACATCATTTTTTGATCCTGCAGGAGGAGGAGATCCAATTTTATATCAACATTTATTT"
```


[Please report any issues or bugs](https://github.com/ropensci/bold/issues).

License: MIT

This package is part of the [rOpenSci](http://ropensci.org/packages) project.

```coffee
To cite package ‘bold’ in publications use:

  Scott Chamberlain (2014). bold: Interface to Bold Systems API methods. R package version 0.0.8. https://github.com/ropensci/bold

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {bold: Interface to Bold Systems API methods},
    author = {Scott Chamberlain},
    year = {2014},
    note = {R package version 0.0.8},
    url = {https://github.com/ropensci/bold},
  }

```

Get citation information for `bold` in R doing `citation(package = 'bold')`

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
