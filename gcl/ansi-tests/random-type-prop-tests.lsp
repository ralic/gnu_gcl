;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Sun Feb 20 11:50:26 2005
;;;; Contains: Randomized tests of type propagation during compilation

(compile-and-load "random-type-prop.lsp")

(in-package :cl-test)

(load "random-type-prop-tests-01.lsp")
(load "random-type-prop-tests-02.lsp")
(load "random-type-prop-tests-03.lsp")
(load "random-type-prop-tests-04.lsp")

