let instance, start, end, coo_row_index, coo_col_index, coo_val_index, x_index, y_index, inside_max;
onmessage = function(e) {
  if(e.data[0] == 0){
    let id = e.data[1];
    let mod = e.data[2];
    let memory = e.data[3];
    (async () => {
    let instance = WebAssembly.instantiate(mod, { js: { mem: memory }, console: {
    log: function(arg) {
      console.log(arg);
    }}});
    my_instance = await instance;
    })(); 
    postMessage(id); 
  }
  if(e.data[0] == 1){
    let id = e.data[1];
    start = e.data[2];
    end = e.data[3];
    coo_row_index = start * 4 + e.data[4];
    coo_col_index = start * 4 + e.data[5];
    coo_val_index = start * 4 + e.data[6];
    x_index = e.data[7];
    y_index = e.data[8];
    inside_max = e.data[9];
    my_instance.exports.spmv_coo_wrapper(id, coo_row_index, coo_col_index, coo_val_index, x_index, y_index, end-start, inside_max);
    postMessage(id); 
  }
  if(e.data[0] == 2){
    let id = e.data[1];
    start = e.data[2];
    end = e.data[3];
    csr_row_index = start * 4 + e.data[4];
    csr_col_index = e.data[5];
    csr_val_index = e.data[6];
    x_index = e.data[7];
    y_index = start * 4 + e.data[8];
    inside_max = e.data[9];
    my_instance.exports.spmv_csr_wrapper(id, csr_row_index, csr_col_index, csr_val_index, x_index, y_index, end-start, inside_max);
    postMessage(id); 
  }
}
