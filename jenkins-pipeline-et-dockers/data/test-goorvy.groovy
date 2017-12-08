#!/usr/bin/groovy
/* 
* Test de groovy les boucles et tous
* 
************************/

Toto = "{'x3-webdav','x3-titi'}"

toto_cleanA = Toto.replaceAll('\\{','[')
toto_clean = toto_cleanA.replaceAll('\\}',']')

def lst = Eval.me(toto_clean)

for (String item : lst) {
   System.out.println(item)
}
