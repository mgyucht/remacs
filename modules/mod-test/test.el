;;; Test GNU Emacs modules.

;; Copyright 2015 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.  */

(require 'ert)

(add-to-list 'load-path (file-name-directory (or #$ (expand-file-name (buffer-file-name)))))
(require 'mod-test)

;;
;; basic tests
;;

(ert-deftest mod-test-sum-test ()
  (should (= (mod-test-sum 1 2) 3)))

(ert-deftest mod-test-sum-docstring ()
  (should (string= (documentation 'mod-test-sum) "Return A + B")))

;;
;; non-local exists (throw, signal)
;;

(ert-deftest mod-test-non-local-exit-signal-test ()
  (should-error (mod-test-signal)))

(ert-deftest mod-test-non-local-exit-throw-test ()
  (should (equal
           (catch 'tag
             (mod-test-throw)
             (ert-fail "expected throw"))
           65)))

(ert-deftest mod-test-non-local-exit-funcall-normal ()
  (should (equal (mod-test-non-local-exit-funcall (lambda () 23))
                 23)))

(ert-deftest mod-test-non-local-exit-funcall-signal ()
  (should (equal (mod-test-non-local-exit-funcall (lambda () (signal 'error '(32))))
                 '(signal error (32)))))

(ert-deftest mod-test-non-local-exit-funcall-throw ()
  (should (equal (mod-test-non-local-exit-funcall (lambda () (throw 'tag 32)))
                 '(throw tag 32))))

;;
;; string
;;

(defun multiply-string (s n)
  (let ((res ""))
    (dotimes (i n res)
      (setq res (concat res s)))))

(ert-deftest mod-test-globref-make-test ()
  (let ((mod-str (mod-test-globref-make))
        (ref-str (multiply-string "abcdefghijklmnopqrstuvwxyz" 100)))
    (garbage-collect) ;; XXX: not enough to really test but it's something..
    (should (string= ref-str mod-str))))

(ert-deftest mod-test-string-a-to-b-test ()
  (should (string= (mod-test-string-a-to-b "aaa") "bbb")))

;;
;; user-pointer
;;

(ert-deftest mod-test-userptr-fun-test ()
  (let* ((n 42)
         (v (mod-test-userptr-make n))
         (r (mod-test-userptr-get v)))

    (should (eq (type-of v) 'user-ptr))
    (should (integerp r))
    (should (= r n))))

;; TODO: try to test finalizer

;;
;; vectors
;;

(ert-deftest mod-test-vector-test ()
  (dolist (s '(2 10 100 1000))
    (dolist (e '(42 foo "foo"))
      (let* ((v-ref (make-vector 2 e))
             (eq-ref (eq (aref v-ref 0) (aref v-ref 1)))
             (v-test (make-vector s nil)))

        (should (eq (mod-test-vector-fill v-test e) t))
        (should (eq (mod-test-vector-eq v-test e) eq-ref))))))