;;; -*- lexical-binding: t -*-
(progn
  (set
   (make-local-variable 'lexical-binding)
   t)
  'cl
  (progn
    (or lexical-binding
        (signal 'cl-assertion-failed
                (list 'lexical-binding)))
    nil)
  (let*
    ((h
      (make-hash-table :test 'eq)))
    (defalias 'y-unique
      #'(lambda
          (&optional x)
          (let*
            ((s
              (or x 'gs))
             (n
              (gethash s h 0))
             (s1
              (make-symbol
               (format "%s%d"
                       (symbol-name s)
                       n))))
            (puthash s
                     (+ n 1)
                     h)
            s1))))
  (defalias 'y-let-unique
    (cons 'macro
          #'(lambda
              (vars &rest body)
              (cons 'let*
                    (cons
                     (mapcar
                      #'(lambda
                          (x)
                          (list x
                                (list 'y-unique
                                      (list 'quote x))))
                      vars)
                     body)))))
  (prog1
(defalias 'y-next
  #'(lambda
      (h)
      (if
          (keywordp
           (car h))
          (cddr h)
        (cdr h))))
'byte-compile-inline-expand)
  (defalias 'y-%for
    (cons 'macro
          #'(lambda
              (h k v &rest body)
              (let*
                ((i
                  (y-unique 'i)))
                (cons 'let*
                      (cons
                       (list
                         (cons i
                               '(-1)))
                       (cons
                        (list 'while h
                              (cons 'let*
                                    (cons
                                     (list
                                       (list k
                                             (list 'if
                                                   (list 'keywordp
                                                         (list 'car h))
                                                   (list 'car h)
                                                   (list 'incf i)))
                                       (list v
                                             (list 'if
                                                   (list 'keywordp
                                                         (list 'car h))
                                                   (list 'cadr h)
                                                   (list 'car h))))
                                     body))
                              (list 'setq h
                                    (list 'if
                                          (list 'keywordp
                                                (list 'car h))
                                          (list 'cddr h)
                                          (list 'cdr h))))
                        '(nil))))))))
  (defalias 'y-set
    (cons 'macro
          #'(lambda
              (a &optional b)
              (list 'setf a b))))
  (prog1
(defalias 'y-get
  #'(lambda
      (h k)
      (if
          (hash-table-p h)
          (gethash k h)
        (if
            (listp h)
            (catch 'y-break
              (let*
                ((i8 -1))
                (while h
                  (let*
                    ((var
                      (if
                          (keywordp
                           (car h))
                          (car h)
                        (setq i8
                              (1+ i8))))
                     (val
                      (if
                          (keywordp
                           (car h))
                          (cadr h)
                        (car h))))
                    (if
                        (eq var k)
                        (progn
                          (throw 'y-break val))))
                  (setq h
                        (if
                            (keywordp
                             (car h))
                            (cddr h)
                          (cdr h))))
                nil))
          (elt h k)))))
'byte-compile-inline-expand)
  (put 'y-get 'gv-expander
       #'(lambda
           (f place idx)
           (gv-get place
                   #'(lambda
                       (getter setter)
                       (funcall f
                                (list 'y-get getter idx)
                                #'(lambda
                                    (val)
                                    (let*
                                      ((k
                                        (y-unique 'k))
                                       (v
                                        (y-unique 'v)))
                                      (list 'let*
                                            (list
                                              (list k idx)
                                              (list v val))
                                            (list 'y-set getter
                                                  (list 'y-put getter k v))
                                            v))))))))
  (prog1
(defalias 'y-put
  #'(lambda
      (h k &optional v)
      (if
          (hash-table-p h)
          (progn
            (puthash k v h)
            h)
        (let*
          ((l h))
          (if
              (listp h)
              (catch 'y-break
                (if
                    (or
                     (keywordp k)
                     (>= k 0))
                    (progn
                      (if
                          (null l)
                          (progn
                            (setq l
                                  (if
                                      (keywordp k)
                                      (list k nil)
                                    (list nil)))
                            (setq h l)))
                      (let*
                        ((i9 -1))
                        (while h
                          (let*
                            ((var
                              (if
                                  (keywordp
                                   (car h))
                                  (car h)
                                (setq i9
                                      (1+ i9))))
                             (_val
                              (if
                                  (keywordp
                                   (car h))
                                  (cadr h)
                                (car h))))
                            (if
                                (eq var k)
                                (progn
                                  (if
                                      (keywordp k)
                                      (setcar
                                       (cdr h)
                                       v)
                                    (setq h
                                          (setcar h v)))
                                  (throw 'y-break l)))
                            (if
                                (null
                                 (y-next h))
                                (progn
                                  (if
                                      (keywordp k)
                                      (nconc h
                                             (list k v))
                                    (nconc h
                                           (list nil))))))
                          (setq h
                                (if
                                    (keywordp
                                     (car h))
                                    (cddr h)
                                  (cdr h))))
                        nil))))
            (aset h k v))
          l))))
'byte-compile-inline-expand)
  (prog1
(defalias 'y-length
  #'(lambda
      (h &optional upto)
      (catch 'y-break
        (if
            (listp h)
            (let*
              ((n -1))
              (let*
                ((i10 -1))
                (while h
                  (let*
                    ((k
                      (if
                          (keywordp
                           (car h))
                          (car h)
                        (setq i10
                              (1+ i10))))
                     (_v
                      (if
                          (keywordp
                           (car h))
                          (cadr h)
                        (car h))))
                    (if
                        (integerp k)
                        (progn
                          (setq n
                                (max n k))
                          (if
                              (and upto
                                   (>= n upto))
                              (progn
                                (throw 'y-break
                                       (+ n 1)))))))
                  (setq h
                        (if
                            (keywordp
                             (car h))
                            (cddr h)
                          (cdr h))))
                nil)
              (+ n 1))
          (if
              (hash-table-p h)
              (let*
                ((n -1))
                (maphash
                 #'(lambda
                     (k _v)
                     (if
                         (integerp k)
                         (progn
                           (setq n
                                 (max n k))
                           (if
                               (and upto
                                    (>= n upto))
                               (progn
                                 (throw 'y-break
                                        (+ n 1)))))))
                 h)
                (+ n 1))
            (length h))))))
'byte-compile-inline-expand)
  (defalias 'y-do
    (cons 'macro
          #'(lambda
              (&rest body)
              (let*
                ((y-environment
                  (y-apply 'vector
                           (append y-environment nil))))
                (cons 'progn
                      (mapcar 'y-macroexpand body))))))
  (progn
(defvar y-environment
  (list
    (make-hash-table :test 'eq)))
(progn
(defalias 'y-setenv
  #'(lambda
      (k &rest ks)
      (let*
        ((i0
          (if
              (memq :toplevel ks)
              0
            (-
             (y-length y-environment)
             1))))
        (progn
          (let*
            ((frame
              (y-get y-environment i0)))
            (let*
              ((entry
                (or
                 (y-get frame k)
                 (make-hash-table :test 'eq))))
              (progn
                (let*
                  ((o0 ks))
                  (let*
                    ((f0
                      #'(lambda
                          (k a0)
                          (let*
                            ((v a0))
                            (progn
                              (let*
                                ((k2 k)
                                 (v3 v))
                                (setq entry
                                      (y-put entry k2 v3))
                                v3))))))
                    (progn
                      (if
                          (hash-table-p o0)
                          (maphash f0 o0)
                        (if
                            (listp o0)
                            (let*
                              ((i11 -1))
                              (while o0
                                (let*
                                  ((k
                                    (if
                                        (keywordp
                                         (car o0))
                                        (car o0)
                                      (setq i11
                                            (1+ i11))))
                                   (a0
                                    (if
                                        (keywordp
                                         (car o0))
                                        (cadr o0)
                                      (car o0))))
                                  (funcall f0 k a0))
                                (setq o0
                                      (if
                                          (keywordp
                                           (car o0))
                                          (cddr o0)
                                        (cdr o0))))
                              nil)
                          (let*
                            ((n0
                              (y-length o0)))
                            (progn
                              (let*
                                ((k 0))
                                (progn
                                  (while
                                    (< k n0)
                                    (let*
                                      ((a0
                                        (y-get o0 k)))
                                      (progn
                                        (funcall f0 k a0)))
                                    (setq k
                                          (+ k 1))))))))))))
                (let*
                  ((k3 k)
                   (v4 entry))
                  (setq frame
                        (y-put frame k3 v4))
                  v4))))))))
(y-setenv 'setenv :symbol 'y-setenv))
(progn
(defalias 'y-getenv
  #'(lambda
      (k &optional p)
      (let*
        ((i1
          (-
           (y-length y-environment)
           1)))
        (progn
          (progn
            (catch 'y-break
              (while
                (>= i1 0)
                (let*
                  ((b
                    (y-get
                     (y-get y-environment i1)
                     k)))
                  (progn
                    (if b
                        (throw 'y-break
                               (if p
                                   (y-get b p)
                                 b))
                      (setq i1
                            (- i1 1))))))))))))
(y-setenv 'getenv :symbol 'y-getenv))
(y-setenv 'unique :symbol 'y-unique)
(y-setenv 'let-unique :symbol 'y-let-unique)
(y-setenv 'at :symbol 'get)
(y-setenv 'set :macro
          #'(lambda
              (&rest args)
              (cons 'y-set args)))
(y-setenv 'get :symbol 'y-get)
(y-setenv '\# :symbol 'y-length)
(y-setenv '= :symbol 'eql)
(y-setenv 'environment :symbol 'y-environment)
(progn
(defalias 'y-nil-p
  #'(lambda
      (x)
      (eql x nil)))
(y-setenv 'nil\? :symbol 'y-nil-p))
(progn
(defalias 'y-is-p
  #'(lambda
      (x)
      (not
       (y-nil-p x))))
(y-setenv 'is\? :symbol 'y-is-p))
(progn
(defalias 'y-none-p
  #'(lambda
      (x)
      (eql
       (y-length x 0)
       0)))
(y-setenv 'none\? :symbol 'y-none-p))
(progn
(defalias 'y-some-p
  #'(lambda
      (x)
      (>
       (y-length x 0)
       0)))
(y-setenv 'some\? :symbol 'y-some-p))
(progn
(defalias 'y-one-p
  #'(lambda
      (x)
      (eql
       (y-length x 1)
       1)))
(y-setenv 'one\? :symbol 'y-one-p))
(progn
(defalias 'y-two-p
  #'(lambda
      (x)
      (eql
       (y-length x 2)
       2)))
(y-setenv 'two\? :symbol 'y-two-p))
(progn
(defalias 'y-hd
  #'(lambda
      (l)
      (y-get l 0)))
(y-setenv 'hd :symbol 'y-hd))
(progn
(defalias 'y-type
  #'(lambda
      (x)
      (type-of x)))
(y-setenv 'type :symbol 'y-type))
(progn
(defalias 'y-string-p
  #'(lambda
      (x)
      (stringp x)))
(y-setenv 'string\? :symbol 'y-string-p))
(progn
(defalias 'y-number-p
  #'(lambda
      (x)
      (or
       (integerp x)
       (numberp x))))
(y-setenv 'number\? :symbol 'y-number-p))
(progn
(defalias 'y-function-p
  #'(lambda
      (x)
      (and
       (not
        (symbolp x))
       (functionp x))))
(y-setenv 'function\? :symbol 'y-function-p))
(progn
(defalias 'y-obj-p
  #'(lambda
      (x)
      (hash-table-p x)))
(y-setenv 'obj\? :symbol 'y-obj-p))
(y-setenv 'obj :macro
          #'(lambda nil
              '(make-hash-table :test 'eq)))
(progn
(defalias 'y-atom-p
  #'(lambda
      (x)
      (or
       (y-nil-p x)
       (symbolp x)
       (y-string-p x)
       (y-number-p x))))
(y-setenv 'atom\? :symbol 'y-atom-p))
(progn
(defalias 'y-clip
  #'(lambda
      (s from &optional upto)
      (let*
        ((n1
          (length s)))
        (progn
          (let*
            ((i
              (if
                  (or
                   (y-nil-p from)
                   (< from 0))
                  0 from)))
            (let*
              ((j
                (if
                    (or
                     (y-nil-p upto)
                     (> upto n1))
                    n1
                  (max upto i))))
              (progn
                (substring s i j))))))))
(y-setenv 'clip :symbol 'y-clip))
(progn
(defalias 'y--chop-p
  #'(lambda
      (x from upto)
      (and
       (consp x)
       (eql from 1)
       (null upto)
       (not
        (keywordp
         (car x))))))
(y-setenv 'chop\? :symbol 'y--chop-p))
(progn
(defalias 'y-cut
  #'(lambda
      (x &optional from upto)
      (if
          (y--chop-p x from upto)
          (cdr x)
        (let*
          ((l0
            (if
                (y-obj-p x)
                (make-hash-table :test 'eq)
              nil)))
          (progn
            (progn
              (let*
                ((j 0))
                (let*
                  ((i
                    (if
                        (or
                         (y-nil-p from)
                         (< from 0))
                        0 from)))
                  (let*
                    ((n
                      (y-length x)))
                    (let*
                      ((upto
                        (if
                            (or
                             (y-nil-p upto)
                             (> upto n))
                            n upto)))
                      (progn
                        (while
                          (< i upto)
                          (let*
                            ((k4 j)
                             (v5
                              (y-get x i)))
                            (setq l0
                                  (y-put l0 k4 v5))
                            v5)
                          (setq i
                                (+ i 1))
                          (setq j
                                (+ j 1)))
                        (let*
                          ((o1 x))
                          (let*
                            ((f1
                              #'(lambda
                                  (k a1)
                                  (let*
                                    ((v a1))
                                    (progn
                                      (if
                                          (y-number-p k)
                                          nil
                                        (let*
                                          ((k5 k)
                                           (v6 v))
                                          (setq l0
                                                (y-put l0 k5 v6))
                                          v6)))))))
                            (progn
                              (if
                                  (hash-table-p o1)
                                  (maphash f1 o1)
                                (if
                                    (listp o1)
                                    (let*
                                      ((i12 -1))
                                      (while o1
                                        (let*
                                          ((k
                                            (if
                                                (keywordp
                                                 (car o1))
                                                (car o1)
                                              (setq i12
                                                    (1+ i12))))
                                           (a1
                                            (if
                                                (keywordp
                                                 (car o1))
                                                (cadr o1)
                                              (car o1))))
                                          (funcall f1 k a1))
                                        (setq o1
                                              (if
                                                  (keywordp
                                                   (car o1))
                                                  (cddr o1)
                                                (cdr o1))))
                                      nil)
                                  (let*
                                    ((n2
                                      (y-length o1)))
                                    (progn
                                      (let*
                                        ((k 0))
                                        (progn
                                          (while
                                            (< k n2)
                                            (let*
                                              ((a1
                                                (y-get o1 k)))
                                              (progn
                                                (funcall f1 k a1)))
                                            (setq k
                                                  (+ k 1)))))))))))))))))
              l0))))))
(y-setenv 'cut :symbol 'y-cut))
(progn
(defalias 'y-keys
  #'(lambda
      (x)
      (let*
        ((l1
          (if
              (y-obj-p x)
              (make-hash-table :test 'eq)
            nil)))
        (progn
          (progn
            (let*
              ((o2 x))
              (let*
                ((f2
                  #'(lambda
                      (k a2)
                      (let*
                        ((v a2))
                        (progn
                          (if
                              (y-number-p k)
                              nil
                            (let*
                              ((k6 k)
                               (v7 v))
                              (setq l1
                                    (y-put l1 k6 v7))
                              v7)))))))
                (progn
                  (if
                      (hash-table-p o2)
                      (maphash f2 o2)
                    (if
                        (listp o2)
                        (let*
                          ((i13 -1))
                          (while o2
                            (let*
                              ((k
                                (if
                                    (keywordp
                                     (car o2))
                                    (car o2)
                                  (setq i13
                                        (1+ i13))))
                               (a2
                                (if
                                    (keywordp
                                     (car o2))
                                    (cadr o2)
                                  (car o2))))
                              (funcall f2 k a2))
                            (setq o2
                                  (if
                                      (keywordp
                                       (car o2))
                                      (cddr o2)
                                    (cdr o2))))
                          nil)
                      (let*
                        ((n3
                          (y-length o2)))
                        (progn
                          (let*
                            ((k 0))
                            (progn
                              (while
                                (< k n3)
                                (let*
                                  ((a2
                                    (y-get o2 k)))
                                  (progn
                                    (funcall f2 k a2)))
                                (setq k
                                      (+ k 1))))))))))))
            l1)))))
(y-setenv 'keys :symbol 'y-keys))
(progn
(defalias 'y-edge
  #'(lambda
      (x)
      (-
       (y-length x)
       1)))
(y-setenv 'edge :symbol 'y-edge))
(progn
(defalias 'y-tl
  #'(lambda
      (l)
      (y-cut l 1)))
(y-setenv 'tl :symbol 'y-tl))
(progn
(defalias 'y-last
  #'(lambda
      (l)
      (y-get l
             (y-edge l))))
(y-setenv 'last :symbol 'y-last))
(progn
(defalias 'y-almost
  #'(lambda
      (l)
      (y-cut l 0
             (y-edge l))))
(y-setenv 'almost :symbol 'y-almost))
(y-setenv 'add :macro
          #'(lambda
              (l x)
              (progn
                (or
                 (y-atom-p l)
                 (signal 'cl-assertion-failed
                         (list
                           '(y-atom-p l))))
                nil)
              (cons 'progn
                    (cons
                     (list 'set
                           (list 'at l
                                 (list '\# l))
                           x)
                     '(nil)))))
(y-setenv 'drop :macro
          #'(lambda
              (l)
              (progn
                (or
                 (y-atom-p l)
                 (signal 'cl-assertion-failed
                         (list
                           '(y-atom-p l))))
                nil)
              (list 'prog1
                    (list 'at l
                          (list 'edge l))
                    (list 'set l
                          (list 'almost l)))))
(progn
(defalias 'y-reverse
  #'(lambda
      (l)
      (let*
        ((l10
          (y-keys l)))
        (progn
          (progn
            (let*
              ((i
                (y-edge l)))
              (progn
                (while
                  (>= i 0)
                  (progn
                    (let*
                      ((k7
                        (y-length l10))
                       (v8
                        (y-get l i)))
                      (setq l10
                            (y-put l10 k7 v8))
                      v8)
                    nil)
                  (setq i
                        (- i 1)))))
            l10)))))
(y-setenv 'reverse :symbol 'y-reverse))
(progn
(defalias 'y-reduce
  #'(lambda
      (f x)
      (if
          (y-none-p x)
          nil
        (y-one-p x)
        (y-hd x)
        (funcall f
                 (y-hd x)
                 (y-reduce f
                           (y-tl x))))))
(y-setenv 'reduce :symbol 'y-reduce))
(progn
(defalias 'y-join
  #'(lambda
      (&rest ls)
      (if
          (y-two-p ls)
          (let*
            ((var00 ls))
            (progn
              (let*
                ((a
                  (y-get var00 '0)))
                (let*
                  ((b
                    (y-get var00 '1)))
                  (progn
                    (if
                        (and a b)
                        (let*
                          ((c
                            (if
                                (y-obj-p a)
                                (make-hash-table :test 'eq)
                              nil)))
                          (let*
                            ((o
                              (y-length a)))
                            (progn
                              (let*
                                ((o3 a))
                                (let*
                                  ((f3
                                    #'(lambda
                                        (k a3)
                                        (let*
                                          ((v a3))
                                          (progn
                                            (let*
                                              ((k8 k)
                                               (v9 v))
                                              (setq c
                                                    (y-put c k8 v9))
                                              v9))))))
                                  (progn
                                    (if
                                        (hash-table-p o3)
                                        (maphash f3 o3)
                                      (if
                                          (listp o3)
                                          (let*
                                            ((i14 -1))
                                            (while o3
                                              (let*
                                                ((k
                                                  (if
                                                      (keywordp
                                                       (car o3))
                                                      (car o3)
                                                    (setq i14
                                                          (1+ i14))))
                                                 (a3
                                                  (if
                                                      (keywordp
                                                       (car o3))
                                                      (cadr o3)
                                                    (car o3))))
                                                (funcall f3 k a3))
                                              (setq o3
                                                    (if
                                                        (keywordp
                                                         (car o3))
                                                        (cddr o3)
                                                      (cdr o3))))
                                            nil)
                                        (let*
                                          ((n4
                                            (y-length o3)))
                                          (progn
                                            (let*
                                              ((k 0))
                                              (progn
                                                (while
                                                  (< k n4)
                                                  (let*
                                                    ((a3
                                                      (y-get o3 k)))
                                                    (progn
                                                      (funcall f3 k a3)))
                                                  (setq k
                                                        (+ k 1))))))))))))
                              (let*
                                ((o4 b))
                                (let*
                                  ((f4
                                    #'(lambda
                                        (k a4)
                                        (let*
                                          ((v0 a4))
                                          (progn
                                            (progn
                                              (if
                                                  (y-number-p k)
                                                  (progn
                                                    (setq k
                                                          (+ k o))))
                                              (let*
                                                ((k9 k)
                                                 (v10 v0))
                                                (setq c
                                                      (y-put c k9 v10))
                                                v10)))))))
                                  (progn
                                    (if
                                        (hash-table-p o4)
                                        (maphash f4 o4)
                                      (if
                                          (listp o4)
                                          (let*
                                            ((i15 -1))
                                            (while o4
                                              (let*
                                                ((k
                                                  (if
                                                      (keywordp
                                                       (car o4))
                                                      (car o4)
                                                    (setq i15
                                                          (1+ i15))))
                                                 (a4
                                                  (if
                                                      (keywordp
                                                       (car o4))
                                                      (cadr o4)
                                                    (car o4))))
                                                (funcall f4 k a4))
                                              (setq o4
                                                    (if
                                                        (keywordp
                                                         (car o4))
                                                        (cddr o4)
                                                      (cdr o4))))
                                            nil)
                                        (let*
                                          ((n5
                                            (y-length o4)))
                                          (progn
                                            (let*
                                              ((k0 0))
                                              (progn
                                                (progn
                                                  (while
                                                    (< k0 n5)
                                                    (let*
                                                      ((a4
                                                        (y-get o4 k0)))
                                                      (progn
                                                        (funcall f4 k0 a4)))
                                                    (setq k0
                                                          (+ k0 1)))))))))))))
                              c)))
                      (or a b nil)))))))
        (or
         (y-reduce 'y-join ls)
         nil))))
(y-setenv 'join :symbol 'y-join))
(progn
(defalias 'y-find
  #'(lambda
      (f l)
      (catch 'y-break
        (let*
          ((o50 l))
          (progn
            (let*
              ((f5
                #'(lambda
                    (i2 a5)
                    (let*
                      ((x a5))
                      (progn
                        (let*
                          ((y
                            (funcall f x)))
                          (progn
                            (if y
                                (throw 'y-break y)))))))))
              (progn
                (if
                    (hash-table-p o50)
                    (maphash f5 o50)
                  (if
                      (listp o50)
                      (let*
                        ((i16 -1))
                        (while o50
                          (let*
                            ((i2
                              (if
                                  (keywordp
                                   (car o50))
                                  (car o50)
                                (setq i16
                                      (1+ i16))))
                             (a5
                              (if
                                  (keywordp
                                   (car o50))
                                  (cadr o50)
                                (car o50))))
                            (funcall f5 i2 a5))
                          (setq o50
                                (if
                                    (keywordp
                                     (car o50))
                                    (cddr o50)
                                  (cdr o50))))
                        nil)
                    (let*
                      ((n6
                        (y-length o50)))
                      (progn
                        (let*
                          ((i2 0))
                          (progn
                            (while
                              (< i2 n6)
                              (let*
                                ((a5
                                  (y-get o50 i2)))
                                (progn
                                  (funcall f5 i2 a5)))
                              (setq i2
                                    (+ i2 1))))))))))))))))
(y-setenv 'find :symbol 'y-find))
(progn
(defalias 'y-first
  #'(lambda
      (f l)
      (catch 'y-break
        (let*
          ((x00 l))
          (progn
            (let*
              ((n7
                (y-length x00)))
              (progn
                (let*
                  ((i3 0))
                  (progn
                    (while
                      (< i3 n7)
                      (let*
                        ((x
                          (y-get x00 i3)))
                        (progn
                          (let*
                            ((y
                              (funcall f x)))
                            (progn
                              (if y
                                  (throw 'y-break y))))))
                      (setq i3
                            (+ i3 1))))))))))))
(y-setenv 'first :symbol 'y-first))
(progn
(defalias 'y-in-p
  #'(lambda
      (x l)
      (y-find
       #'(lambda
           (y)
           (eql x y))
       l)))
(y-setenv 'in\? :symbol 'y-in-p))
(progn
(defalias 'y-pair
  #'(lambda
      (l)
      (let*
        ((l11
          (if
              (y-obj-p l)
              (make-hash-table :test 'eq)
            nil)))
        (progn
          (progn
            (let*
              ((n
                (y-length l)))
              (progn
                (let*
                  ((i 0))
                  (progn
                    (while
                      (< i n)
                      (progn
                        (let*
                          ((k10
                            (y-length l11))
                           (v11
                            (list
                              (y-get l i)
                              (y-get l
                                     (+ i 1)))))
                          (setq l11
                                (y-put l11 k10 v11))
                          v11)
                        nil)
                      (setq i
                            (+ i 1))
                      (setq i
                            (+ i 1)))))))
            l11)))))
(y-setenv 'pair :symbol 'y-pair))
(progn
(defalias 'y-map
  #'(lambda
      (f x)
      (let*
        ((l2
          (if
              (y-obj-p x)
              (make-hash-table :test 'eq)
            nil)))
        (progn
          (progn
            (let*
              ((x1 x))
              (let*
                ((n8
                  (y-length x1)))
                (progn
                  (let*
                    ((i4 0))
                    (progn
                      (while
                        (< i4 n8)
                        (let*
                          ((v
                            (y-get x1 i4)))
                          (progn
                            (let*
                              ((y
                                (funcall f v)))
                              (progn
                                (if
                                    (y-is-p y)
                                    (progn
                                      (let*
                                        ((k11
                                          (y-length l2))
                                         (v12 y))
                                        (setq l2
                                              (y-put l2 k11 v12))
                                        v12)
                                      nil))))))
                        (setq i4
                              (+ i4 1))))))))
            (let*
              ((o6 x))
              (let*
                ((f6
                  #'(lambda
                      (k a6)
                      (let*
                        ((v1 a6))
                        (progn
                          (progn
                            (if
                                (y-number-p k)
                                nil
                              (let*
                                ((y0
                                  (funcall f v1)))
                                (progn
                                  (progn
                                    (if
                                        (y-is-p y0)
                                        (progn
                                          (let*
                                            ((k12 k)
                                             (v13 y0))
                                            (setq l2
                                                  (y-put l2 k12 v13))
                                            v13)))))))))))))
                (progn
                  (if
                      (hash-table-p o6)
                      (maphash f6 o6)
                    (if
                        (listp o6)
                        (let*
                          ((i17 -1))
                          (while o6
                            (let*
                              ((k
                                (if
                                    (keywordp
                                     (car o6))
                                    (car o6)
                                  (setq i17
                                        (1+ i17))))
                               (a6
                                (if
                                    (keywordp
                                     (car o6))
                                    (cadr o6)
                                  (car o6))))
                              (funcall f6 k a6))
                            (setq o6
                                  (if
                                      (keywordp
                                       (car o6))
                                      (cddr o6)
                                    (cdr o6))))
                          nil)
                      (let*
                        ((n9
                          (y-length o6)))
                        (progn
                          (let*
                            ((k 0))
                            (progn
                              (while
                                (< k n9)
                                (let*
                                  ((a6
                                    (y-get o6 k)))
                                  (progn
                                    (funcall f6 k a6)))
                                (setq k
                                      (+ k 1))))))))))))
            l2)))))
(y-setenv 'map :symbol 'y-map))
(progn
(defalias 'y-keep
  #'(lambda
      (f x)
      (y-map
       #'(lambda
           (v)
           (if
               (funcall f v)
               (progn v)))
       x)))
(y-setenv 'keep :symbol 'y-keep))
(progn
(defalias 'y-keys-p
  #'(lambda
      (l)
      (catch 'y-break
        (let*
          ((o70 l))
          (progn
            (let*
              ((f7
                #'(lambda
                    (k a7)
                    (let*
                      ((v a7))
                      (progn
                        (setq v v)
                        (if
                            (y-number-p k)
                            nil
                          (throw 'y-break t)))))))
              (progn
                (if
                    (hash-table-p o70)
                    (maphash f7 o70)
                  (if
                      (listp o70)
                      (let*
                        ((i18 -1))
                        (while o70
                          (let*
                            ((k
                              (if
                                  (keywordp
                                   (car o70))
                                  (car o70)
                                (setq i18
                                      (1+ i18))))
                             (a7
                              (if
                                  (keywordp
                                   (car o70))
                                  (cadr o70)
                                (car o70))))
                            (funcall f7 k a7))
                          (setq o70
                                (if
                                    (keywordp
                                     (car o70))
                                    (cddr o70)
                                  (cdr o70))))
                        nil)
                    (let*
                      ((n10
                        (y-length o70)))
                      (progn
                        (let*
                          ((k 0))
                          (progn
                            (while
                              (< k n10)
                              (let*
                                ((a7
                                  (y-get o70 k)))
                                (progn
                                  (funcall f7 k a7)))
                              (setq k
                                    (+ k 1)))))))))))))
        nil)))
(y-setenv 'keys\? :symbol 'y-keys-p))
(progn
(defalias 'y-empty-p
  #'(lambda
      (l)
      (catch 'y-break
        (let*
          ((o80 l))
          (progn
            (let*
              ((f8
                #'(lambda
                    (i5 a8)
                    (let*
                      ((x a8))
                      (progn
                        (setq x x)
                        (throw 'y-break nil))))))
              (progn
                (if
                    (hash-table-p o80)
                    (maphash f8 o80)
                  (if
                      (listp o80)
                      (let*
                        ((i19 -1))
                        (while o80
                          (let*
                            ((i5
                              (if
                                  (keywordp
                                   (car o80))
                                  (car o80)
                                (setq i19
                                      (1+ i19))))
                             (a8
                              (if
                                  (keywordp
                                   (car o80))
                                  (cadr o80)
                                (car o80))))
                            (funcall f8 i5 a8))
                          (setq o80
                                (if
                                    (keywordp
                                     (car o80))
                                    (cddr o80)
                                  (cdr o80))))
                        nil)
                    (let*
                      ((n11
                        (y-length o80)))
                      (progn
                        (let*
                          ((i5 0))
                          (progn
                            (while
                              (< i5 n11)
                              (let*
                                ((a8
                                  (y-get o80 i5)))
                                (progn
                                  (funcall f8 i5 a8)))
                              (setq i5
                                    (+ i5 1)))))))))))))
        t)))
(y-setenv 'empty\? :symbol 'y-empty-p))
(progn
(defalias 'y-stash
  #'(lambda
      (args)
      (let*
        ((l3 nil))
        (progn
          (progn
            (let*
              ((x2 args))
              (let*
                ((n12
                  (y-length x2)))
                (progn
                  (let*
                    ((i6 0))
                    (progn
                      (while
                        (< i6 n12)
                        (let*
                          ((x
                            (y-get x2 i6)))
                          (progn
                            (progn
                              (let*
                                ((k13
                                  (y-length l3))
                                 (v14 x))
                                (setq l3
                                      (y-put l3 k13 v14))
                                v14)
                              nil)))
                        (setq i6
                              (+ i6 1))))))))
            (if
                (y-keys-p args)
                (progn
                  (let*
                    ((p
                      (if
                          (y-obj-p args)
                          (make-hash-table :test 'eq)
                        nil)))
                    (progn
                      (let*
                        ((o9 args))
                        (let*
                          ((f9
                            #'(lambda
                                (k a9)
                                (let*
                                  ((v a9))
                                  (progn
                                    (if
                                        (y-number-p k)
                                        nil
                                      (let*
                                        ((k14 k)
                                         (v15 v))
                                        (setq p
                                              (y-put p k14 v15))
                                        v15)))))))
                          (progn
                            (if
                                (hash-table-p o9)
                                (maphash f9 o9)
                              (if
                                  (listp o9)
                                  (let*
                                    ((i20 -1))
                                    (while o9
                                      (let*
                                        ((k
                                          (if
                                              (keywordp
                                               (car o9))
                                              (car o9)
                                            (setq i20
                                                  (1+ i20))))
                                         (a9
                                          (if
                                              (keywordp
                                               (car o9))
                                              (cadr o9)
                                            (car o9))))
                                        (funcall f9 k a9))
                                      (setq o9
                                            (if
                                                (keywordp
                                                 (car o9))
                                                (cddr o9)
                                              (cdr o9))))
                                    nil)
                                (let*
                                  ((n13
                                    (y-length o9)))
                                  (progn
                                    (let*
                                      ((k 0))
                                      (progn
                                        (while
                                          (< k n13)
                                          (let*
                                            ((a9
                                              (y-get o9 k)))
                                            (progn
                                              (funcall f9 k a9)))
                                          (setq k
                                                (+ k 1))))))))))))
                      (let*
                        ((k15 :_stash)
                         (v16 t))
                        (setq p
                              (y-put p k15 v16))
                        v16)
                      (progn
                        (let*
                          ((k16
                            (y-length l3))
                           (v17 p))
                          (setq l3
                                (y-put l3 k16 v17))
                          v17)
                        nil)))))
            l3)))))
(y-setenv 'stash :symbol 'y-stash))
(progn
(defalias 'y-unstash
  #'(lambda
      (args)
      (if
          (y-none-p args)
          nil
        (let*
          ((l4
            (y-last args)))
          (progn
            (progn
              (if
                  (y-get l4 :_stash)
                  (let*
                    ((args1
                      (y-almost args)))
                    (progn
                      (let*
                        ((o10 l4))
                        (let*
                          ((f10
                            #'(lambda
                                (k a10)
                                (let*
                                  ((v a10))
                                  (progn
                                    (if
                                        (eql k :_stash)
                                        nil
                                      (let*
                                        ((k17 k)
                                         (v18 v))
                                        (setq args1
                                              (y-put args1 k17 v18))
                                        v18)))))))
                          (progn
                            (if
                                (hash-table-p o10)
                                (maphash f10 o10)
                              (if
                                  (listp o10)
                                  (let*
                                    ((i21 -1))
                                    (while o10
                                      (let*
                                        ((k
                                          (if
                                              (keywordp
                                               (car o10))
                                              (car o10)
                                            (setq i21
                                                  (1+ i21))))
                                         (a10
                                          (if
                                              (keywordp
                                               (car o10))
                                              (cadr o10)
                                            (car o10))))
                                        (funcall f10 k a10))
                                      (setq o10
                                            (if
                                                (keywordp
                                                 (car o10))
                                                (cddr o10)
                                              (cdr o10))))
                                    nil)
                                (let*
                                  ((n14
                                    (y-length o10)))
                                  (progn
                                    (let*
                                      ((k 0))
                                      (progn
                                        (while
                                          (< k n14)
                                          (let*
                                            ((a10
                                              (y-get o10 k)))
                                            (progn
                                              (funcall f10 k a10)))
                                          (setq k
                                                (+ k 1))))))))))))
                      args1))
                args)))))))
(y-setenv 'unstash :symbol 'y-unstash))
(progn
(defalias 'y-destash!
  #'(lambda
      (l args1)
      (if
          (and
           (or
            (listp l)
            (y-obj-p l))
           (y-get l :_stash))
          (let*
            ((o110 l))
            (progn
              (let*
                ((f11
                  #'(lambda
                      (k a11)
                      (let*
                        ((v a11))
                        (progn
                          (if
                              (eql k :_stash)
                              nil
                            (let*
                              ((k18 k)
                               (v19 v))
                              (setq args1
                                    (y-put args1 k18 v19))
                              v19)))))))
                (progn
                  (if
                      (hash-table-p o110)
                      (maphash f11 o110)
                    (if
                        (listp o110)
                        (let*
                          ((i22 -1))
                          (while o110
                            (let*
                              ((k
                                (if
                                    (keywordp
                                     (car o110))
                                    (car o110)
                                  (setq i22
                                        (1+ i22))))
                               (a11
                                (if
                                    (keywordp
                                     (car o110))
                                    (cadr o110)
                                  (car o110))))
                              (funcall f11 k a11))
                            (setq o110
                                  (if
                                      (keywordp
                                       (car o110))
                                      (cddr o110)
                                    (cdr o110))))
                          nil)
                      (let*
                        ((n15
                          (y-length o110)))
                        (progn
                          (let*
                            ((k 0))
                            (progn
                              (while
                                (< k n15)
                                (let*
                                  ((a11
                                    (y-get o110 k)))
                                  (progn
                                    (funcall f11 k a11)))
                                (setq k
                                      (+ k 1)))))))))))))
        l)))
(y-setenv 'destash! :symbol 'y-destash!))
(progn
(defalias 'y-apply
  #'(lambda
      (f args)
      (let*
        ((args10
          (y-stash args)))
        (progn
          (progn
            (funcall 'apply f args10))))))
(y-setenv 'apply :symbol 'y-apply))
(progn
(defalias 'y-toplevel-p
  #'(lambda nil
      (y-one-p y-environment)))
(y-setenv 'toplevel\? :symbol 'y-toplevel-p))
(progn
(defalias 'y--id
  #'(lambda
      (x)
      (let*
        ((s0
          (append
           (if
               (symbolp x)
               (symbol-name x)
             x)
           nil)))
        (progn
          (progn
            (if
                (eq 63
                    (y-get s0
                           (y-edge s0)))
                (progn
                  (if
                      (memq 45 s0)
                      (progn
                        (let*
                          ((k19
                            (y-edge s0))
                           (v20 45))
                          (setq s0
                                (y-put s0 k19 v20))
                          v20)
                        (let*
                          ((k20
                            (y-length s0))
                           (v21 112))
                          (setq s0
                                (y-put s0 k20 v21))
                          v21))
                    (let*
                      ((k21
                        (y-edge s0))
                       (v22 112))
                      (setq s0
                            (y-put s0 k21 v22))
                      v22))))
            (intern
             (concat s0)))))))
(y-setenv 'id :symbol 'y--id))
(defvar y-module nil)
(progn
(defalias 'y--module-name
  #'(lambda nil
      (or y-module
          (let*
            ((file0
              (or load-file-name
                  (buffer-file-name))))
            (progn
              (progn
                (if file0
                    (file-name-base file0)
                  (buffer-name))))))))
(y-setenv 'module-name :symbol 'y--module-name))
(progn
(defalias 'y--global-id
  #'(lambda
      (prefix name)
      (let*
        ((s1
          (if
              (stringp name)
              name
            (symbol-name name))))
        (progn
          (progn
            (if
                (eq 0
                    (string-match
                     (regexp-quote prefix)
                     s1))
                name
              (y--id
               (concat prefix s1))))))))
(y-setenv 'global-id :symbol 'y--global-id))
(progn
(defalias 'y--macro-function
  #'(lambda
      (k)
      (y-getenv k :macro)))
(y-setenv 'macro-function :symbol 'y--macro-function))
(progn
(defalias 'y--macro-p
  #'(lambda
      (k)
      (y--macro-function k)))
(y-setenv 'macro\? :symbol 'y--macro-p))
(progn
(defalias 'y--symbol-expansion
  #'(lambda
      (k)
      (y-getenv k :symbol)))
(y-setenv 'symbol-expansion :symbol 'y--symbol-expansion))
(progn
(defalias 'y--symbol-p
  #'(lambda
      (k)
      (let*
        ((v2
          (y--symbol-expansion k)))
        (progn
          (progn
            (and v2
                 (not
                  (eq v2 k))))))))
(y-setenv 'symbol\? :symbol 'y--symbol-p))
(progn
(defalias 'y--variable-p
  #'(lambda
      (k)
      (let*
        ((i7
          (-
           (y-length y-environment)
           1)))
        (progn
          (progn
            (catch 'y-break
              (while
                (>= i7 0)
                (let*
                  ((b
                    (y-get
                     (y-get y-environment i7)
                     k)))
                  (progn
                    (if b
                        (throw 'y-break
                               (and b
                                    (y-get b :variable)))
                      (setq i7
                            (1- i7))))))))))))
(y-setenv 'variable\? :symbol 'y--variable-p))
(progn
(defalias 'y--bound-p
  #'(lambda
      (x)
      (or
       (y--macro-p x)
       (y--symbol-p x)
       (y--variable-p x))))
(y-setenv 'bound\? :symbol 'y--bound-p))
(progn
(defalias 'y--unkeywordify
  #'(lambda
      (k)
      (if
          (keywordp k)
          (intern
           (y-clip
            (symbol-name k)
            1))
        k)))
(y-setenv 'unkeywordify :symbol 'y--unkeywordify))
(progn
(defalias 'y--bind
  #'(lambda
      (lh rh)
      (if
          (y-atom-p lh)
          (list lh rh)
        (let*
          ((var
            (y-unique 'var)))
          (let*
            ((bs0
              (list var rh)))
            (progn
              (progn
                (let*
                  ((o12 lh))
                  (let*
                    ((f12
                      #'(lambda
                          (k a12)
                          (let*
                            ((v a12))
                            (progn
                              (let*
                                ((x
                                  (if
                                      (eql k :rest)
                                      (list 'cut var
                                            (y-length lh))
                                    (list 'get var
                                          (list 'quote k)))))
                                (progn
                                  (if
                                      (y-is-p k)
                                      (progn
                                        (let*
                                          ((k1
                                            (if
                                                (eql v t)
                                                (y--unkeywordify k)
                                              v)))
                                          (progn
                                            (progn
                                              (setq bs0
                                                    (y-join bs0
                                                            (y--bind k1 x)))))))))))))))
                    (progn
                      (if
                          (hash-table-p o12)
                          (maphash f12 o12)
                        (if
                            (listp o12)
                            (let*
                              ((i23 -1))
                              (while o12
                                (let*
                                  ((k
                                    (if
                                        (keywordp
                                         (car o12))
                                        (car o12)
                                      (setq i23
                                            (1+ i23))))
                                   (a12
                                    (if
                                        (keywordp
                                         (car o12))
                                        (cadr o12)
                                      (car o12))))
                                  (funcall f12 k a12))
                                (setq o12
                                      (if
                                          (keywordp
                                           (car o12))
                                          (cddr o12)
                                        (cdr o12))))
                              nil)
                          (let*
                            ((n16
                              (y-length o12)))
                            (progn
                              (let*
                                ((k 0))
                                (progn
                                  (while
                                    (< k n16)
                                    (let*
                                      ((a12
                                        (y-get o12 k)))
                                      (progn
                                        (funcall f12 k a12)))
                                    (setq k
                                          (+ k 1))))))))))))
                bs0)))))))
(y-setenv 'bind :symbol 'y--bind))
(progn
(defalias 'y-macroexpand
  #'(lambda
      (form)
      (let*
        ((s2
          (y--symbol-expansion form)))
        (progn
          (progn
            (if s2
                (y-macroexpand s2)
              (if
                  (atom form)
                  form
                (let*
                  ((x
                    (y-macroexpand
                     (y-hd form))))
                  (progn
                    (if
                        (eq x 'quote)
                        form
                      (if
                          (eq x '\`)
                          (y-macroexpand
                           (funcall 'macroexpand form))
                        (if
                            (y--macro-p x)
                            (y-macroexpand
                             (funcall 'apply
                                      (y--macro-function x)
                                      (y-tl form)))
                          (cons x
                                (mapcar 'y-macroexpand
                                        (y-tl form)))))))))))))))
(y-setenv 'macroexpand :symbol 'y-macroexpand))
(progn
(defalias 'y-expand
  #'(lambda
      (form)
      (macroexpand-all
       (y-macroexpand form))))
(y-setenv 'expand :symbol 'y-expand))
(progn
(defalias 'y-eval
  #'(lambda
      (form)
      (funcall 'eval
               (y-macroexpand form)
               t)))
(y-setenv 'eval :symbol 'y-eval))
(y-setenv 'with :macro
          #'(lambda
              (x v &rest body)
              (cons 'let
                    (cons
                     (list x v)
                     (append body
                             (list x))))))
(y-setenv 'fn :macro
          #'(lambda
              (args &rest body)
              (cons 'lambda
                    (cons
                     (if
                         (not
                          (listp args))
                         (list '&rest args)
                       args)
                     body))))
(y-setenv 'define-macro :macro
          #'(lambda
              (name args &rest body)
              (let*
                ((form1
                  (list 'setenv
                        (list 'quote name)
                        ':macro
                        (cons 'fn
                              (cons args body)))))
                (progn
                  (progn
                    (y-eval form1)
                    form1)))))
(y-setenv 'define-symbol :macro
          #'(lambda
              (name expansion)
              (y-setenv name :symbol expansion)
              (list 'setenv
                    (list 'quote name)
                    ':symbol
                    (list 'quote expansion))))
(y-setenv 'define :macro
          #'(lambda
              (name x &rest body)
              (let*
                ((var2
                  (y--global-id
                   (concat
                    (y--module-name)
                    "--")
                   name)))
                (progn
                  (progn
                    (y-setenv name :symbol var2)
                    (y-setenv var2 :variable t)
                    (list 'progn
                          (list 'defalias
                                (list 'quote var2)
                                (cons 'fn
                                      (cons x body)))
                          (list 'setenv
                                (list 'quote name)
                                ':symbol
                                (list 'quote var2))))))))
(y-setenv 'define-global :macro
          #'(lambda
              (name x &rest body)
              (let*
                ((var4
                  (y--global-id
                   (concat
                    (y--module-name)
                    "-")
                   name)))
                (progn
                  (progn
                    (y-setenv name :symbol var4)
                    (y-setenv var4 :variable t :toplevel t)
                    (list 'progn
                          (list 'defalias
                                (list 'quote var4)
                                (cons 'fn
                                      (cons x body)))
                          (list 'setenv
                                (list 'quote name)
                                ':symbol
                                (list 'quote var4))))))))
(y-setenv 'with-frame :macro
          #'(lambda
              (&rest body)
              (let*
                ((x
                  (y-unique 'x)))
                (list 'progn
                      '(set environment
                            (apply 'vector
                                   (append environment
                                           (list
                                             (obj)))))
                      (cons 'with
                            (cons x
                                  (cons
                                   (cons 'progn body)
                                   '((set environment
                                          (apply 'vector
                                                 (almost environment)))))))))))
(y-setenv 'let-macro :macro
          #'(lambda
(definitions &rest body)
(progn
  (setq y-environment
        (y-apply 'vector
                 (append y-environment
                         (list
                           (make-hash-table :test 'eq)))))
  (let*
    ((x40
      (progn
        (y-map
         #'(lambda
             (m)
             (y-macroexpand
              (cons 'define-macro m)))
         definitions)
        (cons 'progn
              (y-macroexpand body)))))
    (progn
      (progn
        (setq y-environment
              (y-apply 'vector
                       (y-almost y-environment)))
        x40))))))
(y-setenv 'let-symbol :macro
          #'(lambda
              (expansions &rest body)
              (if
                  (y-none-p expansions)
                  (cons 'progn
                        (y-macroexpand body))
                (progn
                  (setq y-environment
                        (y-apply 'vector
                                 (append y-environment
                                         (list
                                           (make-hash-table :test 'eq)))))
                  (let*
                    ((x60
                      (progn
                        (mapc
                         #'(lambda
                             (x)
                             (y-macroexpand
                              (cons 'define-symbol x)))
                         (y-pair expansions))
                        (cons 'progn
                              (y-macroexpand body)))))
                    (progn
                      (progn
                        (setq y-environment
                              (y-apply 'vector
                                       (y-almost y-environment)))
                        x60)))))))
(y-setenv 'when-compiling :macro
          #'(lambda
              (&rest body)
              (y-eval
               (cons 'progn body))))
(y-setenv 'let :macro
          #'(lambda
              (bs &rest body)
              (if
                  (and bs
                       (atom bs))
                  (cons 'let
                        (cons
                         (list bs
                               (y-hd body))
                         (y-tl body)))
                (if
                    (y-none-p bs)
                    (cons 'progn body)
                  (let*
                    ((var70 bs))
                    (progn
                      (let*
                        ((lh
                          (y-get var70 '0)))
                        (let*
                          ((rh
                            (y-get var70 '1)))
                          (let*
                            ((bs2
                              (y-cut var70 2)))
                            (let*
                              ((var8
                                (y--bind lh rh)))
                              (let*
                                ((var
                                  (y-get var8 '0)))
                                (let*
                                  ((val
                                    (y-get var8 '1)))
                                  (let*
                                    ((bs1
                                      (y-cut var8 2)))
                                    (progn
                                      (let*
                                        ((renames nil))
                                        (progn
                                          (if
                                              (or
                                               (y--bound-p var)
                                               (y-toplevel-p))
                                              (let*
                                                ((var1
                                                  (y-unique var)))
                                                (progn
                                                  (setq renames
                                                        (list var var1))
                                                  (setq var var1)))
                                            (y-setenv var :variable t))
                                          (let*
                                            ((form
                                               (cons 'let
                                                     (cons
                                                      (y-join bs1 bs2)
                                                      body))))
                                            (progn
                                              (if
                                                  (y-none-p renames)
                                                  nil
                                                (setq form
                                                      (list 'let-symbol renames form)))
                                              (list 'let*
                                                    (list
                                                      (list var val))
                                                    (y-macroexpand form))))))))))))))))))))
(y-setenv 'join! :macro
          #'(lambda
              (a &rest bs)
              (list 'set a
                    (cons 'join
                          (cons a bs)))))
(y-setenv 'inc :macro
          #'(lambda
              (n &optional by)
              (list 'set n
                    (list '+ n
                          (or by 1)))))
(y-setenv 'dec :macro
          #'(lambda
              (n &optional by)
              (list 'set n
                    (list '- n
                          (or by 1)))))
(y-setenv 'for :macro
          #'(lambda
              (i to &rest body)
              (list 'let i 0
                    (cons 'while
                          (cons
                           (list '< i to)
                           (append body
                                   (list
                                     (list 'inc i))))))))
(y-setenv 'step :macro
          #'(lambda
              (v l &rest body)
              (let*
                ((x
                  (y-unique 'x))
                 (n
                  (y-unique 'n))
                 (i
                  (y-unique 'i)))
                (list 'let
                      (list x l n
                            (list '\# x))
                      (list 'for i n
                            (cons 'let
                                  (cons
                                   (list v
                                         (list 'at x i))
                                   body)))))))
(y-setenv 'each :macro
          #'(lambda
              (x l &rest body)
              (let*
                ((o
                  (y-unique 'o))
                 (n
                  (y-unique 'n))
                 (f
                  (y-unique 'f))
                 (a
                  (y-unique 'a)))
                (let*
                  ((var100
                    (if
                        (y-atom-p x)
                        (list
                          (y-unique 'i)
                          x)
                      (if
                          (>
                           (y-length x)
                           1)
                          x
                        (list
                          (y-unique 'i)
                          (y-hd x))))))
                  (progn
                    (let*
                      ((k
                        (y-get var100 '0)))
                      (let*
                        ((v
                          (y-get var100 '1)))
                        (progn
                          (list 'let
                                (list o l f
                                      (list 'lambda
                                            (list k a)
                                            (cons 'let
                                                  (cons
                                                   (list v a)
                                                   body))))
                                (list 'if
                                      (list 'hash-table-p o)
                                      (list 'maphash f o)
                                      (list 'if
                                            (list 'listp o)
                                            (list 'y-%for o k a
                                                  (list 'funcall f k a))
                                            (list 'let n
                                                  (list '\# o)
                                                  (list 'for k n
                                                        (list 'let
                                                              (list a
                                                                    (list 'at o k))
                                                              (list 'funcall f k a))))))))))))))))
  (provide 'y))
