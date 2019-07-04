extends Node

#class_name Score_Sort

func sort_by_score(a, b):
	if a.score < b.score:
		return a < b
	else:
		return b < a