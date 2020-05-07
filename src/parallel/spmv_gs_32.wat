(module
  (import "js" "mem" (memory 1 32767 shared))
  (import "console" "log" (func $logi (param i32)))
  (import "console" "log" (func $logf (param f32)))
  (func $spmv_coo (export "spmv_coo") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $this_y i32)
    (local $temp v128)
    (local $y_index v128)
    (local $x_index v128)
    (local $i i32)
    (local $j i32)
    local.get $len
    i32.const 0
    local.tee $i
    i32.le_s
    if
      (return)
    end
    (local.get $len)
    (i32.const 4)
    (i32.rem_u)
    (local.set $j)
    (i32.const 0)
    (local.get $j)
    (i32.lt_s)
    (if
      (then
      (loop $top
        (i32.add (local.get $y) (i32.shl (i32.load (local.get $coo_row)) (i32.const 2)))
        (local.tee $this_y)
        (f32.load (local.get $coo_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $coo_col)) (i32.const 2)))
        f32.load
        f32.mul
        (local.get $this_y)
        f32.load
        f32.add
        f32.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $j)
        i32.ne
        br_if $top
      )))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
      (then
      (loop $top1
        (v128.load (local.get $coo_val))

	(i32x4.splat(local.get $x))
	(v128.load (local.get $coo_col))
	(i32.const 2)
	(i32x4.shl)
	(i32x4.add)
	(local.set $x_index)
	(f32x4.replace_lane 0 (f32x4.splat(f32.const 0.0)) (f32.load (i32x4.extract_lane 0 (local.get $x_index))))
	(local.set $temp)
	(f32x4.replace_lane 1 (local.get $temp) (f32.load (i32x4.extract_lane 1 (local.get $x_index))))
	(local.set $temp)
	(f32x4.replace_lane 2 (local.get $temp) (f32.load (i32x4.extract_lane 2 (local.get $x_index))))
	(local.set $temp)
	(f32x4.replace_lane 3 (local.get $temp) (f32.load (i32x4.extract_lane 3 (local.get $x_index))))

        f32x4.mul
	(local.set $temp)

	(i32x4.splat(local.get $y))
	(v128.load (local.get $coo_row))
	(i32.const 2)
	(i32x4.shl)
	(i32x4.add)
	(local.set $y_index)

	(i32x4.extract_lane 0 (local.get $y_index))
	(f32.load (i32x4.extract_lane 0 (local.get $y_index)))
	(f32x4.extract_lane 0 (local.get $temp))
	(f32.add)
	(f32.store)
	(i32x4.extract_lane 1 (local.get $y_index))
	(f32.load (i32x4.extract_lane 1 (local.get $y_index)))
	(f32x4.extract_lane 1 (local.get $temp))
	(f32.add)
	(f32.store)
	(i32x4.extract_lane 2 (local.get $y_index))
	(f32.load (i32x4.extract_lane 2 (local.get $y_index)))
	(f32x4.extract_lane 2 (local.get $temp))
	(f32.add)
	(f32.store)
	(i32x4.extract_lane 3 (local.get $y_index))
	(f32.load (i32x4.extract_lane 3 (local.get $y_index)))
	(f32x4.extract_lane 3 (local.get $temp))
	(f32.add)
	(f32.store)

        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 16)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 16)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 16)))
        (local.tee $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $len)
        i32.ne
        br_if $top1
      )))
  )
  (func (export "sum") (param $y i32) (param $w i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local.tee $i (i32.const 0))
    (local.get $N)
    i32.ge_s
    if
      (return)
    end
    (loop $loop
      (local.get $y)
      (f32.load (local.get $y))
      (f32.load (local.get $w))
      f32.add
      f32.store
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (local.set $y (i32.add (local.get $y) (i32.const 4)))
      (local.set $w (i32.add (local.get $w) (i32.const 4)))
      (i32.ne (local.get $i) (local.get $N))
      (br_if $loop)
    )
  )
  (func (export "spmv_coo_wrapper") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $id
      local.get $coo_row
      local.get $coo_col
      local.get $coo_val
      local.get $x
      local.get $y
      local.get $len
      call $spmv_coo
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_csr (export "spmv_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $temp f32)
    (local $temp_v v128)
    (local $x_index v128)
    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (i32.load (local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load (local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)
    (loop $outer_loop
      (local.tee $j (i32.load (local.get $csr_rowptr)))
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
      (i32.lt_s)
      if
	(f32.const 0.0)
	f32x4.splat
	(local.set $temp_v)
        (f32.load (local.get $y))
        (local.set $temp)
        (i32.load (local.get $csr_rowptr))
        (local.get $j)
        (i32.sub)
        (i32.const 4)
	(i32.rem_u)
        (local.get $j)
        (i32.add)
        (local.set $k)
        (local.get $j)
        (local.get $k)
        (i32.lt_s)
        (if
	  (then
          (loop $inner_loop
            (f32.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
            (f32.load)
            (f32.mul)
            (local.get $temp)
            (f32.add)
            (local.set $temp)
	    (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
	    (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $k)
            (i32.ne)
            (br_if $inner_loop)
          )))
        (local.get $j)
        (i32.load (local.get $csr_rowptr))
        (i32.lt_s)
        (if
	  (then
          (loop $inner_loop1
            (v128.load (local.get $csr_val))

            (i32x4.splat(local.get $x))
            (v128.load (local.get $csr_col))
            (i32.const 2)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)
            (f32x4.replace_lane 3 
              (f32x4.replace_lane 2 
                (f32x4.replace_lane 1  
                  (f32x4.replace_lane 0 
	            (f32x4.splat(f32.const 0.0)) 
		    (f32.load (i32x4.extract_lane 0 (local.get $x_index)))
		  )
	          (f32.load (i32x4.extract_lane 1 (local.get $x_index)))
	        )
	        (f32.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
	      (f32.load (i32x4.extract_lane 3 (local.get $x_index)))
	    )

            f32x4.mul
            (local.get $temp_v)
	    f32x4.add
            (local.set $temp_v)


	    (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 16)))
	    (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 16)))
            (local.tee $j (i32.add (local.get $j) (i32.const 4)))
            (local.get $csr_rowptr)
	    (i32.load)
            (i32.ne)
            (br_if $inner_loop1)
	    )))
        (local.get $y)
        (local.get $temp)
	(f32x4.extract_lane 0 (local.get $temp_v))
	(f32.add)
	(f32x4.extract_lane 1 (local.get $temp_v))
	(f32.add)
	(f32x4.extract_lane 2 (local.get $temp_v))
	(f32.add)
	(f32x4.extract_lane 3 (local.get $temp_v))
	(f32.add)
        (f32.store)
	;;(f32x4.extract_lane 0
        ;;(local.get $temp_v)
	;;(v8x16.shuffle 8 9 10 11 12 13 14 15 24 25 26 27 28 29 30 31 (local.get $temp_v) (local.get $temp_v))
	;;(f32x4.add)
        ;;(local.tee $temp_v)
	;;(v8x16.shuffle 4 5 6 7 8 9 10 11 20 21 22 23 24 25 26 27 (local.get $temp_v) (local.get $temp_v))
	;;(f32x4.add)
	;;)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 4)))
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $outer_loop)
    )
  )
  (func (export "spmv_csr_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $csr_rowptr
      local.get $csr_col
      local.get $csr_val
      local.get $x
      local.get $y
      local.get $len
      call $spmv_csr
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_dia (export "spmv_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_diag i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $exp i32)
    (local.get $start_row)
    (local.get $num_diag)
    (i32.mul)
    (local.set $exp)
    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $num_diag) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
    (loop $outer_loop
      (local.set $i (i32.const 0)) 
      (f32.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))))
      (local.set $temp)
      (loop $inner_loop
        (i32.load (i32.add (local.get $offset) (i32.shl (local.get $i) (i32.const 2)))) 
        (local.get $start_row)
        (i32.add)
        (local.set $col)
        (if (i32.and (i32.ge_s (local.get $col) (i32.const 0)) (i32.lt_s (local.get $col) (local.get $N)))
          (then
            (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))
            f32.load
            (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 2)))
            f32.load
            f32.mul
            (local.get $temp)
            f32.add
            (local.set $temp)
          )
        )
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $num_diag)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))) 
      (local.get $temp)
      (f32.store)
      (local.set $exp (i32.add (local.get $exp) (local.get $num_diag)))
      (local.tee $start_row (i32.add (local.get $start_row) (i32.const 1)))
      (local.get $end_row)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_dia_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_diag i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $id
      local.get $offset
      local.get $data
      local.get $start_row
      local.get $end_row
      local.get $num_diag
      local.get $N
      local.get $x
      local.get $y
      call $spmv_dia
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_ell (export "spmv_ell") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $exp i32)
    (local.get $start_row)
    (local.get $num_cols)
    (i32.mul)
    (local.set $exp)
    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end
    (local.get $num_cols) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
    (loop $outer_loop
      (local.set $i (i32.const 0))
      (f32.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))))
      (local.set $temp)
      (loop $inner_loop
        (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
        local.set $col
        (if (i32.ge_s (local.get $col) (i32.const 0))
          (then
            (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))
            f32.load
            (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 2)))
            f32.load
            f32.mul
            (local.get $temp)
            f32.add
            (local.set $temp)
            (local.tee $i (i32.add (local.get $i) (i32.const 1)))
            (local.get $num_cols) 
            (i32.lt_s)
            (br_if $inner_loop)
          )
        )
      )
      (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))) 
      (local.get $temp)
      (f32.store)
      (local.set $exp (i32.add (local.get $exp) (local.get $num_cols)))
      (local.tee $start_row (i32.add (local.get $start_row) (i32.const 1)))
      (local.get $end_row)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_ell_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $id
      local.get $indices
      local.get $data
      local.get $start_row
      local.get $end_row
      local.get $num_cols
      local.get $N
      local.get $x
      local.get $y
      call $spmv_ell
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )


