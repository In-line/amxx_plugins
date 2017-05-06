#if defined _levenshtein_distance_included
	#endinput
#endif
#define _levenshtein_distance_included

#if defined LEVENSHTEIN_BUFFER_SIZE
	#define LEVENSHTEIN_BUFFER_X LEVENSHTEIN_BUFFER_SIZE
	#define LEVENSHTEIN_BUFFER_Y LEVENSHTEIN_BUFFER_SIZE
#endif

#if !defined LEVENSHTEIN_BUFFER_X
	#define LEVENSHTEIN_BUFFER_X 64
#endif

#if !defined LEVENSHTEIN_BUFFER_Y
	#define LEVENSHTEIN_BUFFER_Y 64
#endif

#if !defined LEVENSHTEIN_ALLOC
	#define LEVENSHTEIN_ALLOC static
#endif


static stock __fast_min(const a, const b)
{
	return a < b ? a : b;
}

stock levenshtein_distance(const str1[], const str1_size, const str2[], const str2_size) 
{
	if(str1_size == 0)
		return str1_size;

	if(str2_size == 0)
		return str2_size;

	if(str1_size > LEVENSHTEIN_BUFFER_X - 1 || str2_size > LEVENSHTEIN_BUFFER_Y - 1)
		return -1;
	
	LEVENSHTEIN_ALLOC matrix[LEVENSHTEIN_BUFFER_X][LEVENSHTEIN_BUFFER_Y];
	
	for(new i = 0; i <= str1_size; ++i)
		matrix[i][0] = i;
	
	for(new i = 0; i <= str2_size; ++i)	
		matrix[0][i] = i;

	for(new i = 1; i <= str1_size; ++i)
	{
		for(new j = 1; j <= str2_size; ++j)
		{
			#define above_cell matrix[i - 1][j]
			#define left_cell matrix[i][j - 1]
			#define diagonal_cell matrix[i - 1][j - 1]
			#define cost ((str1[i - 1] == str2[j - 1]) ? 0 : 1)
			
			matrix[i][j] = __fast_min(__fast_min(above_cell + 1, left_cell + 1), diagonal_cell + cost);

			#undef above_cell
			#undef left_cell
			#undef diagonal_cell
			#undef cost
		}
	}
	
	return matrix[str1_size][str2_size];
}
