#lang racket

(require json)
(require xml)
(require web-server/servlet
         web-server/servlet-env)

(define servers (string->jsexpr (file->string "servers.json")))

; Probably some nicer way to do this that I don't know about yet...
(define all_servers (hash-ref (hash-ref (hash-ref servers 'fonline) 'config) 'server))

; Get a server from all_servers
(define (server_get server)
  (hash-ref all_servers server)
  )
(define (server_key server key)
  (hash-ref (server_get server) key ""))
(define (server_key_exists server key)
  (hash-has-key? (server_get server) key))

; Make pair where server key (used for access the all_servers hash) is the first and second value is the string, later used for sorting.
; (server_key, output_of_proc)
(define (server_key_pair proc)
  (map (lambda (x) (list x (proc x) )) (hash-keys all_servers))
  )

(define (server_attr_pair attr)
  (server_key_pair (lambda (x) (server_key x attr)) )
  )


; Get list of server keys by sorted by some property, e.g 'name
(define (server_keys_by_sorted_attr attr)
  (map (lambda (x) (first x)) (sort (server_attr_pair attr) string<? #:key (lambda (x) (last x))))
  )

(define server_keys (server_keys_by_sorted_attr 'name))


; Helpers to get all properties from server x
(define (server_name server)(server_key server 'name))
(define (server_host server)(server_key server 'host))
(define (server_port server)(server_key server 'port))
(define (server_web server) (server_key server 'website))
(define (server_link server)(server_key server 'link))
(define (server_irc server)(server_key server 'irc))
(define (server_color server)(server_key server 'color))

(define (server_fmt_attr server input expr attr)
  (string-replace input expr (~a (server_key server attr))))

(define (server_fmt server fmt)
  (let ([res fmt])
      (set! res (string-replace res "%key" (~a server)) )
      (set! res (server_fmt_attr server res "%host" 'host))
      (set! res (server_fmt_attr server res "%port" 'port))
      (set! res (server_fmt_attr server res "%irc" 'irc))
      (set! res (server_fmt_attr server res "%link" 'link))
    res
  )
)

;(map (lambda (x) (writeln (server_fmt x "%key -- %host:%port"))) server_keys)

; host:port or ""
(define (server_addr server)
  (if (server_key_exists server 'host)
      (server_fmt server "%host:%port")
      ""
  )
 )

(define (html_href url text) `(a (( href ,url)) ,text))

; Link to server
;(define (server_href x) `(a (( href ,(format "/server/~a" x))) ,(server_key x 'name)) )
(define (server_href x) (html_href (format "/server/~a" x) (server_name x)))
  
(define (include_css name)
  `(link ((rel "stylesheet") (href "style.css")))
  )

(define (html_table_header elems)
  `(tr ,@(for/list ([x elems])
    `(th ,x)))
  )

(define (html_table_row cells)
`(tr ,@(for/list ([x cells])
    `(td ,x ))))

(define (html_table header rows)
  `(table (thead (,@header) ) (tbody ,@rows))
)

; Cells to show for each row.
(define (server_attrs x) 
  (list (server_href x)
        (server_addr x)
        (html_href (server_web x) (server_web x))
  )
)

(define server_rows (map (lambda (x) `,(html_table_row `,(server_attrs x))) server_keys))

(define server_table (html_table
                              (html_table_header '("Name" "IP:Port", "Website"))
                              server_rows
  ))


(define (start req)
  (response/xexpr
   `(html (head (title "FOStatus Config-ed")
                ,(include_css "style.css")) 
          (body (div ((id "content"))
                     (div ((id "edit-area" )) (p "Click on a server to edit config.")
                      ,server_table))))))


(serve/servlet start
               #:port 1500
               #:servlet-path "/"
               #:extra-files-paths (list(build-path "./static" ))
               )