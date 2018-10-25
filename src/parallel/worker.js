let instance, start, end, coo_row_index, coo_col_index, coo_val_index, x_index, y_index, inside_max;
onmessage = function(e) {
  if(e.data[0] == 0){
    let id = e.data[1];
    let mod = e.data[2];
    let memory = e.data[3];
    start = e.data[4];
    end = e.data[5];
    coo_row_index = start * 4 + e.data[6];
    coo_col_index = start * 4 + e.data[7];
    coo_val_index = start * 4 + e.data[8];
    x_index = e.data[9];
    y_index = e.data[10];
    inside_max = e.data[11];
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
    for(var j = 0; j < inside_max; j++)
    my_instance.exports.spmv_coo(id, coo_row_index, coo_col_index, coo_val_index, x_index, y_index, end-start);
    postMessage(id); 
  }
}
