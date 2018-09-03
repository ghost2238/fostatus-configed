#lang racket

(require json)
(require xml)
(require web-server/servlet
         web-server/servlet-env)

(define servers (string->jsexpr (file->string "servers.json")))

; Probably some nicer way to do this that I don't know about yet...
(define all_servers (hash-ref (hash-ref (hash-ref servers 'fonline) 'config) 'server))

; Get server names, convert to list of strings and sort in alphanumerical order
(define names (sort (map ~a (hash-keys all_servers)) string<?))

; Print servers and defined keys
;(for ([server names])
   ;(define xx (map ~a (hash-keys (hash-ref all_servers (string->symbol server)))) )
   ;(printf "~a: ~a\n" server (string-join xx ","))
; )


(define (include_css name)
  `(link ((rel "stylesheet") (href "style.css")))
  )

(define (html_table_header elems)
  `(,@(for/list ([x elems])
    `(th ,x)))
  )

(html_table_header '("Test" "Hoho"))

(define (html_table header rows)
  `(table (thead ,@header) (tbody ,@rows))
)

;(html_table (html_table_header '("Test" "Hoho"))

(define html_server_list (map (lambda (x) `(li ,x)) names))

(include_css "test.css")

(define (start req)
  (response/xexpr
   `(html (head (title "FOStatus Config-ed")
                ,(include_css "style.css")) 
          (body (div ((id "content")) (p ((style "margin-left: 45px")) "Woohoo!")
                      (ol ,@html_server_list)
                          ) ))
                     ))

;(xml->xexpr (document-element
;               (read-xml (open-input-string
;                          "<doc><p attr='abc' attr2='xyz'>test</p></doc>"))))

(serve/servlet start
               #:port 1500
               #:servlet-path "/"
               #:extra-files-paths (list(build-path "./static" ))
               )

;(sort names string<?)
;(define server_names list)
;(for ( ((i) (in-hash-keys all_servers)) )
;  (append (server_names i) )

;(sort (hash-keys all_servers) string>?)
;(define sorted (sort (all_servers string>?s) ))
;sorted
   ;(define server_names list)
   ;(for ([server (hash-keys all_servers)])
   ;    print server
   ;    append (server_names server))

;(for (((server_name props) (in-hash all_servers)))
; (println server_name))