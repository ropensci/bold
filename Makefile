all: move rmd2md

move:
	cp inst/vign/bold_vignette.md vignettes

rmd2md:
	cd vignettes;\
	mv bold_vignette.md bold_vignette.Rmd
