.DEFAULT_GOAL := chamal.analyzer.tr.hfst

# generate analyzer and generator
chamal.analyzer.hfst: chamal.generator.hfst
	hfst-invert $< -o $@
chamal.generator.hfst: chamal.morphotactics.hfst chamal.twol.hfst
	hfst-compose-intersect $^ -o $@
chamal.morphotactics.hfst: chamal.num.lexd.hfst chamal.morphotactics.twol.hfst
	hfst-invert $< | hfst-compose-intersect - chamal.morphotactics.twol.hfst | hfst-invert -o $@
chamal.num.lexd.hfst: chamal.num.lexd
	lexd $< | hfst-txt2fst -o $@
chamal.twol.hfst: chamal.twol
	hfst-twolc $< -o $@
chamal.morphotactics.twol.hfst: chamal.morphotactics.twol
	hfst-twolc $< -o $@
	
# generate transliterators
cy2la.transliterator.hfst: la2cy.transliterator.hfst
	hfst-invert $< -o $@
la2cy.transliterator.hfst: correspondence.hfst
	hfst-repeat -f 1 $< -o $@
correspondence.hfst: correspondence
	hfst-strings2fst -j correspondence -o $@

# generate analyzer and generator for transcription
chamal.analyzer.tr.hfst: chamal.generator.tr.hfst
	hfst-invert $< -o $@
chamal.generator.tr.hfst: chamal.generator.hfst cy2la.transliterator.hfst
	hfst-compose $^ -o $@
    
# remove all hfst files
clean:
	rm *.hfst
