(module
  (import "js" "mem" (memory 1 32767 shared))
  (import "console" "log" (func $logi (param i32)))
  (import "console" "log" (func $logf (param f64)))
  (import "math" "expm1" (func $expm1f (param f64) (result f64)))
  (import "math" "log1p" (func $log1pf (param f64) (result f64)))
  (import "math" "sin" (func $sinf (param f64) (result f64)))
  (import "math" "tan" (func $tanf (param f64) (result f64)))
  (import "math" "pow" (func $powf (param f64) (param f64) (result f64)))

  (func (export "self_expm1_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $loop
      (local.get $val)
      (f64.load (local.get $val))
      (call $expm1f)
      (f64.store)
      (local.set $val (i32.add (local.get $val) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_log1p_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $loop
      (local.get $val)
      (f64.load (local.get $val))
      (call $log1pf)
      (f64.store)
      (local.set $val (i32.add (local.get $val) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_sin_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $loop
      (local.get $val)
      (f64.load (local.get $val))
      (call $sinf)
      (f64.store)
      (local.set $val (i32.add (local.get $val) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_tan_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $loop
      (local.get $val)
      (f64.load (local.get $val))
      (call $tanf)
      (f64.store)
      (local.set $val (i32.add (local.get $val) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_pow_coo") (param $id i32) (param $p f64) (param $val i32) (param $len i32)
    (local $i i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $loop
      (local.get $val)
      (f64.load (local.get $val))
      (local.get $p)
      (call $powf)
      (f64.store)
      (local.set $val (i32.add (local.get $val) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_deg2rad_coo") (param $id i32) (param $pi f64) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)
    (local $pi_on_180 f64)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    
    (local.get $pi)
    (f64.const 180)
    (f64.div)
    (local.set $pi_on_180)
    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.load (local.get $val))
        (local.get $pi_on_180)
        (f64.mul)
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (v128.load (local.get $val))
        (f64x2.splat (local.get $pi_on_180))
        (f64x2.mul)
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_rad2deg_coo") (param $id i32) (param $pi f64) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)
    (local $pi_on_180 f64)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $pi)
    (f64.const 180)
    (f64.div)
    (local.set $pi_on_180)
    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.load (local.get $val))
        (local.get $pi_on_180)
        (f64.div)
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (v128.load (local.get $val))
        (f64x2.splat (local.get $pi_on_180))
        (f64x2.div)
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_abs_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.abs (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.abs (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_neg_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.neg (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.neg (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_sqrt_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.sqrt (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.sqrt (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_ceil_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.ceil (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.ceil (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_floor_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.floor (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.floor (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_trunc_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.trunc (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.trunc (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_nearest_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.nearest (f64.load (local.get $val)))
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f64x2.nearest (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_sign_coo") (param $id i32) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (loop $loop
      (local.get $val)
      (if (result f64) (f64.gt (f64.load (local.get $val)) (f64.const 0.0))
        (then
        (f64.const 1)
        )
        (else
        (f64.const -1)
        )
      )
      (f64.store)
      (local.set $val (i32.add (local.get $val) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_multiply_scalar_coo") (param $id i32) (param $scalar f64) (param $val i32) (param $len i32)
    (local $i i32)
    (local $rem i32)

    (local.get $len)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end

    (local.get $len)
    (i32.const 2)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f64.load (local.get $val))
        (local.get $scalar)
        (f64.mul)
        (f64.store)
        (local.set $val (i32.add (local.get $val) (i32.const 8)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $len)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (v128.load (local.get $val))
        (f64x2.splat (local.get $scalar))
        (f64x2.mul)
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 2)))
        (local.get $len)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )





  ;;;;;;;;;;;;;;;;;;--SPMV Routines--;;;;;;;;;;;;;;;;;;

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
        (i32.add (local.get $y) (i32.shl (i32.load (local.get $coo_row)) (i32.const 3)))
	(local.tee $this_y)
        (f64.load (local.get $coo_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $coo_col)) (i32.const 3)))
        f64.load
        f64.mul
	(local.get $this_y)
        f64.load
        f64.add
        f64.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $len)
        i32.ne
        br_if $top
    )
  )

  (func (export "sum") (param $y i32) (param $w i32) (param $start_row i32) (param $end_row i32)
    ;;(local $i i32)
    (local $new_end i32)
    ;;(local.tee $i (i32.const 0))
    ;;(local.get $N)
    ;;i32.ge_s
    ;;if
      ;;(return)
    ;;end
    ;;(local.get $N)
    (local.set $y (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
    (local.set $w (i32.add (local.get $w) (i32.shl (local.get $start_row) (i32.const 3))))
    (local.get $end_row)
    (local.get $start_row)
    (i32.sub)
    (i32.const 2)
    (i32.rem_u)
    (local.get $start_row)
    (i32.add)
    (local.tee $new_end)
    (local.get $start_row)
    (i32.gt_s)
    (if
      (then
      (loop $loop
        (local.get $y)
        (f64.load (local.get $y))
        (f64.load (local.get $w))
        f64.add
        f64.store
        ;;(local.set $i (i32.add (local.get $i) (i32.const 1)))
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $w (i32.add (local.get $w) (i32.const 8)))
        ;;(i32.ne (local.get $i) (local.get $N))
        (local.set $start_row (i32.add (local.get $start_row) (i32.const 1)))
        (i32.ne (local.get $start_row) (local.get $new_end))
        (br_if $loop)
      )
    ))
    ;;(local.get $i)
    ;;(local.get $i)
    (local.get $start_row)
    (local.get $end_row)
    (i32.lt_s)
    (if
      (then
      (loop $loop1
        (local.get $y)
        (v128.load (local.get $y))
	(v128.load (local.get $w))
        (f64x2.add)
        (v128.store)
        ;;(local.set $i (i32.add (local.get $i) (i32.const 4)))
        (local.set $y (i32.add (local.get $y) (i32.const 16)))
        (local.set $w (i32.add (local.get $w) (i32.const 16)))
        (local.set $start_row (i32.add (local.get $start_row) (i32.const 2)))
        ;;(i32.ne (local.get $i) (local.get $N))
        (i32.ne (local.get $start_row) (local.get $end_row))
        (br_if $loop1)
      ))
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
        (i32.add (local.get $y) (i32.shl (i32.load (local.get $coo_row)) (i32.const 3)))
        (local.tee $this_y)
        (f64.load (local.get $coo_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $coo_col)) (i32.const 3)))
        f64.load
        f64.mul
        (local.get $this_y)
        f64.load
        f64.add
        f64.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 8)))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
      )
    )
    (loop $top
        (i32.add (local.get $y) (i32.shl (i32.load (local.get $coo_row)) (i32.const 3)))
        (local.tee $this_y)
        (f64.load (local.get $coo_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $coo_col)) (i32.const 3)))
        f64.load
        f64.mul
        (local.get $this_y)
        f64.load
        f64.add
        f64.store
        (i32.add (local.get $y) (i32.shl (i32.load (i32.add (local.get $coo_row) (i32.const 4))) (i32.const 3)))
        (local.tee $this_y)
        (f64.load (i32.add (local.get $coo_val) (i32.const 8)))
        (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $coo_col) (i32.const 4))) (i32.const 3)))
        f64.load
        f64.mul
        (local.get $this_y)
        f64.load
        f64.add
        f64.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 8)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 8)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 16)))
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
        (i32.add (local.get $y) (i32.shl (i32.load (local.get $coo_row)) (i32.const 3)))
        (local.tee $this_y)
        (f64.load (local.get $coo_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $coo_col)) (i32.const 3)))
        f64.load
        f64.mul
        (local.get $this_y)
        f64.load
        f64.add
        f64.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 8)))
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
        (i32x4.splat(local.get $x))
        (v128.load (local.get $coo_col))
        (i32.const 3)
        (i32x4.shl)
        (i32x4.add)
        (local.set $x_index)

        (i32x4.splat(local.get $y))
        (v128.load (local.get $coo_row))
        (i32.const 3)
        (i32x4.shl)
        (i32x4.add)
        (local.set $y_index)

        (v128.load (local.get $coo_val))
        (f64x2.replace_lane 0 (f64x2.splat(f64.const 0.0)) (f64.load (i32x4.extract_lane 0 (local.get $x_index))))
        (local.set $temp)
        (f64x2.replace_lane 1 (local.get $temp) (f64.load (i32x4.extract_lane 1 (local.get $x_index))))
        f64x2.mul
        (local.set $temp)

        (i32x4.extract_lane 0 (local.get $y_index))
        (f64.load (i32x4.extract_lane 0 (local.get $y_index)))
        (f64x2.extract_lane 0 (local.get $temp))
        (f64.add)
        (f64.store)
        (i32x4.extract_lane 1 (local.get $y_index))
        (f64.load (i32x4.extract_lane 1 (local.get $y_index)))
        (f64x2.extract_lane 1 (local.get $temp))
        (f64.add)
        (f64.store)

        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 16)))
        (v128.load (local.get $coo_val))
        (f64x2.replace_lane 0 (f64x2.splat(f64.const 0.0)) (f64.load (i32x4.extract_lane 2 (local.get $x_index))))
        (local.set $temp)
        (f64x2.replace_lane 1 (local.get $temp) (f64.load (i32x4.extract_lane 3 (local.get $x_index))))
        f64x2.mul
        (local.set $temp)

        (i32x4.extract_lane 2 (local.get $y_index))
        (f64.load (i32x4.extract_lane 2 (local.get $y_index)))
        (f64x2.extract_lane 0 (local.get $temp))
        (f64.add)
        (f64.store)
        (i32x4.extract_lane 3 (local.get $y_index))
        (f64.load (i32x4.extract_lane 3 (local.get $y_index)))
        (f64x2.extract_lane 1 (local.get $temp))
        (f64.add)
        (f64.store)

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
    (local $temp f64)
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
    (i32.const 3)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)
    (local.set $j (i32.load (local.get $csr_rowptr)))
    (loop $outer_loop
      (local.get $j)
      (i32.load (local.tee $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4))))
      ;;(i32.load (local.get $csr_rowptr))
      ;;call $logi
      (i32.lt_s)
      if
        (f64.load (local.get $y))
        (local.set $temp)
        (loop $inner_loop
          (f64.load (local.get $csr_val))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
	  (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
	  (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $csr_rowptr)
	  (i32.load)
          (i32.ne)
          (br_if $inner_loop)
        )
        (local.get $y)
        (local.get $temp)
        (f64.store)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
    (local $temp f64)

    (i32.load (local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load (local.get $csr_rowptr))
    (i32.const 3)
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (f64.store)
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $y))
        (local.set $temp)
        (loop $inner_loop
          (f64.load (local.get $csr_val))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $csr_rowptr)
          (i32.load)
          (i32.ne)
          (br_if $inner_loop)
        )
        (local.get $y)
        (local.get $temp)
        (f64.store)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
    (local $temp1 f64)
    (local $temp2 f64)
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
    (i32.const 3)
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (f64.store)
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
        
	 (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
      (f64.load (local.get $y))
      (local.set $temp1)
      (loop $inner_loop_odd
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp1)
        (f64.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
        (local.tee $j (i32.add (local.get $j) (i32.const 1)))
        (local.get $csr_rowptr)
        (i32.load)
        (i32.ne)
        (br_if $inner_loop_odd)
      )
      (local.get $y)
      (local.get $temp1)
      (f64.store)
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y2)
      (f64.load (local.get $y))
      (local.set $temp1)
      (f64.load (local.get $y2))
      (local.set $temp2)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 3))))
      (i32.const 0)
      (local.set $j)
  
       (loop $inner_loop_jam
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp1)
        (f64.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp2)
        (f64.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

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
          (f64.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp2)
          (f64.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j2)
            (i32.ne)
            (br_if $inner_loop2)
        )
      ))
      (local.get $y)
      (local.get $temp1)
      (f64.store)
      (local.get $y2)
      (local.get $temp2)
      (f64.store)
      (local.set $csr_col (local.get $csr_col2))
      (local.set $csr_val (local.get $csr_val2))
      (local.set $y (i32.add (local.get $y) (i32.const 16)))
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
    (local $temp1 f64)
    (local $temp2 f64)
    (local $temp3 f64)
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
    (i32.const 3)
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (f64.store)
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
        
	 (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
          (f64.load (local.get $y))
          (local.set $temp1)
          (loop $inner_loop_odd
            (f64.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
            (f64.load)
            (f64.mul)
            (local.get $temp1)
            (f64.add)
            (local.set $temp1)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $csr_rowptr)
            (i32.load)
            (i32.ne)
            (br_if $inner_loop_odd)
          )
          (local.get $y)
          (local.get $temp1)
          (f64.store)
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y2)
      (i32.add (local.get $y) (i32.const 16))
      (local.set $y3)
      (f64.load (local.get $y))
      (local.set $temp1)
      (f64.load (local.get $y2))
      (local.set $temp2)
      (f64.load (local.get $y3))
      (local.set $temp3)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 3))))
      (local.set $csr_col3 (i32.add (local.get $csr_col2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_val3 (i32.add (local.get $csr_val2) (i32.shl (local.get $j2) (i32.const 3))))
      (i32.const 0)
      (local.set $j)
      (loop $inner_loop_jam
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp1)
        (f64.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp2)
        (f64.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

	(f64.load (local.get $csr_val3))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp3)
        (f64.add)
        (local.set $temp3)
        (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
        (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

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
          (f64.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp2)
          (f64.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

          (f64.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp3)
          (f64.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

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
          (f64.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp3)
          (f64.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j3)
          (i32.ne)
          (br_if $inner_loop_peel_3)
        ))
      )
      (local.get $y)
      (local.get $temp1)
      (f64.store)
      (local.get $y2)
      (local.get $temp2)
      (f64.store)
      (local.get $y3)
      (local.get $temp3)
      (f64.store)
      (local.set $csr_col (local.get $csr_col3))
      (local.set $csr_val (local.get $csr_val3))
      (local.set $y (i32.add (local.get $y) (i32.const 24)))
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
    (local $temp1 f64)
    (local $temp2 f64)
    (local $temp3 f64)
    (local $temp4 f64)
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
    (i32.const 3)
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (f64.store)
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

         (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
          (f64.load (local.get $y))
          (local.set $temp1)
          (loop $inner_loop_odd
            (f64.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
            (f64.load)
            (f64.mul)
            (local.get $temp1)
            (f64.add)
            (local.set $temp1)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $csr_rowptr)
            (i32.load)
            (i32.ne)
            (br_if $inner_loop_odd)
          )
          (local.get $y)
          (local.get $temp1)
          (f64.store)
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y2)
      (i32.add (local.get $y) (i32.const 16))
      (local.set $y3)
      (i32.add (local.get $y) (i32.const 24))
      (local.set $y4)
      (f64.load (local.get $y))
      (local.set $temp1)
      (f64.load (local.get $y2))
      (local.set $temp2)
      (f64.load (local.get $y3))
      (local.set $temp3)
      (f64.load (local.get $y4))
      (local.set $temp4)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 3))))
      (local.set $csr_col3 (i32.add (local.get $csr_col2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_val3 (i32.add (local.get $csr_val2) (i32.shl (local.get $j2) (i32.const 3))))
      (local.set $csr_col4 (i32.add (local.get $csr_col3) (i32.shl (local.get $j3) (i32.const 2))))
      (local.set $csr_val4 (i32.add (local.get $csr_val3) (i32.shl (local.get $j3) (i32.const 3))))
      (i32.const 0)
      (local.set $j)
      (loop $inner_loop_jam
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp1)
        (f64.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp2)
        (f64.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

        (f64.load (local.get $csr_val3))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp3)
        (f64.add)
        (local.set $temp3)
        (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
        (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

	(f64.load (local.get $csr_val4))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp4)
        (f64.add)
        (local.set $temp4)
        (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
        (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))


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
          (f64.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp2)
          (f64.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

          (f64.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp3)
          (f64.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

	  (f64.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp4)
          (f64.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))

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
          (f64.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp3)
          (f64.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

          (f64.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp4)
          (f64.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))

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
          (f64.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp4)
          (f64.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j4)
          (i32.ne)
          (br_if $inner_loop_peel_4)
        ))
      )
      (local.get $y)
      (local.get $temp1)
      (f64.store)
      (local.get $y2)
      (local.get $temp2)
      (f64.store)
      (local.get $y3)
      (local.get $temp3)
      (f64.store)
      (local.get $y4)
      (local.get $temp4)
      (f64.store)
      (local.set $csr_col (local.get $csr_col4))
      (local.set $csr_val (local.get $csr_val4))
      (local.set $y (i32.add (local.get $y) (i32.const 32)))
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
    (local $temp1 f64)
    (local $temp2 f64)
    (local $temp3 f64)
    (local $temp4 f64)
    (local $temp5 f64)
    (local $temp6 f64)
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
    (i32.const 3)
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (f64.store)
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

         (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
          (f64.load (local.get $y))
          (local.set $temp1)
          (loop $inner_loop_odd
            (f64.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
            (f64.load)
            (f64.mul)
            (local.get $temp1)
            (f64.add)
            (local.set $temp1)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $csr_rowptr)
            (i32.load)
            (i32.ne)
            (br_if $inner_loop_odd)
          )
          (local.get $y)
          (local.get $temp1)
          (f64.store)
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
      (i32.add (local.get $y) (i32.const 8))
      (local.set $y2)
      (i32.add (local.get $y) (i32.const 16))
      (local.set $y3)
      (i32.add (local.get $y) (i32.const 24))
      (local.set $y4)
      (i32.add (local.get $y) (i32.const 32))
      (local.set $y5)
      (i32.add (local.get $y) (i32.const 40))
      (local.set $y6)
      (f64.load (local.get $y))
      (local.set $temp1)
      (f64.load (local.get $y2))
      (local.set $temp2)
      (f64.load (local.get $y3))
      (local.set $temp3)
      (f64.load (local.get $y4))
      (local.set $temp4)
      (f64.load (local.get $y5))
      (local.set $temp5)
      (f64.load (local.get $y6))
      (local.set $temp6)
      (local.set $csr_col2 (i32.add (local.get $csr_col) (i32.shl (local.get $j1) (i32.const 2))))
      (local.set $csr_val2 (i32.add (local.get $csr_val) (i32.shl (local.get $j1) (i32.const 3))))
      (local.set $csr_col3 (i32.add (local.get $csr_col2) (i32.shl (local.get $j2) (i32.const 2))))
      (local.set $csr_val3 (i32.add (local.get $csr_val2) (i32.shl (local.get $j2) (i32.const 3))))
      (local.set $csr_col4 (i32.add (local.get $csr_col3) (i32.shl (local.get $j3) (i32.const 2))))
      (local.set $csr_val4 (i32.add (local.get $csr_val3) (i32.shl (local.get $j3) (i32.const 3))))
      (local.set $csr_col5 (i32.add (local.get $csr_col4) (i32.shl (local.get $j4) (i32.const 2))))
      (local.set $csr_val5 (i32.add (local.get $csr_val4) (i32.shl (local.get $j4) (i32.const 3))))
      (local.set $csr_col6 (i32.add (local.get $csr_col5) (i32.shl (local.get $j5) (i32.const 2))))
      (local.set $csr_val6 (i32.add (local.get $csr_val5) (i32.shl (local.get $j5) (i32.const 3))))
      (i32.const 0)
      (local.set $j)
      (loop $inner_loop_jam
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp1)
        (f64.add)
        (local.set $temp1)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val2))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp2)
        (f64.add)
        (local.set $temp2)
        (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
        (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

        (f64.load (local.get $csr_val3))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp3)
        (f64.add)
        (local.set $temp3)
        (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
        (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

        (f64.load (local.get $csr_val4))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp4)
        (f64.add)
        (local.set $temp4)
        (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
        (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))

	(f64.load (local.get $csr_val5))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp5)
        (f64.add)
        (local.set $temp5)
        (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
        (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 8)))

        (f64.load (local.get $csr_val6))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (local.get $temp6)
        (f64.add)
        (local.set $temp6)
        (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
        (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 8)))


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
          (f64.load (local.get $csr_val2))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col2)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp2)
          (f64.add)
          (local.set $temp2)
          (local.set $csr_col2 (i32.add (local.get $csr_col2) (i32.const 4)))
          (local.set $csr_val2 (i32.add (local.get $csr_val2) (i32.const 8)))

	  (f64.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp3)
          (f64.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

          (f64.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp4)
          (f64.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))

          (f64.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp5)
          (f64.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 8)))

          (f64.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp6)
          (f64.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 8)))

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
          (f64.load (local.get $csr_val3))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col3)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp3)
          (f64.add)
          (local.set $temp3)
          (local.set $csr_col3 (i32.add (local.get $csr_col3) (i32.const 4)))
          (local.set $csr_val3 (i32.add (local.get $csr_val3) (i32.const 8)))

          (f64.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp4)
          (f64.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))

          (f64.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp5)
          (f64.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 8)))

          (f64.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp6)
          (f64.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 8)))

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
          (f64.load (local.get $csr_val4))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col4)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp4)
          (f64.add)
          (local.set $temp4)
          (local.set $csr_col4 (i32.add (local.get $csr_col4) (i32.const 4)))
          (local.set $csr_val4 (i32.add (local.get $csr_val4) (i32.const 8)))

          (f64.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp5)
          (f64.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 8)))

          (f64.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp6)
          (f64.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 8)))

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
          (f64.load (local.get $csr_val5))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col5)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp5)
          (f64.add)
          (local.set $temp5)
          (local.set $csr_col5 (i32.add (local.get $csr_col5) (i32.const 4)))
          (local.set $csr_val5 (i32.add (local.get $csr_val5) (i32.const 8)))

          (f64.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp6)
          (f64.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 8)))

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
          (f64.load (local.get $csr_val6))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col6)) (i32.const 3)))
          (f64.load)
          (f64.mul)
          (local.get $temp6)
          (f64.add)
          (local.set $temp6)
          (local.set $csr_col6 (i32.add (local.get $csr_col6) (i32.const 4)))
          (local.set $csr_val6 (i32.add (local.get $csr_val6) (i32.const 8)))
          (local.tee $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $j6)
          (i32.ne)
          (br_if $inner_loop_peel_6)
        ))
      )
      (local.get $y)
      (local.get $temp1)
      (f64.store)
      (local.get $y2)
      (local.get $temp2)
      (f64.store)
      (local.get $y3)
      (local.get $temp3)
      (f64.store)
      (local.get $y4)
      (local.get $temp4)
      (f64.store)
      (local.get $y5)
      (local.get $temp5)
      (f64.store)
      (local.get $y6)
      (local.get $temp6)
      (f64.store)
      (local.set $csr_col (local.get $csr_col6))
      (local.set $csr_val (local.get $csr_val6))
      (local.set $y (i32.add (local.get $y) (i32.const 48)))
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
    (local $temp f64)
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
    (i32.const 3)
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
        (f64.const 0.0)
        f64x2.splat
        (local.set $temp_v)
        (f64.load (local.get $y))
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
	    (f64.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
            (f64.load)
            (f64.mul)
            (local.get $temp)
            (f64.add)
            (local.set $temp)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

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
            (i32x4.splat(local.get $x))
            (v128.load (local.get $csr_col))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (v128.load (local.get $csr_val))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 16)))
            (v128.load (local.get $csr_val))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)
            ;;(local.set $temp_v)
            ;;(local.get $temp)
            ;;(f64x2.extract_lane 0 (local.get $temp_v))
            ;;(f64.add)
            ;;(f64x2.extract_lane 1 (local.get $temp_v))
            ;;(f64.add)
            ;;(f64x2.extract_lane 2 (local.get $temp_v))
            ;;(f64.add)
            ;;(f64x2.extract_lane 3 (local.get $temp_v))
            ;;(f64.add)
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
        (f64x2.extract_lane 0 (local.get $temp_v))
        (f64.add)
        (f64x2.extract_lane 1 (local.get $temp_v))
        (f64.add)
        (f64.store)
        ;;(f64x2.extract_lane 0
        ;;(local.get $temp_v)
        ;;(v8x16.shuffle 8 9 10 11 12 13 14 15 24 25 26 27 28 29 30 31 (local.get $temp_v) (local.get $temp_v))
        ;;(f64x2.add)
        ;;(local.tee $temp_v)
        ;;(v8x16.shuffle 4 5 6 7 8 9 10 11 20 21 22 23 24 25 26 27 (local.get $temp_v) (local.get $temp_v))
        ;;(f64x2.add)
        ;;)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
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


  (func $spmv_csr_gs_short (export "spmv_csr_gs_short") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $one i32) (param $two i32) (param $three i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $temp f64)
    (local $temp_v v128)
    (local $x_index v128)

    (i32.load (local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load (local.get $csr_rowptr))
    (i32.const 3)
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (f64.store)
        (local.set $y (i32.add (local.get $y) (i32.const 8)))
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.load (local.get $y))
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (f64.load (local.get $csr_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
        (f64.load)
        (f64.mul)
        (f64.add)
        (f64.store)
        (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
        (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))

        (local.set $y (i32.add (local.get $y) (i32.const 8)))
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
        (f64.const 0.0)
        f64x2.splat
        (local.set $temp_v)
        (f64.load (local.get $y))
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
	    (f64.load (local.get $csr_val))
            (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3)))
            (f64.load)
            (f64.mul)
            (local.get $temp)
            (f64.add)
            (local.set $temp)
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
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
            (i32x4.splat(local.get $x))
            (v128.load (local.get $csr_col))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (v128.load (local.get $csr_val))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 16)))
            (v128.load (local.get $csr_val))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
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
        (f64x2.extract_lane 0 (local.get $temp_v))
        (f64.add)
        (f64x2.extract_lane 1 (local.get $temp_v))
        (f64.add)
        (f64.store)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_csr_gs_short_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32)  (param $one i32) (param $two i32) (param $three i32) (param $inside_max i32)
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
      call $spmv_csr_gs_short
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func (export "self_expm1_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
  
    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      )
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)

        (loop $inner_loop
          (local.get $this_data)
          (f64.load (local.get $this_data))
          (call $expm1f)
          (f64.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end)
          (i32.lt_s)
          (br_if $inner_loop)
        )
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_log1p_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
  
    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      )
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)

        (loop $inner_loop
          (local.get $this_data)
          (f64.load (local.get $this_data))
          (call $log1pf)
          (f64.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end)
          (i32.lt_s)
          (br_if $inner_loop)
        )
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_sin_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
  
    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      )
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)

        (loop $inner_loop
          (local.get $this_data)
          (f64.load (local.get $this_data))
          (call $sinf)
          (f64.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end)
          (i32.lt_s)
          (br_if $inner_loop)
        )
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_tan_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
  
    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      )
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)

        (loop $inner_loop
          (local.get $this_data)
          (f64.load (local.get $this_data))
          (call $tanf)
          (f64.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end)
          (i32.lt_s)
          (br_if $inner_loop)
        )
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_sign_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
  
    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      )
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)

        (loop $inner_loop
          (local.get $this_data)
	  (if (result f64) (f64.eq (f64.load (local.get $this_data)) (f64.const 0.0))
          (then
            (f64.const 0)
          )
          (else
            (if (result f64) (f64.gt (f64.load (local.get $this_data)) (f64.const 0.0))
            (then
              (f64.const 1)
            )
            (else
              (f64.const -1)
            ))
          ))
          (f64.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end)
          (i32.lt_s)
          (br_if $inner_loop)
        )
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_pow_dia") (param $id i32) (param $p f64) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 
  
    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (i32.lt_s (local.get $n) (local.get $start_row))
        (then
          (local.get $start_row)
          (local.set $n)
        )
      )
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)

        (loop $inner_loop
          (local.get $this_data)
          (f64.load (local.get $this_data))
	  (local.get $p)
          (call $powf)
          (f64.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end)
          (i32.lt_s)
          (br_if $inner_loop)
        )
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_deg2rad_dia") (param $id i32) (param $pi f64) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)
    (local $pi_on_180 f64)


    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)
    (local.get $pi)
    (f64.const 180)
    (f64.div)
    (local.set $pi_on_180)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (local.get $pi_on_180)
            (f64.mul)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.splat (local.get $pi_on_180))
            (f64x2.mul)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_rad2deg_dia") (param $id i32) (param $pi f64) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)
    (local $pi_on_180 f64)


    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)
    (local.get $pi)
    (f64.const 180)
    (f64.div)
    (local.set $pi_on_180)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (local.get $pi_on_180)
            (f64.div)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.splat (local.get $pi_on_180))
            (f64x2.div)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func (export "self_abs_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.abs)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.abs)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func (export "self_neg_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.neg)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.neg)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_sqrt_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.sqrt)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.sqrt)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_ceil_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.ceil)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.ceil)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_floor_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.floor)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.floor)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_trunc_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.trunc)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.trunc)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_nearest_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end 
    (local.get $ndiags) 
    (i32.const 0)
    (i32.le_s) 
    if
      (return)
    end 

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
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
      ;; start position
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
      ;; end position
      (local.set $end)
      (if (i32.gt_s (local.get $end) (local.get $end_row))
        (then
          (local.get $end_row)
          (local.set $end)
        )
      )
      (if (i32.lt_s (local.get $n) (local.get $end))
      (then
        (local.get $end)
        (local.get $n)
        (i32.sub)
        (i32.const 2)
        (i32.rem_u)
        (local.get $n)
        (i32.add)
        (local.set $new_end)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (local.get $n)
        (local.get $new_end)
        (i32.lt_s)
        (if
        (then
          (loop $inner_loop
            (local.get $this_data)
            (f64.load (local.get $this_data))
            (f64.nearest)
            (f64.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
            (tee_local $n (i32.add (local.get $n) (i32.const 1)))
            (local.get $new_end)
            (i32.lt_s)
            (br_if $inner_loop)
          )
        ))
        (local.get $new_end)
        (local.get $end)
        (i32.lt_s)
        (if
        (then
          (loop $vector_inner_loop
            (local.get $this_data)
            (v128.load (local.get $this_data))
            (f64x2.nearest)
            (v128.store)
            (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
            (tee_local $n (i32.add (local.get $n) (i32.const 2)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
        ))
      ))
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $spmv_dia (export "spmv_dia") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_diag i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f64)
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
      (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
      (local.set $temp)
      (loop $inner_loop
        (i32.load (i32.add (local.get $offset) (i32.shl (local.get $i) (i32.const 2)))) 
        (local.get $start_row)
        (i32.add)
        (local.set $col)
        (if (i32.and (i32.ge_s (local.get $col) (i32.const 0)) (i32.lt_s (local.get $col) (local.get $N)))
          (then
            (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3)))
            f64.load
            (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 3)))
            f64.load
            f64.mul
            (local.get $temp)
            f64.add
            (local.set $temp)
          )
        )
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $num_diag)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))) 
      (local.get $temp)
      (f64.store)
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
    (local $temp f64)
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
      (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
      (local.set $temp)
      (loop $inner_loop
        (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
        local.set $col
        (if (i32.ge_s (local.get $col) (i32.const 0))
          (then
            (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3)))
            f64.load
            (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 3)))
            f64.load
            f64.mul
            (local.get $temp)
            f64.add
            (local.set $temp)
            (local.tee $i (i32.add (local.get $i) (i32.const 1)))
            (local.get $num_cols) 
            (i32.lt_s)
            (br_if $inner_loop)
          )
        )
      )
      (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))) 
      (local.get $temp)
      (f64.store)
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
    (local $temp f64)
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
        (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
        (local.set $temp)
        (loop $inner_loop
          (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
          local.set $col
          (if (i32.ge_s (local.get $col) (i32.const 0))
            (then
              (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3)))
              f64.load
              (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 3)))
              f64.load
              f64.mul
              (local.get $temp)
              f64.add
              (local.set $temp)
              (local.tee $i (i32.add (local.get $i) (i32.const 1)))
              (local.get $num_cols)
              (i32.lt_s)
              (br_if $inner_loop)
            )
          )
        )
        (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3)))
        (local.get $temp)
        (f64.store)
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
          (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
          (local.set $temp)
          (f64.const 0.0)
          f64x2.splat
          (local.set $temp_v)
          (local.set $i (i32.const 0))
          (loop $inner_loop_4
            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.set $i (i32.add (local.get $i) (i32.const 2)))
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.tee $i (i32.add (local.get $i) (i32.const 2)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_4)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3)))
          (local.get $temp)
          (f64x2.extract_lane 0 (local.get $temp_v))
          (f64.add)
          (f64x2.extract_lane 1 (local.get $temp_v))
          (f64.add)
          (f64.store)
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

          (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
          (local.set $temp)
          (local.set $i (i32.const 0))
	  
          (f64.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 3))))
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f64.const 0.0)
          f64x2.splat
          (local.set $temp_v)
	  
          (loop $inner_loop_5
            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1 
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.set $i (i32.add (local.get $i) (i32.const 2)))
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1 
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.tee $i (i32.add (local.get $i) (i32.const 2)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_5)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3)))
          (local.get $temp)
          (f64x2.extract_lane 0 (local.get $temp_v))
          (f64.add)
          (f64x2.extract_lane 1 (local.get $temp_v))
          (f64.add)
          (f64.store)
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

          (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
          (local.set $temp)
          (local.set $i (i32.const 0))

          (f64.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 3))))
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))


          (f64.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 3))))
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f64.const 0.0)
          f64x2.splat
          (local.set $temp_v)

          (loop $inner_loop_6
            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.set $i (i32.add (local.get $i) (i32.const 2)))
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.tee $i (i32.add (local.get $i) (i32.const 2)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_6)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3)))
          (local.get $temp)
          (f64x2.extract_lane 0 (local.get $temp_v))
          (f64.add)
          (f64x2.extract_lane 1 (local.get $temp_v))
          (f64.add)
          (f64.store)
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

          (f64.load (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3))))
          (local.set $temp)
          (local.set $i (i32.const 0))

          (f64.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 3))))
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f64.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 3))))
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f64.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2)))) (i32.const 3))))
          (f64.mul)
          (local.get $temp)
          (f64.add)
          (local.set $temp)
          (local.set $i (i32.add (local.get $i) (i32.const 1)))

          (f64.const 0.0)
          f64x2.splat
          (local.set $temp_v)

          (loop $inner_loop_7
            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 2))))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.set $i (i32.add (local.get $i) (i32.const 2)))
            (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $i)) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (local.get $temp_v)
            f64x2.add
            (local.set $temp_v)

            (local.tee $i (i32.add (local.get $i) (i32.const 2)))
            (local.get $num_cols)
            (i32.lt_s)
            (br_if $inner_loop_7)
          )
          (i32.add (local.get $y) (i32.shl (local.get $start_row) (i32.const 3)))
          (local.get $temp)
          (f64x2.extract_lane 0 (local.get $temp_v))
          (f64.add)
          (f64x2.extract_lane 1 (local.get $temp_v))
          (f64.add)
          (f64.store)
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
    ;;(local $i i32)
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
    (i32.shl (local.get $nd) (i32.const 2))
    (local.set $nd)
    local.get $nd
    i32.const 0
    ;;local.tee $i
    local.tee $n
    i32.le_s
    if
      (return)
    end
    (i32.const 1024)
    (local.set $B)
    (i32.add (local.get $end_row) (i32.const 1))
    (local.set $end_row)

     (loop $loop_init
      ;;(i32.shl (local.get $i) (i32.const 2))
      ;;local.set $n
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
      ;;(local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.tee $n (i32.add (local.get $n) (i32.const 4)))
      (local.get $nd)
      (i32.ne)
      (br_if $loop_init)
    )


    (loop $block_outer_loop
      (i32.const 0)
      ;;(local.set $i)
      (local.set $n)
      (i32.const 0)
      (local.set $j)
      (i32.const 0)
      (local.set $exp1)
      (loop $outer_loop
        ;;(i32.shl (local.get $i) (i32.const 2))
        ;;local.set $n
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
	    ;;(local.get $B)
            ;;(i32.const 4)
            ;;(i32.rem_u)
            (local.get $start)
            ;;(i32.add)
            (local.set $new_end)
	  )
          (else
            (local.get $end)
            (local.get $start)
            (i32.sub)
            (i32.const 2)
            (i32.rem_u)
            (local.get $start)
            (i32.add)
            (local.set $new_end)
	  ))
          ;;local.get $new_end
          ;;call $logi
          (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3))) 
          (local.set $this_y)
          (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $start)) (i32.const 3)))
          (local.set $this_data)
          (i32.add (local.get $x) (i32.shl (i32.add (local.get $start) (local.get $k)) (i32.const 3))) 
          (local.set $this_x)
          (local.get $start)
          (local.get $new_end)
          (i32.lt_s)
          (if
	  (then
            (loop $block_inner_loop
	      (local.get $this_y)
	      (local.get $this_data)
              (f64.load)
	      (local.get $this_x)
              (f64.load)
              (f64.mul)
	      (f64.load (local.get $this_y))
              (f64.add)
              (f64.store)
	      (local.set $this_y (i32.add (local.get $this_y) (i32.const 8)))
	      (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
	      (local.set $this_x (i32.add (local.get $this_x) (i32.const 8)))
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
              (f64x2.mul)
              (v128.load (local.get $this_y))
              (f64x2.add)
              (v128.store)
              (local.set $this_y (i32.add (local.get $this_y) (i32.const 16)))
              (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
              (local.set $this_x (i32.add (local.get $this_x) (i32.const 16)))
              (local.tee $start (i32.add (local.get $start) (i32.const 2)))
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
          ;;(local.set $j (i32.add (local.get $j) (i32.const 1)))
          (local.set $j (i32.add (local.get $j) (i32.const 4)))
	))
        (i32.add (local.get $exp1) (local.get $N))
	(local.set $exp1)
        ;;(local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.tee $n (i32.add (local.get $n) (i32.const 4)))
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


  (func $spmv_dia_col_basic (export "spmv_dia_col_basic") (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $iend i32)
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
        (i32.add (local.get $y) (i32.shl (local.get $n) (i32.const 3)))
        (local.set $this_y)
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
        (local.set $this_data)
        (i32.add (local.get $x) (i32.shl (i32.add (local.get $n) (local.get $k)) (i32.const 3)))
        (local.set $this_x)
        (loop $inner_loop
          (local.get $this_y)
          (local.get $this_data)
          (f64.load)
          (local.get $this_x)
          (f64.load)
          (f64.mul)
          (f64.load (local.get $this_y))
          (f64.add)
          (f64.store)
          (local.set $this_y (i32.add (local.get $this_y) (i32.const 8)))
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
          (local.set $this_x (i32.add (local.get $this_x) (i32.const 8)))
          (local.tee $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $end_row)
          (i32.lt_s)
          (br_if $inner_loop)
      )))
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

  (func (export "spmv_dia_col_basic_wrapper") (param $id i32) (param $offset i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $nd i32) (param $N i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
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
      call $spmv_dia_col_basic
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
      (i32.const 2)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $y) (i32.shl (local.get $n) (i32.const 3))) 
      (local.set $this_y)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 3)))
      (local.set $this_data)
      (i32.add (local.get $x) (i32.shl (i32.add (local.get $n) (local.get $k)) (i32.const 3))) 
      (local.set $this_x)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
	(then
        (loop $inner_loop
	  (local.get $this_y)
	  (local.get $this_data)
          (f64.load)
	  (local.get $this_x)
          (f64.load)
          (f64.mul)
	  (f64.load (local.get $this_y))
          (f64.add)
          (f64.store)
	  (local.set $this_y (i32.add (local.get $this_y) (i32.const 8)))
	  (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
	  (local.set $this_x (i32.add (local.get $this_x) (i32.const 8)))
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
        (f64x2.mul)
	(v128.load (local.get $this_y))
        (f64x2.add)
        (v128.store)
	(local.set $this_y (i32.add (local.get $this_y) (i32.const 16)))
	(local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
	(local.set $this_x (i32.add (local.get $this_x) (i32.const 16)))
        (local.tee $n (i32.add (local.get $n) (i32.const 2)))
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

  
  (func $self_expm1_ell (export "self_expm1_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (call $expm1f)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_log1p_ell (export "self_log1p_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (call $log1pf)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_sin_ell (export "self_sin_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (call $sinf)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_tan_ell (export "self_tan_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (call $tanf)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_pow_ell (export "self_pow_ell") (param $id i32) (param $p f64) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
	(local.get $p)
        (call $powf)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_deg2rad_ell (export "self_deg2rad_ell") (param $id i32) (param $pi f64) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)
    (local $pi_on_180 f64)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end

    (local.get $pi)
    (f64.const 180)
    (f64.div)
    (local.set $pi_on_180)

    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (local.get $pi_on_180)
        (f64.mul)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_rad2deg_ell (export "self_rad2deg_ell") (param $id i32) (param $pi f64) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)
    (local $pi_on_180 f64)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end

    (local.get $pi)
    (f64.const 180)
    (f64.div)
    (local.set $pi_on_180)

    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (local.get $pi_on_180)
        (f64.div)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_sign_ell (export "self_sign_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
	(if (result f64) (f64.eq (f64.load (local.get $this_data)) (f64.const 0.0))
        (then
          (f64.const 0)
          )
        (else
          (if (result f64) (f64.gt (f64.load (local.get $this_data)) (f64.const 0.0))
          (then
            (f64.const 1)
            )
          (else
            (f64.const -1)
          ))
        ))
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_abs_ell (export "self_abs_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.abs)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_neg_ell (export "self_neg_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.neg)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_sqrt_ell (export "self_sqrt_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.sqrt)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_ceil_ell (export "self_ceil_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.ceil)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_floor_ell (export "self_floor_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.floor)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_trunc_ell (export "self_trunc_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.trunc)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $self_nearest_ell (export "self_nearest_ell") (param $id i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $this_data i32)

    (local.get $start_row)
    (local.get $end_row)
    i32.ge_s
    if
      (return)
    end

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (local.set $exp1 (i32.const 0))

    (loop $outer_loop
      (local.set $i (local.get $start_row))
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp1) (local.get $i)) (i32.const 3)))
      (local.set $this_data)
      (loop $inner_loop
        (local.get $this_data)
        (f64.load (local.get $this_data))
        (f64.nearest)
        (f64.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 8)))
        (local.tee $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $end_row)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $exp1 (i32.add (local.get $exp1) (local.get $N)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.lt_s)
      (br_if $outer_loop)
    )
  )

  (func $spmv_ell_col (export "spmv_ell_col") (param $id i32) (param $indices i32) (param $data i32) (param $start_row i32) (param $end_row i32) (param $num_cols i32) (param $N i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $temp f64)
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
      (i32.add (local.get $exp1) (local.get $row))
      local.set $exp2
      (loop $inner_loop
        (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3)))

        (i32.add (local.get $data) (i32.shl (local.get $exp2) (i32.const 3)))
        f64.load
	
        (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (i32.shl (local.get $exp2) (i32.const 2)))) (i32.const 3)))
        f64.load
        f64.mul
	
        (f64.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3))))
        f64.add
        f64.store
	(i32.add (local.get $exp2) (i32.const 1))
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
    (local $temp f64)
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
          (i32.add (local.get $exp1) (local.get $start))
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
              (i32.load (i32.add (local.get $indices) (i32.shl (local.get $exp2) (i32.const 2))))
              local.set $col
              (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3)))
              (f64.load (i32.add (local.get $data) (i32.shl (local.get $exp2) (i32.const 3))))
              (f64.load (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 3))))
              f64.mul
              (f64.load (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3))))
              f64.add
              f64.store
	      (i32.add (local.get $exp2) (i32.const 1))
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
            (i32x4.splat(local.get $x))
            (v128.load (i32.add (local.get $indices) (i32.shl (local.get $exp2) (i32.const 2))))
            (i32.const 3)
            (i32x4.shl)
            (i32x4.add)
            (local.set $x_index)

            (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3)))
            (v128.load (i32.add (local.get $data) (i32.shl (local.get $exp2) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
            )
            f64x2.mul
            (v128.load (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3))))
            f64x2.add
            (v128.store)

	    (i32.add (local.get $exp2) (i32.const 2))
            (local.set $exp2)
            (local.set $start (i32.add (local.get $start) (i32.const 2)))
            (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3)))
            (v128.load (i32.add (local.get $data) (i32.shl (local.get $exp2) (i32.const 3))))
            (f64x2.replace_lane 1
              (f64x2.replace_lane 0
                (f64x2.splat(f64.const 0.0))
                (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
              )
              (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
            )
            f64x2.mul
            (v128.load (i32.add (local.get $y) (i32.shl (local.get $start) (i32.const 3))))
            f64x2.add
            (v128.store)

	    (i32.add (local.get $exp2) (i32.const 2))
            (local.set $exp2)
            (local.tee $start (i32.add (local.get $start) (i32.const 2)))
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
    (local $temp f64)
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
          (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3)))
          (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 3)))
          f64.load
          (i32.add (local.get $x) (i32.shl (local.get $col) (i32.const 3)))
          f64.load
          f64.mul
          (f64.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3))))
          f64.add
          f64.store
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
          (i32x4.splat(local.get $x))
          (v128.load (i32.add (local.get $indices) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 2))))
          (i32.const 3)
          (i32x4.shl)
          (i32x4.add)
          (local.set $x_index)

          (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3)))
          (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 3))))
          (f64x2.replace_lane 1
            (f64x2.replace_lane 0
              (f64x2.splat(f64.const 0.0))
              (f64.load (i32x4.extract_lane 0 (local.get $x_index)))
            )
            (f64.load (i32x4.extract_lane 1 (local.get $x_index)))
          )
          f64x2.mul
          (v128.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3))))
          f64x2.add
          (v128.store)

          ;;(f64x2.replace_lane 0 (f64x2.splat(f64.const 0.0)) (f64.load (i32x4.extract_lane 0 (local.get $x_index))))
          ;;(local.set $temp_v)
          ;;(f64x2.replace_lane 1 (local.get $temp_v) (f64.load (i32x4.extract_lane 1 (local.get $x_index))))
          ;;(local.set $temp_v)
          ;;(f64x2.replace_lane 2 (local.get $temp_v) (f64.load (i32x4.extract_lane 2 (local.get $x_index))))
          ;;(local.set $temp_v)
          ;;(f64x2.replace_lane 3 (local.get $temp_v) (f64.load (i32x4.extract_lane 3 (local.get $x_index))))

          (local.set $row (i32.add (local.get $row) (i32.const 2)))
          (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3)))
          (v128.load (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp) (local.get $row)) (i32.const 3))))
          (f64x2.replace_lane 1
            (f64x2.replace_lane 0
              (f64x2.splat(f64.const 0.0))
              (f64.load (i32x4.extract_lane 2 (local.get $x_index)))
            )
            (f64.load (i32x4.extract_lane 3 (local.get $x_index)))
          )
          f64x2.mul
          (v128.load (i32.add (local.get $y) (i32.shl (local.get $row) (i32.const 3))))
          f64x2.add
          (v128.store)

          (local.tee $row (i32.add (local.get $row) (i32.const 2)))
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

  ;;;;;;;;;;;;;;;;;;--SPTS Routines--;;;;;;;;;;;;;;;;;;

