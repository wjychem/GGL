#!/bin/bash

export wd=$(pwd)/../

###WJY
for file in `ls ${wd}/Data`
	do
	cd ${wd}
	export nstart=1
	export nend=40 ### 20 to 30 suffices
	cp -r LG_bak LG
#	cp ${wd}/Data/${file} ${wd}/LG/
        cp ${wd}/Data/${file} ${wd}/LG/gene_coeffe.csv
#	sed -i 's/-dim 3/-dim 2/g' ${wd}/train_script/*-train-hic.sh
#	sed -i 's/-train_threads 1/-train_threads 32/g' ${wd}/train_script/*-train-hic.sh
	###EOF WJY
	while [ $nstart -le $nend ]; do
	
		cd ${wd}/LG/
		python stochastic_graph.py  ### yield random_graph
		echo "Graph Sampling done."
		
		cd ${wd}/train_script
		
		if [ $nstart -eq 1 ]; then
		./first-train-hic.sh
		else
		./restart-train-hic.sh ${nstart}
		fi
		
		mv ${wd}/keys.txt ${wd}/LG/keys.$[$nstart -1].txt
		mv ${wd}/pe.coors.txt ${wd}/LG/pe.coors.$[$nstart -1].txt
		
		export nstart=$[ $nstart + 1 ]
	done
	###WJY
	cd ${wd}
	echo 'loss' >>trainstate.txt
	cat test.log |grep -Po '(?<="loss": ).*(?=, "sqnorm_min":)'|tee -a trainstate.txt
	echo 'mean_rank' >>trainstate.txt
	cat test.log |grep -Po '(?<="mean_rank": ).*(?=, "map_rank":)'|tee -a trainstate.txt
	echo 'map_rank' >>trainstate.txt
	cat test.log |grep -Po '(?<="map_rank": ).*(?=})'|tee -a trainstate.txt
	mv trainstate.txt test.log LG
	mv LG hic/${file%.*}
done
###EOF WJY
