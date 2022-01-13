.DEFAULT_GOAL := chamal.analizer.hfst

# generate analizer and generator
chamal.analizer.hfst: chamal.generator.hfst
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