;;  (func $spts_csr_sync_free (export "spts_csr_sync_free") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $flag i32) (param $nthreads i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $stride1 i32)
;;    (local $stride2 i32)
;;    (local $current i32)
;;    (local $random i32)
;;    (local $end i32)
;;    (local $temp f64)
;;    (local.get $len)
;;    (local.get $id)
;;    (tee_local $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (local.get $i)
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.set $stride1)
;;    (local.set $y (i32.add (local.get $y) (local.get $stride1)))
;;    (local.set $current (i32.add (local.get $flag) (local.get $stride1)))
;;    (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (local.get $stride1)))
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.set $stride2)
;;    (local.get $csr_col)
;;    (local.get $stride2)
;;    (i32.add)
;;    (local.set $csr_col)
;;    (local.get $csr_val)
;;    (local.get $stride2)
;;    (i32.add)
;;    (local.set $csr_val) 
;;    (local.get $nthreads)
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.set $stride1)
;;    (loop $outer_loop
;;      ;; check if there are non-diagonals elements in the row.
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (i32.const 1)
;;      (i32.add)
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;	  (i32.add (local.get $flag) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
;;          (local.set $random)
;;          (loop $wait_loop
;;            (i32.load (local.get $random))
;;	    (i32.const 1)
;;            (i32.ne)
;;            (br_if $wait_loop)
;;	  )
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1)) 
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1)) 
;;      ))
;;      (local.set $y (i32.add (local.get $y) (local.get $stride1)))
;;      (local.set $current (i32.add (local.get $current) (local.get $stride1)))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (local.get $stride1)))
;;      (i32.load (local.get $csr_rowptr))
;;      (local.get $end)
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.add)
;;      (i32.const 2)
;;      (i32.shl)
;;      (local.set $stride2)
;;      (local.set $csr_col (i32.add (local.get $csr_col) (local.get $stride2)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (local.get $stride2)))
;;      (tee_local $i (i32.add (local.get $i) (local.get $nthreads)))
;;      (local.get $len)
;;      (i32.lt_s)
;;      (br_if $outer_loop)
;;    )
;;  )
;;
;;  (func $spts_csr_sync_free_wrapper (export "spts_csr_sync_free_wrapper") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $N i32) (param $barrier i32) (param $global_flag i32) (param $flag i32) (param $nthreads i32) (param $inner_max i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $len i32)
;;    (local $temp_x i32)
;;    (local $temp_y i32)
;;    (local $temp_flag i32)
;;    (local $local_flag i32)
;;    (local.get $inner_max)
;;    (i32.const 0)
;;    (tee_local $j)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (i32.const 0)
;;    (local.set $local_flag)
;;    (loop $top
;;      (local.get $local_flag)
;;      (i32.eqz)
;;      (if
;;      (then
;;        (i32.const 1)
;;        (local.set $local_flag)
;;      )
;;      (else
;;        (i32.const 0)
;;        (local.set $local_flag)
;;      ))
;;      ;; each worker thread copies x to y for its asssigned partition.
;;      (local.get $N)
;;      (local.get $nthreads)
;;      (i32.div_u)
;;      (local.set $len)
;;      (local.get $len)
;;      (local.get $id)
;;      (i32.mul)
;;      (i32.const 2)
;;      (i32.shl)
;;      (local.set $i)
;;      (i32.add (local.get $y) (local.get $i))
;;      (local.set $temp_y)
;;      (i32.add (local.get $x) (local.get $i))
;;      (local.set $temp_x)
;;      (i32.add (local.get $flag) (local.get $i))
;;      (local.set $temp_flag)
;;      (local.get $nthreads)
;;      (local.get $id)
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      if
;;        (local.get $N)
;;        (local.get $nthreads)
;;        (i32.rem_u)
;;        (local.get $len)
;;        (i32.add)
;;        (local.set $len)
;;      end
;;      (i32.const 0)
;;      (local.set $i)
;;      (loop $copy_x_to_y
;;        (local.get $temp_y)
;;        (f64.load (local.get $temp_x))
;;        (f64.store)
;;        (local.get $temp_flag)
;;        (i32.const 0)
;;        (i32.store)
;;        (local.set $temp_x (i32.add (local.get $temp_x) (i32.const 4)))
;;        (local.set $temp_y (i32.add (local.get $temp_y) (i32.const 4)))
;;        (local.set $temp_flag (i32.add (local.get $temp_flag) (i32.const 4)))
;;        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;        (local.get $len)
;;        (i32.ne)
;;        (br_if $copy_x_to_y)
;;      )
;;      (i32.const 0)
;;      (local.set $i)
;;      (local.get $nthreads)
;;      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1))
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      (if
;;      (then
;;        (i32.store (local.get $barrier) (i32.const 0))
;;        (i32.atomic.store (local.get $global_flag) (local.get $local_flag))
;;      )
;;      (else
;;        (loop $top_wait_loop
;;          (i32.load (local.get $global_flag))
;;          (local.get $local_flag)
;;          (i32.ne)
;;          (br_if $top_wait_loop)
;;        )
;;      ))
;;      (local.get $local_flag)
;;      (i32.eqz)
;;      (if
;;      (then
;;        (i32.const 1)
;;        (local.set $local_flag)
;;      )
;;      (else
;;        (i32.const 0)
;;        (local.set $local_flag)
;;      ))
;;      (local.get $id)
;;      (local.get $csr_rowptr)
;;      (local.get $csr_col)
;;      (local.get $csr_val)
;;      (local.get $y)
;;      (local.get $y)
;;      (local.get $N)
;;      (local.get $flag)
;;      (local.get $nthreads)
;;      (call $spts_csr_sync_free)
;;      
;;      (local.get $nthreads)
;;      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1)) 
;;      (i32.sub)
;;      (i32.const 1)	
;;      (i32.eq)
;;      (if
;;      (then
;;        (i32.store (local.get $barrier) (i32.const 0)) 
;;        (i32.atomic.store (local.get $global_flag) (local.get $local_flag)) 
;;      )
;;      (else
;;        (loop $wait_loop
;;          (i32.load (local.get $global_flag))
;;          (local.get $local_flag)
;;          (i32.ne)
;;          (br_if $wait_loop)
;;        )
;;      ))
;;      (local.get $inner_max)
;;      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;      (i32.ne)
;;      (br_if $top)
;;    )
;;  )

  (func $spts_csr (export "spts_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $s_y i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $j i32)
    (local $end i32)
    (local $temp f64)
    (local.get $len)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_col)
;;    (i32.add)
;;    (local.set $csr_col)
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_val)
;;    (i32.add)
;;    (local.set $csr_val)
    (loop $outer_loop
      ;; check if there are non-diagonals elements in the row.
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (i32.const 1)
      (i32.sub)
      (tee_local $end)
      (i32.load (local.get $csr_rowptr))
      (tee_local $j)
      (i32.gt_s)
      (if
      (then
	(f64.const 0)
        (local.set $temp)
        (loop $inner_loop
          (local.get $temp)
          (f64.load (local.get $csr_val))
          (f64.load (i32.add (local.get $s_y) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3))))
          (f64.mul)
	  (f64.add)
          (local.set $temp)
          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $end)
          (i32.ne)
          (br_if $inner_loop)
        )	 
        ;; Divide by the diagonal element to get final value of y 
        (local.get $y)
        (f64.load (local.get $x))
        (local.get $temp)
	(f64.sub)
        (f64.load (local.get $csr_val))
        (f64.div)
        (f64.store)
      )
      (else
        ;; Divide by the diagonal element to get final value of y 
        (local.get $y)
        (f64.load (local.get $x))
        (f64.load (local.get $csr_val))
        (f64.div)
        (f64.store)
      ))
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
      (local.set $x (i32.add (local.get $x) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)     
      (br_if $outer_loop)
    )
  )

  (func $spts_level_csr (export "spts_level_csr") (param $id i32) (param $level_ptr i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $permutation i32) (param $nlevels i32) (param $barrier i32) (param $global_flag i32) (param $nthreads i32) (param $N i32) (param $inner_max i32)
    (local $i i32)
    (local $j i32)
    (local $nrows i32)
    (local $len i32)
    (local $rem i32)
    (local $start_32 i32)
    (local $start_64 i32)
    (local $this_y i32)
    ;;(local $temp_y i32)
    ;;(local $temp_x i32)
    (local $start_level_ptr i32)
    (local $local_flag i32)
    ;; check if the number of levels is less than or equal to zero.
    (local.get $nlevels)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (local.get $inner_max)
    (i32.const 0)
    (tee_local $j)
    (i32.le_s)
    if
      (return)
    end
    (i32.const 0)
    (local.set $local_flag)
    (local.get $level_ptr)
    (local.set $start_level_ptr)
    (loop $top
;;      (local.get $local_flag)
;;      (i32.eqz)
;;      (if
;;      (then
;;	(i32.const 1)
;;	(local.set $local_flag)
;;      )
;;      (else
;;	(i32.const 0)
;;	(local.set $local_flag)
;;      ))
      ;; each worker thread copies x to y for its asssigned partition.
;;      (local.get $N)
;;      (local.get $nthreads)
;;      (i32.div_u)
;;      (local.set $len)
;;      (local.get $len)
;;      (local.get $id)
;;      (i32.mul)
;;      (i32.const 2)
;;      (i32.shl)
;;      (local.set $i)
;;      (i32.add (local.get $y) (local.get $i))
;;      (local.set $temp_y)
;;      (i32.add (local.get $x) (local.get $i))
;;      (local.set $temp_x)
;;      (local.get $nthreads)
;;      (local.get $id)
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      if
;;        (local.get $N)
;;        (local.get $nthreads)
;;        (i32.rem_u)
;;	(local.get $len)
;;        (i32.add)
;;	(local.set $len)
;;      end
;;      (i32.const 0)
;;      (local.set $i)
;;      (loop $copy_x_to_y 
;;        (local.get $temp_y)
;;        (f64.load (local.get $temp_x))
;;        (f64.store)
;;        (local.set $temp_x (i32.add (local.get $temp_x) (i32.const 4)))
;;        (local.set $temp_y (i32.add (local.get $temp_y) (i32.const 4)))
;;        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;        (local.get $len)
;;        (i32.ne)
;;        (br_if $copy_x_to_y)
;;      )
;;      (local.get $nthreads)
;;      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1)) 
;;      (i32.sub)
;;      (i32.const 1)	
;;      (i32.eq)
;;      (if
;;      (then
;;        (i32.atomic.store (local.get $barrier) (i32.const 0)) 
;;        (i32.atomic.store (local.get $global_flag) (local.get $local_flag)) 
;;      )
;;      (else
;;        (loop $top_wait_loop
;;          (i32.atomic.load (local.get $global_flag))
;;          (local.get $local_flag)
;;          (i32.ne)
;;          (br_if $top_wait_loop)
;;        )
;;      ))
      (i32.const 0)
      (local.set $i)
      (loop $level_loop
	(local.get $local_flag)
	(i32.eqz)
	(if
	(then
	  (i32.const 1)
	  (local.set $local_flag)
	)
	(else
	  (i32.const 0)
	  (local.set $local_flag)
	))
        ;; At each level, calculate the rows partition for each thread using id.
        ;; This is to avoid calls (equal to the number of levels) between the master 
        ;; JavaScript thread and worker WebAssembly threads.
        (i32.load (i32.add (local.get $level_ptr) (i32.const 4)))
        (i32.load (local.get $level_ptr))
        (i32.sub)
        (tee_local $nrows)
        (local.get $nthreads)
        (i32.div_u)
        (local.set $len)
      
        (local.get $len)
        (i32.const 0)
        (i32.ne)
        (if
        (then
          (local.get $nrows)
          (local.get $nthreads)
          (i32.rem_u)
	  (tee_local $rem)
	  (local.get $id)
	  (i32.gt_s)
	  (if
	  (then
            (local.set $start_32 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id))) (i32.const 2)))
            (local.set $start_64 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id))) (i32.const 3)))
            (local.get $len)
	    (i32.const 1)
            (i32.add)	
            (local.set $len)
          )
	  (else
            (local.set $start_32 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem))) (i32.const 2)))
            (local.set $start_64 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem))) (i32.const 3)))
	  ))
          (i32.add (local.get $csr_rowptr) (local.get $start_32)) 
          (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
          (i32.const 2)
          (i32.shl)
          (local.get $csr_col)
          (i32.add)
          (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
          (i32.const 3)
          (i32.shl)
          (local.get $csr_val)
          (i32.add)
          (i32.add (local.get $x) (local.get $start_64)) 
          (local.get $y)
          (i32.add (local.get $y) (local.get $start_64)) 
          (local.get $len)
          (call $spts_csr)
        )
        (else
          (local.get $nrows) 
	  (local.get $id)
	  (i32.gt_s)
	  if
	    (i32.const 1)
	    (local.set $len)
            (local.set $start_32 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (local.get $id)) (i32.const 2)))
            (local.set $start_64 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (local.get $id)) (i32.const 3)))
            (i32.add (local.get $csr_rowptr) (local.get $start_32)) 
            (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
            (i32.const 2)
            (i32.shl)
            (local.get $csr_col)
            (i32.add)
            (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
            (i32.const 3)
            (i32.shl)
            (local.get $csr_val)
            (i32.add)
            (i32.add (local.get $x) (local.get $start_64)) 
            (local.get $y)
            (i32.add (local.get $y) (local.get $start_64)) 
            (local.get $len)
            (call $spts_csr)
	  end
        ))
        ;; Increment the barrier value using atomic read-modify-write operation 
        ;; (returns value read from memory before the modify operation was performed).
        (local.get $nthreads)
        (i32.atomic.rmw.add (local.get $barrier) (i32.const 1)) 
	(i32.sub)
        (i32.const 1)	
	(i32.eq)
	(if
	(then
          (i32.atomic.store (local.get $barrier) (i32.const 0)) 
          (i32.atomic.store (local.get $global_flag) (local.get $local_flag)) 
	)
        (else
          (loop $wait_loop
            (i32.atomic.load (local.get $global_flag))
            (local.get $local_flag)
            (i32.ne)
            (br_if $wait_loop)
          )
        ))
        (local.set $level_ptr (i32.add (local.get $level_ptr) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $nlevels)
        (i32.ne)     
        (br_if $level_loop)
      )
      (local.get $start_level_ptr)
      (local.set $level_ptr)
      (local.get $inner_max)
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (i32.ne)
      (br_if $top)
    )
  )

