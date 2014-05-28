all: move rmd2md cleanup

move:
	cp inst/vign/bold_vignette.md vignettes

rmd2md:
	cd vignettes;\
	cp bold_vignette.md bold_vignette.Rmd

cleanup:
	cd vignettes;\
	rm bold_vignette.md
