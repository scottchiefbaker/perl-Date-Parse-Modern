# How to do a new release of a module

### Start clean
`make clean`

### Generate the Makefile again
`perl Makefile.PL`

### Run the tests 
`make test`

### Run the tests faster
`prove -lv t/0*`

### Compare our results with Date::Parse for a sanity check
`perl compare.pl`

### Run a benchmark to compare our speed to `Date::Parse`
`perl compare.pl --bench`

### Run a test on a specific string to see how we parse it
`perl compare.pl --string '1980-08-08' --debug`

### Regenerate the `README.md` from the POD documentation
`pod2markdown lib/Date/Parse/Modern.pm > README.md`

### Make the .tar.gz
`make tardist`

### Upload .tar.gz to PAUSE
https://pause.cpan.org/pause/authenquery