;;  (func $spts_csr_level_sync_free (export "spts_csr_level_sync_free") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $current i32) (param $flag i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $end i32)
;;    (local $random i32)
;;    (local $temp f64)
;;    (local.get $len)
;;    (i32.const 0)
;;    (tee_local $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_col)
;;    (i32.add)
;;    (local.set $csr_col)
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_val)
;;    (i32.add)
;;    (local.set $csr_val)
;;    (loop $outer_loop
;;      ;; check if there are non-diagonals elements in the row.
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;	  (i32.add (local.get $flag) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
;;          (local.set $random)
;;          (loop $wait_loop
;;            (i32.load (local.get $random))
;;            (i32.const 1)
;;            (i32.ne)
;;            (br_if $wait_loop)
;;          )
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1)) 
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1)) 
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;      (local.get $len)
;;      (i32.ne)
;;      (br_if $outer_loop)
;;    )
;;  )
;;
;;
;;
;;  (func $spts_csr_level_sync_free_wrapper (export "spts_csr_level_sync_free_wrapper") (param $id i32) (param $level_ptr i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $permutation i32) (param $nlevels i32) (param $barrier i32) (param $global_flag i32) (param $flag i32) (param $nthreads i32) (param $N i32) (param $inner_max i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $nrows i32)
;;    (local $len i32)
;;    (local $rem i32)
;;    (local $start i32)
;;    (local $this_y i32)
;;    (local $temp_y i32)
;;    (local $temp_x i32)
;;    (local $temp_flag i32)
;;    (local $start_level_ptr i32)
;;    (local $local_flag i32)
;;    ;; check if the number of levels is less than or equal to zero.
;;    (local.get $nlevels)
;;    (i32.const 0)
;;    (local.tee $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (local.get $inner_max)
;;    (i32.const 0)
;;    (tee_local $j)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (i32.const 0)
;;    (local.set $local_flag)
;;    (local.get $level_ptr)
;;    (local.set $start_level_ptr)
;;    (loop $top
;;      (local.get $local_flag)
;;      (i32.eqz)
;;      (if
;;      (then
;;        (i32.const 1)
;;        (local.set $local_flag)
;;      )
;;      (else
;;        (i32.const 0)
;;        (local.set $local_flag)
;;      ))
;;      ;; each worker thread copies x to y for its asssigned partition.
;;      (local.get $N)
;;      (local.get $nthreads)
;;      (i32.div_u)
;;      (local.set $len)
;;      (local.get $len)
;;      (local.get $id)
;;      (i32.mul)
;;      (i32.const 2)
;;      (i32.shl)
;;      (local.set $i)
;;      (i32.add (local.get $y) (local.get $i))
;;      (local.set $temp_y)
;;      (i32.add (local.get $x) (local.get $i))
;;      (local.set $temp_x)
;;      (i32.add (local.get $flag) (local.get $i))
;;      (local.set $temp_flag)
;;      (local.get $nthreads)
;;      (local.get $id)
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      if
;;        (local.get $N)
;;        (local.get $nthreads)
;;        (i32.rem_u)
;;        (local.get $len)
;;        (i32.add)
;;        (local.set $len)
;;      end
;;      (i32.const 0)
;;      (local.set $i)
;;      (loop $copy_x_to_y
;;        (local.get $temp_y)
;;        (f64.load (local.get $temp_x))
;;        (f64.store)
;;        (local.get $temp_flag)
;;        (i32.const 0)
;;        (i32.store)
;;        (local.set $temp_x (i32.add (local.get $temp_x) (i32.const 4)))
;;        (local.set $temp_y (i32.add (local.get $temp_y) (i32.const 4)))
;;        (local.set $temp_flag (i32.add (local.get $temp_flag) (i32.const 4)))
;;        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;        (local.get $len)
;;        (i32.ne)
;;        (br_if $copy_x_to_y)
;;      )
;;      (i32.const 0)
;;      (local.set $i)
;;      (local.get $nthreads)
;;      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1))
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      (if
;;      (then
;;        (i32.store (local.get $barrier) (i32.const 0))
;;        (i32.atomic.store (local.get $global_flag) (local.get $local_flag))
;;      )
;;      (else
;;        (loop $top_wait_loop
;;          (i32.load (local.get $global_flag))
;;          (local.get $local_flag)
;;          (i32.ne)
;;          (br_if $top_wait_loop)
;;        )
;;      ))
;;      (local.get $local_flag)
;;      (i32.eqz)
;;      (if
;;      (then
;;        (i32.const 1)
;;        (local.set $local_flag)
;;      )
;;      (else
;;        (i32.const 0)
;;        (local.set $local_flag)
;;      ))
;;      (loop $level_loop
;;        ;; At each level, calculate the rows partition for each thread using id.
;;        ;; This is to avoid calls (equal to the number of levels) between the master
;;        ;; JavaScript thread and worker WebAssembly threads.
;;        (i32.load (i32.add (local.get $level_ptr) (i32.const 4)))
;;        (i32.load (local.get $level_ptr))
;;        (i32.sub)
;;        (tee_local $nrows)
;;        (local.get $nthreads)
;;        (i32.div_u)
;;        (local.set $len)
;;
;;        (local.get $len)
;;        (i32.const 0)
;;        (i32.ne)
;;        (if
;;        (then
;;          (local.get $nrows)
;;          (local.get $nthreads)
;;          (i32.rem_u)
;;          (tee_local $rem)
;;          (local.get $id)
;;          (i32.gt_s)
;;          (if
;;          (then
;;            (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id))) (i32.const 2)))
;;            (local.get $len)
;;            (i32.const 1)
;;            (i32.add)
;;            (local.set $len)
;;          )
;;          (else
;;            (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem))) (i32.const 2)))
;;          ))
;;          (i32.add (local.get $csr_rowptr) (local.get $start))
;;          (local.get $csr_col)
;;          (local.get $csr_val)
;;          (local.get $y)
;;          (i32.add (local.get $y) (local.get $start))
;;          (local.get $len)
;;          (i32.add (local.get $flag) (local.get $start))
;;          (local.get $flag)
;;          (call $spts_csr_level_sync_free)
;;        )
;;	(else
;;          (local.get $nrows)
;;          (local.get $id)
;;          (i32.gt_s)
;;          if
;;            (i32.const 1)
;;            (local.set $len)
;;            (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.mul (local.get $id) (local.get $len))) (i32.const 2)))
;;            (i32.add (local.get $csr_rowptr) (local.get $start))
;;            (local.get $csr_col)
;;            (local.get $csr_val)
;;            (local.get $y)
;;            (i32.add (local.get $y) (local.get $start))
;;            (local.get $len)
;;            (i32.add (local.get $flag) (local.get $start))
;;            (local.get $flag)
;;            (call $spts_csr_level_sync_free)
;;          end
;;        ))
;;        (local.set $level_ptr (i32.add (local.get $level_ptr) (i32.const 4)))
;;        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;        (local.get $nlevels)
;;        (i32.ne)
;;        (br_if $level_loop)
;;      )
;;      ;; Increment the barrier value using atomic read-modify-write operation
;;      ;; (returns value read from memory before the modify operation was performed).
;;      (local.get $nthreads)
;;      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1))
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      (if
;;      (then
;;        (i32.store (local.get $barrier) (i32.const 0))
;;        (i32.atomic.store (local.get $global_flag) (local.get $local_flag))
;;      )
;;      (else
;;        (loop $wait_loop
;;          (i32.load (local.get $global_flag))
;;          (local.get $local_flag)
;;          (i32.ne)
;;          (br_if $wait_loop)
;;        )
;;      ))
;;      (local.get $start_level_ptr)
;;      (local.set $level_ptr)
;;      (local.get $inner_max)
;;      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;      (i32.ne)
;;      (br_if $top)
;;    )
;;  )
;;
;;  (func $spts_csr_level_sync_free_direct_nobusywait (export "spts_csr_level_sync_free_direct_nobusywait") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $s_y i32) (param $y i32) (param $len i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $end i32)
;;    (local $temp f64)
;;    (local.get $len)
;;    (i32.const 0)
;;    (tee_local $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_col)
;;    (i32.add)
;;    (local.set $csr_col)
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_val)
;;    (i32.add)
;;    (local.set $csr_val)
;;    (loop $outer_loop
;;      ;; check if there are non-diagonals elements in the row.
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;	(f64.const 0)
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $s_y) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.add)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $x))
;;        (local.get $temp)
;;	(f64.sub)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $x))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $x (i32.add (local.get $x) (i32.const 4)))
;;      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;      (local.get $len)
;;      (i32.ne)
;;      (br_if $outer_loop)
;;    )
;;  )
;;
;;  (func $spts_csr_unroll2_level_sync_free_direct_nobusywait (export "spts_csr_unroll2_level_sync_free_direct_nobusywait") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $current i32) (param $nthreads i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $end i32)
;;    (local $temp f64)
;;    (local.get $len)
;;    (i32.const 0)
;;    (tee_local $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_col)
;;    (i32.add)
;;    (local.set $csr_col)
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_val)
;;    (i32.add)
;;    (local.set $csr_val)
;;    (local.get $len)
;;    (i32.const 2)
;;    (i32.rem_u)
;;    (i32.const 0)
;;    (i32.ne)
;;    (if
;;    (then
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop_odd
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop_odd)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      ))
;;      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;      (local.get $len)
;;      (i32.ge_s)
;;      if
;;        (return)
;;      end
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;    ))
;;    (loop $outer_loop
;;      ;; check if there are non-diagonals elements in the row.
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;
;;      (tee_local $i (i32.add (local.get $i) (i32.const 2)))
;;      (local.get $len)
;;      (i32.ne)
;;      (br_if $outer_loop)
;;    )
;;  )
;;
;;
;;  (func $spts_csr_level_sync_free_nobusywait (export "spts_csr_level_sync_free_nobusywait") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $s_y i32) (param $y i32) (param $len i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $end i32)
;;    (local $temp f64)
;;    (local.get $len)
;;    (i32.const 0)
;;    (tee_local $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (loop $outer_loop
;;      ;; check if there are non-diagonals elements in the row.
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;	(f64.const 0)
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $s_y) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.add)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $x))
;;        (local.get $temp)
;;	(f64.sub)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $x))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $x (i32.add (local.get $x) (i32.const 4)))
;;      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;      (local.get $len)
;;      (i32.ne)
;;      (br_if $outer_loop)
;;    )
;;  )
;;
;;  (func $spts_csr_unroll2_level_sync_free_nobusywait (export "spts_csr_unroll2_level_sync_free_nobusywait") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32) (param $current i32) (param $nthreads i32)
;;    (local $i i32)
;;    (local $j i32)
;;    (local $end i32)
;;    (local $temp f64)
;;    (local.get $len)
;;    (i32.const 0)
;;    (tee_local $i)
;;    (i32.le_s)
;;    if
;;      (return)
;;    end
;;    (local.get $len)
;;    (i32.const 2)
;;    (i32.rem_u)
;;    (i32.const 0)
;;    (i32.ne)
;;    (if
;;    (then
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop_odd
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop_odd)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;      (local.get $len)
;;      (i32.ge_s)
;;      if
;;        (return)
;;      end
;;    ))
;;    (loop $outer_loop
;;      ;; check if there are non-diagonals elements in the row.
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;	;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;	;;(drop)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;	;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;	;;(drop)
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;
;;      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (i32.const 1)
;;      (i32.sub)
;;      (tee_local $end)
;;      (i32.load (local.get $csr_rowptr))
;;      (tee_local $j)
;;      (i32.gt_s)
;;      (if
;;      (then
;;        (f64.load (local.get $y))
;;        (local.set $temp)
;;        (loop $inner_loop
;;          (local.get $temp)
;;          (f64.load (local.get $csr_val))
;;          (f64.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
;;          (f64.mul)
;;          (f64.sub)
;;          (local.set $temp)
;;          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
;;          (local.get $end)
;;          (i32.ne)
;;          (br_if $inner_loop)
;;        )
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (local.get $temp)
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      )
;;      (else
;;        ;; Divide by the diagonal element to get final value of y
;;        (local.get $y)
;;        (f64.load (local.get $y))
;;        (f64.load (local.get $csr_val))
;;        (f64.div)
;;        (f64.store)
;;        (i32.store (local.get $current) (i32.const 1))
;;        ;;(i32.atomic.store (local.get $current) (i32.const 1))
;;        ;;(memory.atomic.notify (local.get $current) (local.get $nthreads))
;;        ;;(drop)
;;      ))
;;      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
;;      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
;;      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
;;      (local.set $y (i32.add (local.get $y) (i32.const 4)))
;;      (local.set $current (i32.add (local.get $current) (i32.const 4)))
;;
;;      (tee_local $i (i32.add (local.get $i) (i32.const 2)))
;;      (local.get $len)
;;      (i32.ne)
;;      (br_if $outer_loop)
;;    )
;;  )

  (func $spts_csr_level_sync_free_busywait (export "spts_csr_level_sync_free_busywait") (param $id i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $s_y i32) (param $y i32) (param $len i32) (param $local_level i32) (param $global_level i32) (param $global_rows i32) (param $row_level_index i32) (param $row_worker_index i32) (param $worker_level_index i32)
    (local $i i32)
    (local $j i32)
    (local $end i32)
    (local $random i32)
    (local $worker i32)
    (local $worker_level i32)
    (local $level i32)
    (local $temp f64)
    (local.get $len)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_col)
