;;; forex.el --- Forex data from google finance  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Md Arif Shaikh

;; Author: Md Arif Shaikh <arifshaikh.astro@gmail.com>
;; Keywords: forex, convenience
;; Version: 0.1.0
;; Homepage: https://github.com/md-arif-shaikh/forex
;; URL: https://github.com/md-arif-shaikh/forex
;; Package-Requires: ((emacs "26.1") (s "1.12.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;; Minima EMACS package to get forex data from google finance.
;;; Get forex rate, convert currency from one to another.

;;; Code:
(require 'dom)
(require 's)

(defvar forex--google-class-alist
  '(("rate" . "YMlKec fxKbKc")
    ("date" . "ygUjEc"))
  "Alist of classes to find neccessary forex data from google finance.")

(defcustom forex-currency-list
  '("KRW" "INR" "USD" "EUR")
  "List of currencies.")

(defun forex--get-forex-item (item dom)
  "Get ITEM in DOM."
  (nth 0 (dom-strings (dom-by-class dom (cdr (assoc item forex--google-class-alist))))))

(defun forex--get-forex-data (from to)
  "Get the forex data from FROM to TO."
  (let* ((url (replace-regexp-in-string " " "-" (format "https://www.google.com/finance/quote/%s-%s" (upcase from) (upcase to)))))
    (with-current-buffer (url-retrieve-synchronously url)
      (let* ((dom (libxml-parse-html-region (point-min) (point-max)))
	     (rate (string-to-number (forex--get-forex-item "rate" dom)))
	     (date (s-left -2 (s-trim-right (forex--get-forex-item "date" dom)))))
	`(("rate" . ,rate)
	  ("date" . ,date))))))

(defun forex-rate (from to)
  "Get forex rate from FROM to TO."
  (interactive
   (let ((from (completing-read "FROM: " forex-currency-list))
	 (to (completing-read "TO :" forex-currency-list)))
     (list from to)))
  (let ((forex-data (forex--get-forex-data from to)))
    (message (format "EXCHANGE RATE %s/%s = %s on %s"
		     (s-upcase from)
		     (s-upcase to)
		     (cdr (assoc "rate" forex-data))
		     (cdr (assoc "date" forex-data))))))

(defun forex-convert (amount from to)
  "Convert AMOUNT from FROM to TO."
  (interactive
   (let ((amount (read-number "AMOUNT: "))
	 (from (completing-read "FROM: " forex-currency-list))
	 (to (completing-read "TO :" forex-currency-list)))
     (list amount from to)))
  (let* ((forex-data (forex--get-forex-data from to))
	 (rate (cdr (assoc "rate" forex-data)))
	 (converted-amount (* amount rate)))
    (message (format "%s %s = %s %s. %s"
		     amount
		     (s-upcase from)
		     converted-amount
		     (s-upcase to)
		     (forex-rate from to)))))

(provide 'forex)
;;; forex.el ends here
