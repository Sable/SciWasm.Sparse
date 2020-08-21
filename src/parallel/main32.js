var coo_mflops = -1, csr_mflops = -1, dia_mflops = -1, ell_mflops = -1;
var coo_sum=-1, csr_sum=-1, dia_sum=-1, ell_sum=-1;
var coo_sd=-1, csr_sd=-1, dia_sd=-1, ell_sd=-1;
var coo_flops = [], csr_flops = [], dia_flops = [], ell_flops = [];
var variance;
var csr_row_mflops = -1, csr_row_gs_mflops = -1, csr_nnz_mflops = -1, csr_nnz_gs_mflops = -1, csr_nnz_sorted_mflops = -1, csr_nnz_gs_sorted_mflops = -1, csr_nnz_short_mflops = -1, csr_nnz_gs_short_mflops = -1, csr_nnz_unroll2_mflops = -1, csr_nnz_unroll3_mflops = -1, csr_nnz_unroll4_mflops = -1, csr_nnz_unroll6_mflops = -1;
var csr_row_sum = -1, csr_row_gs_sum = -1, csr_nnz_sum = -1, csr_nnz_gs_sum = -1, csr_nnz_sorted_sum = -1, csr_nnz_gs_sorted_sum = -1, csr_nnz_short_sum = -1, csr_nnz_gs_short_sum = -1, csr_nnz_unroll2_sum = -1, csr_nnz_unroll3_sum = -1, csr_nnz_unroll4_sum = -1, csr_nnz_unroll6_sum = -1;
var csr_row_sd = -1, csr_row_gs_sd = -1, csr_nnz_sd = -1, csr_nnz_gs_sd = -1, csr_nnz_sorted_sd = -1, csr_nnz_gs_sorted_sd = -1, csr_nnz_short_sd = -1, csr_nnz_gs_short_sd = -1, csr_nnz_unroll2_sd = -1, csr_nnz_unroll3_sd = -1, csr_nnz_unroll4_sd = -1, csr_nnz_unroll6_sd = -1;
var dia_row_mflops = -1, bdia_row_mflops = -1, dia_nnz_mflops = -1, bdia_nnz_mflops = -1;
var dia_row_sum = -1, bdia_row_sum = -1, dia_nnz_sum = -1, bdia_nnz_sum = -1;
var dia_row_sd = -1, bdia_row_sd = -1, dia_nnz_sd = -1, bdia_nnz_sd = -1;
var ell_col_sum = -1, ell_col_sd = -1, ell_col_mflops = -1;
var ell_gs_sum = -1, ell_gs_sd = -1, ell_gs_mflops = -1;
var bell_gs_sum = -1, bell_gs_sd = -1, bell_gs_mflops = -1;
var coo_gs_sum = -1, coo_gs_sd = -1, coo_gs_mflops = -1;
var coo_nnz_sum = -1, coo_nnz_sd = -1, coo_nnz_mflops = -1;

