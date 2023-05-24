.DEFAULT_GOAL := cji.analyzer.hfst

# join all lexd files
cji.lexd: $(wildcard cji.*.lexd)
	cat cji.*.lexd > cji.lexd

# make twol transducer
cji.twol.hfst: cji.twol
	hfst-twolc $< -o $@

# generate generator
cji.generator.hfst: cji.lexd cji.twol.hfst
	lexd $< | hfst-txt2fst -o cji_.generator.hfst
	hfst-compose-intersect cji_.generator.hfst cji.twol.hfst -o $@

# test generator
test.pass.txt: tests.csv
	awk -F, '$$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
check: cji.generator.hfst test.pass.txt
	bash compare.sh $< test.pass.txt

# generate analyzer
cji.analyzer.hfst: check
	rm test.*
	hfst-invert cji.generator.hfst -o $@

# generate transliterator
cy2la.transliterator.hfst: correspondence.hfst
	hfst-repeat -f 1 $< -o $@
correspondence.hfst: correspondence
	hfst-strings2fst -j correspondence -o $@

# combine analyzer and generator with transliteratior
cji.analyzer.tr.hfst: cji.generator.tr.hfst
	hfst-invert $< -o $@
cji.generator.tr.hfst: cji.generator.hfst cy2la.transliterator.hfst
	hfst-compose $^ -o $@
	rm correspondence.hfst
	rm cy2la.transliterator.hfst

# remove created files
clean:
	rm *.hfst *.txt *.mchar *.res cji.lexd


