.DEFAULT_GOAL := cji.analyzer.disam.hfst

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

# generate analyzer
cji.analyzer.hfst: cji.generator.hfst
	hfst-invert $< -o $@

# generate transliterators
cy2la.transliterator.hfst: la2cy.transliterator.hfst
	hfst-invert $< -o $@
la2cy.transliterator.hfst: correspondence.hfst
	hfst-repeat -f 1 $< -o $@
correspondence.hfst: correspondence
	hfst-strings2fst -j correspondence -o $@

# generate analyzer and generator for transcription
cji.analyzer.disam.hfst: cji.generator.disam.hfst
	hfst-invert $< -o $@
cji.generator.disam.hfst: cji.generator.tr.hfst tr.regexp.hfst
	hfst-compose -F -1 $< -2 $(word 2,$^) -o $@
tr.regexp.hfst: transliterator.regexp
	hfst-regexp2fst -o $@ < $<
cji.generator.tr.hfst: cji.generator.hfst cy2la.transliterator.hfst
	hfst-compose $^ -o $@	
	
# test generator
test.pass.txt: tests.csv
	awk -F, '$$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
check: cji.generator.disam.hfst test.pass.txt
	bash compare.sh $< test.pass.txt

# remove created files
clean:
	rm *.hfst *.txt *.mchar *.res cji.lexd


