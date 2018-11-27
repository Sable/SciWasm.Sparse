function matlab_modulo(x, y) {
  var n = Math.floor(x/y);
  return x - n*y;
}

function fletcher_sum(A) {
  var sum1 = 0;
  var sum2 = 0;

  for (var i = 0; i < A.length; ++i) {
    sum1 = matlab_modulo((sum1 + A[i]),255);
    sum2 = matlab_modulo((sum2 + sum1),255);
  }
  return sum2 * 256 + sum1;
}

function num_cols(csr_row, N)
{
  var temp, max = 0;
  for(var i = 0; i < N ; i++){
    temp = csr_row[i+1] - csr_row[i];
    if (max < temp)
      max = temp;
  }
  return max;
}

function csr_ell(csr_row, csr_col, csr_val, indices, data, nc, N){
  var i, j, k, temp, max = 0;
  for(i = 0; i < N; i++){
    k = 0;
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      data[i*nc+k] = csr_val[j];
      indices[i*nc+k] = csr_col[j];
      k++;
    }
  }
}

function num_diags(N,csr_row,csr_col)
{
  var ind = new Int32Array(2*N-1);
  var num_diag = 0;
  ind.fill(0);
  for(var i = 0; i < N ; i++){
    for(var j = csr_row[i]; j<csr_row[i+1]; j++){
      if(!ind[N+csr_col[j]-i-1]++)
        num_diag++;
    }
  }
  var diag_no = -(parseInt((2*N-1)/2));
  var min = Math.abs(diag_no);
  for(var i = 0; i < 2*N-1; i++){
    if(ind[i]){
      if(min > Math.abs(diag_no))
        min = Math.abs(diag_no); 
    }
    diag_no++; 
  }
  //stride = N - min;
  stride = N;
  return [num_diag,stride];
}


function csr_dia(csr_row, csr_col, csr_val, offset, data, nz, N, stride){
  var ind = [], i, j, move;
  for(i = 0; i < 2*N-1; i++){
    ind[i] = 0; 
  }
  for(i = 0; i < N; i++){
    for(j = csr_row[i]; j < csr_row[i+1]; j++){ 
      ind[N+csr_col[j]-i-1]++;
    }
  }
  var diag_no = -(parseInt((2*N-1)/2));
  var index = 0;
  for(i = 0; i < 2*N-1; i++){
    if(ind[i])
      offset[index++] = diag_no;
    diag_no++; 
  }
  var c;
  
  for(i = 0; i < N; i++){
    for(j = csr_row[i]; j < csr_row[i+1]; j++){ 
      c = csr_col[j];  
      for(k = 0; k < offset.length; k++){
        move = 0;
        if(c - i == offset[k]){
          //if(offset[k] < 0)
            //move = N - stride; 
          //data[k*stride+i-move] = csr_val[j];
          data[i*offset.length+k] = csr_val[j];
          break;
        }
      }
    }
  }
  return stride;
}

function quick_sort(arr, arr2, arr3, left, right)
{
  var i = left
  var j = right;
  var pivot = arr[parseInt((left + right) / 2)];
  var pivot_col = arr2[parseInt((left + right) / 2)];

  /* partition */
  while(i <= j) {
    while((arr[i] < pivot) || (arr[i] == pivot && arr2[i] < pivot_col))
      i++;
    while((arr[j] > pivot) || (arr[j] == pivot && arr2[j] > pivot_col))
      j--;
    if(i <= j) {
      arr[j] = [arr[i], arr[i] = arr[j]][0];
      arr2[j] = [arr2[i], arr2[i] = arr2[j]][0];
      arr3[j] = [arr3[i], arr3[i] = arr3[j]][0];
      i++;
      j--;
    }
  }

  /* recursion */
  if(left < j)
    quick_sort(arr, arr2, arr3, left, j);
  if (i < right)
    quick_sort(arr, arr2, arr3, i, right);
}


function sort(start, end, array1, array2)
{ 
  var i, j, temp;
  for(i = 0; i < end-start-1; i++){
    for(j = start; j < end-i-1; j++){
      if(array1[j] > array1[j+1]){
        temp = array1[j];
        array1[j] = array1[j+1];
        array1[j+1] = temp;
        temp = array2[j];
        array2[j] = array2[j+1];
        array2[j+1] = temp;
      }
    }
  }
}

