function CSR_create_level_sets(A_csr)
{
  // assume the column array is sorted by ascending order per row
  var nz = A_csr.nnz;
  var N = A_csr.nrows;

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, N + 1);
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, nz);

  // allocate level per row array
  var level_per_row = new Int32Array(N);

  var max_level = 0;
  for(var i = 0; i < N; i++){
    // check if there is only 1 element in row i (which is the diagonal element in lower-triangular matrix) 
    if(csr_row[i+1] - csr_row[i] == 1)
      // if yes, assign row i to level 0
      level_per_row[i] = 0;
    else{
      /* otherwise, assign row i to one level higher 
       * than the row number corresponding to the maximum level 
       * among the non-zero column value of row i */
      var max_level_per_row = 0;
      for(var j = csr_row[i]; j < csr_row[i+1] - 1; j++){
        if(level_per_row[csr_col[j]] > max_level_per_row)
          max_level_per_row = level_per_row[csr_col[j]];
      }
      level_per_row[i] = 1 + max_level_per_row;
      if(level_per_row[i] > max_level)
        max_level = level_per_row[i];
    }
  }
  // total number of levels
  var tot_levels = max_level + 1;
  A_csr.nlevels = tot_levels;

  // calculate number of rows at each level
  var freq = new Int32Array(tot_levels);
  freq.fill(0);
  for(var i = 0; i < N; i++){
    freq[level_per_row[i]]++;
  }

  // allocate level pointer array
  A_csr.level_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (tot_levels + 1));
  var level = new Int32Array(memory.buffer, A_csr.level_index, tot_levels + 1);

  // calculate the starting index of each level if the rows are sorted by levels
  var starting_index = new Int32Array(tot_levels);
  starting_index[0] = level[0] = 0;
  for(var i = 1; i < tot_levels; i++){
    starting_index[i] = level[i] = level[i-1] + freq[i-1];
  }
  level[i] = level[i-1] + freq[i-1];


  // allocate permutation array
  A_csr.permutation_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var permutation = new Int32Array(memory.buffer, A_csr.permutation_index, N);
  // calculate the permutation of rows if the rows are sorted by levels
  for(var i = 0; i < N; i++){
    permutation[starting_index[level_per_row[i]]] = i;
    starting_index[level_per_row[i]]++;
  }
}


function CSR_create_level_sets_with_reorder(A_csr)
{
  // assume the column array is sorted by ascending order per row
  var nz = A_csr.nnz; 
  var N = A_csr.nrows;

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, N + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, nz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, nz);
	
  // new CSR    
  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (N + 1));
  var csr_nnz_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * nz);
  var csr_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * nz);
  var A_csr_new = new sswasm_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, N, nz);
  var nnz_per_row = new Int32Array(memory.buffer, A_csr_new.nnz_row_index, N);
  var csr_row_new = new Int32Array(memory.buffer, A_csr_new.row_index, A_csr_new.nrows + 1);
  var csr_col_new = new Int32Array(memory.buffer, A_csr_new.col_index, A_csr_new.nnz);
  var csr_val_new = new Float32Array(memory.buffer, A_csr_new.val_index, A_csr_new.nnz);
  csr_row_new.fill(0);
  csr_col_new.fill(0);
  csr_val_new.fill(0);

  // allocate level per row array
  var level_per_row = new Int32Array(N);

  var max_level = 0;
  for(var i = 0; i < N; i++){
    nnz_per_row[i] = csr_row[i+1] - csr_row[i];
    // check if there is only 1 element in row i (which is the diagonal element in lower-triangular matrix) 
    if(nnz_per_row[i] == 1)
      // if yes, assign row i to level 0
      level_per_row[i] = 0;
    else{
      /* otherwise, assign row i to one level higher 
       * than the row number corresponding to the maximum level 
       * among the non-zero column value of row i */
      var max_level_per_row = 0;
      for(var j = csr_row[i]; j < csr_row[i+1] - 1; j++){
        if(level_per_row[csr_col[j]] > max_level_per_row)
	  max_level_per_row = level_per_row[csr_col[j]];
      }
      level_per_row[i] = 1 + max_level_per_row;
      if(level_per_row[i] > max_level)
        max_level = level_per_row[i];
    }
  }
  // total number of levels
  var tot_levels = max_level + 1;
  A_csr_new.nlevels = tot_levels;

  // calculate number of rows at each level
  var freq = new Int32Array(tot_levels);
  freq.fill(0);
  for(var i = 0; i < N; i++){
    freq[level_per_row[i]]++; 
  }

  // allocate level pointer array
  A_csr_new.level_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (tot_levels + 1));
  var level = new Int32Array(memory.buffer, A_csr_new.level_index, tot_levels + 1);

  // calculate the starting index of each level if the rows are sorted by levels
  var starting_index = new Int32Array(tot_levels);
  starting_index[0] = level[0] = 0;
  for(var i = 1; i < tot_levels; i++){
    starting_index[i] = level[i] = level[i-1] + freq[i-1]; 
  }
  level[i] = level[i-1] + freq[i-1]; 


  // allocate permutation array
  A_csr_new.permutation_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var permutation = new Int32Array(memory.buffer, A_csr_new.permutation_index, N);
  // calculate the permutation of rows if the rows are sorted by levels
  for(var i = 0; i < N; i++){
    permutation[starting_index[level_per_row[i]]] = i;
    starting_index[level_per_row[i]]++;
  }

  // calculate reordered CSR
  console.log("calculate new CSR")
  var temp, k;
  j = 0;
  csr_row_new[0] = 0;
  for(i = 0; i < N; i++){
   k = csr_row[permutation[i]];
   temp = nnz_per_row[permutation[i]];
   csr_row_new[i+1] = csr_row_new[i] + temp;
   while(temp != 0){
     csr_col_new[j] = csr_col[k];
     csr_val_new[j++] = csr_val[k++];
     temp--;
   }
  }
  return A_csr_new;
}
