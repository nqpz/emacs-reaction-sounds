;;; -*- lexical-binding: t -*-
;;; emacs-reaction-sounds.el --- function for playing sounds after typing words

;; Written by Niels G. W. Serup (ngws@metanohi.name) in 2016.
;; Available under WTFPL 2.0.

;; Put this in your load-path, and enter (require 'emacs-reaction-sounds) in
;; your init file.
;;
;; Examples:
;;
;;   (ers-add-reaction-sound
;;    "Captain"
;;    "/path/to/tos-intercom-sound.wav"
;;    t)
;;
;;   (ers-add-reaction-sound
;;    "unsafePerformIO"
;;    "/path/to/danger-zone.wav"
;;    (lambda () (string= (buffer-mode) "haskell-mode")))
;;
;; Bugs:
;;
;;   + The sound is played whenever the cursor is at the end of the word, not
;;     just once the word has been typed.
;;
;;   + The string cannot contain spaces.

(defun ers-play-sound-file-in-background (path)
  "Play the sound in PATH in the background."
  ;; It would be nice to just use `play-sound-file', but that function
  ;; blocks.
  (start-process "sound-in-background" nil "mplayer" path))

(defun ers-add-reaction-sound (offending-string sound-file-path condition)
  "Add a reaction sound to be played when the user types a string.
It reacts on OFFENDING-STRING and plays the sound at
SOUND-FILE-PATH.  If CONDITION is a function, evaluate that
function and only play the sound if it returns non-nil; otherwise
ignore CONDITION."
  (add-hook 'after-change-functions
            (lambda (begin end length)
              (let ((cond-actual
                     (if (functionp condition)
                         (funcall condition)
                       t
                       )))
                (if cond-actual
                    (save-excursion
                      (ignore-errors (backward-char 1) t)
                      (unless (looking-at "[[:space:]]")
                        (ignore-errors (backward-sexp 1) t)
                        (if (looking-at (concat "\\<" offending-string "\\>"))
                            (ers-play-sound-file-in-background
                             sound-file-path)))))))
            nil))

(provide 'emacs-reaction-sounds)

;;; emacs-reaction-sounds.el ends here
