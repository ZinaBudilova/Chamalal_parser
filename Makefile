.DEFAULT_GOAL := chamalal.analyzer.tr.hfst

# generate num analyzer and generator
num.analyzer.hfst: num.generator.hfst
	hfst-invert $< -o $@
num.generator.hfst: num.morphotactics.hfst chamalal.twol.hfst
	hfst-compose-intersect $^ -o $@
num.morphotactics.hfst: num.lexd.hfst chamalal.morphotactics.twol.hfst
	hfst-invert $< | hfst-compose-intersect - chamalal.morphotactics.twol.hfst | hfst-invert -o $@
num.lexd.hfst: chamalal.num.lexd
	lexd $< | hfst-txt2fst -o $@
chamalal.twol.hfst: chamalal.twol
	hfst-twolc $< -o $@
chamalal.morphotactics.twol.hfst: chamalal.morphotactics.twol
	hfst-twolc $< -o $@
	
# generate noun analyzer and generator
noun.analyzer.hfst: noun.generator.hfst
	hfst-invert $< -o $@
noun.generator.hfst: noun.morphotactics.hfst chamalal.twol.hfst
	hfst-compose-intersect $^ -o $@
noun.morphotactics.hfst: noun.lexd.hfst chamalal.morphotactics.twol.hfst
	hfst-invert $< | hfst-compose-intersect - chamalal.morphotactics.twol.hfst | hfst-invert -o $@
noun.lexd.hfst: chamalal.noun.lexd
	lexd $< | hfst-txt2fst -o $@

# unite pos generators	
chamalal.generator.hfst: noun.generator.hfst num.generator.hfst
	hfst-disjunct $^ -o $@
	
# generate transliterators
cy2la.transliterator.hfst: la2cy.transliterator.hfst
	hfst-invert $< -o $@
la2cy.transliterator.hfst: correspondence.hfst
	hfst-repeat -f 1 $< -o $@
correspondence.hfst: correspondence
	hfst-strings2fst -j correspondence -o $@

# generate analyzer and generator for transcription
chamalal.analyzer.tr.hfst: chamalal.generator.tr.hfst
	hfst-invert $< -o $@
chamalal.generator.tr.hfst: chamalal.generator.hfst cy2la.transliterator.hfst
	hfst-compose $^ -o $@
    
# remove all hfst files
clean:
	rm *.hfst