function coo_test(A_coo, x_view, y_view, workers, gs)
{
  return new Promise(function(resolve){
  console.log("COO");
  console.log(inner_max);
  if(typeof A_coo === "undefined"){
    console.log("matrix is undefined");
    return resolve(-1);
  }
  if(typeof x_view === "undefined"){
    console.log("vector x is undefined");
    return resolve(-1);
  }
  if(typeof y_view === "undefined"){
    console.log("vector y is undefined");
    return resolve(-1);
  }
  var N_per_worker = Math.floor(N/num_workers);
  var rem_N  = N - N_per_worker * num_workers; 
  var nnz_per_worker = Math.floor(anz/num_workers);
  var rem = anz - nnz_per_worker * num_workers;
  var t1, t2, tt = 0.0;
  var t = 0;
  function runCOO(){
    console.log("unvectorized COO");
    pending_workers = num_workers;
    do_sum = -1;
    clear_y(y_view);
    clear_w_y(A_coo);
    t1 = Date.now();
    for(var i = 0; i < num_workers; i++){
      if(i == num_workers - 1)
        workers.worker[i].postMessage(["coo", i, i * nnz_per_worker, (i+1) * nnz_per_worker + rem, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, A_coo.w_y_view[i].y_index, inner_max]);
      else
        workers.worker[i].postMessage(["coo", i, i * nnz_per_worker, (i+1) * nnz_per_worker, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, A_coo.w_y_view[i].y_index, inner_max]);
      workers.worker[i].onmessage = sumCOO;
    }
  }
  function runCOO_gs(){
    console.log("gather/scatter vectorized COO");
    pending_workers = num_workers;
    do_sum = -1;
    clear_y(y_view);
    clear_w_y(A_coo);
    t1 = Date.now();
    for(var i = 0; i < num_workers; i++){
      if(i == num_workers - 1)
        workers.worker[i].postMessage(["coo_gs", i, i * nnz_per_worker, (i+1) * nnz_per_worker + rem, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, A_coo.w_y_view[i].y_index, inner_max]);
      else
        workers.worker[i].postMessage(["coo_gs", i, i * nnz_per_worker, (i+1) * nnz_per_worker, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, A_coo.w_y_view[i].y_index, inner_max]);
      workers.worker[i].onmessage = sumCOO;
    }
  }

  function sumCOO(event){
    pending_workers -= 1;
    if(pending_workers <= 0){
      pending_workers = num_workers;
      do_sum++;
      for(var i = 0; i < num_workers; i++){
	if(i == num_workers - 1)
          workers.worker[i].postMessage(["sum", i, y_view.y_index, A_coo.w_y_view[do_sum].y_index, i * N_per_worker, (i+1) * N_per_worker + rem_N, N]);
	else
          workers.worker[i].postMessage(["sum", i, y_view.y_index, A_coo.w_y_view[do_sum].y_index, i * N_per_worker, (i+1) * N_per_worker, N]);
	if(do_sum == num_workers - 1)
          workers.worker[i].onmessage = storeCOO;
	else
          workers.worker[i].onmessage = sumCOO;

      }
    }
  }

  function storeCOO(){
    pending_workers -= 1;
    if(pending_workers <= 0){
      //for(var i = 0; i < num_workers; i++)
        //sparse_instance.exports.sum(y_view.y_index, A_coo.w_y_view[i].y_index, N);
      t2 = Date.now();
      //console.log(1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000));
      if(t >= 10){
        coo_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
        tt += t2 - t1;
      }
      t++;
      if(t < (outer_max + 10)){
	if(gs == 0)
          runCOO();
	else if(gs == 1)
          runCOO_gs();
      }
      else{
        tt = tt/1000;
        coo_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
        variance = 0;
        for(var i = 0; i < outer_max; i++)
          variance += (coo_mflops - coo_flops[i]) * (coo_mflops - coo_flops[i]);
        variance /= outer_max;
        coo_sd = Math.sqrt(variance);
        coo_sum = fletcher_sum_y(y_view);
	if(gs == 0){
	  coo_nnz_sd = coo_sd;
	  coo_nnz_mflops = coo_mflops;
	  coo_nnz_sum = coo_sum;
	}
	else if(gs == 1){
	  coo_gs_sd = coo_sd;
	  coo_gs_mflops = coo_mflops;
	  coo_gs_sum = coo_sum;
	}
        //pretty_print_y(y_view);
        //pretty_print_COO(A_coo);
        //pretty_print_x(x_view);
        console.log('coo sum is ', coo_sum);
        console.log('coo mflops is ', coo_mflops);
        console.log("Returned to main thread");
        return resolve(0);
      }
    }
  }
  if(gs == 0)
    runCOO();
  else if(gs == 1)
    runCOO_gs();
  });
}

