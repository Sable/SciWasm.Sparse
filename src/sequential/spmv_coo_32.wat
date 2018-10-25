(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $log (param f32)))
  (func (export "spmv_coo") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $len)))        
        (i32.add (get_local $y) (i32.mul (i32.load (get_local $coo_row)) (i32.const 4))) 
        (f32.load (get_local $coo_val))
        (i32.add (get_local $x) (i32.mul (i32.load (get_local $coo_col)) (i32.const 4)))
        f32.load 
        f32.mul 
        (f32.load (i32.add (get_local $y) (i32.mul (i32.load (get_local $coo_row)) (i32.const 4)))) 
        f32.add
        f32.store
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (set_local $coo_row (i32.add (get_local $coo_row) (i32.const 4)))
        (set_local $coo_col (i32.add (get_local $coo_col) (i32.const 4)))
        (set_local $coo_val (i32.add (get_local $coo_val) (i32.const 4)))
        (br $top)
    ))
  )
)