(func $spmv_diaII (export "spmv_diaII") (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $iend i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; N - 1
    (local $exp3 i32)
    (local $this_x i32)
    (local $this_y i32)
    (local $this_data i32)
    local.get $nd
    i32.const 0
    local.tee $i
    i32.le_s
    if
      (return)
    end
    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)
    (i32.const 0)
    (local.set $exp2)
    (i32.add (local.get $end_row) (i32.const 1))
    (local.set $end_row)
    (loop $outer_loop
      (i32.load (local.get $offset))
      local.set $k
      (if (result i32) (i32.lt_s (local.get $k) (i32.const 0))
        (then
          (i32.sub (local.get $exp2) (local.get $exp1))
          (local.set $exp3)
          (i32.sub (i32.const 0)(local.get $k))
        )
        (else
          i32.const 0
        )
      )
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      ) 
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          local.get $N
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      (local.set $iend)
      (if (i32.gt_s (local.get $iend) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $iend)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end_row))
        (then
      (local.get $iend)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $y) (i32.shl (local.get $n) (i32.const 2))) 
      (local.set $this_y)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (i32.add (local.get $x) (i32.shl (i32.add (local.get $n) (local.get $k)) (i32.const 2))) 
      (local.set $this_x)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
	(then
        (loop $inner_loop
	  (local.get $this_y)
	  (local.get $this_data)
          (f32.load)
	  (local.get $this_x)
          (f32.load)
          (f32.mul)
	  (f32.load (local.get $this_y))
          (f32.add)
          (f32.store)
	  (local.set $this_y (i32.add (local.get $this_y) (i32.const 4)))
	  (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
	  (local.set $this_x (i32.add (local.get $this_x) (i32.const 4)))
          (local.tee $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        )))
      (local.get $new_end)
      (local.get $iend)
      (i32.lt_s)
      (if
	(then
      (loop $inner_loop1
	(local.get $this_y)
	(local.get $this_data)
        (v128.load)
	(local.get $this_x)
        (v128.load)
        (f32x4.mul)
	(v128.load (local.get $this_y))
        (f32x4.add)
        (v128.store)
	(local.set $this_y (i32.add (local.get $this_y) (i32.const 16)))
	(local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
	(local.set $this_x (i32.add (local.get $this_x) (i32.const 16)))
        (local.tee $n (i32.add (local.get $n) (i32.const 4)))
        (local.get $iend)
        (i32.lt_s)
        (br_if $inner_loop1)
      )))))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nd)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_diaII_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $offset
      local.get $data
      local.get $start_row
      local.get $end_row
      local.get $nd
      local.get $N
      local.get $stride
      local.get $x
      local.get $y
      call $spmv_diaII
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_ellII (export "spmv_ellII") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $temp_v v128)
    (local $x_index v128)
    (local $exp i32)
    (local $row i32)
    (local $new_end_row i32)
    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end
    (local.get $num_cols)
    (i32.const 0)
    (i32.le_s)
    if
      (return)
    end
    (local.set $i (i32.const 0))
    (local.set $exp (i32.const 0))
    (loop $outer_loop
      (local.set $row (local.get $start_row))
      (local.get $end_row)
      (local.get $start_row)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $row)
      (i32.add)
      (local.set $new_end_row)
      (local.get $row)
      (local.get $new_end_row)
      (i32.lt_s)
      (if
	(then
        (loop $inner_loop
          (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 2))))
          local.set $col
          (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 2)))
          (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 2)))
          f32.load
          (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 2)))
          f32.load
          f32.mul
          (f32.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 2))))
          f32.add
          f32.store
          (local.tee $row (i32.add (local.get $row) (i32.const 1)))
          (local.get $new_end_row)
          (i32.lt_s)
          (br_if $inner_loop)
        )))
      (local.get $row)
      (local.get $end_row)
      (i32.lt_s)
      (if
	(then
        (loop $inner_loop1
          (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 2)))
          (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 2))))

          (i32x4.splat(local.get $x))
          (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 2))))
          (i32.const 2)
          (i32x4.shl)
          (i32x4.add)
          (local.set $x_index)
          (f32x4.replace_lane 0 (f32x4.splat(f32.const 0.0)) (f32.load (i32x4.extract_lane 0 (local.get $x_index))))
          (local.set $temp_v)
          (f32x4.replace_lane 1 (local.get $temp_v) (f32.load (i32x4.extract_lane 1 (local.get $x_index))))
          (local.set $temp_v)
          (f32x4.replace_lane 2 (local.get $temp_v) (f32.load (i32x4.extract_lane 2 (local.get $x_index))))
          (local.set $temp_v)
          (f32x4.replace_lane 3 (local.get $temp_v) (f32.load (i32x4.extract_lane 3 (local.get $x_index))))

          f32x4.mul
          (v128.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 2))))
	  f32x4.add
	  (v128.store)

          (local.tee $row (i32.add (local.get $row) (i32.const 4)))
          (local.get $end_row)
          (i32.lt_s)
          (br_if $inner_loop1)
	)))
      (local.set $exp (i32.add (local.get $exp) (local.get $N)))
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $num_cols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )


  (func (export "spmv_ellII_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $id
      local.get $indices
      local.get $data
      local.get $start_row
      local.get $end_row
      local.get $num_cols
      local.get $N
      local.get $x
      local.get $y
      call $spmv_ellII
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )
)  
