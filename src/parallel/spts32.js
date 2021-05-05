function spts_init_x(x_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  for(var i = 0; i < x_view.x_nelem; i++)
    x[i] = 1.0;
}
function spts_init_y(y_view){
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  for(var i = 0; i < y_view.y_nelem; i++)
    y[i] = 1.0;
}


function create_LCOO_from_MM(mm_info)
{
  var row = mm_info.row;
  var col = mm_info.col;
  var val = mm_info.val;
  var L_anz = mm_info.nrows;

  if(mm_info.symmetry == "symmetric"){
    for(var n = 0; n < mm_info.nentries; n++) {
      if(row[n] != col[n])
        L_anz++;
    }
  }
  else{
    for(var n = 0; n < mm_info.nentries; n++) {
      if(row[n] > col[n])
        L_anz++;
    }
  }

  mm_info.anz = L_anz;
  anz = mm_info.anz;
  var A_coo = allocate_COO(mm_info);
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz);
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz);
  var coo_val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz);
  var i = 0;

  if(mm_info.symmetry == "symmetric"){
    if(mm_info.field == "pattern"){
      for(var n = 0; n < mm_info.nentries; n++) {
        if(row[n] > col[n]){
          coo_row[i] = Number(row[n] - 1);
          coo_col[i] = Number(col[n] - 1);
          coo_val[i] = 1.0;
          i++;
        }
        else if(row[n] < col[n]){
          coo_row[i] = Number(col[n] - 1);
          coo_col[i] = Number(row[n] - 1);
          coo_val[i] = 1.0;
          i++;
        }
      }
    }
    else{
      for(var n = 0; n < mm_info.nentries; n++) {
        if(val[n] < 0 || val[n] > 0){
          if(row[n] > col[n]){
            coo_row[i] = Number(row[n] - 1);
            coo_col[i] = Number(col[n] - 1);
            coo_val[i] = Number(val[n]);
            i++;
          }
          else if(row[n] < col[n]){
            coo_row[i] = Number(col[n] - 1);
            coo_col[i] = Number(row[n] - 1);
            coo_val[i] = Number(val[n]);
            i++;
          }
        }
      }
    }
  }
  else{
    if(mm_info.field == "pattern"){
      for(n = 0; n < mm_info.nentries; n++, i++) {
        if(row[n] > col[n]){
          coo_row[i] = Number(row[n] - 1);
          coo_col[i] = Number(col[n] - 1);
          coo_val[i] = 1.0;
          i++;
        }
      }
    }
    else{
      for(var n = 0; n < mm_info.nentries; n++) {
        if(val[n] < 0 || val[n] > 0){
          if(row[n] > col[n]){
            coo_row[i] = Number(row[n] - 1);
            coo_col[i] = Number(col[n] - 1);
            coo_val[i] = Number(val[n]);
            i++;
          }
        }
      }
    }
  }
  for(var n = 0; n < mm_info.nrows; n++){
    coo_row[i] = n;
    coo_col[i] = n;
    coo_val[i] = 1.0;
    i++;
  }
  quick_sort_COO(A_coo, 0, anz-1);
  return A_coo;
}

function setup_sync_free_metadata(A_csr)
{
  console.log('sync free metadata');
  // assume the column array is sorted by ascending order per row
  var nz = A_csr.nnz;
  var N = A_csr.nrows;
  // allocate and set barrier to 0
  A_csr.barrier_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT);
  var barrier = new Int32Array(memory.buffer, A_csr.barrier_index, 1);
  barrier[0] = 0;
  A_csr.flag_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT);
  var flag = new Int32Array(memory.buffer, A_csr.flag_index, 1);
  flag[0] = 0;
  A_csr.array_flag_index = malloc_instance.exports._malloc(N * Int32Array.BYTES_PER_ELEMENT);
  var array_flag = new Int32Array(memory.buffer, A_csr.array_flag_index, N);
  for(var i = 0; i < N; i++){
    array_flag[i] = 0;
  }
}

function CSR_create_level_sets(A_csr)
{
  console.log('creating level sets');
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
  console.log('creating level sets');
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
  console.log('number of levels', tot_levels);

  // calculate number of rows at each level
  var freq = new Int32Array(tot_levels);
  freq.fill(0);
  for(var i = 0; i < N; i++){
    freq[level_per_row[i]]++; 
  }

  // allocate level pointer array
  A_csr_new.level_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (tot_levels + 1));
  var level = new Int32Array(memory.buffer, A_csr_new.level_index, tot_levels + 1);

  // allocate and set barrier to 0
  A_csr_new.barrier_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT);
  var barrier = new Int32Array(memory.buffer, A_csr_new.barrier_index, 1);
  barrier[0] = 0;
  A_csr_new.flag_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT);
  var flag = new Int32Array(memory.buffer, A_csr_new.flag_index, 1);
  flag[0] = 0;
  A_csr_new.array_flag_index = malloc_instance.exports._malloc(N * Int32Array.BYTES_PER_ELEMENT);
  var array_flag = new Int32Array(memory.buffer, A_csr_new.array_flag_index, N);
  for(var i = 0; i < N; i++){
    array_flag[i] = 0;
  }
  A_csr_new.global_level_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT);
  var global_level = new Int32Array(memory.buffer, A_csr_new.global_level_index, 1);
  global_level[0] = -1;
  A_csr_new.array_level_index = malloc_instance.exports._malloc(tot_levels * Int32Array.BYTES_PER_ELEMENT);
  var array_level = new Int32Array(memory.buffer, A_csr_new.array_level_index, tot_levels);
  for(var i = 0; i < tot_levels; i++){
    array_level[i] = 0;
  }
  //for(var i = 0; i < tot_levels; i++){
    //barrier[i] = 0;
  //}
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
  var order = new Int32Array(N);
  // calculate the permutation of rows if the rows are sorted by levels
  for(var i = 0; i < N; i++){
    permutation[starting_index[level_per_row[i]]] = i;
    order[i] = starting_index[level_per_row[i]];
    starting_index[level_per_row[i]]++;
  }

  //for(var i = 0; i < 10; i++){
    //console.log(i, permutation[i]);
  //}

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
     csr_col_new[j] = order[csr_col[k]];
     //csr_col_new[j] = csr_col[k];
     csr_val_new[j++] = csr_val[k++];
     temp--;
   }
  }
  return A_csr_new;
}
