(module
  (import "js" "mem" (memory 1 32767 shared))
  (import "console" "log" (func $logi (param i32)))
  (import "console" "log" (func $logf (param f32)))
  (func $spmv_coo (export "spmv_coo") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    get_local $len
    i32.const 0
    tee_local $i
    i32.le_s
    if
      (return)
    end
    (loop $top
        (i32.add (get_local $y) (i32.shl (i32.load (get_local $coo_row)) (i32.const 2)))
        (f32.load (get_local $coo_val))
        (i32.add (get_local $x) (i32.shl (i32.load (get_local $coo_col)) (i32.const 2)))
        f32.load
        f32.mul
        (i32.add (get_local $y) (i32.shl (i32.load (get_local $coo_row)) (i32.const 2)))
        f32.load
        f32.add
        f32.store
        (set_local $coo_row (i32.add (get_local $coo_row) (i32.const 4)))
        (set_local $coo_col (i32.add (get_local $coo_col) (i32.const 4)))
        (set_local $coo_val (i32.add (get_local $coo_val) (i32.const 4)))
        (tee_local $i (i32.add (get_local $i) (i32.const 1)))
        (get_local $len)
        i32.ne
        br_if $top
    )
  )
  (func (export "sum") (param $y i32) (param $w i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (tee_local $i (i32.const 0))
    (get_local $N)
    i32.ge_s
    if
      (return)
    end
    (loop $loop
      (get_local $y)
      (f32.load (get_local $y))
      (f32.load (get_local $w))
      f32.add
      f32.store
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (set_local $y (i32.add (get_local $y) (i32.const 4)))
      (set_local $w (i32.add (get_local $w) (i32.const 4)))
      (i32.ne (get_local $i) (get_local $N))
      (br_if $loop)
    )
  )
  (func (export "spmv_coo_wrapper") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $id
      get_local $coo_row
      get_local $coo_col
      get_local $coo_val
      get_local $x
      get_local $y
      get_local $len
      call $spmv_coo
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_csr (export "spmv_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $j i32)
    (local $temp f32)
    (local $end i32)
    (get_local $len)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $outer_loop
      (i32.add (get_local $csr_rowptr) (i32.const 4))
      (i32.load)
      (tee_local $end)
      (i32.load (get_local $csr_rowptr))
      (tee_local $j)
      (i32.gt_s)
      if
        (f32.load (get_local $y))
        (set_local $temp)
        (loop $inner_loop
          (i32.add (get_local $csr_val) (i32.shl (get_local $j) (i32.const 2)))
          f32.load
          (i32.add (get_local $x) (i32.shl (i32.load (i32.add (get_local $csr_col) (i32.shl (get_local $j) (i32.const 2)))) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (get_local $temp)
          (f32.add)
          (set_local $temp)
          (tee_local $j (i32.add (get_local $j) (i32.const 1)))
          (get_local $end)
          (i32.ne)
          (br_if $inner_loop)
        )
        (get_local $y)
        (get_local $temp)
        (f32.store)
      end
      (set_local $y (i32.add (get_local $y) (i32.const 4)))
      (i32.add (get_local $csr_rowptr) (i32.const 4))
      (set_local $csr_rowptr)
      (tee_local $i (i32.add (get_local $i) (i32.const 1)))
      (get_local $len)
      (i32.ne)
      (br_if $outer_loop)
    )
  )
  (func (export "spmv_csr_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $csr_rowptr
      get_local $csr_col
      get_local $csr_val
      get_local $x
      get_local $y
      get_local $len
      call $spmv_csr
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_dia (export "spmv_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_diag i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $exp i32)
    (get_local $start_row)
    (get_local $num_diag)
    (i32.mul)
    (set_local $exp)
    (get_local $start_row)
    (get_local $end_row)
    i32.ge_s
    if
      (return)
    end 
    (get_local $num_diag) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
    (loop $outer_loop
      (set_local $i (i32.const 0)) 
      (f32.load (i32.add (get_local $y) (i32.shl (get_local $start_row) (i32.const 2))))
      (set_local $temp)
      (loop $inner_loop
        (i32.load (i32.add (get_local $offset) (i32.shl (get_local $i) (i32.const 2)))) 
        (get_local $start_row)
        (i32.add)
        (set_local $col)
        (if (i32.and (i32.ge_s (get_local $col) (i32.const 0)) (i32.lt_s (get_local $col) (get_local $N)))
          (then
            (i32.add (get_local $data) (i32.shl (i32.add (get_local $exp) (get_local $i)) (i32.const 2)))
            f32.load
            (i32.add (get_local $x) (i32.shl (get_local $col) (i32.const 2)))
            f32.load
            f32.mul
            (get_local $temp)
            f32.add
            (set_local $temp)
          )
        )
        (tee_local $i (i32.add (get_local $i) (i32.const 1)))
        (get_local $num_diag)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (i32.add (get_local $y) (i32.shl (get_local $start_row) (i32.const 2))) 
      (get_local $temp)
      (f32.store)
      (set_local $exp (i32.add (get_local $exp) (get_local $num_diag)))
      (tee_local $start_row (i32.add (get_local $start_row) (i32.const 1)))
      (get_local $end_row)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_dia_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_diag i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $id
      get_local $offset
      get_local $data
      get_local $start_row
      get_local $end_row
      get_local $num_diag
      get_local $N
      get_local $x
      get_local $y
      call $spmv_dia
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_ell (export "spmv_ell") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $exp i32)
    (get_local $start_row)
    (get_local $num_cols)
    (i32.mul)
    (set_local $exp)
    (get_local $start_row)
    (get_local $end_row)
    i32.ge_s
    if
      (return)
    end
    (get_local $num_cols) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
    (loop $outer_loop
      (set_local $i (i32.const 0))
      (f32.load (i32.add (get_local $y) (i32.shl (get_local $start_row) (i32.const 2))))
      (set_local $temp)
      (loop $inner_loop
        (i32.load (i32.add (get_local $indices) (i32.shl (i32.add (get_local $exp) (get_local $i)) (i32.const 2))))
        set_local $col
        (if (i32.ge_s (get_local $col) (i32.const 0))
          (then
            (i32.add (get_local $data) (i32.shl (i32.add (get_local $exp) (get_local $i)) (i32.const 2)))
            f32.load
            (i32.add (get_local $x) (i32.shl (get_local $col) (i32.const 2)))
            f32.load
            f32.mul
            (get_local $temp)
            f32.add
            (set_local $temp)
            (tee_local $i (i32.add (get_local $i) (i32.const 1)))
            (get_local $num_cols) 
            (i32.lt_s)
            (br_if $inner_loop)
          )
        )
      )
      (i32.add (get_local $y) (i32.shl (get_local $start_row) (i32.const 2))) 
      (get_local $temp)
      (f32.store)
      (set_local $exp (i32.add (get_local $exp) (get_local $num_cols)))
      (tee_local $start_row (i32.add (get_local $start_row) (i32.const 1)))
      (get_local $end_row)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_ell_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $id
      get_local $indices
      get_local $data
      get_local $start_row
      get_local $end_row
      get_local $num_cols
      get_local $N
      get_local $x
      get_local $y
      call $spmv_ell
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )


(func $spmv_diaII (export "spmv_diaII") (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $k i32)
    (local $istart i32)
    (local $iend i32)
    (local $index i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; N - 1
    (local $exp3 i32)
    get_local $nd
    i32.const 0
    tee_local $i
    i32.le_s
    if
      (return)
    end
    (get_local $N)
    (get_local $stride)
    (i32.sub)
    set_local $exp1
    (get_local $N)
    (i32.const 1)
    (i32.sub)
    (set_local $exp2)
    i32.const 0
    (set_local $exp3)
    (loop $outer_loop
      i32.const 0
      set_local $index
      (i32.load (get_local $offset))
      set_local $k
      (if (result i32) (i32.lt_s (get_local $k) (i32.const 0))
        (then
          get_local $exp1
          set_local $index
          (i32.sub (i32.const 0)(get_local $k))
        )
        (else
          i32.const 0
        )
      )
      (set_local $istart)
      (if (i32.lt_s (get_local $istart) (get_local $start_row))
        (then
          (get_local $start_row)
          (set_local $istart)
        )
      ) 
      (if (result i32) (i32.lt_s (get_local $exp2) (i32.sub (get_local $exp2) (get_local $k)))
        (then
          get_local $exp2
        )
        (else
          (i32.sub (get_local $exp2) (get_local $k))
        )
      )
      (set_local $iend)
      (if (i32.gt_s (get_local $iend) (get_local $end_row))
        (then
          (get_local $end_row)
          (set_local $iend)
        )
      )
      (get_local $istart)
      (get_local $iend)
      (i32.le_s)
      if
        (loop $inner_loop
          (i32.add (get_local $y) (i32.shl (get_local $istart) (i32.const 2)))
          (i32.add (get_local $data) (i32.shl (i32.sub (i32.add (get_local $exp3) (get_local $istart)) (get_local $index)) (i32.const 2)))
          (f32.load)
          (i32.add (get_local $x) (i32.shl (i32.add (get_local $istart) (get_local $k)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (f32.load (i32.add (get_local $y) (i32.shl (get_local $istart) (i32.const 2))))
          (f32.add)
          (f32.store)
          (tee_local $istart (i32.add (get_local $istart) (i32.const 1)))
          (get_local $iend)
          (i32.le_s)
          (br_if $inner_loop)
        )
      end
      (set_local $exp3 (i32.add (get_local $exp3) (get_local $stride)))
      (set_local $offset (i32.add (get_local $offset) (i32.const 4)))
      (tee_local $i (i32.add (get_local $i) (i32.const 1)))
      (get_local $nd)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_diaII_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $offset
      get_local $data
      get_local $start_row
      get_local $end_row
      get_local $nd
      get_local $N
      get_local $stride
      get_local $x
      get_local $y
      call $spmv_diaII
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_ellII (export "spmv_ellII") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $exp i32)
    (local $row i32)
    (get_local $start_row)
    (get_local $end_row)
    i32.ge_s
    if
      (return)
    end
    (get_local $num_cols)
    (i32.const 0)
    (i32.le_s)
    if
      (return)
    end
    (set_local $i (i32.const 0))
    (set_local $exp (i32.const 0))
    (loop $outer_loop
      (set_local $row (get_local $start_row))
      (loop $inner_loop
        (i32.load (i32.add (get_local $indices) (i32.shl (i32.add (get_local $exp) (get_local $row)) (i32.const 2))))
        set_local $col
        (if (i32.ge_s (get_local $col) (i32.const 0))
          (then
            (i32.add (get_local $y) (i32.shl (get_local $row) (i32.const 2)))
            (i32.add (get_local $data) (i32.shl (i32.add (get_local $exp) (get_local $row)) (i32.const 2)))
            f32.load
            (i32.add (get_local $x) (i32.shl (get_local $col) (i32.const 2)))
            f32.load
            f32.mul
            (f32.load (i32.add (get_local $y) (i32.shl (get_local $row) (i32.const 2))))
            f32.add
            f32.store
          )
        )
        (tee_local $row (i32.add (get_local $row) (i32.const 1)))
        (get_local $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (set_local $exp (i32.add (get_local $exp) (get_local $N)))
      (tee_local $i (i32.add (get_local $i) (i32.const 1)))
      (get_local $num_cols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )


  (func (export "spmv_ellII_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $id
      get_local $indices
      get_local $data
      get_local $start_row
      get_local $end_row
      get_local $num_cols
      get_local $N
      get_local $x
      get_local $y
      call $spmv_ellII
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )
)  