;;    (i32.add)
;;    (local.set $csr_col)
;;    (i32.load (local.get $csr_rowptr))
;;    (i32.const 2)
;;    (i32.shl)
;;    (local.get $csr_val)
;;    (i32.add)
;;    (local.set $csr_val)
    (i32.atomic.load (local.get $global_level))
    (local.get $local_level)
    (i32.eq)
    if
      (local.get $csr_rowptr)
      (local.get $csr_col)
      (local.get $csr_val)
      (local.get $x)
      (local.get $s_y)
      (local.get $y)
      (local.get $len)
      (call $spts_csr)
      (return)
    end
    (loop $outer_loop
      ;; check if there are non-diagonals elements in the row.
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (i32.const 1)
      (i32.sub)
      (tee_local $end)
      (i32.load (local.get $csr_rowptr))
      (tee_local $j)
      (i32.gt_s)
      (if
      (then
        (i32.atomic.load (local.get $global_level))
        (local.get $local_level)
        (i32.eq)
        if
          (local.get $csr_rowptr)
          (local.get $csr_col)
          (local.get $csr_val)
          (local.get $x)
          (local.get $s_y)
          (local.get $y)
          (i32.sub (local.get $len) (local.get $i))
          (call $spts_csr)
          (return)
	end
	(f64.const 0)
        (local.set $temp)
        (loop $inner_loop
          (i32.atomic.load (local.get $global_level))
          (local.get $local_level)
          (i32.eq)
          if
	    (loop $inner_leftover_loop
              (local.get $temp)
              (f64.load (local.get $csr_val))
              (f64.load (i32.add (local.get $s_y) (i32.shl (i32.load (local.get $csr_col)) (i32.const 3))))
              (f64.mul)
              (f64.add)
              (local.set $temp)
              (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
              (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
              (tee_local $j (i32.add (local.get $j) (i32.const 1)))
              (local.get $end)
              (i32.ne)
              (br_if $inner_leftover_loop)
            )
            ;; Divide by the diagonal element to get final value of y
            (local.get $y)
            (f64.load (local.get $x))
            (local.get $temp)
	    (f64.sub)
            (f64.load (local.get $csr_val))
            (f64.div)
            (f64.store)

            (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
            (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
            (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
            (local.set $y (i32.add (local.get $y) (i32.const 8)))
            (local.set $x (i32.add (local.get $x) (i32.const 8)))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
  
            (local.get $csr_rowptr)
            (local.get $csr_col)
            (local.get $csr_val)
            (local.get $x)
            (local.get $s_y)
            (local.get $y)
            (i32.sub (local.get $len) (local.get $i))
            (call $spts_csr)
            (return)
	  end
          (local.get $temp)
          (f64.load (local.get $csr_val))
          (i32.load (local.get $csr_col))
          (local.set $random)
          (i32.atomic.load (local.get $global_rows))
	  (local.get $random)
          (i32.le_s)
	  if
	    (i32.load (i32.add (local.get $row_worker_index) (i32.shl (local.get $random) (i32.const 2))))
	    (local.set $worker)
	    (local.get $worker)
	    (local.get $id)
	    (i32.ne)
	    if
	      (i32.load (i32.add (local.get $row_level_index) (i32.shl (local.get $random) (i32.const 2))))
	      (local.set $level)
	      (i32.add (local.get $worker_level_index) (i32.shl (local.get $worker) (i32.const 2)))
	      (local.set $worker_level)
              (loop $wait_loop
		(local.get $level)
	        (i32.atomic.load (local.get $worker_level))
	        (i32.gt_s)
                (br_if $wait_loop)
              )
	    end
	  end
          (f64.load (i32.add (local.get $s_y) (i32.shl (local.get $random) (i32.const 3))))
          (f64.mul)
          (f64.add)
          (local.set $temp)
          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $end)
          (i32.ne)
          (br_if $inner_loop)
        )
        ;; Divide by the diagonal element to get final value of y
        (local.get $y)
        (f64.load (local.get $x))
        (local.get $temp)
	(f64.sub)
        (f64.load (local.get $csr_val))
        (f64.div)
        (f64.store)
      )
      (else
        ;; Divide by the diagonal element to get final value of y
        (local.get $y)
        (f64.load (local.get $x))
        (f64.load (local.get $csr_val))
        (f64.div)
        (f64.store)
      ))
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
      (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 8)))
      (local.set $y (i32.add (local.get $y) (i32.const 8)))
      (local.set $x (i32.add (local.get $x) (i32.const 8)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $len)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $spts_csr_opt_level_sync_free_wrapper (export "spts_csr_opt_level_sync_free_wrapper") (param $id i32) (param $level_ptr i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $permutation i32) (param $nlevels i32) (param $barrier i32) (param $global_flag i32) (param $global_level i32) (param $global_rows i32) (param $level_barrier i32) (param $row_level_index i32) (param $row_worker_index i32) (param $worker_level_index i32)(param $nthreads i32) (param $N i32) (param $inner_max i32)
    (local $i i32)
    (local $j i32)
    (local $nrows i32)
    (local $len i32)
    (local $rem i32)
    (local $start_32 i32)
    (local $start_64 i32)
    (local $this_y i32)
    ;;(local $temp_y i32)
    ;;(local $temp_x i32)
    (local $start_level_ptr i32)
    (local $local_flag i32)
    (local $local_level i32)
    (local $worker_level i32)
    ;; check if the number of levels is less than or equal to zero.
    (local.get $nlevels)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (local.get $inner_max)
    (i32.const 0)
    (tee_local $j)
    (i32.le_s)
    if
      (return)
    end
    (i32.shl (local.get $id) (i32.const 2))
    (local.get $worker_level_index) 
    (i32.add)
    (local.set $worker_level) 
    (i32.const 0)
    (local.set $local_flag)
    (local.get $level_ptr)
    (local.set $start_level_ptr)
    (loop $top
      (i32.const -1)
      (local.set $local_level)
      (local.get $local_flag)
      (i32.eqz)
      (if
      (then
        (i32.const 1)
        (local.set $local_flag)
      )
      (else
        (i32.const 0)
        (local.set $local_flag)
      ))
      ;;(i32.const 0)
      ;;(local.set $i)
      ;;(local.get $flag)
      ;;(local.set $temp_flag)
      ;;(loop $reset_flag
	;;(local.get $temp_flag)
	;;(i32.const 0)
	;;(i32.store)
        ;;(local.set $temp_flag (i32.add (local.get $temp_flag) (i32.const 4)))
        ;;(tee_local $i (i32.add (local.get $i) (i32.const 1)))
        ;;(local.get $N)
        ;;(i32.ne)
        ;;(br_if $reset_flag)
      ;;)
      (i32.store (local.get $worker_level) (i32.const -1))
      ;; each worker thread copies x to y for its asssigned partition.
;;      (local.get $N)
;;      (local.get $nthreads)
;;      (i32.div_u)
;;      (local.set $len)
;;      (local.get $len)
;;      (local.get $id)
;;      (i32.mul)
;;      (i32.const 2)
;;      (i32.shl)
;;      (local.set $i)
;;      (i32.add (local.get $y) (local.get $i))
;;      (local.set $temp_y)
;;      (i32.add (local.get $x) (local.get $i))
;;      (local.set $temp_x)
;;      (local.get $nthreads)
;;      (local.get $id)
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      if
;;        (local.get $N)
;;        (local.get $nthreads)
;;        (i32.rem_u)
;;        (local.get $len)
;;        (i32.add)
;;        (local.set $len)
;;      end
      (i32.const 0)
      (local.set $i)
;;      (loop $copy_x_to_y
;;        (local.get $temp_y)
;;        (f64.load (local.get $temp_x))
;;        (f64.store)
;;        (local.set $temp_x (i32.add (local.get $temp_x) (i32.const 4)))
;;        (local.set $temp_y (i32.add (local.get $temp_y) (i32.const 4)))
;;        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
;;        (local.get $len)
;;        (i32.ne)
;;        (br_if $copy_x_to_y)
;;      )
;;      (i32.const 0)
;;      (local.set $i)
;;      (local.get $nthreads)
;;      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1))
;;      (i32.sub)
;;      (i32.const 1)
;;      (i32.eq)
;;      (if
;;      (then
;;        (i32.atomic.store (local.get $barrier) (i32.const 0))
;;        (i32.atomic.store (local.get $global_flag) (local.get $local_flag))
;;      )
;;      (else
;;        (loop $top_wait_loop
;;          (i32.atomic.load (local.get $global_flag))
;;          (local.get $local_flag)
;;          (i32.ne)
;;          (br_if $top_wait_loop)
;;        )
;;      ))
;;      (local.get $local_flag)
;;      (i32.eqz)
;;      (if
;;      (then
;;        (i32.const 1)
;;        (local.set $local_flag)
;;      )
;;      (else
;;        (i32.const 0)
;;        (local.set $local_flag)
;;      ))
      (loop $level_loop
        ;; At each level, calculate the rows partition for each thread using id.
        ;; This is to avoid calls (equal to the number of levels) between the master
        ;; JavaScript thread and worker WebAssembly threads.
        (i32.load (i32.add (local.get $level_ptr) (i32.const 4)))
        (i32.load (local.get $level_ptr))
        (i32.sub)
        (tee_local $nrows)
        (local.get $nthreads)
        (i32.div_u)
        (local.set $len)

        (local.get $len)
        (i32.const 0)
        (i32.ne)
        (if
        (then
          (local.get $nrows)
          (local.get $nthreads)
          (i32.rem_u)
          (tee_local $rem)
          (local.get $id)
          (i32.gt_s)
          (if
          (then
            (local.set $start_32 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id))) (i32.const 2)))
            (local.set $start_64 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id))) (i32.const 3)))
            (local.get $len)
            (i32.const 1)
            (i32.add)
            (local.set $len)
          )
          (else
            (local.set $start_32 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem))) (i32.const 2)))
            (local.set $start_64 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem))) (i32.const 3)))
          ))
	  (i32.atomic.load (local.get $global_level))
          (local.get $local_level)
          (i32.eq)
          (if
	  (then
            (i32.add (local.get $csr_rowptr) (local.get $start_32))
            (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
            (i32.const 2)
            (i32.shl)
            (local.get $csr_col)
            (i32.add)
            (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
            (i32.const 3)
            (i32.shl)
            (local.get $csr_val)
            (i32.add)
            (i32.add (local.get $x) (local.get $start_64))
            (local.get $y)
            (i32.add (local.get $y) (local.get $start_64))
            (local.get $len)
            (call $spts_csr)
	  )
	  (else
	    (local.get $id)
            (i32.add (local.get $csr_rowptr) (local.get $start_32))
            (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
            (i32.const 2)
            (i32.shl)
            (local.get $csr_col)
            (i32.add)
            (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
            (i32.const 3)
            (i32.shl)
            (local.get $csr_val)
            (i32.add)
            (i32.add (local.get $x) (local.get $start_64))
            (local.get $y)
            (i32.add (local.get $y) (local.get $start_64))
            (local.get $len)
            (local.get $local_level)
            (local.get $global_level)
            (local.get $global_rows)
	    (local.get $row_level_index)
	    (local.get $row_worker_index)
	    (local.get $worker_level_index)
            (call $spts_csr_level_sync_free_busywait)
	  ))
        )
        (else
          (local.get $nrows)
          (local.get $id)
          (i32.gt_s)
          if
            (i32.const 1)
            (local.set $len)
            (local.set $start_32 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (local.get $id)) (i32.const 2)))
            (local.set $start_64 (i32.shl (i32.add (i32.load (local.get $level_ptr)) (local.get $id)) (i32.const 3)))
	    (i32.atomic.load (local.get $global_level))
            (local.get $local_level)
            (i32.eq)
            (if
            (then
              (i32.add (local.get $csr_rowptr) (local.get $start_32))
              (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
              (i32.const 2)
              (i32.shl)
              (local.get $csr_col)
              (i32.add)
              (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
              (i32.const 3)
              (i32.shl)
              (local.get $csr_val)
              (i32.add)
              (i32.add (local.get $x) (local.get $start_64))
              (local.get $y)
              (i32.add (local.get $y) (local.get $start_64))
              (local.get $len)
              (call $spts_csr)
            )
            (else
	      (local.get $id)
              (i32.add (local.get $csr_rowptr) (local.get $start_32))
              (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
              (i32.const 2)
              (i32.shl)
              (local.get $csr_col)
              (i32.add)
              (i32.load (i32.add (local.get $csr_rowptr) (local.get $start_32)))
              (i32.const 3)
              (i32.shl)
              (local.get $csr_val)
              (i32.add)
              (i32.add (local.get $x) (local.get $start_64))
              (local.get $y)
              (i32.add (local.get $y) (local.get $start_64))
              (local.get $len)
              (local.get $local_level)
              (local.get $global_level)
              (local.get $global_rows)
	      (local.get $row_level_index)
	      (local.get $row_worker_index)
	      (local.get $worker_level_index)
              (call $spts_csr_level_sync_free_busywait)
	    ))
          end
        ))
        (local.set $local_level (i32.add (local.get $local_level) (i32.const 1)))
        (local.get $nthreads)
	(i32.atomic.rmw.add (local.get $worker_level) (i32.const 1))
	(drop)
        (i32.atomic.rmw.add (i32.add (local.get $level_barrier) (i32.shl (local.get $local_level) (i32.const 2))) (i32.const 1))
        (i32.sub)
        (i32.const 1)
        (i32.eq)
        (if
        (then
          (i32.atomic.store (local.get $global_level) (local.get $local_level))
	  (i32.atomic.rmw.add (local.get $global_rows) (local.get $nrows))
	  (drop)
          (i32.atomic.store (i32.add (local.get $level_barrier) (i32.shl (local.get $local_level) (i32.const 2))) (i32.const 0))
	))
        (local.set $level_ptr (i32.add (local.get $level_ptr) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $nlevels)
        (i32.ne)
        (br_if $level_loop)
      )
      ;; Increment the barrier value using atomic read-modify-write operation
      ;; (returns value read from memory before the modify operation was performed).
      (local.get $nthreads)
      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1))
      (i32.sub)
      (i32.const 1)
      (i32.eq)
      (if
      (then
        (i32.atomic.store (local.get $barrier) (i32.const 0))
        (i32.atomic.store (local.get $global_level) (i32.const -1))
        (i32.atomic.store (local.get $global_rows) (i32.const 0))
        (i32.atomic.store (local.get $global_flag) (local.get $local_flag))
      )
      (else
        (loop $wait_loop
          (i32.atomic.load (local.get $global_flag))
          (local.get $local_flag)
          (i32.ne)
          (br_if $wait_loop)
        )
      ))
      (local.get $start_level_ptr)
      (local.set $level_ptr)
      (local.get $inner_max)
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (i32.ne)
      (br_if $top)
    )
  )

  (func $meta_data (export "metadata") (param $id i32) (param $level_ptr i32) (param $nlevels i32) (param $nthreads i32) (param $N i32) (param $row_level_index i32) (param $row_worker_index i32)
    (local $i i32)
    (local $j i32)
    (local $nrows i32)
    (local $len i32)
    (local $rem i32)
    (local $start i32)
    (local $worker i32)
    (local $level i32)
    (loop $level_loop
      (i32.load (i32.add (local.get $level_ptr) (i32.const 4)))
      (i32.load (local.get $level_ptr))
      (i32.sub)
      (tee_local $nrows)
      (local.get $nthreads)
      (i32.div_u)
      (local.set $len)

      (local.get $len)
      (i32.const 0)
      (i32.ne)
      (if
      (then
        (local.get $nrows)
        (local.get $nthreads)
        (i32.rem_u)
        (tee_local $rem)
        (local.get $id)
        (i32.gt_s)
        (if
        (then
          (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id))) (i32.const 2)))
          (local.get $len)
          (i32.const 1)
          (i32.add)
          (local.set $len)
        )
        (else
          (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem))) (i32.const 2)))
        ))
	(i32.add (local.get $row_worker_index) (local.get $start))
	(local.set $worker)
	(i32.add (local.get $row_level_index) (local.get $start))
	(local.set $level)
	(i32.const 0)
	(local.set $j)
        (loop $row_loop1
	  (i32.store (local.get $worker) (local.get $id))
	  (i32.store (local.get $level) (local.get $i))
          (local.set $worker (i32.add (local.get $worker) (i32.const 4)))
          (local.set $level (i32.add (local.get $level) (i32.const 4)))
          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $len)
          (i32.ne)
          (br_if $row_loop1)
        )	      
      )
      (else
        (local.get $nrows)
        (local.get $id)
        (i32.gt_s)
        if
          (i32.const 1)
          (local.set $len)
          (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (local.get $id)) (i32.const 2)))
	  (i32.add (local.get $row_worker_index) (local.get $start))
	  (local.set $worker)
	  (i32.add (local.get $row_level_index) (local.get $start))
	  (local.set $level)
	  (i32.const 0)
	  (local.set $j)
          (loop $row_loop2
	    (i32.store (local.get $worker) (local.get $id))
	    (i32.store (local.get $level) (local.get $i))
            (local.set $worker (i32.add (local.get $worker) (i32.const 4)))
            (local.set $level (i32.add (local.get $level) (i32.const 4)))
            (tee_local $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $len)
            (i32.ne)
            (br_if $row_loop2)
          )	      
        end
      ))
      (local.set $level_ptr (i32.add (local.get $level_ptr) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nlevels)
      (i32.ne)
      (br_if $level_loop)
    )
  )
)
