function gitzip 
	git archive HEAD -o (basename $PWD).zip
end