function coo_csr(row, col, val, N, nz, csr_row, csr_col, csr_val){
  var i;
  for(i = 0; i < nz; i++){
    csr_row[row[i]]++; 
  }

  var j = 0, j0 = 0;
  for(i = 0; i < N; i++){
    j0 = csr_row[i];
    csr_row[i] = j;
    j += j0;
  }

  var r, c, data;
  for(i = 0; i < nz; i++){
    j = csr_row[row[i]];
    csr_col[j] = col[i];
    csr_val[j] = val[i];
    csr_row[row[i]]++;
  }

  for(i = N-1; i > 0; i--){
    csr_row[i] = csr_row[i-1]; 
  }
  csr_row[0] = 0;
  csr_row[N] = nz;
  for(i = 0; i < N; i++)
    sort(csr_row[i], csr_row[i+1], csr_col, csr_val);
  
}


  
var coo_mflops = -1, csr_mflops = -1, dia_mflops = -1, ell_mflops = -1;
var coo_sum=-1, csr_sum=-1, dia_sum=-1, ell_sum=-1;
var coo_sd=-1, csr_sd=-1, dia_sd=-1, ell_sd=-1;
var anz = 0;
var coo_flops = [], csr_flops = [], dia_flops = [], ell_flops = [];
var N;
var variance;
var inside = 0, inside_max = 100000, outer_max = 30;
function spmv(callback){
  var files = new Array(num);
  var fileno = 0;
  var loadfiles = function(fileno, callback){
    var request = new XMLHttpRequest();
    myname = filename + (Math.floor(fileno/10)).toString() + (fileno%10).toString() + '.mtx'
    console.log(myname);
    request.onreadystatechange = function() {
      if(request.readyState == 4 && request.status == 200){
        try{
        files[fileno] = request.responseText.split("\n");
        fileno++;
        if(fileno < num)
          loadfiles(fileno, callback);
        else {
          var start = 0;
          var symmetry, field;
          var row, col, val;
          var rows, cols, entries;
          var n = 0;
          for(var i = 0; i < num; i++){
            var temp = files[i];
            var index = 0;
            if(i == 0){
              var first = temp[0].split(" ");
              field = first[3];
              symmetry = first[4];
              while(temp[n][0] == "%")
                n++;
              info = temp[n++].split(" ");
              N = Number(info[0]);
              rows = Number(info[0]);
              cols = Number(info[1]);
              entries = Number(info[2]);
              console.log(rows, cols, entries);
              index = n;
              if(entries > Math.pow(2,27)){
                console.log("entries : cannot allocate this much");
                callback();
              }
              row = new Int32Array(entries);
              col = new Int32Array(entries);
              if(field != "pattern")
                val = new Float64Array(entries);
            }
            for(var j = start; index < temp.length - 1; index++){
              coord = temp[index].split(" ");
              row[j] = Number(coord[0]);
              col[j] = Number(coord[1]);
              if(symmetry == "symmetric"){
                if(field != "pattern"){
                  val[j] = Number(coord[2]);
                  if(val[j] < 0 || val[j] > 0){
                    if(row[j] == col[j])
                      anz++; 
                    else
                      anz = anz + 2;
                  }
                }
                else{
                  if(row[j] == col[j])
                    anz++; 
                  else
                    anz = anz + 2;
                } 
              }
              else{
                if(field != "pattern"){
                  val[j] = Number(coord[2]);
                  if(val[j] < 0 || val[j] > 0)
                    anz++;
                }
              }
              j++;
            }
            start = j;
          }
          if(anz == 0)
            anz = entries;
          console.log(anz);
          if(anz > Math.pow(2,28)){
            console.log("anz : cannot allocate this much");
            callback();
          }

          // Total Memory required  = COO + CSR + x + y 
          var total_length = Int32Array.BYTES_PER_ELEMENT * 3 * anz + Int32Array.BYTES_PER_ELEMENT * (N + 1)  + Float32Array.BYTES_PER_ELEMENT * 2 * anz + Float32Array.BYTES_PER_ELEMENT * 2 * N; 
          const bytesPerPage = 64 * 1024;
          var num_pages = Math.ceil((total_length + num_workers * Float32Array.BYTES_PER_ELEMENT * N)/bytesPerPage);
          console.log('num_pages ', num_pages);
          var max_pages = 16384;
          let memory = new WebAssembly.Memory({initial:num_pages, maximum: max_pages, shared:true});
          let buffer = memory.buffer;
          console.log(buffer instanceof SharedArrayBuffer);

          // COO memory allocation
          var coo_row_index = 0;
          let coo_row = new Int32Array(memory.buffer, coo_row_index, anz); 
          var coo_col_index = coo_row.byteLength; 
          let coo_col = new Int32Array(memory.buffer, coo_col_index, anz);
          var coo_val_index = coo_col_index + coo_col.byteLength;
          let coo_val = new Float32Array(memory.buffer, coo_val_index, anz);

          // CSR memory allocation
          var csr_row_index = coo_val_index + coo_val.byteLength;
          let csr_row = new Int32Array(memory.buffer, csr_row_index, N + 1);
          var csr_col_index = csr_row_index + csr_row.byteLength;
          let csr_col = new Int32Array(memory.buffer, csr_col_index, anz);
          var csr_val_index = csr_col_index + csr_col.byteLength;
          let csr_val = new Float32Array(memory.buffer, csr_val_index, anz);

          var t1, t2, tt = 0.0;
          if(symmetry == "symmetric"){
            if(field == "pattern"){
              for(var i = 0, n = 0; n < start; n++) {
                coo_row[i] = Number(row[n] - 1);
                coo_col[i] = Number(col[n] - 1);
                coo_val[i] = 1.0;
                if(row[n] == col[n])
                  i++;
                else{
                  coo_row[i+1] = Number(col[n] - 1);
                  coo_col[i+1] = Number(row[n] - 1);
                  coo_val[i+1] = 1.0;
                  i = i + 2;
                }
              } 
            }
            else{
              for(var i = 0, n = 0; n < start; n++) {
                if(val[n] < 0 || val[n] > 0){
                  coo_row[i] = Number(row[n] - 1);
                  coo_col[i] = Number(col[n] - 1);
                  coo_val[i] = Number(val[n]);
                  if(row[n] == col[n])
                    i++;
                  else{
                    coo_row[i+1] = Number(col[n] - 1);
                    coo_col[i+1] = Number(row[n] - 1);
                    coo_val[i+1] = Number(val[n]);
                    i = i + 2;
                  }
                }
              }
            }
          }
          else{
            if(field == "pattern"){
              for(var i = 0, n = 0; n < start; n++, i++) {
                coo_row[i] = Number(row[n] - 1);
                coo_col[i] = Number(col[n] - 1);
                coo_val[i] = 1.0;
              }
            }
            else{
              for(var i = 0, n = 0; n < start; n++) {
                if(val[n] < 0 || val[n] > 0){
                  coo_row[i] = Number(row[n] - 1);
                  coo_col[i] = Number(col[n] - 1);
                  coo_val[i] = Number(val[n]);
                  i++;
                }
              }
            }
          }
          
          // sort COO row-wise 
          quick_sort(coo_row, coo_col, coo_val, 0, anz-1);          
     
          //convert COO to CSR
          coo_csr(coo_row, coo_col, coo_val, N, anz, csr_row, csr_col, csr_val);

          //get DIA info
          var result = num_diags(N, csr_row, csr_col);
          var nd = result[0];
          var stride = result[1];

          //get ELL info
          var nc = num_cols(csr_row, N);

          //grow memory buffer size for DIA and ELL
          var dia_length = Int32Array.BYTES_PER_ELEMENT * nd + Float32Array.BYTES_PER_ELEMENT * nd * stride;
          var ell_length = Int32Array.BYTES_PER_ELEMENT * nc * N + Float32Array.BYTES_PER_ELEMENT * nc * N;
          var grow_num_pages = Math.ceil((dia_length + ell_length)/bytesPerPage);
          memory.grow(grow_num_pages);
          console.log('grow num pages', grow_num_pages);
          console.log(memory.buffer.byteLength / bytesPerPage);
          console.log(memory.buffer instanceof SharedArrayBuffer);

          //re-attach the CSR array buffers
          /* Note: Since an ArrayBuffer’s byteLength is immutable, 
          after a successful Memory.prototype.grow() operation the 
          buffer getter will return a new ArrayBuffer object 
          (with the new byteLength) and any previous ArrayBuffer 
          objects become “detached”, or disconnected from the 
          underlying memory they previously pointed to.*/
          csr_row = new Int32Array(memory.buffer, csr_row_index, N + 1);
          csr_col = new Int32Array(memory.buffer, csr_col_index, anz);
          csr_val = new Float32Array(memory.buffer, csr_val_index, anz);


          // DIA memory allocation
          var offset_index = csr_val_index + csr_val.byteLength;
          let offset = new Int32Array(memory.buffer, offset_index, nd);
          var dia_data_index = offset_index + offset.byteLength;
          let dia_data = new Float32Array(memory.buffer, dia_data_index, nd * stride);
          console.log("allocated memory");

          // ELL memory allocation
          var indices_index = dia_data_index + dia_data.byteLength;
          let indices = new Int32Array(memory.buffer, indices_index, nc * N);
          var ell_data_index = indices_index + indices.byteLength;
          let ell_data = new Float32Array(memory.buffer,ell_data_index, nc * N);

          //convert CSR to DIA
          csr_dia(csr_row, csr_col, csr_val, offset, dia_data, anz, N, stride);


          //convert CSR to ELL
          csr_ell(csr_row, csr_col, csr_val, indices, ell_data, nc, N);

          // vector x and y allocation
          var x_index = ell_data_index + ell_data.byteLength;
          console.log("x index is ", x_index);
          let x = new Float32Array(memory.buffer, x_index, cols);
          var y_index = x_index + x.byteLength;
          console.log("y index is ", y_index);
          let y = new Float32Array(memory.buffer, y_index, rows);

          // initialize x array
          for(var i = 0; i < N; i++){
            x[i] = i;
          } 

          var nnz_per_worker = Math.floor(anz/num_workers);
          var rem = anz - nnz_per_worker * num_workers;
          var N_per_worker = Math.floor(N/num_workers);
          var rem_N  = N - N_per_worker * num_workers;

          var pending_workers = num_workers;
          var t = 0;

          var w_y = new Array(num_workers); 
          var w = new Array(num_workers); 
          var w_y_index = new Array(num_workers);
          var temp = y_index + y.byteLength; 
          for(var i = 0; i < num_workers; i++){
            w_y_index[i] = temp;
            w_y[i] = new Float32Array(memory.buffer, temp, N);
            w[i] = new Worker('worker.js');
            temp += y.byteLength;
          }

          
          if(anz > 1000000) inside_max = 1;
          else if (anz > 100000) inside_max = 10;
          else if (anz > 50000) inside_max = 50;
          else if(anz > 10000) inside_max = 100;
          else if(anz > 2000) inside_max = 1000;
          else if(anz > 100) inside_max = 10000;
          console.log("inside max is ", inside_max);

          var my_instance;
          WebAssembly.compileStreaming(fetch('spmv_32.wasm'))
          .then(mod => {
            (async () => {
              let instance = WebAssembly.instantiate(mod, { js: { mem: memory }, console: {
              log: function(arg) {
                console.log(arg);
              }}});
              my_instance = await instance;
            })();
            for(var i = 0; i < num_workers; i++){
              w[i].postMessage([0, i, mod, memory]);
              w[i].onmessage = loaded;
            }

            function loaded(event){
              pending_workers -= 1;
              if(pending_workers <= 0){
                run_workers(0);
              }
            }

            function run_workers(format){
              pending_workers = num_workers;
              y.fill(0.0);
              for(var i = 0; i < num_workers; i++){
                w_y[i].fill(0.0);
              }
              if(format == 0){
                t1 = Date.now();
                for(var i = 0; i < num_workers; i++){
                  if(i == num_workers - 1)
                    w[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker + rem, coo_row_index, coo_col_index, coo_val_index, x_index, w_y_index[i], inside_max]);
                  else
                    w[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker, coo_row_index, coo_col_index, coo_val_index, x_index, w_y_index[i], inside_max]);
                  w[i].onmessage = storeCOO;
                }
              }
              else if(format == 1){
                t1 = Date.now();
                for(var i = 0; i < num_workers; i++){
                  if(i == num_workers - 1)
                    w[i].postMessage([2, i, i * N_per_worker, (i+1) * N_per_worker + rem_N, csr_row_index, csr_col_index, csr_val_index, x_index, y_index, inside_max]);
                  else
                    w[i].postMessage([2, i, i * N_per_worker, (i+1) * N_per_worker, csr_row_index, csr_col_index, csr_val_index, x_index, y_index, inside_max]);
                  w[i].onmessage = storeCSR;
                }
              }
              else if(format == 2){
                t1 = Date.now();
                for(var i = 0; i < num_workers; i++){
                  if(i == num_workers - 1)
                    w[i].postMessage([3, i, i * N_per_worker, (i+1) * N_per_worker + rem_N, offset_index, dia_data_index, nd, N, x_index, y_index, inside_max]);
                  else
                    w[i].postMessage([3, i, i * N_per_worker, (i+1) * N_per_worker, offset_index, dia_data_index, nd, N, x_index, y_index, inside_max]);
                  w[i].onmessage = storeDIA;
                }
              }
              else if(format == 3){
                t1 = Date.now();
                for(var i = 0; i < num_workers; i++){
                  if(i == num_workers - 1)
                    w[i].postMessage([4, i, i * N_per_worker, (i+1) * N_per_worker + rem_N, indices_index, ell_data_index, nc, N, x_index, y_index, inside_max]);
                  else
                    w[i].postMessage([4, i, i * N_per_worker, (i+1) * N_per_worker, indices_index, ell_data_index, nc, N, x_index, y_index, inside_max]);
                  w[i].onmessage = storeELL;
                }
              }
            }

            function storeCOO(event){
              pending_workers -= 1;
              if(pending_workers <= 0){
                my_date = Date.now();
                my_instance.exports.sum(y_index, y_index + y.byteLength, N, num_workers);
                t2 = Date.now();
                if(t >= 10){
                  coo_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inside_max/ ((t2 - t1)/1000);
                  //console.log(coo_flops[t-10]);
                  tt += t2 - t1;
                }
                t++;
                if(t < (outer_max + 10))
                  run_workers(0);
                else{
                  tt = tt/1000; 
                  coo_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inside_max/ tt;
                  variance = 0;
                  for(var i = 0; i < outer_max; i++)
                    variance += (coo_mflops - coo_flops[i]) * (coo_mflops - coo_flops[i]);
                  variance /= outer_max;
                  coo_sd = Math.sqrt(variance);
                  coo_sum = parseInt(fletcher_sum(y));
                  console.log('coo mflops is ', coo_mflops);
                  console.log("Returned to main thread");
                  t = 0, tt = 0.0;
                  run_workers(1);
                }
              }
            }

            function storeCSR(event){
              pending_workers -= 1;
              if(pending_workers <= 0){
                t2 = Date.now();
                if(t >= 10){
                  csr_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inside_max/ ((t2 - t1)/1000);
                  //console.log(csr_flops[t-10]);
                  tt += t2 - t1;
                }
                t++;
                if(t < (outer_max + 10))
                  run_workers(1);
                else{
                  tt = tt/1000; 
                  csr_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inside_max/ tt;
                  variance = 0;
                  for(var i = 0; i < outer_max; i++)
                    variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
                  variance /= outer_max;
                  csr_sd = Math.sqrt(variance);
                  csr_sum = parseInt(fletcher_sum(y));
                  console.log('csr mflops is ', csr_mflops);
                  console.log("Returned to main thread");
                  t = 0, tt = 0.0;
                  run_workers(2);
                }
              }
            }
            
            function storeDIA(event){
              pending_workers -= 1;
              if(pending_workers <= 0){
                t2 = Date.now();
                //console.log("TIME ", t1, t2, t2 - t1);
                if(t >= 10){
                  dia_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inside_max/ ((t2 - t1)/1000);
                  tt += t2 - t1;
                }
                t++;
                if(t < (outer_max + 10))
                  run_workers(2);
                else{
                  tt = tt/1000;
                  dia_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inside_max/ tt;
                  variance = 0;
                  for(var i = 0; i < outer_max; i++)
                    variance += (dia_mflops - dia_flops[i]) * (dia_mflops - dia_flops[i]);
                  variance /= outer_max;
                  dia_sd = Math.sqrt(variance);
                  dia_sum = parseInt(fletcher_sum(y));
                  console.log('dia mflops is ', dia_mflops);
                  console.log("Returned to main thread");
                  t = 0, tt = 0.0;
                  run_workers(3);
                }
              }
            }
           
            function storeELL(event){
              pending_workers -= 1;
              if(pending_workers <= 0){
                t2 = Date.now();
                if(t >= 10){
                  ell_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inside_max/ ((t2 - t1)/1000);
                  tt += t2 - t1;
                }
                t++;
                if(t < (outer_max + 10))
                  run_workers(3);
                else{
                  tt = tt/1000;
                  ell_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inside_max/ tt;
                  variance = 0;
                  for(var i = 0; i < outer_max; i++)
                    variance += (ell_mflops - ell_flops[i]) * (ell_mflops - ell_flops[i]);
                  variance /= outer_max;
                  ell_sd = Math.sqrt(variance);
                  ell_sum = parseInt(fletcher_sum(y));
                  console.log('ell mflops is ', ell_mflops);
                  console.log("Returned to main thread");
                  console.log("Done");
                  callback();
                }
              }
            }


          });
        }
        }
        catch(e){
          console.log('Error : ', e.stack);
          callback();
        }
      }
    } 
    request.open('GET', myname, true);
    request.send();
  }
  loadfiles(fileno, function(){
    callback();
  });
}