function static_nnz_csr_test(A_csr, x_view, y_view, workers, gs, sorted, short_rows)
{
  // prereq : provide sorted A_csr input argument if sorted or short == 1
  console.log("csr nnz")
  return new Promise(function(resolve){
    console.log("CSR");
    if(typeof A_csr === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    console.log(calculate_csr_locality_index(A_csr));

    var t1, t2, tt = 0.0;
    var t = 0;
    var row_start, row_end, one_row, two_row, three_row, four_row;
    
    if(short_rows == 1){
      console.log("short rows");
      row_start = new Int32Array(num_workers);
      row_end = new Int32Array(num_workers);
      one_row = new Int32Array(num_workers);
      two_row = new Int32Array(num_workers);
      three_row = new Int32Array(num_workers);
      four_row = new Int32Array(num_workers);
      // distribute almost equal number of nnzs to each worker & calculate number of rows with short length : 0, 1, 2, 3  
      static_nnz_special_codes(A_csr, num_workers, row_start, row_end, one_row, two_row, three_row, four_row);
    }
    else{
      row_start = new Int32Array(num_workers);
      row_end = new Int32Array(num_workers);
      static_nnz(A_csr, num_workers, row_start, row_end);
      console.log("distribution done");
    }

    // CSR run for reorder format with static nnz partitioning  
    function runCSR(){
      console.log("nnz");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr", i, row_start[i], row_end[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    function runCSR_short(){
      console.log("nnz short");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_sorted_short_rows", i, row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    function runCSR_gs(){
      console.log("Gather Scatter nnz");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_gs", i, row_start[i], row_end[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    function runCSR_gs_short(){
      console.log("Gather Scatter nnz short");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_gs_short", i, row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    function storeCSR(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          csr_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
          if(gs == 0 && short_rows == 0) 
	    runCSR();
	  else if(gs == 1 && short_rows == 0) 
	    runCSR_gs();
          else if(gs == 0 && short_rows == 1) 
            runCSR_short();
          else if(gs == 1 && short_rows == 1) 
            runCSR_gs_short();
	}
        else{
          tt = tt/1000;
          csr_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
          variance /= outer_max;
          csr_sd = Math.sqrt(variance);
	  if(sorted == 1 || short_rows == 1)
            sort_y_rows_by_nnz(y_view, A_csr);
          csr_sum = fletcher_sum_y(y_view);
          console.log('csr sum is ', csr_sum);
          console.log('csr mflops is ', csr_mflops);
	  if(gs == 0 && sorted == 0 && short_rows == 0){
	    csr_nnz_mflops = csr_mflops;
	    csr_nnz_sum = csr_sum;
	    csr_nnz_sd = csr_sd;
	  }
	  else if(gs == 0 && sorted == 1 && short_rows == 0){
	    csr_nnz_sorted_mflops = csr_mflops;
	    csr_nnz_sorted_sum = csr_sum;
	    csr_nnz_sorted_sd = csr_sd;
	  }
	  if(gs == 0 && sorted == 0 && short_rows == 1){
	    csr_nnz_short_mflops = csr_mflops;
	    csr_nnz_short_sum = csr_sum;
	    csr_nnz_short_sd = csr_sd;
	  }
          else if(gs == 1 && sorted == 0 && short_rows == 0){
	    csr_nnz_gs_mflops = csr_mflops;
	    csr_nnz_gs_sum = csr_sum;
	    csr_nnz_gs_sd = csr_sd;
          }
          else if(gs == 1 && sorted == 1 && short_rows == 0){
	    csr_nnz_gs_sorted_mflops = csr_mflops;
	    csr_nnz_gs_sorted_sum = csr_sum;
	    csr_nnz_gs_sorted_sd = csr_sd;
          }
          else if(gs == 1 && sorted == 0 && short_rows == 1){
	    csr_nnz_gs_short_mflops = csr_mflops;
	    csr_nnz_gs_short_sum = csr_sum;
	    csr_nnz_gs_short_sd = csr_sd;
          }
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(gs == 0 && short_rows == 0) 
      runCSR();
    else if(gs == 1 && short_rows == 0) 
      runCSR_gs();
    else if(gs == 0 && short_rows == 1) 
      runCSR_short();
    else if(gs == 1 && short_rows == 1) 
      runCSR_gs_short();
  });
}



function static_nnz_reorder_csr_test(A_csr_original, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    console.log("CSR");
    if(typeof A_csr_original === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    console.log(calculate_csr_locality_index(A_csr_original));
    // sort CSR format by nnz per row
    var A_csr_sorted = sort_rows_by_nnz(A_csr_original);
    console.log(calculate_csr_locality_index(A_csr_sorted));
    console.log("CSR sorted");
    console.log("reordering A_csr");
    var A_csr = reorder_NN(A_csr_sorted, 16);
    console.log("reordered A_csr");
    console.log(calculate_csr_locality_index(A_csr));

    var t1, t2, tt = 0.0;
    var t = 0;
    var row_start = new Int32Array(num_workers);
    var row_end = new Int32Array(num_workers);

    static_nnz(A_csr, num_workers, row_start, row_end);

    // CSR run for reorder format with static nnz partitioning  
    function runCSR(){
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr", i, row_start[i], row_end[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }
	
    function storeCSR(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          csr_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10))
          runCSR();
        else{
          tt = tt/1000;
          csr_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
          variance /= outer_max;
          csr_sd = Math.sqrt(variance);
          sort_y_rows_by_nnz(y_view, A_csr);
          sort_y_rows_by_nnz(y_view, A_csr_sorted);
          csr_sum = fletcher_sum_y(y_view);
          console.log('csr sum is ', csr_sum);
          console.log('csr mflops is ', csr_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    runCSR();
  });
}


function csr_test(A_csr, x_view, y_view, workers, gs)
{
  console.log('csr row');
  return new Promise(function(resolve){
    console.log("CSR");
    if(typeof A_csr === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    //console.log("reordering A_csr");
    //var A_csr = reorder_NN(A_csr_original, 16);
    //console.log("reordered A_csr");
    print_nnz_per_worker(A_csr, num_workers);
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runCSR(){
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["csr", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["csr", i, i * N_per_worker, (i+1) * N_per_worker, A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    function runCSR_gs(){
      console.log("Gather Scatter row");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["csr_gs", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["csr_gs", i, i * N_per_worker, (i+1) * N_per_worker, A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    function storeCSR(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          csr_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
	  if(gs == 0)
            runCSR();
          else if(gs == 1)
            runCSR_gs();
	}
        else{
          tt = tt/1000;
          csr_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
          variance /= outer_max;
          csr_sd = Math.sqrt(variance);
          //sort_y_rows_by_nnz(y_view, A_csr);
          csr_sum = fletcher_sum_y(y_view);
          console.log('csr sum is ', csr_sum);
          console.log('csr mflops is ', csr_mflops);
	  if(gs == 0){
	    csr_row_mflops = csr_mflops;
	    csr_row_sum = csr_sum;
	    csr_row_sd = csr_sd;
	  }
          else if(gs == 1){
	    csr_row_gs_mflops = csr_mflops;
	    csr_row_gs_sum = csr_sum;
	    csr_row_gs_sd = csr_sd;
          }
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(gs == 0)
      runCSR();
    else if(gs == 1)
      runCSR_gs();
  });
}

function static_nnz_sorted_unrolled_csr_test(A_csr, x_view, y_view, workers, unroll_factor)
{
  // prereq : provide sorted A_csr input argument if sorted or short == 1
  return new Promise(function(resolve){
    console.log("CSR static nnz");
    if(typeof A_csr === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var t1, t2, tt = 0.0;
    var t = 0;
    var row_start = new Int32Array(num_workers);
    var row_end = new Int32Array(num_workers);
    var one_row = new Int32Array(num_workers);
    var two_row = new Int32Array(num_workers);
    var three_row = new Int32Array(num_workers);
    var four_row = new Int32Array(num_workers);
    // distribute almost equal number of nnzs to each worker & calculate number of rows with short length : 0, 1, 2, 3  
    static_nnz_special_codes(A_csr, num_workers, row_start, row_end, one_row, two_row, three_row, four_row);

    // CSR run for sorted format with static nnz partitioning  
    function runCSR(){
      console.log("CSR run");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr", i, row_start[i], row_end[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    // CSR run for sorted format with static nnz partitioning and unroll factor 2
    function run_unrolled2_CSR(){
      console.log("unrolled CSR run");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_unroll_2", i, row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    // CSR run for sorted format with static nnz partitioning and unroll factor 3
    function run_unrolled3_CSR(){
      console.log("unrolled CSR run");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_unroll_3", i, row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    // CSR run for sorted format with static nnz partitioning and unroll factor 4
    function run_unrolled4_CSR(){
      console.log("unrolled 4 CSR run");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_unroll_4", i, row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }

    // CSR run for sorted format with static nnz partitioning and unroll factor 6
    function run_unrolled6_CSR(){
      console.log("unrolled CSR run");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["csr_unroll_6", i, row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i], A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }	  
 
    function storeCSR(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          csr_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
          if(unroll_factor == 1)
            runCSR();
	  else if(unroll_factor == 2) 
            run_unrolled2_CSR();
	  else if(unroll_factor == 3) 
            run_unrolled3_CSR();
          else if(unroll_factor == 4)
            run_unrolled4_CSR();
          else if(unroll_factor == 6)
            run_unrolled6_CSR();
	}
        else{
          tt = tt/1000;
          csr_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
          variance /= outer_max;
          csr_sd = Math.sqrt(variance);
          sort_y_rows_by_nnz(y_view, A_csr);
          csr_sum = fletcher_sum_y(y_view);
	  if(unroll_factor == 2){
	    csr_nnz_unroll2_sd = csr_sd;
	    csr_nnz_unroll2_mflops = csr_mflops;
	    csr_nnz_unroll2_sum = csr_sum;
	  }
	  if(unroll_factor == 3){
	    csr_nnz_unroll3_sd = csr_sd;
	    csr_nnz_unroll3_mflops = csr_mflops;
	    csr_nnz_unroll3_sum = csr_sum;
	  }
	  if(unroll_factor == 4){
	    csr_nnz_unroll4_sd = csr_sd;
	    csr_nnz_unroll4_mflops = csr_mflops;
	    csr_nnz_unroll4_sum = csr_sum;
	  }
	  if(unroll_factor == 6){
	    csr_nnz_unroll6_sd = csr_sd;
	    csr_nnz_unroll6_mflops = csr_mflops;
	    csr_nnz_unroll6_sum = csr_sum;
	  }
          console.log('csr sum is ', csr_sum);
          console.log('csr mflops is ', csr_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(unroll_factor == 1)
      runCSR();
    else if(unroll_factor == 2) 
      run_unrolled2_CSR();
    else if(unroll_factor == 3) 
      run_unrolled3_CSR();
    else if(unroll_factor == 4)
      run_unrolled4_CSR();
    else if(unroll_factor == 6)
      run_unrolled6_CSR();
  });
}


/*function dia_test(A_dia, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    console.log("DIA");
    if(typeof A_dia === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runDIA()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["dia_row", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["dia_row", i, i * N_per_worker, (i+1) * N_per_worker, A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeDIA;
      }
    }

    function storeDIA(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          dia_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10))
          runDIA();
        else{
          tt = tt/1000;
          dia_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (dia_mflops - dia_flops[i]) * (dia_mflops - dia_flops[i]);
          variance /= outer_max;
          dia_sd = Math.sqrt(variance);
          dia_sum = fletcher_sum_y(y_view);
          //pretty_print_DIA(A_dia);
          //pretty_print_y(y_view);
          console.log('dia sum is ', dia_sum);
          console.log('dia mflops is ', dia_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    runDIA();
  });
}*/

function dia_col_test(A_dia, x_view, y_view, workers, blocked)
{
  console.log("dia row partition")
  return new Promise(function(resolve){
    console.log("DIA col");
    if(typeof A_dia === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    console.log(N_per_worker, rem_N);
    var t = 0;

    function runDIA()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["dia_col", i, i * N_per_worker, (i+1) * N_per_worker - 1 + rem_N, A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, A_dia.stride, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["dia_col", i, i * N_per_worker, (i+1) * N_per_worker - 1, A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, A_dia.stride, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeDIA;
      }
    }
    function runBDIA()
    {
      console.log("blocking DIA");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["bdia_col", i, i * N_per_worker, (i+1) * N_per_worker - 1 + rem_N, A_dia.offset_index, A_dia.data_index, A_dia.w_istart_index[i], A_dia.w_iend_index[i], A_dia.ndiags, N, A_dia.stride, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["bdia_col", i, i * N_per_worker, (i+1) * N_per_worker - 1, A_dia.offset_index, A_dia.data_index, A_dia.w_istart_index[i], A_dia.w_iend_index[i], A_dia.ndiags, N, A_dia.stride, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeDIA;
      }
    }
	
    function storeDIA(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          dia_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
          if(blocked == 0)
            runDIA();
          else if(blocked == 1)
            runBDIA();
        }
        else{
          tt = tt/1000;
          dia_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (dia_mflops - dia_flops[i]) * (dia_mflops - dia_flops[i]);
          variance /= outer_max;
          dia_sd = Math.sqrt(variance);
          dia_sum = fletcher_sum_y(y_view);
	  if(blocked == 0){
	    dia_row_mflops = dia_mflops;
	    dia_row_sd = dia_sd;
	    dia_row_sum = dia_sum;
	  }
	  else if(blocked == 1){
	    bdia_row_mflops = dia_mflops;
	    bdia_row_sd = dia_sd;
	    bdia_row_sum = dia_sum;
	  }
          console.log('dia sum is ', dia_sum);
          console.log('dia mflops is ', dia_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(blocked == 0)
      runDIA();
    else if(blocked == 1)
      runBDIA();
  });
}



function dia_col_static_nnz_test(A_dia, x_view, y_view, workers, blocked)
{
  console.log("dia nnz")
  return new Promise(function(resolve){
    if(typeof A_dia === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var t1, t2, tt = 0.0;
    var row_start = new Int32Array(num_workers);
    var row_end = new Int32Array(num_workers);
    static_nnz_dia(A_dia, num_workers, row_start, row_end)
    var t = 0;

    function runDIA()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        workers.worker[i].postMessage(["dia_col", i, row_start[i], row_end[i], A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, A_dia.stride, x_view.x_index, y_view.y_index, inner_max]);
	workers.worker[i].onmessage = storeDIA;
      }
    }
    function runBDIA()
    {
      console.log("blocking DIA");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
	workers.worker[i].postMessage(["bdia_col", i, row_start[i], row_end[i], A_dia.offset_index, A_dia.data_index, A_dia.w_istart_index[i], A_dia.w_iend_index[i], A_dia.ndiags, N, A_dia.stride, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeDIA;
      }
    }
    function storeDIA(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          dia_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
	  if(blocked == 0)
            runDIA();
          else if(blocked == 1)
            runBDIA();
	}
        else{
          tt = tt/1000;
          dia_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (dia_mflops - dia_flops[i]) * (dia_mflops - dia_flops[i]);
          variance /= outer_max;
          dia_sd = Math.sqrt(variance);
          dia_sum = fletcher_sum_y(y_view);
	  if(blocked == 0){
	    dia_nnz_mflops = dia_mflops;
	    dia_nnz_sd = dia_sd;
	    dia_nnz_sum = dia_sum;
	  }
	  else if(blocked == 1){
	    bdia_nnz_mflops = dia_mflops;
	    bdia_nnz_sd = dia_sd;
	    bdia_nnz_sum = dia_sum;
	  }
          console.log('dia sum is ', dia_sum);
          console.log('dia mflops is ', dia_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(blocked == 0)
      runDIA();
    else if(blocked == 1)
      runBDIA();
  });
}

function ell_row_test(A_ell, x_view, y_view, workers, gs)
{
  return new Promise(function(resolve){
    console.log("ELL");
    if(typeof A_ell === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runELL()
    {
      console.log("unvectorized");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["ell_row", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["ell_row", i, i * N_per_worker, (i+1) * N_per_worker, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeELL;
      }
    }

    function runELL_gs()
    {
      console.log("vectorized");
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["ell_row_gs", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["ell_row_gs", i, i * N_per_worker, (i+1) * N_per_worker, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeELL;
      }
    }

    function storeELL(event)
    {
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          ell_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
	  if(gs == 0)
            runELL();
	  else if(gs == 1)
            runELL_gs();
	}
        else{
          tt = tt/1000;
          ell_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (ell_mflops - ell_flops[i]) * (ell_mflops - ell_flops[i]);
          variance /= outer_max;
          ell_sd = Math.sqrt(variance);
          ell_sum = fletcher_sum_y(y_view);
          //pretty_print_y(y_view);
          console.log('ell sum is ', ell_sum);
          console.log('ell mflops is ', ell_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(gs == 0)
      runELL();
    else if(gs == 1)
      runELL_gs();
  });
}

function ell_col_test(A_ell, x_view, y_view, workers, gs, blocked)
{
  return new Promise(function(resolve){
    if(typeof A_ell === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runELL()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["ell_col", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["ell_col", i, i * N_per_worker, (i+1) * N_per_worker, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeELL;
      }
    }

    function runELL_gs()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["ell_col_gs", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["ell_col_gs", i, i * N_per_worker, (i+1) * N_per_worker, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeELL;
      }
    }

    function runBELL_gs()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage(["bell_col_gs", i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage(["bell_col_gs", i, i * N_per_worker, (i+1) * N_per_worker, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeELL;
      }
    }

    function storeELL(event)
    {
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          ell_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10)){
	  if(gs == 0)
            runELL();
	  else if(gs == 1 && blocked == 0)
            runELL_gs();
	  else if(gs == 1 && blocked == 1)
            runBELL_gs();
	}
        else{
          tt = tt/1000;
          ell_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (ell_mflops - ell_flops[i]) * (ell_mflops - ell_flops[i]);
          variance /= outer_max;
          ell_sd = Math.sqrt(variance);
          ell_sum = fletcher_sum_y(y_view);
	  if(gs == 0){
	    ell_col_mflops = ell_mflops;
	    ell_col_sd = ell_sd;
	    ell_col_sum = ell_sum;
	  }
	  if(gs == 1 && blocked == 0){
	    ell_gs_mflops = ell_mflops;
	    ell_gs_sd = ell_sd;
	    ell_gs_sum = ell_sum;
	  }
	  if(gs == 1 && blocked == 1){
	    bell_gs_mflops = ell_mflops;
	    bell_gs_sd = ell_sd;
	    bell_gs_sum = ell_sum;
	  }
          //pretty_print_y(y_view);
          console.log('ell sum is ', ell_sum);
          console.log('ell mflops is ', ell_mflops);
          console.log("Returned to main thread");
          return resolve(0);
        }
      }
    }
    if(gs == 0)
      runELL();
    else if(gs == 1 && blocked == 0)
      runELL_gs();
    else if(gs == 1 && blocked == 1)
      runBELL_gs();
  });
}

function spmv_coo_test(files, callback)
{
  console.log("inside coo test");
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, x_view, y_view;

  console.log("memory allocated");

  A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");
  x_view = allocate_x(mm_info);
  init_x(x_view);
  y_view = allocate_y(mm_info);
  clear_y(y_view);

  var coo_promise = coo_test(A_coo, x_view, y_view, workers, 0);
  coo_promise.then(coo_value => {
    var coo_gs_promise = coo_test(A_coo, x_view, y_view, workers, 1);
    coo_gs_promise.then(coo_gs_value => {
      free_memory_coo(A_coo);
      free_memory_x(x_view);
      free_memory_y(y_view);
      console.log("done");
      callback();
    });
  });
}


function spmv_ell_test(files, callback)
{
  console.log("inside ell test");
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, A_ell, x_view, y_view;
  console.log("memory allocated");

  A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");

  A_csr = allocate_CSR(mm_info);
  //convert COO to CSR
  coo_csr(A_coo, A_csr);
  free_memory_coo(A_coo);
  console.log("CSR allocated");

  //get ELL info
  var nc = num_cols(A_csr);
  if((nc*N < Math.pow(2,27)) && (((N * nc)/anz) <= 5)){
    A_ell = allocate_ELL(mm_info, nc);
    //convert CSR to ELL
    csr_ell_col(A_csr, A_ell);
  }

  free_memory_csr(A_csr);
  x_view = allocate_x(mm_info);
  init_x(x_view);
  y_view = allocate_y(mm_info);
  clear_y(y_view);

  // ell col
  var ell_promise = ell_col_test(A_ell, x_view, y_view, workers, 0, 0);
  ell_promise.then(ell_value => {
    // ell col gather/scatter
    var ell_gs_promise = ell_col_test(A_ell, x_view, y_view, workers, 1, 0);
    ell_gs_promise.then(ell_gs_value => {
    // ell col gather/scatter + loop blocking
    var bell_gs_promise = ell_col_test(A_ell, x_view, y_view, workers, 1, 1);
      bell_gs_promise.then(bell_gs_value => {
        free_memory_ell(A_ell);
        free_memory_x(x_view);
        free_memory_y(y_view);
        console.log("done");
        callback();
      });
    });
  });
}


function spmv_dia_test(files, callback)
{
  console.log("inside dia test");
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, A_dia, x_view, y_view;
  console.log("memory allocated");

  A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");

  A_csr = allocate_CSR(mm_info);
  //convert COO to CSR
  coo_csr(A_coo, A_csr);
  free_memory_coo(A_coo);
  console.log("CSR allocated");
      
  //get DIA info
  var result = num_diags(A_csr);
  var nd = result[0];
  var stride = result[1];
  if(nd*stride < Math.pow(2,27) && (((stride * nd)/anz) <= 5)){
    A_dia = allocate_DIA(mm_info, nd, stride);
    //convert CSR to DIA
    csr_dia_col(A_csr, A_dia);
  }

  free_memory_csr(A_csr);
  x_view = allocate_x(mm_info);
  init_x(x_view);
  y_view = allocate_y(mm_info);
  clear_y(y_view);

  // dia row partitioning
  var dia_promise = dia_col_test(A_dia, x_view, y_view, workers, 0);
  dia_promise.then(dia_value => {
    // bdia row partitioning
    var bdia_promise = dia_col_test(A_dia, x_view, y_view, workers, 1);
    bdia_promise.then(bdia_value => {
      // dia nnz partitioning
      var dia_nnz_promise = dia_col_static_nnz_test(A_dia, x_view, y_view, workers, 0)
      dia_nnz_promise.then(dia_nnz_value => {
        // bdia nnz partitioning
        var bdia_nnz_promise = dia_col_static_nnz_test(A_dia, x_view, y_view, workers, 1);
        bdia_nnz_promise.then(bdia_nnz_value => {
          free_memory_dia(A_dia);
          free_memory_x(x_view);
          free_memory_y(y_view);
          console.log("done");
          callback();
	});
      });
    });
  });
}

function spmv_csr_nnz_test(files, callback)
{
  console.log("inside csr nnz test");
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, A_csr_sorted, x_view, y_view;
  console.log("memory allocated");

  A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");


  A_csr = allocate_CSR(mm_info);
  //convert COO to CSR
  coo_csr(A_coo, A_csr);
  free_memory_coo(A_coo);
  console.log("CSR allocated");

  x_view = allocate_x(mm_info);
  init_x(x_view);
  y_view = allocate_y(mm_info);
  clear_y(y_view);
      
  var csr_nnz_promise = static_nnz_csr_test(A_csr, x_view, y_view, workers, 0, 0, 0);
  csr_nnz_promise.then(csr_nnz_value => {
    // CSR nnz gather/scatter
    var csr_nnz_gs_promise = static_nnz_csr_test(A_csr, x_view, y_view, workers, 1, 0, 0);
    csr_nnz_gs_promise.then(csr_nnz_gs_value => {
      free_memory_x(x_view);
      free_memory_y(y_view);
      // sort CSR format by nnz per row
      A_csr_sorted = sort_rows_by_nnz(A_csr);
      free_memory_csr(A_csr);
      x_view = allocate_x(mm_info);
      init_x(x_view);
      y_view = allocate_y(mm_info);
      clear_y(y_view);
      var csr_nnz_sorted_promise = static_nnz_csr_test(A_csr_sorted, x_view, y_view, workers, 0, 1, 0);
      csr_nnz_sorted_promise.then(csr_nnz_sorted_value => {
        var csr_nnz_gs_sorted_promise = static_nnz_csr_test(A_csr_sorted, x_view, y_view, workers, 1, 1, 0);
        csr_nnz_gs_sorted_promise.then(csr_nnz_gs_sorted_value => {
          var csr_nnz_short_promise = static_nnz_csr_test(A_csr_sorted, x_view, y_view, workers, 0, 0, 1);
          csr_nnz_short_promise.then(csr_nnz_short_value => {
            // CSR nnz gather/scatter short
            var csr_nnz_gs_short_promise = static_nnz_csr_test(A_csr_sorted, x_view, y_view, workers, 1, 0, 1);
            csr_nnz_gs_short_promise.then(csr_nnz_gs_short_value => {
	      var csr_nnz_unroll2_promise = static_nnz_sorted_unrolled_csr_test(A_csr_sorted, x_view, y_view, workers, 2);
              csr_nnz_unroll2_promise.then(csr_nnz_unroll2_value => {
	        var csr_nnz_unroll3_promise = static_nnz_sorted_unrolled_csr_test(A_csr_sorted, x_view, y_view, workers, 3);
                csr_nnz_unroll3_promise.then(csr_nnz_unroll3_value => {
	          var csr_nnz_unroll4_promise = static_nnz_sorted_unrolled_csr_test(A_csr_sorted, x_view, y_view, workers, 4);
                  csr_nnz_unroll4_promise.then(csr_nnz_unroll4_value => {
                    free_memory_csr(A_csr_sorted);
                    free_memory_x(x_view);
                    free_memory_y(y_view);
                    console.log("done");
                    callback();
                  });
                });
              });
            });
          });
        });
      });
    });
  });
}



function spmv_csr_row_test(files, callback)
{
  console.log("inside csr test");
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, x_view, y_view;
  console.log("memory allocated");

  A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");


  A_csr = allocate_CSR(mm_info);
  //convert COO to CSR
  coo_csr(A_coo, A_csr);
  free_memory_coo(A_coo);
  console.log("CSR allocated");
  
  /*console.log(calculate_csr_locality_index(A_csr));
  // sort CSR format by nnz per row
  var A_csr_sorted = sort_rows_by_nnz(A_csr);
  console.log("CSR sorted");
  console.log(calculate_csr_locality_index(A_csr_sorted));
  free_memory_csr(A_csr);*/

  x_view = allocate_x(mm_info);
  init_x(x_view);
  y_view = allocate_y(mm_info);
  clear_y(y_view);

  /*var csr_nnz_promise = static_nnz_sorted_unrolled_csr_test(A_csr_sorted, x_view, y_view, workers, 1, 0);
  csr_nnz_promise.then(csr_nnz_value => {
    var csr_nnz_short_rows_promise = static_nnz_sorted_unrolled_csr_test(A_csr_sorted, x_view, y_view, workers, 1, 1)
    csr_nnz_short_rows_promise.then(csr_nnz_short_rows_value => {
      free_memory_csr(A_csr_sorted);
      free_memory_x(x_view);
      free_memory_y(y_view);
      console.log("done");
      callback();
    });
  });*/

  // CSR row
  var csr_row_promise = csr_test(A_csr, x_view, y_view, workers, 0);
  csr_row_promise.then(csr_row_value => {
    // CSR row gather/scatter
    var csr_row_gs_promise = csr_test(A_csr, x_view, y_view, workers, 1);
    csr_row_gs_promise.then(csr_row_gs_value => {
      // CSR nnz
      var csr_nnz_promise = static_nnz_csr_test(A_csr, x_view, y_view, workers, 0, 0, 0);
      csr_nnz_promise.then(csr_nnz_value => {
        // CSR nnz gather/scatter
        var csr_nnz_gs_promise = static_nnz_csr_test(A_csr, x_view, y_view, workers, 1, 0, 0);
        csr_nnz_gs_promise.then(csr_nnz_gs_value => {
          free_memory_csr(A_csr);
          free_memory_x(x_view);
          free_memory_y(y_view);
          console.log("done");
          callback();
	});
      });
    });
  });
}

function spmv_all_test(files, callback)
{
  console.log("inside all test");
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, A_dia, A_ell, x_view, y_view;

  console.log("memory allocated");

  A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");
  x_view = allocate_x(mm_info);
  init_x(x_view);
  y_view = allocate_y(mm_info);
  clear_y(y_view);

  var coo_promise = coo_test(A_coo, x_view, y_view, workers, 0);
  coo_promise.then(coo_value => {
    A_csr = allocate_CSR(mm_info);
    //convert COO to CSR
    coo_csr(A_coo, A_csr);
    free_memory_coo(A_coo);
    console.log("CSR allocated");

    var csr_promise = csr_test(A_csr, x_view, y_view, workers, 0);
    csr_promise.then(csr_value => {
      //get DIA info
      var result = num_diags(A_csr);
      var nd = result[0];
      var stride = result[1];
      if(nd*stride < Math.pow(2,27) && (((stride * nd)/anz) <= 5)){
        A_dia = allocate_DIA(mm_info, nd, stride);
        //convert CSR to DIA
        csr_dia_col(A_csr, A_dia);
      }

      var dia_promise = dia_col_test(A_dia, x_view, y_view, workers, 0);
      dia_promise.then(dia_value => {
        free_memory_dia(A_dia);
        //get ELL info
        var nc = num_cols(A_csr);
        if((nc*mm_info.nrows < Math.pow(2,27)) && (((mm_info.nrows * nc)/anz) <= 5)){
          A_ell = allocate_ELL(mm_info, nc);
          //convert CSR to ELL
          csr_ell_col(A_csr, A_ell);
        }

        var ell_promise = ell_col_test(A_ell, x_view, y_view, workers, 1, 0);
        ell_promise.then(ell_value => {
          free_memory_ell(A_ell);
          free_memory_csr(A_csr);
          free_memory_x(x_view);
          free_memory_y(y_view);
          console.log("done");
          callback();
        });
      });
    });
  });
}



function spmv(callback)
{
  let promise = load_file();
  promise.then(files => {
    console.log("inside promise")
    if(tests == 'all')
      spmv_all_test(files, callback)
    else if(tests == 'dia')
      spmv_dia_test(files, callback)
    else if(tests == 'ell')
      spmv_ell_test(files, callback)
    else if(tests == 'csr_nnz')
      spmv_csr_nnz_test(files, callback)
    else if(tests == 'csr_row')
      spmv_csr_row_test(files, callback)
    else if(tests == 'coo')
      spmv_coo_test(files, callback)
  },
  error => callback()
  ); 
}
