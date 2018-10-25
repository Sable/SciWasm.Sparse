(module
  (import "js" "mem" (memory 1 16384 shared))
  (import "console" "log" (func $log (param f32)))
  (func (export "spmv_coo") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (set_local $i (i32.const 0))
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
  (func (export "sum") (param $y i32) (param $w i32) (param $N i32) (param $num_workers i32)
    (local $i i32)
    (local $j i32)
    (local $temp i32)
    (set_local $i (i32.const 0))
    (set_local $temp (get_local $y))
    (block $workers (loop $outer
      (br_if $workers (i32.eq (get_local $i) (get_local $num_workers)))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (set_local $j (i32.const 0))
        (block $break (loop $inner
          (br_if $break (i32.eq (get_local $j) (get_local $N)))
          (get_local $y)
          (f32.load (get_local $y))
          (f32.load (get_local $w))
          f32.add
          f32.store
          (set_local $j (i32.add (get_local $j) (i32.const 1)))
          (set_local $y (i32.add (get_local $y) (i32.const 4)))
          (set_local $w (i32.add (get_local $w) (i32.const 4)))
          (br $inner)
        ))
      (set_local $y (get_local $temp))
      (br $outer)
    ))
  )
)
