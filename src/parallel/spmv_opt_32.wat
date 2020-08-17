(module
  (import "js" "mem" (memory 1 32767 shared))
  (import "console" "log" (func $logi (param i32)))
  (import "console" "log" (func $logf (param f32)))


  ;; SpMV COO initial implementation 
  (func $spmv_coo (export "spmv_coo") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $this_y i32)
    (local $i i32)
    local.get $len
    i32.const 0
    local.tee $i
    i32.le_s
    if
      (return)
    end
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
        (local.get $len)
        i32.ne
        br_if $top
    )
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

  ;; SpMV COO implementation unrolled with factor 2
  (func $spmv_coo_unroll2 (export "spmv_coo_unroll2") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $this_y i32)
    (local $i i32)
    local.get $len
    i32.const 0
    local.tee $i
    i32.le_s
    if
      (return)
    end
    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (i32.const 0)
    (i32.ne)
    (if
      (then
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
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
      )
    )
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
        (i32.add (local.get $y) (i32.shl (i32.load (i32.add (local.get $coo_row) (i32.const 4))) (i32.const 2)))
        (local.tee $this_y)
        (f32.load (i32.add (local.get $coo_val) (i32.const 4)))
        (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $coo_col) (i32.const 4))) (i32.const 2)))
        f32.load
        f32.mul
        (local.get $this_y)
        f32.load
        f32.add
        f32.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 8)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 8)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        i32.ne
        br_if $top
    )
  )

  (func (export "spmv_coo_unroll2_wrapper") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
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
      call $spmv_coo_unroll2
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

   (func $spmv_coo_gs (export "spmv_coo_gs") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
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

  (func (export "spmv_coo_gs_wrapper") (param $id i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
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
      call $spmv_coo_gs
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )



  ;; SpMV CSR initial implementation
  (func $spmv_csr (export "spmv_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $j i32)
    (local $temp f32)
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
    (local.set $j (i32.load (local.get $csr_rowptr)))
    (loop $outer_loop
      (local.get $j)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
      (i32.lt_s)
      if
        (f32.load (local.get $y))
        (local.set $temp)
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
          (local.get $csr_rowptr)
	  (i32.load)
          (i32.ne)
          (br_if $inner_loop)
        )
        (local.get $y)
        (local.get $temp)
        (f32.store)
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

  ;; SpMV CSR sorted with special code for short rows implementation
  (func $spmv_csr_short_rows (export "spmv_csr_short_rows") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32)
    (local $i i32)
    (local $j i32)
    (local $temp f32)

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

    (local.get $one)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $one)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $one) (i32.const 2))))
      (loop $outer_loop_one
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (f32.store)
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $one)
        (i32.ne)
        (br_if $outer_loop_one)
      )
    ))

    (local.get $two)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $two)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $two) (i32.const 2))))
      (loop $outer_loop_two
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $two)
        (i32.ne)
        (br_if $outer_loop_two)
      )
    ))

    (local.get $three)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $three)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $three) (i32.const 2))))
      (loop $outer_loop_three
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $three)
        (i32.ne)
        (br_if $outer_loop_three)
      )
    ))

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end



    (local.set $j (i32.load (local.get $csr_rowptr)))
    (loop $outer_loop
      (local.get $j)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
      (i32.lt_s)
      if
        (f32.load (local.get $y))
        (local.set $temp)
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
          (local.get $csr_rowptr)
          (i32.load)
          (i32.ne)
          (br_if $inner_loop)
        )
        (local.get $y)
        (local.get $temp)
        (f32.store)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 4)))
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $outer_loop)
    )
  )
  (func (export "spmv_csr_short_rows_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32) (param $inside_max i32)
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
      local.get $one
      local.get $two
      local.get $three
      call $spmv_csr_short_rows
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )


  ;; SpMV CSR implementation unrolled with factor 2 and special code for short rows : 1, 2, 3
  (func $spmv_csr_unroll2 (export "spmv_csr_unroll2") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32)
    (local $i i32)
    (local $j i32)
    (local $j1 i32)
    (local $j2 i32)
    (local $first i32)
    (local $second i32)
    (local $temp1 f32)
    (local $temp2 f32)
    (local $y2 i32)
    (local $csr_col2 i32)
    (local $csr_val2 i32)

    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $one)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $one)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $one) (i32.const 2))))
      (loop $outer_loop_one
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (f32.store)
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $one)
        (i32.ne)
        (br_if $outer_loop_one)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $two)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $two)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $two) (i32.const 2))))
      (loop $outer_loop_two
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        
	 (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $two)
        (i32.ne)
        (br_if $outer_loop_two)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $three)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $three)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $three) (i32.const 2))))
      (loop $outer_loop_three
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $three)
        (i32.ne)
        (br_if $outer_loop_three)
      )
    ))


    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    ;;(local.get $len)
    ;;(call $logi)
    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      (local.set $j (i32.load (local.get $csr_rowptr)))
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (f32.load (local.get $y))
      (local.set $temp1)
      (loop $inner_loop_odd
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp1)
        (f32.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
        (local.get $csr_rowptr)
        (i32.load)
        (i32.ne)
        (br_if $inner_loop_odd)
      )
      (local.get $y)
      (local.get $temp1)
      (f32.store)
      (local.set $y (i32.add (local.get $y) (i32.const 4)))
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ge_s)
      if
        (return)
      end
      )
    )
    (i32.load (local.get $csr_rowptr))
    (local.set $first)
    (loop $outer_loop
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j1)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 8))))
      (local.tee $first)
      (local.get $second)
      (i32.sub)
      (local.set $j2)
      ;;(local.get $j1)
      ;;(call $logi)
      ;;(local.get $j2)
      ;;(call $logi)
      (i32.add (local.get $y) (i32.const 4))
      (local.set $y2)
      (f32.load (local.get $y))
      (local.set $temp1)
      (f32.load (local.get $y2))
      (local.set $temp2)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 2))))
      (i32.const 0)
      (local.set $j)
  
       (loop $inner_loop_jam
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp1)
        (f32.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp2)
        (f32.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
        (local.get $j1)
        (i32.ne)
        (br_if $inner_loop_jam)
      )
      (local.get $j1)
      (local.get $j2)
      (i32.ne)
      (if
        (then
        (loop $inner_loop2
          (f32.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp2)
          (f32.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j2)
            (i32.ne)
            (br_if $inner_loop2)
        )
      ))
      (local.get $y)
      (local.get $temp1)
      (f32.store)
      (local.get $y2)
      (local.get $temp2)
      (f32.store)
      (local.set $csr_col (local.get $csr_col2))
      (local.set $csr_val (local.get $csr_val2))
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
      (local.tee $i (i32.add (local.get $i) (i32.const 2)))
      (local.get $len)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )
  (func (export "spmv_csr_unroll2_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32) (param $inside_max i32)
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
      local.get $one
      local.get $two
      local.get $three
      call $spmv_csr_unroll2
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  ;; SpMV CSR implementation unrolled with factor 3 and special code for short rows : 1, 2, 3
  (func $spmv_csr_unroll3 (export "spmv_csr_unroll3") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $j1 i32)
    (local $j2 i32)
    (local $j3 i32)
    (local $first i32)
    (local $second i32)
    (local $third i32)
    (local $temp1 f32)
    (local $temp2 f32)
    (local $temp3 f32)
    (local $y2 i32)
    (local $y3 i32)
    (local $csr_col2 i32)
    (local $csr_val2 i32)
    (local $csr_col3 i32)
    (local $csr_val3 i32)

    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $one)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $one)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $one) (i32.const 2))))
      (loop $outer_loop_one
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (f32.store)
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $one)
        (i32.ne)
        (br_if $outer_loop_one)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $two)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $two)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $two) (i32.const 2))))
      (loop $outer_loop_two
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        
	 (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $two)
        (i32.ne)
        (br_if $outer_loop_two)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $three)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $three)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $three) (i32.const 2))))
      (loop $outer_loop_three
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $three)
        (i32.ne)
        (br_if $outer_loop_three)
      )
    ))


    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    ;;(local.get $len)
    ;;(call $logi)
    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $len)
    (i32.const 3)
    (i32.rem_u)
    (local.set $k)
    (local.get $k)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      (loop $outer_loop_odd
        (local.tee $j (i32.load (local.get $csr_rowptr)))
        (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
        (i32.lt_s)
        (if
          (then
          (f32.load (local.get $y))
          (local.set $temp1)
          (loop $inner_loop_odd
            (f32.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
            (f32.load)
            (f32.mul)
            (local.get $temp1)
            (f32.add)
            (local.set $temp1)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $csr_rowptr)
            (i32.load)
            (i32.ne)
            (br_if $inner_loop_odd)
          )
          (local.get $y)
          (local.get $temp1)
          (f32.store)
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $k)
        (i32.lt_s)
        (br_if $outer_loop_odd)
      )
      (local.get $i)
      (local.get $len)
      (i32.ge_s)
      if
        (return)
      end
      )
    )

    (i32.load (local.get $csr_rowptr))
    (local.set $first)
    (loop $outer_loop
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j1)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 8)))
      (local.tee $third)
      (local.get $second)
      (i32.sub)
      (local.set $j2)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 12))))
      (local.tee $first)
      (local.get $third)
      (i32.sub)
      (local.set $j3)
      (i32.add (local.get $y) (i32.const 4))
      (local.set $y2)
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y3)
      (f32.load (local.get $y))
      (local.set $temp1)
      (f32.load (local.get $y2))
      (local.set $temp2)
      (f32.load (local.get $y3))
      (local.set $temp3)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_col3 (i32.add (local.get $csr_col2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_val3 (i32.add (local.get $csr_val2) (i32.shl (local.get $j2) (i32.const 2))))
      (i32.const 0)
      (local.set $j)
      (loop $inner_loop_jam
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp1)
        (f32.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp2)
        (f32.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

	(f32.load (local.get $csr_val3))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp3)
        (f32.add)
        (local.set $temp3)
        (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
        (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
        (local.get $j1)
        (i32.ne)
        (br_if $inner_loop_jam)
      )
      (local.get $j1)
      (local.get $j2)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_2
          (f32.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp2)
          (f32.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

          (f32.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp3)
          (f32.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j2)
          (i32.ne)
          (br_if $inner_loop_peel_2)
        ))
      )
      (local.get $j2)
      (local.get $j3)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_3
          (f32.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp3)
          (f32.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j3)
          (i32.ne)
          (br_if $inner_loop_peel_3)
        ))
      )
      (local.get $y)
      (local.get $temp1)
      (f32.store)
      (local.get $y2)
      (local.get $temp2)
      (f32.store)
      (local.get $y3)
      (local.get $temp3)
      (f32.store)
      (local.set $csr_col (local.get $csr_col3))
      (local.set $csr_val (local.get $csr_val3))
      (local.set $y (i32.add (local.get $y) (i32.const 12)))
      (local.tee $i (i32.add (local.get $i) (i32.const 3)))
      (local.get $len)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_csr_unroll3_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32) (param $inside_max i32)
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
      local.get $one
      local.get $two
      local.get $three
      call $spmv_csr_unroll3
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )


  ;; SpMV CSR implementation unrolled with factor 4 and special code for short rows : 1, 2, 3
  (func $spmv_csr_unroll4 (export "spmv_csr_unroll4") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $j1 i32)
    (local $j2 i32)
    (local $j3 i32)
    (local $j4 i32)
    (local $first i32)
    (local $second i32)
    (local $temp1 f32)
    (local $temp2 f32)
    (local $temp3 f32)
    (local $temp4 f32)
    (local $y2 i32)
    (local $y3 i32)
    (local $y4 i32)
    (local $csr_col2 i32)
    (local $csr_val2 i32)
    (local $csr_col3 i32)
    (local $csr_val3 i32)
    (local $csr_col4 i32)
    (local $csr_val4 i32)

    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $one)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $one)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $one) (i32.const 2))))
      (loop $outer_loop_one
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (f32.store)
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $one)
        (i32.ne)
        (br_if $outer_loop_one)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $two)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $two)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $two) (i32.const 2))))
      (loop $outer_loop_two
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

         (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $two)
        (i32.ne)
        (br_if $outer_loop_two)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $three)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $three)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $three) (i32.const 2))))
      (loop $outer_loop_three
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $three)
        (i32.ne)
        (br_if $outer_loop_three)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    ;;(local.get $len)
    ;;(call $logi)
    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $len)
    (i32.const 4)
    (i32.rem_u)
    (local.set $k)
    (local.get $k)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      (loop $outer_loop_odd
        (local.tee $j (i32.load (local.get $csr_rowptr)))
        (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
        (i32.lt_s)
        (if
          (then
          (f32.load (local.get $y))
          (local.set $temp1)
          (loop $inner_loop_odd
            (f32.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
            (f32.load)
            (f32.mul)
            (local.get $temp1)
            (f32.add)
            (local.set $temp1)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $csr_rowptr)
            (i32.load)
            (i32.ne)
            (br_if $inner_loop_odd)
          )
          (local.get $y)
          (local.get $temp1)
          (f32.store)
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $k)
        (i32.lt_s)
        (br_if $outer_loop_odd)
      )
      (local.get $i)
      (local.get $len)
      (i32.ge_s)
      if
        (return)
      end
      )
    )

    (i32.load (local.get $csr_rowptr))
    (local.set $first)
    (loop $outer_loop
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j1)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 8)))
      (local.tee $first)
      (local.get $second)
      (i32.sub)
      (local.set $j2)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 12)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j3)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 16))))
      (local.tee $first)
      (local.get $second)
      (i32.sub)
      (local.set $j4)
      (i32.add (local.get $y) (i32.const 4))
      (local.set $y2)
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y3)
      (i32.add (local.get $y) (i32.const 12))
      (local.set $y4)
      (f32.load (local.get $y))
      (local.set $temp1)
      (f32.load (local.get $y2))
      (local.set $temp2)
      (f32.load (local.get $y3))
      (local.set $temp3)
      (f32.load (local.get $y4))
      (local.set $temp4)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_col3 (i32.add (local.get $csr_col2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_val3 (i32.add (local.get $csr_val2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_col4 (i32.add (local.get $csr_col3) (i32.shl (local.get $j3) (i32.const 2))))
      (local.set $csr_val4 (i32.add (local.get $csr_val3) (i32.shl (local.get $j3) (i32.const 2))))
      (i32.const 0)
      (local.set $j)
      (loop $inner_loop_jam
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp1)
        (f32.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp2)
        (f32.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

        (f32.load (local.get $csr_val3))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp3)
        (f32.add)
        (local.set $temp3)
        (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
        (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

	(f32.load (local.get $csr_val4))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp4)
        (f32.add)
        (local.set $temp4)
        (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
        (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))


        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
        (local.get $j1)
        (i32.ne)
        (br_if $inner_loop_jam)
      )
      (local.get $j1)
      (local.get $j2)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_2
          (f32.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp2)
          (f32.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

          (f32.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp3)
          (f32.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

	  (f32.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp4)
          (f32.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j2)
          (i32.ne)
          (br_if $inner_loop_peel_2)
        ))
      )
      (local.get $j2)
      (local.get $j3)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_3
          (f32.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp3)
          (f32.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

          (f32.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp4)
          (f32.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j3)
          (i32.ne)
          (br_if $inner_loop_peel_3)
        ))
      )
      (local.get $j3)
      (local.get $j4)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_4
          (f32.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp4)
          (f32.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j4)
          (i32.ne)
          (br_if $inner_loop_peel_4)
        ))
      )
      (local.get $y)
      (local.get $temp1)
      (f32.store)
      (local.get $y2)
      (local.get $temp2)
      (f32.store)
      (local.get $y3)
      (local.get $temp3)
      (f32.store)
      (local.get $y4)
      (local.get $temp4)
      (f32.store)
      (local.set $csr_col (local.get $csr_col4))
      (local.set $csr_val (local.get $csr_val4))
      (local.set $y (i32.add (local.get $y) (i32.const 16)))
      (local.tee $i (i32.add (local.get $i) (i32.const 4)))
      (local.get $len)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )


  (func (export "spmv_csr_unroll4_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32) (param $inside_max i32)
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
      local.get $one
      local.get $two
      local.get $three
      call $spmv_csr_unroll4
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

   ;; SpMV CSR implementation unrolled with factor 6 and special code for short rows : 1, 2, 3
  (func $spmv_csr_unroll6 (export "spmv_csr_unroll6") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $j1 i32)
    (local $j2 i32)
    (local $j3 i32)
    (local $j4 i32)
    (local $j5 i32)
    (local $j6 i32)
    (local $first i32)
    (local $second i32)
    (local $temp1 f32)
    (local $temp2 f32)
    (local $temp3 f32)
    (local $temp4 f32)
    (local $temp5 f32)
    (local $temp6 f32)
    (local $y2 i32)
    (local $y3 i32)
    (local $y4 i32)
    (local $y5 i32)
    (local $y6 i32)
    (local $csr_col2 i32)
    (local $csr_val2 i32)
    (local $csr_col3 i32)
    (local $csr_val3 i32)
    (local $csr_col4 i32)
    (local $csr_val4 i32)
    (local $csr_col5 i32)
    (local $csr_val5 i32)
    (local $csr_col6 i32)
    (local $csr_val6 i32)

    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load(local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $one)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $one)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $one) (i32.const 2))))
      (loop $outer_loop_one
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (f32.store)
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $one)
        (i32.ne)
        (br_if $outer_loop_one)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $two)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $two)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $two) (i32.const 2))))
      (loop $outer_loop_two
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

         (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $two)
        (i32.ne)
        (br_if $outer_loop_two)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $three)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      ;;(local.get $three)
      ;;(call $logi)
      (i32.const 0)
      (local.set $i)
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.shl (local.get $three) (i32.const 2))))
      (loop $outer_loop_three
        (local.get $y)
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.load (local.get $y))
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (f32.add)
        (f32.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $three)
        (i32.ne)
        (br_if $outer_loop_three)
      )
    ))

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    ;;(local.get $len)
    ;;(call $logi)
    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    ;;(local.get $csr_col)
    ;;(call $logi)
    ;;(local.get $csr_val)
    ;;(call $logi)

    (local.get $len)
    (i32.const 6)
    (i32.rem_u)
    (local.set $k)
    (local.get $k)
    (i32.const 0)
    (i32.ne)
    (if
      (then
      (loop $outer_loop_odd
        (local.tee $j (i32.load (local.get $csr_rowptr)))
        (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
        (i32.lt_s)
        (if
          (then
          (f32.load (local.get $y))
          (local.set $temp1)
          (loop $inner_loop_odd
            (f32.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
            (f32.load)
            (f32.mul)
            (local.get $temp1)
            (f32.add)
            (local.set $temp1)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $csr_rowptr)
            (i32.load)
            (i32.ne)
            (br_if $inner_loop_odd)
          )
          (local.get $y)
          (local.get $temp1)
          (f32.store)
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 4)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $k)
        (i32.lt_s)
        (br_if $outer_loop_odd)
      )
      (local.get $i)
      (local.get $len)
      (i32.ge_s)
      if
        (return)
      end
      )
    )

    (i32.load (local.get $csr_rowptr))
    (local.set $first)
    (loop $outer_loop
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j1)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 8)))
      (local.tee $first)
      (local.get $second)
      (i32.sub)
      (local.set $j2)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 12)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j3)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 16)))
      (local.tee $first)
      (local.get $second)
      (i32.sub)
      (local.set $j4)
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 20)))
      (local.tee $second)
      (local.get $first)
      (i32.sub)
      (local.set $j5)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 24))))
      (local.tee $first)
      (local.get $second)
      (i32.sub)
      (local.set $j6)
      (i32.add (local.get $y) (i32.const 4))
      (local.set $y2)
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y3)
      (i32.add (local.get $y) (i32.const 12))
      (local.set $y4)
      (i32.add (local.get $y) (i32.const 16))
      (local.set $y5)
      (i32.add (local.get $y) (i32.const 20))
      (local.set $y6)
      (f32.load (local.get $y))
      (local.set $temp1)
      (f32.load (local.get $y2))
      (local.set $temp2)
      (f32.load (local.get $y3))
      (local.set $temp3)
      (f32.load (local.get $y4))
      (local.set $temp4)
      (f32.load (local.get $y5))
      (local.set $temp5)
      (f32.load (local.get $y6))
      (local.set $temp6)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_col3 (i32.add (local.get $csr_col2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_val3 (i32.add (local.get $csr_val2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_col4 (i32.add (local.get $csr_col3) (i32.shl (local.get $j3) (i32.const 2))))
      (local.set $csr_val4 (i32.add (local.get $csr_val3) (i32.shl (local.get $j3) (i32.const 2))))
      (local.set $csr_col5 (i32.add (local.get $csr_col4) (i32.shl (local.get $j4) (i32.const 2))))
      (local.set $csr_val5 (i32.add (local.get $csr_val4) (i32.shl (local.get $j4) (i32.const 2))))
      (local.set $csr_col6 (i32.add (local.get $csr_col5) (i32.shl (local.get $j5) (i32.const 2))))
      (local.set $csr_val6 (i32.add (local.get $csr_val5) (i32.shl (local.get $j5) (i32.const 2))))
      (i32.const 0)
      (local.set $j)
      (loop $inner_loop_jam
        (f32.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp1)
        (f32.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))

        (f32.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp2)
        (f32.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

        (f32.load (local.get $csr_val3))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp3)
        (f32.add)
        (local.set $temp3)
        (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
        (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

        (f32.load (local.get $csr_val4))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp4)
        (f32.add)
        (local.set $temp4)
        (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
        (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))

	(f32.load (local.get $csr_val5))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp5)
        (f32.add)
        (local.set $temp5)
        (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
        (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 4)))

        (f32.load (local.get $csr_val6))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 2)))
        (f32.load)
        (f32.mul)
        (local.get $temp6)
        (f32.add)
        (local.set $temp6)
        (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
        (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 4)))


        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
        (local.get $j1)
        (i32.ne)
        (br_if $inner_loop_jam)
      )
      (local.get $j1)
      (local.get $j2)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_2
          (f32.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp2)
          (f32.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 4)))

	  (f32.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp3)
          (f32.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

          (f32.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp4)
          (f32.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))

          (f32.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp5)
          (f32.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 4)))

          (f32.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp6)
          (f32.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j2)
          (i32.ne)
          (br_if $inner_loop_peel_2)
        ))
      )
      (local.get $j2)
      (local.get $j3)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_3
          (f32.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp3)
          (f32.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 4)))

          (f32.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp4)
          (f32.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))

          (f32.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp5)
          (f32.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 4)))

          (f32.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp6)
          (f32.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j3)
          (i32.ne)
          (br_if $inner_loop_peel_3)
        ))
      )
      (local.get $j3)
      (local.get $j4)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_4
          (f32.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp4)
          (f32.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 4)))

          (f32.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp5)
          (f32.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 4)))

          (f32.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp6)
          (f32.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j4)
          (i32.ne)
          (br_if $inner_loop_peel_4)
        ))
      )
      (local.get $j4)
      (local.get $j5)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_5
          (f32.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp5)
          (f32.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 4)))

          (f32.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp6)
          (f32.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 4)))

          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j5)
          (i32.ne)
          (br_if $inner_loop_peel_5)
        ))
      )
      (local.get $j5)
      (local.get $j6)
      (i32.ne)
      (if
        (then
        (loop $inner_loop_peel_6
          (f32.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 2)))
          (f32.load)
          (f32.mul)
          (local.get $temp6)
          (f32.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 4)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j6)
          (i32.ne)
          (br_if $inner_loop_peel_6)
        ))
      )
      (local.get $y)
      (local.get $temp1)
      (f32.store)
      (local.get $y2)
      (local.get $temp2)
      (f32.store)
      (local.get $y3)
      (local.get $temp3)
      (f32.store)
      (local.get $y4)
      (local.get $temp4)
      (f32.store)
      (local.get $y5)
      (local.get $temp5)
      (f32.store)
      (local.get $y6)
      (local.get $temp6)
      (f32.store)
      (local.set $csr_col (local.get $csr_col6))
      (local.set $csr_val (local.get $csr_val6))
      (local.set $y (i32.add (local.get $y) (i32.const 24)))
      (local.tee $i (i32.add (local.get $i) (i32.const 6)))
      (local.get $len)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )


  (func (export "spmv_csr_unroll6_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32) (param $inside_max i32)
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
      local.get $one
      local.get $two
      local.get $three
      call $spmv_csr_unroll6
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )


  (func $spmv_csr_gs (export "spmv_csr_gs") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32)
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
            ;;(local.set $temp_v)
            ;;(local.get $temp)
            ;;(f32x4.extract_lane 0 (local.get $temp_v))
            ;;(f32.add)
            ;;(f32x4.extract_lane 1 (local.get $temp_v))
            ;;(f32.add)
            ;;(f32x4.extract_lane 2 (local.get $temp_v))
            ;;(f32.add)
            ;;(f32x4.extract_lane 3 (local.get $temp_v))
            ;;(f32.add)
            ;;(local.set $temp)


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
  (func (export "spmv_csr_gs_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
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
      call $spmv_csr_gs
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

 (func $spmv_ell_row_gs (export "spmv_ell_row_gs") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $k i32)
    (local $temp f32)
    (local $col i32)
    (local $exp i32)
    (local $temp_v v128)
    (local $x_index v128)
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
    (local.get $start_row)
    (local.get $num_cols)
    (i32.mul)
    (local.set $exp)
    (local.get $num_cols)
    (i32.const 4)
    (i32.lt_s)
    (if
      (then
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
      ))
    (else
      (local.get $num_cols)
      (i32.const 4)
      (i32.rem_u)
      (local.tee $k)
      (i32.const 0)
      (i32.eq)
      (if
        (then
        (loop $outer_loop_4
          (f32.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))))
          (local.set $temp)
          (f32.const 0.0)
          f32x4.splat
          (local.set $temp_v)
          (local.set $i (i32.const 0))
          (loop $inner_loop_4
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))

            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
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
            (local.tee $i (i32.add (local.get $i) (i32.const 4)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_4)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2)))
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
          (local.set $exp (i32.add (local.get $exp) (local.get $num_cols)))
          (local.tee $start_row (i32.add (local.get $start_row) (i32.const 1)))
          (local.get $end_row)
          (i32.lt_s)
          (br_if $outer_loop_4)
      )))
      (local.get $k)
      (i32.const 1)
      (i32.eq)
      (if
        (then 
        (loop $outer_loop_5

          (f32.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))))
          (local.set $temp)
          (local.set $i (i32.const 0))
	  
          (f32.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 2))))
          (f32.mul)
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f32.const 0.0)
          f32x4.splat
          (local.set $temp_v)
	  
          (loop $inner_loop_5
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
            
            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
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
            (local.tee $i (i32.add (local.get $i) (i32.const 4)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_5)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2)))
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
          (local.set $exp (i32.add (local.get $exp) (local.get $num_cols)))
          (local.tee $start_row (i32.add (local.get $start_row) (i32.const 1)))
          (local.get $end_row)
          (i32.lt_s)
          (br_if $outer_loop_5)
      ))) 
      (local.get $k)
      (i32.const 2)
      (i32.eq)
      (if
        (then
        (loop $outer_loop_6

          (f32.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))))
          (local.set $temp)
          (local.set $i (i32.const 0))

          (f32.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 2))))
          (f32.mul)
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))


          (f32.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 2))))
          (f32.mul)
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f32.const 0.0)
          f32x4.splat
          (local.set $temp_v)

          (loop $inner_loop_6
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))

            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
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
            (local.tee $i (i32.add (local.get $i) (i32.const 4)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_6)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2)))
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
          (local.set $exp (i32.add (local.get $exp) (local.get $num_cols)))
          (local.tee $start_row (i32.add (local.get $start_row) (i32.const 1)))
          (local.get $end_row)
          (i32.lt_s)
          (br_if $outer_loop_6)
      )))
      (local.get $k)
      (i32.const 3)
      (i32.eq)
      (if
        (then
        (loop $outer_loop_7

          (f32.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2))))
          (local.set $temp)
          (local.set $i (i32.const 0))

          (f32.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 2))))
          (f32.mul)
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f32.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 2))))
          (f32.mul)
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f32.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 2))))
          (f32.mul)
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f32.const 0.0)
          f32x4.splat
          (local.set $temp_v)

          (loop $inner_loop_7
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))

            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
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
            (local.tee $i (i32.add (local.get $i) (i32.const 4)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_7)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 2)))
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
          (local.set $exp (i32.add (local.get $exp) (local.get $num_cols)))
          (local.tee $start_row (i32.add (local.get $start_row) (i32.const 1)))
          (local.get $end_row)
          (i32.lt_s)
          (br_if $outer_loop_7)
      )))
    ))
  )
  
  (func (export "spmv_ell_row_gs_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
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
      call $spmv_ell_row_gs
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

   (func $spmv_bdia_col (export "spmv_bdia_col") (param $offset i32) (param $data i32) (param $istart i32) (param $iend i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $n i32)
    (local $start i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; i*N
    (local $this_x i32)
    (local $this_y i32)
    (local $this_data i32)
    (local $B i32)
    local.get $nd
    i32.const 0
    local.tee $i
    i32.le_s
    if
      (return)
    end
    (i32.const 1024)
    (local.set $B)
    (i32.add (local.get $end_row) (i32.const 1))
    (local.set $end_row)

    (loop $loop_init
      (i32.shl (local.get $i) (i32.const 2))
      local.set $n
      ;; k = offset[i]
      (i32.load (i32.add (local.get $offset) (local.get $n))) 
      local.set $k
      ;; istart[i] = (0 < -k) ? -k : 0;
      (i32.add (local.get $istart) (local.get $n)) 
      (if (result i32) (i32.lt_s (local.get $k) (i32.const 0))
        (then
          (i32.sub (i32.const 0)(local.get $k))
        )
        (else
          i32.const 0
        )
      )
      (i32.store)
      ;; istart[i] = (istart[i] > start_row) ? istart[i] : start_row;
      (if (i32.lt_s (i32.load(i32.add (local.get $istart) (local.get $n))) (local.get $start_row))
        (then
          (i32.add (local.get $istart) (local.get $n)) 
          (local.get $start_row)
	  (i32.store)
        )
      ) 
      ;; iend[i] = (N < N-k) ? N : N-k;
      (i32.add (local.get $iend) (local.get $n)) 
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          local.get $N
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      (i32.store)
      ;; iend[i] = (iend[i] < end_row) ? iend[i] : end_row;
      (if (i32.gt_s (i32.load(i32.add (local.get $iend) (local.get $n))) (local.get $end_row))
        (then
          (i32.add (local.get $iend) (local.get $n)) 
          (local.get $end_row)
	  (i32.store)
        )
      )
      ;; i != nd; i++
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nd)
      (i32.ne)
      (br_if $loop_init)
    )

    (loop $block_outer_loop
      (i32.const 0)
      (local.set $i)
      (i32.const 0)
      (local.set $j)
      (i32.const 0)
      (local.set $exp1)
      (loop $outer_loop
        (i32.shl (local.get $i) (i32.const 2))
        local.set $n
        ;; k = offset[i]
        (i32.load (i32.add (local.get $offset) (local.get $n))) 
        local.set $k
        ;;local.get $k
        ;;call $logi
	;; start = istart[i]
	(i32.load(i32.add (local.get $istart) (local.get $n)))
	(local.set $start)
	;; end = iend[i]
	(i32.load(i32.add (local.get $iend) (local.get $n)))
	(local.set $end)
	;; if (end[i] > start[i])
	(if (i32.gt_s (local.get $end) (local.get $start))
	(then
	  ;; if(end >= start + B)
	  (if (i32.ge_s (local.get $end) (i32.add (local.get $B) (local.get $start)))
	  (then
	    ;; end = start + B
	    (i32.add (local.get $B) (local.get $start))
	    (local.set $end)
            ;;local.get $end
            ;;call $logi
	    (local.get $B)
            (i32.const 4)
            (i32.rem_u)
            (local.get $start)
            (i32.add)
            (local.set $new_end)
	  )
          (else
            (local.get $end)
            (local.get $start)
            (i32.sub)
            (i32.const 4)
            (i32.rem_u)
            (local.get $start)
            (i32.add)
            (local.set $new_end)
	  ))
          ;;local.get $new_end
          ;;call $logi
          (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 2))) 
          (local.set $this_y)
          (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $start)) (i32.const 2)))
          (local.set $this_data)
          (i32.add (local.get $x) (i32.shl (i32.add (local.get $start) (local.get $k)) (i32.const 2))) 
          (local.set $this_x)
          (local.get $start)
          (local.get $new_end)
          (i32.lt_s)
          (if
	  (then
            (loop $block_inner_loop
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
              (local.tee $start (i32.add (local.get $start) (i32.const 1)))
              (local.get $new_end)
              (i32.lt_s)
              (br_if $block_inner_loop)
	    )
	  ))
          (local.get $new_end)
          (local.get $end)
          (i32.lt_s)
          (if
	  (then
            (loop $block_inner_loop1
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
              (local.tee $start (i32.add (local.get $start) (i32.const 4)))
              (local.get $end)
              (i32.lt_s)
              (br_if $block_inner_loop1)
            )
	  ))
	  (i32.add (local.get $istart) (local.get $n))
	  (local.get $end)
	  (i32.store)
	)
	(else
          (local.set $j (i32.add (local.get $j) (i32.const 1)))
	))
        (i32.add (local.get $exp1) (local.get $N))
	(local.set $exp1)
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $nd)
        (i32.ne)
        (br_if $outer_loop)
      )
      (local.get $j)
      (local.get $nd)
      (i32.ne)
      (br_if $block_outer_loop)
    )
  )

   (func (export "spmv_bdia_col_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $istart i32) (param $iend i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $offset
      local.get $data
      local.get $istart
      local.get $iend
      local.get $start_row
      local.get $end_row
      local.get $nd
      local.get $N
      local.get $stride
      local.get $x
      local.get $y
      call $spmv_bdia_col
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

      



  (func $spmv_dia_col (export "spmv_dia_col") (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32)
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

  (func (export "spmv_dia_col_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
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
      call $spmv_dia_col
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_ell_col (export "spmv_ell_col") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    (local $exp1 i32) ;; j * N
    (local $exp2 i32) ;; j * N + i
    (local $row i32)
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
    (local.set $exp1 (i32.const 0))
    (loop $outer_loop
      (local.set $row (local.get $start_row))
      (i32.shl (i32.add (local.get $exp1) (local.get $row)) (i32.const 2))
      local.set $exp2
      (loop $inner_loop
        (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 2)))

        (i32.add (local.get $data) (local.get $exp2))
        f32.load
	
        (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (local.get $exp2))) (i32.const 2)))
        f32.load
        f32.mul
	
        (f32.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 2))))
        f32.add
        f32.store
	(i32.add (local.get $exp2) (i32.const 4))
        (local.set $exp2)
        (local.tee $row (i32.add (local.get $row) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $num_cols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )


  (func (export "spmv_ell_col_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
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
      call $spmv_ell_col
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_bell_col_gs (export "spmv_bell_col_gs") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    ;;(local $temp_v v128)
    (local $x_index v128)
    (local $exp1 i32)
    (local $exp2 i32)
    (local $B i32)
    (local $start i32)
    (local $end i32)
    (local $new_end i32)
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
    (local.set $B (i32.const 1024))
    (loop $block_outer_loop
      (local.set $i (i32.const 0))
      (local.set $exp1 (i32.const 0))
      ;;if(end_row > start_row)
      (if (i32.gt_s (local.get $end_row) (local.get $start_row))
      (then
        (loop $outer_loop
          (local.set $start (local.get $start_row))
          (i32.shl (i32.add (local.get $exp1) (local.get $start)) (i32.const 2))
          local.set $exp2
	  ;; if(end_row >= start_row + B)
	  (if (i32.ge_s (local.get $end_row) (i32.add (local.get $B) (local.get $start)))
	  (then
	    ;; end = start + B
	    (i32.add (local.get $B) (local.get $start))
	    (local.set $end)
            ;;local.get $end
            ;;call $logi
	    (local.get $B)
            (i32.const 4)
            (i32.rem_u)
            (local.get $start)
            (i32.add)
            (local.set $new_end)
	  )
	  (else
            (local.set $end (local.get $end_row))
            (local.get $end)
            (local.get $start)
            (i32.sub)
            (i32.const 4)
            (i32.rem_u)
            (local.get $start)
            (i32.add)
            (local.set $new_end)
	  ))

          (local.get $start)
          (local.get $new_end)
          (i32.lt_s)
          (if
	  (then
            (loop $inner_loop
              (i32.load (i32.add (local.get $indices) (local.get $exp2)))
              local.set $col
              (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 2)))
              (f32.load (i32.add (local.get $data) (local.get $exp2)))
              (f32.load (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 2))))
              f32.mul
              (f32.load (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 2))))
              f32.add
              f32.store
	      (i32.add (local.get $exp2) (i32.const 4))
              (local.set $exp2)
              (local.tee $start (i32.add (local.get $start) (i32.const 1)))
              (local.get $new_end)
              (i32.lt_s)
              (br_if $inner_loop)
          )))

	  (local.get $start)
          (local.get $end)
          (i32.lt_s)
          (if
          (then
            (loop $inner_loop1
            (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 2)))
            (v128.load (i32.add (local.get $data) (local.get $exp2)))

            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (local.get $exp2)))
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
            (v128.load (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 2))))
            f32x4.add
            (v128.store)
	    (i32.add (local.get $exp2) (i32.const 16))
            (local.set $exp2)
            (local.tee $start (i32.add (local.get $start) (i32.const 4)))
            (local.get $end)
            (i32.lt_s)
            (br_if $inner_loop1)
          )))
	  
	  (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
          (local.tee $i (i32.add (local.get $i) (i32.const 1)))
          (local.get $num_cols)
          (i32.lt_s)
          (br_if $outer_loop)
        )
	(local.get $start)
	(local.set $start_row)
        (br $block_outer_loop)
      )))
    )


  (func (export "spmv_bell_col_gs_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
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
      call $spmv_bell_col_gs
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )



   (func $spmv_ell_col_gs (export "spmv_ell_col_gs") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f32)
    (local $col i32)
    ;;(local $temp_v v128)
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

          ;;(f32x4.replace_lane 0 (f32x4.splat(f32.const 0.0)) (f32.load (i32x4.extract_lane 0 (local.get $x_index))))
          ;;(local.set $temp_v)
          ;;(f32x4.replace_lane 1 (local.get $temp_v) (f32.load (i32x4.extract_lane 1 (local.get $x_index))))
          ;;(local.set $temp_v)
          ;;(f32x4.replace_lane 2 (local.get $temp_v) (f32.load (i32x4.extract_lane 2 (local.get $x_index))))
          ;;(local.set $temp_v)
          ;;(f32x4.replace_lane 3 (local.get $temp_v) (f32.load (i32x4.extract_lane 3 (local.get $x_index))))

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


  (func (export "spmv_ell_col_gs_wrapper") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32) (param $inside_max i32)
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
      call $spmv_ell_col_gs
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

)  
