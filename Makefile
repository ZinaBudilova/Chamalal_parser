.DEFAULT_GOAL := cji.analyzer.disam.hfst

# generate num analyzer and generator
num.analyzer.hfst: num.generator.hfst
	hfst-invert $< -o $@
num.generator.hfst: num.lexd.hfst cji.twol.hfst
	hfst-compose-intersect $^ -o $@
num.lexd.hfst: cji.num.lexd
	lexd $< | hfst-txt2fst -o $@
cji.twol.hfst: cji.twol
	hfst-twolc $< -o $@
cji.morphotactics.twol.hfst: cji.morphotactics.twol
	hfst-twolc $< -o $@
	
# generate noun analyzer and generator
noun.analyzer.hfst: noun.generator.hfst
	hfst-invert $< -o $@
noun.generator.hfst: noun.lexd.hfst cji.twol.hfst
	hfst-compose-intersect $^ -o $@
noun.lexd.hfst: cji.noun.lexd
	lexd $< | hfst-txt2fst -o $@

# unite pos generators	and analyzers
cji.generator.hfst: noun.generator.hfst num.generator.hfst
	hfst-disjunct $^ -o $@
cji.analyzer.hfst: noun.analyzer.hfst num.analyzer.hfst
	hfst-disjunct $^ -o $@
	
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
     
# generate tests
test.pass.txt: tests.csv
	awk -F, '$$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
check: cji.generator.disam.hfst test.pass.txt
	bash compare.sh $< test.pass.txt

# remove all hfst files
clean:
	rm *.hfst *.res *.mchar *.txt
